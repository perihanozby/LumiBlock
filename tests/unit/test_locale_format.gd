extends RefCounted

func run(t) -> void:
	for locale in ["en","ja","ko","zh-CN","ar","hi","th"]: t.check_eq(LocaleFormat.number(1234567,locale),"1,234,567","comma grouping "+locale)
	for locale in ["tr","es","pt-BR","de","it","id","vi"]: t.check_eq(LocaleFormat.number(1234567,locale),"1.234.567","dot grouping "+locale)
	t.check_eq(LocaleFormat.number(1234567,"fr"),"1\u202f234\u202f567","French grouping")
	t.check_eq(LocaleFormat.number(1234567,"ru"),"1\u00a0234\u00a0567","Russian grouping")
	t.check_eq(LocaleFormat.number(-10),"-10","signed number")
	t.check_eq(LocaleFormat.duration(8040,"tr"),"2 sa 14 dk","Turkish duration uses requested locale")
	t.check_eq(LocaleFormat.duration(8040,"ja"),"2 時間 14 分","Japanese duration")
	t.check_eq(LocaleFormat.date("2026-11-14","tr"),"14 Kasım 2026","Turkish month")
	t.check_eq(LocaleFormat.date("2026-11-14","ja"),"2026年11月14日","Japanese date pattern")
	for locale in ["en","tr","es","pt-BR","fr","de","it","ja","ko","zh-CN","ar","hi","id","vi","ru","th"]:
		t.check(not "month." in LocaleFormat.date("2026-11-14",locale),"translated month for "+locale)
		t.check(not "time." in LocaleFormat.duration(8040,locale),"translated duration for "+locale)
