extends Node

const SaveTools = preload("res://tests/save_test_tools.gd")
const Bot = preload("res://tests/greedy_bot.gd")
const DragTools = preload("res://tests/ui/drag_test_tools.gd")

var app: Control
var output:="res://docs/review/REVIEW_PACK_1"
var failed:=false

func _ready() -> void:
	call_deferred("capture_all")

func capture_all() -> void:
	if "--pack2" in OS.get_cmdline_user_args(): output="res://docs/review/REVIEW_PACK_2"
	if "--actual" in OS.get_cmdline_user_args(): output="res://tests/screenshots/actual/final"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	var temporary=SaveTools.service("review_capture")
	SaveService.save_path=temporary.save_path
	temporary.free()
	SaveService.last_notice=""
	SaveService.saving_disabled=false
	SaveService.failure_notified=false
	SaveService.pending.clear()
	SaveService.timer.stop()
	SaveService.notice.connect(func(key):
		if key=="toast.save_failed":
			failed=true
			push_error("Capture fixture save failed: "+SaveService.save_path))
	SaveService.profile=SaveSchema.defaults()
	SettingsService.values=SaveService.profile.settings.duplicate(true)
	SettingsService.values.reduce_motion=true
	SettingsService.values.sfx=false
	SettingsService.values.music=false
	SaveService.profile.settings=SettingsService.values.duplicate(true)
	LocalizationService.apply_language("en")
	app=load("res://app/app_root.tscn").instantiate()
	app.seed_provider=func(): return 12345
	app.date_provider=func(): return "2026-11-15"
	add_child(app)
	var files: Array[String]=[]
	for resolution in [Vector2i(390,844),Vector2i(360,640),Vector2i(360,780),Vector2i(412,915),Vector2i(430,932),Vector2i(480,1000),Vector2i(600,1024)]:
		app.session=null
		SaveService.profile=SaveSchema.defaults()
		SaveService.profile.settings=SettingsService.values.duplicate(true)
		get_window().size=resolution
		await get_tree().process_frame
		for id in ["home","daily","stats","settings","about","privacy"]:
			app.router.settle_transition()
			app.show_screen(id)
			app.router.settle_transition()
			await shot(id,resolution,files)
			if id=="about":
				app.router.current.controls["about.licenses"].pressed.emit()
				await shot("about_licenses",resolution,files)
			if id=="settings":
				app.router.current.scroll.scroll_vertical=int(app.router.current.scroll.get_v_scroll_bar().max_value)
				await shot("settings_bottom",resolution,files)
		app.router.settle_transition()
		app.start_game("classic",true)
		app.router.settle_transition()
		await shot("game_empty",resolution,files)
		var game: GameScreen=app.router.current
		app.show_screen("home")
		app.router.settle_transition()
		await shot("home_continue",resolution,files)
		app.start_game("classic",false)
		app.router.settle_transition()
		game=app.router.current
		var move:=Bot.move(app.session)
		var target:=DragTools.target(game,move.slot,move.origin)
		DragTools.touch(game.drag,game.metrics.slots[move.slot].get_center(),true)
		DragTools.motion(game.drag,target)
		await shot("game_valid_ghost",resolution,files)
		game.drag.cancel()
		app.session.board.cells[2][2]=1
		app.session.board.cells[3][3]=2
		game._refresh()
		await shot("game_mid",resolution,files)
		game.fx.metrics=game.metrics
		game.fx.reduced=false
		game.fx.effects=[{"kind":"clear","cells":[Vector2i(2,2),Vector2i(3,3)],"family":1,"age":0.18,"duration":0.52}]
		game.fx.set_process(false)
		game.fx.queue_redraw()
		await shot("game_clear_frame",resolution,files)
		game.fx.cancel_all()
		for y in 8:
			for x in 8: app.session.board.cells[y][x]=(x+y)%5 if y<7 else -1
		app.router.current._refresh()
		await shot("game_dense",resolution,files)
		game.drag.lock_until_ms=0
		DragTools.touch(game.drag,game.metrics.slots[0].get_center(),true)
		DragTools.motion(game.drag,DragTools.target(game,0,Vector2i.ZERO))
		await shot("game_invalid_ghost",resolution,files)
		game.drag.cancel()
		app.pause_game()
		await shot("pause",resolution,files)
		app.confirm_new("classic",true)
		await shot("confirm",resolution,files)
		app.router.pop_modal()
		app.router.pop_modal()
		app.session.score=1234
		app.session.lines=12
		app.session.pieces=47
		app.session.max_combo=3
		app.session.elapsed_s=132
		app.best_before=500
		app.session.finish("over")
		app.session_changed()
		await shot("game_over",resolution,files)
		app.best_before=2000
		app.router.modals[-1].rebuild()
		await shot("game_over_no_record",resolution,files)
		app.show_screen("stats")
		app.router.settle_transition()
		SaveService.profile.history=[{"ts":1794691200,"mode":"classic","score":1234,"lines":12,"pieces":47,"max_combo":3,"seconds":132,"result":"over"}]
		app.router.current.rebuild()
		await shot("stats_filled",resolution,files)
		for template in 3:
			var fixture_date:=""
			for day in range(1,29):
				var candidate:="2026-11-%02d" % day
				if DailyChallenge.describe(candidate).template==template:
					fixture_date=candidate
					break
			app.session=null
			app.date_provider=func(): return fixture_date
			SaveService.profile.sessions.daily=null
			SaveService.profile.daily.completed.clear()
			app.show_screen("daily")
			app.router.settle_transition()
			await shot("daily_template%d_new" % template,resolution,files)
			app.start_game("daily",true)
			app.router.settle_transition()
			app.session.score=100
			app.show_screen("daily")
			app.router.settle_transition()
			await shot("daily_template%d_progress" % template,resolution,files)
			SaveService.profile.daily.completed[fixture_date]={"score":750,"seconds":123,"ts":1794691200}
			app.router.current.rebuild()
			await shot("daily_template%d_done" % template,resolution,files)
			app.start_game("daily",true)
			app.router.settle_transition()
			app.session.finish("completed")
			app.session_changed()
			await shot("game_over_daily_done_template%d" % template,resolution,files)
			app.start_game("daily",true)
			app.router.settle_transition()
			app.session.finish("failed")
			app.session_changed()
			await shot("game_over_daily_failed_template%d" % template,resolution,files)
		app.date_provider=func(): return "2026-11-15"
		app.router.settle_transition()
		app.show_screen("settings")
		app.router.settle_transition()
		app.language_picker()
		await shot("language_picker",resolution,files)
		app.router.pop_modal()
		app.show_tutorial(true)
		app.router.settle_transition()
		await shot("tutorial",resolution,files)
		var tutorial: GameScreen=app.router.current
		DragTools.touch(tutorial.drag,tutorial.metrics.slots[0].get_center(),true)
		DragTools.motion(tutorial.drag,DragTools.target(tutorial,0,Vector2i(0,7)))
		DragTools.touch(tutorial.drag,DragTools.target(tutorial,0,Vector2i(0,7)),false)
		await shot("tutorial_step2",resolution,files)
		tutorial.next_button.pressed.emit()
		await shot("tutorial_step3",resolution,files)
		if resolution in [Vector2i(390,844),Vector2i(360,640)]:
			SettingsService.set_value("text_scale",1.15)
			for id in ["home","settings"]:
				app.router.settle_transition()
				app.show_screen(id)
				app.router.settle_transition()
				await shot(id+"_scale115",resolution,files)
			app.start_game("classic",true)
			app.router.settle_transition()
			app.session.finish("over")
			app.session_changed()
			await shot("game_over_scale115",resolution,files)
			SettingsService.set_value("text_scale",1.0)
	for locale_resolution in [Vector2i(360,640),Vector2i(390,844),Vector2i(412,915),Vector2i(480,1000)]:
		get_window().size=locale_resolution
		for locale in LocalizationService.LOCALES:
			LocalizationService.apply_language(locale)
			app.router.settle_transition()
			app.show_screen("home")
			app.router.settle_transition()
			await shot("home_"+locale,locale_resolution,files)
			if not output.ends_with("REVIEW_PACK_1"):
				app.show_screen("settings")
				app.router.settle_transition()
				await shot("settings_"+locale,locale_resolution,files)
				app.start_game("classic",true)
				app.router.settle_transition()
				await shot("game_"+locale,locale_resolution,files)
				app.session.score=1234
				app.session.finish("over")
				app.session_changed()
				var skip:=InputEventScreenTouch.new()
				skip.pressed=true
				app.router.modals[-1]._input(skip)
				await shot("game_over_"+locale,locale_resolution,files)
	get_window().size=Vector2i(390,844)
	# Explicit daily template fixtures; no claim that these are today's real mission.
	LocalizationService.apply_language("en")
	var dates: Dictionary={}
	for day in range(1,29):
		var date:="2026-11-%02d" % day
		dates[DailyChallenge.describe(date).template]=date
	for template in dates:
		var date: String=dates[template]
		app.date_provider=func(): return date
		app.router.settle_transition()
		app.show_screen("daily")
		app.router.settle_transition()
		await shot("daily_template"+str(template),Vector2i(390,844),files)
	var index:=FileAccess.open(output+"/index.md",FileAccess.WRITE)
	index.store_string("# Review evidence\n\nReview #1 direction was approved. Review #2 was explicitly waived; no new approval is requested. Manrope and six Noto families are bundled with OFL notices; every translated character passed coverage checks. All 16 locales are machine-drafted and native review remains required. Audio quality and real haptic feel remain blocked for human feedback. These are desktop fixtures, not phone results.\n\nCheck small-screen fit, hierarchy, dense-board legibility, cube treatment, touch targets and modal readability.\n\n")
	for file in files: index.store_line("- ["+file+"]("+file+")")
	index.close()
	print("Review capture: %d files" % files.size())
	AudioService.stop_all()
	await get_tree().create_timer(0.12).timeout
	get_tree().quit(1 if failed else 0)

func shot(id: String,resolution: Vector2i,files: Array[String]) -> void:
	if app.router.current is GameScreen and id!="game_clear_frame":
		app.router.current.fx.cancel_all()
	for modal in app.router.modals:
		if modal.get("entrance")!=null: modal.entrance.kill()
		modal.modulate.a=1.0
		if modal.get("screen_id")=="game_over":
			var skip:=InputEventScreenTouch.new()
			skip.pressed=true
			modal._input(skip)
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image:=get_viewport().get_texture().get_image()
	var filename:="%s_%dx%d.png" % [id,resolution.x,resolution.y]
	var error:=image.save_png(output+"/"+filename)
	if error!=OK:
		push_error("Capture failed "+filename)
		get_tree().quit(1)
	files.append(filename)
