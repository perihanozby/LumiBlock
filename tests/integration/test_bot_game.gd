extends RefCounted

const Bot = preload("res://tests/greedy_bot.gd")

func run(t) -> void:
	# Full required batch is reproducible separately; this suite does not silently reduce it.
	for seed_value in 200:
		var result := Bot.play(seed_value+1)
		t.check(result.finished,"bot game must finish seed="+str(seed_value+1))
		t.check(result.monotone,"monotone score")
		t.check(result.pieces>0,"bot placed pieces")
