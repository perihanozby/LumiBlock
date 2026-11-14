class_name ScoringEngine
extends RefCounted

static func placement_score(cell_count: int, lines: int, combo: int) -> int:
	return gain(cell_count, lines, combo, false)

static func gain(cells: int, n: int, streak: int, perfect: bool) -> int:
	var multiplier := minf(ScoringConfig.MAX_MULTIPLIER, 1.0 + ScoringConfig.MULTIPLIER_STEP * maxi(0, streak - 1))
	return cells * ScoringConfig.CELL_POINTS + roundi(ScoringConfig.LINE_POINTS * n * (n + 1) * multiplier) + (ScoringConfig.PERFECT_BONUS if perfect else 0)

static func advance(streak: int, grace: int, cleared_lines: int) -> Dictionary:
	if cleared_lines > 0: return {"streak": streak + 1, "grace": 0}
	grace += 1
	return {"streak": 0 if grace > ScoringConfig.GRACE else streak, "grace": mini(grace, ScoringConfig.GRACE + 1)}
