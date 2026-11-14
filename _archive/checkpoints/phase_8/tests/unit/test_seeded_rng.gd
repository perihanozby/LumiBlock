extends RefCounted

func run(t) -> void:
	var rng := SeededRng.new(1)
	# Independently calculated from the standard JavaScript Mulberry32 reference.
	for expected in [2693262067,11749833,2265367787,4213581821,4159151403]:
		t.check_eq(rng.next_u32(),expected,"mulberry32 reference seed=1")
	var restored := SeededRng.new(int(JSON.parse_string(JSON.stringify({"state":rng.state})).state))
	for i in 1000:
		t.check_eq(restored.next_u32(),rng.next_u32(),"resume exact")
		t.check(rng.state>=0 and rng.state<4294967296,"state u32")
