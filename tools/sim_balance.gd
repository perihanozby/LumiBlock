extends SceneTree

const Bot = preload("res://tests/greedy_bot.gd")

func _init() -> void:
	call_deferred("simulate")

func simulate() -> void:
	var count := 10000
	var lengths: Array[int] = []
	var total_score := 0
	var total_pieces := 0
	var unfinished := 0
	var guarantee_failed_games := 0
	var out := FileAccess.open("res://build/evidence/balance-games.jsonl",FileAccess.WRITE)
	for i in count:
		var result := Bot.play(i+1)
		lengths.append(result.pieces)
		total_score+=result.score
		total_pieces+=result.pieces
		if not result.finished: unfinished+=1
		if result.guarantee_failures>0: guarantee_failed_games+=1
		out.store_line(JSON.stringify(result))
		if i%100==0:
			out.flush()
			print("BALANCE %d/%d" % [i,count])
	out.close()
	lengths.sort()
	var report := "# Balance report\n\nExecuted 10,000 seeded greedy bot games, seeds 1 through 10000. Lines are maximized first, then enclosed holes minimized. This does not establish human difficulty.\n\nMean placements: %.2f; median: %d; p10: %d; p90: %d. Mean score: %.2f. Games unfinished at 2000-move guard: %d.\n\nGames with a first-level tray guarantee failure: %d (%.4f%%). Every initial and subsequent refill checked against the current board.\n\nEvidence: build/evidence/balance-games.jsonl and balance.stdout.\n" % [total_pieces/float(count),lengths[count/2],lengths[count/10],lengths[count*9/10],total_score/float(count),unfinished,guarantee_failed_games,guarantee_failed_games*100.0/count]
	var file := FileAccess.open("res://docs/BALANCE_REPORT.md",FileAccess.WRITE)
	file.store_string(report)
	file.close()
	print(report)
	quit(1 if unfinished>0 or guarantee_failed_games>0 else 0)
