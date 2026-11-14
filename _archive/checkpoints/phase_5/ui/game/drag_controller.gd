class_name DragController
extends Node

signal drag_started(slot: int)
signal drag_updated(info: Dictionary)
signal drag_dropped(slot: int,origin: Vector2i)
signal drag_cancelled(slot: int)
enum State { IDLE,DRAGGING,PLACING,RETURNING }
var state:=State.IDLE
var owner_index:=-1
var slot:=-1
var session: GameSession
var tray: TrayView
var metrics: Dictionary={}
var pointer:=Vector2.ZERO
var start_pointer:=Vector2.ZERO
var previous_origin: Variant=null
var resolved: Dictionary={}
var last_event_ms:=0
var lock_until_ms:=0
var modal_open:=false
var assist:=true

func configure(value: GameSession,tray_view: TrayView,layout: Dictionary) -> void:
	cancel()
	session=value
	tray=tray_view
	metrics=layout

func viewport_position(position: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse()*position

func _input(event: InputEvent) -> void:
	handle(event)

func handle(event: InputEvent) -> void:
	if not (event is InputEventScreenTouch or event is InputEventScreenDrag): return
	if session==null or metrics.is_empty(): return
	if state==State.DRAGGING:
		if event.index!=owner_index: return
		last_event_ms=Time.get_ticks_msec()
		pointer=viewport_position(event.position)
		if event is InputEventScreenTouch and event.canceled:
			cancel()
		elif event is InputEventScreenTouch and not event.pressed:
			resolve_pointer()
			var dropped_slot:=slot
			var origin: Vector2i=resolved.origin
			var valid: bool=resolved.valid and pointer.distance_to(start_pointer)>4
			_end(State.PLACING if valid else State.RETURNING)
			if valid: drag_dropped.emit(dropped_slot,origin)
			else: drag_cancelled.emit(dropped_slot)
		else: resolve_pointer()
	elif event is InputEventScreenTouch and event.pressed:
		if modal_open or session.state!="active" or Time.get_ticks_msec()<lock_until_ms: return
		var position:=viewport_position(event.position)
		var candidate:=tray.slot_at(position)
		if candidate<0 or session.tray[candidate]==null: return
		owner_index=event.index
		slot=candidate
		pointer=position
		start_pointer=position
		last_event_ms=Time.get_ticks_msec()
		previous_origin=null
		state=State.DRAGGING
		drag_started.emit(slot)
		resolve_pointer()

func resolve_pointer() -> void:
	if slot<0 or session.tray[slot]==null: return
	var piece:=session.tray[slot]
	resolved=DropResolver.resolve(pointer,piece.shape,PieceView.bounds(piece.shape),metrics.pitch,metrics.board_origin,session.board,assist,previous_origin,metrics.safe_area)
	previous_origin=resolved.origin
	drag_updated.emit(resolved)

func _end(next: State) -> void:
	state=next
	owner_index=-1
	slot=-1
	previous_origin=null
	lock_until_ms=Time.get_ticks_msec()+160

func cancel() -> void:
	if state!=State.DRAGGING: return
	var cancelled_slot:=slot
	_end(State.RETURNING)
	drag_cancelled.emit(cancelled_slot)

func _process(_delta: float) -> void:
	if state==State.DRAGGING and Time.get_ticks_msec()-last_event_ms>=2000: cancel()
	elif state in [State.PLACING,State.RETURNING] and Time.get_ticks_msec()>=lock_until_ms: state=State.IDLE

func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT,NOTIFICATION_APPLICATION_PAUSED,NOTIFICATION_WM_WINDOW_FOCUS_OUT]: cancel()
