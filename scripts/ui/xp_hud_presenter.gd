class_name XpHudPresenter
extends RefCounted

var level_label: Label
var value_label: Label


func bind(target_level_label: Label, target_value_label: Label) -> void:
	level_label = target_level_label
	value_label = target_value_label


func is_bound() -> bool:
	return level_label != null and value_label != null


func refresh(level: int, xp_in_level: int) -> void:
	if not is_bound():
		return
	level_label.text = "ÚROVEŇ %d" % level
	value_label.text = "%d/100 XP" % xp_in_level
