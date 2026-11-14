extends RefCounted

func run(t) -> void:
	var view:=BoardView.new()
	t.add_child(view)
	var board:=BoardModel.new()
	for row in board.cells: row.fill(0)
	view.configure(board,40)
	await t.get_tree().process_frame
	await t.get_tree().process_frame
	var requests:=view.redraw_requests
	var resources:=Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)
	await t.get_tree().create_timer(5.0).timeout
	t.check_eq(view.redraw_requests,requests,"zero board invalidations during five idle seconds")
	t.check(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)<=resources,"no new steady-state resources")
	var samples: Array[int]=[]
	for i in 60:
		view.invalidate()
		await t.get_tree().process_frame
		samples.append(view.last_draw_us)
		t.check(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)<=resources,"no new Resource during repeated draws")
	samples.sort()
	t.check(samples[59]<=1500,"64 filled-cell draw max <= 1.5ms; measured "+str(samples[59])+"us")
	print("BOARD method=%s draws=%d max_us=%d idle_redraw_requests=0" % [ProjectSettings.get_setting("rendering/renderer/rendering_method"),view.draw_count,samples[59]])
	view.queue_free()
	await t.get_tree().process_frame
