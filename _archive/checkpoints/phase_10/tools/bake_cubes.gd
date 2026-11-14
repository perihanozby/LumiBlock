extends SceneTree

const S := 128

static func sdf(p: Vector2) -> float:
	var q:=p.abs()-Vector2.ONE*31
	return q.max(Vector2.ZERO).length()+minf(maxf(q.x,q.y),0)-28

static func oklab(c: Color) -> Vector3:
	var rgb:=ColorMath.linear_rgb(c)
	var l:=pow(rgb.dot(Vector3(0.4122214708,0.5363325363,0.0514459929)),1.0/3)
	var m:=pow(rgb.dot(Vector3(0.2119034982,0.6806995451,0.1073969566)),1.0/3)
	var s:=pow(rgb.dot(Vector3(0.0883024619,0.2817188376,0.6299787005)),1.0/3)
	return Vector3(0.2104542553*l+0.793617785*m-0.0040720468*s,1.9779984951*l-2.428592205*m+0.4505937099*s,0.0259040371*l+0.7827717662*m-0.808675766*s)

static func from_lab(v: Vector3) -> Color:
	var l:=pow(v.x+0.3963377774*v.y+0.2158037573*v.z,3)
	var m:=pow(v.x-0.1055613458*v.y-0.0638541728*v.z,3)
	var s:=pow(v.x-0.0894841775*v.y-1.291485548*v.z,3)
	return Color(4.0767416621*l-3.3077115913*m+0.2309699292*s,-1.2684380046*l+2.6097574011*m-0.3413193965*s,-0.0041960863*l-0.7034186147*m+1.707614701*s).linear_to_srgb()

static func mark_alpha(p: Vector2, family: int) -> float:
	var d:=0.0
	match family:
		0: d=p.length()-7
		1: d=(absf(p.x)+absf(p.y)-12)/sqrt(2)
		2: d=maxf(p.y-10,maxf(-p.x*0.866-p.y*0.5-6,p.x*0.866-p.y*0.5-6))
		3: d=maxf(absf(p.x),absf(p.y))-9
		4: d=minf(maxf(absf(p.x)-3,absf(p.y)-12),maxf(absf(p.x)-12,absf(p.y)-3))
	return clampf(0.5-d,0,1)*0.55

static func bake() -> Dictionary:
	var image:=Image.create(S*4,S*6,false,Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var rects: Dictionary={}
	# Gradient lookup is computed in OKLab once per subpixel scanline.
	var gradients: Array=[]
	for family in Tokens.FAMILIES:
		var gradient: Array[Color]=[]
		for sy in S*4:
			var t:=clampf(((sy+0.5)/4-5)/118.0,0,1)
			var first: Color=family.light if t<0.45 else family.base
			var second: Color=family.base if t<0.45 else family.dark
			var local:=t/0.45 if t<0.45 else (t-0.45)/0.55
			gradient.append(from_lab(oklab(first).lerp(oklab(second),smoothstep(0,1,local))))
		gradients.append(gradient)
	for row in 6:
		for col in 4:
			rects["%d_%d" % [row,col]]=[col*S,row*S,S,S]
			if row<5 and col==3: continue
			for y in S:
				for x in S:
					var accum:=Color(0,0,0,0)
					for oy in 4:
						for ox in 4:
							var p:=Vector2(x+(ox+0.5)/4.0,y+(oy+0.5)/4.0)-Vector2.ONE*64
							var distance:=sdf(p)
							var alpha:=clampf(0.5-distance,0,1)
							var color:=Color.TRANSPARENT
							if row<5 and alpha>0:
								var family: Dictionary=Tokens.FAMILIES[row]
								color=gradients[row][y*4+oy]
								if col==2: color=color.lightened(0.04)
								var rim:=clampf(1-absf(p.y+58)/2,0,1)*0.28*clampf((47-absf(p.x))/12,0,1)
								color=color.lerp(Color.WHITE,rim)
								color=color.darkened(smoothstep(52,59,p.y)*0.22)
								var spec:=Vector2((p.x+23)/38.4,(p.y+30.7)/20.5)
								color=color.lerp(Color.WHITE,exp(-spec.length_squared()*2)*0.10)
								color=color.lerp(family.edge,clampf(1.5+distance,0,1)*0.35)
								if col==1: color=color.lerp(family.dark,mark_alpha(p,row))
								color.a=alpha
							elif row==5:
								match col:
									0:
										color=Tokens.CELL_EMPTY.darkened((1-smoothstep(-59,-56,p.y))*0.35)
										color=color.lerp(Color.WHITE,smoothstep(57,59,p.y)*0.06)
										color.a=alpha
									1: color=Color(1,1,1,alpha*0.35 if fposmod(p.x+p.y,14)<2 else 0)
									2: color=Color(1,1,1,alpha)
									3: color=Color(1,1,1,exp(-p.length_squared()/(2*24*24))*clampf((64-p.length())/8,0,1))
							accum+=Color(color.r*color.a,color.g*color.a,color.b*color.a,color.a)/16.0
					if accum.a>0: accum=Color(accum.r/accum.a,accum.g/accum.a,accum.b/accum.a,accum.a)
					image.set_pixel(col*S+x,row*S+y,accum)
	return {"image":image,"rects":rects}

func _init() -> void:
	var result:=bake()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/cubes"))
	var error: int=result.image.save_png("res://assets/cubes/cube_atlas.png")
	var file:=FileAccess.open("res://assets/cubes/cube_atlas.json",FileAccess.WRITE)
	if file!=null:
		file.store_string(JSON.stringify(result.rects,"",true))
		file.close()
	else: error=ERR_CANT_CREATE
	print("Atlas bake: "+str(error)+" size="+str(result.image.get_size()))
	quit(0 if error==OK else 1)
