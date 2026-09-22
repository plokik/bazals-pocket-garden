extends "res://scripts/ui/garden_selection_presenter.gd"
## Two explicit lines retain the plant name and slot on narrow screens.

func refresh(occupied_count: int, max_slots: int, selected_index: int, slot_empty: bool, plant_name: String) -> void:
	super.refresh(occupied_count, max_slots, selected_index, slot_empty, plant_name)
	if is_bound():
		var title := EMPTY_SLOT_TEXT if slot_empty else plant_name.to_upper()
		plant_position_label.text = "%s\n%d/%d" % [title, selected_index + 1, max_slots]
