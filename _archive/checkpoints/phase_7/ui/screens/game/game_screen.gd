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
var pause_button: LBIconButton
var fx: FxController
var chip: Label
var chip_timer: Timer
var record_announced:=false

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
	pause_button=pause
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
	chip=Label.new()
	chip.theme_type_variation="LB_caption"
	status_row.add_child(chip)
	chip_timer=Timer.new()
	chip_timer.one_shot=true
	chip_timer.timeout.connect(func(): chip.text="")
	add_child(chip_timer)
	drag_layer=DragLayer.new()
	add_child(drag_layer)
	drag_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fx=FxController.new()
	add_child(fx)
	fx.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
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
	if session==null or not is_inside_tree(): return
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
	var rest:=_rest_transform(slot)
	drag_layer.begin_lift(rest.position,rest.pitch)
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
	var placed_piece:=session.tray[slot]
	var previous_score:=session.score
	_clear_drag()
	var result:=session.place(slot,origin)
	if result.valid:
		fx.placement(placed_piece,origin,result,metrics)
		AudioService.play("place")
		HapticsService.pulse("place")
		if result.lines>0:
			fx.celebrate(session.streak,placed_piece.color,session.board.is_empty(),session.score-previous_score)
			AudioService.play(StringName("clear_%d" % mini(result.lines,5)))
			HapticsService.pulse("clear",result.lines)
			if session.streak>=2:
				AudioService.play("combo_step",mini(session.streak-1,5))
				HapticsService.pulse("combo",session.streak)
			if session.board.is_empty():
				AudioService.play("perfect")
				HapticsService.pulse("perfect")
				show_chip("game.perfect",1.2)
		if app!=null and app.session==session and app.best_before>0 and session.score>app.best_before and not record_announced:
			record_announced=true
			AudioService.play("record")
			HapticsService.pulse("record")
			show_chip("over.new_best",1.5)
		if app!=null and app.session==session: app.session_changed()

func show_chip(key: String,duration: float) -> void:
	chip.text=tr(key)
	chip_timer.start(duration)

func _rest_transform(slot: int) -> Dictionary:
	var rect: Rect2=metrics.slots[slot]
	var bbox:=PieceView.bounds(session.tray[slot].shape)
	var rest_pitch:=minf(rect.size.x/(bbox.x+1),minf(rect.size.y/(bbox.y+1),32))
	return {"position":rect.get_center()-Vector2(bbox)*rest_pitch/2,"pitch":rest_pitch}

func _drag_cancelled(slot: int) -> void:
	board_view.set_ghost(null,{})
	var rest:=_rest_transform(slot)
	drag_layer.return_to_slot(rest.position,rest.pitch,func():
		tray_view.lifted_slot=-1
		tray_view.queue_redraw())
	if drag.cancel_reason=="invalid":
		AudioService.play("deny")
		HapticsService.pulse("deny")

func _on_locale_changed() -> void:
	if session!=null: _refresh()

func exit() -> void:
	drag.cancel()
	_clear_drag()
	fx.cancel_all()
	if session!=null and session.piece_placed.is_connected(_refresh): session.piece_placed.disconnect(_refresh)
