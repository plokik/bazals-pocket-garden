class_name CoinHudPresenter
extends RefCounted

const HudTextFitterScene := preload("res://scripts/ui/hud_text_fitter.gd")
const COMPACT_LABEL_WIDTH := 53.28

var value_label: Label
var text_fitter := HudTextFitterScene.new()


func bind(label: Label) -> void:
	value_label = label
	text_fitter.bind(value_label, 19, 6, COMPACT_LABEL_WIDTH)


func is_bound() -> bool:
	return value_label != null


func refresh(value: float) -> void:
	if not is_bound():
		return
	text_fitter.set_text("%d" % roundi(value))
