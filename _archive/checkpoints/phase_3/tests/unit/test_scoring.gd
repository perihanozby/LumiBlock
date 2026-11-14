extends RefCounted

func run(t) -> void:
	for n in 6:
		for s in 9:
			var expected := 30 + roundi(50 * n * (n + 1) * minf(2.5, 1 + 0.25 * maxi(0, s - 1)))
			t.check_eq(ScoringEngine.gain(3, n, s, false), expected, "scoring %d/%d" % [n,s])
			t.check_eq(ScoringEngine.gain(3, n, s, true), expected + 500, "perfect bonus")
	var state := {"streak": 0, "grace": 0}
	for lines in [1, 0, 0, 1]: state = ScoringEngine.advance(state.streak, state.grace, lines)
	t.check_eq(state.streak, 2, "two misses preserve streak")
	for lines in [0, 0, 0]: state = ScoringEngine.advance(state.streak, state.grace, lines)
	t.check_eq(state.streak, 0, "third miss resets streak")
