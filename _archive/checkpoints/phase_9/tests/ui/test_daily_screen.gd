extends RefCounted

const MenuTools = preload("res://tests/ui/menu_test_tools.gd")

func run(t) -> void:
	var root=MenuTools.fixture(t)
	root.show_screen("daily")
	root.router.settle_transition()
	t.check_eq(root.router.current.labels["daily.mission"].text,root.mission_text(),"mission card matches model")
	MenuTools.click(t,root,"daily.start")
	t.check_eq(root.session.mode,"daily","daily starts")
	root.show_screen("home")
	root.router.settle_transition()
	root.start_game("classic",true)
	root.router.settle_transition()
	t.check(SaveService.profile.sessions.daily is Dictionary,"classic preserves daily")
	root.show_screen("daily")
	root.router.settle_transition()
	t.check_eq(root.router.current.labels["daily.attempts"].text,root.tr("daily.attempts").format({"n":1}),"active attempt included today")
	MenuTools.click(t,root,"daily.resume")
	t.check_eq(root.session.mode,"daily","daily resumes independently")
	var old_date: String=root.session.date
	var tomorrow:=Time.get_date_string_from_unix_time(Time.get_unix_time_from_datetime_string(old_date)+86400)
	root.date_provider=func(): return tomorrow
	root.refresh_daily()
	t.check_eq(SaveService.profile.sessions.daily.result,"expired","open-app midnight rollover expires old daily")
	root.queue_free()
	await t.get_tree().process_frame
