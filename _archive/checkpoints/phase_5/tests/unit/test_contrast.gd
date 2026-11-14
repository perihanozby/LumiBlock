extends RefCounted

const BASES := [Color("61AFFF"), Color("5BCEBB"), Color("9D7CAF"), Color("D06F6B"), Color("C5A04E")]

func run(t) -> void:
	var report := PackedStringArray()
	for pair in [["title", "F3F6FD", "182235"], ["body", "C5CEE3", "182235"], ["muted", "8E9BB8", "182235"], ["primary", "04201B", "62D6C4"], ["secondary", "E8EEFB", "222E46"], ["accent", "8E9CFF", "182235"], ["success", "6BD8A0", "182235"], ["error", "F27A8F", "182235"]]:
		var ratio := ColorMath.contrast(Color(pair[1]), Color(pair[2]))
		report.append("%s contrast %.4f" % [pair[0], ratio])
		t.check(ratio >= 4.5, "%s text contrast %.4f >= 4.5" % [pair[0], ratio])
	for i in BASES.size():
		var ratio := ColorMath.contrast(BASES[i], Color("1A2438"))
		report.append("family %d socket contrast %.4f" % [i, ratio])
		t.check(ratio >= 3, "family %d vs socket %.4f >= 3" % [i, ratio])
	for mode in [[], ColorMath.DEUT, ColorMath.PROT]:
		var minimum := INF
		for i in BASES.size():
			for j in range(i + 1, BASES.size()):
				var delta := ColorMath.lab(BASES[i], mode).distance_to(ColorMath.lab(BASES[j], mode))
				minimum = minf(minimum, delta)
				t.check(delta >= 20, "colour separation %d/%d mode=%d deltaE=%.4f >=20" % [i, j, mode.size(), delta])
		report.append("minimum deltaE %.4f matrix=%s" % [minimum, str(mode)])
	var file := FileAccess.open("res://build/evidence/palette-math.txt", FileAccess.WRITE)
	file.store_string("\n".join(report))
	file.close()
