class_name PlantSimulation
extends RefCounted

const PlantBehaviorCatalogScene := preload("res://scripts/plant_behavior_catalog.gd")
const ENVIRONMENT_DAY_SECONDS := 3840.0
const MAX_INTEGRATION_STEP_SECONDS := 10.0
const TREATMENT_READY_VENTILATION := 70.0

signal changed
signal event_created(message: String)

enum Stage {
	EMPTY,
	GERMINATING,
	SPROUT,
	VEGETATIVE,
	MATURE,
	HARVESTED,
	DRYING,
	DRY,
	PACKAGED,
	DEAD,
}

var profile: Dictionary = {}
var _behavior_catalog := PlantBehaviorCatalogScene.new()
var _behavior_definitions: Array[Dictionary] = []
var stage: Stage = Stage.EMPTY
var growth_percent := 0.0
var health := 100.0
var moisture := 0.0
var nutrients := 0.0
var ventilation := 58.0
var disease_pressure := 0.0
var disease_level := 0
var plant_age_seconds := 0.0
var growth_target_seconds := 0.0
var tutorial_cycle := false
var mature_elapsed_seconds := 0.0
var critical_neglect_seconds := 0.0
var drying_progress := 0.0
var fresh_harvest_g := 0.0
var dry_harvest_g := 0.0
var harvest_quality := 0.0
var lamp_on := false

# Permanent equipment bonuses are owned by GameSession and projected onto each
# plant at runtime. Defaults deliberately preserve the pre-equipment balance.
var equipment_lamp_lux := 11500.0
var equipment_ventilation_decay_multiplier := 1.0
var equipment_disease_gain_multiplier := 1.0
var equipment_water_loss_multiplier := 1.0
var equipment_harvest_yield_multiplier := 1.0

var temperature_c := 22.0
var humidity_percent := 55.0
var ph := 6.45
var ec_ms_cm := 1.1
var light_lux := 0.0
var co2_ppm := 460.0
var oxygen_percent := 20.90
var oxygen_balance_mg_h := 0.0
var photosynthesis_mg_h := 0.0
var respiration_mg_h := 0.0
var condition_score := 1.0
var current_issue := "Žádný problém"
var weather_name := "Jasno"


func _init(definition: Dictionary = {}) -> void:
	profile = definition.duplicate(true)
	_cache_behavior_definitions()
	reset()


func configure_profile(definition: Dictionary) -> void:
	if stage != Stage.EMPTY:
		return
	profile = definition.duplicate(true)
	_cache_behavior_definitions()
	reset()


func configure_equipment(effects: Dictionary) -> void:
	equipment_lamp_lux = maxf(0.0, float(effects.get("lamp_lux", 11500.0)))
	equipment_ventilation_decay_multiplier = clampf(float(effects.get("ventilation_decay_multiplier", 1.0)), 0.25, 1.0)
	equipment_disease_gain_multiplier = clampf(float(effects.get("disease_gain_multiplier", 1.0)), 0.20, 1.0)
	equipment_water_loss_multiplier = clampf(float(effects.get("water_loss_multiplier", 1.0)), 0.35, 1.0)
	equipment_harvest_yield_multiplier = clampf(float(effects.get("harvest_yield_multiplier", 1.0)), 1.0, 2.0)


func get_species_id() -> String:
	return str(profile.get("id", "basil_genovese"))


func get_display_name() -> String:
	return str(profile.get("display_name", "Bazalka pravá"))


func get_short_name() -> String:
	return str(profile.get("short_name", get_display_name()))


func get_behavior_ids() -> Array[String]:
	var behavior_ids: Array[String] = []
	for definition in _behavior_definitions:
		behavior_ids.append(str(definition.get("id", "")))
	return behavior_ids


func get_behavior_definitions() -> Array[Dictionary]:
	var definitions: Array[Dictionary] = []
	for definition in _behavior_definitions:
		definitions.append(definition.duplicate(true))
	return definitions


func get_behavior_status_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for definition in _behavior_definitions:
		var raw_activation: Variant = definition.get("activation", {})
		var activation_type := str((raw_activation as Dictionary).get("type", "")) if raw_activation is Dictionary else ""
		var active := is_growing() and _is_behavior_definition_active(definition)
		if activation_type == "harvest_quality_at_least":
			active = stage in [Stage.MATURE, Stage.HARVESTED, Stage.DRYING, Stage.DRY, Stage.PACKAGED] \
				and _is_behavior_definition_active(definition)
		elif activation_type == "sale_seed_drop":
			active = stage not in [Stage.EMPTY, Stage.DEAD] and _is_behavior_definition_active(definition)
		var status_text := str(definition.get("active_text" if active else "inactive_text", ""))
		entries.append({
			"id": str(definition.get("id", "")),
			"label": str(definition.get("label", definition.get("name", ""))),
			"name": str(definition.get("name", definition.get("label", ""))),
			"description": str(definition.get("description", "")),
			"compact_description": str(definition.get("compact_description", "")),
			"active": active,
			"status_text": status_text,
			"status": status_text,
			"activation": (definition.get("activation", {}) as Dictionary).duplicate(true),
			"effects": (definition.get("effects", {}) as Dictionary).duplicate(true),
		})
	return entries


func _cache_behavior_definitions() -> void:
	_behavior_definitions = _behavior_catalog.get_definitions(profile.get("behavior_ids", []))


func _is_behavior_definition_active(definition: Dictionary, context: Dictionary = {}) -> bool:
	var raw_activation: Variant = definition.get("activation", {})
	if not raw_activation is Dictionary:
		return false
	var activation: Dictionary = raw_activation
	match str(activation.get("type", "")):
		"stress_above":
			var stress := float(context.get("stress", 1.0 - condition_score))
			return stress > float(activation.get("threshold", 0.32))
		"condition_score_at_least":
			var sample_condition := float(context.get("condition_score", condition_score))
			return sample_condition >= float(activation.get("threshold", 1.0))
		"harvest_quality_at_least":
			var sample_quality := -1.0
			if context.has("harvest_quality"):
				var raw_quality: Variant = context.get("harvest_quality")
				if not (raw_quality is int or raw_quality is float):
					return false
				sample_quality = float(raw_quality)
			elif stage == Stage.MATURE:
				sample_quality = get_estimated_harvest_quality()
			elif stage in [Stage.HARVESTED, Stage.DRYING, Stage.DRY, Stage.PACKAGED]:
				sample_quality = harvest_quality
			return sample_quality >= float(activation.get("threshold", 1.0))
		"watering_crosses_profile_band":
			var minimum := float(profile.get(str(activation.get("minimum_field", "ideal_moisture_min")), 42.0))
			var maximum := float(profile.get(str(activation.get("maximum_field", "ideal_moisture_max")), 72.0))
			if context.has("moisture_before") and context.has("moisture_after"):
				var before := float(context.get("moisture_before", moisture))
				var after := float(context.get("moisture_after", moisture))
				return before < minimum and after >= minimum and after <= maximum
			return moisture < minimum
		"disease_pressure_gain":
			var sample_humidity := float(context.get("humidity_percent", humidity_percent))
			var sample_ventilation := float(context.get("ventilation", ventilation))
			return sample_humidity > float(activation.get("humidity_above", 76.0)) \
				and sample_ventilation < float(activation.get("ventilation_below", 38.0))
		"growth_value_in_profile_band":
			var raw_effects: Variant = definition.get("effects", {})
			var applies_while_mature := raw_effects is Dictionary \
				and (raw_effects as Dictionary).has("nutrient_loss_multiplier")
			if stage not in [Stage.GERMINATING, Stage.SPROUT, Stage.VEGETATIVE] \
				and not (stage == Stage.MATURE and applies_while_mature):
				return false
			var value_name := str(activation.get("value", ""))
			var minimum_field := str(activation.get("minimum_field", ""))
			var maximum_field := str(activation.get("maximum_field", ""))
			if value_name.is_empty() or minimum_field.is_empty() or maximum_field.is_empty():
				return false
			if not profile.has(minimum_field) or not profile.has(maximum_field):
				return false
			var sample_value := 0.0
			if context.has(value_name):
				var raw_sample: Variant = context.get(value_name)
				if not (raw_sample is int or raw_sample is float):
					return false
				sample_value = float(raw_sample)
			else:
				match value_name:
					"moisture": sample_value = moisture
					"nutrients": sample_value = nutrients
					"ventilation": sample_value = ventilation
					"condition_score": sample_value = condition_score
					_: return false
			var minimum := float(profile.get(minimum_field, 0.0))
			var maximum := float(profile.get(maximum_field, 0.0))
			return minimum <= maximum and sample_value >= minimum and sample_value <= maximum
		"value_at_or_below_profile_field":
			var value_name := str(activation.get("value", ""))
			var profile_field := str(activation.get("profile_field", ""))
			if value_name.is_empty() or profile_field.is_empty() or not profile.has(profile_field):
				return false
			var sample_value := float(context.get(value_name, moisture if value_name == "moisture" else 0.0))
			return sample_value <= float(profile.get(profile_field, 0.0))
		"daylight_light_below":
			var sample_light := maxf(0.0, float(context.get("light_lux", light_lux)))
			# Runtime condition checks pass the authoritative daylight flag. The
			# status-only fallback treats zero natural light as night, so the UI
			# never advertises shade tolerance during darkness.
			var sample_daylight := bool(context.get("daylight", sample_light > 0.0))
			return sample_daylight and sample_light < maxf(0.0, float(activation.get("threshold_lux", 0.0)))
		"sale_seed_drop":
			return stage not in [Stage.EMPTY, Stage.DEAD]
	return false


func _get_active_effect_multiplier(effect_key: String, context: Dictionary = {}) -> float:
	var multiplier := 1.0
	for definition in _behavior_definitions:
		if not _is_behavior_definition_active(definition, context):
			continue
		var raw_effects: Variant = definition.get("effects", {})
		if raw_effects is Dictionary and raw_effects.has(effect_key):
			multiplier *= maxf(0.0, float(raw_effects.get(effect_key, 1.0)))
	return multiplier


func _get_active_effect_total(effect_key: String, context: Dictionary = {}) -> float:
	var total := 0.0
	for definition in _behavior_definitions:
		if not _is_behavior_definition_active(definition, context):
			continue
		var raw_effects: Variant = definition.get("effects", {})
		if raw_effects is Dictionary and raw_effects.has(effect_key):
			total += maxf(0.0, float(raw_effects.get(effect_key, 0.0)))
	return total


func _get_active_effect_maximum(effect_key: String, context: Dictionary = {}) -> float:
	var maximum := 0.0
	for definition in _behavior_definitions:
		if not _is_behavior_definition_active(definition, context):
			continue
		var raw_effects: Variant = definition.get("effects", {})
		if raw_effects is Dictionary and raw_effects.has(effect_key):
			maximum = maxf(maximum, maxf(0.0, float(raw_effects.get(effect_key, 0.0))))
	return maximum


func _get_active_effect_labels(effect_key: String, context: Dictionary = {}) -> Array[String]:
	var labels: Array[String] = []
	for definition in _behavior_definitions:
		if not _is_behavior_definition_active(definition, context):
			continue
		var raw_effects: Variant = definition.get("effects", {})
		if raw_effects is Dictionary and raw_effects.has(effect_key):
			labels.append(str(definition.get("label", definition.get("name", "SCHOPNOST"))))
	return labels


func reset() -> void:
	stage = Stage.EMPTY
	growth_percent = 0.0
	health = 100.0
	moisture = float(profile.get("initial_moisture", 62.0))
	nutrients = float(profile.get("initial_nutrients", 48.0))
	ventilation = 58.0
	disease_pressure = 0.0
	disease_level = 0
	plant_age_seconds = 0.0
	growth_target_seconds = 0.0
	tutorial_cycle = false
	mature_elapsed_seconds = 0.0
	critical_neglect_seconds = 0.0
	drying_progress = 0.0
	fresh_harvest_g = 0.0
	dry_harvest_g = 0.0
	harvest_quality = 0.0
	lamp_on = false
	_update_environment()


func plant_seed(target_seconds_override := -1.0, is_tutorial_cycle := false) -> bool:
	if stage != Stage.EMPTY:
		return false
	stage = Stage.GERMINATING
	growth_percent = 0.0
	health = 100.0
	plant_age_seconds = 0.0
	growth_target_seconds = maxf(1.0, target_seconds_override) if target_seconds_override > 0.0 else get_base_growth_seconds()
	tutorial_cycle = is_tutorial_cycle
	mature_elapsed_seconds = 0.0
	critical_neglect_seconds = 0.0
	moisture = float(profile.get("initial_moisture", 62.0))
	nutrients = float(profile.get("initial_nutrients", 48.0))
	event_created.emit("Semínko rostliny %s je zasazené. Udržuj půdu vlhkou, ne rozmočenou." % get_display_name())
	changed.emit()
	return true


func water(amount_ml: float = 120.0, safe_moisture_cap: float = 100.0) -> bool:
	if not is_growing():
		return false
	var before := moisture
	var capped_target := minf(clampf(safe_moisture_cap, 0.0, 100.0), moisture + amount_ml / 4.2)
	moisture = clampf(maxf(before, capped_target), 0.0, 100.0)
	var watering_context := {
		"moisture_before": before,
		"moisture_after": moisture,
	}
	var restored_health := _get_active_effect_total("health_restore", watering_context)
	var restoring_behavior_labels := _get_active_effect_labels("health_restore", watering_context)
	var health_before := health
	health = minf(100.0, health + restored_health)
	if moisture > 88.0:
		event_created.emit("Půda je velmi mokrá. Další zálivku odlož, kořeny potřebují kyslík.")
	else:
		event_created.emit("Zalito %d ml. Vlhkost půdy se zvýšila o %d bodů." % [int(amount_ml), int(moisture - before)])
	if health > health_before and not restoring_behavior_labels.is_empty():
		event_created.emit("%s · zdraví +%d." % [restoring_behavior_labels[0], roundi(health - health_before)])
	_reset_recoverable_critical_timer()
	changed.emit()
	return true


func fertilize(dose_ml: float = 5.0) -> bool:
	if not is_growing():
		return false
	nutrients = clampf(nutrients + dose_ml * 5.0, 0.0, 100.0)
	if nutrients > 82.0:
		event_created.emit("Pozor na přehnojení. Vysoké EC může poškodit kořeny.")
	else:
		event_created.emit("Přidáno %d ml tekutého hnojiva." % int(dose_ml))
	_reset_recoverable_critical_timer()
	changed.emit()
	return true


func ventilate(disease_relief: float = 12.0) -> bool:
	if not is_growing():
		return false
	var next_ventilation := 100.0
	var next_disease_pressure := maxf(0.0, disease_pressure - maxf(0.0, disease_relief))
	var ventilation_improved := next_ventilation > ventilation and not is_equal_approx(next_ventilation, ventilation)
	var disease_pressure_reduced := next_disease_pressure < disease_pressure and not is_equal_approx(next_disease_pressure, disease_pressure)
	if not ventilation_improved and not disease_pressure_reduced:
		return false
	ventilation = next_ventilation
	disease_pressure = next_disease_pressure
	event_created.emit("Vyvětráno. Proudění vzduchu snižuje vlhkost a riziko plísně.")
	_reset_recoverable_critical_timer()
	changed.emit()
	return true


func can_treat_disease() -> bool:
	return is_growing() and disease_level > 0 and ventilation <= TREATMENT_READY_VENTILATION


func treat_disease(disease_relief: float = 52.0) -> bool:
	if not is_growing() or disease_level <= 0:
		event_created.emit("Rostlina teď nepotřebuje ošetření proti plísni.")
		return false
	if ventilation > TREATMENT_READY_VENTILATION:
		event_created.emit("Ošetření ještě působí. Nech proudění vzduchu dokončit práci.")
		return false
	var before := clampf(disease_pressure, 0.0, 100.0)
	disease_pressure = maxf(0.0, before - maxf(0.0, disease_relief))
	ventilation = 100.0
	if disease_pressure <= 18.0 and moisture < 76.0:
		disease_level = 0
		event_created.emit("Postřik a proudění zastavily plíseň. Rostlina se teď může zotavit.")
	else:
		event_created.emit("Ošetřeno. Tlak plísně klesl o %d bodů. Drž vlhkost pod 76%%." % roundi(before - disease_pressure))
	_reset_recoverable_critical_timer()
	changed.emit()
	return true


func toggle_lamp() -> bool:
	if not is_growing():
		return false
	lamp_on = not lamp_on
	event_created.emit("Pěstební světlo: %s." % ("zapnuto" if lamp_on else "vypnuto"))
	changed.emit()
	return true


func advance(simulation_seconds: float, environment_start_seconds := -1.0, suppress_mature_lifecycle := false) -> void:
	if simulation_seconds <= 0.0:
		return
	var remaining := minf(simulation_seconds, 259200.0)
	var elapsed := 0.0
	while remaining > 0.0:
		var step := minf(remaining, MAX_INTEGRATION_STEP_SECONDS)
		_advance_step(
			step,
			environment_start_seconds + elapsed + step if environment_start_seconds >= 0.0 else -1.0,
			suppress_mature_lifecycle
		)
		remaining -= step
		elapsed += step
	changed.emit()


func _advance_step(seconds: float, environment_time_seconds := -1.0, suppress_mature_lifecycle := false) -> void:
	if is_growing():
		plant_age_seconds += seconds
		_update_environment(environment_time_seconds)
		var hours := seconds / 3600.0
		_advance_moisture_loss(hours)
		_advance_nutrient_loss(hours)
		ventilation = maxf(28.0, ventilation - 1.4 * equipment_ventilation_decay_multiplier * hours)
		_update_condition_score()

		var target_seconds := get_growth_target_seconds()
		growth_percent = minf(
			100.0,
			growth_percent
				+ seconds / target_seconds * 100.0
					* get_growth_efficiency()
					* get_growth_behavior_multiplier()
		)

		var stress := 1.0 - condition_score
		if stress > 0.32:
			var stress_damage_multiplier := _get_active_effect_multiplier("stress_damage_multiplier", {"stress": stress})
			health = maxf(5.0, health - hours * stress * 1.9 * stress_damage_multiplier)
		else:
			health = minf(100.0, health + hours * 0.22)

		_update_disease(hours)
		_refresh_stage_from_growth()
		if stage == Stage.MATURE and not suppress_mature_lifecycle:
			_advance_mature_lifecycle(seconds)
	elif stage == Stage.DRYING:
		var drying_seconds := get_drying_target_seconds()
		drying_progress = minf(100.0, drying_progress + seconds / drying_seconds * 100.0)
		if drying_progress >= 100.0:
			stage = Stage.DRY
			dry_harvest_g = snappedf(fresh_harvest_g * float(profile.get("dry_matter_ratio", 0.16)), 0.1)
			event_created.emit("%s je suchá. Teď ji zabal do sáčku." % get_short_name())
		_update_environment(environment_time_seconds)
	else:
		_update_environment(environment_time_seconds)


func sync_environment(environment_time_seconds: float) -> void:
	_update_environment(environment_time_seconds)
	_update_condition_score(environment_time_seconds)
	if stage == Stage.DEAD:
		condition_score = 0.0
		current_issue = "Rostlina uhynula"
	changed.emit()


static func get_weather_for_environment_seconds(environment_time_seconds: float) -> String:
	var world_day := maxf(0.0, environment_time_seconds) / ENVIRONMENT_DAY_SECONDS
	var weather_roll := 0.5 + 0.5 * sin(floor(world_day) * 1.73 + 0.6)
	if weather_roll > 0.80:
		return "Jasno"
	if weather_roll > 0.62:
		return "Polojasno"
	if weather_roll > 0.42:
		return "Větrno"
	if weather_roll > 0.22:
		return "Zataženo"
	return "Déšť"


func _update_environment(environment_time_seconds := -1.0) -> void:
	var biological_day := environment_time_seconds / ENVIRONMENT_DAY_SECONDS if environment_time_seconds >= 0.0 else get_biological_day()
	var time_of_day := fmod(8.0 + biological_day * 24.0, 24.0)
	var sun_curve := maxf(0.0, sin((time_of_day - 6.0) / 12.0 * PI))
	var weather_roll := 0.5 + 0.5 * sin(floor(biological_day) * 1.73 + 0.6)
	var weather_light_factor := 1.0
	var weather_temperature_offset := 0.0
	var weather_humidity_offset := 0.0
	if weather_roll > 0.80:
		weather_name = "Jasno"
	elif weather_roll > 0.62:
		weather_name = "Polojasno"
		weather_light_factor = 0.86
	elif weather_roll > 0.42:
		weather_name = "Větrno"
		weather_light_factor = 0.78
		weather_temperature_offset = -0.5
	elif weather_roll > 0.22:
		weather_name = "Zataženo"
		weather_light_factor = 0.70
		weather_temperature_offset = -0.8
		weather_humidity_offset = 2.0
	else:
		weather_name = "Déšť"
		weather_light_factor = 0.56
		weather_temperature_offset = -1.2
		weather_humidity_offset = 5.0
	light_lux = sun_curve * 28500.0 * weather_light_factor + (equipment_lamp_lux if lamp_on else 0.0)
	temperature_c = 21.5 + sun_curve * 4.2 + weather_temperature_offset + (0.8 if lamp_on else 0.0)
	humidity_percent = clampf(57.0 - sun_curve * 7.0 + weather_humidity_offset + maxf(0.0, moisture - 72.0) * 0.24 - (ventilation - 45.0) * 0.06, 30.0, 92.0)
	ph = clampf(6.45 - maxf(0.0, nutrients - 70.0) * 0.013 + maxf(0.0, 25.0 - nutrients) * 0.008, 4.5, 8.0)
	ec_ms_cm = 0.35 + nutrients / 100.0 * 1.75

	var leaf_factor := clampf(growth_percent / 55.0, 0.0, 1.0) * health / 100.0
	var light_factor := clampf(light_lux / 14000.0, 0.0, 1.0)
	photosynthesis_mg_h = 7.5 * leaf_factor * light_factor
	respiration_mg_h = 1.4 * leaf_factor
	var net_exchange := photosynthesis_mg_h - respiration_mg_h
	oxygen_balance_mg_h = net_exchange * 0.73
	co2_ppm = clampf(475.0 - net_exchange * 6.0, 405.0, 495.0)
	oxygen_percent = 20.90 + oxygen_balance_mg_h * 0.001


func _update_condition_score(environment_time_seconds := -1.0) -> void:
	if stage == Stage.DEAD:
		condition_score = 0.0
		current_issue = "Rostlina uhynula"
		return
	var water_factor := _band_factor(moisture, float(profile.get("ideal_moisture_min", 42.0)), float(profile.get("ideal_moisture_max", 72.0)), 28.0)
	var nutrient_factor := _band_factor(nutrients, float(profile.get("ideal_nutrients_min", 32.0)), float(profile.get("ideal_nutrients_max", 76.0)), 30.0)
	var temperature_factor := _band_factor(temperature_c, float(profile.get("ideal_temperature_min", 20.0)), float(profile.get("ideal_temperature_max", 28.0)), 8.0)
	var ph_factor := _band_factor(ph, float(profile.get("ideal_ph_min", 5.8)), float(profile.get("ideal_ph_max", 7.0)), 1.5)
	var daylight := is_daylight_at(environment_time_seconds)
	var light_factor := clampf(light_lux / 9000.0, 0.12, 1.0) if daylight else 1.0
	if daylight:
		light_factor = maxf(light_factor, get_behavior_daylight_light_factor_floor(true, light_lux))
	var air_factor := clampf((ventilation - 18.0) / 45.0, 0.2, 1.0)
	condition_score = minf(water_factor, minf(nutrient_factor, minf(temperature_factor, minf(ph_factor, minf(light_factor, air_factor)))))
	condition_score = clampf(condition_score, 0.08, 1.0)
	current_issue = get_most_important_issue(daylight)


func is_daylight_at(environment_time_seconds := -1.0) -> bool:
	var environment_day := environment_time_seconds / ENVIRONMENT_DAY_SECONDS if environment_time_seconds >= 0.0 else get_biological_day()
	var time_of_day := fmod(8.0 + environment_day * 24.0, 24.0)
	return time_of_day >= 6.0 and time_of_day <= 20.0


func get_behavior_daylight_light_factor_floor(daylight: bool, sample_light_lux := -1.0) -> float:
	if not is_growing():
		return 0.0
	var sample := light_lux if sample_light_lux < 0.0 else maxf(0.0, sample_light_lux)
	return clampf(
		_get_active_effect_maximum("daylight_light_factor_floor", {
			"daylight": daylight,
			"light_lux": sample,
		}),
		0.0,
		1.0
	)


func get_effective_water_loss_per_hour(sample_moisture: float = -1.0) -> float:
	var sample := moisture if sample_moisture < 0.0 else clampf(sample_moisture, 0.0, 100.0)
	var base_loss := maxf(0.0, float(profile.get("water_loss_per_hour", 1.05))) * equipment_water_loss_multiplier
	var behavior_multiplier := _get_active_effect_multiplier("water_loss_multiplier", {"moisture": sample})
	return base_loss * behavior_multiplier


func get_effective_nutrient_loss_per_hour(sample_nutrients: float = -1.0) -> float:
	var sample := nutrients if sample_nutrients < 0.0 else clampf(sample_nutrients, 0.0, 100.0)
	var base_loss := maxf(0.0, float(profile.get("nutrient_loss_per_hour", 0.16)))
	var behavior_multiplier := _get_active_effect_multiplier("nutrient_loss_multiplier", {"nutrients": sample})
	return base_loss * behavior_multiplier


func get_estimated_seconds_until_nutrients(target: float) -> float:
	if not is_growing():
		return -1.0
	var target_nutrients := clampf(target, 0.0, 100.0)
	if target_nutrients >= nutrients:
		return 0.0
	var band := _get_nutrient_loss_behavior_band()
	var current := nutrients
	var elapsed_hours := 0.0
	if band.x >= 0.0 and current > band.y and target_nutrients < band.y:
		var rate_above := get_effective_nutrient_loss_per_hour((current + band.y) * 0.5)
		if rate_above <= 0.0:
			return -1.0
		elapsed_hours += (current - band.y) / rate_above
		current = band.y
	if band.x >= 0.0 and current > band.x and target_nutrients < band.x:
		var rate_in_band := get_effective_nutrient_loss_per_hour((current + band.x) * 0.5)
		if rate_in_band <= 0.0:
			return -1.0
		elapsed_hours += (current - band.x) / rate_in_band
		current = band.x
	var final_rate := get_effective_nutrient_loss_per_hour((current + target_nutrients) * 0.5)
	if final_rate <= 0.0:
		return -1.0
	elapsed_hours += (current - target_nutrients) / final_rate
	return elapsed_hours * 3600.0


func get_estimated_seconds_until_moisture(target: float) -> float:
	if not is_growing():
		return -1.0
	var target_moisture := clampf(target, 0.0, 100.0)
	if target_moisture >= moisture:
		return 0.0
	var transition := _get_water_loss_transition_moisture()
	var current := moisture
	var elapsed_hours := 0.0
	if transition >= 0.0 and current > transition and target_moisture < transition:
		var rate_above := get_effective_water_loss_per_hour((current + transition) * 0.5)
		if rate_above <= 0.0:
			return -1.0
		elapsed_hours += (current - transition) / rate_above
		current = transition
	var sample := (current + target_moisture) * 0.5
	var final_rate := get_effective_water_loss_per_hour(sample)
	if final_rate <= 0.0:
		return -1.0
	elapsed_hours += (current - target_moisture) / final_rate
	return elapsed_hours * 3600.0


func _advance_moisture_loss(hours: float) -> void:
	var remaining_hours := maxf(0.0, hours)
	if remaining_hours <= 0.0 or moisture <= 0.0:
		return
	var transition := _get_water_loss_transition_moisture()
	if transition >= 0.0 and moisture > transition:
		var rate_above := get_effective_water_loss_per_hour((moisture + transition) * 0.5)
		if rate_above <= 0.0:
			return
		var hours_to_transition := (moisture - transition) / rate_above
		if remaining_hours <= hours_to_transition:
			moisture = maxf(0.0, moisture - rate_above * remaining_hours)
			return
		moisture = transition
		remaining_hours -= hours_to_transition
	var rate := get_effective_water_loss_per_hour(moisture)
	moisture = maxf(0.0, moisture - rate * remaining_hours)


func _advance_nutrient_loss(hours: float) -> void:
	var remaining_hours := maxf(0.0, hours)
	if remaining_hours <= 0.0 or nutrients <= 0.0:
		return
	var band := _get_nutrient_loss_behavior_band()
	if band.x >= 0.0 and nutrients > band.y:
		var rate_above := get_effective_nutrient_loss_per_hour((nutrients + band.y) * 0.5)
		if rate_above <= 0.0:
			return
		var hours_to_band := (nutrients - band.y) / rate_above
		if remaining_hours <= hours_to_band:
			nutrients = maxf(0.0, nutrients - rate_above * remaining_hours)
			return
		nutrients = band.y
		remaining_hours -= hours_to_band
	if band.x >= 0.0 and nutrients > band.x:
		var rate_in_band := get_effective_nutrient_loss_per_hour((nutrients + band.x) * 0.5)
		if rate_in_band <= 0.0:
			return
		var hours_to_lower_bound := (nutrients - band.x) / rate_in_band
		if remaining_hours <= hours_to_lower_bound:
			nutrients = maxf(0.0, nutrients - rate_in_band * remaining_hours)
			return
		nutrients = band.x
		remaining_hours -= hours_to_lower_bound
	var rate_below := get_effective_nutrient_loss_per_hour(maxf(0.0, nutrients - 0.001))
	nutrients = maxf(0.0, nutrients - rate_below * remaining_hours)


func _get_nutrient_loss_behavior_band() -> Vector2:
	for definition in _behavior_definitions:
		var raw_effects: Variant = definition.get("effects", {})
		var raw_activation: Variant = definition.get("activation", {})
		if not raw_effects is Dictionary or not (raw_effects as Dictionary).has("nutrient_loss_multiplier"):
			continue
		if not raw_activation is Dictionary:
			continue
		var activation: Dictionary = raw_activation
		if str(activation.get("type", "")) != "growth_value_in_profile_band" \
			or str(activation.get("value", "")) != "nutrients":
			continue
		var minimum_field := str(activation.get("minimum_field", ""))
		var maximum_field := str(activation.get("maximum_field", ""))
		if not profile.has(minimum_field) or not profile.has(maximum_field):
			continue
		var minimum := clampf(float(profile.get(minimum_field, 0.0)), 0.0, 100.0)
		var maximum := clampf(float(profile.get(maximum_field, 0.0)), 0.0, 100.0)
		if minimum <= maximum:
			return Vector2(minimum, maximum)
	return Vector2(-1.0, -1.0)


func _get_water_loss_transition_moisture() -> float:
	for definition in _behavior_definitions:
		var raw_effects: Variant = definition.get("effects", {})
		var raw_activation: Variant = definition.get("activation", {})
		if not raw_effects is Dictionary or not raw_effects.has("water_loss_multiplier"):
			continue
		if not raw_activation is Dictionary:
			continue
		var activation: Dictionary = raw_activation
		if str(activation.get("type", "")) != "value_at_or_below_profile_field":
			continue
		if str(activation.get("value", "")) != "moisture":
			continue
		var profile_field := str(activation.get("profile_field", ""))
		if profile.has(profile_field):
			return clampf(float(profile.get(profile_field, 0.0)), 0.0, 100.0)
	return -1.0


func _update_disease(hours: float) -> void:
	if humidity_percent > 76.0 and ventilation < 38.0:
		var behavior_multiplier := _get_active_effect_multiplier("disease_pressure_gain_multiplier", {
			"humidity_percent": humidity_percent,
			"ventilation": ventilation,
		})
		disease_pressure += hours * (humidity_percent - 70.0) * 0.55 * equipment_disease_gain_multiplier * behavior_multiplier
	else:
		disease_pressure = maxf(0.0, disease_pressure - hours * 2.5)
	disease_pressure = clampf(disease_pressure, 0.0, 100.0)
	if disease_pressure >= 100.0:
		disease_level = 1
	if disease_level > 0:
		health = maxf(5.0, health - hours * 0.55)
		if disease_pressure <= 18.0 and ventilation > 55.0 and moisture < 76.0:
			disease_level = 0
			event_created.emit("Dobré podmínky zastavily šíření plísně. Rostlina se zotavuje.")


func _band_factor(value: float, ideal_min: float, ideal_max: float, tolerance: float) -> float:
	if value >= ideal_min and value <= ideal_max:
		return 1.0
	if value < ideal_min:
		return clampf(1.0 - (ideal_min - value) / tolerance, 0.05, 1.0)
	return clampf(1.0 - (value - ideal_max) / tolerance, 0.05, 1.0)


func get_most_important_issue(daylight: bool = true) -> String:
	if disease_level > 0:
		return "Plíseň listů"
	if moisture < 24.0:
		return "Sucho"
	if moisture > 88.0:
		return "Přemokření"
	if nutrients > 84.0:
		return "Přehnojení"
	if nutrients < 23.0:
		return "Málo živin"
	if daylight and light_lux < 3200.0:
		return "Málo světla"
	if humidity_percent > 76.0 and ventilation < 40.0:
		return "Riziko plísně"
	if temperature_c > 30.0:
		return "Přílišné teplo"
	return "Žádný problém"


func _refresh_stage_from_growth() -> void:
	if stage in [Stage.HARVESTED, Stage.DRYING, Stage.DRY, Stage.PACKAGED, Stage.DEAD, Stage.EMPTY]:
		return
	if growth_percent >= 100.0:
		if stage != Stage.MATURE:
			event_created.emit("%s dospěla. Můžeš ji sklidit." % get_short_name())
		stage = Stage.MATURE
	elif growth_percent >= 38.0:
		stage = Stage.VEGETATIVE
	elif growth_percent >= 10.0:
		stage = Stage.SPROUT
	else:
		stage = Stage.GERMINATING


func get_fatal_care_issue_count() -> int:
	return get_fatal_care_issue_ids().size()


func get_fatal_care_issue_ids() -> Array[String]:
	var issues: Array[String] = []
	if stage == Stage.EMPTY or stage == Stage.DEAD:
		return issues
	if moisture < 24.0:
		issues.append("water")
	if disease_level > 0:
		issues.append("treat")
	if moisture > 88.0 and ventilation < 40.0:
		issues.append("ventilate")
	if nutrients < 23.0:
		issues.append("fertilize")
	return issues


func get_critical_care_issue_limit() -> int:
	return maxi(1, int(profile.get("care_issue_limit", 1)))


func get_critical_wilt_seconds() -> float:
	return maxf(1.0, float(profile.get("critical_wilt_seconds", 7200.0)))


func get_critical_death_seconds() -> float:
	return maxf(get_critical_wilt_seconds(), float(profile.get("critical_death_seconds", 10800.0)))


func is_wilted() -> bool:
	return stage == Stage.MATURE and not tutorial_cycle and critical_neglect_seconds >= get_critical_wilt_seconds()


func get_seconds_until_wilt() -> float:
	if stage != Stage.MATURE or tutorial_cycle:
		return -1.0
	if is_wilted():
		return 0.0
	if get_fatal_care_issue_count() < get_critical_care_issue_limit():
		return -1.0
	return maxf(0.0, get_critical_wilt_seconds() - critical_neglect_seconds)


func get_seconds_until_death() -> float:
	if stage == Stage.DEAD:
		return 0.0
	if not is_wilted() or tutorial_cycle:
		return -1.0
	return maxf(0.0, get_critical_death_seconds() - critical_neglect_seconds)


func _advance_mature_lifecycle(seconds: float) -> void:
	if stage != Stage.MATURE:
		return
	if tutorial_cycle:
		mature_elapsed_seconds = 0.0
		critical_neglect_seconds = 0.0
		return
	mature_elapsed_seconds += seconds
	var already_wilted := is_wilted()
	var has_fatal_care_state := get_fatal_care_issue_count() >= get_critical_care_issue_limit()
	if already_wilted or has_fatal_care_state:
		critical_neglect_seconds = minf(get_critical_death_seconds(), critical_neglect_seconds + seconds)
	else:
		critical_neglect_seconds = 0.0
	if critical_neglect_seconds >= get_critical_death_seconds():
		stage = Stage.DEAD
		health = 0.0
		condition_score = 0.0
		lamp_on = false
		fresh_harvest_g = 0.0
		dry_harvest_g = 0.0
		harvest_quality = 0.0
		current_issue = "Rostlina uhynula"
		event_created.emit("%s uhynula po dlouhém zanedbání. Vyčisti květináč a začni znovu." % get_short_name())
	elif not already_wilted and is_wilted():
		current_issue = "Poškozené listy"
		event_created.emit("%s zvadla. Odstraň příčinu a potom poškozené listy." % get_short_name())


func _reset_recoverable_critical_timer() -> void:
	if stage == Stage.MATURE and not is_wilted() and get_fatal_care_issue_count() < get_critical_care_issue_limit():
		critical_neglect_seconds = 0.0


func prune_damaged_leaves() -> bool:
	if not is_wilted():
		return false
	if get_fatal_care_issue_count() >= get_critical_care_issue_limit():
		event_created.emit("Nejdřív odstraň všechny kritické příčiny, potom můžeš ostříhat poškozené listy.")
		return false
	critical_neglect_seconds = 0.0
	health = maxf(45.0, health)
	_update_condition_score()
	event_created.emit("Poškozené listy jsou odstraněné. %s se může znovu zotavit." % get_short_name())
	changed.emit()
	return true


func get_freshness_grace_seconds() -> float:
	return maxf(0.0, float(profile.get("freshness_grace_seconds", 7200.0)))


func get_freshness_decay_seconds() -> float:
	return maxf(1.0, float(profile.get("freshness_decay_seconds", 10800.0)))


func get_minimum_freshness_factor() -> float:
	return clampf(float(profile.get("minimum_freshness_factor", 0.65)), 0.05, 1.0)


func get_freshness_factor() -> float:
	if tutorial_cycle:
		return 1.0
	var decay_elapsed := maxf(0.0, mature_elapsed_seconds - get_freshness_grace_seconds())
	var decay_progress := clampf(decay_elapsed / get_freshness_decay_seconds(), 0.0, 1.0)
	return lerpf(1.0, get_minimum_freshness_factor(), decay_progress)


func get_harvest_freshness_factor() -> float:
	return get_freshness_factor()


func get_seconds_until_freshness_decay() -> float:
	if stage != Stage.MATURE or tutorial_cycle:
		return -1.0
	return maxf(0.0, get_freshness_grace_seconds() - mature_elapsed_seconds)


func get_estimated_harvest_quality() -> float:
	if stage != Stage.MATURE:
		return 0.0
	var care_quality := clampf((health / 100.0) * 0.72 + condition_score * 0.28, 0.15, 1.0)
	return care_quality * get_freshness_factor()


func get_estimated_fresh_yield_g() -> float:
	if stage != Stage.MATURE:
		return 0.0
	return _calculate_estimated_fresh_yield_g(get_estimated_harvest_quality())


func get_harvest_behavior_yield_multiplier() -> float:
	if stage != Stage.MATURE:
		return 1.0
	return clampf(
		_get_active_effect_multiplier("fresh_yield_multiplier", {"condition_score": condition_score}),
		0.0,
		4.0
	)


## Seed drops are rolled only after a successful sale. The behavior remains
## stateless: the current profile and lifecycle stage derive the chance, while
## GameSession owns the single deterministic roll for each completed sale.
func get_seed_drop_chance(base_chance := 0.58) -> float:
	return clampf(
		base_chance + _get_active_effect_total("seed_drop_chance_bonus"),
		0.0,
		1.0
	)


func get_drying_behavior_time_multiplier(sample_harvest_quality := -1.0) -> float:
	var effective_quality := sample_harvest_quality
	if effective_quality < 0.0:
		effective_quality = get_estimated_harvest_quality() if stage == Stage.MATURE else harvest_quality
	return clampf(
		_get_active_effect_multiplier("drying_time_multiplier", {"harvest_quality": effective_quality}),
		0.25,
		1.0
	)


func _calculate_estimated_fresh_yield_g(quality: float) -> float:
	return snappedf(
		float(profile.get("base_fresh_yield_g", 32.0))
			* quality
			* equipment_harvest_yield_multiplier
			* get_harvest_behavior_yield_multiplier(),
		0.1
	)


func get_estimated_fresh_harvest_g() -> float:
	return get_estimated_fresh_yield_g()


func get_estimated_harvest_yield_g() -> float:
	return get_estimated_fresh_yield_g()


func get_harvest_estimate() -> Dictionary:
	if stage != Stage.MATURE:
		return {"quality": 0.0, "fresh_yield_g": 0.0, "freshness_factor": get_freshness_factor()}
	var quality := get_estimated_harvest_quality()
	return {
		"quality": quality,
		"fresh_yield_g": _calculate_estimated_fresh_yield_g(quality),
		"freshness_factor": get_freshness_factor(),
	}


func harvest() -> bool:
	if stage != Stage.MATURE:
		return false
	var estimate := get_harvest_estimate()
	harvest_quality = float(estimate.get("quality", 0.0))
	fresh_harvest_g = float(estimate.get("fresh_yield_g", 0.0))
	stage = Stage.HARVESTED
	event_created.emit("Sklizeno %.1f g čerstvé bylinky %s. Přesuň ji do sušárny." % [fresh_harvest_g, get_short_name()])
	changed.emit()
	return true


func start_drying() -> bool:
	if stage != Stage.HARVESTED:
		return false
	stage = Stage.DRYING
	drying_progress = 0.0
	event_created.emit("Sušení začalo. Listy potřebují suché a větrané místo.")
	changed.emit()
	return true


func package_harvest() -> bool:
	if stage != Stage.DRY:
		return false
	stage = Stage.PACKAGED
	event_created.emit("Usušená bylinka %s je zabalená a připravená k prodeji." % get_short_name())
	changed.emit()
	return true


func clear_after_sale() -> void:
	reset()
	changed.emit()


func is_growing() -> bool:
	return stage in [Stage.GERMINATING, Stage.SPROUT, Stage.VEGETATIVE, Stage.MATURE]


func get_biological_day() -> float:
	var target_seconds := get_growth_target_seconds()
	return plant_age_seconds / target_seconds * float(profile.get("biological_days_to_harvest", 45.0))


func get_base_growth_seconds() -> float:
	return maxf(1.0, float(profile.get("growth_seconds", 21600.0)))


func get_growth_target_seconds() -> float:
	return growth_target_seconds if growth_target_seconds > 0.0 else get_base_growth_seconds()


func get_drying_target_seconds() -> float:
	var base_seconds := maxf(1.0, float(profile.get("drying_seconds", 7200.0)))
	if tutorial_cycle:
		return maxf(1.0, float(profile.get("tutorial_drying_seconds", base_seconds)))
	return maxf(1.0, base_seconds * get_drying_behavior_time_multiplier(harvest_quality))


func get_estimated_drying_target_seconds() -> float:
	var base_seconds := maxf(1.0, float(profile.get("drying_seconds", 7200.0)))
	if tutorial_cycle:
		return maxf(1.0, float(profile.get("tutorial_drying_seconds", base_seconds)))
	var estimated_quality := get_estimated_harvest_quality() if stage == Stage.MATURE else harvest_quality
	return maxf(1.0, base_seconds * get_drying_behavior_time_multiplier(estimated_quality))


func get_minimum_growth_efficiency() -> float:
	return clampf(float(profile.get("minimum_growth_efficiency", 0.5)), 0.05, 1.0)


func get_growth_efficiency() -> float:
	var health_factor := lerpf(0.35, 1.0, clampf(health / 100.0, 0.0, 1.0))
	return clampf(condition_score * health_factor, get_minimum_growth_efficiency(), 1.0)


func get_growth_behavior_multiplier() -> float:
	if stage not in [Stage.GERMINATING, Stage.SPROUT, Stage.VEGETATIVE]:
		return 1.0
	return clampf(_get_active_effect_multiplier("growth_multiplier"), 0.0, 4.0)


func get_estimated_seconds_to_mature() -> float:
	if stage == Stage.MATURE:
		return 0.0
	if not is_growing():
		return -1.0
	if growth_percent >= 100.0:
		return 0.0
	var remaining_ratio := clampf(1.0 - growth_percent / 100.0, 0.0, 1.0)
	return get_growth_target_seconds() * remaining_ratio / maxf(
		0.01,
		get_growth_efficiency() * get_growth_behavior_multiplier()
	)


func get_biomass_g() -> float:
	if stage == Stage.DEAD:
		return 0.0
	if stage >= Stage.HARVESTED:
		return fresh_harvest_g
	return snappedf(float(profile.get("max_live_biomass_g", 42.0)) * pow(growth_percent / 100.0, 1.35) * (0.65 + health / 100.0 * 0.35), 0.1)


func get_stage_name() -> String:
	match stage:
		Stage.EMPTY: return "Prázdný květináč"
		Stage.GERMINATING: return "Klíčení"
		Stage.SPROUT: return "Sazenice"
		Stage.VEGETATIVE: return "Růst listů"
		Stage.MATURE: return "Připraveno ke sklizni"
		Stage.HARVESTED: return "Čerstvá sklizeň"
		Stage.DRYING: return "Sušení"
		Stage.DRY: return "Usušeno"
		Stage.PACKAGED: return "Zabaleno"
		Stage.DEAD: return "Uhynulá rostlina"
	return "Neznámý stav"


func to_dict() -> Dictionary:
	return {
		"species_id": get_species_id(),
		"stage": int(stage),
		"growth_percent": growth_percent,
		"health": health,
		"moisture": moisture,
		"nutrients": nutrients,
		"ventilation": ventilation,
		"disease_pressure": disease_pressure,
		"disease_level": disease_level,
		"plant_age_seconds": plant_age_seconds,
		"growth_target_seconds": growth_target_seconds,
		"tutorial_cycle": tutorial_cycle,
		"mature_elapsed_seconds": mature_elapsed_seconds,
		"critical_neglect_seconds": critical_neglect_seconds,
		"drying_progress": drying_progress,
		"fresh_harvest_g": fresh_harvest_g,
		"dry_harvest_g": dry_harvest_g,
		"harvest_quality": harvest_quality,
		"lamp_on": lamp_on,
	}


func from_dict(data: Dictionary) -> void:
	stage = clampi(int(data.get("stage", Stage.EMPTY)), int(Stage.EMPTY), int(Stage.DEAD)) as Stage
	growth_percent = clampf(float(data.get("growth_percent", 0.0)), 0.0, 100.0)
	health = clampf(float(data.get("health", 100.0)), 0.0, 100.0)
	moisture = clampf(float(data.get("moisture", profile.get("initial_moisture", 62.0))), 0.0, 100.0)
	nutrients = clampf(float(data.get("nutrients", profile.get("initial_nutrients", 48.0))), 0.0, 100.0)
	ventilation = clampf(float(data.get("ventilation", 58.0)), 0.0, 100.0)
	disease_pressure = clampf(float(data.get("disease_pressure", 0.0)), 0.0, 100.0)
	disease_level = clampi(int(data.get("disease_level", 0)), 0, 1)
	var stored_growth_target := float(data.get("growth_target_seconds", 0.0))
	if stage == Stage.EMPTY:
		growth_target_seconds = 0.0
		tutorial_cycle = false
	else:
		growth_target_seconds = maxf(1.0, stored_growth_target) if stored_growth_target > 0.0 else get_base_growth_seconds()
		tutorial_cycle = bool(data.get("tutorial_cycle", false))
	if data.has("growth_target_seconds"):
		plant_age_seconds = maxf(0.0, float(data.get("plant_age_seconds", 0.0)))
	else:
		# Schema 1–18 used multi-day targets. Preserve authoritative progress and
		# normalize biological age to the new per-cycle real-time target.
		plant_age_seconds = growth_target_seconds * clampf(growth_percent / 100.0, 0.0, 1.0)
	var has_reached_maturity := int(stage) >= int(Stage.MATURE)
	mature_elapsed_seconds = maxf(0.0, float(data.get("mature_elapsed_seconds", 0.0))) if has_reached_maturity else 0.0
	critical_neglect_seconds = clampf(float(data.get("critical_neglect_seconds", 0.0)), 0.0, get_critical_death_seconds()) if has_reached_maturity else 0.0
	if tutorial_cycle:
		mature_elapsed_seconds = 0.0
		critical_neglect_seconds = 0.0
	drying_progress = clampf(float(data.get("drying_progress", 0.0)), 0.0, 100.0)
	fresh_harvest_g = maxf(0.0, float(data.get("fresh_harvest_g", 0.0)))
	dry_harvest_g = maxf(0.0, float(data.get("dry_harvest_g", 0.0)))
	harvest_quality = clampf(float(data.get("harvest_quality", 0.0)), 0.0, 1.0)
	lamp_on = bool(data.get("lamp_on", false))
	if stage == Stage.DEAD:
		health = 0.0
		lamp_on = false
		critical_neglect_seconds = get_critical_death_seconds()
		fresh_harvest_g = 0.0
		dry_harvest_g = 0.0
		harvest_quality = 0.0
	_update_environment()
	_update_condition_score()
	if stage == Stage.DEAD:
		condition_score = 0.0
		current_issue = "Rostlina uhynula"
	changed.emit()
