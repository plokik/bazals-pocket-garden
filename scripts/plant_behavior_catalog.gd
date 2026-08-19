class_name PlantBehaviorCatalog
extends RefCounted

## Phase 79 keeps plant behaviours declarative and stateless. Profiles only
## reference these canonical ids; the active effect is always derived from the
## current simulation state and is therefore never part of a save file.
const MAX_BEHAVIOR_IDS := 4
const MAX_BEHAVIOR_ID_LENGTH := 64
const ORDER: Array[String] = [
	"resilient_leaves",
	"refreshing_water",
	"aromatic_defense",
	"water_saving_needles",
	"fragrant_bloom",
	"clumping_vigor",
	"aroma_preservation",
	"shade_tolerance",
	"self_seeding",
	"modest_feeding",
]
const DEFINITIONS := {
	"resilient_leaves": {
		"id": "resilient_leaves",
		"label": "RYCHLÁ OBNOVA",
		"name": "RYCHLÁ OBNOVA",
		"description": "Odolné listy zmírní poškození zdraví způsobené stresem o 25 %.",
		"compact_description": "Poškození stresem −25 %",
		"active_text": "Aktivní · poškození stresem −25 %",
		"inactive_text": "Aktivuje se při silnějším stresu",
		"activation": {
			"type": "stress_above",
			"threshold": 0.32,
		},
		"effects": {
			"stress_damage_multiplier": 0.75,
		},
	},
	"refreshing_water": {
		"id": "refreshing_water",
		"label": "MÁTOVÉ VZPRUŽENÍ",
		"name": "MÁTOVÉ VZPRUŽENÍ",
		"description": "Zálivka zpod ideální vláhy přímo do bezpečného pásma jednorázově obnoví 4 zdraví.",
		"compact_description": "Správná zálivka obnoví 4 zdraví",
		"active_text": "Připraveno · správná zálivka obnoví 4 zdraví",
		"inactive_text": "Vláha teď vzpružení nepotřebuje",
		"activation": {
			"type": "watering_crosses_profile_band",
			"minimum_field": "ideal_moisture_min",
			"maximum_field": "ideal_moisture_max",
		},
		"effects": {
			"health_restore": 4.0,
			"once_per_action": true,
		},
	},
	"aromatic_defense": {
		"id": "aromatic_defense",
		"label": "AROMATICKÝ ŠTÍT",
		"name": "AROMATICKÝ ŠTÍT",
		"description": "Když nevhodné vlhko a slabé proudění zvyšují tlak choroby, přírůstek je o 30 % pomalejší.",
		"compact_description": "Přírůstek tlaku choroby −30 %",
		"active_text": "Aktivní · tlak choroby roste o 30 % pomaleji",
		"inactive_text": "Bez nového tlaku choroby",
		"activation": {
			"type": "disease_pressure_gain",
			"humidity_above": 76.0,
			"ventilation_below": 38.0,
		},
		"effects": {
			"disease_pressure_gain_multiplier": 0.70,
		},
	},
	"water_saving_needles": {
		"id": "water_saving_needles",
		"label": "KOŽOVITÉ JEHLICE",
		"name": "KOŽOVITÉ JEHLICE",
		"description": "Při vláze nejvýše na horní hranici ideálu spotřebuje rostlina o 25 % méně vody. V přemokření se efekt vypne.",
		"compact_description": "Spotřeba vody −25 % mimo přemokření",
		"active_text": "Aktivní · spotřeba vody −25 %",
		"inactive_text": "Vypnuto při přemokření",
		"activation": {
			"type": "value_at_or_below_profile_field",
			"value": "moisture",
			"profile_field": "ideal_moisture_max",
		},
		"effects": {
			"water_loss_multiplier": 0.75,
		},
	},
	"fragrant_bloom": {
		"id": "fragrant_bloom",
		"label": "VOŇAVÝ KVĚT",
		"name": "VOŇAVÝ KVĚT",
		"description": "Při kondici alespoň 85 % zvýší voňavý květ čerstvý výnos o 12 %.",
		"compact_description": "Kondice ≥ 85 % · čerstvý výnos +12 %",
		"active_text": "Aktivní · čerstvý výnos +12 %",
		"inactive_text": "Vyžaduje kondici alespoň 85 %",
		"activation": {
			"type": "condition_score_at_least",
			"threshold": 0.85,
		},
		"effects": {
			"fresh_yield_multiplier": 1.12,
			"once_per_harvest": true,
		},
	},
	"clumping_vigor": {
		"id": "clumping_vigor",
		"label": "SÍLA TRSU",
		"name": "SÍLA TRSU",
		"description": "Při vláze v ideálním pásmu roste hustý trs o 10 % rychleji.",
		"compact_description": "Ideální vláha · růst +10 %",
		"active_text": "Aktivní · růst +10 %",
		"inactive_text": "Vyžaduje vláhu v ideálním pásmu",
		"activation": {
			"type": "growth_value_in_profile_band",
			"value": "moisture",
			"minimum_field": "ideal_moisture_min",
			"maximum_field": "ideal_moisture_max",
		},
		"effects": {
			"growth_multiplier": 1.10,
		},
	},
	"aroma_preservation": {
		"id": "aroma_preservation",
		"label": "VŮNĚ PO USUŠENÍ",
		"name": "VŮNĚ PO USUŠENÍ",
		"description": "Při sklizňové kvalitě alespoň 80 % se doba sušení voňavé majoránky zkrátí o 20 %.",
		"compact_description": "Kvalita ≥ 80 % · doba sušení −20 %",
		"active_text": "Aktivní · doba sušení −20 %",
		"inactive_text": "Vyžaduje sklizňovou kvalitu alespoň 80 %",
		"activation": {
			"type": "harvest_quality_at_least",
			"threshold": 0.80,
		},
		"effects": {
			"drying_time_multiplier": 0.80,
			"once_per_harvest": true,
		},
	},
	"shade_tolerance": {
		"id": "shade_tolerance",
		"label": "TOLERANCE POLOSTÍNU",
		"name": "TOLERANCE POLOSTÍNU",
		"description": "Při denním osvětlení pod 5 400 lux neklesne světelná část kondice petržele pod 60 %. Noční tma se nepočítá.",
		"compact_description": "Slabé denní světlo · světelná kondice min. 60 %",
		"active_text": "Aktivní · polostín zmírňuje ztrátu kondice",
		"inactive_text": "Aktivuje se při slabším denním světle",
		"activation": {
			"type": "daylight_light_below",
			"threshold_lux": 5400.0,
		},
		"effects": {
			"daylight_light_factor_floor": 0.60,
		},
	},
	"self_seeding": {
		"id": "self_seeding",
		"label": "BOHATÝ SAMOVÝSEV",
		"name": "BOHATÝ SAMOVÝSEV",
		"description": "Bujná meduňka po dokončeném prodeji vrátí semínko se 75% šancí místo běžných 58 %.",
		"compact_description": "Prodej · šance na semínko 75 %",
		"active_text": "Aktivní · šance na semínko po prodeji 75 %",
		"inactive_text": "Aktivuje se po zasazení meduňky",
		"activation": {
			"type": "sale_seed_drop",
		},
		"effects": {
			"seed_drop_chance_bonus": 0.17,
			"once_per_sale": true,
		},
	},
	"modest_feeding": {
		"id": "modest_feeding",
		"label": "STŘÍDMÁ VÝŽIVA",
		"name": "STŘÍDMÁ VÝŽIVA",
		"description": "V ideálním pásmu živin spotřebuje šalvěj o 25 % méně živin.",
		"compact_description": "Ideální živiny · spotřeba −25 %",
		"active_text": "Aktivní · spotřeba živin −25 %",
		"inactive_text": "Vyžaduje živiny v ideálním pásmu",
		"activation": {
			"type": "growth_value_in_profile_band",
			"value": "nutrients",
			"minimum_field": "ideal_nutrients_min",
			"maximum_field": "ideal_nutrients_max",
		},
		"effects": {
			"nutrient_loss_multiplier": 0.75,
		},
	},
}


func get_order() -> Array[String]:
	return ORDER.duplicate()


func has_definition(behavior_id: String) -> bool:
	return DEFINITIONS.has(behavior_id)


func get_definition(behavior_id: String) -> Dictionary:
	var canonical_id := behavior_id.strip_edges()
	if not has_definition(canonical_id):
		return {}
	return (DEFINITIONS[canonical_id] as Dictionary).duplicate(true)


func get_definitions(raw_behavior_ids: Variant) -> Array[Dictionary]:
	var definitions: Array[Dictionary] = []
	for behavior_id in normalize_behavior_ids(raw_behavior_ids):
		var definition := get_definition(behavior_id)
		if not definition.is_empty():
			definitions.append(definition)
	return definitions


## Runtime callers may receive hand-built or future profiles. Unknown and
## malformed ids intentionally become a safe no-op instead of an error.
func normalize_behavior_ids(raw_behavior_ids: Variant) -> Array[String]:
	var behavior_ids: Array[String] = []
	if not raw_behavior_ids is Array:
		return behavior_ids
	for raw_behavior_id in raw_behavior_ids:
		if behavior_ids.size() >= MAX_BEHAVIOR_IDS:
			break
		if not (raw_behavior_id is String or raw_behavior_id is StringName):
			continue
		var behavior_id := str(raw_behavior_id).strip_edges()
		if not is_canonical_behavior_id(behavior_id):
			continue
		if not has_definition(behavior_id) or behavior_id in behavior_ids:
			continue
		behavior_ids.append(behavior_id)
	return behavior_ids


func is_canonical_behavior_id(behavior_id: String) -> bool:
	if behavior_id.is_empty() or behavior_id.length() > MAX_BEHAVIOR_ID_LENGTH:
		return false
	for index in range(behavior_id.length()):
		var code := behavior_id.unicode_at(index)
		if not ((code >= 97 and code <= 122) or (code >= 48 and code <= 57) or code == 95):
			return false
	return true
