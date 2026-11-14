extends Control

var router: ScreenRouter
var session: GameSession
var tracker:=StatsTracker.new()
var best_before:=0
var toast: LBToast
var daily_date:=""
var elapsed_since_save:=0.0
var date_provider: Callable
var seed_provider: Callable
var quit_hook: Callable

func _ready() -> void:
	get_tree().auto_accept_quit=false
	theme=ThemeFactory.build(float(SettingsService.values.get("text_scale",1.0)),LocalizationService.ui_font)
	router=ScreenRouter.new()
	router.app=self
	add_child(router)
	router.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	router.register("game",load("res://ui/screens/game/game_screen.tscn"))
	for id in ["home","daily","stats","settings","about","privacy","tutorial"]: router.register(id,scene(id))
	router.modal_changed.connect(func():
		if router.current is GameScreen:
			router.current.drag.modal_open=not router.modals.is_empty()
			if not router.modals.is_empty():
				router.current.drag.cancel()
				router.current._clear_drag()
				router.current.fx.cancel_all())
	LocalizationService.locale_changed.connect(_apply_theme)
	SettingsService.changed.connect(func(key,_value):
		if key=="text_scale": _apply_theme()
		if key=="reduce_motion" and _value: router.settle_transition()
		if key=="reduce_motion" and _value and router.current is GameScreen: router.current._clear_drag()
		if key in ["placement_assist","colorblind_marks"] and router.current is GameScreen: router.current._layout())
	toast=LBToast.new()
	add_child(toast)
	toast.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	toast.offset_left=Tokens.MARGIN
	toast.offset_right=-Tokens.MARGIN
	toast.offset_top=-96
	toast.offset_bottom=-Tokens.MARGIN
	SaveService.notice.connect(func(key): toast.show_key(key))
	if SaveService.last_notice!="": toast.show_key(SaveService.last_notice)
	router.quit_requested.connect(func():
		persist(true)
		if quit_hook.is_valid(): quit_hook.call()
		else: quit_safely())
	var timer:=Timer.new()
	timer.wait_time=1
	timer.timeout.connect(refresh_daily)
	add_child(timer)
	timer.start()
	daily_date=today()
	router.go("home",{},false)
	_apply_theme()
	if OS.is_debug_build() and "--perf-overlay" in OS.get_cmdline_user_args():
		add_child(load("res://app/performance_overlay.gd").new())

func _apply_theme() -> void:
	theme=ThemeFactory.build(float(SettingsService.values.get("text_scale",1.0)),LocalizationService.ui_font)
	layout_direction=Control.LAYOUT_DIRECTION_RTL if LocalizationService.locale=="ar" else Control.LAYOUT_DIRECTION_LTR

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Tokens.BG_0)

func pause_game() -> void:
	if router.current is GameScreen and router.modals.is_empty():
		router.current.drag.cancel()
		persist(true)
		router.push_modal(scene("pause"))

func session_changed() -> void:
	if session==null: return
	var record_key: String="best_daily" if session.mode=="daily" else "best_classic"
	SaveService.profile.records[record_key]=maxi(SaveService.profile.records[record_key],session.score)
	if session.state=="finished":
		var newly_finished:=tracker.finish(session,SaveService.profile)
		if newly_finished:
			AudioService.play("daily_done" if session.result=="completed" else "over")
			HapticsService.pulse("daily_done" if session.result=="completed" else "over")
	SaveService.profile.sessions[session.mode]=session.to_dict()
	SaveService.save_game(SaveService.profile)
	if session.state=="finished" and router.current_id=="game" and router.modals.is_empty(): router.push_modal(scene("game_over"))

func _process(delta: float) -> void:
	if session!=null and router!=null and router.current_id=="game" and router.modals.is_empty():
		session.tick(delta)
		elapsed_since_save+=delta
		if elapsed_since_save>=15:
			elapsed_since_save=0
			persist()

func scene(id: String) -> PackedScene:
	if id=="tutorial": return load("res://ui/screens/tutorial/tutorial_overlay.tscn")
	return load("res://ui/screens/%s/%s_screen.tscn" % [id,id])

func today() -> String:
	if date_provider.is_valid(): return date_provider.call()
	return Time.get_date_string_from_system()

func mission_text() -> String:
	var mission:=DailyChallenge.describe(today())
	var keys:= ["daily.mission.lines","daily.mission.score","daily.mission.combo"]
	return tr(keys[mission.template]).format({"n":mission.target})

func resumable(mode: String) -> bool:
	var data: Variant=SaveService.profile.sessions[mode]
	return data is Dictionary and data.state=="active" and (mode!="daily" or data.date==today())

func show_screen(id: String) -> void:
	persist(true)
	router.go(id)

func play_classic() -> void:
	if not SaveService.profile.flags.tutorial_done: show_tutorial(false)
	else: start_game("classic",true)

func start_game(mode: String,new_game: bool = false) -> void:
	if router.transitioning: return
	if new_game and resumable(mode):
		var abandoned:=GameSession.from_dict(SaveService.profile.sessions[mode])
		abandoned.finish("abandoned")
		tracker.finish(abandoned,SaveService.profile)
	if not new_game and resumable(mode): session=GameSession.from_dict(SaveService.profile.sessions[mode])
	else:
		var seed_value: int=seed_provider.call() if seed_provider.is_valid() else int(Time.get_unix_time_from_system())+Time.get_ticks_usec()
		session=GameSession.new(seed_value,mode,today() if mode=="daily" else "")
		SaveService.profile.stats.games_started+=1
		session.extra_fields["best_at_start"]=SaveService.profile.records.best_daily if mode=="daily" else SaveService.profile.records.best_classic
	best_before=int(session.extra_fields.get("best_at_start",SaveService.profile.records.best_daily if mode=="daily" else SaveService.profile.records.best_classic))
	persist(true)
	router.go("game",{"session":session})

func persist(force: bool = false) -> void:
	if session!=null: SaveService.profile.sessions[session.mode]=session.to_dict()
	SaveService.save_game(SaveService.profile,force)

func confirm_new(mode: String,restart: bool = false) -> void:
	router.push_modal(load("res://ui/components/lb_dialog.tscn"),{"title":"confirm.restart.title" if restart else "confirm.newgame.title","body":"confirm.restart.body" if restart else "confirm.newgame.body","confirm":func(): start_game(mode,true)})

func language_picker() -> void:
	router.push_modal(scene("language_picker"))

func show_tutorial(return_to_settings: bool) -> void:
	persist(true)
	router.go("tutorial",{"return_to_settings":return_to_settings})

func tutorial_done(return_to_settings: bool) -> void:
	SaveService.profile.flags.tutorial_done=true
	SaveService.save_game(SaveService.profile,true)
	if return_to_settings: router.go("settings")
	else: start_game("classic",true)

func confirm_reset() -> void:
	router.push_modal(load("res://ui/components/lb_dialog.tscn"),{"title":"reset.title","body":"reset.body","confirm":func():
		session=null
		SaveService.profile=SaveSchema.defaults()
		SettingsService.values=SaveService.profile.settings.duplicate(true)
		SaveService.save_game(SaveService.profile,true)
		LocalizationService.apply_language("system")
		router.go("home")
		toast.show_key("reset.done")})

func refresh_daily() -> void:
	if daily_date==today(): return
	daily_date=today()
	var data: Variant=SaveService.profile.sessions.daily
	if data is Dictionary:
		var active:=GameSession.from_dict(data)
		if DailyChallenge.expire_if_stale(active,today()):
			tracker.finish(active,SaveService.profile)
			SaveService.profile.sessions.daily=active.to_dict()
			if session!=null and session.mode=="daily": session=active
			SaveService.save_game(SaveService.profile,true)
			toast.show_key("daily.expired")
			if router.current_id=="game" and session!=null and session.mode=="daily": router.go("daily",{},false)
	if router.current is MenuScreen: router.current.rebuild()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_ESCAPE:
		router.back()
		get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
	if not is_node_ready() or router==null: return
	if what==NOTIFICATION_WM_GO_BACK_REQUEST: router.back()
	elif what in [NOTIFICATION_APPLICATION_PAUSED,NOTIFICATION_APPLICATION_FOCUS_OUT]:
		if router.current_id=="game" and router.modals.is_empty(): pause_game()
		else: persist(true)
	elif what==NOTIFICATION_APPLICATION_RESUMED: refresh_daily()
	elif what==NOTIFICATION_WM_CLOSE_REQUEST:
		persist(true)
		if quit_hook.is_valid(): quit_hook.call()
		else: quit_safely()

func quit_safely() -> void:
	AudioService.stop_all()
	get_tree().create_timer(0.12).timeout.connect(func(): get_tree().quit())
