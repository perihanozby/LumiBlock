extends SceneTree

func _init() -> void:
	var folder:="res://assets/icons/android/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var cubes:=""
	for index in 4:
		var x:=132+(index%2)*128
		var y:=132+(index/2)*128
		var family: Dictionary=Tokens.FAMILIES[index]
		cubes+='<rect x="%d" y="%d" width="116" height="116" rx="26" fill="#%s"/><path d="M%d %d h64" stroke="#%s" stroke-width="5" stroke-linecap="round" opacity=".7"/>' % [x,y,family.base.to_html(false),x+26,y+10,family.light.to_html(false)]
	var foreground:='<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">'+cubes+'</svg>'
	var background:='<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512"><rect width="512" height="512" fill="#0C121D"/></svg>'
	var complete:=background.replace('</svg>',cubes+'</svg>')
	var failed:=false
	for item in [["icon_512.png",512,complete],["main_192.png",192,complete],["foreground_432.png",432,foreground],["background_432.png",432,background],["monochrome_432.png",432,foreground.replace('#61afff','#ffffff').replace('#5bcebb','#ffffff').replace('#9d7caf','#ffffff').replace('#d06f6b','#ffffff')]]:
		var image:=Image.new()
		var error:=image.load_svg_from_string(item[2],float(item[1])/512)
		if error!=OK or image.save_png(folder+item[0])!=OK: failed=true
	for property in ProjectSettings.get_property_list():
		if str(property.name).begins_with("application/boot_splash/"): print("SPLASH ",JSON.stringify(property))
	for key in ["application/boot_splash/bg_color","application/boot_splash/image","application/boot_splash/show_image"]:
		if not ProjectSettings.has_setting(key):
			print("FAIL missing project splash option: ",key)
			failed=true
	ProjectSettings.set_setting("application/boot_splash/bg_color",Tokens.BG_0)
	ProjectSettings.set_setting("application/boot_splash/image",folder+"main_192.png")
	ProjectSettings.set_setting("application/boot_splash/show_image",true)
	ProjectSettings.set_setting("application/boot_splash/stretch_mode",1)
	ProjectSettings.set_setting("application/config/icon",folder+"icon_512.png")
	if not failed and ProjectSettings.save()!=OK: failed=true
	print("Android icons/splash: ","FAIL" if failed else "PASS; five PNGs + verified boot-splash project settings")
	quit(1 if failed else 0)
