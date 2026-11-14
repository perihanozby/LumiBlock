extends Node

const SaveTools = preload("res://tests/save_test_tools.gd")

var failures := 0

func check(condition: bool, message: String) -> void:
	if not condition:
		failures+=1
		print("FAIL prototype " + message)

func _ready() -> void:
	var temporary = SaveTools.service("prototype")
	SaveService.save_path=temporary.save_path
	temporary.free()
	SaveService.save_game(SaveSchema.defaults(),true)
	var main = load("res://scenes/main.tscn").instantiate()
	add_child(main)
	main._start_game(false)
	main.tray.assign([PieceGenerator.make_piece("mono",0),PieceGenerator.make_piece("mono",1),PieceGenerator.make_piece("mono",2)])
	main.dragging=0
	main._pointer_up(Vector2(24,132))
	check(main.tray.size()==3 and main.tray[0]==null,"fixed slot after placement")
	main._pointer_down(Vector2(40,550))
	check(main.dragging==-1,"empty slot not captured")
	main._pointer_up(Vector2(24,132))
	check(main.score==10,"empty slot release no score change")
	main._go_home()
	var save := SaveService.load_legacy_game()
	check(save.sessions.classic.active,"menu preserves active session")
	main._restore_session(save.sessions.classic)
	check(main.tray.size()==3 and main.tray[0]==null,"restore preserves fixed slot")
	for row in main.board.cells: row.fill(0)
	main._save_session()
	save = SaveService.load_legacy_game()
	main._restore_session(save.sessions.classic)
	check(not main.has_saved_session,"restored board without moves is not resumable")
	var numeric_profile := SaveSchema.defaults()
	numeric_profile.stats.games_finished=3.0
	SaveService.save_game(numeric_profile,true)
	var legacy: Dictionary = SaveService.load_legacy_game()
	check(str(legacy.stats.games)=="3","statistics coercion has no decimal suffix")
	var saved_count := [0]
	SaveService.saved.connect(func(): saved_count[0]+=1)
	SaveService.save_game(numeric_profile,false)
	numeric_profile.records.best_classic=10
	SaveService.save_game(numeric_profile,false)
	check(saved_count[0]==0,"rapid saves debounce")
	await get_tree().create_timer(0.30).timeout
	check(saved_count[0]==1,"debounced latest profile written once")
	check(SaveService.load_game().records.best_classic==10,"latest pending data retained")
	main.queue_free()
	print("Prototype compatibility: %d failures" % failures)
	get_tree().quit(1 if failures else 0)
