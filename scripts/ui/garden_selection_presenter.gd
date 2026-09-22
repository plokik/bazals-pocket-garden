class_name GardenSelectionPresenter
extends RefCounted

const EMPTY_SLOT_TEXT := "VOLNÝ KVĚTINÁČ"

var plant_count_label: Label
var plant_position_label: Label


func bind(count_label: Label, position_label: Label) -> void:
	plant_count_label = count_label
	plant_position_label = position_label


func is_bound() -> bool:
	return plant_count_label != null and plant_position_label != null


func refresh(occupied_count: int, max_slots: int, selected_index: int, slot_empty: bool, plant_name: String) -> void:
	if not is_bound():
		return
	plant_count_label.text = "%d/%d OBSAZENO" % [occupied_count, max_slots]
	var display_name := EMPTY_SLOT_TEXT if slot_empty else plant_name.to_upper()
	plant_position_label.text = "%s  ·  %d/%d" % [display_name, selected_index + 1, max_slots]
