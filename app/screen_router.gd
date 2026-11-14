class_name ScreenRouter
extends Control

signal screen_changed(id: String)
signal modal_changed
signal quit_requested
var screens: Dictionary = {}
var current: Control
var current_id := ""
var history: Array[String] = []
var modals: Array[Control] = []
var transition: Tween
var transitioning := false
var app: Node

func register(id: String, scene: PackedScene) -> void:
	screens[id]=scene

func go(id: String, params: Dictionary = {}, remember: bool = true) -> void:
	if transitioning or not screens.has(id): return
	if current!=null:
		if remember and current_id!="": history.append(current_id)
		if current.has_method("exit"): current.exit()
		remove_child(current)
		current.queue_free()
	for modal in modals:
		remove_child(modal)
		modal.queue_free()
	modals.clear()
	current=screens[id].instantiate()
	current_id=id
	current.set("app",app)
	add_child(current)
	current.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if current.has_method("enter"): current.enter(params)
	transitioning=true
	current.modulate.a=0
	current.process_mode=Node.PROCESS_MODE_DISABLED
	transition=create_tween().set_parallel(true)
	if not SettingsService.reduce_motion():
		current.position.y=12
		transition.parallel().tween_property(current,"position:y",0.0,Tokens.MOTION_BASE).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	transition.tween_property(current,"modulate:a",1.0,0.08 if SettingsService.reduce_motion() else Tokens.MOTION_BASE)
	transition.finished.connect(func():
		transitioning=false
		current.process_mode=Node.PROCESS_MODE_INHERIT)
	screen_changed.emit(id)

func push_modal(scene: PackedScene, params: Dictionary = {}) -> Control:
	if transitioning: return null
	var modal: Control = scene.instantiate()
	modal.set("app",app)
	add_child(modal)
	modal.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	modals.append(modal)
	if modal.has_method("enter"): modal.enter(params)
	modal_changed.emit()
	return modal

func pop_modal() -> void:
	if modals.is_empty(): return
	var modal := modals.pop_back() as Control
	if modal.has_method("exit"): modal.exit()
	remove_child(modal)
	modal.queue_free()
	modal_changed.emit()

func back() -> void:
	if transitioning: return
	if not modals.is_empty():
		if modals[-1] is MenuScreen and modals[-1].screen_id=="game_over": go("home",{},false)
		else: pop_modal()
	elif current_id=="home": quit_requested.emit()
	elif current_id=="game": app.pause_game()
	else:
		var target: String = history.pop_back() if not history.is_empty() else "home"
		go(target,{},false)

func settle_transition() -> void:
	# Deterministic screenshots/tests finish only the router's transition.
	if transition!=null: transition.kill()
	transitioning=false
	if current!=null:
		current.modulate.a=1
		current.position.y=0
		current.process_mode=Node.PROCESS_MODE_INHERIT
