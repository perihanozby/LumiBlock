extends Node

const SaveTools=preload("res://tests/save_test_tools.gd")
const Bot=preload("res://tests/greedy_bot.gd")
const DragTools=preload("res://tests/ui/drag_test_tools.gd")
var failed:=false
var frames: Array[float]=[]

func _ready() -> void:
	call_deferred("run")

func snapshot() -> Dictionary:
	return {"nodes":Performance.get_monitor(Performance.OBJECT_NODE_COUNT),"orphans":Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT),"resources":Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT),"static_bytes":Performance.get_monitor(Performance.MEMORY_STATIC),"fps":Engine.get_frames_per_second(),"frame_ms":Performance.get_monitor(Performance.TIME_PROCESS)*1000,"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)}

func run() -> void:
	var temporary=SaveTools.service("stress_ui")
	SaveService.save_path=temporary.save_path
	temporary.free()
	SaveService.profile=SaveSchema.defaults()
	SettingsService.values=SaveService.profile.settings.duplicate(true)
	SettingsService.values.effects="rich"
	SettingsService.values.sfx=false
	SettingsService.values.music=false
	var app=load("res://app/app_root.tscn").instantiate()
	app.date_provider=func(): return "2026-11-15"
	add_child(app)
	var samples: Array=[]
	var total_moves:=0
	for index in 51:
		app.seed_provider=func(): return 10000+index
		app.router.settle_transition()
		app.start_game("classic",true)
		app.router.settle_transition()
		var game: GameScreen=app.router.current
		var moves:=0
		while app.session.state=="active" and moves<2000:
			var selected:=Bot.move(app.session)
			if selected.slot<0:
				failed=true
				break
			game.drag.lock_until_ms=0
			var target:=DragTools.target(game,selected.slot,selected.origin)
			var before: int=app.session.pieces
			DragTools.touch(game.drag,game.metrics.slots[selected.slot].get_center(),true)
			DragTools.motion(game.drag,target)
			DragTools.touch(game.drag,target,false)
			if app.session.pieces!=before+1: failed=true
			moves+=1
			total_moves+=1
			await get_tree().process_frame
			frames.append(Performance.get_monitor(Performance.TIME_PROCESS)*1000)
			if game.fx.sparks.size()>120: failed=true
		if app.session.state!="finished": failed=true
		app.show_screen("home")
		app.router.settle_transition()
		await get_tree().create_timer(0.55).timeout
		await get_tree().process_frame
		var sample:=snapshot()
		sample.game=index
		sample.moves=moves
		samples.append(sample)
		print("STRESS ",JSON.stringify(sample))
		if sample.orphans!=0: failed=true
	var baseline: Dictionary=samples[1]
	var final: Dictionary=samples[-1]
	var growth: float=final.static_bytes-baseline.static_bytes
	if growth>15*1024*1024 or final.nodes!=baseline.nodes: failed=true
	frames.sort()
	var report:={"games":50,"warmup_games":1,"moves":total_moves,"effects":"rich","samples":samples,"static_growth_bytes":growth,"frame_ms_p50":frames[frames.size()/2],"frame_ms_p95":frames[int(frames.size()*0.95)],"failed":failed,"scope":"Desktop real drag controller; one rendered frame per move; not phone performance or human pacing."}
	var file:=FileAccess.open("res://build/evidence/stress-ui.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"\t"))
	file.close()
	app.queue_free()
	AudioService.stop_all()
	await get_tree().create_timer(0.15).timeout
	print("Stress UI: 50 games + warmup, ",total_moves," moves; growth=",growth," bytes; failed=",failed)
	get_tree().quit(1 if failed else 0)
