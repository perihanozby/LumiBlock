extends RefCounted

func run(t) -> void:
	for size in [Vector2(360,640),Vector2(360,780),Vector2(390,844),Vector2(412,915),Vector2(430,932),Vector2(480,1000),Vector2(600,1024)]:
		for inset in [0.0,32.0]:
			var safe := Rect2(Vector2(0,inset),size-Vector2(0,inset+24))
			var layout := LayoutMetrics.compute(size,safe)
			t.check_eq(layout.board_rect.size.x,layout.board_rect.size.y,"square board")
			t.check(layout.board_side<=520,"tablet cap")
			t.check(layout.pitch>0,"positive pitch")
			for slot in layout.slots:
				t.check(slot.size.x>=48 and slot.size.y>=48,"touch target")
				t.check(safe.encloses(slot),"tray within safe area")
