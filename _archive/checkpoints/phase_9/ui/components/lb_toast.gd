class_name LBToast
extends PanelContainer

var label: Label
var timeout: Timer

func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	label=Label.new()
	label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	add_child(label)
	timeout=Timer.new()
	timeout.one_shot=true
	timeout.timeout.connect(hide)
	add_child(timeout)
	hide()

func show_key(key: String) -> void:
	label.text=tr(key)
	show()
	timeout.start(2.5)
