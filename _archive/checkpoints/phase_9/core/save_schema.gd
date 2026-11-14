class_name SaveSchema
extends RefCounted

const LANGUAGES := ["system","en","tr","es","pt-BR","fr","de","it","ja","ko","zh-CN","ar","hi","id","vi","ru","th"]

static func defaults() -> Dictionary:
	return {"settings":{"language":"system","sfx":true,"music":true,"sfx_volume":0.8,"music_volume":0.6,"haptics":true,"effects":"balanced","reduce_motion":false,"placement_assist":true,"colorblind_marks":false,"text_scale":1.0},"records":{"best_classic":0,"best_daily":0,"best_combo":0},"stats":{"games_started":0,"games_finished":0,"games_abandoned":0,"lines_cleared":0,"pieces_placed":0,"perfect_clears":0,"play_seconds":0,"daily_completed":0,"daily_streak":0,"daily_best_streak":0},"history":[],"daily":{"completed":{},"last_streak_date":""},"sessions":{"classic":null,"daily":null},"flags":{"tutorial_done":false}}

static func numeric(value: Variant, fallback: float = 0.0) -> float:
	if value is int or value is float:
		if is_finite(float(value)): return float(value)
	return fallback

static func nonnegative(value: Variant) -> int:
	return int(clampf(numeric(value),0,9007199254740991))

static func boolean(value: Variant, fallback: bool) -> bool:
	if value is bool: return value
	if value is int or value is float: return value != 0
	return fallback

static func merge_defaults(default_data: Dictionary, raw: Dictionary) -> Dictionary:
	var result := raw.duplicate(true)
	for key in default_data:
		if not result.has(key): result[key]=default_data[key]
		elif default_data[key] is Dictionary:
			result[key]=merge_defaults(default_data[key],result[key] if result[key] is Dictionary else {})
	return result

static func validate(raw: Dictionary) -> Dictionary:
	var defaults_data := defaults()
	var result := merge_defaults(defaults_data,canonical(raw))
	var settings: Dictionary = result.settings
	for key in ["sfx","music","haptics","reduce_motion","placement_assist","colorblind_marks"]: settings[key]=boolean(settings[key],defaults_data.settings[key])
	for key in ["sfx_volume","music_volume"]: settings[key]=clampf(numeric(settings[key],defaults_data.settings[key]),0,1)
	if not settings.language in LANGUAGES: settings.language="system"
	if not settings.effects in ["minimal","balanced","rich"]: settings.effects="balanced"
	settings.text_scale=1.15 if numeric(settings.text_scale)==1.15 else 1.0
	for section in ["records","stats"]:
		for key in defaults_data[section]: result[section][key]=nonnegative(result[section][key])
	result.flags.tutorial_done=boolean(result.flags.tutorial_done,false)
	if not result.history is Array: result.history=[]
	var history: Array = []
	for entry in result.history:
		if not entry is Dictionary: continue
		var copy: Dictionary = entry.duplicate(true)
		for key in ["ts","score","lines","max_combo","pieces","seconds"]: copy[key]=nonnegative(copy.get(key,0))
		if not copy.get("mode","") in ["classic","daily"]: copy.mode="classic"
		if not copy.get("result","") in ["over","completed","failed","expired","abandoned"]: copy.result="over"
		history.append(copy)
		if history.size()==30: break
	result.history=history
	for mode in ["classic","daily"]:
		var data: Variant = result.sessions[mode]
		if data is Dictionary:
			var clean: Dictionary = data.duplicate(true)
			for key in ["score","streak","grace","lines","pieces","max_combo","stream_index","started_at"]: clean[key]=nonnegative(clean.get(key,0))
			clean.elapsed_s=maxf(0,numeric(clean.get("elapsed_s",0)))
			clean.rng_state=int(numeric(clean.get("rng_state",1)))&SeededRng.MASK
			clean.mode=mode
			clean.state="finished" if clean.get("state", "active")=="finished" else "active"
			clean.id=str(clean.get("id","restored-%s-%d" % [mode,clean.started_at]))
			clean.date=str(clean.get("date",""))
			clean.result=str(clean.get("result",""))
			if clean.result not in ["","over","completed","failed","expired","abandoned"]: clean.result=""
			var original_tray: Array = clean.get("tray",[]) if clean.get("tray") is Array else []
			var session := GameSession.from_dict(clean)
			clean.merge(session.to_dict(),true)
			for slot in 3:
				if slot<original_tray.size() and original_tray[slot] is Dictionary and clean.tray[slot] is Dictionary:
					var piece_data: Dictionary = original_tray[slot].duplicate(true)
					piece_data.merge(clean.tray[slot],true)
					clean.tray[slot]=piece_data
			result.sessions[mode]=clean
		else: result.sessions[mode]=null
	if not result.daily.completed is Dictionary: result.daily.completed={}
	var completed: Dictionary = {}
	for date in result.daily.completed:
		var entry: Variant = result.daily.completed[date]
		if date is String and valid_date(date) and entry is Dictionary:
			var copy: Dictionary = entry.duplicate(true)
			for key in ["score","seconds","ts"]: copy[key]=nonnegative(entry.get(key,0))
			completed[date]=copy
	result.daily.completed=completed
	if not result.daily.last_streak_date is String or (result.daily.last_streak_date!="" and not valid_date(result.daily.last_streak_date)): result.daily.last_streak_date=""
	return result

static func valid_date(value: String) -> bool:
	if value.length()!=10 or value[4]!="-" or value[7]!="-": return false
	var parts := value.split("-")
	if parts.size()!=3 or not parts[0].is_valid_int() or not parts[1].is_valid_int() or not parts[2].is_valid_int(): return false
	var month := int(parts[1])
	var day := int(parts[2])
	var year := int(parts[0])
	if month<1 or month>12 or year<1: return false
	var lengths: Array[int] = [31,29 if year%4==0 and (year%100!=0 or year%400==0) else 28,31,30,31,30,31,31,30,31,30,31]
	return day>=1 and day<=lengths[month-1]

static func canonical(value: Variant) -> Variant:
	if value is float and is_finite(value) and absf(value)<9007199254740992.0 and value==floor(value): return int(value)
	if value is Dictionary:
		var result := {}
		var keys: Array = value.keys()
		keys.sort_custom(func(a,b): return str(a)<str(b))
		for key in keys: result[str(key)]=canonical(value[key])
		return result
	if value is Array:
		var result: Array = []
		for entry in value: result.append(canonical(entry))
		return result
	return value

static func canonical_json(value: Variant) -> String:
	return JSON.stringify(canonical(value),"",true,true)

static func checksum(data: Dictionary) -> String:
	return canonical_json(data).sha256_text()
