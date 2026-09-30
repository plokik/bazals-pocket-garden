class_name PlantActionPresenter
extends RefCounted

const TooltipPolicy := preload("res://scripts/ui/tooltip_policy.gd")
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
		TooltipPolicy.apply(seed_button, "Nejdřív oprav kritickou péči, potom odstraň poškozené listy")

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
		var airflow_percent := roundi(plant.ventilation)
		_set_text(vent_button, "Vyvětrat\nProudění\n%d%%" % airflow_percent, "Vyvětrat · proudění %d%%" % airflow_percent)
		_set_visual(vent_button, not plant.is_growing())


func _set_text(button: Button, text_value: String, tooltip := "") -> void:
	TooltipPolicy.apply(button, text_value if tooltip.is_empty() else tooltip)
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
		var target := _get_icon_color(icon_active)
		var previous_target: Color = icon.get_meta("resting_color", target)
		icon.set_meta("resting_color", target)
		var tween := icon.get_meta("light_tween") as Tween if icon.has_meta("light_tween") else null
		if tween != null and tween.is_valid() and previous_target == target and not disabled:
			return
		if tween != null:
			_reset_icon_transition(icon)
		icon.modulate = target


func play_lamp_transition(enabled: bool, reduced_motion: bool) -> void:
	stop_lamp_transition()
	if lamp_button == null or reduced_motion or lamp_button.disabled:
		return
	var icon := lamp_button.get_meta("action_icon", null) as TextureRect
	if icon == null:
		return
	var resting_color: Color = icon.get_meta("resting_color", icon.modulate)
	icon.pivot_offset = icon.size * 0.5
	icon.scale = Vector2(0.86, 0.86) if enabled else Vector2(1.10, 1.10)
	icon.rotation = -0.12 if enabled else 0.10
	icon.modulate = Color("#ffe28c") if enabled else Color.WHITE
	var tween := icon.create_tween()
	icon.set_meta("light_tween", tween)
	tween.tween_property(icon, "scale", Vector2(1.14, 1.14) if enabled else Vector2(0.88, 0.88), 0.17).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(icon, "rotation", 0.10 if enabled else -0.06, 0.17)
	tween.parallel().tween_property(icon, "modulate", resting_color, 0.38)
	tween.tween_property(icon, "scale", Vector2.ONE, 0.21).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(icon, "rotation", 0.0, 0.21)
	tween.finished.connect(func(): _reset_icon_transition(icon))


func stop_lamp_transition() -> void:
	if lamp_button == null:
		return
	var icon := lamp_button.get_meta("action_icon", null) as TextureRect
	if icon != null:
		_reset_icon_transition(icon)


func _reset_icon_transition(icon: TextureRect) -> void:
	var tween := icon.get_meta("light_tween") as Tween if icon.has_meta("light_tween") else null
	if tween != null and tween.is_valid():
		tween.kill()
	if icon.has_meta("light_tween"):
		icon.remove_meta("light_tween")
	icon.scale = Vector2.ONE
	icon.rotation = 0.0
	icon.modulate = icon.get_meta("resting_color", icon.modulate)


func _get_icon_color(active: bool) -> Color:
	return Color.WHITE if active else INACTIVE_ICON_COLOR
