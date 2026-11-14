class_name LBCard
extends PanelContainer

func _init() -> void:
	# Cards are surfaces, not gesture owners; let ancestor scrollers see drags.
	mouse_filter=Control.MOUSE_FILTER_PASS

func _ready() -> void:
	size_flags_horizontal=Control.SIZE_EXPAND_FILL
