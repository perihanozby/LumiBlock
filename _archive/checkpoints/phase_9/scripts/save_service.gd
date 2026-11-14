extends Node

signal save_failed
signal saved
signal notice(key: String)

const PATH := "user://lumiblock_save.json"
const VERSION := 2
var save_path := PATH
var profile: Dictionary = {}
var saving_disabled := false
var last_save_succeeded := false
var last_notice := ""
var last_write_ms := -1000
var pending: Dictionary = {}
var timer: Timer
var failure_notified := false

func _ready() -> void:
	timer=Timer.new()
	timer.one_shot=true
	timer.timeout.connect(flush)
	add_child(timer)

static func encode_payload(data: Dictionary) -> String:
	return JSON.stringify({"schema":VERSION,"app_version":"0.2.0","saved_at":int(Time.get_unix_time_from_system()),"checksum":SaveSchema.checksum(data),"data":SaveSchema.canonical(data)},"",true,true)

static func decode_payload(raw: String) -> Dictionary:
	var parser := JSON.new()
	if parser.parse(raw)!=OK: return {}
	var parsed: Variant = parser.data
	if not parsed is Dictionary or not parsed.get("data") is Dictionary: return {}
	if parsed.has("schema"):
		if SaveSchema.numeric(parsed.schema)!=VERSION: return {}
		# Godot's decimal parser can shift a double by one ULP. Our writer hashes
		# the exact canonical data bytes; verify those bytes as a fallback, without
		# rounding gameplay data or weakening checksum coverage.
		if parsed.get("checksum")!=SaveSchema.checksum(parsed.data):
			var data_bytes:=raw_data_json(raw)
			var extracted:=JSON.new()
			if parsed.get("checksum")!=data_bytes.sha256_text() or extracted.parse(data_bytes)!=OK or extracted.data!=parsed.data: return {}
		return SaveSchema.validate(parsed.data)
	if SaveSchema.numeric(parsed.get("version",0))==1: return SaveMigrations.from_v1(parsed)
	return {}

static func raw_data_json(raw: String) -> String:
	var depth:=0
	var index:=0
	while index<raw.length():
		var character:=raw[index]
		if character=='"':
			var start:=index
			index+=1
			while index<raw.length():
				if raw[index]=='\\': index+=2
				elif raw[index]=='"': break
				else: index+=1
			var token:=raw.substr(start,index-start+1)
			if depth==1 and token=='"data"':
				var cursor:=index+1
				while cursor<raw.length() and raw[cursor] in [" ","\t","\r","\n"]: cursor+=1
				if cursor>=raw.length() or raw[cursor]!=":":
					index+=1
					continue
				cursor+=1
				while cursor<raw.length() and raw[cursor] in [" ","\t","\r","\n"]: cursor+=1
				var value_start:=cursor
				var nested:=0
				var quoted:=false
				while cursor<raw.length():
					var c:=raw[cursor]
					if quoted:
						if c=='\\': cursor+=1
						elif c=='"': quoted=false
					elif c=='"': quoted=true
					elif c in ["{","["]: nested+=1
					elif c in ["}","]"]:
						nested-=1
						if nested==0: return raw.substr(value_start,cursor-value_start+1)
					cursor+=1
		elif character in ["{","["]: depth+=1
		elif character in ["}","]"]: depth-=1
		index+=1
	return ""

func _announce(key: String) -> void:
	last_notice=key
	notice.emit(key)

func _read(path: String) -> Dictionary:
	var file := FileAccess.open(path,FileAccess.READ)
	if file==null: return {"status":"missing"}
	var raw := file.get_as_text()
	file.close()
	var parser := JSON.new()
	if parser.parse(raw)!=OK: return {"status":"invalid"}
	var parsed: Variant = parser.data
	if not parsed is Dictionary: return {"status":"invalid"}
	if SaveSchema.numeric(parsed.get("schema",parsed.get("version",0)))>VERSION: return {"status":"future"}
	var data := decode_payload(raw)
	if data.is_empty(): return {"status":"invalid"}
	return {"status":"valid","data":data,"v1":not parsed.has("schema")}

func _absolute(path: String) -> String:
	return ProjectSettings.globalize_path(path)

func _backup_path() -> String:
	return save_path.get_basename()+".bak.json"

func load_game() -> Dictionary:
	saving_disabled=false
	last_notice=""
	for path in [save_path,_backup_path()]:
		var loaded := _read(path)
		if loaded.status=="future":
			saving_disabled=true
			profile=SaveSchema.defaults()
			_announce("toast.save_future")
			return profile.duplicate(true)
		if loaded.status=="valid":
			if loaded.v1:
				var original := save_path.get_basename()+".v1.bak.json"
				if not FileAccess.file_exists(original):
					if DirAccess.copy_absolute(_absolute(path),_absolute(original))!=OK:
						saving_disabled=true
						_announce("toast.save_failed")
						profile=loaded.data
						return profile.duplicate(true)
			profile=loaded.data
			if path!=save_path: _announce("toast.save_repaired")
			return profile.duplicate(true)
		if loaded.status=="invalid":
			var quarantine := save_path.get_basename()+".corrupt.%d.%d.json" % [int(Time.get_unix_time_from_system()),Time.get_ticks_usec()]
			if DirAccess.rename_absolute(_absolute(path),_absolute(quarantine))!=OK:
				saving_disabled=true
				_announce("toast.save_failed")
				profile=SaveSchema.defaults()
				return profile.duplicate(true)
			last_notice="toast.save_unreadable"
	profile=SaveSchema.defaults()
	if last_notice=="toast.save_unreadable": _announce(last_notice)
	return profile.duplicate(true)

func rename_file(source: String, destination: String) -> Error:
	return DirAccess.rename_absolute(_absolute(source),_absolute(destination))

func _fail() -> bool:
	last_save_succeeded=false
	save_failed.emit()
	if not failure_notified:
		failure_notified=true
		_announce("toast.save_failed")
	return false

func save_game(data: Dictionary, force: bool = false) -> bool:
	if saving_disabled:
		last_save_succeeded=false
		return false
	profile=SaveSchema.validate(data)
	if not force and timer!=null and Time.get_ticks_msec()-last_write_ms<250:
		pending=profile.duplicate(true)
		timer.start(maxf(0.001,(250-(Time.get_ticks_msec()-last_write_ms))/1000.0))
		return true
	var temp := save_path+".tmp"
	var file := FileAccess.open(temp,FileAccess.WRITE)
	if file==null: return _fail()
	file.store_string(encode_payload(profile))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error!=OK: return _fail()
	var verified := _read(temp)
	if verified.status!="valid": return _fail()
	var existed := FileAccess.file_exists(save_path)
	if existed:
		var current := _read(save_path)
		if current.status=="future":
			saving_disabled=true
			_announce("toast.save_future")
			return _fail()
		if current.status!="valid": return _fail()
		if current.v1:
			var original := save_path.get_basename()+".v1.bak.json"
			if not FileAccess.file_exists(original) and DirAccess.copy_absolute(_absolute(save_path),_absolute(original))!=OK: return _fail()
		if DirAccess.copy_absolute(_absolute(save_path),_absolute(_backup_path()))!=OK: return _fail()
		if DirAccess.remove_absolute(_absolute(save_path))!=OK: return _fail()
	if rename_file(temp,save_path)!=OK:
		if existed:
			var recovery := DirAccess.copy_absolute(_absolute(_backup_path()),_absolute(save_path))
			if recovery!=OK: _announce("toast.save_failed")
		return _fail()
	last_write_ms=Time.get_ticks_msec()
	last_save_succeeded=true
	failure_notified=false
	pending.clear()
	if timer!=null: timer.stop()
	saved.emit()
	return true

func flush() -> void:
	if not pending.is_empty(): save_game(pending,true)

# Transitional adapter for the single-scene prototype; AppRoot will use v2 directly.
func load_legacy_game() -> Dictionary:
	var data := load_game()
	var sessions := {}
	for mode in ["classic","daily"]:
		if not data.sessions[mode] is Dictionary: continue
		var session: Dictionary = data.sessions[mode]
		var tray: Array = []
		for entry in session.tray:
			tray.append(null if entry==null else PieceGenerator.make_piece(entry.shape_id,entry.color).to_dict())
		sessions[mode]={"active":session.state=="active","state":session.state,"mode":mode,"date":session.date,"score":session.score,"combo":session.streak,"daily_lines":session.lines,"rng_state":0,"board":{"cells":session.board},"tray":tray}
	return {"best":data.records.best_classic,"stats":{"games":data.stats.games_finished,"lines":data.stats.lines_cleared,"best_combo":data.records.best_combo,"play_time":float(data.stats.play_seconds)},"settings":{"sound":data.settings.sfx,"music":data.settings.music,"haptics":data.settings.haptics,"reduced_effects":data.settings.effects=="minimal","language":data.settings.language},"sessions":sessions,"active_mode":"classic"}

func save_legacy_game(data: Dictionary, force: bool = false) -> bool:
	var migrated := SaveMigrations.from_v1({"version":1,"data":data})
	var merged := profile.duplicate(true) if not profile.is_empty() else SaveSchema.defaults()
	merged.records.best_classic=migrated.records.best_classic
	merged.records.best_combo=migrated.records.best_combo
	for key in ["games_finished","lines_cleared","play_seconds"]: merged.stats[key]=migrated.stats[key]
	for key in ["sfx","music","haptics","effects","reduce_motion","language"]: merged.settings[key]=migrated.settings[key]
	merged.sessions=migrated.sessions
	return save_game(merged,force)
