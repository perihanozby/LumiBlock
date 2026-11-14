extends SceneTree

func _init() -> void:
	var directory:="res://docs/review/REVIEW_PACK_1/"
	var contact:=Image.create(780,1688,false,Image.FORMAT_RGBA8)
	contact.fill(Tokens.BG_0)
	var locales:=["en","tr","es","pt-BR","fr","de","it","ja","ko","zh-CN","ar","hi","id","vi","ru","th"]
	for i in locales.size():
		var source:=Image.new()
		var error:=source.load_png_from_buffer(FileAccess.get_file_as_bytes(directory+"home_%s_390x844.png" % locales[i]))
		if error!=OK:
			print("FAIL contact source "+locales[i])
			quit(1)
			return
		source.resize(195,422,Image.INTERPOLATE_LANCZOS)
		contact.blit_rect(source,Rect2i(0,0,195,422),Vector2i((i%4)*195,(i/4)*422))
	var error:=contact.save_png(directory+"locale_contact_sheet.png")
	print("Locale contact sheet: "+str(error)+" 780x1688; row-major en,tr,es,pt-BR / fr,de,it,ja / ko,zh-CN,ar,hi / id,vi,ru,th")
	quit(0 if error==OK else 1)
