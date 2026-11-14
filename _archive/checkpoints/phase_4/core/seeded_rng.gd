class_name SeededRng
extends RefCounted

const MASK := 0xffffffff
var state: int:
	set(value): state = value & MASK

func _init(seed_value: int = 1) -> void:
	state = seed_value & MASK

static func mul32(a: int, b: int) -> int:
	# Split multiplication avoids signed int64 overflow of two unsigned u32s.
	return (((a & 0xffff) * (b & 0xffff)) + (((((a >> 16) * (b & 0xffff)) + ((b >> 16) * (a & 0xffff))) & 0xffff) << 16)) & MASK

func next_u32() -> int:
	state = (state + 0x6d2b79f5) & MASK
	var t := mul32(state ^ (state >> 15), state | 1)
	t = (t ^ ((t + mul32(t ^ (t >> 7), t | 61)) & MASK)) & MASK
	return (t ^ (t >> 14)) & MASK

func next_float() -> float:
	return next_u32() / 4294967296.0

func range_int(a: int, b: int) -> int:
	return a + int(next_float() * (b - a + 1))

func pick_weighted(weights: Array) -> int:
	var total := 0.0
	for weight in weights: total += maxf(0.0, weight)
	if total <= 0: return -1
	var needle := next_float() * total
	for i in weights.size():
		needle -= maxf(0.0, weights[i])
		if needle < 0: return i
	return weights.size() - 1
