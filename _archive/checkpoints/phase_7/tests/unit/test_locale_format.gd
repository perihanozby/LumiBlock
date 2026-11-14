extends RefCounted

func run(t) -> void:
	for locale in ["en","ja","ko","zh-CN","ar","hi","th"]: t.check_eq(LocaleFormat.number(1234567,locale),"1,234,567","comma grouping "+locale)
	for locale in ["tr","es","pt-BR","de","it","id","vi"]: t.check_eq(LocaleFormat.number(1234567,locale),"1.234.567","dot grouping "+locale)
	t.check_eq(LocaleFormat.number(1234567,"fr"),"1\u202f234\u202f567","French grouping")
	t.check_eq(LocaleFormat.number(1234567,"ru"),"1\u00a0234\u00a0567","Russian grouping")
	t.check_eq(LocaleFormat.number(-10),"-10","signed number")
