class_name GameScreen
extends LBScreen

var session: GameSession
var board_view: BoardView
var tray_view: TrayView
var drag: DragController
var drag_layer: DragLayer
var score_label: LBScoreLabel
var best_label: Label
var combo_label: LBComboChip
var progress_label: Label
var status_row: HBoxContainer
var metrics: Dictionary={}
var safe: SafeAreaContainer

func _ready() -> void:
	super._ready()
	board_view=BoardView.new()
	add_child(board_view)
	tray_view=TrayView.new()
	add_child(tray_view)
	tray_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe=SafeAreaContainer.new()
	add_child(safe)
	safe.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var column:=VBoxContainer.new()
	column.mouse_filter=Control.MOUSE_FILTER_IGNORE
	safe.add_child(column)
	var bar:=HBoxContainer.new()
	bar.custom_minimum_size.y=88
	column.add_child(bar)
	var pause:=LBIconButton.new()
	pause.name="Pause"
	pause.icon_name="pause"
	pause.text_key="game.pause"
	pause.pressed_action.connect(func(): app.pause_game())
	bar.add_child(pause)
	var score_column:=VBoxContainer.new()
	score_column.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	bar.add_child(score_column)
	var caption:=Label.new()
	caption.text=tr("game.score")
	caption.theme_type_variation="LB_overline"
	score_column.add_child(caption)
	score_label=LBScoreLabel.new()
	score_column.add_child(score_label)
	best_label=Label.new()
	best_label.theme_type_variation="LB_caption"
	bar.add_child(best_label)
	status_row=HBoxContainer.new()
	status_row.custom_minimum_size.y=28
	column.add_child(status_row)
	progress_label=Label.new()
	progress_label.theme_type_variation="LB_caption"
	progress_label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	status_row.add_child(progress_label)
	combo_label=LBComboChip.new()
	status_row.add_child(combo_label)
	drag_layer=DragLayer.new()
	add_child(drag_layer)
	drag_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	drag=DragController.new()
	add_child(drag)
	drag.drag_started.connect(_drag_started)
	drag.drag_updated.connect(_drag_updated)
	drag.drag_dropped.connect(_drag_dropped)
	drag.drag_cancelled.connect(_drag_cancelled)
	get_viewport().size_changed.connect(_layout)

func enter(params: Dictionary) -> void:
	super.enter(params)
	session=params.get("session",app.session if app!=null else null)
	if session==null: session=GameSession.new(1)
	session.piece_placed.connect(_refresh)
	_layout()
	_refresh()

func _layout() -> void:
	if session==null: return
	drag.cancel()
	safe.refresh()
	metrics=LayoutMetrics.compute(get_viewport_rect().size,safe.safe_rect)
	board_view.position=metrics.board_rect.position
	board_view.size=metrics.board_rect.size
	board_view.configure(session.board,metrics.pitch,SettingsService.values.colorblind_marks)
	tray_view.configure(session,metrics.slots,SettingsService.values.colorblind_marks)
	drag.configure(session,tray_view,metrics)
	drag.assist=SettingsService.values.placement_assist

func _refresh() -> void:
	score_label.set_value(session.score)
	var best: int=SaveService.profile.records.best_daily if session.mode=="daily" else SaveService.profile.records.best_classic
	best_label.text=tr("game.best")+"\n"+LocaleFormat.number(maxi(best,session.score),LocalizationService.locale)
	combo_label.set_combo(session.streak)
	progress_label.text=""
	if session.mode=="daily":
		var mission:=DailyChallenge.describe(session.date)
		var value: int=session.lines if mission.template==0 else (session.score if mission.template==1 else session.max_combo)
		progress_label.text=tr("daily.progress").format({"a":value,"b":mission.target})
	board_view.invalidate()
	tray_view.queue_redraw()

func _drag_started(slot: int) -> void:
	tray_view.lifted_slot=slot
	tray_view.queue_redraw()
	AudioService.play("pickup")
	HapticsService.pulse("pickup")

func _drag_updated(info: Dictionary) -> void:
	var piece:=session.tray[drag.slot]
	board_view.set_ghost(piece,{"origin":info.origin,"valid":info.valid})
	drag_layer.update_piece(piece,info,metrics.pitch)

func _clear_drag() -> void:
	tray_view.lifted_slot=-1
	tray_view.queue_redraw()
	board_view.set_ghost(null,{})
	drag_layer.update_piece(null,{},metrics.pitch)

func _drag_dropped(slot: int,origin: Vector2i) -> void:
	_clear_drag()
	var result:=session.place(slot,origin)
	if result.valid:
		AudioService.play("place")
		HapticsService.pulse("place")
		if app!=null and app.has_method("session_changed"): app.session_changed()

func _drag_cancelled(_slot: int) -> void:
	_clear_drag()
	AudioService.play("deny")
	HapticsService.pulse("deny")

func _on_locale_changed() -> void:
	if session!=null: _refresh()

func exit() -> void:
	drag.cancel()
	if session!=null and session.piece_placed.is_connected(_refresh): session.piece_placed.disconnect(_refresh)
