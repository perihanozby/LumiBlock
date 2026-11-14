extends RefCounted

func run(t) -> void:
	SaveService.profile.records={"best_classic":1234,"best_daily":567,"best_combo":4}
	SaveService.profile.stats.games_finished=3
	SaveService.profile.stats.lines_cleared=42
	SaveService.profile.stats.pieces_placed=99
	SaveService.profile.stats.perfect_clears=2
	var root=MenuTestTools.fixture(t)
	root.show_screen("stats")
	root.router.settle_transition()
	var labels: Dictionary=root.router.current.labels
	for pair in [["stats.best_classic.value","1,234"],["stats.best_daily.value","567"],["stats.best_combo.value","4"],["stats.games.value","3"],["stats.lines.value","42"],["stats.pieces.value","99"],["stats.perfect.value","2"]]: t.check_eq(labels[pair[0]].text,pair[1],"fixture stat "+pair[0])
	root.queue_free()
	await t.get_tree().process_frame
