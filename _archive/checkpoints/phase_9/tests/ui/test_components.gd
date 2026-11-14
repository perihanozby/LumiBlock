extends RefCounted

func run(t) -> void:
	var theme:=ThemeFactory.build()
	for pair in [["display_xl",56],["display_l",40],["headline",28],["title",20],["button",16],["body",16],["body_s",14],["caption",12],["overline",12]]:
		if pair[0]=="button": t.check_eq(theme.get_font_size("font_size","LB_primary"),pair[1],"button typography contract")
		else: t.check_eq(theme.get_font_size("font_size","LB_"+pair[0]),pair[1],"typography contract "+pair[0])
	for filename in DirAccess.get_files_at("res://ui/components"):
		if not filename.ends_with(".tscn"): continue
		var packed=load("res://ui/components/"+filename)
		t.check(packed!=null,"component scene "+filename)
		if packed==null: continue
		var component=packed.instantiate()
		t.add_child(component)
		if component is LBButton:
			var pressed_count := [0]
			component.pressed_action.connect(func(): pressed_count[0]+=1)
			component.pressed.emit()
			t.check_eq(pressed_count[0],1,"button action "+filename)
			t.check(component.custom_minimum_size.y>=48,"button touch target")
		if component is LBScoreLabel:
			component.set_value(1234)
			t.check_eq(component.value,1234,"score setter")
		if component is LBStatCard: component.configure("stats.lines","123")
		if component is LBSegmented:
			component.configure(["settings.text_normal","settings.text_large"],[1.0,1.15],1.0)
			t.check_eq(component.buttons.size(),2,"segments built")
		component.queue_free()
	await t.get_tree().process_frame
