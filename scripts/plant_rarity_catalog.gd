class_name PlantRarityCatalog
extends RefCounted

const DEFAULT_RARITY_ID := "common"
const INK_HEX := "#17212B"
const ORDERED_IDS: Array[String] = [
	"common",
	"rare",
	"epic",
	"legendary",
	"special",
]
const DEFINITIONS := {
	"common": {
		"id": "common",
		"order": 10,
		"catalog_order": 10,
		"stars": 1,
		"label": "BĚŽNÁ",
		"color_hex": "#76D91D",
		"ink_hex": INK_HEX,
	},
	"rare": {
		"id": "rare",
		"order": 20,
		"catalog_order": 20,
		"stars": 2,
		"label": "VZÁCNÁ",
		"color_hex": "#39D8EE",
		"ink_hex": INK_HEX,
	},
	"epic": {
		"id": "epic",
		"order": 30,
		"catalog_order": 30,
		"stars": 3,
		"label": "EPICKÁ",
		"color_hex": "#A64FE0",
		"ink_hex": INK_HEX,
	},
	"legendary": {
		"id": "legendary",
		"order": 40,
		"catalog_order": 40,
		"stars": 4,
		"label": "LEGENDÁRNÍ",
		"color_hex": "#FFD51E",
		"ink_hex": INK_HEX,
	},
	"special": {
		"id": "special",
		"order": 50,
		"catalog_order": 50,
		"stars": 5,
		"label": "SPECIÁLNÍ",
		"color_hex": "#FF5FB7",
		"ink_hex": INK_HEX,
	},
}


func normalize_rarity_id(value: Variant, diagnostic_context := "") -> String:
	var normalized := str(value).strip_edges().to_lower()
	if DEFINITIONS.has(normalized):
		return normalized
	var context_suffix := ""
	if not diagnostic_context.strip_edges().is_empty():
		context_suffix = " (%s)" % diagnostic_context.strip_edges()
	push_warning(
		"Unknown plant rarity '%s'%s; using '%s'."
		% [str(value), context_suffix, DEFAULT_RARITY_ID]
	)
	return DEFAULT_RARITY_ID


func get_definition(value: Variant, diagnostic_context := "") -> Dictionary:
	var rarity_id := normalize_rarity_id(value, diagnostic_context)
	var definition: Dictionary = DEFINITIONS[rarity_id].duplicate(true)
	definition["color"] = Color(str(definition["color_hex"]))
	definition["ink_color"] = Color(str(definition["ink_hex"]))
	return definition


func get_definitions() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for rarity_id in ORDERED_IDS:
		result.append(get_definition(rarity_id))
	return result


func get_order() -> Array[String]:
	return ORDERED_IDS.duplicate()


func get_label(value: Variant) -> String:
	return str(get_definition(value).get("label", "BĚŽNÁ"))


func get_color(value: Variant) -> Color:
	return Color(str(get_definition(value).get("color_hex", "#76D91D")))


func get_stars(value: Variant) -> int:
	return int(get_definition(value).get("stars", 1))


func get_ink_color() -> Color:
	return Color(INK_HEX)
