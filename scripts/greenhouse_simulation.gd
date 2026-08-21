class_name GreenhouseSimulation
extends RefCounted

const BED_COUNT := 4
const CROP_IDS: Array[String] = ["cherry_tomato", "sweet_pepper", "salad_cucumber"]
const CROP_CATALOG := {
	"cherry_tomato": {
		"name": "Cherry rajče",
		"short_name": "RAJČE",
		"unlock_level": 1,
		"seed_price": 10,
		"growth_seconds": 21600.0,
		"reward_coins": 24,
		"reward_xp": 8,
		"accent": "#ef4e45",
		"description": "Sladká červená rajčata z teplého skleníkového záhonu.",
	},
	"sweet_pepper": {
		"name": "Sladká paprika",
		"short_name": "PAPRIKA",
		"unlock_level": 2,
		"seed_price": 14,
		"growth_seconds": 28800.0,
		"reward_coins": 34,
		"reward_xp": 11,
		"accent": "#f4b52c",
		"description": "Pomalejší skleníková plodina s vyšší sklizňovou odměnou.",
	},
	"salad_cucumber": {
		"name": "Salátová okurka",
		"short_name": "OKURKA",
		"unlock_level": 4,
		"seed_price": 18,
		"growth_seconds": 36000.0,
		"reward_coins": 46,
		"reward_xp": 14,
		"accent": "#35b874",
		"description": "Popínavá zelenina pro zkušenější pěstitele s desetihodinovým cyklem.",
	},
}

var beds: Array[Dictionary] = []


func _init() -> void:
	reset()


func reset() -> void:
	beds.clear()
	for _index in range(BED_COUNT):
		beds.append(_empty_bed())


func get_crop_catalog() -> Dictionary:
	return CROP_CATALOG.duplicate(true)


func get_crop(crop_id: String) -> Dictionary:
	var crop = CROP_CATALOG.get(crop_id, {})
	return crop.duplicate(true) if crop is Dictionary else {}


func get_beds() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for bed in beds:
		result.append((bed as Dictionary).duplicate(true))
	return result


func get_bed(index: int) -> Dictionary:
	if index < 0 or index >= beds.size():
		return {}
	return beds[index].duplicate(true)


func get_bed_state(index: int, available_coins: int) -> Dictionary:
	if index < 0 or index >= beds.size():
		return {
			"valid": false,
			"stage": "invalid",
			"action": "none",
			"can_action": false,
			"action_label": "NEPLATNÝ ZÁHON",
		}
	var bed := beds[index]
	var crop_id := str(bed.get("crop_id", ""))
	if crop_id.is_empty():
		var crop := get_crop(CROP_IDS[0])
		var price := int(crop.get("seed_price", 0))
		return {
			"valid": true,
			"bed_index": index,
			"crop_id": "",
			"crop": crop,
			"stage": "empty",
			"stage_name": "VOLNÝ ZÁHON",
			"progress": 0.0,
			"remaining_seconds": 0.0,
			"action": "plant",
			"can_action": available_coins >= price,
			"action_label": "ZASADIT RAJČE · %d MINCÍ" % price if available_coins >= price else "CHYBÍ MINCE · POTŘEBA %d" % price,
			"price": price,
		}
	var crop := get_crop(crop_id)
	if crop.is_empty():
		return {
			"valid": false,
			"bed_index": index,
			"stage": "invalid",
			"action": "none",
			"can_action": false,
			"action_label": "NEZNÁMÁ ZELENINA",
		}
	var growth_target := maxf(1.0, float(crop.get("growth_seconds", 1.0)))
	var growth_seconds := clampf(float(bed.get("growth_seconds", 0.0)), 0.0, growth_target)
	var progress := clampf(growth_seconds / growth_target, 0.0, 1.0)
	if not bool(bed.get("watered", false)):
		return {
			"valid": true,
			"bed_index": index,
			"crop_id": crop_id,
			"crop": crop,
			"stage": "needs_water",
			"stage_name": "ČEKÁ NA ZÁLIVKU",
			"progress": progress,
			"remaining_seconds": growth_target - growth_seconds,
			"action": "water",
			"can_action": true,
			"action_label": "ZALÍT ZÁHON",
			"price": 0,
		}
	if progress >= 1.0:
		return {
			"valid": true,
			"bed_index": index,
			"crop_id": crop_id,
			"crop": crop,
			"stage": "ready",
			"stage_name": "PŘIPRAVENO KE SKLIZNI",
			"progress": 1.0,
			"remaining_seconds": 0.0,
			"action": "harvest",
			"can_action": true,
			"action_label": "SKLIDIT · +%d MINCÍ" % int(crop.get("reward_coins", 0)),
			"price": 0,
		}
	return {
		"valid": true,
		"bed_index": index,
		"crop_id": crop_id,
		"crop": crop,
		"stage": "growing",
		"stage_name": "ROSTE",
		"progress": progress,
		"remaining_seconds": growth_target - growth_seconds,
		"action": "none",
		"can_action": false,
		"action_label": "ROSTE · %s" % _format_duration(growth_target - growth_seconds),
		"price": 0,
	}


func plant(index: int, crop_id: String) -> bool:
	if index < 0 or index >= beds.size() or not CROP_CATALOG.has(crop_id):
		return false
	if not str(beds[index].get("crop_id", "")).is_empty():
		return false
	beds[index] = {
		"crop_id": crop_id,
		"watered": false,
		"growth_seconds": 0.0,
	}
	return true


func water(index: int) -> bool:
	if index < 0 or index >= beds.size():
		return false
	var bed := beds[index]
	if str(bed.get("crop_id", "")).is_empty() or bool(bed.get("watered", false)):
		return false
	bed["watered"] = true
	beds[index] = bed
	return true


func harvest(index: int) -> Dictionary:
	if index < 0 or index >= beds.size():
		return {}
	var state := get_bed_state(index, 0)
	if str(state.get("stage", "")) != "ready":
		return {}
	var crop := (state.get("crop", {}) as Dictionary).duplicate(true)
	crop["crop_id"] = str(state.get("crop_id", ""))
	beds[index] = _empty_bed()
	return crop


func advance(real_seconds: float) -> Array[Dictionary]:
	var ready_events: Array[Dictionary] = []
	if real_seconds <= 0.0 or not is_finite(real_seconds):
		return ready_events
	for index in range(beds.size()):
		var bed := beds[index]
		var crop_id := str(bed.get("crop_id", ""))
		if crop_id.is_empty() or not bool(bed.get("watered", false)):
			continue
		var crop := get_crop(crop_id)
		if crop.is_empty():
			continue
		var target := maxf(1.0, float(crop.get("growth_seconds", 1.0)))
		var previous_growth := maxf(0.0, float(bed.get("growth_seconds", 0.0)))
		var current_growth := minf(target, previous_growth + real_seconds)
		bed["growth_seconds"] = current_growth
		beds[index] = bed
		if previous_growth < target and current_growth >= target:
			ready_events.append({
				"kind": "greenhouse_ready",
				"source": "greenhouse",
				"bed_index": index,
				"bed_number": index + 1,
				"crop_id": crop_id,
				"crop_name": str(crop.get("name", crop_id)),
			})
	return ready_events


func to_dict() -> Array[Dictionary]:
	return get_beds()


func load_state(raw_beds: Variant, authorized_crop_ids: Array[String]) -> void:
	reset()
	if authorized_crop_ids.is_empty() or not raw_beds is Array:
		return
	for index in range(mini(BED_COUNT, raw_beds.size())):
		var raw_bed = raw_beds[index]
		if not raw_bed is Dictionary:
			continue
		var raw_crop_id = raw_bed.get("crop_id", "")
		if not (raw_crop_id is String or raw_crop_id is StringName):
			continue
		var crop_id := str(raw_crop_id)
		if crop_id.is_empty():
			continue
		if not CROP_CATALOG.has(crop_id) or crop_id not in authorized_crop_ids:
			continue
		var raw_watered = raw_bed.get("watered", false)
		var watered: bool = bool(raw_watered) if raw_watered is bool else false
		var crop := get_crop(crop_id)
		var target := maxf(1.0, float(crop.get("growth_seconds", 1.0)))
		var growth_seconds := _sanitize_growth(raw_bed.get("growth_seconds", 0.0), target)
		if not watered:
			growth_seconds = 0.0
		beds[index] = {
			"crop_id": crop_id,
			"watered": watered,
			"growth_seconds": growth_seconds,
		}


func _empty_bed() -> Dictionary:
	return {
		"crop_id": "",
		"watered": false,
		"growth_seconds": 0.0,
	}


func _sanitize_growth(raw_value: Variant, target: float) -> float:
	if raw_value is bool or not (raw_value is int or raw_value is float):
		return 0.0
	var numeric := float(raw_value)
	if not is_finite(numeric):
		return 0.0
	return clampf(numeric, 0.0, target)


func _format_duration(seconds: float) -> String:
	var minutes := maxi(1, ceili(maxf(0.0, seconds) / 60.0))
	if minutes < 60:
		return "%d MIN" % minutes
	var hours := int(minutes / 60)
	var remainder := minutes % 60
	return "%d H %02d MIN" % [hours, remainder] if remainder > 0 else "%d H" % hours
