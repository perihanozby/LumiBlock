extends RefCounted

func run(t) -> void:
	var file:=FileAccess.open("res://localization/strings.csv",FileAccess.READ)
	t.check(file!=null,"CSV exists")
	if file==null: return
	var header:=file.get_csv_line()
	t.check_eq(header.size(),17,"17 CSV columns")
	var keys: Dictionary={}
	while not file.eof_reached():
		var row:=file.get_csv_line()
		if row.size()==1 and row[0]=="": continue
		t.check_eq(row.size(),17,"row width")
		if row.size()!=17: continue
		t.check(not keys.has(row[0]),"unique key "+row[0])
		keys[row[0]]=true
		var regex:=RegEx.new()
		regex.compile("\\{[a-z]+\\}")
		var source: Array=[]
		for match in regex.search_all(row[1]): source.append(match.get_string())
		source.sort()
		for value in row.slice(1):
			t.check(not value.is_empty(),"nonempty "+row[0])
			var placeholders: Array=[]
			for match in regex.search_all(value): placeholders.append(match.get_string())
			placeholders.sort()
			t.check_eq(placeholders,source,"matching placeholders "+row[0])
	file.close()
	var registered: PackedStringArray=ProjectSettings.get_setting("internationalization/locale/translations",PackedStringArray())
	t.check_eq(registered.size(),16,"16 registered translations")
	for path in registered: t.check(ResourceLoader.exists(path),"translation exists "+path)
	t.check_eq(ProjectSettings.get_setting("internationalization/locale/fallback"),"en","English fallback")
	_scan_keys("res://ui",keys,t)

func _scan_keys(path: String,keys: Dictionary,t) -> void:
	for file in DirAccess.get_files_at(path):
		if not file.ends_with(".gd"): continue
		var source:=FileAccess.get_file_as_string(path+"/"+file)
		var regex:=RegEx.new()
		regex.compile('tr\\("([a-z][a-z0-9_.]+)"\\)')
		for match in regex.search_all(source): t.check(keys.has(match.get_string(1)),"defined UI key "+match.get_string(1))
		var literals:=RegEx.new()
		literals.compile('\\.text\\s*=\\s*"[^"\\n]+"')
		t.check(literals.search(source)==null,"no direct UI text literal "+file)
	for directory in DirAccess.get_directories_at(path): _scan_keys(path+"/"+directory,keys,t)
