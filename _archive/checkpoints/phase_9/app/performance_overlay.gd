extends Label

var elapsed:=0.0
func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	position=Vector2(8,48)
	add_theme_font_size_override("font_size",12)

func _process(delta: float) -> void:
	elapsed+=delta
	if elapsed<0.5: return
	elapsed=0
	text="%d FPS | %.2f ms | nodes %d | orphans %d | draws %d" % [Engine.get_frames_per_second(),Performance.get_monitor(Performance.TIME_PROCESS)*1000,Performance.get_monitor(Performance.OBJECT_NODE_COUNT),Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT),Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)]
