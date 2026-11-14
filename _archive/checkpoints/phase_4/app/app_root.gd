extends Control

var router: ScreenRouter

func _ready() -> void:
	theme=ThemeFactory.build(float(SettingsService.values.get("text_scale",1.0)),LocalizationService.ui_font)
	router=ScreenRouter.new()
	router.app=self
	add_child(router)
	router.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	LocalizationService.locale_changed.connect(_apply_theme)
	SettingsService.changed.connect(func(key,_value):
		if key=="text_scale": _apply_theme())

func _apply_theme() -> void:
	theme=ThemeFactory.build(float(SettingsService.values.get("text_scale",1.0)),LocalizationService.ui_font)
	layout_direction=Control.LAYOUT_DIRECTION_RTL if LocalizationService.locale=="ar" else Control.LAYOUT_DIRECTION_LTR

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Tokens.BG_0)

func pause_game() -> void:
	pass
