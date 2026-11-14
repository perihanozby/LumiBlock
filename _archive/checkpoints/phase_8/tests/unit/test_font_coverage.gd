extends RefCounted

func run(t) -> void:
	if not ResourceLoader.exists("res://assets/fonts/Manrope.ttf"):
		t.blocked("approved Manrope/Noto font files unavailable; built-in/system fallback is not verified coverage")
		return
	var font: FontFile=load("res://assets/fonts/Manrope.ttf")
	var parser:=JSON.new()
	parser.parse(FileAccess.get_file_as_string("res://assets/fonts/manifest.json"))
	var manifest: Dictionary=parser.data if parser.data is Dictionary else {}
	var families:={"ar":"Arabic","hi":"Devanagari","th":"Thai","ja":"JP","ko":"KR","zh-CN":"SC"}
	var file:=FileAccess.open("res://localization/strings.csv",FileAccess.READ)
	var header:=file.get_csv_line()
	while not file.eof_reached():
		var row:=file.get_csv_line()
		if row.size()!=17: continue
		for index in range(1,17):
			var chain: Array[Font]=[font]
			if families.has(header[index]):
				for path in manifest.get(families[header[index]],[]): chain.append(load(path))
			var value:=row[index]
			for i in value.length():
				var code:=value.unicode_at(i)
				var found:=code in [9,10,13]
				for member in chain:
					if member.has_char(code): found=true; break
				t.check(found,"font glyph %s U+%04X %s" % [header[index],code,row[0]])
