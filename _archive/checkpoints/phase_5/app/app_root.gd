extends Control

var router: ScreenRouter
var session: GameSession

func _ready() -> void:
	theme=ThemeFactory.build(float(SettingsService.values.get("text_scale",1.0)),LocalizationService.ui_font)
	router=ScreenRouter.new()
	router.app=self
	add_child(router)
	router.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	router.register("game",load("res://ui/screens/game/game_screen.tscn"))
	router.modal_changed.connect(func():
		if router.current is GameScreen:
			router.current.drag.modal_open=not router.modals.is_empty()
			if not router.modals.is_empty(): router.current.drag.cancel())
	LocalizationService.locale_changed.connect(_apply_theme)
	SettingsService.changed.connect(func(key,_value):
		if key=="text_scale": _apply_theme())

func _apply_theme() -> void:
	theme=ThemeFactory.build(float(SettingsService.values.get("text_scale",1.0)),LocalizationService.ui_font)
	layout_direction=Control.LAYOUT_DIRECTION_RTL if LocalizationService.locale=="ar" else Control.LAYOUT_DIRECTION_LTR

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Tokens.BG_0)

func pause_game() -> void:
	if router.current is GameScreen:
		router.current.drag.cancel()
		router.push_modal(load("res://ui/components/lb_dialog.tscn"),{"title":"pause.title","body":"pause.saved","confirm":func(): pass})

func session_changed() -> void:
	if session==null: return
	SaveService.profile.sessions[session.mode]=session.to_dict()
	SaveService.save_game(SaveService.profile)

func _process(delta: float) -> void:
	if session!=null and router!=null and router.current_id=="game" and router.modals.is_empty(): session.tick(delta)
