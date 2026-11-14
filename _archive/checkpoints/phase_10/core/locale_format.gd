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

static func phrase(key: String,locale: String) -> String:
	var translation:=TranslationServer.get_translation_object(TranslationServer.standardize_locale(locale))
	if translation!=null:
		var message:=str(translation.get_message(key))
		if not message.is_empty(): return message
	return str(TranslationServer.translate(key))

static func duration(seconds: float, locale: String = "en") -> String:
	var minutes := maxi(0,int(seconds/60))
	return ("%d %s " % [minutes/60,phrase("time.h",locale)] if minutes>=60 else "") + "%d %s" % [minutes%60,phrase("time.min",locale)]

static func date(value: Variant, locale: String = "en") -> String:
	var parts: Dictionary = Time.get_datetime_dict_from_datetime_string(value,false) if value is String else Time.get_date_dict_from_unix_time(int(value))
	return phrase("date.pattern",locale).format({"d":parts.day,"month":phrase("month.%d" % int(parts.month),locale),"y":parts.year})
