extends RefCounted

func run(t) -> void:
	var session := GameSession.new(12)
	session.tray = [PieceGenerator.make_piece("mono",0),PieceGenerator.make_piece("mono",1),PieceGenerator.make_piece("mono",2)]
	t.check(session.place(0,Vector2i.ZERO).valid,"first placement")
	t.check_eq(session.tray.size(),3,"fixed slots")
	t.check(session.tray[0]==null and session.tray[1].color==1,"remaining slot stable")
	t.check(not session.place(0,Vector2i.ONE).valid,"empty slot safe")
	var snapshot := session.to_dict()
	var resumed := GameSession.from_dict(snapshot)
	t.check_eq(resumed.to_dict(),snapshot,"session exact roundtrip")
	for row in session.board.cells: row.fill(0)
	var stuck := GameSession.from_dict(session.to_dict())
	t.check_eq(stuck.state,"finished","restore reevaluates game over")
	var finished := [0]
	stuck.game_over.connect(func(_reason): finished[0]+=1)
	stuck.evaluate()
	t.check_eq(finished[0],0,"finish idempotent")
