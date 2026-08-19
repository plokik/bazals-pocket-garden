class_name SeedSelectorPresenter
extends RefCounted

var species_buttons: Dictionary = {}
var status_label: Label


func bind(buttons: Dictionary, status: Label) -> void:
	species_buttons = buttons
	status_label = status


func is_bound() -> bool:
	return not species_buttons.is_empty() and status_label != null


func refresh(game_session: GameSession) -> void:
	if not is_bound():
		return
	for species_id in species_buttons:
		var species_button := species_buttons[species_id] as Button
		var owned := species_button.get_meta("owned_label") as Label
		var count := game_session.get_seed_count(str(species_id))
		if owned != null:
			owned.text = "V zásobě: %d semínek" % count
		species_button.disabled = not game_session.can_plant_species(str(species_id))
	status_label.text = "První společný cyklus začíná bazalkou. Ostatní druhy se otevřou hned potom." if game_session.is_tutorial_seed_choice_required() else "Žádné semínko? Další koupíš v OBCHODĚ za herní mince."
