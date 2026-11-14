class_name PieceModel
extends RefCounted

var shape: Array[Vector2i]
var color: int
var shape_id: String

func _init(p_shape: Array[Vector2i], p_color: int) -> void:
	shape = p_shape.duplicate()
	color = p_color
	# Resolve lazily via catalog on serialization to avoid a preload cycle.

func to_dict() -> Dictionary:
	var serialized_shape: Array = []
	for cell in shape:
		serialized_shape.append([cell.x, cell.y])
	return {"shape": serialized_shape, "shape_id": shape_id, "color": color}

static func from_dict(data: Dictionary) -> PieceModel:
	var typed_shape: Array[Vector2i] = []
	var raw_shape: Variant = data.get("shape", [])
	if raw_shape is Array:
		for raw_cell in raw_shape:
			if raw_cell is Array and raw_cell.size() >= 2:
				typed_shape.append(Vector2i(int(raw_cell[0]), int(raw_cell[1])))
	var result := PieceModel.new(typed_shape, clampi(int(data.get("color", 0)), 0, 4))
	result.shape_id = str(data.get("shape_id", ""))
	return result
