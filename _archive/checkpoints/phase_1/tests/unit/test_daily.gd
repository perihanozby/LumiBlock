extends RefCounted

func run(t) -> void:
	var start := Time.get_unix_time_from_datetime_string("2024-01-01")
	var templates := [0,0,0]
	for day in 366:
		var date := Time.get_date_string_from_unix_time(start+day*86400)
		var mission := DailyChallenge.describe(date)
		templates[mission.template] += 1
		var range_values: Array = [[16,24],[2500,4500],[3,5]][mission.template]
		t.check(mission.target>=range_values[0] and mission.target<=range_values[1],"daily valid target")
		var board := DailyChallenge.start_board(date)
		t.check(board.occupancy()>=10/64.0 and board.occupancy()<=18/64.0,"daily occupancy")
		t.check_eq(board.clear_completed().cells.size(),0,"no complete start lines")
	for count in templates: t.check(count>90 and count<155,"template distribution")
	var a := GameSession.new(1,"daily","2024-12-31")
	var b := GameSession.new(2,"daily","2024-12-31")
	t.check_eq(a.board.cells,b.board.cells,"same date same board")
	for i in 10:
		for slot in 3: t.check_eq(a.tray[slot].to_dict(),b.tray[slot].to_dict(),"same date first 30 pieces")
		a.refill()
		b.refill()
