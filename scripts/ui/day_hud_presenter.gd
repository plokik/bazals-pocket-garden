class_name DayHudPresenter
extends RefCounted

const HudTextFitterScene := preload("res://scripts/ui/hud_text_fitter.gd")
const COMPACT_LABEL_WIDTH := 53.28

var day_label: Label
var text_fitter := HudTextFitterScene.new()


func bind(label: Label) -> void:
	day_label = label
	text_fitter.bind(day_label, 16, 6, COMPACT_LABEL_WIDTH)


func is_bound() -> bool:
	return day_label != null


func refresh(display_day: int) -> void:
	if not is_bound():
		return
	var safe_day := maxi(1, display_day)
	text_fitter.set_text("DEN %d" % safe_day)
