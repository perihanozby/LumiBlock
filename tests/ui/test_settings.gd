extends RefCounted

const MenuTools = preload("res://tests/ui/menu_test_tools.gd")

func run(t) -> void:
	var root=MenuTools.fixture(t)
	root.show_screen("settings")
	root.router.settle_transition()
	var screen: MenuScreen=root.router.current
	for pair in [["settings.sfx","sfx"],["settings.music","music"],["settings.haptics","haptics"],["settings.reduce_motion","reduce_motion"],["settings.assist","placement_assist"],["settings.marks","colorblind_marks"]]:
		var node: CheckButton=screen.controls[pair[0]]
		var before: bool=SettingsService.values[pair[1]]
		node.button_pressed=not before
		t.check_eq(SettingsService.values[pair[1]],not before,"setting toggle "+pair[1])
		if pair[1] in ["sfx","music"]:
			t.check_eq(AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX" if pair[1]=="sfx" else "Music")),before,"actual bus mute "+pair[1])
	screen.controls["settings.sfx_volume"].value=0.42
	t.check(is_equal_approx(SettingsService.values.sfx_volume,0.42),"volume persists")
	screen.controls["settings.music_volume"].value=0.37
	t.check(is_equal_approx(SettingsService.values.music_volume,0.37),"music volume persists")
	t.check(is_equal_approx(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")),linear_to_db(0.37)),"volume maps to actual audio bus")
	screen.controls["settings.effects"].buttons[2].pressed.emit()
	t.check_eq(SettingsService.values.effects,"rich","effects setting")
	screen.controls["settings.text_size"].buttons[1].pressed.emit()
	t.check_eq(SettingsService.values.text_scale,1.15,"text scale setting")
	t.check_eq(root.theme.get_font_size("font_size","LB_body"),18,"text scale affects actual theme")
	MenuTools.click(t,root,"settings.about")
	MenuTools.click(t,root,"about.licenses")
	t.check(root.router.current.labels["license.text"].text.length()>100,"actual engine licence text shown")
	MenuTools.click(t,root,"about.licenses")
	t.check(not root.router.current.labels["license.text"].visible,"licences can be collapsed")
	MenuTools.click(t,root,"common.back")
	MenuTools.click(t,root,"settings.privacy")
	t.check(root.router.current.labels.has("privacy.body"),"privacy text shown")
	t.check(not root.router.current.controls.has("privacy.url"),"no policy URL row")
	root.router.back()
	root.router.settle_transition()
	MenuTools.click(t,root,"settings.reset")
	MenuTools.click(t,root,"common.cancel")
	t.check_eq(SettingsService.values.effects,"rich","cancel reset preserves settings")
	MenuTools.click(t,root,"settings.reset")
	MenuTools.click(t,root,"common.confirm")
	t.check_eq(SaveService.profile.records.best_classic,0,"confirmed reset clears records")
	root.queue_free()
	await t.get_tree().process_frame
