class_name StorageInventoryPresenter
extends RefCounted

var inventory_label: Label
var value_labels: Dictionary = {}


func bind(label: Label, values: Dictionary) -> void:
	inventory_label = label
	value_labels = values


func is_bound() -> bool:
	return inventory_label != null and value_labels.size() == 3


func refresh(game_session: GameSession) -> void:
	if not is_bound():
		return
	inventory_label.text = "AKTUÁLNÍ ZÁSOBY  ·  vybraná pozice %d/%d" % [game_session.selected_plant_index + 1, GameSession.MAX_PLANT_SLOTS]
	(value_labels.seeds as Label).text = str(game_session.get_total_seed_count())
	(value_labels.fertilizer as Label).text = str(game_session.fertilizer_doses)
	(value_labels.harvests as Label).text = str(game_session.harvest_count)
