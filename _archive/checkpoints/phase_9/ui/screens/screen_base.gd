class_name LBScreen
extends Control

signal request_back
var app: Node
var parameters: Dictionary = {}

func _ready() -> void:
	LocalizationService.locale_changed.connect(_on_locale_changed)

func enter(params: Dictionary) -> void:
	parameters=params

func exit() -> void:
	pass

func _on_locale_changed() -> void:
	pass
