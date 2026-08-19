class_name PlantActionPresenter
extends RefCounted

const DISABLED_ALPHA := 0.44
const INACTIVE_ICON_COLOR := Color("#657568")

var seed_button: Button
var water_button: Button
var lamp_button: Button
var fertilizer_button: Button
var vent_button: Button


func bind(seed: Button, water: Button, lamp: Button, fertilizer: Button, vent: Button) -> void:
	seed_button = seed
	water_button = water
	lamp_button = lamp
	fertilizer_button = fertilizer
	vent_button = vent


func is_bound() -> bool:
	return seed_button != null and water_button != null and lamp_button != null and fertilizer_button != null and vent_button != null


func refresh(plant: PlantSimulation, fertilizer_doses: int, water_amount_ml := 120.0, treatment_relief := 52.0) -> void:
	if not is_bound() or plant == null:
		return
	var is_wilted := plant.has_method("is_wilted") and plant.is_wilted()
	var fatal_actions: Array[String] = plant.get_fatal_care_issue_ids() if plant.has_method("get_fatal_care_issue_ids") else []
	var prune_blocked := is_wilted and plant.get_fatal_care_issue_count() >= plant.get_critical_care_issue_limit()

	seed_button.visible = plant.stage == PlantSimulation.Stage.EMPTY or plant.stage == PlantSimulation.Stage.DEAD or is_wilted
	seed_button.set_meta("action_mode", "seed" if plant.stage == PlantSimulation.Stage.EMPTY else ("clear" if plant.stage == PlantSimulation.Stage.DEAD else ("prune" if is_wilted else "seed")))
	if is_wilted:
		_set_text(seed_button, "ODSTRANIT\nLISTY", "Odstranit poškozené listy")
	elif plant.stage == PlantSimulation.Stage.DEAD:
		_set_text(seed_button, "VYČISTIT\nKVĚTINÁČ", "Vyčistit květináč")
	else:
		_set_text(seed_button, "ZASADIT")
	_set_visual(seed_button, prune_blocked)
	if prune_blocked:
		seed_button.tooltip_text = "Nejdřív oprav kritickou péči, potom odstraň poškozené listy"

	water_button.visible = plant.stage != PlantSimulation.Stage.EMPTY and plant.stage != PlantSimulation.Stage.DEAD and (not is_wilted or "water" in fatal_actions)
	_set_visual(water_button, not plant.is_growing())
	_set_text(water_button, "Zalít %d ml" % roundi(water_amount_ml))

	lamp_button.visible = plant.stage != PlantSimulation.Stage.EMPTY and plant.stage != PlantSimulation.Stage.DEAD and not is_wilted
	_set_visual(lamp_button, not plant.is_growing(), plant.lamp_on)
	_set_text(lamp_button, "Světlo: %s" % ("ZAP" if plant.lamp_on else "VYP"))

	fertilizer_button.visible = plant.stage != PlantSimulation.Stage.EMPTY and plant.stage != PlantSimulation.Stage.DEAD and (not is_wilted or "fertilize" in fatal_actions)
	_set_visual(fertilizer_button, not plant.is_growing() or fertilizer_doses <= 0)
	_set_text(fertilizer_button, "Hnojit · %d×" % fertilizer_doses)

	vent_button.visible = plant.stage != PlantSimulation.Stage.EMPTY and plant.stage != PlantSimulation.Stage.DEAD and (not is_wilted or "ventilate" in fatal_actions or "treat" in fatal_actions)
	var treatment_mode := plant.disease_level > 0
	vent_button.set_meta("action_mode", "treatment" if treatment_mode else "ventilation")
	vent_button.set_meta("treatment_relief", treatment_relief if treatment_mode else 0.0)
	if treatment_mode:
		var treatment_ready := plant.can_treat_disease()
		_set_text(
			vent_button,
			"OŠETŘIT" if treatment_ready else "LÉČBA PŮSOBÍ",
			"Ošetřit plíseň · sníží tlak o %d bodů" % roundi(treatment_relief) if treatment_ready else "Ošetření působí · vyčkej na pokles proudění"
		)
		_set_visual(vent_button, not treatment_ready)
	else:
		_set_text(vent_button, "Vyvětrat")
		_set_visual(vent_button, not plant.is_growing())


func _set_text(button: Button, text_value: String, tooltip := "") -> void:
	button.tooltip_text = text_value if tooltip.is_empty() else tooltip
	var label := button.get_meta("action_label", null) as Label
	if label != null:
		label.text = text_value


func _set_visual(button: Button, disabled: bool, icon_active := true) -> void:
	button.disabled = disabled
	var content := button.get_meta("action_content", null) as Control
	if content != null:
		content.modulate = Color(1, 1, 1, DISABLED_ALPHA if disabled else 1.0)
	var icon := button.get_meta("action_icon", null) as TextureRect
	if icon != null:
		icon.modulate = Color.WHITE if icon_active else INACTIVE_ICON_COLOR
