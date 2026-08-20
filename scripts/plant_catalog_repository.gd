extends RefCounted

const PlantRarityCatalogScene := preload("res://scripts/plant_rarity_catalog.gd")
const PlantBehaviorCatalogScene := preload("res://scripts/plant_behavior_catalog.gd")
const CATALOG_MANIFEST_PATH := "res://data/plants/catalog.json"
const CATALOG_MANIFEST_VERSION := 1
const DEFAULT_PROFILE_PATH := "res://data/plants/basil.json"
const MAX_PROFILE_COUNT := 64
const MAX_PROFILE_ID_LENGTH := 64
const MAX_CATALOG_ORDER := 1000000
const MAX_STARTER_SEED_COUNT := 9999
const MAX_ACQUISITION_SOURCE_ID_LENGTH := 64
const MAX_SHOP_UNLOCK_LEVEL := 10000
const MAX_DAILY_SHOP_STOCK := 99
const MAX_SHOP_STOCK_CYCLE_DAYS := 31
const MAX_SEED_PRICE := 9999
const MAX_XP_REWARD := 9999
const MAX_DRY_MATTER_RATIO := 1.0
const MIN_DRY_MATTER_RATIO := 0.0
const MAX_YIELD_G := 9999.0
const MAX_DRY_HARVEST_G := 9999.0
const MAX_BIOMASS_G := 9999.0
const MAX_BIO_DAYS := 3650.0
const MIN_PERCENT := 0.0
const MAX_PERCENT := 100.0
const MAX_TEMPERATURE_C := 120.0
const MIN_TEMPERATURE_C := -80.0
const MAX_PH := 14.0
const MIN_PH := 0.0
const REQUIRED_STAGE_TEXTURE_IDS: Array[String] = [
	"seed",
	"sprout",
	"young",
	"mature",
	"sick",
	"harvest_ready",
]
const REQUIRED_ECONOMIC_FIELDS: Array[String] = [
	"base_fresh_yield_g",
	"dry_matter_ratio",
	"dried_price_per_g",
	"max_live_biomass_g",
	"biological_days_to_harvest",
	"minimum_growth_efficiency",
]
const REQUIRED_ECONOMIC_INT_FIELDS: Array[String] = [
	"seed_price",
	"xp_harvest",
	"xp_sale",
]
const REQUIRED_CARE_FIELDS: Array[String] = [
	"initial_moisture",
	"initial_nutrients",
	"water_loss_per_hour",
	"nutrient_loss_per_hour",
	"ideal_moisture_min",
	"ideal_moisture_max",
	"ideal_nutrients_min",
	"ideal_nutrients_max",
	"ideal_temperature_min",
	"ideal_temperature_max",
	"ideal_humidity_min",
	"ideal_humidity_max",
	"ideal_ph_min",
	"ideal_ph_max",
]
const REQUIRED_LIFECYCLE_FIELDS: Array[String] = [
	"growth_seconds",
	"drying_seconds",
	"care_issue_limit",
	"freshness_grace_seconds",
	"freshness_decay_seconds",
	"minimum_freshness_factor",
	"critical_wilt_seconds",
	"critical_death_seconds",
]

var _rarities := PlantRarityCatalogScene.new()
var _behaviors := PlantBehaviorCatalogScene.new()


func load_profile(path: String) -> Dictionary:
	var text := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)
	if not parsed is Dictionary:
		push_error("Plant profile could not be loaded: %s" % path)
		return {}
	var profile: Dictionary = parsed.duplicate(true)
	profile["rarity"] = _rarities.normalize_rarity_id(
		profile.get("rarity", ""),
		"plant profile %s" % path
	)
	if not _validate_profile(profile, path):
		return {}
	return profile.duplicate(true)


func load_manifest(path := CATALOG_MANIFEST_PATH) -> Dictionary:
	var manifest_path := str(path)
	var text := FileAccess.get_file_as_string(manifest_path)
	var parsed = JSON.parse_string(text)
	if not parsed is Dictionary:
		push_error("Plant catalog manifest could not be loaded: %s" % manifest_path)
		return {}
	var manifest: Dictionary = parsed.duplicate(true)
	if not _validate_manifest(manifest, manifest_path):
		return {}
	return manifest.duplicate(true)


func load_catalog() -> Dictionary:
	var manifest := load_manifest(CATALOG_MANIFEST_PATH)
	if manifest.is_empty():
		return {}
	return load_catalog_from_manifest(manifest, CATALOG_MANIFEST_PATH)


func load_catalog_from_manifest(manifest: Dictionary, manifest_path := CATALOG_MANIFEST_PATH) -> Dictionary:
	var diagnostic_path := str(manifest_path)
	var normalized_manifest := manifest.duplicate(true)
	if not _validate_manifest(normalized_manifest, diagnostic_path):
		return {}
	var catalog: Dictionary = {}
	var botanist_orders: Dictionary = {}
	for raw_entry in normalized_manifest.get("profiles", []):
		var entry: Dictionary = raw_entry
		var expected_id := str(entry.get("id", ""))
		var expected_order := int(entry.get("catalog_order", -1))
		var profile_path := str(entry.get("path", ""))
		var loaded := load_profile(profile_path)
		if loaded.is_empty():
			push_error("Plant catalog entry could not load its profile '%s': %s" % [expected_id, diagnostic_path])
			return {}
		if str(loaded.get("id", "")) != expected_id:
			push_error("Plant catalog id/profile mismatch for '%s': %s" % [expected_id, diagnostic_path])
			return {}
		if int(loaded.get("catalog_order", -1)) != expected_order:
			push_error("Plant catalog order/profile mismatch for '%s': %s" % [expected_id, diagnostic_path])
			return {}
		if catalog.has(expected_id):
			push_error("Duplicate plant profile id '%s' was rejected: %s" % [expected_id, diagnostic_path])
			return {}
		if "botanist" in (loaded.get("acquisition_sources", []) as Array):
			var shop_order := int(loaded.get("botanist_shop_order", -1))
			if botanist_orders.has(shop_order):
				push_error("Duplicate botanist_shop_order %d was rejected: %s" % [shop_order, diagnostic_path])
				return {}
			botanist_orders[shop_order] = expected_id
		catalog[expected_id] = loaded.duplicate(true)
	return catalog


func load_default_profile() -> Dictionary:
	var manifest := load_manifest(CATALOG_MANIFEST_PATH)
	if manifest.is_empty():
		return {}
	var default_profile_id := str(manifest.get("default_profile_id", ""))
	for raw_entry in manifest.get("profiles", []):
		var entry: Dictionary = raw_entry
		if str(entry.get("id", "")) == default_profile_id:
			return load_profile(str(entry.get("path", ""))).duplicate(true)
	push_error("Plant catalog default profile is unavailable: %s" % CATALOG_MANIFEST_PATH)
	return {}


func _validate_manifest(manifest: Dictionary, path: String) -> bool:
	var raw_version: Variant = manifest.get("version")
	if not _is_whole_number(raw_version) or int(raw_version) != CATALOG_MANIFEST_VERSION:
		push_error("Plant catalog manifest has an unsupported version: %s" % path)
		return false
	var default_profile_id := str(manifest.get("default_profile_id", ""))
	if not _is_canonical_identifier(default_profile_id, MAX_PROFILE_ID_LENGTH):
		push_error("Plant catalog manifest has an invalid default_profile_id: %s" % path)
		return false
	var raw_profiles: Variant = manifest.get("profiles")
	if not raw_profiles is Array or raw_profiles.is_empty() or raw_profiles.size() > MAX_PROFILE_COUNT:
		push_error("Plant catalog manifest has an invalid profiles list: %s" % path)
		return false
	var ids: Array[String] = []
	var profile_paths: Array[String] = []
	var orders: Array[int] = []
	var previous_order := -1
	for raw_entry in raw_profiles:
		if not raw_entry is Dictionary:
			push_error("Plant catalog manifest contains a non-dictionary entry: %s" % path)
			return false
		var entry: Dictionary = raw_entry
		var species_id := str(entry.get("id", ""))
		var profile_path := str(entry.get("path", ""))
		var raw_order: Variant = entry.get("catalog_order")
		if not _is_canonical_identifier(species_id, MAX_PROFILE_ID_LENGTH):
			push_error("Plant catalog manifest contains an invalid id '%s': %s" % [species_id, path])
			return false
		if species_id in ids:
			push_error("Plant catalog manifest contains duplicate id '%s': %s" % [species_id, path])
			return false
		if not _is_canonical_profile_path(profile_path) or profile_path in profile_paths:
			push_error("Plant catalog manifest contains an invalid or duplicate path '%s': %s" % [profile_path, path])
			return false
		if not FileAccess.file_exists(profile_path):
			push_error("Plant catalog manifest references a missing profile '%s': %s" % [profile_path, path])
			return false
		if not _is_whole_number(raw_order):
			push_error("Plant catalog manifest contains a non-whole order for '%s': %s" % [species_id, path])
			return false
		var catalog_order := int(raw_order)
		if catalog_order <= 0 or catalog_order > MAX_CATALOG_ORDER or catalog_order in orders or catalog_order <= previous_order:
			push_error("Plant catalog manifest contains an invalid, duplicate, or unsorted order for '%s': %s" % [species_id, path])
			return false
		ids.append(species_id)
		profile_paths.append(profile_path)
		orders.append(catalog_order)
		previous_order = catalog_order
	if default_profile_id not in ids:
		push_error("Plant catalog manifest default_profile_id is not listed: %s" % path)
		return false
	return true


func _validate_profile(profile: Dictionary, path: String) -> bool:
	var species_id := str(profile.get("id", ""))
	if not _is_canonical_identifier(species_id, MAX_PROFILE_ID_LENGTH):
		push_error("Plant profile has an invalid id and was rejected: %s" % path)
		return false
	var raw_catalog_order: Variant = profile.get("catalog_order")
	if not _is_whole_number(raw_catalog_order) or int(raw_catalog_order) <= 0 or int(raw_catalog_order) > MAX_CATALOG_ORDER:
		push_error("Plant profile '%s' has an invalid catalog_order: %s" % [species_id, path])
		return false
	profile["catalog_order"] = int(raw_catalog_order)
	var raw_acquisition_sources: Variant = profile.get("acquisition_sources")
	if not raw_acquisition_sources is Array:
		push_error("Plant profile '%s' has invalid acquisition_sources: %s" % [species_id, path])
		return false
	var acquisition_sources: Array[String] = []
	for raw_source_id in raw_acquisition_sources:
		if not (raw_source_id is String or raw_source_id is StringName):
			push_error("Plant profile '%s' has a non-string acquisition source: %s" % [species_id, path])
			return false
		var source_id := str(raw_source_id).strip_edges()
		if not _is_canonical_acquisition_source_id(source_id):
			push_error("Plant profile '%s' has an invalid acquisition source '%s': %s" % [species_id, source_id, path])
			return false
		if source_id in acquisition_sources:
			push_error("Plant profile '%s' has duplicate acquisition source '%s': %s" % [species_id, source_id, path])
			return false
		acquisition_sources.append(source_id)
	profile["acquisition_sources"] = acquisition_sources
	var raw_behavior_ids: Variant = profile.get("behavior_ids")
	if not raw_behavior_ids is Array:
		push_error("Plant profile '%s' has invalid behavior_ids: %s" % [species_id, path])
		return false
	if raw_behavior_ids.size() > _behaviors.MAX_BEHAVIOR_IDS:
		push_error("Plant profile '%s' has too many behavior_ids: %s" % [species_id, path])
		return false
	var behavior_ids: Array[String] = []
	for raw_behavior_id in raw_behavior_ids:
		if not (raw_behavior_id is String or raw_behavior_id is StringName):
			push_error("Plant profile '%s' has a non-string behavior id: %s" % [species_id, path])
			return false
		var behavior_id := str(raw_behavior_id).strip_edges()
		if str(raw_behavior_id) != behavior_id:
			push_error("Plant profile '%s' has a non-canonical behavior id '%s': %s" % [species_id, str(raw_behavior_id), path])
			return false
		if not _behaviors.is_canonical_behavior_id(behavior_id):
			push_error("Plant profile '%s' has an invalid behavior id '%s': %s" % [species_id, behavior_id, path])
			return false
		if not _behaviors.has_definition(behavior_id):
			push_error("Plant profile '%s' has an unknown behavior id '%s': %s" % [species_id, behavior_id, path])
			return false
		if behavior_id in behavior_ids:
			push_error("Plant profile '%s' has duplicate behavior id '%s': %s" % [species_id, behavior_id, path])
			return false
		behavior_ids.append(behavior_id)
	profile["behavior_ids"] = behavior_ids
	if not _validate_behavior_profile_bands(profile, species_id, path, behavior_ids):
		return false
	if not _validate_presentation(profile, species_id, path):
		return false
	if not _validate_shop_policy(profile, species_id, path):
		return false
	if not _validate_economy_fields(profile, species_id, path):
		return false
	if not _validate_care_fields(profile, species_id, path):
		return false
	var raw_starter_seed_count: Variant = profile.get("starter_seed_count")
	if not _is_whole_number(raw_starter_seed_count):
		push_error("Plant profile '%s' has an invalid starter_seed_count: %s" % [species_id, path])
		return false
	var numeric_starter_seed_count := int(raw_starter_seed_count)
	if numeric_starter_seed_count < 0 or numeric_starter_seed_count > MAX_STARTER_SEED_COUNT:
		push_error("Plant profile '%s' has an out-of-range starter_seed_count: %s" % [species_id, path])
		return false
	profile["starter_seed_count"] = numeric_starter_seed_count
	for field_name in REQUIRED_LIFECYCLE_FIELDS:
		if not profile.has(field_name):
			push_error("Plant profile '%s' is missing lifecycle field '%s': %s" % [species_id, field_name, path])
			return false
		var field_value: Variant = profile[field_name]
		if field_value is bool or not (field_value is int or field_value is float) or not is_finite(float(field_value)):
			push_error("Plant profile '%s' has a non-numeric lifecycle field '%s': %s" % [species_id, field_name, path])
			return false
	if float(profile["growth_seconds"]) <= 0.0:
		return _reject_lifecycle_value(species_id, "growth_seconds", path)
	if float(profile["drying_seconds"]) <= 0.0:
		return _reject_lifecycle_value(species_id, "drying_seconds", path)
	if not _is_whole_number(profile["care_issue_limit"]):
		return _reject_lifecycle_value(species_id, "care_issue_limit", path)
	if int(profile["care_issue_limit"]) < 1:
		return _reject_lifecycle_value(species_id, "care_issue_limit", path)
	if float(profile["freshness_grace_seconds"]) < 0.0:
		return _reject_lifecycle_value(species_id, "freshness_grace_seconds", path)
	if float(profile["freshness_decay_seconds"]) <= 0.0:
		return _reject_lifecycle_value(species_id, "freshness_decay_seconds", path)
	var minimum_freshness := float(profile["minimum_freshness_factor"])
	if minimum_freshness <= 0.0 or minimum_freshness > 1.0:
		return _reject_lifecycle_value(species_id, "minimum_freshness_factor", path)
	var wilt_seconds := float(profile["critical_wilt_seconds"])
	var death_seconds := float(profile["critical_death_seconds"])
	if wilt_seconds <= 0.0:
		return _reject_lifecycle_value(species_id, "critical_wilt_seconds", path)
	if death_seconds < wilt_seconds:
		return _reject_lifecycle_value(species_id, "critical_death_seconds", path)
	return true


func _validate_behavior_profile_bands(profile: Dictionary, species_id: String, path: String, behavior_ids: Array[String]) -> bool:
	for behavior_id in behavior_ids:
		var definition := _behaviors.get_definition(behavior_id)
		var raw_activation: Variant = definition.get("activation", {})
		if not raw_activation is Dictionary:
			continue
		var activation: Dictionary = raw_activation
		if str(activation.get("type", "")) != "growth_value_in_profile_band":
			continue
		var minimum_field := str(activation.get("minimum_field", ""))
		var maximum_field := str(activation.get("maximum_field", ""))
		if minimum_field.is_empty() or maximum_field.is_empty():
			push_error("Plant behavior '%s' has an invalid profile band contract: %s" % [behavior_id, path])
			return false
		if not _has_required_numeric(profile, species_id, path, minimum_field, false) \
			or not _has_required_numeric(profile, species_id, path, maximum_field, false):
			return false
		var minimum := float(profile.get(minimum_field, 0.0))
		var maximum := float(profile.get(maximum_field, 0.0))
		if minimum < MIN_PERCENT or maximum > MAX_PERCENT or minimum > maximum:
			push_error("Plant profile '%s' has an out-of-range or inverted behavior band for '%s': %s" % [species_id, behavior_id, path])
			return false
	return true


func _validate_economy_fields(profile: Dictionary, species_id: String, path: String) -> bool:
	for field_name in REQUIRED_ECONOMIC_FIELDS:
		if not _has_required_numeric(profile, species_id, path, field_name, false):
			return false
	for field_name in REQUIRED_ECONOMIC_INT_FIELDS:
		if not _has_required_numeric(profile, species_id, path, field_name, true):
			return false
	var seed_price := int(profile.get("seed_price", 0))
	if seed_price < 0 or seed_price > MAX_SEED_PRICE:
		push_error("Plant profile '%s' has an out-of-range seed_price: %s" % [species_id, path])
		return false
	profile["seed_price"] = seed_price
	var xp_harvest := int(profile.get("xp_harvest", 0))
	if xp_harvest < 0 or xp_harvest > MAX_XP_REWARD:
		push_error("Plant profile '%s' has an out-of-range xp_harvest: %s" % [species_id, path])
		return false
	profile["xp_harvest"] = xp_harvest
	var xp_sale := int(profile.get("xp_sale", 0))
	if xp_sale < 0 or xp_sale > MAX_XP_REWARD:
		push_error("Plant profile '%s' has an out-of-range xp_sale: %s" % [species_id, path])
		return false
	profile["xp_sale"] = xp_sale
	var base_fresh_yield_g := float(profile.get("base_fresh_yield_g", 0.0))
	if base_fresh_yield_g <= 0.0 or base_fresh_yield_g > MAX_YIELD_G:
		push_error("Plant profile '%s' has an out-of-range base_fresh_yield_g: %s" % [species_id, path])
		return false
	var dry_matter_ratio := float(profile.get("dry_matter_ratio", 0.0))
	if dry_matter_ratio <= MIN_DRY_MATTER_RATIO or dry_matter_ratio > MAX_DRY_MATTER_RATIO:
		push_error("Plant profile '%s' has an out-of-range dry_matter_ratio: %s" % [species_id, path])
		return false
	var dried_price_per_g := float(profile.get("dried_price_per_g", 0.0))
	if dried_price_per_g <= 0.0:
		push_error("Plant profile '%s' has an out-of-range dried_price_per_g: %s" % [species_id, path])
		return false
	var max_live_biomass_g := float(profile.get("max_live_biomass_g", 0.0))
	if max_live_biomass_g <= 0.0 or max_live_biomass_g > MAX_BIOMASS_G:
		push_error("Plant profile '%s' has an out-of-range max_live_biomass_g: %s" % [species_id, path])
		return false
	var biological_days_to_harvest := float(profile.get("biological_days_to_harvest", 0.0))
	if biological_days_to_harvest <= 0.0 or biological_days_to_harvest > MAX_BIO_DAYS:
		push_error("Plant profile '%s' has an out-of-range biological_days_to_harvest: %s" % [species_id, path])
		return false
	var minimum_growth_efficiency := float(profile.get("minimum_growth_efficiency", 0.0))
	if minimum_growth_efficiency <= 0.0 or minimum_growth_efficiency > 1.0:
		push_error("Plant profile '%s' has an out-of-range minimum_growth_efficiency: %s" % [species_id, path])
		return false
	if base_fresh_yield_g > max_live_biomass_g:
		push_error("Plant profile '%s' has inconsistent biomass constraints: base_fresh_yield_g exceeds max_live_biomass_g: %s" % [species_id, path])
		return false
	var dry_harvest_g := base_fresh_yield_g * dry_matter_ratio
	if dry_harvest_g > MAX_DRY_HARVEST_G:
		push_error("Plant profile '%s' has an out-of-range dry yield potential: %s" % [species_id, path])
		return false
	return true


func _validate_care_fields(profile: Dictionary, species_id: String, path: String) -> bool:
	for field_name in REQUIRED_CARE_FIELDS:
		if not _has_required_numeric(profile, species_id, path, field_name, false):
			return false
	var initial_moisture := float(profile.get("initial_moisture", 0.0))
	var initial_nutrients := float(profile.get("initial_nutrients", 0.0))
	if initial_moisture < MIN_PERCENT or initial_moisture > MAX_PERCENT or initial_nutrients < MIN_PERCENT or initial_nutrients > MAX_PERCENT:
		push_error("Plant profile '%s' has an out-of-range initial care value: %s" % [species_id, path])
		return false
	var water_loss_per_hour := float(profile.get("water_loss_per_hour", 0.0))
	var nutrient_loss_per_hour := float(profile.get("nutrient_loss_per_hour", 0.0))
	if water_loss_per_hour < 0.0 or water_loss_per_hour > MAX_PERCENT:
		push_error("Plant profile '%s' has an out-of-range water_loss_per_hour: %s" % [species_id, path])
		return false
	if nutrient_loss_per_hour < 0.0 or nutrient_loss_per_hour > MAX_PERCENT:
		push_error("Plant profile '%s' has an out-of-range nutrient_loss_per_hour: %s" % [species_id, path])
		return false
	var ideal_moisture_min := float(profile.get("ideal_moisture_min", 0.0))
	var ideal_moisture_max := float(profile.get("ideal_moisture_max", 0.0))
	var ideal_nutrients_min := float(profile.get("ideal_nutrients_min", 0.0))
	var ideal_nutrients_max := float(profile.get("ideal_nutrients_max", 0.0))
	var ideal_temperature_min := float(profile.get("ideal_temperature_min", 0.0))
	var ideal_temperature_max := float(profile.get("ideal_temperature_max", 0.0))
	var ideal_humidity_min := float(profile.get("ideal_humidity_min", 0.0))
	var ideal_humidity_max := float(profile.get("ideal_humidity_max", 0.0))
	var ideal_ph_min := float(profile.get("ideal_ph_min", 0.0))
	var ideal_ph_max := float(profile.get("ideal_ph_max", 0.0))
	if ideal_moisture_min < MIN_PERCENT or ideal_moisture_max < MIN_PERCENT or ideal_nutrients_min < MIN_PERCENT or ideal_nutrients_max < MIN_PERCENT or ideal_humidity_min < MIN_PERCENT or ideal_humidity_max < MIN_PERCENT:
		push_error("Plant profile '%s' has an out-of-range ideal percentage: %s" % [species_id, path])
		return false
	if ideal_moisture_max > MAX_PERCENT or ideal_nutrients_max > MAX_PERCENT or ideal_humidity_max > MAX_PERCENT:
		push_error("Plant profile '%s' has an out-of-range ideal percentage: %s" % [species_id, path])
		return false
	if ideal_moisture_min > ideal_moisture_max or ideal_nutrients_min > ideal_nutrients_max or ideal_humidity_min > ideal_humidity_max:
		push_error("Plant profile '%s' has inverted ideal care intervals: %s" % [species_id, path])
		return false
	if ideal_temperature_min < MIN_TEMPERATURE_C or ideal_temperature_max > MAX_TEMPERATURE_C or ideal_temperature_min > ideal_temperature_max:
		push_error("Plant profile '%s' has out-of-range or inverted ideal temperature interval: %s" % [species_id, path])
		return false
	if ideal_ph_min < MIN_PH or ideal_ph_max > MAX_PH or ideal_ph_min > ideal_ph_max:
		push_error("Plant profile '%s' has out-of-range or inverted ideal pH interval: %s" % [species_id, path])
		return false
	return true


func _has_required_numeric(profile: Dictionary, species_id: String, path: String, field_name: String, require_int: bool) -> bool:
	if not profile.has(field_name):
		push_error("Plant profile '%s' is missing field '%s': %s" % [species_id, field_name, path])
		return false
	var field_value: Variant = profile.get(field_name)
	if not (field_value is int or field_value is float) or field_value is bool or not is_finite(float(field_value)):
		push_error("Plant profile '%s' has a non-numeric field '%s': %s" % [species_id, field_name, path])
		return false
	if require_int and not _is_whole_number(field_value):
		push_error("Plant profile '%s' has a non-integer field '%s': %s" % [species_id, field_name, path])
		return false
	return true


func _validate_presentation(profile: Dictionary, species_id: String, path: String) -> bool:
	if not _is_hex_color(str(profile.get("accent_hex", ""))):
		push_error("Plant profile '%s' has an invalid accent_hex: %s" % [species_id, path])
		return false
	for texture_field in ["seed_preview_texture", "herbarium_texture"]:
		if not _is_canonical_texture_path(str(profile.get(texture_field, ""))):
			push_error("Plant profile '%s' has an invalid %s: %s" % [species_id, texture_field, path])
			return false
	var raw_stage_textures: Variant = profile.get("stage_textures")
	if not raw_stage_textures is Dictionary:
		push_error("Plant profile '%s' has invalid stage_textures: %s" % [species_id, path])
		return false
	var stage_textures: Dictionary = raw_stage_textures
	for state_id in REQUIRED_STAGE_TEXTURE_IDS:
		if not _is_canonical_texture_path(str(stage_textures.get(state_id, ""))):
			push_error("Plant profile '%s' has an invalid '%s' stage texture: %s" % [species_id, state_id, path])
			return false
	for text_field in ["seed_care_description", "shop_description", "shop_badge"]:
		if str(profile.get(text_field, "")).strip_edges().is_empty():
			push_error("Plant profile '%s' has an empty %s: %s" % [species_id, text_field, path])
			return false
	return true


func _validate_shop_policy(profile: Dictionary, species_id: String, path: String) -> bool:
	for integer_field in ["shop_unlock_level", "botanist_shop_order", "shop_stock_base"]:
		if not _is_whole_number(profile.get(integer_field)):
			push_error("Plant profile '%s' has an invalid %s: %s" % [species_id, integer_field, path])
			return false
	var unlock_level := int(profile.get("shop_unlock_level", 0))
	var shop_order := int(profile.get("botanist_shop_order", 0))
	var stock_base := int(profile.get("shop_stock_base", -1))
	if unlock_level < 1 or unlock_level > MAX_SHOP_UNLOCK_LEVEL or shop_order <= 0 or shop_order > MAX_CATALOG_ORDER or stock_base < 0 or stock_base > MAX_DAILY_SHOP_STOCK:
		push_error("Plant profile '%s' has an out-of-range shop policy: %s" % [species_id, path])
		return false
	var raw_cycle: Variant = profile.get("shop_stock_cycle")
	if not raw_cycle is Array or raw_cycle.is_empty() or raw_cycle.size() > MAX_SHOP_STOCK_CYCLE_DAYS:
		push_error("Plant profile '%s' has an invalid shop_stock_cycle: %s" % [species_id, path])
		return false
	var normalized_cycle: Array[int] = []
	for raw_stock_delta in raw_cycle:
		if not _is_whole_number(raw_stock_delta):
			push_error("Plant profile '%s' has a non-whole shop stock delta: %s" % [species_id, path])
			return false
		var stock_delta := int(raw_stock_delta)
		if stock_delta < 0 or stock_base + stock_delta > MAX_DAILY_SHOP_STOCK:
			push_error("Plant profile '%s' has an out-of-range shop stock delta: %s" % [species_id, path])
			return false
		normalized_cycle.append(stock_delta)
	profile["shop_unlock_level"] = unlock_level
	profile["botanist_shop_order"] = shop_order
	profile["shop_stock_base"] = stock_base
	profile["shop_stock_cycle"] = normalized_cycle
	return true


func _reject_lifecycle_value(species_id: String, field_name: String, path: String) -> bool:
	push_error("Plant profile '%s' has an invalid lifecycle field '%s': %s" % [species_id, field_name, path])
	return false


func _is_whole_number(value: Variant) -> bool:
	if value is bool or not (value is int or value is float):
		return false
	var numeric_value := float(value)
	return is_finite(numeric_value) and numeric_value == floor(numeric_value)


func _is_canonical_identifier(value: String, maximum_length: int) -> bool:
	if value.is_empty() or value.length() > maximum_length or value != value.strip_edges():
		return false
	for index in range(value.length()):
		var code := value.unicode_at(index)
		if not ((code >= 97 and code <= 122) or (code >= 48 and code <= 57) or code == 95):
			return false
	return true


func _is_canonical_profile_path(path: String) -> bool:
	return path.begins_with("res://data/plants/") \
		and path.ends_with(".json") \
		and path != CATALOG_MANIFEST_PATH \
		and "\\" not in path \
		and ".." not in path \
		and "//" not in path.trim_prefix("res://")


func _is_canonical_texture_path(path: String) -> bool:
	return path.begins_with("res://assets/plants/comic/") \
		and path.ends_with(".png") \
		and "\\" not in path \
		and ".." not in path \
		and "//" not in path.trim_prefix("res://")


func _is_hex_color(value: String) -> bool:
	if value.length() != 7 or not value.begins_with("#"):
		return false
	for index in range(1, value.length()):
		var code := value.unicode_at(index)
		var is_digit := code >= 48 and code <= 57
		var is_lower_hex := code >= 97 and code <= 102
		var is_upper_hex := code >= 65 and code <= 70
		if not (is_digit or is_lower_hex or is_upper_hex):
			return false
	return true


func _is_canonical_acquisition_source_id(source_id: String) -> bool:
	return _is_canonical_identifier(source_id, MAX_ACQUISITION_SOURCE_ID_LENGTH)
