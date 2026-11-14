extends GameScreen

var step:=0
var message: Label
var next_button: LBButton
var return_to_settings:=false
var guide: Guide

class Guide extends Control:
	var from:=Vector2.ZERO
	var to:=Vector2.ZERO
	var age:=0.0
	func _ready() -> void:
		mouse_filter=Control.MOUSE_FILTER_IGNORE
		set_process(not SettingsService.reduce_motion())
	func _process(delta: float) -> void:
		age+=delta
		if SettingsService.reduce_motion(): set_process(false)
		queue_redraw()
	func _draw() -> void:
		draw_line(from,to,Color(Tokens.PRIMARY,0.35),2,true)
		var direction:=(from-to).normalized()
		draw_line(to,to+direction.rotated(0.5)*16,Tokens.PRIMARY,2,true)
		draw_line(to,to+direction.rotated(-0.5)*16,Tokens.PRIMARY,2,true)
		draw_circle(from.lerp(to,0.5 if SettingsService.reduce_motion() else fposmod(age/1.2,1)),5,Tokens.PRIMARY)

func _ready() -> void:
	super._ready()
	pause_button.hide()

func _layout() -> void:
	if safe!=null and is_inside_tree(): safe.injected_area=Rect2(Vector2.ZERO,get_viewport_rect().size-Vector2(0,156))
	super._layout()

func enter(params: Dictionary) -> void:
	return_to_settings=params.get("return_to_settings",false)
	var tutorial:=GameSession.new(1)
	for x in range(3,8): tutorial.board.cells[7][x]=0
	tutorial.tray.assign([PieceGenerator.make_piece("i3_h",1),null,null])
	var scripted:=params.duplicate()
	scripted.session=tutorial
	super.enter(scripted)
	board_view.set_ghost(session.tray[0],{"origin":Vector2i(0,7),"valid":true})
	guide=Guide.new()
	guide.from=metrics.slots[0].get_center()
	guide.to=metrics.board_origin+Vector2(1.5,7.5)*metrics.pitch
	add_child(guide)
	drag.drag_started.connect(func(_slot): guide.hide(); guide.set_process(false))
	session.piece_placed.connect(_placed)
	var footer:=VBoxContainer.new()
	add_child(footer)
	footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer.offset_left=Tokens.MARGIN
	footer.offset_right=-Tokens.MARGIN
	footer.offset_top=-156
	footer.offset_bottom=-Tokens.MARGIN
	message=Label.new()
	message.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	message.text=tr("tutorial.step1")
	footer.add_child(message)
	next_button=LBButton.new()
	next_button.text_key="tutorial.next"
	next_button.visible=false
	next_button.pressed_action.connect(_next)
	footer.add_child(next_button)
	var skip:=LBButton.new()
	skip.text_key="tutorial.skip"
	skip.pressed_action.connect(func(): app.tutorial_done(return_to_settings))
	footer.add_child(skip)

func _placed() -> void:
	step=1
	drag.modal_open=true
	message.text=tr("tutorial.step2")
	next_button.show()

func _next() -> void:
	if step==1:
		step=2
		message.text=tr("tutorial.step3")
		next_button.text_key="tutorial.done"
		next_button.relabel()
	else: app.tutorial_done(return_to_settings)

func _on_locale_changed() -> void:
	super._on_locale_changed()
	if message!=null: message.text=tr("tutorial.step%d" % (step+1))
