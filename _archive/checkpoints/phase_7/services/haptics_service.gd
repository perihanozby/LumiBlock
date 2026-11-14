extends Node

var request_count:=0
var emitted_count:=0
var driver: Callable
var clock: Callable
var mobile_override: Variant=null
var last_request_ms:=-1000
var queue: Array=[]
var due_ms:=0

func _ready() -> void:
	set_process(false)
	SettingsService.changed.connect(func(key,value):
		if key=="haptics":
			if value: pulse("tap")
			else: queue.clear())

static func pattern(kind: String,amount: int = 1) -> Array:
	match kind:
		"tap": return [[8,0.2,0]]
		"pickup": return [[12,0.3,0]]
		"place": return [[18,0.5,0]]
		"deny": return [[10,0.25,40],[10,0.25,0]]
		"perfect": return [[40,0.7,0]]
		"record": return [[25,0.5,40],[25,0.5,0]]
		"over": return [[60,0.4,0]]
		"daily_done": return [[20,0.6,45],[20,0.6,45],[20,0.6,0]]
		"clear":
			if amount<=1: return [[28,0.6,0]]
			var result: Array=[]
			for i in mini(amount,5): result.append([30+mini(i,2)*10,0.6,50])
			return result
		"combo":
			var result: Array=[]
			for i in mini(amount,3): result.append([20,minf(0.8,0.5+i*0.15),45])
			return result
	return []

func now() -> int:
	return clock.call() if clock.is_valid() else Time.get_ticks_msec()

func pulse(kind: String, amount: int = 1) -> void:
	if not SettingsService.values.get("haptics",false): return
	request_count+=1
	var mobile: bool=mobile_override if mobile_override!=null else OS.get_name() in ["Android","iOS"]
	if not mobile or now()-last_request_ms<40: return
	last_request_ms=now()
	queue=pattern(kind,amount)
	due_ms=now()
	set_process(true)
	_process(0)

func _process(_delta: float) -> void:
	if queue.is_empty():
		set_process(false)
		return
	if now()<due_ms: return
	if not SettingsService.values.get("haptics",false):
		queue.clear()
		return
	var step: Array=queue.pop_front()
	if driver.is_valid(): driver.call(step[0],step[1])
	else: Input.vibrate_handheld(step[0],step[1])
	emitted_count+=1
	due_ms=now()+int(step[0])+int(step[2])
	if queue.is_empty(): set_process(false)
