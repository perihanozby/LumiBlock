extends RefCounted

func run(t) -> void:
	for day in ["2024-01-01","2024-02-29","2024-12-31"]:
		var session := GameSession.new(1,"daily",day)
		var mission := DailyChallenge.describe(day)
		if mission.template==0: session.lines=mission.target
		elif mission.template==1: session.score=mission.target
		else: session.max_combo=mission.target
		session.evaluate()
		t.check_eq(session.result,"completed","target ends daily")
		var failed := GameSession.new(1,"daily",day)
		for row in failed.board.cells: row.fill(1)
		failed.evaluate()
		t.check_eq(failed.result,"failed","no moves daily")
		var expired := GameSession.new(1,"daily",day)
		expired.finish("expired")
		t.check_eq(expired.result,"expired","expiry transition")
