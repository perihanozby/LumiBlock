class_name ColorMath
extends RefCounted

# Machado et al. 2009, severity 1.0, applied to linear-light sRGB.
const DEUT := [Vector3(0.367322, 0.860646, -0.227968), Vector3(0.280085, 0.672501, 0.047413), Vector3(-0.011820, 0.042940, 0.968881)]
const PROT := [Vector3(0.152286, 1.052583, -0.204868), Vector3(0.114503, 0.786281, 0.099216), Vector3(-0.003882, -0.048116, 1.051998)]

static func linear_channel(c: float) -> float:
	return c / 12.92 if c <= 0.04045 else pow((c + 0.055) / 1.055, 2.4)

static func linear_rgb(c: Color) -> Vector3:
	return Vector3(linear_channel(c.r), linear_channel(c.g), linear_channel(c.b))

static func luminance(c: Color) -> float:
	return linear_rgb(c).dot(Vector3(0.2126, 0.7152, 0.0722))

static func contrast(a: Color, b: Color) -> float:
	var x := luminance(a)
	var y := luminance(b)
	return (maxf(x, y) + 0.05) / (minf(x, y) + 0.05)

static func lab_curve(v: float) -> float:
	return pow(v, 1.0 / 3.0) if v > 216.0 / 24389.0 else v * (24389.0 / 27.0) / 116.0 + 16.0 / 116.0

static func lab(c: Color, matrix: Array = []) -> Vector3:
	var rgb := linear_rgb(c)
	if not matrix.is_empty():
		rgb = Vector3(clampf(matrix[0].dot(rgb), 0, 1), clampf(matrix[1].dot(rgb), 0, 1), clampf(matrix[2].dot(rgb), 0, 1))
	var x := lab_curve(rgb.dot(Vector3(0.4124564, 0.3575761, 0.1804375)) / 0.95047)
	var y := lab_curve(rgb.dot(Vector3(0.2126729, 0.7151522, 0.0721750)))
	var z := lab_curve(rgb.dot(Vector3(0.0193339, 0.1191920, 0.9503041)) / 1.08883)
	return Vector3(116 * y - 16, 500 * (x - y), 200 * (y - z))
