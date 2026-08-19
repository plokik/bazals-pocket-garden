class_name DayHudPresenter
extends RefCounted

var day_label: Label


func bind(label: Label) -> void:
	day_label = label


func is_bound() -> bool:
	return day_label != null


func refresh(display_day: int) -> void:
	if not is_bound():
		return
	var safe_day := maxi(1, display_day)
	day_label.text = "DEN %d" % safe_day
	var digits := str(safe_day).length()
	var font_size := 16
	if digits >= 6:
		font_size = 8
	elif digits == 5:
		font_size = 10
	elif digits == 4:
		font_size = 11
	elif digits in [2, 3]:
		font_size = 13
	day_label.add_theme_font_size_override("font_size", font_size)
