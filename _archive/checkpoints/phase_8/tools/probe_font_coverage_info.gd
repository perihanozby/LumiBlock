extends SceneTree
func _init() -> void:
	var font: FontFile=load("res://assets/fonts/Manrope.ttf")
	for pair in [["Latin-Ext",0x130],["Cyrillic",0x416],["Greek",0x3a9],["Vietnamese",0x1ed9]]: print("Manrope %s U+%04X=%s" % [pair[0],pair[1],font.has_char(pair[1])])
	print("Variation axes: "+str(font.get_supported_variation_list()))
	quit()
