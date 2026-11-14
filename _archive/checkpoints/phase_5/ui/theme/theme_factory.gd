class_name ThemeFactory
extends RefCounted

static func box(color: Color, radius: int = Tokens.CARD_RADIUS, padding: int = Tokens.CARD_PADDING) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color=color
	style.set_corner_radius_all(radius)
	style.set_border_width_all(1)
	style.border_color=Tokens.HAIRLINE
	style.content_margin_left=padding
	style.content_margin_right=padding
	style.content_margin_top=padding
	style.content_margin_bottom=padding
	return style

static func build(text_scale: float = 1.0, font: Font = null) -> Theme:
	var theme := Theme.new()
	theme.default_font=font if font!=null else ThemeDB.fallback_font
	theme.default_font_size=roundi(Tokens.FONT_SIZES.body*text_scale)
	theme.set_color("font_color","Label",Tokens.TEXT_BODY)
	theme.set_color("font_color","CheckButton",Tokens.TEXT_BODY)
	theme.set_constant("separation","VBoxContainer",Tokens.SPACE[2])
	theme.set_constant("separation","HBoxContainer",Tokens.SPACE[1])
	theme.set_stylebox("panel","PanelContainer",box(Tokens.SURFACE))
	for role in Tokens.FONT_SIZES:
		var type: String = "LB_"+role
		theme.set_type_variation(type,"Label")
		theme.set_font_size("font_size",type,roundi(Tokens.FONT_SIZES[role]*text_scale))
		theme.set_color("font_color",type,Tokens.TEXT_TITLE if role in ["display_xl","display_l","headline","title"] else Tokens.TEXT_BODY)
	for variant in ["primary","secondary","ghost"]:
		var type: String = "LB_"+variant
		theme.set_type_variation(type,"Button")
		var color := Tokens.PRIMARY if variant=="primary" else (Tokens.SURFACE_HI if variant=="secondary" else Color.TRANSPARENT)
		theme.set_font_size("font_size",type,roundi(Tokens.FONT_SIZES.button*text_scale))
		for state in ["normal","hover","pressed","disabled"]:
			var style := box(color.darkened(0.08) if state=="pressed" else color,Tokens.BUTTON_RADIUS)
			if state=="disabled": style.bg_color.a=0.4
			theme.set_stylebox(state,type,style)
		for state in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:
			theme.set_color(state,type,Tokens.ON_PRIMARY if variant=="primary" else Tokens.ON_SECONDARY)
		var focus := box(Color.TRANSPARENT,Tokens.BUTTON_RADIUS)
		focus.border_color=Tokens.ACCENT
		focus.set_border_width_all(2)
		theme.set_stylebox("focus",type,focus)
	return theme
