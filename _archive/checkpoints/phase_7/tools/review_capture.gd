extends Node

var app: Control
var output:="res://docs/review/REVIEW_PACK_1"

func _ready() -> void:
	call_deferred("capture_all")

func capture_all() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	var temporary=SaveTestTools.service("review_capture")
	SaveService.save_path=temporary.save_path
	temporary.free()
	SaveService.profile=SaveSchema.defaults()
	SettingsService.values=SaveService.profile.settings.duplicate(true)
	LocalizationService.apply_language("en")
	app=load("res://app/app_root.tscn").instantiate()
	add_child(app)
	var files: Array[String]=[]
	for resolution in [Vector2i(390,844),Vector2i(360,640),Vector2i(360,780),Vector2i(412,915),Vector2i(430,932),Vector2i(480,1000),Vector2i(600,1024)]:
		get_window().size=resolution
		await get_tree().process_frame
		for id in ["home","daily","stats","settings","about","privacy"]:
			app.router.settle_transition()
			app.show_screen(id)
			app.router.settle_transition()
			await shot(id,resolution,files)
			if id=="settings":
				app.router.current.scroll.scroll_vertical=int(app.router.current.scroll.get_v_scroll_bar().max_value)
				await shot("settings_bottom",resolution,files)
		app.router.settle_transition()
		app.start_game("classic",true)
		app.router.settle_transition()
		await shot("game_empty",resolution,files)
		var game: GameScreen=app.router.current
		var move:=GreedyBot.move(app.session)
		var target:=DragTestTools.target(game,move.slot,move.origin)
		DragTestTools.touch(game.drag,game.metrics.slots[move.slot].get_center(),true)
		DragTestTools.motion(game.drag,target)
		await shot("game_valid_ghost",resolution,files)
		game.drag.cancel()
		for y in 8:
			for x in 8: app.session.board.cells[y][x]=(x+y)%5 if y<7 else -1
		app.router.current._refresh()
		await shot("game_dense",resolution,files)
		game.drag.lock_until_ms=0
		DragTestTools.touch(game.drag,game.metrics.slots[0].get_center(),true)
		DragTestTools.motion(game.drag,DragTestTools.target(game,0,Vector2i.ZERO))
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
		DragTestTools.touch(tutorial.drag,tutorial.metrics.slots[0].get_center(),true)
		DragTestTools.motion(tutorial.drag,DragTestTools.target(tutorial,0,Vector2i(0,7)))
		DragTestTools.touch(tutorial.drag,DragTestTools.target(tutorial,0,Vector2i(0,7)),false)
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
	get_window().size=Vector2i(390,844)
	for locale in LocalizationService.LOCALES:
		LocalizationService.apply_language(locale)
		app.router.settle_transition()
		app.show_screen("home")
		app.router.settle_transition()
		await shot("home_"+locale,Vector2i(390,844),files)
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
	index.store_string("# Human design review 1\n\nReview required; no visual approval or golden set is claimed. Fonts use built-in/system fallback because the authorized official download could not connect. Only core navigation strings are drafted in all locales in Phase 6; complete localization is Phase 8. Audio/effects are not yet implemented.\n\nCheck small-screen fit, hierarchy, dense-board legibility, cube treatment, touch targets and modal readability.\n\n")
	for file in files: index.store_line("- ["+file+"]("+file+")")
	index.close()
	print("Review capture: %d files" % files.size())
	get_tree().quit()

func shot(id: String,resolution: Vector2i,files: Array[String]) -> void:
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
