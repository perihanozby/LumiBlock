class_name FxController
extends Control

var effects: Array=[]
var sparks: Array=[]
var tweens: Array[Tween]=[]
var metrics: Dictionary={}
var reduced:=false
var max_sparks:=120
var elapsed:=0.0
var popup_text:=""
var popup_age:=1.0
var popup_duration:=0.5
var glow_strength:=0.0
var glow_family:=0

func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	SettingsService.changed.connect(func(key,_value):
		if key in ["reduce_motion","effects"]: cancel_all())
	set_process(false)

func placement(piece: PieceModel,origin: Vector2i,info: Dictionary,layout: Dictionary) -> void:
	metrics=layout
	reduced=SettingsService.reduce_motion()
	var positions: Array[Vector2i]=[]
	for cell in piece.shape: positions.append(origin+cell)
	effects.append({"kind":"settle","cells":positions,"family":piece.color,"age":0.0,"duration":0.06 if reduced else 0.16})
	if info.lines>0:
		effects.append({"kind":"clear","cells":info.cleared.duplicate(),"family":piece.color,"age":0.0,"duration":0.12 if reduced else 0.52})
		var count:=0 if reduced or SettingsService.values.effects=="minimal" else (4 if SettingsService.values.effects=="balanced" else 10)
		for i in mini(count*info.lines,max_sparks-sparks.size()):
			var cell: Vector2i=info.cleared[i%info.cleared.size()]
			sparks.append({"position":metrics.board_origin+(Vector2(cell)+Vector2.ONE*0.5)*metrics.pitch,"velocity":Vector2(cos(i*2.4),sin(i*2.4))*48,"age":0.0,"family":piece.color})
	set_process(true)
	queue_redraw()

func celebrate(streak: int,family: int,perfect: bool,gain: int) -> void:
	glow_family=family
	glow_strength=minf(0.3,maxf(0,streak-1)/6.0*0.3)
	if perfect: glow_strength=0.3
	popup_text="+"+str(gain)
	popup_age=0
	popup_duration=0.12 if SettingsService.reduce_motion() else 0.5
	set_process(true)
	queue_redraw()

func tween_node(node: Node,property: NodePath,target: Variant,duration: float) -> Tween:
	var tween:=create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tweens.append(tween)
	tween.tween_property(node,property,target,minf(duration,0.12) if SettingsService.reduce_motion() else duration)
	tween.finished.connect(func(): tweens.erase(tween))
	return tween

func cancel_all() -> void:
	for tween in tweens:
		if tween!=null and tween.is_valid(): tween.kill()
	tweens.clear()
	effects.clear()
	sparks.clear()
	popup_age=1
	glow_strength=0
	set_process(false)
	queue_redraw()

func _process(delta: float) -> void:
	popup_age+=delta
	for effect in effects: effect.age+=delta
	effects=effects.filter(func(effect): return effect.age<effect.duration)
	for spark in sparks:
		spark.age+=delta
		spark.position+=spark.velocity*delta
	sparks=sparks.filter(func(spark): return spark.age<0.45)
	queue_redraw()
	if effects.is_empty() and sparks.is_empty() and popup_age>=popup_duration: set_process(false)

func _draw() -> void:
	if metrics.is_empty(): return
	var atlas:=PieceView.texture()
	if glow_strength>0:
		var glow_color: Color=Tokens.FAMILIES[glow_family].glow
		glow_color.a=glow_strength
		draw_texture_rect_region(atlas,metrics.board_rect.grow(12),Rect2(384,640,128,128),glow_color)
	for effect in effects:
		for i in effect.cells.size():
			var cell: Vector2i=effect.cells[i]
			var rect:=Rect2(metrics.board_origin+Vector2(cell)*metrics.pitch,Vector2.ONE*metrics.pitch)
			var fraction: float=clampf(effect.age/effect.duration,0,1)
			var tint:=Color.WHITE
			if effect.kind=="clear":
				if not reduced:
					fraction=clampf((effect.age-minf(i*0.018,0.12))/0.36,0,1)
					rect=rect.grow(-metrics.pitch*0.2*fraction)
				tint.a=1-fraction
				draw_texture_rect_region(atlas,rect,Rect2(0,effect.family*128,128,128),tint)
				if not reduced and effect.age<0.08: draw_texture_rect_region(atlas,rect,Rect2(256,640,128,128),Color(1,1,1,0.6*(1-effect.age/0.08)))
			elif not reduced:
				var scale_factor: float=1+0.04*sin(PI*fraction)
				rect=rect.grow(metrics.pitch*(scale_factor-1)*0.5)
				draw_texture_rect_region(atlas,rect,Rect2(0,effect.family*128,128,128))
				if effect.age<0.09: draw_texture_rect_region(atlas,rect,Rect2(256,640,128,128),Color(1,1,1,0.25*(1-effect.age/0.09)))
	for spark in sparks:
		var color: Color=Tokens.FAMILIES[spark.family].glow
		color.a=1-spark.age/0.45
		draw_circle(spark.position,2,color)
	if popup_age<popup_duration:
		var fraction:=popup_age/popup_duration
		var color:=Tokens.TEXT_TITLE
		color.a=1-fraction
		var position: Vector2=metrics.board_rect.get_center()
		if not reduced: position.y-=24*fraction
		draw_string(ThemeDB.fallback_font,position,popup_text,HORIZONTAL_ALIGNMENT_CENTER,-1,Tokens.FONT_SIZES.title,color)
