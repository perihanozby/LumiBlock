extends RefCounted

const MenuTools=preload("res://tests/ui/menu_test_tools.gd")
const Bot=preload("res://tests/greedy_bot.gd")
const DragTools=preload("res://tests/ui/drag_test_tools.gd")

class InputProbe extends Node:
	var touches:=0
	var mice:=0
	var emulated_mice:=0
	func _input(event: InputEvent) -> void:
		if event is InputEventScreenTouch or event is InputEventScreenDrag: touches+=1
		if event is InputEventMouse: mice+=1
		if event is InputEventMouse and event.device<0: emulated_mice+=1

# Inject physical touch events into Input, never Control methods/signals.
# Input performs emulation and viewport dispatch exactly as it does for a device.
func touch(viewport: Viewport,point: Vector2,pressed: bool,index: int=0) -> void:
	var event:=InputEventScreenTouch.new()
	event.index=index
	event.position=viewport.get_final_transform()*point
	event.pressed=pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func swipe(t,from: Vector2,to: Vector2,index: int=0,observe: Callable=Callable(),jitter: float=0.0) -> void:
	var viewport: Viewport=t.get_viewport()
	touch(viewport,from,true,index)
	await t.get_tree().process_frame
	var previous:=from
	for step in range(1,13):
		var point:=from.lerp(to,float(step)/12)
		point.y+=sin(float(step)*PI/3)*jitter
		var event:=InputEventScreenDrag.new()
		event.index=index
		event.position=viewport.get_final_transform()*point
		event.relative=viewport.get_final_transform().basis_xform(point-previous)
		event.velocity=event.relative*60
		Input.parse_input_event(event)
		Input.flush_buffered_events()
		if observe.is_valid(): observe.call(point)
		previous=point
		await t.get_tree().process_frame
	touch(viewport,to,false,index)
	await t.get_tree().process_frame

func settle(t) -> void:
	for frame in 5: await t.get_tree().process_frame

func tap(t,point: Vector2) -> void:
	touch(t.get_viewport(),point,true)
	await t.get_tree().process_frame
	touch(t.get_viewport(),point,false)
	await settle(t)

func scroll_from(t,screen: MenuScreen,node: Control,description: String) -> void:
	screen.scroll.scroll_vertical=0
	await settle(t)
	var visible:=node.get_global_rect().intersection(screen.scroll.get_global_rect())
	t.check(visible.has_area(),description+" starts on a visible child")
	if not visible.has_area(): return
	var start:=visible.get_center()
	if description=="Stats card surface": start.x=visible.position.x+4
	var end:=start-Vector2(0,minf(160,start.y-screen.scroll.global_position.y-4))
	var before:=screen.scroll.scroll_vertical
	await swipe(t,start,end)
	print("TOUCH ",description," scroll ",before," -> ",screen.scroll.scroll_vertical)
	t.check(screen.scroll.scroll_vertical>before,description+" bubbles a vertical touch drag")

func run(t) -> void:
	var old_size: Vector2i=t.get_window().size
	t.get_window().size=Vector2i(390,844)
	var probe:=InputProbe.new()
	t.add_child(probe)
	var root=MenuTools.fixture(t)
	root.show_screen("settings")
	root.router.settle_transition()
	await settle(t)
	var settings: MenuScreen=root.router.current
	var before:=settings.scroll.scroll_vertical
	var start: Vector2=settings.labels["settings.sound"].get_global_rect().get_center()
	await swipe(t,start+Vector2(0,140),start+Vector2(0,-20))
	print("TOUCH settings scroll ",before," -> ",settings.scroll.scroll_vertical)
	t.check(settings.scroll.scroll_vertical>before,"viewport touch scrolls Settings")
	await scroll_from(t,settings,settings.labels["settings.feel"],"Settings label")
	var haptics_before: bool=SettingsService.values.haptics
	await scroll_from(t,settings,settings.controls["settings.haptics"],"Settings toggle row")
	t.check_eq(SettingsService.values.haptics,haptics_before,"scrolling a toggle does not toggle it")
	settings.scroll.scroll_vertical=0
	await settle(t)
	for key in ["sfx","music"]:
		var slider: HSlider=settings.controls["settings."+key+"_volume"]
		var bounds:=slider.get_global_rect()
		var old:=slider.value
		var scroll_before:=settings.scroll.scroll_vertical
		var samples: Array[float]=[]
		await swipe(t,Vector2(bounds.position.x+bounds.size.x*0.8,bounds.get_center().y),Vector2(bounds.position.x+bounds.size.x*0.2,bounds.get_center().y),0,func(_point): samples.append(slider.value),4)
		print("TOUCH ",key," slider ",old," -> ",slider.value)
		t.check(absf(slider.value-old)>0.15,"viewport touch drags "+key+" slider")
		t.check(bounds.size.y>=48,key+" slider touch height >=48dp")
		t.check(absf(slider.value-0.2)<0.07,key+" slider reaches finger position")
		t.check(samples.any(func(value): return value>0.3 and value<0.7),key+" slider follows intermediate finger motion")
		t.check_eq(settings.scroll.scroll_vertical,scroll_before,key+" horizontal drag with vertical jitter is not stolen by scroll")
		await t.get_tree().create_timer(0.35).timeout
		var saved:=SaveService.decode_payload(FileAccess.get_file_as_string(SaveService.save_path))
		t.check(not saved.is_empty(),key+" settings save is valid")
		if not saved.is_empty(): t.check(absf(saved.settings[key+"_volume"]-slider.value)<0.001,key+" touched value persisted on disk")
	var selected_count:=[0]
	var effects: LBSegmented=settings.controls["settings.effects"]
	effects.selected.connect(func(_value): selected_count[0]+=1)
	await tap(t,effects.buttons[2].get_global_rect().get_center())
	t.check_eq(SettingsService.values.effects,"rich","viewport tap selects Rich segment")
	t.check_eq(selected_count[0],1,"touch/mouse emulation emits one segment action")
	await scroll_from(t,settings,settings.labels["settings.feel"],"Settings text-size reveal")
	var text_size: LBSegmented=settings.controls["settings.text_size"]
	await tap(t,text_size.buttons[1].get_global_rect().get_center())
	t.check_eq(SettingsService.values.text_scale,1.15,"viewport tap selects Large text segment")
	await tap(t,text_size.buttons[0].get_global_rect().get_center())
	t.check_eq(SettingsService.values.text_scale,1.0,"viewport tap restores Normal text segment")
	SaveService.profile.stats.games_finished=10
	SaveService.profile.history=[]
	for index in 10:
		SaveService.profile.history.append({"ts":1794691200-index*86400,"score":1234,"mode":"classic","result":"over","lines":12,"pieces":47,"max_combo":3,"seconds":132})
	root.show_screen("stats")
	root.router.settle_transition()
	await settle(t)
	var stats: MenuScreen=root.router.current
	t.check_eq(stats.labels["stats.best_classic.value"].mouse_filter,Control.MOUSE_FILTER_IGNORE,"passive stat label does not own gestures")
	before=stats.scroll.scroll_vertical
	start=stats.labels["stats.best_classic.value"].get_global_rect().get_center()
	await swipe(t,start+Vector2(0,120),start-Vector2(0,60))
	print("TOUCH stats scroll ",before," -> ",stats.scroll.scroll_vertical)
	t.check(stats.scroll.scroll_vertical>before,"viewport touch scrolls Statistics")
	await scroll_from(t,stats,stats.labels["stats.best_classic.value"],"Stats card label")
	await scroll_from(t,stats,stats.labels["stats.best_classic.value"].get_parent().get_parent(),"Stats card surface")
	# The picker is mostly buttons: a vertical drag must not select a language.
	root.show_screen("settings")
	root.router.settle_transition()
	root.language_picker()
	await settle(t)
	var picker: MenuScreen=root.router.modals[-1]
	await scroll_from(t,picker,picker.controls["settings.language_system"],"Language picker button")
	t.check_eq(LocalizationService.locale,"en","picker scroll does not select a language")
	await tap(t,picker.controls["locale.tr"].get_global_rect().get_center())
	t.check_eq(LocalizationService.locale,"tr","real picker touch selects Turkish")
	t.check(root.router.modals.is_empty(),"picker closes once after touch selection")
	LocalizationService.apply_language("en")
	root.show_screen("about")
	root.router.settle_transition()
	await settle(t)
	var about: MenuScreen=root.router.current
	await tap(t,about.controls["about.licenses"].get_global_rect().get_center())
	t.check(about.labels.has("license.text"),"viewport tap opens actual licence text")
	if about.labels.has("license.text"): await scroll_from(t,about,about.labels["license.text"],"About licence label")
	# Other full-page menus retain scrolling only when their content overflows.
	for id in ["home","daily","privacy"]:
		root.show_screen(id)
		root.router.settle_transition()
		await settle(t)
		var menu: MenuScreen=root.router.current
		var extent: float=menu.scroll.get_v_scroll_bar().max_value-menu.scroll.get_v_scroll_bar().page
		var area:=menu.scroll.get_global_rect()
		await swipe(t,area.position+Vector2(area.size.x*0.6,area.size.y*0.7),area.position+Vector2(area.size.x*0.6,area.size.y*0.45))
		t.check_eq(root.router.current_id,id,id+" vertical gesture does not accidentally navigate")
		if extent>1: t.check(menu.scroll.scroll_vertical>0,id+" overflow remains touch-scrollable")
		if id=="home":
			var navigations:=[0]
			var count_navigation:=func(_id): navigations[0]+=1
			root.router.screen_changed.connect(count_navigation)
			await tap(t,menu.labels["daily.date"].get_global_rect().get_center())
			t.check_eq(root.router.current_id,"daily","completed viewport card tap opens Daily")
			t.check_eq(navigations[0],1,"card tap navigates once across both emulation paths")
			root.router.screen_changed.disconnect(count_navigation)
			root.router.settle_transition()
	# Real viewport gameplay path receives both native touch and synthesized mouse.
	root.router.settle_transition()
	root.start_game("classic",true)
	root.router.settle_transition()
	await settle(t)
	var game: GameScreen=root.router.current
	var selected:=Bot.move(root.session)
	var drops:=[0]
	game.drag.drag_dropped.connect(func(_slot,_origin): drops[0]+=1)
	var pieces_before: int=root.session.pieces
	var target:=DragTools.target(game,selected.slot,selected.origin)
	touch(t.get_viewport(),game.metrics.slots[selected.slot].get_center(),true)
	await t.get_tree().process_frame
	t.check_eq(game.drag.owner_index,0,"viewport native touch owns gameplay drag")
	touch(t.get_viewport(),game.metrics.slots[(selected.slot+1)%3].get_center(),true,1)
	await t.get_tree().process_frame
	t.check_eq(game.drag.owner_index,0,"second viewport finger does not steal ownership")
	var move:=InputEventScreenDrag.new()
	move.index=0
	move.position=t.get_viewport().get_final_transform()*target
	move.relative=Vector2(10,-100)
	Input.parse_input_event(move)
	Input.flush_buffered_events()
	await t.get_tree().process_frame
	t.check_eq(game.board_view.ghost.origin,selected.origin,"emulated mouse does not jump viewport ghost")
	touch(t.get_viewport(),target,false)
	touch(t.get_viewport(),game.metrics.slots[(selected.slot+1)%3].get_center(),false,1)
	await settle(t)
	t.check_eq(root.session.pieces,pieces_before+1,"native/emulated pair places exactly one piece")
	t.check_eq(drops[0],1,"viewport drag emits one drop")
	t.check_eq(game.drag.owner_index,-1,"viewport release clears pointer owner")
	t.check(probe.touches>0 and probe.mice>0,"real input dispatch includes touch and emulated mouse")
	t.check(probe.emulated_mice>0,"native touches actually generated emulated mouse events")
	# Desktop mouse still produces a touch-index-owned drag, not a second path.
	selected=Bot.move(root.session)
	t.check(selected.slot>=0,"desktop emulation has a legal second move")
	if selected.slot>=0:
		game.drag.lock_until_ms=0
		pieces_before=root.session.pieces
		target=DragTools.target(game,selected.slot,selected.origin)
		var mouse_start: Vector2=t.get_viewport().get_final_transform()*game.metrics.slots[selected.slot].get_center()
		var mouse_target: Vector2=t.get_viewport().get_final_transform()*target
		var press:=InputEventMouseButton.new()
		press.button_index=MOUSE_BUTTON_LEFT
		press.button_mask=MOUSE_BUTTON_MASK_LEFT
		press.position=mouse_start
		press.global_position=mouse_start
		press.pressed=true
		Input.parse_input_event(press)
		Input.flush_buffered_events()
		await t.get_tree().process_frame
		t.check_eq(game.drag.owner_index,0,"physical mouse is converted to touch owner0")
		var motion:=InputEventMouseMotion.new()
		motion.button_mask=MOUSE_BUTTON_MASK_LEFT
		motion.position=mouse_target
		motion.global_position=mouse_target
		motion.relative=mouse_target-mouse_start
		Input.parse_input_event(motion)
		Input.flush_buffered_events()
		await t.get_tree().process_frame
		t.check_eq(game.board_view.ghost.origin,selected.origin,"desktop emulated touch preview is exact")
		var release:=InputEventMouseButton.new()
		release.button_index=MOUSE_BUTTON_LEFT
		release.position=mouse_target
		release.global_position=mouse_target
		release.pressed=false
		Input.parse_input_event(release)
		Input.flush_buffered_events()
		await settle(t)
		t.check_eq(root.session.pieces,pieces_before+1,"desktop mouse places exactly one piece")
		t.check_eq(drops[0],2,"one native-touch plus one desktop-mouse drop total")
	# The same Controls also live in modal stacks over an active drag controller.
	pieces_before=root.session.pieces
	root.pause_game()
	root.router.push_modal(root.scene("settings"),{"modal":true})
	await settle(t)
	var modal_settings: MenuScreen=root.router.modals[-1]
	await scroll_from(t,modal_settings,modal_settings.labels["settings.feel"],"Pause Settings label")
	modal_settings.scroll.scroll_vertical=0
	await settle(t)
	var modal_slider: HSlider=modal_settings.controls["settings.sfx_volume"]
	var modal_bounds:=modal_slider.get_global_rect()
	before=modal_settings.scroll.scroll_vertical
	await swipe(t,Vector2(modal_bounds.position.x+modal_bounds.size.x*0.2,modal_bounds.get_center().y),Vector2(modal_bounds.position.x+modal_bounds.size.x*0.7,modal_bounds.get_center().y),0,Callable(),4)
	t.check(modal_slider.value>0.6,"Pause Settings volume drag works through modal stack")
	t.check_eq(modal_settings.scroll.scroll_vertical,before,"modal horizontal slider drag does not pan")
	t.check_eq(root.session.pieces,pieces_before,"modal touch gestures never place a gameplay piece")
	var back:=MenuTools.find_button(modal_settings,"common.back")
	t.check(back!=null,"modal Settings has real Back target")
	if back!=null: await tap(t,back.get_global_rect().get_center())
	t.check_eq(root.router.modals.size(),1,"real Back touch closes only Settings")
	var resume:=MenuTools.find_button(root.router.modals[-1],"pause.resume")
	if resume!=null: await tap(t,resume.get_global_rect().get_center())
	t.check_eq(root.router.modals.size(),0,"real Resume touch closes Pause once")
	root.confirm_new("classic",true)
	await settle(t)
	var cancel:=MenuTools.find_button(root.router.modals[-1],"common.cancel")
	if cancel!=null: await tap(t,cancel.get_global_rect().get_center())
	t.check_eq(root.router.modals.size(),0,"confirm Cancel still handles one emulated touch click")
	t.check_eq(root.session.pieces,pieces_before,"cancelled confirmation preserves gameplay")
	SettingsService.set_value("reduce_motion",true)
	SettingsService.set_value("text_scale",1.15)
	root.session.finish("over")
	root.session_changed()
	await t.get_tree().create_timer(0.12).timeout
	await settle(t)
	var over: MenuScreen=root.router.modals[-1]
	var overflow: float=over.scroll.get_v_scroll_bar().max_value-over.scroll.get_v_scroll_bar().page
	if overflow>1: await scroll_from(t,over,over.labels["over.lines.value"],"Large-text Game Over card")
	else: t.check_eq(over.scroll.scroll_vertical,0,"fitting Game Over modal needs no pan")
	root.queue_free()
	probe.queue_free()
	t.get_window().size=old_size
	await t.get_tree().process_frame
