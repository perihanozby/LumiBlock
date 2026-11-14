class_name LocaleFormat
extends RefCounted

static func number(value: int, locale: String = "en") -> String:
	var separator := ","
	if locale in ["tr","es","pt-BR","de","it","id","vi"]: separator = "."
	elif locale == "fr": separator = "\u202f"
	elif locale == "ru": separator = "\u00a0"
	var digits := str(absi(value))
	var result := ""
	for i in digits.length():
		if i>0 and (digits.length()-i)%3==0: result += separator
		result += digits[i]
	return ("-" if value<0 else "")+result

static func duration(seconds: float, _locale: String = "en") -> String:
	var minutes := maxi(0,int(seconds/60))
	return ("%d %s " % [minutes/60,TranslationServer.translate("time.h")] if minutes>=60 else "") + "%d %s" % [minutes%60,TranslationServer.translate("time.min")]

static func date(value: Variant, _locale: String = "en") -> String:
	var parts: Dictionary = Time.get_datetime_dict_from_datetime_string(value,false) if value is String else Time.get_date_dict_from_unix_time(int(value))
	return TranslationServer.translate("date.pattern").format({"d":parts.day,"month":TranslationServer.translate("month.%d" % int(parts.month)),"y":parts.year})
