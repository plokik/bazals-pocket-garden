class_name CoinHudPresenter
extends RefCounted

var value_label: Label


func bind(label: Label) -> void:
	value_label = label


func is_bound() -> bool:
	return value_label != null


func refresh(value: float) -> void:
	if not is_bound():
		return
	value_label.text = "%d" % roundi(value)
