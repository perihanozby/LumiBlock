extends RefCounted

func run(t) -> void:
	var root=MenuTestTools.fixture(t)
	for locale in LocalizationService.LOCALES:
		root.language_picker()
		var picker: MenuScreen=root.router.modals[-1]
		var button: LBButton=picker.controls["locale."+locale]
		button.pressed.emit()
		t.check_eq(LocalizationService.locale,locale,"live locale selected "+locale)
		t.check_eq(SettingsService.values.language,locale,"language persisted "+locale)
		t.check(root.router.modals.is_empty(),"picker closes after selection")
		t.check(not root.router.current.controls["home.play"].text.is_empty(),"home live label populated")
	root.language_picker()
	MenuTestTools.click(t,root,"settings.language_system")
	t.check_eq(SettingsService.values.language,"system","system default selectable")
	root.queue_free()
	await t.get_tree().process_frame
