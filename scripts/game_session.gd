class_name GameSession
extends RefCounted

const PlantRarityCatalogScene := preload("res://scripts/plant_rarity_catalog.gd")
const PlantBehaviorCatalogScene := preload("res://scripts/plant_behavior_catalog.gd")
const ProfessorStoryScene := preload("res://scripts/professor_story.gd")
const ProfessorResearchScene := preload("res://scripts/professor_research.gd")
const GreenhouseSimulationScene := preload("res://scripts/greenhouse_simulation.gd")

const SAVE_SCHEMA := 41
const DAILY_CHALLENGE_REAL_DAY_SCHEMA := 15
const REAL_TIME_GROWTH_SCHEMA := 19
const PLANT_LIFECYCLE_SCHEMA := 20
const SEED_INVENTORY_SCHEMA := 21
const BOTANICAL_PACK_SCHEMA := 22
## Schema 23 is the permanent trust boundary for the first authored chapter.
## Every later chapter has its own boundary so future additions cannot silently
## broaden what an older save is allowed to author.
const PROFESSOR_STORY_SCHEMA := 23
const PROFESSOR_STORY_CHAPTER_TWO_SCHEMA := 24
const PROFESSOR_STORY_CHAPTER_THREE_SCHEMA := 26
## Schema 27 remains the base repeatable-research trust boundary. Schema 28
## authorizes only the immutable protocol variant selected on acceptance.
const PROFESSOR_RESEARCH_SCHEMA := 27
const PROFESSOR_RESEARCH_VARIANT_SCHEMA := 28
## Schema 29 is the trust boundary for purchased room decorations and their
## five cosmetic placements. Older saves cannot author ownership by injecting
## future keys; they always migrate to an empty decoration collection.
const ROOM_DECORATION_SCHEMA := 29
## Schema 30 authorizes only the closed greenhouse crop catalog and four
## sanitized bed states. Older saves cannot inject a mature paid crop.
const GREENHOUSE_SCHEMA := 30
## Schema 31 extends the trusted greenhouse catalog with sweet pepper. A schema
## 30 save may keep authored tomato beds, but cannot inject the later crop.
const GREENHOUSE_SECOND_CROP_SCHEMA := 31
## Schema 32 adds level-gated greenhouse progression and authorizes salad
## cucumber. Older saves may keep their legitimate tomato and pepper beds, but
## cannot inject the later crop or bypass its planting unlock.
const GREENHOUSE_PROGRESSION_SCHEMA := 32
## Schema 33 authorizes the level-three garden radish. Schema 32 saves retain
## tomato, pepper, and cucumber, but cannot inject a later paid radish crop.
const GREENHOUSE_RADISH_SCHEMA := 33
## Schema 34 authorizes the level-five garden eggplant. Schema 33 saves retain
## the four earlier crops, but cannot inject the later paid eggplant crop.
const GREENHOUSE_EGGPLANT_SCHEMA := 34
## Schema 35 authorizes one canonical persistent greenhouse order. Schema 34
## saves cannot inject its crop, progress, rotation, completion count, or bonus.
const GREENHOUSE_ORDER_SCHEMA := 35
## Schema 36 authorizes the multi-bed service tier and its credited bed list.
## Schema 35 orders remain standard and cannot inject the larger bonus.
const GREENHOUSE_QUALITY_ORDER_SCHEMA := 36
## Schema 37 records the canonical greenhouse reputation tier. The serialized
## tier is evidence only: completion count remains authoritative, so older or
## hostile saves cannot mint deferred milestone rewards.
const GREENHOUSE_REPUTATION_SCHEMA := 37
## Schema 38 expands the cosmetic room from five generic placements to a
## category-safe collection wall: eight houseplant positions plus six fixed
## display positions. Schema 29-37 ownership is preserved and remapped to the
## first compatible new position; only schema 38 may authorize the new items.
const ROOM_COLLECTION_SCHEMA := 38
## Schema 39 adds two category-safe cosmetic positions: preserved herb jars
## and a future-pet corner. Schema 38 saves retain the complete Phase 123 room,
## but cannot inject ownership of either later paid decoration.
const ROOM_LIVING_DETAILS_SCHEMA := 39
## Schema 40 expands the four-shelf houseplant stand from two to three places
## per shelf. Schema 38-39 saves used indices 8-15 for fixed decorations, so
## those placements must move to 12-19 instead of being reinterpreted as plants.
const ROOM_THREE_PER_SHELF_SCHEMA := 40
## Schema 41 authorizes the four additional purchasable houseplants that make
## every position on the approved four-by-three rack visually unique. Schema
## 40 saves retain their complete room but cannot inject ownership of the new
## cosmetics before the catalog expansion exists.
const ROOM_FINAL_RACK_PLANTS_SCHEMA := 41
const BLEND_ORDER_SCHEMA := 25
## Defensive ceiling for malformed saves and future grant sources. This is high
## enough for normal play while keeping arithmetic and UI values bounded.
const MAX_SEEDS_PER_SPECIES := 9999
const MAX_OPAQUE_SEED_SPECIES := 64
const MAX_SEED_SPECIES_ID_LENGTH := 64
const MAX_PENDING_BOTANICAL_PACKS := 32
const MAX_BOTANICAL_PACK_SOURCE_ID_LENGTH := 64
const MAX_BOTANICAL_PACK_SOURCE_TOKEN_LENGTH := 128
const MAX_BOTANICAL_PACK_ID := 2147483646
const BOTANICAL_PACK_ROLL_VERSION := 1
const BOTANICAL_PACK_SEED_COUNT := 1
const BOTANICAL_PACK_PITY_DUPLICATES := 4
const BOTANICAL_PACK_RNG_MODULUS := 2147483647
const BOTANICAL_PACK_RNG_MULTIPLIER := 48271
const BOTANICAL_PACK_DEFAULT_RNG_STATE := 187904819
const BOTANICAL_PACK_RARITY_ORDER: Array[String] = ["common", "rare", "epic", "legendary", "special"]
const BOTANICAL_PACK_RARITY_WEIGHTS := {
	"common": 55,
	"rare": 30,
	"epic": 10,
	"legendary": 5,
	"special": 0,
}
const FAST_TIME_GUARD_MIN_SPEED := 350.0
const CARE_CHECK_MOISTURE := 28.0
const CARE_CHECK_NUTRIENTS := 27.0
const CARE_CHECK_VENTILATION := 44.0
const ROOM_THEMES := {
	"sunrise": {"name": "Sluneční pokoj", "price": 0, "accent": "#ffb52e", "description": "Původní teplé dřevo a zlaté ranní světlo."},
	"lagoon": {"name": "Tyrkysová laguna", "price": 35, "accent": "#19cbd1", "description": "Svěží tyrkysové odlesky, bubliny a chladivý třpyt."},
	"amethyst": {"name": "Ametystový sen", "price": 55, "accent": "#a85bea", "description": "Fialové kouzlo, růžové jiskry a slavnostní girlanda."},
	"research_study": {"name": "Badatelská pracovna", "price": 360, "accent": "#4d8f78", "description": "Klidný pracovní kout pro Profesorovy protokoly, herbář a přesná pozorování.", "research_completed_required": 6},
}
const CORE_ROOM_THEME_IDS: Array[String] = ["sunrise", "lagoon", "amethyst"]
const RESEARCH_STUDY_THEME_ID := "research_study"
const RESEARCH_STUDY_COMPLETED_REQUIRED := 6
const ROOM_DECORATION_SLOT_COUNT := 20
const ROOM_PLANT_SLOT_COUNT := 12
const ROOM_DECORATION_SLOT_GROUPS: Array[String] = [
	"plant", "plant", "plant", "plant", "plant", "plant", "plant", "plant", "plant", "plant", "plant", "plant",
	"books", "fertilizer", "pots", "lamp", "art", "watering_can", "herb_jars", "pet_corner",
]
const LEGACY_ROOM_COLLECTION_SLOT_MIGRATION: Array[int] = [
	0, 2, 3, 5, 6, 8, 9, 11,
	12, 13, 14, 15, 16, 17, 18, 19,
]
const LEGACY_ROOM_DECORATION_IDS: Array[String] = [
	"botanical_books",
	"mini_monstera",
	"snake_plant",
	"golden_lamp",
	"room_fern",
	"flowering_begonia",
]
const ROOM_DECORATION_IDS: Array[String] = [
	"room_orchid",
	"mini_monstera",
	"snake_plant",
	"room_fern",
	"flowering_begonia",
	"round_leaf_pilea",
	"striped_calathea",
	"climbing_pothos",
	"botanical_books",
	"fertilizer_collection",
	"nested_pots",
	"golden_lamp",
	"botanical_print",
	"plastic_watering_can",
	"preserved_herb_jars",
	"cat_corner",
	"silver_aglaonema",
	"pink_fittonia",
	"lemon_maranta",
	"colorful_coleus",
]
## Phase 159 keeps these IDs readable as historical purchase receipts, but
## never offers them for a new purchase. Their live representation is migrated
## to an existing entitlement so schema 41 remains the trust boundary.
const RETIRED_ROOM_DECORATION_IDS: Array[String] = ["nested_pots"]
## Phase 160 keeps these purchases and placements round-trippable as historical
## receipts, but removes them from the live room and showroom until a coherent
## pet-corner redesign exists. No save field or schema bump is required.
const DORMANT_ROOM_DECORATION_IDS: Array[String] = ["plastic_watering_can", "cat_corner"]
const PHASE160_DORMANT_ROOM_DECORATION_SLOT_INDICES: Array[int] = [17, 19]
const PHASE159_BOTANICAL_CLOCHE_ID := "golden_lamp"
const PHASE159_LEGACY_POTS_ID := "nested_pots"
const PHASE159_RETIRED_POTS_SLOT_INDEX := 14
const PHASE159_BOTANICAL_CLOCHE_SLOT_INDEX := 15
const PHASE123_ROOM_DECORATION_IDS: Array[String] = [
	"room_orchid",
	"mini_monstera",
	"snake_plant",
	"room_fern",
	"flowering_begonia",
	"round_leaf_pilea",
	"striped_calathea",
	"climbing_pothos",
	"botanical_books",
	"fertilizer_collection",
	"nested_pots",
	"golden_lamp",
	"botanical_print",
	"plastic_watering_can",
]
const PHASE141_ROOM_PLANT_IDS: Array[String] = [
	"silver_aglaonema",
	"pink_fittonia",
	"lemon_maranta",
	"colorful_coleus",
]
const ROOM_DECORATIONS := {
	"room_orchid": {
		"name": "Pokojová orchidej",
		"price": 22,
		"kind": "orchid",
		"slot_group": "plant",
		"accent": "#ec78c9",
		"description": "Kvetoucí orchidej pro stojan; je čistě kosmetická a nevyžaduje péči.",
	},
	"botanical_books": {
		"name": "Botanické knihy",
		"price": 14,
		"kind": "books",
		"slot_group": "books",
		"accent": "#ef8c2f",
		"description": "Malá sbírka pěstitelských zápisků a atlasů.",
	},
	"mini_monstera": {
		"name": "Mini monstera",
		"price": 18,
		"kind": "broad_leaf_plant",
		"slot_group": "plant",
		"accent": "#55b85a",
		"description": "Výrazné listy v kompaktním květináči bez péče a umírání.",
	},
	"snake_plant": {
		"name": "Tchynin jazyk",
		"price": 24,
		"kind": "tall_leaf_plant",
		"slot_group": "plant",
		"accent": "#91bd39",
		"description": "Menší dekorativní pokojovka se žlutým lemem.",
	},
	"golden_lamp": {
		"name": "Botanické terárium",
		"price": 26,
		"kind": "botanical_cloche",
		"slot_group": "lamp",
		"accent": "#18a9a5",
		"description": "Malovaná kapradina a mech pod skleněným poklopem; čistě kosmetická dekorace bez péče.",
	},
	"room_fern": {
		"name": "Pokojová kapradina",
		"price": 28,
		"kind": "fern",
		"slot_group": "plant",
		"accent": "#27a65b",
		"description": "Kompaktní zelené vějíře v terakotovém květináči.",
	},
	"flowering_begonia": {
		"name": "Kvetoucí begonie",
		"price": 32,
		"kind": "flowering_plant",
		"slot_group": "plant",
		"accent": "#ef6c9e",
		"description": "Pokojová dekorace s růžovými květy a tmavými listy.",
	},
	"round_leaf_pilea": {
		"name": "Pilea penízková",
		"price": 20,
		"kind": "round_leaf_plant",
		"slot_group": "plant",
		"accent": "#62bd55",
		"description": "Drobná pokojová rostlina s kulatými listy pro sběratelský stojan.",
	},
	"striped_calathea": {
		"name": "Pruhovaná kalatea",
		"price": 34,
		"kind": "striped_leaf_plant",
		"slot_group": "plant",
		"accent": "#8bc85a",
		"description": "Výrazné pruhované listy v menším fialovém květináči.",
	},
	"climbing_pothos": {
		"name": "Popínavý šplhavník",
		"price": 38,
		"kind": "climbing_vine",
		"slot_group": "plant",
		"accent": "#54b74a",
		"description": "Koření v květináči na stojanu a přirozeně šplhá po rámu okna.",
	},
	"fertilizer_collection": {
		"name": "Sbírka hnojiv",
		"price": 20,
		"kind": "fertilizer",
		"slot_group": "fertilizer",
		"accent": "#6aa857",
		"description": "Barevné pokojové balíčky a lahvičky; zásoby ve skladu nijak nemění.",
	},
	"nested_pots": {
		"name": "Složené květináče",
		"price": 16,
		"kind": "nested_pots",
		"slot_group": "pots",
		"accent": "#d57938",
		"description": "Historický nákup; po načtení jej bezpečně zastoupí botanické terárium.",
		"retired": true,
		"replacement_id": "golden_lamp",
	},
	"botanical_print": {
		"name": "Botanický obrázek",
		"price": 30,
		"kind": "botanical_art",
		"slot_group": "art",
		"accent": "#d5a34b",
		"description": "Malý zarámovaný list pro prázdnou stěnu pokoje.",
	},
	"plastic_watering_can": {
		"name": "Plastová konvička",
		"price": 22,
		"kind": "plastic_watering_can",
		"slot_group": "watering_can",
		"accent": "#8b58d6",
		"description": "Historický nákup uložený pro kompatibilitu; v pokoji je do dokončení nového vizuálního konceptu skrytý.",
		"dormant": true,
		"future_replacement_scope": "room_floor_visual_redesign",
	},
	"preserved_herb_jars": {
		"name": "Sklenice se sušenými bylinkami",
		"price": 24,
		"kind": "herb_jars",
		"slot_group": "herb_jars",
		"accent": "#7da34b",
		"description": "Tři zavařovací sklenice s barevnými sušenými bylinkami pro autentickou horní polici.",
	},
	"cat_corner": {
		"name": "Kočičí pelíšek",
		"price": 54,
		"kind": "cat_corner",
		"slot_group": "pet_corner",
		"accent": "#d76f8f",
		"description": "Historický nákup uložený pro kompatibilitu; vrátí se až jako jednotně namalovaný kout společně s budoucím mazlíčkem.",
		"dormant": true,
		"future_replacement_scope": "pet_purchase_and_integrated_corner",
	},
	"silver_aglaonema": {
		"name": "Stříbrná aglaonema",
		"price": 30,
		"kind": "silver_leaf_plant",
		"slot_group": "plant",
		"accent": "#a7c987",
		"description": "Kompaktní stříbřitě zelená pokojovka pro jednu z dvanácti pozic finálního stojanu.",
	},
	"pink_fittonia": {
		"name": "Růžová fitónie",
		"price": 34,
		"kind": "pink_vein_plant",
		"slot_group": "plant",
		"accent": "#ec6fa7",
		"description": "Sytě zelené listy s růžovou žilnatinou v jednotném fialovém květináči a podmisce.",
	},
	"lemon_maranta": {
		"name": "Citronová maranta",
		"price": 36,
		"kind": "lemon_leaf_plant",
		"slot_group": "plant",
		"accent": "#b9d83f",
		"description": "Světlá kresba listů doplňuje spodní police bez přesahu do sousedních míst.",
	},
	"colorful_coleus": {
		"name": "Barevný koleus",
		"price": 40,
		"kind": "coleus",
		"slot_group": "plant",
		"accent": "#b44855",
		"description": "Výrazná vínově zelená pokojovka uzavírá dvanáctidílnou kosmetickou sbírku stojanu.",
	},
}
const MAX_PLANT_SLOTS := 10
const SLOT_UNLOCK_LEVELS := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
const ACTIVE_ORDER_COUNT := 3
const BOTANIST_BUYBACK_FACTOR := 0.82
const SHOP_REAL_DAY_SECONDS := 86400.0
const MAX_SUPPORTED_UNIX_TIME := 253402300799.0
const MAX_SUPPORTED_UTC_DAY := 2932896
const SHOP_FERTILIZER_ITEM_ID := "fertilizer"
const SHOP_SEED_ITEM_PREFIX := "seed:"
const REFRESHING_WATER_BEHAVIOR_ID := "refreshing_water"
const DAILY_ORDER_REFRESHES := 2
const LEGACY_SINGLE_ORDER_TEMPLATE_COUNT := 12
const MAX_ORDER_SEQUENCE := 2147483646
const ORDER_MAX_QUALITY := 0.90
const ORDER_MAX_FLAT_BONUS := 24
const ORDER_MAX_BONUS_XP := 30
const ORDER_MAX_REWARD_COINS := 100
const BLEND_ORDER_MAX_REWARD_COINS := 180
const GREENHOUSE_ORDER_MAX_COMPLETIONS := 2147483646
const GREENHOUSE_ORDER_TIER_STANDARD := "standard"
const GREENHOUSE_ORDER_TIER_MULTI_BED := "multi_bed"
const GREENHOUSE_MULTI_BED_BONUS_COINS := 8
const GREENHOUSE_MULTI_BED_BONUS_XP := 4
const GREENHOUSE_REPUTATION_MILESTONES := [
	{
		"tier": 1,
		"target_orders": 3,
		"title": "SPOLEHLIVÝ PĚSTITEL",
		"reward_coins": 40,
		"reward_xp": 20,
		"cosmetic_sign": "",
	},
	{
		"tier": 2,
		"target_orders": 8,
		"title": "DODAVATEL TRHU",
		"reward_coins": 80,
		"reward_xp": 40,
		"cosmetic_sign": "",
	},
	{
		"tier": 3,
		"target_orders": 15,
		"title": "MISTR SKLENÍKU",
		"reward_coins": 0,
		"reward_xp": 0,
		"cosmetic_sign": "MISTR SKLENÍKU",
	},
]
const DAILY_CHALLENGE_IDS := ["plant", "rescue", "treat", "harvest", "start_drying", "package", "sell", "ventilate", "lamp", "fertilize", "water", "prepare_rain", "prepare_cloud", "prepare_dry"]
const DAILY_CHALLENGE_WEATHER_NAMES := ["Jasno", "Polojasno", "Větrno", "Zataženo", "Déšť"]
const EQUIPMENT_MAX_LEVEL := 3
const EQUIPMENT_ORDER := ["watering_can", "grow_lamp", "ventilation_fan", "protective_spray", "self_watering_pot"]
const EQUIPMENT_CATALOG := {
	"watering_can": {
		"name": "KONEV",
		"levels": [
			{"level": 1, "effect": "120 ml na zálivku", "water_ml": 120.0, "safe_moisture_cap": 100.0},
			{"level": 2, "effect": "135 ml · pojistka 88%", "water_ml": 135.0, "safe_moisture_cap": 88.0, "price": 28, "unlock_level": 2},
			{"level": 3, "effect": "150 ml · pojistka 82%", "water_ml": 150.0, "safe_moisture_cap": 82.0, "price": 76, "unlock_level": 5},
		],
	},
	"grow_lamp": {
		"name": "LAMPA",
		"levels": [
			{"level": 1, "effect": "+11 500 lux", "lamp_lux": 11500.0},
			{"level": 2, "effect": "+13 500 lux", "lamp_lux": 13500.0, "price": 32, "unlock_level": 2},
			{"level": 3, "effect": "+15 500 lux", "lamp_lux": 15500.0, "price": 90, "unlock_level": 6},
		],
	},
	"ventilation_fan": {
		"name": "VENTILÁTOR",
		"levels": [
			{"level": 1, "effect": "Základní proudění", "disease_relief": 12.0, "ventilation_decay_multiplier": 1.0},
			{"level": 2, "effect": "Proudění vydrží déle", "disease_relief": 24.0, "ventilation_decay_multiplier": 0.80, "price": 30, "unlock_level": 3},
			{"level": 3, "effect": "Silná prevence plísně", "disease_relief": 40.0, "ventilation_decay_multiplier": 0.65, "price": 82, "unlock_level": 6},
		],
	},
	"protective_spray": {
		"name": "POSTŘIK",
		"levels": [
			{"level": 1, "effect": "Prevence · léčba −52", "disease_gain_multiplier": 1.0, "disease_treatment_relief": 52.0},
			{"level": 2, "effect": "Riziko −28% · léčba −72", "disease_gain_multiplier": 0.72, "disease_treatment_relief": 72.0, "price": 26, "unlock_level": 2},
			{"level": 3, "effect": "Riziko −52% · léčba −100", "disease_gain_multiplier": 0.48, "disease_treatment_relief": 100.0, "price": 70, "unlock_level": 5},
		],
	},
	"self_watering_pot": {
		"name": "SADA KVĚTINÁČŮ",
		"levels": [
			{"level": 1, "effect": "Běžná nádoba", "water_loss_multiplier": 1.0, "harvest_yield_multiplier": 1.0},
			{"level": 2, "effect": "−12% žízně · +8% sklizně", "water_loss_multiplier": 0.88, "harvest_yield_multiplier": 1.08, "price": 36, "unlock_level": 4},
			{"level": 3, "effect": "−24% žízně · +16% sklizně", "water_loss_multiplier": 0.76, "harvest_yield_multiplier": 1.16, "price": 110, "unlock_level": 7},
		],
	},
}
const LEVEL_REWARDS := [
	{"level": 1, "coins": 5, "fertilizer": 0, "seed_rewards": {}},
	{"level": 2, "coins": 12, "fertilizer": 1, "seed_rewards": {}},
	{"level": 3, "coins": 15, "fertilizer": 0, "seed_rewards": {"basil_genovese": 1}},
	{"level": 4, "coins": 18, "fertilizer": 0, "seed_rewards": {"mint_peppermint": 1}},
	{"level": 5, "coins": 24, "fertilizer": 1, "seed_rewards": {}},
	{"level": 6, "coins": 30, "fertilizer": 0, "seed_rewards": {"rosemary_officinalis": 1}},
	{"level": 7, "coins": 36, "fertilizer": 1, "seed_rewards": {}},
	{"level": 8, "coins": 45, "fertilizer": 0, "seed_rewards": {"basil_genovese": 1}},
	{"level": 9, "coins": 55, "fertilizer": 0, "seed_rewards": {"mint_peppermint": 1}},
	{"level": 10, "coins": 75, "fertilizer": 2, "seed_rewards": {"rosemary_officinalis": 1, "oregano_vulgare": 1}},
]
const MASTERY_TIERS := [
	{"tier": 1, "title": "Učeň", "harvests": 0, "quality": 0.0, "orders": 0, "coins": 0, "xp": 0, "seeds": 0},
	{"tier": 2, "title": "Pěstitel", "harvests": 1, "quality": 0.55, "orders": 0, "coins": 10, "xp": 8, "seeds": 0},
	{"tier": 3, "title": "Znalec", "harvests": 3, "quality": 0.70, "orders": 1, "coins": 20, "xp": 16, "seeds": 1},
	{"tier": 4, "title": "Mistr", "harvests": 6, "quality": 0.82, "orders": 3, "coins": 35, "xp": 28, "seeds": 1},
	{"tier": 5, "title": "Legenda", "harvests": 10, "quality": 0.90, "orders": 6, "coins": 60, "xp": 45, "seeds": 2},
]
const ORDER_TEMPLATES := [
	{
		"customer": "Bistro U Konvičky",
		"title": "Svěží lístky na pesto",
		"species_id": "basil_genovese",
		"min_quality": 0.55,
		"min_dry_g": 3.0,
		"reward_multiplier": 1.15,
		"flat_bonus": 4,
		"bonus_xp": 8,
		"accent": "green",
	},
	{
		"customer": "Lékárna Zelený list",
		"title": "Rozmarýnová prémiová šarže",
		"species_id": "rosemary_officinalis",
		"min_quality": 0.72,
		"min_dry_g": 4.0,
		"reward_multiplier": 1.42,
		"flat_bonus": 7,
		"bonus_xp": 15,
		"accent": "blue",
	},
	{
		"customer": "Městský festival",
		"title": "Mátová festivalová várka",
		"species_id": "mint_peppermint",
		"min_quality": 0.86,
		"min_dry_g": 4.5,
		"reward_multiplier": 1.72,
		"flat_bonus": 10,
		"bonus_xp": 24,
		"accent": "purple",
	},
	{
		"customer": "Pekařství Zlatý klas",
		"title": "Bazalková focaccia",
		"species_id": "basil_genovese",
		"min_quality": 0.64,
		"min_dry_g": 3.5,
		"reward_multiplier": 1.30,
		"flat_bonus": 6,
		"bonus_xp": 12,
		"accent": "gold",
	},
	{
		"customer": "Hotel Modrá veranda",
		"title": "Výběrové lístky pro hosty",
		"species_id": "any",
		"min_quality": 0.80,
		"min_dry_g": 4.2,
		"reward_multiplier": 1.58,
		"flat_bonus": 9,
		"bonus_xp": 20,
		"accent": "orange",
	},
	{
		"customer": "Trattoria U Slunce",
		"title": "Voňavé oregano na pizzu",
		"species_id": "oregano_vulgare",
		"min_quality": 0.74,
		"min_dry_g": 4.2,
		"reward_multiplier": 1.50,
		"flat_bonus": 8,
		"bonus_xp": 18,
		"accent": "gold",
	},
	{
		"customer": "Parfumerie Fialový měsíc",
		"title": "Voňavá levandulová sklizeň",
		"species_id": "lavandula_angustifolia",
		"min_quality": 0.82,
		"min_dry_g": 6.0,
		"reward_multiplier": 1.55,
		"flat_bonus": 10,
		"bonus_xp": 24,
		"accent": "purple",
		"requires_discovery": true,
	},
	{
		"customer": "Bistro U Kopretiny",
		"title": "Pažitka do bylinkového dipu",
		"species_id": "allium_schoenoprasum",
		"min_quality": 0.70,
		"min_dry_g": 4.0,
		"reward_multiplier": 1.35,
		"flat_bonus": 6,
		"bonus_xp": 12,
		"accent": "green",
		"requires_discovery": true,
	},
	{
		"customer": "Hostinec U Zlaté lžíce",
		"title": "Voňavá majoránka do bramboračky",
		"species_id": "origanum_majorana",
		"min_quality": 0.78,
		"min_dry_g": 5.0,
		"reward_multiplier": 1.50,
		"flat_bonus": 8,
		"bonus_xp": 18,
		"accent": "gold",
		"requires_discovery": true,
	},
	{
		"customer": "Jídelna U Zahrádky",
		"title": "Petrželka do sváteční polévky",
		"species_id": "petroselinum_crispum",
		"min_quality": 0.72,
		"min_dry_g": 4.5,
		"reward_multiplier": 1.38,
		"flat_bonus": 7,
		"bonus_xp": 14,
		"accent": "green",
		"requires_discovery": true,
	},
	{
		"customer": "Čajovna Tichý kout",
		"title": "Meduňka pro večerní čaj",
		"species_id": "melissa_officinalis",
		"min_quality": 0.74,
		"min_dry_g": 4.6,
		"reward_multiplier": 1.42,
		"flat_bonus": 7,
		"bonus_xp": 15,
		"accent": "green",
		"requires_discovery": true,
	},
	{
		"customer": "Klášterní kuchyně",
		"title": "Šalvěj pro sváteční nádivku",
		"species_id": "salvia_officinalis",
		"min_quality": 0.84,
		"min_dry_g": 6.0,
		"reward_multiplier": 1.40,
		"flat_bonus": 10,
		"bonus_xp": 26,
		"accent": "gold",
		"requires_discovery": true,
	},
	{
		"customer": "Čajovna Pod hvězdami",
		"title": "Svěží večerní směs",
		"kind": "blend",
		"blend_id": "evening_freshness",
		"requirements": [
			{"species_id": "mint_peppermint", "min_dry_g": 4.0, "min_quality": 0.74},
			{"species_id": "melissa_officinalis", "min_dry_g": 4.5, "min_quality": 0.74},
		],
		"reward_multiplier": 1.25,
		"flat_bonus": 5,
		"bonus_xp": 18,
		"accent": "purple",
		"requires_discovery": true,
	},
	{
		"customer": "Městská polévková kuchyně",
		"title": "Polévková dvojice",
		"kind": "blend",
		"blend_id": "soup_pair",
		"requirements": [
			{"species_id": "petroselinum_crispum", "min_dry_g": 4.2, "min_quality": 0.76},
			{"species_id": "origanum_majorana", "min_dry_g": 4.8, "min_quality": 0.78},
		],
		"reward_multiplier": 1.30,
		"flat_bonus": 7,
		"bonus_xp": 22,
		"accent": "orange",
		"requires_discovery": true,
	},
	{
		"customer": "Ateliér Voňavý herbář",
		"title": "Aromatický sáček",
		"kind": "blend",
		"blend_id": "aromatic_sachet",
		"requirements": [
			{"species_id": "lavandula_angustifolia", "min_dry_g": 5.5, "min_quality": 0.82},
			{"species_id": "rosemary_officinalis", "min_dry_g": 4.8, "min_quality": 0.78},
		],
		"reward_multiplier": 1.35,
		"flat_bonus": 8,
		"bonus_xp": 28,
		"accent": "gold",
		"requires_discovery": true,
	},
	{
		"customer": "Pekárna U Kamenné pece",
		"title": "Tymián na pečenou zeleninu",
		"species_id": "thymus_vulgaris",
		"min_quality": 0.76,
		"min_dry_g": 4.8,
		"reward_multiplier": 1.45,
		"flat_bonus": 8,
		"bonus_xp": 18,
		"accent": "green",
		"requires_discovery": true,
	},
	{
		"customer": "Bistro Levandulový dvůr",
		"title": "Provensálská dvojice",
		"kind": "blend",
		"blend_id": "provence_pair",
		"requirements": [
			{"species_id": "thymus_vulgaris", "min_dry_g": 4.8, "min_quality": 0.78},
			{"species_id": "rosemary_officinalis", "min_dry_g": 4.6, "min_quality": 0.78},
		],
		"reward_multiplier": 1.32,
		"flat_bonus": 8,
		"bonus_xp": 24,
		"accent": "gold",
		"requires_discovery": true,
	},
]
const GREENHOUSE_ORDER_TEMPLATES := [
	{
		"crop_id": "cherry_tomato",
		"customer": "Bistro U Skleníku",
		"title": "Bedýnka cherry rajčat",
		"target_harvests": 2,
		"bonus_coins": 14,
		"bonus_xp": 6,
	},
	{
		"crop_id": "sweet_pepper",
		"customer": "Tržnice Slunečný dvůr",
		"title": "Koš sladkých paprik",
		"target_harvests": 2,
		"bonus_coins": 20,
		"bonus_xp": 8,
	},
	{
		"crop_id": "garden_radish",
		"customer": "Farmářský stánek",
		"title": "Svazek křupavých ředkviček",
		"target_harvests": 3,
		"bonus_coins": 18,
		"bonus_xp": 8,
	},
	{
		"crop_id": "salad_cucumber",
		"customer": "Letní jídelna",
		"title": "Čerstvé salátové okurky",
		"target_harvests": 2,
		"bonus_coins": 28,
		"bonus_xp": 10,
	},
	{
		"crop_id": "garden_eggplant",
		"customer": "Restaurace Fialová zahrada",
		"title": "Výběrový lilek",
		"target_harvests": 2,
		"bonus_coins": 36,
		"bonus_xp": 12,
	},
]

enum JourneyStep {
	PLANT_SEED,
	WATER_PLANT,
	VISIT_MEASUREMENTS,
	GROW_TO_MATURE,
	HARVEST,
	START_DRYING,
	WAIT_FOR_DRYING,
	PACKAGE,
	SELL,
	COMPLETE,
}

signal event_created(message: String)
signal feedback_requested(kind: String, slot_index: int, payload: Dictionary)
signal journey_changed(step: int, previous_step: int)
signal slot_unlocked(slot_index: int, level: int)
signal fast_time_guard_triggered(slot_index: int, reason: String, target: String)
signal story_progressed(event: Dictionary)
signal story_chapter_changed(chapter_id: String, state: Dictionary)

var plant: PlantSimulation
var plants: Array[PlantSimulation] = []
var plant_profiles: Dictionary = {}
var species_progress: Dictionary = {}
var plant_rarity_catalog := PlantRarityCatalogScene.new()
var plant_behavior_catalog := PlantBehaviorCatalogScene.new()
var world_elapsed_seconds := 0.0
var daily_challenge_id := ""
var daily_challenge_issued_day := 0
var daily_challenge_real_day := 0
var daily_challenge_last_claimed_real_day := -1
var daily_challenge_weather := ""
var daily_challenge_forecast_weather := ""
var daily_challenge_completed := false
var daily_challenge_claimed := false
var shop_stock_day := -1
var shop_stock: Dictionary = {}
var selected_plant_index := 0
var coins := 30
var xp := 0
var seed_inventory: Dictionary = {}
var pending_botanical_packs: Array[Dictionary] = []
var next_botanical_pack_id := 1
var botanical_pack_rng_state := BOTANICAL_PACK_DEFAULT_RNG_STATE
var botanical_pack_pity := 0
var professor_story := ProfessorStoryScene.new()
var professor_research := ProfessorResearchScene.new()
var story_chapters: Dictionary = {}
var active_story_chapter_id := ""
# Deprecated schema-20 compatibility properties. Production code reads the
# catalog-backed inventory through get_seed_count()/set_seed_count().
var seeds: int:
	get:
		return get_seed_count("basil_genovese")
	set(value):
		set_seed_count("basil_genovese", value)
var mint_seeds: int:
	get:
		return get_seed_count("mint_peppermint")
	set(value):
		set_seed_count("mint_peppermint", value)
var rosemary_seeds: int:
	get:
		return get_seed_count("rosemary_officinalis")
	set(value):
		set_seed_count("rosemary_officinalis", value)
var oregano_seeds: int:
	get:
		return get_seed_count("oregano_vulgare")
	set(value):
		set_seed_count("oregano_vulgare", value)
var selected_seed_species := "basil_genovese"
var fertilizer_doses := 2
var harvest_count := 0
var speed_multiplier := 1.0
var paused := false
var intro_completed := false
var journey_step := JourneyStep.PLANT_SEED
var journey_completed := false
var journey_reward_claimed := false
var reduced_motion := false
var music_enabled := true
var sfx_enabled := true
var haptics_enabled := true
var music_volume := 0.55
var sfx_volume := 0.80
var visited_screens: Array[int] = []
var chart_samples: Array[Dictionary] = []
var orders: Array[Dictionary] = []
var orders_completed := 0
var order_rotation := 0
var order_refresh_day := -1
var order_refreshes_remaining := DAILY_ORDER_REFRESHES
var saved_at_unix := 0.0
var unlocked_room_themes: Array[String] = ["sunrise"]
var selected_room_theme := "sunrise"
var owned_room_decorations: Array[String] = []
var room_decoration_slots: Array[String] = ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]
var greenhouse = GreenhouseSimulationScene.new()
var greenhouse_order: Dictionary = {}
var greenhouse_order_rotation := 0
var greenhouse_orders_completed := 0
var greenhouse_reputation_claimed_tier := 0
var claimed_level_rewards: Array[int] = []
var equipment_levels: Dictionary = {
	"watering_can": 1,
	"grow_lamp": 1,
	"ventilation_fan": 1,
	"protective_spray": 1,
	"self_watering_pot": 1,
}
var care_reminders_enabled := true
var fast_time_guard_enabled := true

var _chart_accumulator := 0.0
var _daily_challenge_refresh_accumulator := 0.0
var _care_attention_cache: Dictionary = {}
var _care_attention_cache_initialized := false
var _offline_lifecycle_events: Array[Dictionary] = []
var _legacy_lifecycle_protection_pending := false
var _story_progress_events: Array[Dictionary] = []
var _story_return_summary_lines: Array[String] = []


func _init(profile_or_catalog: Dictionary = {}) -> void:
	plant_profiles = _normalize_plant_profiles(profile_or_catalog)
	_initialize_seed_inventory_from_profile_defaults()
	_ensure_species_progress()
	_create_plant_slots(get_plant_profile("basil_genovese"))
	_sync_equipment_effects()
	_ensure_orders()
	_ensure_greenhouse_order()
	refresh_order_declines_for_unix()
	_ensure_daily_challenge()
	refresh_shop_stock_for_unix()
	_sync_professor_story_storage()
	_capture_sample()


func _create_plant_slots(profile: Dictionary) -> void:
	plants.clear()
	for index in range(MAX_PLANT_SLOTS):
		var slot := PlantSimulation.new(profile)
		slot.event_created.connect(_relay_event)
		plants.append(slot)
	selected_plant_index = 0
	plant = plants[0]


func _normalize_plant_profiles(profile_or_catalog: Dictionary) -> Dictionary:
	var catalog: Dictionary = {}
	for key in profile_or_catalog:
		var candidate = profile_or_catalog[key]
		if candidate is Dictionary and candidate.has("id"):
			catalog[str(candidate.get("id", key))] = candidate.duplicate(true)
	if catalog.is_empty() and profile_or_catalog.has("id"):
		catalog[str(profile_or_catalog.get("id", "basil_genovese"))] = profile_or_catalog.duplicate(true)
	if catalog.is_empty():
		catalog["basil_genovese"] = profile_or_catalog.duplicate(true)
	return catalog


func get_plant_profile(species_id: String) -> Dictionary:
	if plant_profiles.has(species_id):
		return plant_profiles[species_id]
	if plant_profiles.has("basil_genovese"):
		return plant_profiles["basil_genovese"]
	return plant_profiles.values()[0] if not plant_profiles.is_empty() else {}


func get_available_species() -> Array[String]:
	var available: Array[String] = []
	for species_id in plant_profiles:
		available.append(str(species_id))
	available.sort_custom(func(left: String, right: String) -> bool:
		var left_profile := get_plant_profile(left)
		var right_profile := get_plant_profile(right)
		var left_order := int(left_profile.get("catalog_order", 1000))
		var right_order := int(right_profile.get("catalog_order", 1000))
		return left < right if left_order == right_order else left_order < right_order
	)
	return available


func get_botanist_shop_species_ids() -> Array[String]:
	var available: Array[String] = []
	for species_id in get_available_species():
		if species_has_acquisition_source(species_id, "botanist"):
			available.append(species_id)
	available.sort_custom(func(left: String, right: String) -> bool:
		var left_profile := get_plant_profile(left)
		var right_profile := get_plant_profile(right)
		var left_order := int(left_profile.get("botanist_shop_order", left_profile.get("catalog_order", 1000)))
		var right_order := int(right_profile.get("botanist_shop_order", right_profile.get("catalog_order", 1000)))
		return left < right if left_order == right_order else left_order < right_order
	)
	return available


func species_has_acquisition_source(species_id: String, source_id: String) -> bool:
	if not plant_profiles.has(species_id):
		return false
	var raw_sources: Variant = (plant_profiles[species_id] as Dictionary).get("acquisition_sources", [])
	return raw_sources is Array and source_id in (raw_sources as Array)


func get_botanist_seed_unlock_level(species_id: String) -> int:
	if not plant_profiles.has(species_id) or not species_has_acquisition_source(species_id, "botanist"):
		return -1
	return maxi(1, int((plant_profiles[species_id] as Dictionary).get("shop_unlock_level", 1)))


func is_botanist_seed_unlocked(species_id: String) -> bool:
	var unlock_level := get_botanist_seed_unlock_level(species_id)
	return unlock_level > 0 and get_level() >= unlock_level


func get_species_rarity_id(species_id: String) -> String:
	return plant_rarity_catalog.normalize_rarity_id(get_plant_profile(species_id).get("rarity", "common"))


func get_species_rarity_definition(species_id: String) -> Dictionary:
	return plant_rarity_catalog.get_definition(get_species_rarity_id(species_id))


func get_species_behavior_definitions(species_id: String) -> Array[Dictionary]:
	if not plant_profiles.has(species_id):
		return []
	var profile: Dictionary = plant_profiles[species_id]
	return plant_behavior_catalog.get_definitions(profile.get("behavior_ids", []))


func get_collection_species_ids() -> Array[String]:
	var collection: Array[String] = []
	for species_id in get_available_species():
		if bool(get_plant_profile(species_id).get("collection_visible", true)):
			collection.append(species_id)
	return collection


func is_species_discovered(species_id: String) -> bool:
	if not plant_profiles.has(species_id):
		return false
	return bool(get_species_progress(species_id).get("discovered", false))


func get_discovered_species_count() -> int:
	var discovered := 0
	for species_id in get_collection_species_ids():
		if is_species_discovered(species_id):
			discovered += 1
	return discovered


func get_collection_completion_percent() -> int:
	var species_count := get_collection_species_ids().size()
	if species_count <= 0:
		return 0
	var completion := float(get_discovered_species_count()) / float(species_count) * 100.0
	return clampi(roundi(completion), 0, 100)


func get_active_story_chapter_id() -> String:
	_activate_professor_story_if_eligible(false)
	return professor_story.get_active_chapter_id()


func is_professor_story_unlocked() -> bool:
	_activate_professor_story_if_eligible(false)
	return professor_story.is_unlocked()


func get_professor_story_state() -> Dictionary:
	_activate_professor_story_if_eligible(false)
	var active_chapter := professor_story.get_active_chapter_id()
	var pack_grant_available := true
	if active_chapter.is_empty() or active_chapter == ProfessorStoryScene.CHAPTER_ID:
		pack_grant_available = _can_grant_botanical_pack("professor_story", ProfessorStoryScene.CHAPTER_ID, true)
	var mastery_species_count := _get_mastery_species_count(ProfessorStoryScene.THIRD_MASTERY_TIER)
	if active_chapter == ProfessorStoryScene.THIRD_CHAPTER_ID:
		return professor_story.build_state(
			get_discovered_species_count(),
			get_collection_species_ids().size(),
			false,
			true,
			mastery_species_count,
			true
		).duplicate(true)
	var sage_reward_available := plant_profiles.has(ProfessorStoryScene.SECOND_REWARD_SPECIES_ID) \
		and get_seed_count(ProfessorStoryScene.SECOND_REWARD_SPECIES_ID) <= MAX_SEEDS_PER_SPECIES - ProfessorStoryScene.SECOND_REWARD_SEEDS
	return professor_story.build_state(
		get_discovered_species_count(),
		get_collection_species_ids().size(),
		pending_botanical_packs.size() >= MAX_PENDING_BOTANICAL_PACKS,
		pack_grant_available,
		mastery_species_count,
		sage_reward_available
	).duplicate(true)


func get_professor_story_next_action() -> Dictionary:
	return (get_professor_story_state().get("next_action", {}) as Dictionary).duplicate(true)


func get_professor_seal_count() -> int:
	return professor_story.get_completed_chapter_count()


func get_professor_title_id() -> String:
	return ProfessorStoryScene.THIRD_REWARD_TITLE_ID \
		if professor_story.is_chapter_claimed(ProfessorStoryScene.THIRD_CHAPTER_ID) else ""


func get_professor_title() -> String:
	return ProfessorStoryScene.THIRD_REWARD_TITLE \
		if professor_story.is_chapter_claimed(ProfessorStoryScene.THIRD_CHAPTER_ID) else ""


func can_claim_professor_story_reward() -> bool:
	return bool(get_professor_story_state().get("can_claim", false))


func has_professor_story_attention() -> bool:
	return bool(get_professor_story_state().get("attention_required", false))


func get_professor_hub_state(unix_time := -1.0) -> Dictionary:
	if not _is_professor_research_unlocked():
		return get_professor_story_state()
	var utc_day := _get_real_shop_day_index(Time.get_unix_time_from_system() if unix_time < 0.0 else unix_time)
	professor_research.set_unlocked(true, utc_day)
	return professor_research.get_state(utc_day).duplicate(true)


func mark_professor_hub_seen(expected_cycle_id: int, unix_time := -1.0) -> bool:
	if not _is_professor_research_unlocked():
		return false
	var utc_day := _get_real_shop_day_index(Time.get_unix_time_from_system() if unix_time < 0.0 else unix_time)
	professor_research.set_unlocked(true, utc_day)
	if not professor_research.mark_offer_seen(expected_cycle_id, utc_day):
		return false
	story_chapter_changed.emit(ProfessorResearchScene.SYSTEM_ID, get_professor_hub_state(unix_time))
	return true


func start_professor_research(expected_cycle_id: int, unix_time := -1.0) -> Dictionary:
	if not _is_professor_research_unlocked():
		return {"success": false, "reason": "locked", "system_id": ProfessorResearchScene.SYSTEM_ID, "cycle_id": expected_cycle_id}
	var utc_day := _get_real_shop_day_index(Time.get_unix_time_from_system() if unix_time < 0.0 else unix_time)
	professor_research.set_unlocked(true, utc_day)
	if not professor_research.start(expected_cycle_id, utc_day):
		var reason := "already_active" if professor_research.get_active_cycle_id() >= 0 else ("already_claimed" if expected_cycle_id <= professor_research.get_last_claimed_cycle_id() else "stale_cycle")
		return {"success": false, "reason": reason, "system_id": ProfessorResearchScene.SYSTEM_ID, "cycle_id": expected_cycle_id}
	var rescue_seed_granted := _grant_emergency_basil_seed_if_softlocked()
	var active_state := professor_research.get_state(utc_day)
	var result := {
		"success": true,
		"reason": "",
		"mode": "research",
		"content_kind": "weekly_research",
		"system_id": ProfessorResearchScene.SYSTEM_ID,
		"cycle_id": expected_cycle_id,
		"protocol_id": str(active_state.get("protocol_id", "")),
		"protocol_name": str(active_state.get("protocol_name", "")),
		"rescue_seed_granted": rescue_seed_granted,
	}
	event_created.emit("Profesorův týdenní protokol byl přijat. Aktivní výzkum nemá datum vypršení.")
	feedback_requested.emit("professor_research_started", selected_plant_index, result.duplicate(true))
	story_chapter_changed.emit(ProfessorResearchScene.SYSTEM_ID, get_professor_hub_state(unix_time))
	return result


func claim_professor_research_reward(expected_cycle_id: int, unix_time := -1.0) -> Dictionary:
	if not _is_professor_research_unlocked():
		return {"success": false, "reason": "locked", "system_id": ProfessorResearchScene.SYSTEM_ID, "cycle_id": expected_cycle_id}
	var utc_day := _get_real_shop_day_index(Time.get_unix_time_from_system() if unix_time < 0.0 else unix_time)
	professor_research.set_unlocked(true, utc_day)
	var active_cycle_id := professor_research.get_active_cycle_id()
	if expected_cycle_id != active_cycle_id:
		return {
			"success": false,
			"reason": "already_claimed" if expected_cycle_id <= professor_research.get_last_claimed_cycle_id() else "stale_cycle",
			"system_id": ProfessorResearchScene.SYSTEM_ID,
			"cycle_id": expected_cycle_id,
		}
	if not professor_research.can_claim(expected_cycle_id):
		return {"success": false, "reason": "incomplete", "system_id": ProfessorResearchScene.SYSTEM_ID, "cycle_id": expected_cycle_id}
	var claimed_protocol_id := professor_research.get_active_protocol_id()

	# Research rewards have no inventory or queue dependency. Snapshot every
	# authoritative field before the single commit so a failed/stale mark can
	# never leave a partial economic reward.
	var previous_research := professor_research.to_dict()
	var previous_coins := coins
	var previous_xp := xp
	var previous_fertilizer_doses := fertilizer_doses
	if not professor_research.mark_claimed(expected_cycle_id):
		coins = previous_coins
		xp = previous_xp
		fertilizer_doses = previous_fertilizer_doses
		professor_research.load_state(previous_research, PROFESSOR_RESEARCH_VARIANT_SCHEMA, true, utc_day)
		return {"success": false, "reason": "atomic_claim_failed", "system_id": ProfessorResearchScene.SYSTEM_ID, "cycle_id": expected_cycle_id}

	_change_coins(ProfessorResearchScene.REWARD_COINS, "professor_research")
	_grant_xp(ProfessorResearchScene.REWARD_XP, "professor_research")
	fertilizer_doses += ProfessorResearchScene.REWARD_FERTILIZER
	var reward := {
		"coins": ProfessorResearchScene.REWARD_COINS,
		"xp": ProfessorResearchScene.REWARD_XP,
		"fertilizer": ProfessorResearchScene.REWARD_FERTILIZER,
		"botanical_packs": 0,
		"seeds": {},
		"text": ProfessorResearchScene.REWARD_TEXT,
	}
	var result := {
		"success": true,
		"reason": "",
		"mode": "research",
		"content_kind": "weekly_research",
		"system_id": ProfessorResearchScene.SYSTEM_ID,
		"cycle_id": expected_cycle_id,
		"protocol_id": claimed_protocol_id,
		"reward": reward.duplicate(true),
		"fertilizer_total": fertilizer_doses,
		"completed_count": professor_research.get_completed_count(),
	}
	feedback_requested.emit("professor_research_reward", selected_plant_index, result.duplicate(true))
	event_created.emit("Profesorův týdenní protokol je dokončen: 45 mincí, 35 XP a 1 dávka hnojiva.")
	story_chapter_changed.emit(ProfessorResearchScene.SYSTEM_ID, get_professor_hub_state(unix_time))
	return result


func get_professor_research_completed_count() -> int:
	return professor_research.get_completed_count() if _is_professor_research_unlocked() else 0


func has_professor_hub_attention(unix_time := -1.0) -> bool:
	return bool(get_professor_hub_state(unix_time).get("attention_required", false))


func mark_professor_story_seen(expected_chapter_id := "") -> bool:
	_activate_professor_story_if_eligible(false)
	if not professor_story.mark_seen(expected_chapter_id):
		return false
	_sync_professor_story_storage()
	story_chapter_changed.emit(active_story_chapter_id, get_professor_story_state())
	return true


func claim_professor_story_reward(expected_chapter_id := "") -> Dictionary:
	var state := get_professor_story_state()
	var active_chapter := str(state.get("chapter_id", ""))
	var requested_chapter := expected_chapter_id.strip_edges()
	if requested_chapter.is_empty():
		requested_chapter = active_chapter
	if not professor_story.has_chapter_id(requested_chapter):
		return {"success": false, "reason": "invalid_chapter", "chapter_id": requested_chapter}
	if requested_chapter != active_chapter:
		return {
			"success": false,
			"reason": "already_claimed" if professor_story.is_chapter_claimed(requested_chapter) else "stale_chapter",
			"chapter_id": requested_chapter,
		}
	if not bool(state.get("can_claim", false)):
		return {
			"success": false,
			"reason": str(state.get("claim_blocked_reason", "incomplete")),
			"chapter_id": requested_chapter,
		}
	if requested_chapter == ProfessorStoryScene.THIRD_CHAPTER_ID:
		return _claim_grand_herbarium_story_reward(state, requested_chapter)
	if requested_chapter == ProfessorStoryScene.SECOND_CHAPTER_ID:
		return _claim_silver_sage_story_reward(state, requested_chapter)
	return _claim_first_story_reward(state, requested_chapter)


func _claim_first_story_reward(state: Dictionary, chapter_id: String) -> Dictionary:
	if not _can_grant_botanical_pack("professor_story", ProfessorStoryScene.CHAPTER_ID, true):
		return {"success": false, "reason": "pack_unavailable", "chapter_id": chapter_id}

	# The pack is created before any economic reward. All mutable pack fields are
	# snapshotted so even an unexpected grant/claim failure remains atomic.
	var previous_story := professor_story.get_story_chapters()
	var previous_active_chapter := professor_story.get_active_chapter_id()
	var previous_packs := pending_botanical_packs.duplicate(true)
	var previous_next_pack_id := next_botanical_pack_id
	var previous_rng_state := botanical_pack_rng_state
	var previous_pity := botanical_pack_pity
	var pack := _grant_botanical_pack("professor_story", chapter_id, false, true)
	if pack.is_empty() or not professor_story.mark_claimed(chapter_id):
		pending_botanical_packs = previous_packs
		next_botanical_pack_id = previous_next_pack_id
		botanical_pack_rng_state = previous_rng_state
		botanical_pack_pity = previous_pity
		professor_story.load_state(previous_story, previous_active_chapter, journey_completed, PROFESSOR_STORY_CHAPTER_THREE_SCHEMA, get_available_species())
		_sync_professor_story_storage()
		return {"success": false, "reason": "atomic_claim_failed", "chapter_id": chapter_id}

	_sync_professor_story_storage()
	_change_coins(ProfessorStoryScene.REWARD_COINS, "professor_story")
	_grant_xp(ProfessorStoryScene.REWARD_XP, "professor_story")
	feedback_requested.emit("botanical_pack_granted", selected_plant_index, pack.duplicate(true))
	var reward: Dictionary = (state.get("reward", {}) as Dictionary).duplicate(true)
	reward["seal_count"] = get_professor_seal_count()
	var result := {
		"success": true,
		"reason": "",
		"chapter_id": chapter_id,
		"reward": reward.duplicate(true),
		"pack": pack.duplicate(true),
	}
	feedback_requested.emit("story_reward", selected_plant_index, result.duplicate(true))
	event_created.emit("Profesorův výzkum dokončen: 75 mincí, 60 XP, botanický balíček a Profesorova pečeť.")
	_emit_story_chapter_unlock_if_needed(chapter_id)
	story_chapter_changed.emit(active_story_chapter_id, get_professor_story_state())
	return result


func _claim_silver_sage_story_reward(state: Dictionary, chapter_id: String) -> Dictionary:
	var species_id := ProfessorStoryScene.SECOND_REWARD_SPECIES_ID
	var seed_reward := ProfessorStoryScene.SECOND_REWARD_SEEDS
	if not plant_profiles.has(species_id) or get_seed_count(species_id) > MAX_SEEDS_PER_SPECIES - seed_reward:
		return {"success": false, "reason": "seed_capacity", "chapter_id": chapter_id}

	# Seed capacity is preflighted, then all authoritative fields that can change
	# while discovering the reward species are snapshotted for a full rollback.
	var previous_story := professor_story.get_story_chapters()
	var previous_active_chapter := professor_story.get_active_chapter_id()
	var previous_seed_inventory := seed_inventory.duplicate(true)
	var previous_species_progress := species_progress.duplicate(true)
	var previous_pity := botanical_pack_pity
	var previous_coins := coins
	var previous_xp := xp
	seed_inventory[species_id] = get_seed_count(species_id) + seed_reward
	var sage_progress := get_species_progress(species_id)
	sage_progress["discovered"] = true
	species_progress[species_id] = sage_progress
	_normalize_botanical_pack_pity_after_discovery()
	if not professor_story.mark_claimed(chapter_id):
		seed_inventory = previous_seed_inventory
		species_progress = previous_species_progress
		botanical_pack_pity = previous_pity
		coins = previous_coins
		xp = previous_xp
		professor_story.load_state(previous_story, previous_active_chapter, journey_completed, PROFESSOR_STORY_CHAPTER_THREE_SCHEMA, get_available_species())
		_sync_professor_story_storage()
		return {"success": false, "reason": "atomic_claim_failed", "chapter_id": chapter_id}

	_sync_professor_story_storage()
	_change_coins(ProfessorStoryScene.SECOND_REWARD_COINS, "professor_story")
	_grant_xp(ProfessorStoryScene.SECOND_REWARD_XP, "professor_story")
	var reward: Dictionary = (state.get("reward", {}) as Dictionary).duplicate(true)
	reward["seal_count"] = get_professor_seal_count()
	var result := {
		"success": true,
		"reason": "",
		"chapter_id": chapter_id,
		"reward": reward.duplicate(true),
		"seeds": {species_id: seed_reward},
		"seed_total": get_seed_count(species_id),
	}
	feedback_requested.emit("story_reward", selected_plant_index, result.duplicate(true))
	event_created.emit("Odkaz stříbrné šalvěje je obnoven: 100 mincí, 80 XP, 2 semínka šalvěje a Profesorova pečeť.")
	_emit_story_chapter_unlock_if_needed(chapter_id)
	story_chapter_changed.emit(active_story_chapter_id, get_professor_story_state())
	return result


func _claim_grand_herbarium_story_reward(state: Dictionary, chapter_id: String) -> Dictionary:
	# The finale has no capacity-bound item, but keep all authoritative fields in
	# one rollback set so a stale or repeated expected id can never grant a
	# partial economic reward or title.
	var previous_story := professor_story.get_story_chapters()
	var previous_active_chapter := professor_story.get_active_chapter_id()
	var previous_coins := coins
	var previous_xp := xp
	var previous_fertilizer_doses := fertilizer_doses
	if not professor_story.mark_claimed(chapter_id):
		coins = previous_coins
		xp = previous_xp
		fertilizer_doses = previous_fertilizer_doses
		professor_story.load_state(previous_story, previous_active_chapter, journey_completed, PROFESSOR_STORY_CHAPTER_THREE_SCHEMA, get_available_species())
		_sync_professor_story_storage()
		return {"success": false, "reason": "atomic_claim_failed", "chapter_id": chapter_id}

	_sync_professor_story_storage()
	_change_coins(ProfessorStoryScene.THIRD_REWARD_COINS, "professor_story")
	_grant_xp(ProfessorStoryScene.THIRD_REWARD_XP, "professor_story")
	fertilizer_doses += ProfessorStoryScene.THIRD_REWARD_FERTILIZER
	var reward: Dictionary = (state.get("reward", {}) as Dictionary).duplicate(true)
	reward["seal_count"] = get_professor_seal_count()
	var result := {
		"success": true,
		"reason": "",
		"chapter_id": chapter_id,
		"reward": reward.duplicate(true),
		"fertilizer": ProfessorStoryScene.THIRD_REWARD_FERTILIZER,
		"fertilizer_total": fertilizer_doses,
		"title_id": get_professor_title_id(),
		"title": get_professor_title(),
	}
	feedback_requested.emit("story_reward", selected_plant_index, result.duplicate(true))
	event_created.emit("Velká herbářová výstava je připravena: 150 mincí, 120 XP, 3 dávky hnojiva, titul MISTR HERBÁŘE a Profesorova pečeť.")
	story_chapter_changed.emit(active_story_chapter_id, get_professor_story_state())
	return result


func consume_story_progress_events() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for progress_event in _story_progress_events:
		result.append(progress_event.duplicate(true))
	_story_progress_events.clear()
	return result


func consume_story_return_summary_text() -> String:
	var result := ""
	for line in _story_return_summary_lines:
		if not result.is_empty():
			result += "\n"
		result += line
	_story_return_summary_lines.clear()
	return result


func _sync_professor_story_storage() -> void:
	story_chapters = professor_story.get_story_chapters()
	active_story_chapter_id = professor_story.get_active_chapter_id()


func _activate_professor_story_if_eligible(emit_event := true) -> bool:
	if not professor_story.ensure_unlocked(journey_completed):
		return false
	_sync_professor_story_storage()
	if emit_event:
		var unlock_event := {
			"chapter_id": active_story_chapter_id,
			"goal_id": "",
			"kind": "chapter_unlocked",
			"current": 0,
			"target": professor_story.get_chapter_goal_count(active_story_chapter_id),
			"completed": false,
			"message": "Profesor Bazal otevřel výzkum %s." % professor_story.get_chapter_title(active_story_chapter_id),
		}
		_record_professor_story_event(unlock_event)
	return true


func _emit_story_chapter_unlock_if_needed(claimed_chapter_id: String) -> void:
	_sync_professor_story_storage()
	var expected_next_chapter := ""
	if claimed_chapter_id == ProfessorStoryScene.CHAPTER_ID:
		expected_next_chapter = ProfessorStoryScene.SECOND_CHAPTER_ID
	elif claimed_chapter_id == ProfessorStoryScene.SECOND_CHAPTER_ID:
		expected_next_chapter = ProfessorStoryScene.THIRD_CHAPTER_ID
	if expected_next_chapter.is_empty() or active_story_chapter_id != expected_next_chapter:
		return
	_record_professor_story_event({
		"chapter_id": active_story_chapter_id,
		"goal_id": "",
		"kind": "chapter_unlocked",
		"current": 0,
		"target": professor_story.get_chapter_goal_count(active_story_chapter_id),
		"completed": false,
		"message": "Profesor Bazal otevřel výzkum %s." % professor_story.get_chapter_title(active_story_chapter_id),
	})


func _record_professor_story_event(progress_event: Dictionary, add_to_return_summary := false) -> void:
	if progress_event.is_empty():
		return
	_sync_professor_story_storage()
	var event_copy := progress_event.duplicate(true)
	var state := get_professor_story_state()
	event_copy["chapter_ready"] = bool(state.get("can_claim", false)) or str(state.get("status", "")) == "ready"
	_story_progress_events.append(event_copy)
	story_progressed.emit(event_copy.duplicate(true))
	feedback_requested.emit("story_progress", selected_plant_index, event_copy.duplicate(true))
	var message := str(event_copy.get("message", ""))
	if not message.is_empty():
		event_created.emit(message)
		if add_to_return_summary:
			_story_return_summary_lines.append(message)
	story_chapter_changed.emit(active_story_chapter_id, state)


func _is_professor_research_unlocked() -> bool:
	return professor_story.is_chapter_claimed(ProfessorStoryScene.THIRD_CHAPTER_ID)


func _record_professor_research_event(progress_event: Dictionary) -> void:
	if progress_event.is_empty() or not _is_professor_research_unlocked():
		return
	var event_copy := progress_event.duplicate(true)
	event_copy["mode"] = "research"
	event_copy["content_kind"] = "weekly_research"
	event_copy["system_id"] = ProfessorResearchScene.SYSTEM_ID
	var state := get_professor_hub_state()
	event_copy["chapter_ready"] = bool(state.get("can_claim", false)) or str(state.get("status", "")) == "ready"
	_story_progress_events.append(event_copy)
	story_progressed.emit(event_copy.duplicate(true))
	feedback_requested.emit("professor_research_progress", selected_plant_index, event_copy.duplicate(true))
	var message := str(event_copy.get("message", ""))
	if not message.is_empty():
		event_created.emit(message)
	story_chapter_changed.emit(ProfessorResearchScene.SYSTEM_ID, state)


func _discover_species(species_id: String) -> bool:
	if not plant_profiles.has(species_id):
		return false
	var previous_collection_discoveries := get_discovered_species_count()
	var progress := get_species_progress(species_id)
	if bool(progress.get("discovered", false)):
		return false
	progress["discovered"] = true
	species_progress[species_id] = progress
	_normalize_botanical_pack_pity_after_discovery()
	var current_collection_discoveries := get_discovered_species_count()
	if current_collection_discoveries > previous_collection_discoveries:
		_activate_professor_story_if_eligible(false)
		_record_professor_story_event(professor_story.make_discovery_event(
			current_collection_discoveries,
			get_collection_species_ids().size()
		))
	return true


func _normalize_botanical_pack_pity_after_discovery() -> void:
	if botanical_pack_pity <= 0:
		return
	var eligible := _get_botanical_pack_eligible_species_ids()
	if _get_ungranted_botanical_pack_species_ids(eligible).is_empty():
		botanical_pack_pity = 0


func _ensure_species_progress(stored_progress: Dictionary = {}) -> void:
	var normalized: Dictionary = {}
	for species_id in get_available_species():
		var stored: Dictionary = stored_progress.get(species_id, {}) if stored_progress.get(species_id, {}) is Dictionary else {}
		normalized[species_id] = {
			"discovered": bool(stored.get("discovered", false)) or species_id == "basil_genovese" or get_seed_count(species_id) > 0,
			"harvests": _sanitize_nonnegative_int(stored.get("harvests", 0), 0),
			"best_quality": clampf(_sanitize_finite_float(stored.get("best_quality", 0.0), 0.0), 0.0, 1.0),
			"orders_completed": _sanitize_nonnegative_int(stored.get("orders_completed", 0), 0),
			"total_dry_g": maxf(0.0, _sanitize_finite_float(stored.get("total_dry_g", 0.0), 0.0)),
			"claimed_tier": clampi(_sanitize_int(stored.get("claimed_tier", 1), 1), 1, MASTERY_TIERS.size()),
		}
	species_progress = normalized


func get_species_progress(species_id: String) -> Dictionary:
	if not species_progress.has(species_id):
		_ensure_species_progress(species_progress)
	return (species_progress.get(species_id, {}) as Dictionary).duplicate(true)


func get_mastery_tier(species_id: String) -> int:
	var progress := get_species_progress(species_id)
	var achieved := 1
	for requirement in MASTERY_TIERS:
		if int(progress.get("harvests", 0)) < int(requirement.get("harvests", 0)):
			break
		if float(progress.get("best_quality", 0.0)) + 0.0001 < float(requirement.get("quality", 0.0)):
			break
		if int(progress.get("orders_completed", 0)) < int(requirement.get("orders", 0)):
			break
		achieved = int(requirement.get("tier", achieved))
	return achieved


func _get_mastery_species_count(minimum_tier: int) -> int:
	var mastered := 0
	for species_id in get_collection_species_ids():
		if is_species_discovered(species_id) and get_mastery_tier(species_id) >= minimum_tier:
			mastered += 1
	return mastered


func get_mastery_tier_data(tier: int) -> Dictionary:
	return (MASTERY_TIERS[clampi(tier, 1, MASTERY_TIERS.size()) - 1] as Dictionary).duplicate(true)


func get_mastery_progress_ratio(species_id: String) -> float:
	var achieved := get_mastery_tier(species_id)
	if achieved >= MASTERY_TIERS.size():
		return 1.0
	var progress := get_species_progress(species_id)
	var next_requirement: Dictionary = MASTERY_TIERS[achieved]
	var ratios: Array[float] = []
	var harvest_target := int(next_requirement.get("harvests", 0))
	var quality_target := float(next_requirement.get("quality", 0.0))
	var order_target := int(next_requirement.get("orders", 0))
	if harvest_target > 0:
		ratios.append(clampf(float(progress.get("harvests", 0)) / float(harvest_target), 0.0, 1.0))
	if quality_target > 0.0:
		ratios.append(clampf(float(progress.get("best_quality", 0.0)) / quality_target, 0.0, 1.0))
	if order_target > 0:
		ratios.append(clampf(float(progress.get("orders_completed", 0)) / float(order_target), 0.0, 1.0))
	var result := 1.0
	for ratio in ratios:
		result = minf(result, ratio)
	return result


func get_mastery_goal_text(species_id: String) -> String:
	var achieved := get_mastery_tier(species_id)
	if achieved >= MASTERY_TIERS.size():
		return "Všechny cíle splněny — tahle bylinka je mistrovsky zvládnutá."
	var progress := get_species_progress(species_id)
	var next_requirement: Dictionary = MASTERY_TIERS[achieved]
	return "Další hodnost: %s · sklizně %d/%d · kvalita %d/%d%% · zakázky %d/%d" % [
		str(next_requirement.get("title", "")),
		int(progress.get("harvests", 0)), int(next_requirement.get("harvests", 0)),
		roundi(float(progress.get("best_quality", 0.0)) * 100.0), roundi(float(next_requirement.get("quality", 0.0)) * 100.0),
		int(progress.get("orders_completed", 0)), int(next_requirement.get("orders", 0)),
	]


func can_claim_mastery_reward(species_id: String) -> bool:
	var progress := get_species_progress(species_id)
	return int(progress.get("claimed_tier", 1)) < get_mastery_tier(species_id)


func claim_mastery_reward(species_id: String) -> bool:
	if not can_claim_mastery_reward(species_id):
		return false
	var progress := get_species_progress(species_id)
	var claimed_tier := int(progress.get("claimed_tier", 1)) + 1
	var reward := get_mastery_tier_data(claimed_tier)
	var reward_coins := int(reward.get("coins", 0))
	var reward_xp := int(reward.get("xp", 0))
	var reward_seeds := int(reward.get("seeds", 0))
	# A mastery claim is one transaction. Do not consume the tier or grant the
	# other rewards when its seed component cannot fit in the bounded inventory.
	if reward_seeds > MAX_SEEDS_PER_SPECIES - get_seed_count(species_id):
		return false
	progress["claimed_tier"] = claimed_tier
	species_progress[species_id] = progress
	var granted_reward_seeds := 0
	_change_coins(reward_coins, "mastery_reward")
	_grant_xp(reward_xp, "mastery_reward")
	if reward_seeds > 0:
		var previous_seed_count := get_seed_count(species_id)
		if _change_seed_count(species_id, reward_seeds):
			granted_reward_seeds = get_seed_count(species_id) - previous_seed_count
	var species_name := str(get_plant_profile(species_id).get("display_name", "Bylinka"))
	event_created.emit("%s získává hodnost %s! Odměna: %d mincí, %d XP%s." % [species_name, str(reward.get("title", "")), reward_coins, reward_xp, " a %d semínko" % granted_reward_seeds if granted_reward_seeds == 1 else (" a %d semínka" % granted_reward_seeds if granted_reward_seeds > 1 else "")])
	feedback_requested.emit("mastery_reward", selected_plant_index, {"species_id": species_id, "tier": claimed_tier, "coins": reward_coins, "xp": reward_xp, "seeds": granted_reward_seeds})
	return true


func _record_species_harvest(species_id: String, quality: float) -> void:
	var previous_mastery_count := _get_mastery_species_count(ProfessorStoryScene.THIRD_MASTERY_TIER)
	var progress := get_species_progress(species_id)
	progress["discovered"] = true
	progress["harvests"] = int(progress.get("harvests", 0)) + 1
	progress["best_quality"] = maxf(float(progress.get("best_quality", 0.0)), clampf(quality, 0.0, 1.0))
	species_progress[species_id] = progress
	var current_mastery_count := _get_mastery_species_count(ProfessorStoryScene.THIRD_MASTERY_TIER)
	if current_mastery_count > previous_mastery_count:
		_record_professor_story_event(professor_story.make_mastery_event(current_mastery_count, get_collection_species_ids().size()))


func _record_species_delivery(species_id: String, dry_g: float, through_order: bool) -> void:
	var previous_mastery_count := _get_mastery_species_count(ProfessorStoryScene.THIRD_MASTERY_TIER)
	var progress := get_species_progress(species_id)
	progress["discovered"] = true
	progress["total_dry_g"] = float(progress.get("total_dry_g", 0.0)) + maxf(0.0, dry_g)
	if through_order:
		progress["orders_completed"] = int(progress.get("orders_completed", 0)) + 1
	species_progress[species_id] = progress
	var current_mastery_count := _get_mastery_species_count(ProfessorStoryScene.THIRD_MASTERY_TIER)
	if current_mastery_count > previous_mastery_count:
		_record_professor_story_event(professor_story.make_mastery_event(current_mastery_count, get_collection_species_ids().size()))


func _initialize_seed_inventory_from_profile_defaults() -> void:
	seed_inventory = _build_starter_seed_inventory()


func _build_starter_seed_inventory() -> Dictionary:
	var starter_inventory: Dictionary = {}
	for species_id in get_available_species():
		starter_inventory[species_id] = _sanitize_seed_count(get_plant_profile(species_id).get("starter_seed_count", 0))
	return starter_inventory


func _sanitize_seed_count(raw_count: Variant) -> int:
	if raw_count is bool or not (raw_count is int or raw_count is float):
		return 0
	if raw_count is float:
		var numeric_count := float(raw_count)
		if not is_finite(numeric_count) or numeric_count != floor(numeric_count):
			return 0
		if numeric_count <= 0.0:
			return 0
		if numeric_count >= float(MAX_SEEDS_PER_SPECIES):
			return MAX_SEEDS_PER_SPECIES
		return int(numeric_count)
	return clampi(int(raw_count), 0, MAX_SEEDS_PER_SPECIES)


func _sanitize_current_seed_inventory(raw_inventory: Variant) -> Dictionary:
	if not raw_inventory is Dictionary:
		return _build_starter_seed_inventory()
	var source: Dictionary = raw_inventory as Dictionary
	var sanitized: Dictionary = {}
	for species_id in get_available_species():
		sanitized[species_id] = _sanitize_seed_count(source.get(species_id, 0))
	# Preserve a small bounded set of canonical future species IDs across a
	# downgrade/upgrade cycle. They remain opaque to gameplay until the catalog
	# actually contains the same ID.
	var opaque_counts: Dictionary = {}
	for raw_species_id in source:
		if not (raw_species_id is String or raw_species_id is StringName):
			continue
		var species_id := str(raw_species_id)
		if plant_profiles.has(species_id) or not _is_canonical_seed_species_id(species_id):
			continue
		var opaque_count := _sanitize_seed_count(source.get(raw_species_id, 0))
		if opaque_count <= 0:
			continue
		opaque_counts[species_id] = maxi(int(opaque_counts.get(species_id, 0)), opaque_count)
	var opaque_ids: Array[String] = []
	for species_id in opaque_counts:
		opaque_ids.append(str(species_id))
	opaque_ids.sort()
	for index in range(mini(opaque_ids.size(), MAX_OPAQUE_SEED_SPECIES)):
		var species_id := opaque_ids[index]
		sanitized[species_id] = int(opaque_counts[species_id])
	return sanitized


func _is_canonical_seed_species_id(species_id: String) -> bool:
	if species_id.is_empty() or species_id.length() > MAX_SEED_SPECIES_ID_LENGTH:
		return false
	for index in range(species_id.length()):
		var code := species_id.unicode_at(index)
		if not ((code >= 97 and code <= 122) or (code >= 48 and code <= 57) or code == 95):
			return false
	return true


func _migrate_legacy_seed_inventory(data: Dictionary) -> Dictionary:
	var migrated := _build_starter_seed_inventory()
	var legacy_fields := {
		"basil_genovese": "seeds",
		"mint_peppermint": "mint_seeds",
		"rosemary_officinalis": "rosemary_seeds",
		"oregano_vulgare": "oregano_seeds",
	}
	var legacy_defaults := {
		"basil_genovese": 1,
		"mint_peppermint": 1,
		"rosemary_officinalis": 0,
		"oregano_vulgare": 0,
	}
	# Preserve every historical positive balance even when an old single-profile
	# caller does not currently load that species. Such entries stay opaque until
	# the corresponding catalog profile is available again.
	for species_id in legacy_fields:
		var legacy_field := str(legacy_fields[species_id])
		var count := _sanitize_seed_count(data.get(legacy_field, legacy_defaults[species_id]))
		if plant_profiles.has(species_id) or count > 0:
			migrated[species_id] = count
	return migrated


func get_seed_count(species_id: String) -> int:
	if not plant_profiles.has(species_id):
		return 0
	return _sanitize_seed_count(seed_inventory.get(species_id, 0))


func get_total_seed_count() -> int:
	var total := 0
	for species_id in get_available_species():
		total += get_seed_count(species_id)
	return total


func get_seed_inventory_snapshot() -> Dictionary:
	var sanitized := _sanitize_current_seed_inventory(seed_inventory)
	var sorted_ids: Array[String] = []
	for raw_species_id in sanitized:
		sorted_ids.append(str(raw_species_id))
	sorted_ids.sort()
	var snapshot: Dictionary = {}
	for species_id in sorted_ids:
		snapshot[species_id] = int(sanitized[species_id])
	return snapshot.duplicate(true)


func set_seed_count(species_id: String, count: int) -> bool:
	if not plant_profiles.has(species_id):
		return false
	seed_inventory[species_id] = clampi(count, 0, MAX_SEEDS_PER_SPECIES)
	if get_seed_count(species_id) > 0:
		_discover_species(species_id)
	return true


func grant_seeds(species_id: String, amount: int) -> bool:
	if amount <= 0:
		return false
	return _change_seed_count(species_id, amount)


func get_botanical_pack_count() -> int:
	return pending_botanical_packs.size()


func get_botanical_pack_odds() -> Dictionary:
	var eligible := _get_botanical_pack_eligible_species_ids()
	var new_species := _get_ungranted_botanical_pack_species_ids(eligible)
	var odds_pool := new_species if botanical_pack_pity >= BOTANICAL_PACK_PITY_DUPLICATES and not new_species.is_empty() else eligible
	var active_rarities: Array[String] = []
	var total_weight := 0
	for rarity_id in BOTANICAL_PACK_RARITY_ORDER:
		if int(BOTANICAL_PACK_RARITY_WEIGHTS.get(rarity_id, 0)) <= 0:
			continue
		if _pack_pool_has_rarity(odds_pool, rarity_id):
			active_rarities.append(rarity_id)
			total_weight += int(BOTANICAL_PACK_RARITY_WEIGHTS[rarity_id])
	var odds: Dictionary = {}
	var assigned_percent := 0.0
	for rarity_id in BOTANICAL_PACK_RARITY_ORDER:
		if rarity_id not in active_rarities or total_weight <= 0:
			odds[rarity_id] = 0.0
			continue
		if rarity_id == active_rarities.back():
			odds[rarity_id] = 100.0 - assigned_percent
		else:
			var percent := 100.0 * float(BOTANICAL_PACK_RARITY_WEIGHTS[rarity_id]) / float(total_weight)
			odds[rarity_id] = percent
			assigned_percent += percent
	return odds


func get_botanical_pack_state() -> Dictionary:
	var eligible := _get_botanical_pack_eligible_species_ids()
	var ungranted_new := _get_ungranted_botanical_pack_species_ids(eligible)
	var next_openable_pack_id := -1
	var blocked_unknown_count := 0
	var blocked_inventory_count := 0
	for pack in pending_botanical_packs:
		var species_id := str(pack.get("species_id", ""))
		if not plant_profiles.has(species_id):
			blocked_unknown_count += 1
			continue
		if get_seed_count(species_id) >= MAX_SEEDS_PER_SPECIES:
			blocked_inventory_count += 1
			continue
		if next_openable_pack_id < 0:
			next_openable_pack_id = int(pack.get("pack_id", -1))
	var blocked_reason := ""
	if next_openable_pack_id < 0 and not pending_botanical_packs.is_empty():
		blocked_reason = "inventory_full" if blocked_inventory_count > 0 else "unknown_species"
	return {
		"count": get_botanical_pack_count(),
		"capacity": MAX_PENDING_BOTANICAL_PACKS,
		"pending": pending_botanical_packs.duplicate(true),
		"can_open": next_openable_pack_id > 0,
		"next_openable_pack_id": next_openable_pack_id,
		"blocked_unknown_count": blocked_unknown_count,
		"blocked_inventory_count": blocked_inventory_count,
		"blocked_reason": blocked_reason,
		"odds": get_botanical_pack_odds(),
		"pity": botanical_pack_pity,
		"pity_threshold": BOTANICAL_PACK_PITY_DUPLICATES,
		"duplicates_until_guaranteed_new": 0 if ungranted_new.is_empty() else maxi(0, BOTANICAL_PACK_PITY_DUPLICATES - botanical_pack_pity),
		"next_grant_guaranteed_new": not ungranted_new.is_empty() and botanical_pack_pity >= BOTANICAL_PACK_PITY_DUPLICATES,
		"eligible_species_count": eligible.size(),
		"ungranted_new_species_count": ungranted_new.size(),
		"queue_full": pending_botanical_packs.size() >= MAX_PENDING_BOTANICAL_PACKS,
	}


func open_botanical_pack(pack_id: int) -> Dictionary:
	if pack_id <= 0:
		return {}
	var pack_index := -1
	for index in range(pending_botanical_packs.size()):
		if int(pending_botanical_packs[index].get("pack_id", 0)) == pack_id:
			pack_index = index
			break
	if pack_index < 0:
		return {}
	var pack: Dictionary = pending_botanical_packs[pack_index]
	var species_id := str(pack.get("species_id", ""))
	# A granted pack is sealed. Catalog rarity and acquisition-source changes may
	# affect future rolls, but must never rewrite or invalidate this stored result.
	# A canonical future outcome therefore stays pending until its profile exists.
	if not _is_canonical_seed_species_id(species_id) or not plant_profiles.has(species_id):
		return {}
	if not _is_exact_botanical_pack_integer(pack.get("seed_count"), BOTANICAL_PACK_SEED_COUNT):
		return {}
	if get_seed_count(species_id) >= MAX_SEEDS_PER_SPECIES:
		return {}
	var was_discovered := is_species_discovered(species_id)
	if not grant_seeds(species_id, BOTANICAL_PACK_SEED_COUNT):
		return {}
	pending_botanical_packs.remove_at(pack_index)
	var result := pack.duplicate(true)
	result["success"] = true
	result["newly_discovered"] = not was_discovered and is_species_discovered(species_id)
	result["seed_total"] = get_seed_count(species_id)
	_activate_professor_story_if_eligible(false)
	_record_professor_story_event(professor_story.record_opened_pack())
	feedback_requested.emit("botanical_pack_opened", selected_plant_index, result.duplicate(true))
	event_created.emit("Botanický balíček ukrýval 1× %s." % str(get_plant_profile(species_id).get("short_name", species_id)))
	return result


func _grant_botanical_pack(source_id: String, source_token: String, emit_feedback := true, guarantee_new := false) -> Dictionary:
	if not _can_grant_botanical_pack(source_id, source_token, guarantee_new):
		return {}
	var eligible := _get_botanical_pack_eligible_species_ids()
	var ungranted_new := _get_ungranted_botanical_pack_species_ids(eligible)
	var force_new := not ungranted_new.is_empty() and (guarantee_new or botanical_pack_pity >= BOTANICAL_PACK_PITY_DUPLICATES)
	var outcome := _roll_botanical_pack_outcome(ungranted_new if force_new else eligible, force_new)
	if outcome.is_empty():
		return {}
	var was_new := bool(outcome.get("was_new", false))
	var pack := {
		"pack_id": next_botanical_pack_id,
		"source_id": source_id,
		"source_token": source_token,
		"species_id": str(outcome.get("species_id", "")),
		"seed_count": BOTANICAL_PACK_SEED_COUNT,
		"rolled_rarity": str(outcome.get("rolled_rarity", "common")),
		"roll_version": BOTANICAL_PACK_ROLL_VERSION,
		"was_new_when_granted": was_new,
	}
	next_botanical_pack_id += 1
	pending_botanical_packs.append(pack.duplicate(true))
	if ungranted_new.is_empty() or was_new:
		botanical_pack_pity = 0
	else:
		botanical_pack_pity = mini(BOTANICAL_PACK_PITY_DUPLICATES, botanical_pack_pity + 1)
	if emit_feedback:
		feedback_requested.emit("botanical_pack_granted", selected_plant_index, pack.duplicate(true))
	return pack.duplicate(true)


func _can_grant_botanical_pack(source_id: String, source_token: String, guarantee_new := false) -> bool:
	if pending_botanical_packs.size() >= MAX_PENDING_BOTANICAL_PACKS:
		return false
	if not _is_canonical_botanical_pack_source_id(source_id) or not _is_canonical_botanical_pack_source_token(source_token):
		return false
	if next_botanical_pack_id <= 0 or next_botanical_pack_id > MAX_BOTANICAL_PACK_ID:
		return false
	var eligible := _get_botanical_pack_eligible_species_ids()
	var ungranted_new := _get_ungranted_botanical_pack_species_ids(eligible)
	var candidates := ungranted_new if guarantee_new and not ungranted_new.is_empty() else eligible
	for rarity_id in BOTANICAL_PACK_RARITY_ORDER:
		if int(BOTANICAL_PACK_RARITY_WEIGHTS.get(rarity_id, 0)) > 0 and _pack_pool_has_rarity(candidates, rarity_id):
			return true
	return false


func _roll_botanical_pack_outcome(candidate_species: Array[String], force_new: bool) -> Dictionary:
	if candidate_species.is_empty():
		return {}
	var active_rarities: Array[String] = []
	var total_weight := 0
	for rarity_id in BOTANICAL_PACK_RARITY_ORDER:
		var weight := int(BOTANICAL_PACK_RARITY_WEIGHTS.get(rarity_id, 0))
		if weight <= 0 or not _pack_pool_has_rarity(candidate_species, rarity_id):
			continue
		active_rarities.append(rarity_id)
		total_weight += weight
	if total_weight <= 0:
		return {}
	var rarity_roll := _next_botanical_pack_random(total_weight)
	var selected_rarity: String = active_rarities.back()
	var threshold := 0
	for rarity_id in active_rarities:
		threshold += int(BOTANICAL_PACK_RARITY_WEIGHTS[rarity_id])
		if rarity_roll < threshold:
			selected_rarity = rarity_id
			break
	var rarity_species: Array[String] = []
	for species_id in candidate_species:
		if get_species_rarity_id(species_id) == selected_rarity:
			rarity_species.append(species_id)
	rarity_species.sort()
	if not force_new:
		var preferred_new := _get_ungranted_botanical_pack_species_ids(rarity_species)
		if not preferred_new.is_empty():
			rarity_species = preferred_new
	if rarity_species.is_empty():
		return {}
	var species_id := rarity_species[_next_botanical_pack_random(rarity_species.size())]
	return {
		"species_id": species_id,
		"rolled_rarity": selected_rarity,
		"was_new": species_id in _get_ungranted_botanical_pack_species_ids(_get_botanical_pack_eligible_species_ids()),
	}


func _next_botanical_pack_random(upper_exclusive: int) -> int:
	botanical_pack_rng_state = int((botanical_pack_rng_state * BOTANICAL_PACK_RNG_MULTIPLIER) % BOTANICAL_PACK_RNG_MODULUS)
	if botanical_pack_rng_state <= 0:
		botanical_pack_rng_state = BOTANICAL_PACK_DEFAULT_RNG_STATE
	return botanical_pack_rng_state % maxi(1, upper_exclusive)


func _get_botanical_pack_eligible_species_ids() -> Array[String]:
	var eligible: Array[String] = []
	for raw_species_id in plant_profiles:
		var species_id := str(raw_species_id)
		if _is_botanical_pack_species_eligible(species_id):
			eligible.append(species_id)
	eligible.sort()
	return eligible


func _is_botanical_pack_species_eligible(species_id: String) -> bool:
	if not plant_profiles.has(species_id):
		return false
	var profile: Dictionary = plant_profiles[species_id]
	if not bool(profile.get("collection_visible", true)):
		return false
	var acquisition_sources: Variant = profile.get("acquisition_sources", [])
	if not acquisition_sources is Array or "botanical_pack" not in acquisition_sources:
		return false
	var rarity_id := get_species_rarity_id(species_id)
	return int(BOTANICAL_PACK_RARITY_WEIGHTS.get(rarity_id, 0)) > 0


func _get_ungranted_botanical_pack_species_ids(candidate_species: Array[String]) -> Array[String]:
	var ungranted_new: Array[String] = []
	for species_id in candidate_species:
		if is_species_discovered(species_id) or _has_pending_botanical_pack_for_species(species_id):
			continue
		ungranted_new.append(species_id)
	ungranted_new.sort()
	return ungranted_new


func _has_pending_botanical_pack_for_species(species_id: String) -> bool:
	for pack in pending_botanical_packs:
		if str(pack.get("species_id", "")) == species_id:
			return true
	return false


func _pack_pool_has_rarity(candidate_species: Array[String], rarity_id: String) -> bool:
	for species_id in candidate_species:
		if get_species_rarity_id(species_id) == rarity_id:
			return true
	return false


func _is_canonical_botanical_pack_source_id(source_id: String) -> bool:
	if source_id.is_empty() or source_id.length() > MAX_BOTANICAL_PACK_SOURCE_ID_LENGTH:
		return false
	return _is_canonical_seed_species_id(source_id)


func _is_canonical_botanical_pack_source_token(source_token: String) -> bool:
	if source_token.is_empty() or source_token.length() > MAX_BOTANICAL_PACK_SOURCE_TOKEN_LENGTH:
		return false
	for index in range(source_token.length()):
		var code := source_token.unicode_at(index)
		if not ((code >= 97 and code <= 122) or (code >= 48 and code <= 57) or code in [45, 58, 95]):
			return false
	return true


func _sanitize_botanical_pack_integer(raw_value: Variant, minimum: int, maximum: int, fallback: int) -> int:
	if raw_value is bool or not (raw_value is int or raw_value is float):
		return fallback
	var numeric_value := float(raw_value)
	if not is_finite(numeric_value) or numeric_value != floor(numeric_value):
		return fallback
	return clampi(int(numeric_value), minimum, maximum)


func _is_exact_botanical_pack_integer(raw_value: Variant, expected: int) -> bool:
	if raw_value is bool or not (raw_value is int or raw_value is float):
		return false
	var numeric_value := float(raw_value)
	return is_finite(numeric_value) and numeric_value == float(expected)


func _sanitize_pending_botanical_packs(raw_packs: Variant) -> Array[Dictionary]:
	var candidates: Array[Dictionary] = []
	if not raw_packs is Array:
		return candidates
	var used_pack_ids: Dictionary = {}
	for raw_pack in raw_packs:
		if not raw_pack is Dictionary:
			continue
		var source: Dictionary = raw_pack
		var raw_pack_id: Variant = source.get("pack_id")
		if raw_pack_id is bool or not (raw_pack_id is int or raw_pack_id is float):
			continue
		var numeric_pack_id := float(raw_pack_id)
		if not is_finite(numeric_pack_id) or numeric_pack_id != floor(numeric_pack_id) or numeric_pack_id < 1.0 or numeric_pack_id > float(MAX_BOTANICAL_PACK_ID):
			continue
		var pack_id := int(numeric_pack_id)
		if used_pack_ids.has(pack_id):
			continue
		var raw_source_id: Variant = source.get("source_id")
		var raw_source_token: Variant = source.get("source_token")
		var raw_species_id: Variant = source.get("species_id")
		var raw_rarity_id: Variant = source.get("rolled_rarity")
		if not (raw_source_id is String or raw_source_id is StringName):
			continue
		if not (raw_source_token is String or raw_source_token is StringName):
			continue
		if not (raw_species_id is String or raw_species_id is StringName):
			continue
		if not (raw_rarity_id is String or raw_rarity_id is StringName):
			continue
		var source_id := str(raw_source_id).strip_edges()
		var source_token := str(raw_source_token).strip_edges()
		if not _is_canonical_botanical_pack_source_id(source_id) or not _is_canonical_botanical_pack_source_token(source_token):
			continue
		if not _is_exact_botanical_pack_integer(source.get("seed_count"), BOTANICAL_PACK_SEED_COUNT):
			continue
		if not _is_exact_botanical_pack_integer(source.get("roll_version"), BOTANICAL_PACK_ROLL_VERSION):
			continue
		var rarity_id := str(raw_rarity_id).strip_edges().to_lower()
		if rarity_id not in BOTANICAL_PACK_RARITY_ORDER:
			continue
		var species_id := str(raw_species_id).strip_edges()
		# Pending outcomes are immutable sealed records. Current eligibility and
		# current profile rarity constrain new grants only; they do not invalidate
		# an already granted known or canonical future species.
		if not _is_canonical_seed_species_id(species_id):
			continue
		used_pack_ids[pack_id] = true
		candidates.append({
			"pack_id": pack_id,
			"source_id": source_id,
			"source_token": source_token,
			"species_id": species_id,
			"seed_count": BOTANICAL_PACK_SEED_COUNT,
			"rolled_rarity": rarity_id,
			"roll_version": BOTANICAL_PACK_ROLL_VERSION,
			"was_new_when_granted": source.get("was_new_when_granted", false) if source.get("was_new_when_granted", false) is bool else false,
		})
		if candidates.size() >= MAX_PENDING_BOTANICAL_PACKS:
			break
	candidates.sort_custom(func(left: Dictionary, right: Dictionary) -> bool: return int(left["pack_id"]) < int(right["pack_id"]))
	return candidates


func _restore_botanical_pack_state(data: Dictionary, stored_schema: int) -> void:
	pending_botanical_packs.clear()
	next_botanical_pack_id = 1
	botanical_pack_rng_state = BOTANICAL_PACK_DEFAULT_RNG_STATE
	botanical_pack_pity = 0
	if stored_schema >= BOTANICAL_PACK_SCHEMA:
		pending_botanical_packs = _sanitize_pending_botanical_packs(data.get("pending_botanical_packs", []))
		var largest_pack_id := 0
		for pack in pending_botanical_packs:
			largest_pack_id = maxi(largest_pack_id, int(pack.get("pack_id", 0)))
		next_botanical_pack_id = _sanitize_botanical_pack_integer(
			data.get("next_botanical_pack_id"),
			largest_pack_id + 1,
			MAX_BOTANICAL_PACK_ID + 1,
			largest_pack_id + 1
		)
		botanical_pack_rng_state = _sanitize_botanical_pack_integer(
			data.get("botanical_pack_rng_state"),
			1,
			BOTANICAL_PACK_RNG_MODULUS - 1,
			BOTANICAL_PACK_DEFAULT_RNG_STATE
		)
		botanical_pack_pity = _sanitize_botanical_pack_integer(
			data.get("botanical_pack_pity"),
			0,
			BOTANICAL_PACK_PITY_DUPLICATES,
			0
		)
		if _get_ungranted_botanical_pack_species_ids(_get_botanical_pack_eligible_species_ids()).is_empty():
			botanical_pack_pity = 0
		return
	# Schemas 1–21 ignore every partially backported pack field. A completed
	# historical first journey receives exactly one deterministic welcome pack.
	if journey_completed or journey_reward_claimed:
		_grant_botanical_pack("legacy_journey", "welcome", false)


func get_minimum_seed_price() -> int:
	var minimum_price := 999999
	for species_id in get_botanist_shop_species_ids():
		var raw_profile: Variant = plant_profiles.get(species_id, {})
		if raw_profile is Dictionary:
			minimum_price = mini(minimum_price, maxi(0, int((raw_profile as Dictionary).get("seed_price", 12))))
	return 12 if minimum_price == 999999 else minimum_price


func get_shop_seed_item_id(species_id: String) -> String:
	return SHOP_SEED_ITEM_PREFIX + species_id


func get_shop_stock(item_id: String) -> int:
	refresh_shop_stock_for_unix()
	return maxi(0, int(shop_stock.get(item_id, 0)))


func get_shop_stock_capacity(item_id: String, day_index := -1) -> int:
	var effective_day := shop_stock_day if day_index < 0 else day_index
	if effective_day < 0:
		effective_day = _get_real_shop_day_index(Time.get_unix_time_from_system())
	return int(_build_shop_stock_for_day(effective_day).get(item_id, 0))


func refresh_shop_stock_for_unix(unix_time := -1.0) -> bool:
	var effective_unix := Time.get_unix_time_from_system() if unix_time < 0.0 else unix_time
	var current_day := _get_real_shop_day_index(effective_unix)
	if not shop_stock.is_empty() and current_day <= shop_stock_day:
		return false
	shop_stock_day = current_day
	shop_stock = _build_shop_stock_for_day(current_day)
	return true


func _get_real_shop_day_index(unix_time: float) -> int:
	var safe_unix := _sanitize_unix_time(unix_time, 0.0)
	return clampi(int(floor(safe_unix / SHOP_REAL_DAY_SECONDS)), 0, MAX_SUPPORTED_UTC_DAY)


func _build_shop_stock_for_day(day_index: int) -> Dictionary:
	var safe_day := clampi(day_index, 0, MAX_SUPPORTED_UTC_DAY)
	var stock: Dictionary = {}
	for species_id in get_botanist_shop_species_ids():
		var seed_profile := get_plant_profile(species_id)
		var base_stock := maxi(0, int(seed_profile.get("shop_stock_base", 0)))
		var raw_cycle: Variant = seed_profile.get("shop_stock_cycle", [])
		var cycle_bonus := 0
		if raw_cycle is Array and not raw_cycle.is_empty():
			cycle_bonus = maxi(0, int((raw_cycle as Array)[posmod(safe_day, raw_cycle.size())]))
		stock[get_shop_seed_item_id(species_id)] = base_stock + cycle_bonus
	stock[SHOP_FERTILIZER_ITEM_ID] = 3 + posmod(safe_day + 2, 2)
	return stock


func _consume_shop_stock(item_id: String) -> bool:
	if get_shop_stock(item_id) <= 0:
		return false
	shop_stock[item_id] = int(shop_stock.get(item_id, 0)) - 1
	return true


func get_world_day_index() -> int:
	return maxi(0, int(floor(world_elapsed_seconds / PlantSimulation.ENVIRONMENT_DAY_SECONDS)))


func get_world_day() -> int:
	return get_world_day_index() + 1


func get_world_weather() -> String:
	return PlantSimulation.get_weather_for_environment_seconds(world_elapsed_seconds)


func get_world_weather_for_day_offset(offset: int) -> String:
	var day_seconds := float(maxi(0, get_world_day_index() + offset)) * PlantSimulation.ENVIRONMENT_DAY_SECONDS
	return PlantSimulation.get_weather_for_environment_seconds(day_seconds)


func _ensure_daily_challenge() -> void:
	refresh_daily_challenge_for_unix()


func refresh_daily_challenge_for_unix(unix_time := -1.0) -> bool:
	var effective_unix := Time.get_unix_time_from_system() if unix_time < 0.0 else unix_time
	var current_real_day := _get_real_shop_day_index(effective_unix)
	var effective_real_day := maxi(current_real_day, maxi(daily_challenge_real_day, daily_challenge_last_claimed_real_day))
	if daily_challenge_id.is_empty():
		_issue_daily_challenge(effective_real_day)
		return true
	if effective_real_day > daily_challenge_real_day:
		_issue_daily_challenge(effective_real_day)
		return true
	return false


func _issue_daily_challenge(real_day: int) -> void:
	daily_challenge_issued_day = get_world_day_index()
	daily_challenge_real_day = maxi(0, real_day)
	daily_challenge_weather = get_world_weather()
	daily_challenge_forecast_weather = get_world_weather_for_day_offset(1)
	daily_challenge_id = _select_daily_challenge_id()
	daily_challenge_completed = false
	daily_challenge_claimed = false


func _select_daily_challenge_id() -> String:
	if get_occupied_count() == 0:
		return "plant"
	var has_growing := false
	var has_low_moisture := false
	var has_low_nutrients := false
	var has_lamp_off := false
	var has_wilted := false
	var has_treatable_disease := false
	var has_mature := false
	var has_harvested := false
	var has_drying_or_dry := false
	var has_packaged := false
	for slot_index in range(plants.size()):
		if not is_plant_slot_unlocked(slot_index):
			continue
		var slot := plants[slot_index]
		has_wilted = has_wilted or slot.is_wilted()
		has_treatable_disease = has_treatable_disease or slot.can_treat_disease()
		has_mature = has_mature or slot.stage == PlantSimulation.Stage.MATURE
		has_harvested = has_harvested or slot.stage == PlantSimulation.Stage.HARVESTED
		has_drying_or_dry = has_drying_or_dry or slot.stage in [PlantSimulation.Stage.DRYING, PlantSimulation.Stage.DRY]
		has_packaged = has_packaged or slot.stage == PlantSimulation.Stage.PACKAGED
		if slot.is_growing():
			has_growing = true
			has_low_moisture = has_low_moisture or slot.moisture <= 55.0
			has_low_nutrients = has_low_nutrients or slot.nutrients <= 60.0
			has_lamp_off = has_lamp_off or not slot.lamp_on
	if has_wilted:
		return "rescue"
	if has_treatable_disease and get_equipment_level("protective_spray") > 0:
		return "treat"
	if has_mature:
		return "harvest"
	if has_harvested:
		return "start_drying"
	if has_drying_or_dry:
		return "package"
	if has_packaged:
		return "sell"
	if daily_challenge_real_day % 2 == 0:
		var forecast_challenge := _select_forecast_daily_challenge(has_growing, has_low_moisture, has_lamp_off)
		if not forecast_challenge.is_empty():
			return forecast_challenge
	match get_world_weather():
		"Déšť":
			if has_growing:
				return "ventilate"
		"Zataženo":
			if has_lamp_off:
				return "lamp"
		"Větrno":
			if fertilizer_doses > 0 and has_low_nutrients:
				return "fertilize"
	if has_low_moisture:
		return "water"
	if has_lamp_off and get_world_weather() == "Zataženo":
		return "lamp"
	if has_growing:
		return "ventilate"
	return "plant"


func _select_forecast_daily_challenge(has_growing: bool, has_low_moisture: bool, has_lamp_off: bool) -> String:
	match daily_challenge_forecast_weather:
		"Déšť":
			if has_growing:
				return "prepare_rain"
		"Zataženo":
			if has_lamp_off:
				return "prepare_cloud"
		_:
			if has_low_moisture:
				return "prepare_dry"
	return ""


func _normalize_daily_challenge_id(value: String) -> String:
	match value:
		"ventilate_rain": return "ventilate"
		"lamp_cloudy": return "lamp"
		"fertilize_wind": return "fertilize"
		"water_clear": return "water"
		_:
			return value if value in DAILY_CHALLENGE_IDS else ""


func refresh_daily_challenge_context(unix_time := -1.0) -> bool:
	var changed := refresh_daily_challenge_for_unix(unix_time)
	if daily_challenge_completed or daily_challenge_claimed or get_daily_challenge_target_slot() >= 0:
		return changed
	var replacement := _select_daily_challenge_id()
	if replacement == daily_challenge_id:
		return changed
	daily_challenge_id = replacement
	return true


func get_daily_challenge_weather_summary() -> String:
	var issued_weather := daily_challenge_weather if daily_challenge_weather in DAILY_CHALLENGE_WEATHER_NAMES else get_world_weather()
	var forecast_weather := daily_challenge_forecast_weather if daily_challenge_forecast_weather in DAILY_CHALLENGE_WEATHER_NAMES else get_world_weather_for_day_offset(1)
	return "DEN %d  ·  DNES %s  ·  ZÍTRA %s" % [maxi(1, daily_challenge_issued_day + 1), issued_weather.to_upper(), forecast_weather.to_upper()]


func get_daily_challenge_target_slot() -> int:
	for slot_index in range(plants.size()):
		if not is_plant_slot_unlocked(slot_index):
			continue
		var slot := plants[slot_index]
		match daily_challenge_id:
			"plant":
				# A dead pot is a valid destination for the planting objective: the
				# player first clears it, then plants. Cleanup itself never grants the
				# daily reward, so failure cannot be farmed for currency or XP.
				if slot.stage in [PlantSimulation.Stage.EMPTY, PlantSimulation.Stage.DEAD]:
					return slot_index
			"treat":
				if get_equipment_level("protective_spray") > 0 and slot.can_treat_disease():
					return slot_index
			"rescue":
				if slot.is_wilted():
					return slot_index
			"harvest":
				if slot.stage == PlantSimulation.Stage.MATURE:
					return slot_index
			"start_drying":
				if slot.stage == PlantSimulation.Stage.HARVESTED:
					return slot_index
			"package":
				if slot.stage in [PlantSimulation.Stage.DRY, PlantSimulation.Stage.DRYING]:
					return slot_index
			"sell":
				if slot.stage == PlantSimulation.Stage.PACKAGED:
					return slot_index
			"water":
				if slot.is_growing() and slot.moisture <= 55.0:
					return slot_index
			"prepare_dry":
				if slot.is_growing() and slot.moisture <= 55.0:
					return slot_index
			"fertilize":
				if fertilizer_doses > 0 and slot.is_growing() and slot.nutrients <= 60.0:
					return slot_index
			"lamp":
				if slot.is_growing() and not slot.lamp_on:
					return slot_index
			"prepare_cloud":
				if slot.is_growing() and not slot.lamp_on:
					return slot_index
			"ventilate":
				if slot.is_growing():
					return slot_index
			"prepare_rain":
				if slot.is_growing():
					return slot_index
	return -1


func get_daily_challenge_target_screen() -> int:
	return 1 if daily_challenge_id in ["harvest", "start_drying", "package", "sell"] else 0


func get_daily_challenge_action_label() -> String:
	match daily_challenge_id:
		"plant":
			var target_slot := get_daily_challenge_target_slot()
			if target_slot >= 0 and plants[target_slot].stage == PlantSimulation.Stage.DEAD:
				return "VYČISTIT A ZASADIT"
			return "ZASADIT BYLINKU"
		"harvest", "start_drying", "package", "sell": return "OTEVŘÍT SKLAD"
		_: return "OTEVŘÍT ROSTLINU"


func get_daily_challenge_title() -> String:
	match daily_challenge_id:
		"plant": return "Probuď nový květináč"
		"rescue": return "Zachraň zvadlou bylinku"
		"treat": return "Zastav plíseň"
		"harvest": return "Sklizeň ve správný čas"
		"start_drying": return "Čerstvá sklizeň do sušárny"
		"package": return "Uzavři sušení"
		"sell": return "Balíček pro zákazníka"
		"prepare_rain": return "Připrav proudění na déšť"
		"prepare_cloud": return "Světlo na zítřejší mraky"
		"prepare_dry": return "Zásoba vláhy na zítřek"
		"ventilate": return "Vzduch po dešti"
		"lamp": return "Světlo skrz mraky"
		"fertilize": return "Výživa ve větrném dni"
		_: return "Chytrá zálivka"


func get_daily_challenge_body() -> String:
	match daily_challenge_id:
		"plant": return "Zasaď libovolnou bylinku. Prázdný květináč počasí opravdu neocení."
		"rescue": return "Nejdřív odstraň kritickou příčinu péčí a potom ostříhej poškozené listy. Odměnu získáš až po skutečné záchraně."
		"treat": return "Ošetři libovolnou nemocnou bylinku, jakmile je připravená na postřik."
		"harvest": return "Skliď libovolnou bylinku, která právě dosáhla plné zralosti."
		"start_drying": return "Přesuň čerstvě sklizenou bylinku do sušárny."
		"package": return "Dokonči sušení a zabal libovolnou usušenou bylinku ve Skladu."
		"sell": return "Prodej jeden zabalený balíček ve Skladu nebo panu Kořínkovi."
		"prepare_rain": return "Před zítřejším deštěm vyvětrej rostoucí bylinku a omez riziko vlhkého vzduchu."
		"prepare_cloud": return "Před zítřejším zataženým dnem zapni rostoucí bylince doplňkové světlo."
		"prepare_dry": return "Před zítřejším jasným nebo větrným dnem zalij bylinku, která má nejvýše 55% vláhy."
		"ventilate": return "Za deště vyvětrej rostoucí bylinku dřív, než vlhký vzduch pozve plíseň."
		"lamp": return "Při zatažené obloze zapni rostoucí bylince doplňkové světlo."
		"fertilize": return "Při větru přihnoj rostoucí bylinku, která má nejvýše 60% živin."
		_: return "Zalij rostoucí bylinku pouze tehdy, když má nejvýše 55% vláhy."


func get_daily_challenge_status() -> String:
	if daily_challenge_claimed:
		return "Dnešní odměna vyzvednuta"
	if daily_challenge_completed:
		return "Splněno — odměna čeká"
	return "Aktivní úkol"


func _try_complete_daily_challenge(action: String, valid_context: bool) -> void:
	refresh_daily_challenge_for_unix()
	if daily_challenge_completed or daily_challenge_claimed or action != _get_daily_challenge_required_action() or not valid_context:
		return
	daily_challenge_completed = true
	event_created.emit("Denní výzva splněna! V kartě dne čeká odměna.")
	feedback_requested.emit("daily_complete", selected_plant_index, {"challenge_id": daily_challenge_id, "day": get_world_day()})


func _get_daily_challenge_required_action() -> String:
	match daily_challenge_id:
		"rescue": return "rescue"
		"prepare_rain": return "ventilate"
		"prepare_cloud": return "lamp"
		"prepare_dry": return "water"
		_: return daily_challenge_id


func claim_daily_challenge_reward(unix_time := -1.0) -> bool:
	refresh_daily_challenge_for_unix(unix_time)
	if not daily_challenge_completed or daily_challenge_claimed:
		return false
	if daily_challenge_real_day <= daily_challenge_last_claimed_real_day:
		return false
	daily_challenge_claimed = true
	daily_challenge_last_claimed_real_day = daily_challenge_real_day
	_change_coins(12, "daily_challenge")
	_grant_xp(10, "daily_challenge")
	var pack := _grant_botanical_pack("daily_challenge", str(daily_challenge_real_day))
	var pack_granted := not pack.is_empty()
	if pack_granted:
		event_created.emit("Denní výzva odměněna: 12 mincí, 10 XP a botanický balíček.")
	elif pending_botanical_packs.size() >= MAX_PENDING_BOTANICAL_PACKS:
		event_created.emit("Denní výzva odměněna: 12 mincí a 10 XP. Zásobník botanických balíčků je plný.")
	else:
		event_created.emit("Denní výzva odměněna: 12 mincí a 10 XP. Botanický balíček tentokrát nebylo možné bezpečně uložit.")
	feedback_requested.emit("daily_reward", selected_plant_index, {"coins": 12, "xp": 10, "day": get_world_day(), "pack_granted": pack_granted, "pack_id": int(pack.get("pack_id", 0))})
	_activate_professor_story_if_eligible(false)
	_record_professor_story_event(professor_story.record_daily_claim(daily_challenge_real_day))
	_record_professor_research_event(professor_research.record_daily_claim(daily_challenge_real_day))
	return true


func _change_seed_count(species_id: String, amount: int) -> bool:
	if not plant_profiles.has(species_id):
		return false
	var previous_count := get_seed_count(species_id)
	var next_count := previous_count
	if amount > 0:
		if amount > MAX_SEEDS_PER_SPECIES - previous_count:
			return false
		next_count = previous_count + amount
	elif amount < 0:
		next_count = 0 if amount <= -previous_count else previous_count + amount
	if next_count == previous_count:
		return false
	seed_inventory[species_id] = next_count
	if amount > 0 and get_seed_count(species_id) > 0:
		_discover_species(species_id)
	return true


func select_plant(index: int) -> bool:
	if index < 0 or index >= plants.size():
		return false
	if not is_plant_slot_unlocked(index):
		return false
	if index == selected_plant_index:
		return true
	selected_plant_index = index
	plant = plants[selected_plant_index]
	chart_samples.clear()
	_chart_accumulator = 0.0
	_capture_sample()
	return true


func get_slot_unlock_level(index: int) -> int:
	if index < 0 or index >= MAX_PLANT_SLOTS:
		return 999
	return int(SLOT_UNLOCK_LEVELS[index])


func is_plant_slot_unlocked(index: int) -> bool:
	return index >= 0 and index < plants.size() and get_level() >= get_slot_unlock_level(index)


func get_unlocked_slot_count() -> int:
	var unlocked := 0
	for index in range(plants.size()):
		if is_plant_slot_unlocked(index):
			unlocked += 1
	return unlocked


func get_adjacent_unlocked_slot_index(offset: int) -> int:
	var unlocked_count := get_unlocked_slot_count()
	if unlocked_count <= 1 or offset == 0:
		return selected_plant_index
	var direction := 1 if offset > 0 else -1
	var candidate := selected_plant_index
	for step in range(MAX_PLANT_SLOTS):
		candidate = wrapi(candidate + direction, 0, plants.size())
		if is_plant_slot_unlocked(candidate):
			return candidate
	return selected_plant_index


func get_occupied_count() -> int:
	var occupied := 0
	for slot in plants:
		if slot.stage != PlantSimulation.Stage.EMPTY:
			occupied += 1
	return occupied


func plant_seed(species_id := "") -> bool:
	var requested_species := species_id if not species_id.is_empty() else selected_seed_species
	if not plant_profiles.has(requested_species):
		event_created.emit("Tento druh rostliny zatím není dostupný.")
		return false
	if is_tutorial_seed_choice_required() and requested_species != "basil_genovese":
		event_created.emit("Profesor Bazal tě prvním cyklem provede na bazalce.")
		return false
	if get_seed_count(requested_species) <= 0:
		event_created.emit("Nemáš semínko. Jedno můžeš koupit ve skladu.")
		return false
	if plant.stage != PlantSimulation.Stage.EMPTY:
		return false
	plant.configure_profile(get_plant_profile(requested_species))
	var tutorial_cycle := requested_species == "basil_genovese" and not journey_completed and journey_step == JourneyStep.PLANT_SEED and harvest_count == 0
	var tutorial_target := float(plant.profile.get("tutorial_growth_seconds", -1.0)) if tutorial_cycle else -1.0
	if plant.plant_seed(tutorial_target, tutorial_cycle):
		plant.sync_environment(world_elapsed_seconds)
		selected_seed_species = requested_species
		var progress := get_species_progress(requested_species)
		progress["discovered"] = true
		species_progress[requested_species] = progress
		_change_seed_count(requested_species, -1)
		_try_complete_daily_challenge("plant", true)
		_grant_xp(2, "plant_seed")
		feedback_requested.emit("seed", selected_plant_index, {"species_id": requested_species, "seeds": get_seed_count(requested_species)})
		_advance_journey(JourneyStep.PLANT_SEED, JourneyStep.WATER_PLANT)
		return true
	return false


func prune_damaged_leaves() -> bool:
	if not plant.prune_damaged_leaves():
		return false
	plant.sync_environment(world_elapsed_seconds)
	feedback_requested.emit("plant_rescued", selected_plant_index, {
		"health": plant.health,
		"freshness": plant.get_harvest_freshness_factor(),
	})
	_try_complete_daily_challenge("rescue", true)
	refresh_daily_challenge_context()
	return true


func clear_dead_plant() -> bool:
	if plant.stage != PlantSimulation.Stage.DEAD:
		return false
	var removed_species := plant.get_species_id()
	plant.reset()
	event_created.emit("Uhynulá rostlina byla odstraněna. Květináč je připravený na nové semínko.")
	var rescue_seed_granted := _grant_emergency_basil_seed_if_softlocked()
	feedback_requested.emit("plant_cleared", selected_plant_index, {
		"species_id": removed_species,
		"rescue_seed": rescue_seed_granted,
	})
	refresh_daily_challenge_context()
	return true


func _grant_emergency_basil_seed_if_softlocked() -> bool:
	if get_occupied_count() > 0 or get_total_seed_count() > 0 or coins >= get_minimum_seed_price():
		return false
	_change_seed_count("basil_genovese", 1)
	event_created.emit("Profesor Bazal ti nechal jedno záchranné semínko bazalky, aby zahrada nezůstala prázdná.")
	return true


func is_tutorial_seed_choice_required() -> bool:
	return not journey_completed and journey_step == JourneyStep.PLANT_SEED and harvest_count == 0


func can_plant_species(species_id: String) -> bool:
	if not plant_profiles.has(species_id) or get_seed_count(species_id) <= 0:
		return false
	return not is_tutorial_seed_choice_required() or species_id == "basil_genovese"


func water() -> bool:
	var before := plant.moisture
	var health_before := plant.health
	var was_growing := plant.is_growing()
	var valid_daily_context := plant.is_growing() and before <= 55.0
	var amount_ml := float(get_equipment_level_data("watering_can").get("water_ml", 120.0))
	var safe_moisture_cap := float(get_equipment_level_data("watering_can").get("safe_moisture_cap", 100.0))
	if not plant.water(amount_ml, safe_moisture_cap):
		event_created.emit("Nejdřív zasaď semínko.")
		return false
	plant.sync_environment(world_elapsed_seconds)
	if before < 72.0:
		_grant_xp(1, "water")
	feedback_requested.emit("water", selected_plant_index, {"amount_ml": amount_ml, "moisture": plant.moisture, "equipment_level": get_equipment_level("watering_can")})
	_emit_refreshing_water_feedback(health_before)
	if was_growing and (plant.moisture > before + 0.0001 or plant.health > health_before + 0.0001):
		_record_professor_research_event(professor_research.record_care("water"))
	_try_complete_daily_challenge("water", valid_daily_context)
	_advance_journey(JourneyStep.WATER_PLANT, JourneyStep.VISIT_MEASUREMENTS)
	return true


func _emit_refreshing_water_feedback(health_before: float) -> void:
	var health_delta := maxf(0.0, plant.health - health_before)
	if health_delta <= 0.0 or REFRESHING_WATER_BEHAVIOR_ID not in plant.get_behavior_ids():
		return
	var definition := plant_behavior_catalog.get_definition(REFRESHING_WATER_BEHAVIOR_ID)
	if definition.is_empty():
		return
	feedback_requested.emit("plant_behavior", selected_plant_index, {
		"behavior_id": REFRESHING_WATER_BEHAVIOR_ID,
		"label": str(definition.get("label", definition.get("name", ""))),
		"health_delta": health_delta,
	})


func fertilize() -> bool:
	if fertilizer_doses <= 0:
		event_created.emit("Hnojivo došlo. Další dávka stojí 8 mincí.")
		return false
	var nutrients_before := plant.nutrients
	var was_growing := plant.is_growing()
	var valid_daily_context := was_growing and nutrients_before <= 60.0
	if plant.fertilize(5.0):
		plant.sync_environment(world_elapsed_seconds)
		fertilizer_doses -= 1
		_grant_xp(1, "fertilize")
		feedback_requested.emit("fertilize", selected_plant_index, {"doses": fertilizer_doses})
		if was_growing and plant.nutrients > nutrients_before + 0.0001:
			_record_professor_research_event(professor_research.record_care("fertilize"))
		_try_complete_daily_challenge("fertilize", valid_daily_context)
		return true
	return false


func buy_fertilizer() -> bool:
	if get_shop_stock(SHOP_FERTILIZER_ITEM_ID) <= 0:
		event_created.emit("Hnojivo je dnes vyprodané. Pan Kořínek doplní zásoby zítra.")
		return false
	if coins < 8:
		event_created.emit("Na dávku hnojiva potřebuješ 8 mincí.")
		return false
	if not _consume_shop_stock(SHOP_FERTILIZER_ITEM_ID):
		return false
	_change_coins(-8, "buy_fertilizer")
	fertilizer_doses += 1
	feedback_requested.emit("purchase", selected_plant_index, {"item": "fertilizer", "amount": 1})
	event_created.emit("Koupena jedna dávka tekutého hnojiva.")
	return true


func ventilate() -> bool:
	var ventilation_before := plant.ventilation
	var pressure_before := plant.disease_pressure
	var was_growing := plant.is_growing()
	var valid_daily_context := was_growing
	var disease_relief := float(get_equipment_level_data("ventilation_fan").get("disease_relief", 12.0))
	if plant.ventilate(disease_relief):
		plant.sync_environment(world_elapsed_seconds)
		_grant_xp(1, "ventilate")
		feedback_requested.emit("wind", selected_plant_index, {"disease_relief": disease_relief, "equipment_level": get_equipment_level("ventilation_fan")})
		if was_growing and (plant.ventilation > ventilation_before + 0.0001 or plant.disease_pressure + 0.0001 < pressure_before):
			_record_professor_research_event(professor_research.record_care("ventilate"))
		_try_complete_daily_challenge("ventilate", valid_daily_context)
		return true
	return false


func treat_disease() -> bool:
	var treatment := get_equipment_level_data("protective_spray")
	var disease_relief := float(treatment.get("disease_treatment_relief", 52.0))
	var before_level := plant.disease_level
	var before_pressure := plant.disease_pressure
	if not plant.treat_disease(disease_relief):
		return false
	plant.sync_environment(world_elapsed_seconds)
	var cured := before_level > 0 and plant.disease_level == 0
	_grant_xp(2 if cured else 1, "treat_disease")
	feedback_requested.emit("treatment", selected_plant_index, {
		"cured": cured,
		"before_pressure": before_pressure,
		"disease_pressure": plant.disease_pressure,
		"equipment_level": get_equipment_level("protective_spray"),
	})
	if plant.disease_level < before_level or plant.disease_pressure + 0.0001 < before_pressure:
		_record_professor_research_event(professor_research.record_care("treat"))
	_try_complete_daily_challenge("treat", before_level > 0)
	return true


func toggle_lamp() -> bool:
	return toggle_lamp_for_slot(selected_plant_index)


func toggle_lamp_for_slot(index: int) -> bool:
	if index < 0 or index >= plants.size() or not is_plant_slot_unlocked(index):
		return false
	var target := plants[index]
	_apply_equipment_to_plant(target)
	var was_growing := target.is_growing()
	var was_lamp_off := not target.lamp_on
	var valid_daily_context := was_growing and was_lamp_off
	var succeeded := target.toggle_lamp()
	if succeeded:
		target.sync_environment(world_elapsed_seconds)
		feedback_requested.emit("light", index, {"enabled": target.lamp_on})
		if was_growing and was_lamp_off and target.lamp_on:
			_record_professor_research_event(professor_research.record_care("lamp_on"))
		_try_complete_daily_challenge("lamp", valid_daily_context and target.lamp_on)
	return succeeded


func harvest() -> bool:
	_apply_equipment_to_plant(plant)
	var harvested_species_id := plant.get_species_id()
	var was_tutorial_cycle := plant.tutorial_cycle
	if not plant.harvest():
		event_created.emit("%s ještě není připravená ke sklizni." % plant.get_short_name())
		return false
	_grant_xp(int(plant.profile.get("xp_harvest", 20)), "harvest")
	harvest_count += 1
	_record_species_harvest(harvested_species_id, plant.harvest_quality)
	_activate_professor_story_if_eligible(false)
	_record_professor_story_event(professor_story.record_quality_harvest(
		harvested_species_id,
		plant.harvest_quality,
		was_tutorial_cycle
	))
	_record_professor_research_event(professor_research.record_quality_harvest(
		plant.harvest_quality,
		was_tutorial_cycle
	))
	feedback_requested.emit("harvest", selected_plant_index, {"fresh_g": plant.fresh_harvest_g, "quality": plant.harvest_quality})
	_try_complete_daily_challenge("harvest", true)
	_advance_journey(JourneyStep.HARVEST, JourneyStep.START_DRYING)
	return true


func start_drying() -> bool:
	var succeeded := plant.start_drying()
	if succeeded:
		feedback_requested.emit("drying", selected_plant_index, {})
		_try_complete_daily_challenge("start_drying", true)
		_advance_journey(JourneyStep.START_DRYING, JourneyStep.WAIT_FOR_DRYING)
	return succeeded


func package_harvest() -> bool:
	if plant.package_harvest():
		_grant_xp(5, "package")
		feedback_requested.emit("package", selected_plant_index, {"dry_g": plant.dry_harvest_g})
		_record_professor_research_event(professor_research.record_package())
		_try_complete_daily_challenge("package", true)
		_advance_journey(JourneyStep.PACKAGE, JourneyStep.SELL)
		return true
	return false


func sell_harvest() -> bool:
	if plant.stage != PlantSimulation.Stage.PACKAGED:
		return false
	var income := get_sale_value()
	var dry_g := plant.dry_harvest_g
	_change_coins(income, "sell_harvest")
	_grant_xp(int(plant.profile.get("xp_sale", 30)), "sell_harvest")
	var sold_species := plant.get_species_id()
	_record_species_delivery(sold_species, dry_g, false)
	var seed_dropped := _roll_seed_drop() and _change_seed_count(sold_species, 1)
	if seed_dropped:
		event_created.emit("Prodáno za %d mincí. Ve sklizni jsi našel nové semínko!" % income)
	else:
		event_created.emit("Prodáno za %d mincí. Další semínko koupíš ve skladu." % income)
	plant.clear_after_sale()
	_capture_sample()
	feedback_requested.emit("sale", selected_plant_index, {"coins": income, "seed_dropped": seed_dropped})
	_record_professor_research_event(professor_research.record_delivery(1))
	_try_complete_daily_challenge("sell", true)
	if _advance_journey(JourneyStep.SELL, JourneyStep.COMPLETE):
		_complete_journey()
	return true


func sell_harvest_to_botanist() -> bool:
	if plant.stage != PlantSimulation.Stage.PACKAGED:
		return false
	var income := get_botanist_sale_value()
	var dry_g := plant.dry_harvest_g
	var sold_species := plant.get_species_id()
	_change_coins(income, "botanist_sale")
	_grant_xp(int(plant.profile.get("xp_sale", 30)), "botanist_sale")
	_record_species_delivery(sold_species, dry_g, false)
	var seed_dropped := _roll_seed_drop() and _change_seed_count(sold_species, 1)
	if seed_dropped:
		event_created.emit("Pan Kořínek koupil balíček za %d mincí a našel v něm nové semínko!" % income)
	else:
		event_created.emit("Pan Kořínek koupil balíček za %d mincí." % income)
	plant.clear_after_sale()
	_capture_sample()
	feedback_requested.emit("sale", selected_plant_index, {"coins": income, "seed_dropped": seed_dropped, "buyer": "botanist"})
	_record_professor_research_event(professor_research.record_delivery(1))
	_try_complete_daily_challenge("sell", true)
	if _advance_journey(JourneyStep.SELL, JourneyStep.COMPLETE):
		_complete_journey()
	return true


func is_blend_order(index: int) -> bool:
	return index >= 0 and index < orders.size() and str(orders[index].get("kind", "single")) == "blend"


func get_order_requirements(index: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if index < 0 or index >= orders.size():
		return result
	var order := orders[index]
	if is_blend_order(index):
		var raw_requirements = order.get("requirements", [])
		if raw_requirements is Array:
			for raw_requirement in raw_requirements:
				if raw_requirement is Dictionary:
					result.append((raw_requirement as Dictionary).duplicate(true))
		return result
	result.append({
		"species_id": str(order.get("species_id", "any")),
		"min_dry_g": float(order.get("min_dry_g", 0.0)),
		"min_quality": float(order.get("min_quality", 0.0)),
	})
	return result


func get_order_requirement_text(index: int) -> String:
	var requirements := get_order_requirements(index)
	if requirements.is_empty():
		return ""
	if not is_blend_order(index):
		var requirement: Dictionary = requirements[0]
		return "BYLINA: %s · min. %.1f g · kvalita %d%%" % [
			get_order_species_name(index).to_upper(),
			float(requirement.get("min_dry_g", 0.0)),
			roundi(float(requirement.get("min_quality", 0.0)) * 100.0),
		]
	var lines: Array[String] = ["SMĚS · 2 BYLINY"]
	for requirement in requirements:
		var species_id := str(requirement.get("species_id", "any"))
		var species_name := str(get_plant_profile(species_id).get("short_name", "Bylina")).to_upper()
		var grams := ("%.1f" % float(requirement.get("min_dry_g", 0.0))).replace(".", ",")
		lines.append("%s · %s g · kvalita %d%%" % [species_name, grams, roundi(float(requirement.get("min_quality", 0.0)) * 100.0)])
	return "\n".join(lines)


func get_order_fulfillment_plan(index: int) -> Dictionary:
	var invalid_plan := {
		"kind": "single",
		"blend_id": "",
		"can_fulfill": false,
		"status": "Zakázka není dostupná",
		"first_failure": "invalid_order",
		"requirements": [],
		"assignments": [],
		"slot_indices": [],
	}
	if index < 0 or index >= orders.size():
		return invalid_plan
	var order := orders[index]
	var kind := "blend" if is_blend_order(index) else "single"
	var requirements := get_order_requirements(index)
	var plan := {
		"kind": kind,
		"blend_id": str(order.get("blend_id", "")) if kind == "blend" else "",
		"can_fulfill": false,
		"status": "Nejdřív připrav balíček",
		"first_failure": "missing_package",
		"requirements": requirements.duplicate(true),
		"assignments": [],
		"slot_indices": [],
	}
	if kind == "single":
		if plant.stage != PlantSimulation.Stage.PACKAGED:
			return plan
		var requirement: Dictionary = requirements[0]
		var required_species := str(requirement.get("species_id", "any"))
		if required_species != "any" and plant.get_species_id() != required_species:
			plan["status"] = "Potřeba: %s" % get_order_species_name(index)
			plan["first_failure"] = "wrong_species"
			return plan
		if plant.dry_harvest_g + 0.0001 < float(requirement.get("min_dry_g", 0.0)):
			plan["status"] = "Chybí hmotnost"
			plan["first_failure"] = "missing_weight"
			return plan
		if plant.harvest_quality + 0.0001 < float(requirement.get("min_quality", 0.0)):
			plan["status"] = "Chybí kvalita"
			plan["first_failure"] = "missing_quality"
			return plan
		plan["can_fulfill"] = true
		plan["status"] = "Připraveno k odevzdání"
		plan["first_failure"] = ""
		plan["assignments"] = [{
			"requirement_index": 0,
			"species_id": plant.get_species_id(),
			"slot_index": selected_plant_index,
			"dry_g": plant.dry_harvest_g,
			"quality": plant.harvest_quality,
		}]
		plan["slot_indices"] = [selected_plant_index]
		return plan

	var assignments_by_requirement: Array[Dictionary] = []
	assignments_by_requirement.resize(requirements.size())
	for requirement_index in range(assignments_by_requirement.size()):
		assignments_by_requirement[requirement_index] = {}
	var candidate_indices: Array[int] = []
	if is_plant_slot_unlocked(selected_plant_index):
		candidate_indices.append(selected_plant_index)
	for slot_index in range(plants.size()):
		if slot_index != selected_plant_index and is_plant_slot_unlocked(slot_index):
			candidate_indices.append(slot_index)
	var assigned_slots: Dictionary = {}
	for slot_index in candidate_indices:
		var slot := plants[slot_index]
		if slot.stage != PlantSimulation.Stage.PACKAGED:
			continue
		for requirement_index in range(requirements.size()):
			if not assignments_by_requirement[requirement_index].is_empty():
				continue
			var requirement: Dictionary = requirements[requirement_index]
			if slot.get_species_id() != str(requirement.get("species_id", "")):
				continue
			if slot.dry_harvest_g + 0.0001 < float(requirement.get("min_dry_g", 0.0)):
				continue
			if slot.harvest_quality + 0.0001 < float(requirement.get("min_quality", 0.0)):
				continue
			assignments_by_requirement[requirement_index] = {
				"requirement_index": requirement_index,
				"species_id": slot.get_species_id(),
				"slot_index": slot_index,
				"dry_g": slot.dry_harvest_g,
				"quality": slot.harvest_quality,
			}
			assigned_slots[slot_index] = true
			break

	var assignments: Array[Dictionary] = []
	var slot_indices: Array[int] = []
	for requirement_index in range(requirements.size()):
		var assignment := assignments_by_requirement[requirement_index]
		if assignment.is_empty():
			var failure := _get_blend_requirement_failure(requirements[requirement_index], candidate_indices)
			plan["status"] = str(failure.get("status", "Zakázka není dostupná"))
			plan["first_failure"] = str(failure.get("first_failure", "invalid_order"))
			return plan
		assignments.append(assignment)
		slot_indices.append(int(assignment.get("slot_index", -1)))
	if assignments.size() != 2 or assigned_slots.size() != 2:
		return invalid_plan
	plan["can_fulfill"] = true
	plan["status"] = "Připraveno k odevzdání"
	plan["first_failure"] = ""
	plan["assignments"] = assignments
	plan["slot_indices"] = slot_indices
	return plan


func _get_blend_requirement_failure(requirement: Dictionary, candidate_indices: Array[int]) -> Dictionary:
	var species_id := str(requirement.get("species_id", ""))
	var species_name := str(get_plant_profile(species_id).get("short_name", "Bylina"))
	var has_species_package := false
	var has_required_weight := false
	for slot_index in candidate_indices:
		var slot := plants[slot_index]
		if slot.stage != PlantSimulation.Stage.PACKAGED or slot.get_species_id() != species_id:
			continue
		has_species_package = true
		if slot.dry_harvest_g + 0.0001 >= float(requirement.get("min_dry_g", 0.0)):
			has_required_weight = true
			if slot.harvest_quality + 0.0001 >= float(requirement.get("min_quality", 0.0)):
				return {"first_failure": "invalid_order", "status": "Zakázka není dostupná"}
	if not has_species_package:
		return {"first_failure": "missing_package:%s" % species_id, "status": "Chybí balíček: %s" % species_name}
	if not has_required_weight:
		return {"first_failure": "missing_weight:%s" % species_id, "status": "%s: chybí hmotnost" % species_name}
	return {"first_failure": "missing_quality:%s" % species_id, "status": "%s: chybí kvalita" % species_name}


func can_fulfill_order(index: int) -> bool:
	return bool(get_order_fulfillment_plan(index).get("can_fulfill", false))


func get_order_reward(index: int, dry_g := -1.0) -> int:
	if index < 0 or index >= orders.size():
		return 0
	var order := orders[index]
	if is_blend_order(index):
		var priced_grams: Dictionary = {}
		var plan := get_order_fulfillment_plan(index)
		if bool(plan.get("can_fulfill", false)):
			for assignment in plan.get("assignments", []):
				if assignment is Dictionary:
					priced_grams[str(assignment.get("species_id", ""))] = float(assignment.get("dry_g", 0.0))
		var ingredient_value := 0.0
		for requirement in get_order_requirements(index):
			var species_id := str(requirement.get("species_id", ""))
			var reward_grams := float(priced_grams.get(species_id, requirement.get("min_dry_g", 0.0)))
			ingredient_value += reward_grams * float(get_plant_profile(species_id).get("dried_price_per_g", 5.0))
		return clampi(roundi(ingredient_value * float(order.get("reward_multiplier", 1.0))) + int(order.get("flat_bonus", 0)), 1, BLEND_ORDER_MAX_REWARD_COINS)
	var reward_grams := dry_g
	if reward_grams < 0.0:
		reward_grams = plant.dry_harvest_g if plant.dry_harvest_g > 0.0 else float(order.get("min_dry_g", 3.0))
	var required_species := str(order.get("species_id", "any"))
	var reward_profile := plant.profile if required_species == "any" else get_plant_profile(required_species)
	var price_per_g := float(reward_profile.get("dried_price_per_g", 5.0))
	var multiplier := float(order.get("reward_multiplier", 1.0))
	return clampi(roundi(reward_grams * price_per_g * multiplier) + int(order.get("flat_bonus", 0)), 1, ORDER_MAX_REWARD_COINS)


func get_order_status(index: int) -> String:
	return str(get_order_fulfillment_plan(index).get("status", "Zakázka není dostupná"))


func get_order_species_name(index: int) -> String:
	if index < 0 or index >= orders.size():
		return "Neznámá bylina"
	if is_blend_order(index):
		var names: Array[String] = []
		for requirement in get_order_requirements(index):
			names.append(str(get_plant_profile(str(requirement.get("species_id", ""))).get("short_name", "Bylina")))
		return " + ".join(names)
	var species_id := str(orders[index].get("species_id", "any"))
	if species_id == "any":
		return "Libovolná bylina"
	return str(get_plant_profile(species_id).get("short_name", "Bylina"))


func refresh_order_declines_for_unix(unix_time := -1.0) -> bool:
	var effective_unix := Time.get_unix_time_from_system() if unix_time < 0.0 else unix_time
	var current_day := _get_real_shop_day_index(effective_unix)
	if order_refresh_day >= 0 and current_day <= order_refresh_day:
		return false
	order_refresh_day = current_day
	order_refreshes_remaining = DAILY_ORDER_REFRESHES
	return true


func decline_order(index: int) -> bool:
	refresh_order_declines_for_unix()
	if index < 0 or index >= orders.size() or order_refreshes_remaining <= 0:
		return false
	var previous_customer := str(orders[index].get("customer", "odběratele"))
	var sequence := _allocate_order_sequence(order_rotation, _get_active_order_sequences(index))
	orders[index] = _build_order(sequence, _get_active_blend_ids(index))
	_advance_order_rotation_after(sequence)
	order_refreshes_remaining -= 1
	event_created.emit("Zakázka od %s byla vyměněna. Dnes zbývá %d výměn." % [previous_customer, order_refreshes_remaining])
	feedback_requested.emit("order_refresh", selected_plant_index, {"order_index": index, "remaining": order_refreshes_remaining})
	return true


func fulfill_order(index: int) -> bool:
	var plan := get_order_fulfillment_plan(index)
	if not bool(plan.get("can_fulfill", false)):
		event_created.emit(get_order_status(index) + ". Vyber vhodnější zakázku nebo vypěstuj lepší šarži.")
		feedback_requested.emit("error", selected_plant_index, {"source": "customer_order", "order_index": index})
		return false
	if is_blend_order(index):
		return _fulfill_blend_order(index, plan)
	var order := orders[index]
	var customer := str(order.get("customer", "odběratele"))
	var dry_g := plant.dry_harvest_g
	var quality := plant.harvest_quality
	var reward_coins := get_order_reward(index, dry_g)
	var reward_xp := int(order.get("bonus_xp", 8))
	_change_coins(reward_coins, "customer_order")
	_grant_xp(reward_xp, "customer_order")
	var sold_species := plant.get_species_id()
	_record_species_delivery(sold_species, dry_g, true)
	var seed_dropped := _roll_seed_drop() and _change_seed_count(sold_species, 1)
	orders_completed += 1
	var replacement_sequence := _allocate_order_sequence(order_rotation, _get_active_order_sequences(index))
	orders[index] = _build_order(replacement_sequence, _get_active_blend_ids(index))
	_advance_order_rotation_after(replacement_sequence)
	plant.clear_after_sale()
	_capture_sample()
	feedback_requested.emit("order_complete", selected_plant_index, {
		"order_kind": "single",
		"customer": customer,
		"coins": reward_coins,
		"xp": reward_xp,
		"quality": quality,
		"dry_g": dry_g,
		"seed_dropped": seed_dropped,
	})
	event_created.emit("Zakázka pro %s je hotová! Získáváš %d mincí a %d XP.%s" % [customer, reward_coins, reward_xp, " Navíc jsi našel nové semínko!" if seed_dropped else ""])
	_activate_professor_story_if_eligible(false)
	_record_professor_story_event(professor_story.record_specific_order(str(order.get("species_id", "any"))))
	_record_professor_research_event(professor_research.record_delivery(1))
	if _advance_journey(JourneyStep.SELL, JourneyStep.COMPLETE):
		_complete_journey()
	return true


func buy_seed(species_id := "basil_genovese") -> bool:
	if not plant_profiles.has(species_id):
		return false
	var seed_profile := get_plant_profile(species_id)
	if not species_has_acquisition_source(species_id, "botanist"):
		event_created.emit("Semínko %s pan Kořínek nenabízí." % str(seed_profile.get("display_name", "bylinky")))
		return false
	var unlock_level := get_botanist_seed_unlock_level(species_id)
	if not is_botanist_seed_unlocked(species_id):
		event_created.emit("Semínko %s se v obchodě odemkne na úrovni %d." % [str(seed_profile.get("display_name", "bylinky")), unlock_level])
		return false
	var price := int(seed_profile.get("seed_price", 12))
	var item_id := get_shop_seed_item_id(species_id)
	if get_seed_count(species_id) >= MAX_SEEDS_PER_SPECIES:
		event_created.emit("Zásoba semínek %s je plná." % str(seed_profile.get("display_name", "bylinky")))
		return false
	if get_shop_stock(item_id) <= 0:
		event_created.emit("Semínko %s je dnes vyprodané. Nové zásoby budou zítra." % str(seed_profile.get("display_name", "bylinky")))
		return false
	if coins < price:
		event_created.emit("Na semínko potřebuješ %d mincí." % price)
		return false
	if not _consume_shop_stock(item_id):
		return false
	_change_coins(-price, "buy_seed")
	_change_seed_count(species_id, 1)
	feedback_requested.emit("purchase", selected_plant_index, {"item": "seed", "species_id": species_id, "amount": 1})
	event_created.emit("Koupeno semínko: %s." % str(seed_profile.get("display_name", "bylinka")))
	return true


func advance(real_seconds: float) -> void:
	if paused or real_seconds <= 0.0:
		return
	var previous_care_entries: Array[Dictionary] = []
	var previous_attention: Dictionary
	if _care_attention_cache_initialized:
		previous_attention = _care_attention_cache.duplicate()
	else:
		previous_care_entries = get_care_center_entries()
		previous_attention = _get_care_attention_slots_from_entries(previous_care_entries)
		_care_attention_cache_initialized = true
	var previous_guard_signatures := {}
	if fast_time_guard_enabled and speed_multiplier >= FAST_TIME_GUARD_MIN_SPEED:
		if previous_care_entries.is_empty():
			previous_care_entries = get_care_center_entries()
		previous_guard_signatures = _fast_time_guard_signatures_from_entries(previous_care_entries)
	# Production growth always consumes real elapsed seconds. speed_multiplier is
	# retained only as a non-player test seam for legacy deterministic captures.
	var simulation_seconds := real_seconds
	var world_start := world_elapsed_seconds
	var suppress_mature_lifecycle := _legacy_lifecycle_protection_pending
	for index in range(plants.size()):
		_advance_slot(index, simulation_seconds, world_start, suppress_mature_lifecycle, false)
	greenhouse.advance(simulation_seconds)
	_legacy_lifecycle_protection_pending = false
	world_elapsed_seconds += simulation_seconds
	_daily_challenge_refresh_accumulator += real_seconds
	if _daily_challenge_refresh_accumulator >= 1.0:
		_daily_challenge_refresh_accumulator = fmod(_daily_challenge_refresh_accumulator, 1.0)
		_ensure_daily_challenge()
	_chart_accumulator += simulation_seconds
	if _chart_accumulator >= 60.0:
		_chart_accumulator = fmod(_chart_accumulator, 60.0)
		_capture_sample()
	var current_care_entries := get_care_center_entries()
	_try_fast_time_guard(previous_guard_signatures, current_care_entries)
	_emit_new_care_reminders(previous_attention, current_care_entries)
	_care_attention_cache = _get_care_attention_slots_from_entries(current_care_entries)


func advance_offline(real_seconds: float) -> float:
	if real_seconds <= 1.0:
		return 0.0
	_sync_equipment_effects()
	_offline_lifecycle_events.clear()
	var capped_seconds := minf(real_seconds, 259200.0)
	var world_start := world_elapsed_seconds
	var suppress_mature_lifecycle := _legacy_lifecycle_protection_pending
	for index in range(plants.size()):
		_advance_slot(index, capped_seconds, world_start, suppress_mature_lifecycle, true)
	var greenhouse_events: Array[Dictionary] = greenhouse.advance(capped_seconds)
	for greenhouse_event in greenhouse_events:
		_offline_lifecycle_events.append(greenhouse_event)
	_legacy_lifecycle_protection_pending = false
	world_elapsed_seconds += capped_seconds
	for slot in plants:
		slot.sync_environment(world_elapsed_seconds)
	_ensure_daily_challenge()
	_capture_sample()
	var offline_outcomes: Array[String] = []
	for lifecycle_event in _offline_lifecycle_events:
		offline_outcomes.append(str(lifecycle_event.get("kind", "")))
	_activate_professor_story_if_eligible(false)
	_record_professor_story_event(
		professor_story.record_qualifying_return(capped_seconds, offline_outcomes),
		true
	)
	event_created.emit("Během nepřítomnosti uběhlo %s." % format_duration(capped_seconds))
	return capped_seconds


func consume_offline_lifecycle_events() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for event in _offline_lifecycle_events:
		result.append(event.duplicate(true))
	_offline_lifecycle_events.clear()
	return result


func get_sale_value() -> int:
	if plant.dry_harvest_g <= 0.0:
		return 0
	var market_factor := 0.92 + 0.08 * sin(float(harvest_count + 1) * 1.83)
	return maxi(1, roundi(plant.dry_harvest_g * float(plant.profile.get("dried_price_per_g", 5.0)) * market_factor))


func get_botanist_sale_value() -> int:
	var market_value := get_sale_value()
	if market_value <= 0:
		return 0
	return maxi(1, floori(float(market_value) * BOTANIST_BUYBACK_FACTOR))


func get_level() -> int:
	return 1 + int(xp / 100)


func get_level_progress() -> float:
	return float(xp % 100)


func get_grower_journal_snapshot() -> Dictionary:
	var species_ids := get_available_species()
	var species_discovered := 0
	var quality_species := 0
	var total_dry_g := 0.0
	var best_quality := 0.0
	for species_id in species_ids:
		var progress := get_species_progress(species_id)
		if bool(progress.get("discovered", false)):
			species_discovered += 1
		var quality := clampf(float(progress.get("best_quality", 0.0)), 0.0, 1.0)
		best_quality = maxf(best_quality, quality)
		if quality >= 0.90:
			quality_species += 1
		total_dry_g += maxf(0.0, float(progress.get("total_dry_g", 0.0)))
	var active_pots := 0
	for slot_index in range(plants.size()):
		if is_plant_slot_unlocked(slot_index) and plants[slot_index].stage not in [PlantSimulation.Stage.EMPTY, PlantSimulation.Stage.DEAD]:
			active_pots += 1
	var equipment_maxed := 0
	for equipment_id in EQUIPMENT_ORDER:
		if get_equipment_level(equipment_id) >= EQUIPMENT_MAX_LEVEL:
			equipment_maxed += 1
	var unlocked_core_themes := _get_unlocked_core_room_theme_count()
	var badges: Array[Dictionary] = [
		_grower_badge("first_cycle", "PRVNÍ CYKLUS", "Dokonči péči, sklizeň, sušení, balení a prodej.", 1 if journey_completed else 0, 1),
		_grower_badge("species_collection", "BYLINKOVÁ SBÍRKA", "Objev a zasaď všechny dostupné druhy.", species_discovered, species_ids.size()),
		_grower_badge("busy_rack", "ŽIVÝ STOJAN", "Měj současně osazených pět odemčených květináčů.", active_pots, 5),
		_grower_badge("trusted_supplier", "SPOLEHLIVÝ DODAVATEL", "Dokonči deset zákaznických zakázek.", orders_completed, 10),
		_grower_badge("seasoned_grower", "ZKUŠENÝ PĚSTITEL", "Nasbírej celkem dvacet pět sklizní.", harvest_count, 25),
		_grower_badge("quality_trio", "MISTR KVALITY", "Dosáhni alespoň 90% kvality u každého druhu.", quality_species, species_ids.size()),
		_grower_badge("workshop_master", "MISTR DÍLNY", "Vylepši všech pět pomůcek na nejvyšší úroveň.", equipment_maxed, EQUIPMENT_ORDER.size()),
		_grower_badge("room_collector", "SBĚRATEL VZHLEDŮ", "Odemkni tři základní vzhledy pěstitelského pokoje.", unlocked_core_themes, CORE_ROOM_THEME_IDS.size()),
		_grower_badge("herbarium_master", "MISTR HERBÁŘE", "Dokonči Velkou herbářovou výstavu a převezmi Profesorovu závěrečnou pečeť.", 1 if not get_professor_title_id().is_empty() else 0, 1),
		_grower_badge("research_partner", "VÝZKUMNÝ PARTNER", "Dokonči čtyři Profesorovy týdenní protokoly.", get_professor_research_completed_count(), 4),
	]
	var completed_badges := 0
	var next_goal: Dictionary = {}
	for badge in badges:
		if bool(badge.get("achieved", false)):
			completed_badges += 1
		elif next_goal.is_empty():
			next_goal = badge.duplicate(true)
	if next_goal.is_empty():
		next_goal = {
			"id": "all_complete",
			"title": "VŠECHNY CÍLE SPLNĚNY",
			"description": "Tvoje současná pěstitelská kronika je kompletní.",
			"current": 1,
			"target": 1,
			"progress": 1.0,
			"achieved": true,
		}
	return {
		"level": get_level(),
		"xp_in_level": int(get_level_progress()),
		"harvests": maxi(0, harvest_count),
		"orders": maxi(0, orders_completed),
		"species_discovered": species_discovered,
		"species_total": species_ids.size(),
		"total_dry_g": snappedf(total_dry_g, 0.1),
		"best_quality": best_quality,
		"active_pots": active_pots,
		"unlocked_pots": get_unlocked_slot_count(),
		"equipment_maxed": equipment_maxed,
		"equipment_total": EQUIPMENT_ORDER.size(),
		"themes_unlocked": unlocked_core_themes,
		"themes_total": CORE_ROOM_THEME_IDS.size(),
		"professor_title_id": get_professor_title_id(),
		"professor_title": get_professor_title(),
		"completed_badges": completed_badges,
		"badge_total": badges.size(),
		"badges": badges,
		"next_goal": next_goal,
	}


func _grower_badge(id: String, title: String, description: String, current: int, target: int) -> Dictionary:
	var safe_target := maxi(1, target)
	var safe_current := maxi(0, current)
	return {
		"id": id,
		"title": title,
		"description": description,
		"current": safe_current,
		"target": safe_target,
		"progress": clampf(float(safe_current) / float(safe_target), 0.0, 1.0),
		"achieved": safe_current >= safe_target,
	}


func _get_unlocked_core_room_theme_count() -> int:
	var count := 0
	for theme_id in CORE_ROOM_THEME_IDS:
		if theme_id in unlocked_room_themes:
			count += 1
	return count


func get_care_center_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	for slot_index in range(plants.size()):
		entries.append(_build_care_entry(slot_index, plants[slot_index]))
	entries.sort_custom(_sort_care_entries)
	return entries


func get_care_attention_count() -> int:
	var count := 0
	for entry in get_care_center_entries():
		if bool(entry.get("attention", false)):
			count += 1
	return count


func set_care_reminders_enabled(enabled: bool) -> void:
	care_reminders_enabled = enabled


func set_fast_time_guard_enabled(enabled: bool) -> void:
	fast_time_guard_enabled = enabled


func check_fast_time_guard_now() -> bool:
	if not fast_time_guard_enabled or paused or speed_multiplier < FAST_TIME_GUARD_MIN_SPEED:
		return false
	return _try_fast_time_guard({}, get_care_center_entries())


func get_next_care_check() -> Dictionary:
	var best := {"slot_index": -1, "seconds": -1.0, "label": "Žádná aktivní rostlina"}
	for entry in get_care_center_entries():
		var seconds := float(entry.get("check_in_seconds", -1.0))
		if seconds < 0.0:
			continue
		if float(best.seconds) < 0.0 or seconds < float(best.seconds):
			best = {
				"slot_index": int(entry.get("slot_index", -1)),
				"seconds": seconds,
				"label": str(entry.get("check_label", "")),
				"status": str(entry.get("status", "Kontrola rostliny")),
				"detail": str(entry.get("detail", "")),
			}
	return best


func get_care_reminder_summary() -> String:
	if not care_reminders_enabled:
		return "Připomínky v aplikaci jsou vypnuté."
	var next := get_next_care_check()
	if int(next.get("slot_index", -1)) < 0:
		return "Připomínky čekají na aktivní rostlinu."
	if float(next.get("seconds", 0.0)) <= 0.0:
		return "Kontrola je potřeba teď · květináč %d." % (int(next.get("slot_index", 0)) + 1)
	return "Další kontrola za %s · květináč %d." % [format_care_duration(float(next.get("seconds", 0.0))), int(next.get("slot_index", 0)) + 1]


func _get_care_attention_slots_from_entries(entries: Array[Dictionary]) -> Dictionary:
	var result := {}
	for entry in entries:
		if bool(entry.get("attention", false)):
			result[int(entry.get("slot_index", -1))] = true
	return result


func _emit_new_care_reminders(previous_attention: Dictionary, current_entries: Array[Dictionary]) -> void:
	if not care_reminders_enabled:
		return
	for entry in current_entries:
		var slot_index := int(entry.get("slot_index", -1))
		if not bool(entry.get("attention", false)) or previous_attention.has(slot_index):
			continue
		feedback_requested.emit("care_reminder", slot_index, {"status": str(entry.get("status", "Kontrola rostliny"))})
		event_created.emit("Plán péče: květináč %d potřebuje kontrolu · %s." % [slot_index + 1, str(entry.get("status", "zkontroluj stav"))])
		return


func _fast_time_guard_signatures_from_entries(entries: Array[Dictionary]) -> Dictionary:
	var signatures := {}
	if not fast_time_guard_enabled or speed_multiplier < FAST_TIME_GUARD_MIN_SPEED:
		return signatures
	for entry in entries:
		var signature := _fast_time_guard_signature(entry)
		if not signature.is_empty():
			signatures[signature] = true
	return signatures


func _fast_time_guard_signature(entry: Dictionary) -> String:
	var slot_index := int(entry.get("slot_index", -1))
	if slot_index < 0 or slot_index >= plants.size() or not bool(entry.get("unlocked", false)):
		return ""
	var slot := plants[slot_index]
	var kind := ""
	if str(entry.get("state", "")) == "critical":
		kind = "critical:%s" % str(entry.get("status", "kontrola"))
	elif slot.stage == PlantSimulation.Stage.MATURE:
		kind = "harvest_ready"
	elif slot.stage == PlantSimulation.Stage.DRY:
		kind = "drying_complete"
	if kind.is_empty():
		return ""
	return "%d:%s" % [slot_index, kind]


func _try_fast_time_guard(previous_signatures: Dictionary, current_entries: Array[Dictionary]) -> bool:
	if not fast_time_guard_enabled or paused or speed_multiplier < FAST_TIME_GUARD_MIN_SPEED:
		return false
	for entry in current_entries:
		var signature := _fast_time_guard_signature(entry)
		if signature.is_empty() or previous_signatures.has(signature):
			continue
		paused = true
		var slot_index := int(entry.get("slot_index", -1))
		var reason := str(entry.get("status", "Rostlina potřebuje kontrolu"))
		var target := str(entry.get("target", "detail"))
		fast_time_guard_triggered.emit(slot_index, reason, target)
		event_created.emit("Bezpečná rychlost pozastavila simulaci · květináč %d · %s." % [slot_index + 1, reason])
		return true
	return false


func _build_care_entry(slot_index: int, slot: PlantSimulation) -> Dictionary:
	var unlocked := is_plant_slot_unlocked(slot_index)
	var entry := {
		"slot_index": slot_index,
		"slot_number": slot_index + 1,
		"unlocked": unlocked,
		"alive": slot.stage not in [PlantSimulation.Stage.EMPTY, PlantSimulation.Stage.DEAD],
		"species_name": slot.get_short_name(),
		"stage_name": slot.get_stage_name(),
		"status": "V pořádku",
		"detail": "Růst %d%% · zdraví %d%%" % [roundi(slot.growth_percent), roundi(slot.health)],
		"priority": 10,
		"attention": false,
		"target": "detail",
		"action": "OTEVŘÍT DETAIL",
		"state": "healthy",
		"check_in_seconds": -1.0,
		"check_label": "BEZ PLÁNU",
	}
	if not unlocked:
		entry.status = "Zamčený květináč"
		entry.detail = "Odemkne se na úrovni %d." % get_slot_unlock_level(slot_index)
		entry.priority = -100 - slot_index
		entry.action = "OD ÚROVNĚ %d" % get_slot_unlock_level(slot_index)
		entry.state = "locked"
		return entry
	match slot.stage:
		PlantSimulation.Stage.EMPTY:
			entry.species_name = "Volný květináč"
			entry.status = "Čeká na semínko"
			entry.detail = "Vyber bylinku a založ nový pěstitelský cyklus."
			entry.priority = 30
			entry.action = "ZASADIT"
			entry.state = "empty"
		PlantSimulation.Stage.MATURE:
			if slot.is_wilted():
				entry.status = "Zvadlá rostlina"
				entry.detail = "Oprav kritickou péči a odstraň poškozené listy · zbývá %s." % format_care_duration(slot.get_seconds_until_death())
				entry.priority = 110
				entry.attention = true
				entry.target = "detail"
				entry.action = "ZACHRÁNIT ROSTLINU"
				entry.state = "critical"
				_set_care_check(entry, slot.get_seconds_until_death())
			elif slot.get_fatal_care_issue_count() >= slot.get_critical_care_issue_limit():
				entry.status = "Kritická péče po dozrání"
				entry.detail = "%s · vadnutí za %s." % [slot.current_issue, format_care_duration(slot.get_seconds_until_wilt())]
				entry.priority = 98
				entry.attention = true
				entry.target = "detail"
				entry.action = "OPRAVIT PÉČI"
				entry.state = "critical"
				_set_care_check(entry, slot.get_seconds_until_wilt())
			else:
				var freshness := slot.get_harvest_freshness_factor()
				entry.status = "Připraveno ke sklizni" if freshness >= 0.999 else "Pozdní sklizeň"
				entry.detail = "Růst 100%% · zdraví %d%% · čerstvost %d%% · sklizeň čeká ve skladu." % [roundi(slot.health), roundi(freshness * 100.0)]
				entry.priority = 88 if freshness >= 0.999 else 94
				entry.attention = true
				entry.target = "storage"
				entry.action = "PŘEJÍT DO SKLADU"
				entry.state = "harvest" if freshness >= 0.999 else "warning"
				_set_care_check(entry, slot.get_seconds_until_freshness_decay() if freshness >= 0.999 else 0.0)
		PlantSimulation.Stage.HARVESTED:
			entry.status = "Čerstvá sklizeň čeká"
			entry.detail = "Zahaj sušení dřív, než listy ztratí kvalitu."
			entry.priority = 84
			entry.attention = true
			entry.target = "storage"
			entry.action = "ZAHÁJIT SUŠENÍ"
			entry.state = "processing"
			_set_care_check(entry, 0.0)
		PlantSimulation.Stage.DRYING:
			entry.status = "Sušení %d%%" % roundi(slot.drying_progress)
			entry.detail = "Proces běží. Ve skladu uvidíš přesný postup."
			entry.priority = 34
			entry.target = "storage"
			entry.action = "ZKONTROLOVAT SUŠENÍ"
			entry.state = "processing"
			var drying_seconds := slot.get_drying_target_seconds()
			_set_care_check(entry, maxf(0.0, drying_seconds * (1.0 - slot.drying_progress / 100.0)))
		PlantSimulation.Stage.DRY:
			entry.status = "Usušená bylinka čeká"
			entry.detail = "Sklizeň je připravená k zabalení."
			entry.priority = 82
			entry.attention = true
			entry.target = "storage"
			entry.action = "ZABALIT VE SKLADU"
			entry.state = "processing"
			_set_care_check(entry, 0.0)
		PlantSimulation.Stage.PACKAGED:
			entry.status = "Balíček je hotový"
			entry.detail = "Můžeš jej prodat nebo použít pro vhodnou zakázku."
			entry.priority = 80
			entry.attention = true
			entry.target = "storage"
			entry.action = "OTEVŘÍT SKLAD"
			entry.state = "processing"
			_set_care_check(entry, 0.0)
		PlantSimulation.Stage.DEAD:
			entry.status = "Rostlina uhynula"
			entry.detail = "Sklizeň je ztracená. Vyčisti květináč a začni nový cyklus."
			entry.priority = 104
			entry.attention = true
			entry.target = "detail"
			entry.action = "VYČISTIT KVĚTINÁČ"
			entry.state = "critical"
			_set_care_check(entry, 0.0)
		_:
			_apply_growing_care_state(entry, slot)
	return entry


func _apply_growing_care_state(entry: Dictionary, slot: PlantSimulation) -> void:
	if slot.disease_level > 0:
		entry.status = "Plíseň listů"
		entry.detail = "Vyvětrej, drž vláhu pod 76%% a sleduj zdraví %d%%" % roundi(slot.health)
		entry.priority = 100
		entry.state = "critical"
	elif slot.moisture < 24.0:
		entry.status = "Potřebuje zalít"
		entry.detail = "Vláha pouze %d%% · ideál začíná kolem %d%%" % [roundi(slot.moisture), roundi(float(slot.profile.get("ideal_moisture_min", 42.0)))]
		entry.priority = 96
		entry.state = "critical"
	elif slot.moisture > 88.0:
		entry.status = "Přemokřená půda"
		entry.detail = "Vláha %d%% · nezalévej a zlepši proudění vzduchu." % roundi(slot.moisture)
		if slot.ventilation >= PlantDiagnosisService.MIN_ADEQUATE_VENTILATION:
			entry.detail = "Vláha %d%% · proudění je dostatečné. Nezalévej a nech půdu přirozeně proschnout." % roundi(slot.moisture)
		entry.priority = 92
		entry.state = "critical"
	elif slot.moisture <= CARE_CHECK_MOISTURE:
		entry.status = "Brzy zalít"
		entry.detail = "Vláha klesla na %d%% · zkontroluj půdu před zálivkou." % roundi(slot.moisture)
		entry.priority = 72
		entry.state = "warning"
	elif slot.health < 55.0:
		entry.status = "Oslabená rostlina"
		entry.detail = "Zdraví %d%% · zkontroluj všechny podmínky." % roundi(slot.health)
		entry.priority = 89
		entry.state = "critical"
	elif slot.nutrients < 23.0:
		entry.status = "Potřebuje přihnojit"
		entry.detail = "Živiny pouze %d%% · v zásobě %d dávek." % [roundi(slot.nutrients), fertilizer_doses]
		entry.priority = 86
		entry.state = "warning"
	elif slot.nutrients <= CARE_CHECK_NUTRIENTS:
		entry.status = "Brzy zkontrolovat živiny"
		entry.detail = "Živiny klesly na %d%% · hnoj až po kontrole hodnot." % roundi(slot.nutrients)
		entry.priority = 70
		entry.state = "warning"
	elif slot.humidity_percent > 76.0 and slot.ventilation < 40.0:
		entry.status = "Potřebuje vyvětrat"
		entry.detail = "Vlhkost vzduchu %d%% · proudění %d%%" % [roundi(slot.humidity_percent), roundi(slot.ventilation)]
		entry.priority = 83
		entry.state = "warning"
	elif slot.current_issue == "Málo světla" and not slot.lamp_on:
		entry.status = "Potřebuje světlo"
		entry.detail = "%d lux · zapni doplňkovou lampu." % roundi(slot.light_lux)
		entry.priority = 76
		entry.state = "warning"
	elif slot.ventilation <= CARE_CHECK_VENTILATION:
		entry.status = "Brzy vyvětrat"
		entry.detail = "Proudění kleslo na %d%%" % roundi(slot.ventilation)
		entry.priority = 68
		entry.state = "warning"
	else:
		entry.status = "V pořádku"
		entry.detail = "Růst %d%% · zdraví %d%% · vláha %d%%" % [roundi(slot.growth_percent), roundi(slot.health), roundi(slot.moisture)]
		entry.priority = 10
		entry.state = "healthy"
	entry.attention = int(entry.priority) >= 68
	if bool(entry.attention):
		_set_care_check(entry, 0.0)
	else:
		_set_care_check(entry, _predict_next_growing_check(slot))


func _predict_next_growing_check(slot: PlantSimulation) -> float:
	if not slot.is_growing():
		return -1.0
	var candidates: Array[float] = []
	var maturity_seconds := slot.get_estimated_seconds_to_mature()
	if maturity_seconds >= 0.0:
		candidates.append(maturity_seconds)
	var moisture_seconds := slot.get_estimated_seconds_until_moisture(CARE_CHECK_MOISTURE)
	if moisture_seconds >= 0.0:
		candidates.append(moisture_seconds)
	var nutrient_seconds := slot.get_estimated_seconds_until_nutrients(CARE_CHECK_NUTRIENTS)
	if nutrient_seconds >= 0.0:
		candidates.append(nutrient_seconds)
	var air_loss := 1.4 * slot.equipment_ventilation_decay_multiplier
	if air_loss > 0.0:
		candidates.append(maxf(0.0, (slot.ventilation - CARE_CHECK_VENTILATION) / air_loss * 3600.0))
	if candidates.is_empty():
		return 21600.0
	var next_seconds := candidates[0]
	for candidate in candidates:
		next_seconds = minf(next_seconds, candidate)
	return clampf(next_seconds, 0.0, 86400.0)


func _set_care_check(entry: Dictionary, seconds: float) -> void:
	entry.check_in_seconds = seconds
	if seconds < 0.0:
		entry.check_label = "BEZ PLÁNU"
	elif seconds <= 0.0:
		entry.check_label = "KONTROLA TEĎ"
	else:
		entry.check_label = "KONTROLA ZA %s" % format_care_duration(seconds).to_upper()


func _sort_care_entries(a: Dictionary, b: Dictionary) -> bool:
	var priority_a := int(a.get("priority", 0))
	var priority_b := int(b.get("priority", 0))
	if priority_a == priority_b:
		return int(a.get("slot_index", 0)) < int(b.get("slot_index", 0))
	return priority_a > priority_b


func get_level_reward(reward_level: int) -> Dictionary:
	if reward_level < 1 or reward_level > LEVEL_REWARDS.size():
		return {}
	return (LEVEL_REWARDS[reward_level - 1] as Dictionary).duplicate(true)


func get_level_unlocks(reward_level: int) -> Array[String]:
	var unlocks: Array[String] = []
	if reward_level >= 1 and reward_level <= MAX_PLANT_SLOTS:
		unlocks.append("Květináč %d" % reward_level)
	for equipment_id in EQUIPMENT_ORDER:
		var definition = EQUIPMENT_CATALOG.get(equipment_id, {})
		if not definition is Dictionary:
			continue
		var levels = (definition as Dictionary).get("levels", [])
		if not levels is Array:
			continue
		for level_data in levels:
			if level_data is Dictionary and int((level_data as Dictionary).get("unlock_level", -1)) == reward_level:
				unlocks.append("%s %d" % [str((definition as Dictionary).get("name", equipment_id)).capitalize(), int((level_data as Dictionary).get("level", 1))])
	for crop_id in GreenhouseSimulationScene.CROP_IDS:
		var crop := greenhouse.get_crop(crop_id)
		if int(crop.get("unlock_level", -1)) == reward_level:
			unlocks.append("Skleník: %s" % str(crop.get("short_name", crop_id)).capitalize())
	return unlocks


func is_level_reward_claimed(reward_level: int) -> bool:
	return reward_level in claimed_level_rewards


func can_claim_level_reward(reward_level: int) -> bool:
	return not get_level_reward(reward_level).is_empty() and reward_level <= get_level() and not is_level_reward_claimed(reward_level)


func get_claimable_level_reward_count() -> int:
	var count := 0
	for reward_level in range(1, LEVEL_REWARDS.size() + 1):
		if can_claim_level_reward(reward_level):
			count += 1
	return count


func claim_level_reward(reward_level: int) -> bool:
	var reward := get_level_reward(reward_level)
	if reward.is_empty():
		return false
	if reward_level > get_level():
		event_created.emit("Tato odměna se odemkne na úrovni %d." % reward_level)
		return false
	if is_level_reward_claimed(reward_level):
		event_created.emit("Odměna za úroveň %d už byla vyzvednuta." % reward_level)
		return false
	claimed_level_rewards.append(reward_level)
	claimed_level_rewards.sort()
	var reward_coins := int(reward.get("coins", 0))
	var reward_fertilizer := int(reward.get("fertilizer", 0))
	var raw_seed_rewards: Variant = reward.get("seed_rewards", {})
	var seed_rewards: Dictionary = raw_seed_rewards if raw_seed_rewards is Dictionary else {}
	var granted_seed_rewards: Dictionary = {}
	_change_coins(reward_coins, "level_reward")
	fertilizer_doses += reward_fertilizer
	for species_id in get_available_species():
		var seed_count := _sanitize_seed_count(seed_rewards.get(species_id, 0))
		var previous_seed_count := get_seed_count(species_id)
		if seed_count > 0 and _change_seed_count(species_id, seed_count):
			granted_seed_rewards[species_id] = get_seed_count(species_id) - previous_seed_count
	feedback_requested.emit("level_reward", selected_plant_index, {
		"level": reward_level,
		"coins": reward_coins,
		"fertilizer": reward_fertilizer,
		"seed_rewards": granted_seed_rewards,
	})
	event_created.emit("Odměna za úroveň %d byla připsána." % reward_level)
	return true


func get_equipment_level(equipment_id: String) -> int:
	if not EQUIPMENT_CATALOG.has(equipment_id):
		return 0
	return clampi(int(equipment_levels.get(equipment_id, 1)), 1, EQUIPMENT_MAX_LEVEL)


func get_equipment_level_data(equipment_id: String, requested_level := 0) -> Dictionary:
	var definition = EQUIPMENT_CATALOG.get(equipment_id, {})
	if not definition is Dictionary:
		return {}
	var levels = (definition as Dictionary).get("levels", [])
	if not levels is Array or (levels as Array).is_empty():
		return {}
	var resolved_level := get_equipment_level(equipment_id) if requested_level <= 0 else clampi(requested_level, 1, EQUIPMENT_MAX_LEVEL)
	return ((levels as Array)[resolved_level - 1] as Dictionary).duplicate(true)


func get_equipment_upgrade_state(equipment_id: String) -> Dictionary:
	var definition = EQUIPMENT_CATALOG.get(equipment_id, {})
	if not definition is Dictionary:
		return {}
	var level := get_equipment_level(equipment_id)
	var is_max := level >= EQUIPMENT_MAX_LEVEL
	var current := get_equipment_level_data(equipment_id, level)
	var next := {} if is_max else get_equipment_level_data(equipment_id, level + 1)
	var unlock_level := int(next.get("unlock_level", 1))
	var price := int(next.get("price", 0))
	return {
		"id": equipment_id,
		"name": str((definition as Dictionary).get("name", equipment_id)),
		"level": level,
		"max_level": EQUIPMENT_MAX_LEVEL,
		"is_max": is_max,
		"current_effect": str(current.get("effect", "")),
		"next_effect": str(next.get("effect", "")),
		"unlock_level": unlock_level,
		"price": price,
		"unlocked": is_max or get_level() >= unlock_level,
		"affordable": is_max or coins >= price,
	}


func buy_equipment_upgrade(equipment_id: String) -> bool:
	var state := get_equipment_upgrade_state(equipment_id)
	if state.is_empty():
		event_created.emit("Tuto pomůcku pan Kořínek nezná.")
		return false
	if bool(state.get("is_max", false)):
		event_created.emit("%s už má nejvyšší úroveň." % str(state.get("name", "Pomůcka")))
		return false
	if not bool(state.get("unlocked", false)):
		event_created.emit("Další úroveň se odemkne na úrovni hráče %d." % int(state.get("unlock_level", 1)))
		return false
	var price := int(state.get("price", 0))
	if coins < price:
		event_created.emit("Na vylepšení potřebuješ %d mincí." % price)
		return false
	var next_level := int(state.get("level", 1)) + 1
	equipment_levels[equipment_id] = next_level
	_sync_equipment_effects()
	for slot in plants:
		slot.sync_environment(world_elapsed_seconds)
	_change_coins(-price, "equipment_upgrade")
	feedback_requested.emit("purchase", selected_plant_index, {"item": "equipment", "equipment_id": equipment_id, "level": next_level})
	event_created.emit("%s je teď na úrovni %d." % [str(state.get("name", "Pomůcka")).capitalize(), next_level])
	return true


func _sync_equipment_effects() -> void:
	for slot in plants:
		_apply_equipment_to_plant(slot)


func _apply_equipment_to_plant(slot: PlantSimulation) -> void:
	if slot == null:
		return
	var lamp := get_equipment_level_data("grow_lamp")
	var fan := get_equipment_level_data("ventilation_fan")
	var spray := get_equipment_level_data("protective_spray")
	var pot := get_equipment_level_data("self_watering_pot")
	slot.configure_equipment({
		"lamp_lux": float(lamp.get("lamp_lux", 11500.0)),
		"ventilation_decay_multiplier": float(fan.get("ventilation_decay_multiplier", 1.0)),
		"disease_gain_multiplier": float(spray.get("disease_gain_multiplier", 1.0)),
		"water_loss_multiplier": float(pot.get("water_loss_multiplier", 1.0)),
		"harvest_yield_multiplier": float(pot.get("harvest_yield_multiplier", 1.0)),
	})


func visit_screen(screen_index: int) -> void:
	if screen_index not in visited_screens:
		visited_screens.append(screen_index)
	if screen_index == 3:
		_advance_journey(JourneyStep.VISIT_MEASUREMENTS, JourneyStep.GROW_TO_MATURE)


func get_journey_step_id() -> String:
	match journey_step:
		JourneyStep.PLANT_SEED: return "plant_seed"
		JourneyStep.WATER_PLANT: return "water_plant"
		JourneyStep.VISIT_MEASUREMENTS: return "visit_measurements"
		JourneyStep.GROW_TO_MATURE: return "grow_to_mature"
		JourneyStep.HARVEST: return "harvest"
		JourneyStep.START_DRYING: return "start_drying"
		JourneyStep.WAIT_FOR_DRYING: return "wait_for_drying"
		JourneyStep.PACKAGE: return "package"
		JourneyStep.SELL: return "sell"
		JourneyStep.COMPLETE: return "complete"
	return "unknown"


func get_journey_title() -> String:
	match journey_step:
		JourneyStep.PLANT_SEED: return "Zasaď první semínko"
		JourneyStep.WATER_PLANT: return "Dej bazalce první zálivku"
		JourneyStep.VISIT_MEASUREMENTS: return "Podívej se do měření"
		JourneyStep.GROW_TO_MATURE: return "Udrž dobré podmínky"
		JourneyStep.HARVEST: return "Sklidit zralou bazalku"
		JourneyStep.START_DRYING: return "Přesuň sklizeň do sušárny"
		JourneyStep.WAIT_FOR_DRYING: return "Nech listy dosušit"
		JourneyStep.PACKAGE: return "Zabal usušenou bazalku"
		JourneyStep.SELL: return "Prodej první balíček"
		JourneyStep.COMPLETE: return "První pěstitelský cyklus hotov"
	return "Další krok"


func get_journey_body() -> String:
	match journey_step:
		JourneyStep.PLANT_SEED: return "Otevři první květináč a klepni na ZASADIT. Jeden statečný lístek začíná pod hlínou."
		JourneyStep.WATER_PLANT: return "Zalij 120 ml. Vlhká půda ano, bazén pro kořeny ne."
		JourneyStep.VISIT_MEASUREMENTS: return "Otevři záložku MĚŘENÍ. Hodnoty ti řeknou proč rostlina prospívá nebo strádá."
		JourneyStep.GROW_TO_MATURE: return "Sleduj vlhkost, světlo a vzduch. Rostlina pokračuje v růstu i po zavření hry."
		JourneyStep.HARVEST: return "Bazalka je připravená. Ve SKLADU spusť sklizeň, dokud jsou listy v nejlepší kondici."
		JourneyStep.START_DRYING: return "Ve SKLADU zahaj sušení. Teď pracuje čas a proudění vzduchu."
		JourneyStep.WAIT_FOR_DRYING: return "Počkej na 100% sušení. Proces pokračuje i po zavření hry; mokré listy do sáčku nepatří."
		JourneyStep.PACKAGE: return "Usušenou bazalku zabal ve SKLADU. Teprve balíček může na trh."
		JourneyStep.SELL: return "Prodej hotový balíček. Mince a XP rozjedou další květináče."
		JourneyStep.COMPLETE: return "Umíš celý cyklus: péče, sklizeň, zpracování i prodej. Teď buduj vlastní bylinkovou dílnu."
	return "Sleduj stav rostliny a udělej další logický krok."


func get_journey_target_screen() -> int:
	match journey_step:
		JourneyStep.VISIT_MEASUREMENTS: return 3
		JourneyStep.HARVEST, JourneyStep.START_DRYING, JourneyStep.WAIT_FOR_DRYING, JourneyStep.PACKAGE, JourneyStep.SELL: return 1
		_: return 0


func get_journey_progress() -> float:
	return 1.0 if journey_completed else float(journey_step) / float(JourneyStep.COMPLETE)


func get_journey_dialog_text() -> String:
	var step_number := mini(int(journey_step) + 1, int(JourneyStep.COMPLETE))
	if journey_completed:
		return "%s\n%s" % [get_journey_title(), get_journey_body()]
	return "ÚKOL %d/%d · %s\n%s" % [step_number, int(JourneyStep.COMPLETE), get_journey_title(), get_journey_body()]


func _advance_slot(index: int, seconds: float, environment_start_seconds := -1.0, suppress_mature_lifecycle := false, collect_offline_event := false) -> void:
	var slot := plants[index]
	var previous_stage := slot.stage
	var previous_wilted := slot.is_wilted()
	slot.advance(seconds, environment_start_seconds, suppress_mature_lifecycle)
	var became_wilted := not previous_wilted and slot.is_wilted()
	var became_dead := previous_stage != PlantSimulation.Stage.DEAD and slot.stage == PlantSimulation.Stage.DEAD
	if collect_offline_event:
		var outcome := ""
		if became_dead:
			outcome = "dead"
		elif became_wilted:
			outcome = "wilted"
		elif previous_stage != PlantSimulation.Stage.MATURE and slot.stage == PlantSimulation.Stage.MATURE:
			outcome = "matured"
		elif previous_stage != PlantSimulation.Stage.DRY and slot.stage == PlantSimulation.Stage.DRY:
			outcome = "drying_complete"
		if not outcome.is_empty():
			_offline_lifecycle_events.append({
				"kind": outcome,
				"slot_index": index,
				"slot_number": index + 1,
				"species_name": slot.get_short_name(),
			})
	elif became_dead:
		feedback_requested.emit("plant_dead", index, {"species_name": slot.get_short_name()})
	elif became_wilted:
		feedback_requested.emit("plant_wilted", index, {
			"species_name": slot.get_short_name(),
			"seconds_until_death": slot.get_seconds_until_death(),
		})
	if slot.stage == previous_stage:
		return
	if not collect_offline_event:
		feedback_requested.emit("growth_stage", index, {"from": int(previous_stage), "to": int(slot.stage), "stage_name": slot.get_stage_name()})
	if index != selected_plant_index:
		return
	if slot.stage == PlantSimulation.Stage.MATURE:
		feedback_requested.emit("growth", index, {"growth": slot.growth_percent})
		_advance_journey(JourneyStep.GROW_TO_MATURE, JourneyStep.HARVEST)
	elif slot.stage == PlantSimulation.Stage.DRY:
		_advance_journey(JourneyStep.WAIT_FOR_DRYING, JourneyStep.PACKAGE)


func _grant_xp(amount: int, source: String) -> void:
	if amount <= 0:
		return
	var previous_level := get_level()
	xp += amount
	var current_level := get_level()
	feedback_requested.emit("xp", selected_plant_index, {"amount": amount, "source": source, "level": current_level})
	if current_level <= previous_level:
		return
	for level in range(previous_level + 1, current_level + 1):
		var slot_index := level - 1
		if slot_index >= 0 and slot_index < MAX_PLANT_SLOTS:
			slot_unlocked.emit(slot_index, level)
			feedback_requested.emit("unlock", slot_index, {"level": level})


func _change_coins(delta: int, source: String) -> void:
	if delta == 0:
		return
	coins += delta
	feedback_requested.emit("coins" if delta > 0 else "spend", selected_plant_index, {"amount": delta, "source": source})


func _advance_journey(expected_step: int, next_step: int) -> bool:
	if journey_completed or journey_step != expected_step:
		return false
	var previous_step := journey_step
	journey_step = next_step
	journey_changed.emit(journey_step, previous_step)
	feedback_requested.emit("objective", selected_plant_index, {"step": get_journey_step_id(), "target_screen": get_journey_target_screen()})
	return true


func get_room_theme(theme_id: String) -> Dictionary:
	return ROOM_THEMES.get(theme_id, ROOM_THEMES.sunrise).duplicate(true)


func is_room_theme_unlocked(theme_id: String) -> bool:
	return ROOM_THEMES.has(theme_id) and theme_id in unlocked_room_themes


func get_room_theme_unlock_state(theme_id: String) -> Dictionary:
	if not ROOM_THEMES.has(theme_id):
		return {
			"known": false,
			"unlocked": false,
			"selected": false,
			"can_unlock": false,
			"reason": "unknown",
			"price": 0,
			"progress_current": 0,
			"progress_target": 0,
		}
	var theme: Dictionary = ROOM_THEMES[theme_id]
	var unlocked := is_room_theme_unlocked(theme_id)
	var selected := unlocked and selected_room_theme == theme_id
	var price := maxi(0, int(theme.get("price", 0)))
	var progress_target := maxi(0, int(theme.get("research_completed_required", 0)))
	var research_completed := get_professor_research_completed_count()
	var progress_current := mini(research_completed, progress_target) if progress_target > 0 else 0
	var reason := "selected" if selected else ("unlocked" if unlocked else "available")
	if not unlocked and progress_current < progress_target:
		reason = "research_required"
	elif not unlocked and coins < price:
		reason = "insufficient_coins"
	return {
		"known": true,
		"unlocked": unlocked,
		"selected": selected,
		"can_unlock": reason == "available",
		"reason": reason,
		"price": price,
		"progress_current": progress_current,
		"progress_target": progress_target,
	}


func unlock_or_select_room_theme(theme_id: String) -> bool:
	var unlock_state := get_room_theme_unlock_state(theme_id)
	if not bool(unlock_state.get("known", false)):
		return false
	if bool(unlock_state.get("unlocked", false)):
		selected_room_theme = theme_id
		return true
	if not bool(unlock_state.get("can_unlock", false)):
		return false
	var price := int(unlock_state.get("price", 0))
	coins -= price
	unlocked_room_themes.append(theme_id)
	selected_room_theme = theme_id
	feedback_requested.emit("coins", selected_plant_index, {"amount": -price, "cosmetic": theme_id})
	return true


func get_room_decoration_ids() -> Array[String]:
	var result: Array[String] = []
	result.assign(ROOM_DECORATION_IDS)
	return result


func get_room_decoration(decoration_id: String) -> Dictionary:
	if not ROOM_DECORATIONS.has(decoration_id):
		return {}
	return (ROOM_DECORATIONS[decoration_id] as Dictionary).duplicate(true)


func get_room_decoration_slot_group(slot_index: int) -> String:
	if slot_index < 0 or slot_index >= ROOM_DECORATION_SLOT_COUNT:
		return ""
	return ROOM_DECORATION_SLOT_GROUPS[slot_index]


func get_room_decoration_slot_label(slot_index: int) -> String:
	if slot_index == PHASE159_RETIRED_POTS_SLOT_INDEX:
		return "VYŘAZENÉ MÍSTO"
	var group := get_room_decoration_slot_group(slot_index)
	match group:
		"plant":
			return "ROSTLINA %d/%d" % [slot_index + 1, ROOM_PLANT_SLOT_COUNT]
		"books":
			return "KNIHY"
		"fertilizer":
			return "HNOJIVA"
		"pots":
			return "KVĚTINÁČE"
		"lamp":
			return "BOTANICKÉ TERÁRIUM"
		"art":
			return "BOTANICKÝ OBRAZ"
		"watering_can":
			return "KONVIČKA"
		"herb_jars":
			return "BYLINKOVÉ SKLENICE"
		"pet_corner":
			return "KOČIČÍ KOUTEK"
		_:
			return "NEPLATNÉ MÍSTO"


func is_room_decoration_compatible(decoration_id: String, slot_index: int) -> bool:
	if not ROOM_DECORATIONS.has(decoration_id):
		return false
	var slot_group := get_room_decoration_slot_group(slot_index)
	if slot_group.is_empty():
		return false
	return str((ROOM_DECORATIONS[decoration_id] as Dictionary).get("slot_group", "")) == slot_group


func get_room_decoration_ids_for_slot(slot_index: int) -> Array[String]:
	var result: Array[String] = []
	for decoration_id in ROOM_DECORATION_IDS:
		if decoration_id in RETIRED_ROOM_DECORATION_IDS or decoration_id in DORMANT_ROOM_DECORATION_IDS:
			continue
		if is_room_decoration_compatible(decoration_id, slot_index):
			result.append(decoration_id)
	return result


func get_room_decoration_slots() -> Array[String]:
	var result: Array[String] = []
	result.assign(room_decoration_slots)
	return result


func is_room_decoration_owned(decoration_id: String) -> bool:
	return ROOM_DECORATIONS.has(decoration_id) and decoration_id in owned_room_decorations


func get_room_decoration_slot_index(decoration_id: String) -> int:
	if not ROOM_DECORATIONS.has(decoration_id):
		return -1
	return room_decoration_slots.find(decoration_id)


func get_room_decoration_action_state(decoration_id: String, slot_index: int) -> Dictionary:
	var valid_slot := slot_index >= 0 and slot_index < ROOM_DECORATION_SLOT_COUNT
	var compatible := valid_slot and is_room_decoration_compatible(decoration_id, slot_index)
	if decoration_id in RETIRED_ROOM_DECORATION_IDS:
		return {
			"known": ROOM_DECORATIONS.has(decoration_id),
			"valid_slot": valid_slot,
			"compatible": false,
			"owned": is_room_decoration_owned(decoration_id),
			"placed_slot": get_room_decoration_slot_index(decoration_id),
			"placed_here": false,
			"can_apply": false,
			"reason": "retired",
			"price": 0,
		}
	if decoration_id in DORMANT_ROOM_DECORATION_IDS:
		var dormant_placed_slot := get_room_decoration_slot_index(decoration_id)
		return {
			"known": ROOM_DECORATIONS.has(decoration_id),
			"valid_slot": valid_slot,
			"compatible": compatible,
			"owned": is_room_decoration_owned(decoration_id),
			"placed_slot": dormant_placed_slot,
			"placed_here": dormant_placed_slot == slot_index,
			"can_apply": false,
			"reason": "reserved_for_redesign",
			"price": 0,
		}
	if not ROOM_DECORATIONS.has(decoration_id) or not valid_slot or not compatible:
		return {
			"known": ROOM_DECORATIONS.has(decoration_id),
			"valid_slot": valid_slot,
			"compatible": compatible,
			"owned": false,
			"placed_slot": -1,
			"placed_here": false,
			"can_apply": false,
			"reason": "invalid_slot" if not valid_slot else ("incompatible_slot" if not compatible else "unknown"),
			"price": 0,
		}
	var decoration: Dictionary = ROOM_DECORATIONS[decoration_id]
	var price := maxi(0, int(decoration.get("price", 0)))
	var owned := is_room_decoration_owned(decoration_id)
	var placed_slot := get_room_decoration_slot_index(decoration_id)
	var placed_here := placed_slot == slot_index
	var reason := "placed_here" if placed_here else ("move" if owned and placed_slot >= 0 else ("place" if owned else "available"))
	if not owned and coins < price:
		reason = "insufficient_coins"
	return {
		"known": true,
		"valid_slot": true,
		"compatible": true,
		"owned": owned,
		"placed_slot": placed_slot,
		"placed_here": placed_here,
		"can_apply": reason in ["available", "place", "move"],
		"reason": reason,
		"price": price,
	}


func purchase_or_place_room_decoration(decoration_id: String, slot_index: int) -> bool:
	var state := get_room_decoration_action_state(decoration_id, slot_index)
	if not bool(state.get("can_apply", false)):
		return false
	var purchased := not bool(state.get("owned", false))
	if purchased:
		var price := int(state.get("price", 0))
		if coins < price:
			return false
		_change_coins(-price, "room_decoration")
		owned_room_decorations.append(decoration_id)
	for existing_slot in range(room_decoration_slots.size()):
		if room_decoration_slots[existing_slot] == decoration_id:
			room_decoration_slots[existing_slot] = ""
	room_decoration_slots[slot_index] = decoration_id
	return true


func move_room_plant(source_slot: int, target_slot: int, expected_id: String) -> bool:
	# Dragging is not a purchase or the modal's intentional replacement action.
	# Validate both final placements before moving either end. An occupied
	# target returns to the source slot; no owned plant is silently displaced.
	if source_slot < 0 or source_slot >= ROOM_PLANT_SLOT_COUNT or target_slot < 0 or target_slot >= ROOM_PLANT_SLOT_COUNT:
		return false
	if source_slot == target_slot or expected_id.is_empty():
		return false
	if room_decoration_slots[source_slot] != expected_id:
		return false
	if not is_room_decoration_owned(expected_id) or not is_room_decoration_compatible(expected_id, target_slot):
		return false
	var displaced_id := room_decoration_slots[target_slot]
	if displaced_id == expected_id:
		return false
	if not displaced_id.is_empty() and (not is_room_decoration_owned(displaced_id) or not is_room_decoration_compatible(displaced_id, source_slot)):
		return false
	room_decoration_slots[source_slot] = displaced_id
	room_decoration_slots[target_slot] = expected_id
	return true


func clear_room_decoration_slot(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= room_decoration_slots.size():
		return false
	var decoration_id := room_decoration_slots[slot_index]
	if decoration_id.is_empty():
		return false
	room_decoration_slots[slot_index] = ""
	return true


func _empty_room_decoration_slots() -> Array[String]:
	var result: Array[String] = []
	result.resize(ROOM_DECORATION_SLOT_COUNT)
	result.fill("")
	return result


func _room_decoration_authorized_for_schema(decoration_id: String, stored_schema: int) -> bool:
	if decoration_id in LEGACY_ROOM_DECORATION_IDS:
		return stored_schema >= ROOM_DECORATION_SCHEMA
	if decoration_id in PHASE123_ROOM_DECORATION_IDS:
		return stored_schema >= ROOM_COLLECTION_SCHEMA
	if decoration_id in PHASE141_ROOM_PLANT_IDS:
		return stored_schema >= ROOM_FINAL_RACK_PLANTS_SCHEMA
	return ROOM_DECORATIONS.has(decoration_id) and stored_schema >= ROOM_LIVING_DETAILS_SCHEMA


func _first_empty_compatible_room_slot(decoration_id: String) -> int:
	for slot_index in range(ROOM_DECORATION_SLOT_COUNT):
		if room_decoration_slots[slot_index].is_empty() and is_room_decoration_compatible(decoration_id, slot_index):
			return slot_index
	return -1


func _normalize_phase159_botanical_cloche_legacy_state() -> void:
	var legacy_owned := PHASE159_LEGACY_POTS_ID in owned_room_decorations
	if not legacy_owned:
		return
	var legacy_was_placed := room_decoration_slots.find(PHASE159_LEGACY_POTS_ID) >= 0
	if PHASE159_BOTANICAL_CLOCHE_ID not in owned_room_decorations:
		owned_room_decorations.append(PHASE159_BOTANICAL_CLOCHE_ID)
	for slot_index in range(room_decoration_slots.size()):
		if room_decoration_slots[slot_index] == PHASE159_LEGACY_POTS_ID:
			room_decoration_slots[slot_index] = ""
	if (
			legacy_was_placed
			and room_decoration_slots.find(PHASE159_BOTANICAL_CLOCHE_ID) < 0
			and PHASE159_BOTANICAL_CLOCHE_SLOT_INDEX < room_decoration_slots.size()
	):
		room_decoration_slots[PHASE159_BOTANICAL_CLOCHE_SLOT_INDEX] = PHASE159_BOTANICAL_CLOCHE_ID


func get_greenhouse_crop_catalog() -> Dictionary:
	var catalog := greenhouse.get_crop_catalog()
	for crop_id in catalog:
		var crop := (catalog[crop_id] as Dictionary).duplicate(true)
		crop["unlocked"] = is_greenhouse_crop_unlocked(str(crop_id))
		catalog[crop_id] = crop
	return catalog


func get_greenhouse_crop_unlock_level(crop_id: String) -> int:
	var crop := greenhouse.get_crop(crop_id)
	if crop.is_empty():
		return -1
	return maxi(1, int(crop.get("unlock_level", 1)))


func is_greenhouse_crop_unlocked(crop_id: String) -> bool:
	var unlock_level := get_greenhouse_crop_unlock_level(crop_id)
	return unlock_level > 0 and get_level() >= unlock_level


func get_greenhouse_beds() -> Array[Dictionary]:
	return greenhouse.get_beds()


func get_greenhouse_bed_state(slot_index: int) -> Dictionary:
	return greenhouse.get_bed_state(slot_index, coins)


func get_greenhouse_bed_states() -> Array[Dictionary]:
	var states: Array[Dictionary] = []
	for slot_index in range(GreenhouseSimulationScene.BED_COUNT):
		states.append(get_greenhouse_bed_state(slot_index))
	return states


func get_greenhouse_attention_summary() -> Dictionary:
	var needs_water := 0
	var ready := 0
	for state in get_greenhouse_bed_states():
		match str(state.get("stage", "invalid")):
			"needs_water":
				needs_water += 1
			"ready":
				ready += 1
	return {
		"needs_water": needs_water,
		"ready": ready,
		"action_count": needs_water + ready,
	}


func get_greenhouse_order_state() -> Dictionary:
	_ensure_greenhouse_order()
	var state := greenhouse_order.duplicate(true)
	var crop_id := str(state.get("crop_id", ""))
	var crop := greenhouse.get_crop(crop_id)
	state["crop"] = crop
	state["crop_name"] = str(crop.get("name", crop_id))
	state["crop_short_name"] = str(crop.get("short_name", crop_id)).to_upper()
	state["remaining_harvests"] = maxi(0, int(state.get("target_harvests", 1)) - int(state.get("progress", 0)))
	state["completed_count"] = greenhouse_orders_completed
	state["reputation"] = get_greenhouse_reputation_state()
	return state


func _get_greenhouse_reputation_tier_for_count(completed_count: int) -> int:
	var tier := 0
	var safe_count := clampi(completed_count, 0, GREENHOUSE_ORDER_MAX_COMPLETIONS)
	for raw_milestone in GREENHOUSE_REPUTATION_MILESTONES:
		var milestone: Dictionary = raw_milestone
		if safe_count < int(milestone.get("target_orders", GREENHOUSE_ORDER_MAX_COMPLETIONS)):
			break
		tier = int(milestone.get("tier", tier))
	return clampi(tier, 0, GREENHOUSE_REPUTATION_MILESTONES.size())


func _get_greenhouse_reputation_milestone(tier: int) -> Dictionary:
	if tier < 1 or tier > GREENHOUSE_REPUTATION_MILESTONES.size():
		return {}
	return (GREENHOUSE_REPUTATION_MILESTONES[tier - 1] as Dictionary).duplicate(true)


func get_greenhouse_reputation_state() -> Dictionary:
	var completed_count := clampi(greenhouse_orders_completed, 0, GREENHOUSE_ORDER_MAX_COMPLETIONS)
	var earned_tier := _get_greenhouse_reputation_tier_for_count(completed_count)
	var tier := clampi(greenhouse_reputation_claimed_tier, 0, earned_tier)
	var current_title := "NOVÝ PĚSTITEL"
	if tier > 0:
		current_title = str(_get_greenhouse_reputation_milestone(tier).get("title", current_title))
	var is_max := tier >= GREENHOUSE_REPUTATION_MILESTONES.size()
	var next_milestone := {} if is_max else _get_greenhouse_reputation_milestone(tier + 1)
	var next_target := completed_count if is_max else int(next_milestone.get("target_orders", completed_count))
	return {
		"tier": tier,
		"title": current_title,
		"completed_orders": completed_count,
		"is_max": is_max,
		"next_tier": tier if is_max else tier + 1,
		"next_title": current_title if is_max else str(next_milestone.get("title", "")),
		"next_target": next_target,
		"next_reward_coins": 0 if is_max else int(next_milestone.get("reward_coins", 0)),
		"next_reward_xp": 0 if is_max else int(next_milestone.get("reward_xp", 0)),
		"cosmetic_sign": str(_get_greenhouse_reputation_milestone(tier).get("cosmetic_sign", "")) if tier > 0 else "",
		"sign_top": "MISTR" if is_max else "POVĚST",
		"sign_bottom": "SKLENÍKU" if is_max else "%d/%d ZAK." % [mini(completed_count, next_target), next_target],
	}


func _claim_new_greenhouse_reputation_milestones() -> Array[Dictionary]:
	var claims: Array[Dictionary] = []
	var earned_tier := _get_greenhouse_reputation_tier_for_count(greenhouse_orders_completed)
	while greenhouse_reputation_claimed_tier < earned_tier:
		var next_tier := greenhouse_reputation_claimed_tier + 1
		var milestone := _get_greenhouse_reputation_milestone(next_tier)
		if milestone.is_empty():
			break
		greenhouse_reputation_claimed_tier = next_tier
		var reward_coins := int(milestone.get("reward_coins", 0))
		var reward_xp := int(milestone.get("reward_xp", 0))
		if reward_coins > 0:
			_change_coins(reward_coins, "greenhouse_reputation")
		if reward_xp > 0:
			_grant_xp(reward_xp, "greenhouse_reputation")
		claims.append(milestone)
	return claims


func _get_greenhouse_order_template(crop_id: String) -> Dictionary:
	for raw_template in GREENHOUSE_ORDER_TEMPLATES:
		var template: Dictionary = raw_template
		if str(template.get("crop_id", "")) == crop_id:
			return template
	return {}


func _build_greenhouse_order(sequence: int) -> Dictionary:
	var safe_sequence := _sanitize_order_sequence(sequence, 0)
	for offset in range(GREENHOUSE_ORDER_TEMPLATES.size()):
		var template: Dictionary = GREENHOUSE_ORDER_TEMPLATES[posmod(safe_sequence + offset, GREENHOUSE_ORDER_TEMPLATES.size())]
		if not is_greenhouse_crop_unlocked(str(template.get("crop_id", ""))):
			continue
		var order := template.duplicate(true)
		order["id"] = "greenhouse_order_%04d" % safe_sequence
		order["sequence"] = safe_sequence
		order["progress"] = 0
		_apply_greenhouse_order_tier(order, GREENHOUSE_ORDER_TIER_MULTI_BED if _is_greenhouse_multi_bed_sequence(safe_sequence, int(order.get("target_harvests", 1))) else GREENHOUSE_ORDER_TIER_STANDARD)
		return order
	# Tomato is available from level one; this is only a defensive fallback for
	# malformed catalog changes.
	var fallback: Dictionary = GREENHOUSE_ORDER_TEMPLATES[0].duplicate(true)
	fallback["id"] = "greenhouse_order_%04d" % safe_sequence
	fallback["sequence"] = safe_sequence
	fallback["progress"] = 0
	_apply_greenhouse_order_tier(fallback, GREENHOUSE_ORDER_TIER_MULTI_BED if _is_greenhouse_multi_bed_sequence(safe_sequence, int(fallback.get("target_harvests", 1))) else GREENHOUSE_ORDER_TIER_STANDARD)
	return fallback


func _is_greenhouse_multi_bed_sequence(sequence: int, target_harvests: int) -> bool:
	return target_harvests == 2 and posmod(sequence, 2) == 1


func _apply_greenhouse_order_tier(order: Dictionary, requested_tier: String) -> void:
	var sequence := _sanitize_order_sequence(order.get("sequence", 0), 0)
	var target := maxi(1, int(order.get("target_harvests", 1)))
	var tier := GREENHOUSE_ORDER_TIER_STANDARD
	if requested_tier == GREENHOUSE_ORDER_TIER_MULTI_BED and _is_greenhouse_multi_bed_sequence(sequence, target):
		tier = GREENHOUSE_ORDER_TIER_MULTI_BED
	order["quality_tier"] = tier
	order["required_distinct_beds"] = target if tier == GREENHOUSE_ORDER_TIER_MULTI_BED else 0
	order["credited_bed_indices"] = []
	if tier == GREENHOUSE_ORDER_TIER_MULTI_BED:
		order["bonus_coins"] = int(order.get("bonus_coins", 0)) + GREENHOUSE_MULTI_BED_BONUS_COINS
		order["bonus_xp"] = int(order.get("bonus_xp", 0)) + GREENHOUSE_MULTI_BED_BONUS_XP


func _ensure_greenhouse_order() -> void:
	if not greenhouse_order.is_empty():
		var sanitized := _sanitize_greenhouse_order(greenhouse_order)
		if not sanitized.is_empty():
			greenhouse_order = sanitized
			greenhouse_order_rotation = maxi(
				_sanitize_order_sequence(greenhouse_order_rotation, 0),
				_next_order_sequence(int(greenhouse_order.get("sequence", 0)))
			)
			return
		greenhouse_order.clear()
	var sequence := _sanitize_order_sequence(greenhouse_order_rotation, 0)
	greenhouse_order = _build_greenhouse_order(sequence)
	greenhouse_order_rotation = _next_order_sequence(sequence)


func _sanitize_greenhouse_order(raw: Variant, authorize_quality_tier := true) -> Dictionary:
	if not raw is Dictionary:
		return {}
	var raw_order: Dictionary = raw
	var crop_id := str(raw_order.get("crop_id", ""))
	var template := _get_greenhouse_order_template(crop_id)
	if template.is_empty() or not is_greenhouse_crop_unlocked(crop_id):
		return {}
	var sequence := _sanitize_order_sequence(raw_order.get("sequence", greenhouse_order_rotation), greenhouse_order_rotation)
	var order := template.duplicate(true)
	var target := maxi(1, int(order.get("target_harvests", 1)))
	order["id"] = "greenhouse_order_%04d" % sequence
	order["sequence"] = sequence
	var requested_tier := str(raw_order.get("quality_tier", GREENHOUSE_ORDER_TIER_STANDARD)) if authorize_quality_tier else GREENHOUSE_ORDER_TIER_STANDARD
	_apply_greenhouse_order_tier(order, requested_tier)
	if str(order.get("quality_tier", GREENHOUSE_ORDER_TIER_STANDARD)) == GREENHOUSE_ORDER_TIER_MULTI_BED:
		var credited_beds: Array[int] = []
		var raw_credited = raw_order.get("credited_bed_indices", [])
		if raw_credited is Array:
			for raw_index in raw_credited:
				var bed_index := _sanitize_int(raw_index, -1)
				if bed_index >= 0 and bed_index < GreenhouseSimulationScene.BED_COUNT and bed_index not in credited_beds and credited_beds.size() < target - 1:
					credited_beds.append(bed_index)
		order["credited_bed_indices"] = credited_beds
		order["progress"] = credited_beds.size()
	else:
		order["progress"] = clampi(_sanitize_nonnegative_int(raw_order.get("progress", 0), 0), 0, target - 1)
	return order


func _record_greenhouse_order_harvest(crop_id: String, bed_index := -1) -> Dictionary:
	_ensure_greenhouse_order()
	if crop_id != str(greenhouse_order.get("crop_id", "")):
		return {"matched": false, "credited": false, "completed": false}
	var completed_order := greenhouse_order.duplicate(true)
	var target := maxi(1, int(completed_order.get("target_harvests", 1)))
	var credited := true
	var progress := 0
	if str(completed_order.get("quality_tier", GREENHOUSE_ORDER_TIER_STANDARD)) == GREENHOUSE_ORDER_TIER_MULTI_BED:
		var credited_beds: Array[int] = []
		for raw_index in completed_order.get("credited_bed_indices", []):
			credited_beds.append(int(raw_index))
		if bed_index < 0 or bed_index >= GreenhouseSimulationScene.BED_COUNT or bed_index in credited_beds:
			credited = false
			progress = credited_beds.size()
		else:
			credited_beds.append(bed_index)
			progress = mini(target, credited_beds.size())
			greenhouse_order["credited_bed_indices"] = credited_beds.duplicate()
	else:
		progress = mini(target, int(completed_order.get("progress", 0)) + 1)
	if not credited:
		return {
			"matched": true,
			"credited": false,
			"completed": false,
			"progress": progress,
			"target_harvests": target,
			"quality_tier": str(completed_order.get("quality_tier", GREENHOUSE_ORDER_TIER_STANDARD)),
		}
	if progress < target:
		greenhouse_order["progress"] = progress
		return {
			"matched": true,
			"credited": true,
			"completed": false,
			"progress": progress,
			"target_harvests": target,
			"quality_tier": str(completed_order.get("quality_tier", GREENHOUSE_ORDER_TIER_STANDARD)),
		}
	completed_order["progress"] = target
	greenhouse_orders_completed = mini(GREENHOUSE_ORDER_MAX_COMPLETIONS, greenhouse_orders_completed + 1)
	var next_sequence := _sanitize_order_sequence(greenhouse_order_rotation, _next_order_sequence(int(completed_order.get("sequence", 0))))
	greenhouse_order = _build_greenhouse_order(next_sequence)
	greenhouse_order_rotation = _next_order_sequence(next_sequence)
	completed_order["matched"] = true
	completed_order["credited"] = true
	completed_order["completed"] = true
	return completed_order


func plant_greenhouse_crop(slot_index: int, crop_id: String) -> bool:
	var state := get_greenhouse_bed_state(slot_index)
	if not bool(state.get("valid", false)) or str(state.get("stage", "")) != "empty":
		return false
	var crop := greenhouse.get_crop(crop_id)
	if crop.is_empty():
		return false
	if not is_greenhouse_crop_unlocked(crop_id):
		event_created.emit("Plodina %s se odemkne na úrovni %d." % [str(crop.get("name", crop_id)).to_lower(), get_greenhouse_crop_unlock_level(crop_id)])
		return false
	var price := int(crop.get("seed_price", 0))
	if price < 0 or coins < price or not greenhouse.plant(slot_index, crop_id):
		return false
	_change_coins(-price, "greenhouse_plant")
	feedback_requested.emit("growth", selected_plant_index, {"source": "greenhouse", "bed_index": slot_index, "action": "plant", "crop_id": crop_id})
	event_created.emit("Záhon %d: zasazena plodina %s. Teď ji zalij." % [slot_index + 1, str(crop.get("name", crop_id)).to_lower()])
	return true


func perform_greenhouse_bed_action(slot_index: int) -> bool:
	var state := get_greenhouse_bed_state(slot_index)
	if not bool(state.get("valid", false)) or not bool(state.get("can_action", false)):
		return false
	var action := str(state.get("action", "none"))
	var crop_id := str(state.get("crop_id", ""))
	var crop := state.get("crop", {}) as Dictionary
	match action:
		"plant":
			return plant_greenhouse_crop(slot_index, GreenhouseSimulationScene.CROP_IDS[0])
		"water":
			if not greenhouse.water(slot_index):
				return false
			feedback_requested.emit("water", selected_plant_index, {"source": "greenhouse", "bed_index": slot_index, "action": "water"})
			event_created.emit("Záhon %d je zalitý. %s začíná růst." % [slot_index + 1, str(crop.get("name", crop_id))])
			return true
		"harvest":
			var harvest_result := greenhouse.harvest(slot_index)
			if harvest_result.is_empty():
				return false
			var reward_coins := int(harvest_result.get("reward_coins", 0))
			var reward_xp := int(harvest_result.get("reward_xp", 0))
			_change_coins(reward_coins, "greenhouse_harvest")
			_grant_xp(reward_xp, "greenhouse_harvest")
			feedback_requested.emit("growth", selected_plant_index, {"source": "greenhouse", "bed_index": slot_index, "action": "harvest", "coins": reward_coins, "xp": reward_xp})
			var order_result := _record_greenhouse_order_harvest(str(harvest_result.get("crop_id", crop_id)), slot_index)
			if bool(order_result.get("completed", false)):
				var bonus_coins := int(order_result.get("bonus_coins", 0))
				var bonus_xp := int(order_result.get("bonus_xp", 0))
				_change_coins(bonus_coins, "greenhouse_order")
				_grant_xp(bonus_xp, "greenhouse_order")
				orders_completed += 1
				_record_professor_research_event(professor_research.record_delivery(1))
				var reputation_claims := _claim_new_greenhouse_reputation_milestones()
				feedback_requested.emit("order_complete", selected_plant_index, {
					"order_kind": "greenhouse",
					"customer": str(order_result.get("customer", "odběratele")),
					"crop_id": crop_id,
					"crop_name": str(harvest_result.get("name", crop_id)),
					"coins": bonus_coins,
					"xp": bonus_xp,
					"base_coins": reward_coins,
					"base_xp": reward_xp,
					"reputation_milestones": reputation_claims.duplicate(true),
				})
				var completion_message := "Skleníková zakázka pro %s je hotová! Sklizeň přinesla %d mincí a %d XP, bonus dalších %d mincí a %d XP." % [str(order_result.get("customer", "odběratele")), reward_coins, reward_xp, bonus_coins, bonus_xp]
				for raw_claim in reputation_claims:
					var claim: Dictionary = raw_claim
					var claim_coins := int(claim.get("reward_coins", 0))
					var claim_xp := int(claim.get("reward_xp", 0))
					if claim_coins > 0 or claim_xp > 0:
						completion_message += " Milník %s přidal %d mincí a %d XP." % [str(claim.get("title", "POVĚST")), claim_coins, claim_xp]
					else:
						completion_message += " Odemčena kosmetická cedule %s." % str(claim.get("cosmetic_sign", claim.get("title", "MISTR SKLENÍKU")))
				event_created.emit(completion_message)
			elif bool(order_result.get("matched", false)) and not bool(order_result.get("credited", true)):
				event_created.emit("Sklizeň plodiny %s přinesla %d mincí a %d XP. Prémiová zakázka vyžaduje jiný záhon; postup zůstává %d/%d." % [str(harvest_result.get("name", crop_id)).to_lower(), reward_coins, reward_xp, int(order_result.get("progress", 0)), int(order_result.get("target_harvests", 1))])
			elif bool(order_result.get("matched", false)):
				event_created.emit("Sklizeň plodiny %s přinesla %d mincí a %d XP. Zakázka pokračuje %d/%d." % [str(harvest_result.get("name", crop_id)).to_lower(), reward_coins, reward_xp, int(order_result.get("progress", 0)), int(order_result.get("target_harvests", 1))])
			else:
				event_created.emit("Sklizeň plodiny %s ze záhonu %d přinesla %d mincí a %d XP." % [str(harvest_result.get("name", crop_id)).to_lower(), slot_index + 1, reward_coins, reward_xp])
			return true
		_:
			return false


func _complete_journey() -> void:
	journey_completed = true
	var pack_granted := false
	if not journey_reward_claimed:
		journey_reward_claimed = true
		_change_coins(25, "first_cycle_reward")
		_grant_xp(40, "first_cycle_reward")
		pack_granted = not _grant_botanical_pack("first_journey", "first_cycle").is_empty()
	feedback_requested.emit("journey_complete", selected_plant_index, {"coins": 25, "xp": 40, "pack_granted": pack_granted})
	if pack_granted:
		event_created.emit("První pěstitelský cyklus je hotový! Profesor Bazal přidal 25 mincí, 40 XP a botanický balíček. Otevřeš ho v kartě DEN.")
	elif pending_botanical_packs.size() >= MAX_PENDING_BOTANICAL_PACKS:
		event_created.emit("První pěstitelský cyklus je hotový! Profesor Bazal přidal 25 mincí a 40 XP. Zásobník botanických balíčků je plný.")
	else:
		event_created.emit("První pěstitelský cyklus je hotový! Profesor Bazal přidal 25 mincí a 40 XP. Botanický balíček tentokrát nebylo možné bezpečně uložit.")
	_activate_professor_story_if_eligible()


func _migrate_legacy_journey() -> void:
	# Schema 1/2 had no guided journey. Infer the nearest safe step without
	# granting a retroactive reward or forcing an impossible earlier action.
	match plant.stage:
		PlantSimulation.Stage.PACKAGED:
			journey_step = JourneyStep.SELL
		PlantSimulation.Stage.DRY:
			journey_step = JourneyStep.PACKAGE
		PlantSimulation.Stage.DRYING:
			journey_step = JourneyStep.WAIT_FOR_DRYING
		PlantSimulation.Stage.HARVESTED:
			journey_step = JourneyStep.START_DRYING
		PlantSimulation.Stage.MATURE:
			journey_step = JourneyStep.HARVEST
		PlantSimulation.Stage.GERMINATING, PlantSimulation.Stage.SPROUT, PlantSimulation.Stage.VEGETATIVE:
			journey_step = JourneyStep.GROW_TO_MATURE
		PlantSimulation.Stage.EMPTY:
			if harvest_count > 0:
				journey_step = JourneyStep.COMPLETE
				journey_completed = true
				journey_reward_claimed = true
			else:
				journey_step = JourneyStep.PLANT_SEED


func _roll_seed_drop() -> bool:
	# Deterministic from the harvest makes save/load behavior testable.
	var roll_seed := harvest_count * 7919 + roundi(plant.fresh_harvest_g * 100.0)
	var rng := RandomNumberGenerator.new()
	rng.seed = roll_seed
	return rng.randf() < plant.get_seed_drop_chance(0.58)


func _sanitize_order_sequence(raw_value: Variant, fallback: int) -> int:
	var safe_fallback := clampi(fallback, 0, MAX_ORDER_SEQUENCE)
	if raw_value is bool:
		return safe_fallback
	if raw_value is int:
		return clampi(int(raw_value), 0, MAX_ORDER_SEQUENCE)
	if raw_value is float:
		var numeric_value := float(raw_value)
		if not is_finite(numeric_value):
			return safe_fallback
		if numeric_value <= 0.0:
			return 0
		if numeric_value >= float(MAX_ORDER_SEQUENCE):
			return MAX_ORDER_SEQUENCE
		return int(numeric_value)
	return safe_fallback


func _next_order_sequence(sequence: int) -> int:
	var safe_sequence := _sanitize_order_sequence(sequence, 0)
	return MAX_ORDER_SEQUENCE if safe_sequence >= MAX_ORDER_SEQUENCE else safe_sequence + 1


func _advance_order_rotation_after(sequence: int) -> void:
	order_rotation = maxi(_sanitize_order_sequence(order_rotation, 0), _next_order_sequence(sequence))


func _get_active_order_sequences(excluded_index := -1) -> Dictionary:
	var used: Dictionary = {}
	for index in range(orders.size()):
		if index == excluded_index:
			continue
		used[_sanitize_order_sequence(orders[index].get("sequence", 0), 0)] = true
	return used


func _get_active_blend_ids(excluded_index := -1) -> Dictionary:
	var used: Dictionary = {}
	for index in range(orders.size()):
		if index == excluded_index:
			continue
		var order := orders[index]
		if str(order.get("kind", "single")) == "blend":
			used[str(order.get("blend_id", ""))] = true
	return used


func _allocate_order_sequence(preferred_sequence: int, used_sequences: Dictionary) -> int:
	var preferred := _sanitize_order_sequence(preferred_sequence, 0)
	if not used_sequences.has(preferred):
		return preferred
	# At most three orders are active, so one of the first four low IDs must be
	# free. This bounded scan avoids incrementing a saturated hostile value.
	for candidate in range(ACTIVE_ORDER_COUNT + 1):
		if not used_sequences.has(candidate):
			return candidate
	return 0


func _ensure_orders() -> void:
	order_rotation = _sanitize_order_sequence(order_rotation, 0)
	var used_sequences := _get_active_order_sequences()
	var active_blend_ids := _get_active_blend_ids()
	while orders.size() < ACTIVE_ORDER_COUNT:
		var sequence := _allocate_order_sequence(order_rotation, used_sequences)
		var order := _build_order(sequence, active_blend_ids)
		orders.append(order)
		used_sequences[sequence] = true
		if str(order.get("kind", "single")) == "blend":
			active_blend_ids[str(order.get("blend_id", ""))] = true
		_advance_order_rotation_after(sequence)
	if orders.size() > ACTIVE_ORDER_COUNT:
		orders.resize(ACTIVE_ORDER_COUNT)


func _build_order(sequence: int, excluded_blend_ids: Dictionary = {}) -> Dictionary:
	sequence = _sanitize_order_sequence(sequence, 0)
	var template := _get_available_order_template(sequence, excluded_blend_ids)
	if str(template.get("kind", "single")) == "blend":
		return _build_blend_order(template, sequence)
	var cycle := int(sequence / ORDER_TEMPLATES.size())
	var order := template.duplicate(true)
	order.erase("requires_discovery")
	order["kind"] = "single"
	order["blend_id"] = ""
	order["species_id"] = _sanitize_order_species(str(order.get("species_id", "any")))
	order["id"] = "order_%04d" % sequence
	order["sequence"] = sequence
	# Later rotations ask for a little more, but remain capped and achievable.
	order["min_quality"] = minf(ORDER_MAX_QUALITY, float(order["min_quality"]) + float(cycle) * 0.01)
	order["min_dry_g"] = minf(get_max_order_dry_g(str(order["species_id"])), float(order["min_dry_g"]) + float(cycle) * 0.15)
	order["flat_bonus"] = mini(ORDER_MAX_FLAT_BONUS, int(order["flat_bonus"]) + cycle * 2)
	order["bonus_xp"] = mini(ORDER_MAX_BONUS_XP, int(order["bonus_xp"]) + cycle)
	order["requirements"] = [{
		"species_id": str(order["species_id"]),
		"min_dry_g": float(order["min_dry_g"]),
		"min_quality": float(order["min_quality"]),
	}]
	return order


func _build_blend_order(template: Dictionary, sequence: int) -> Dictionary:
	var order := template.duplicate(true)
	order.erase("requires_discovery")
	order["kind"] = "blend"
	order["species_id"] = "any"
	order["id"] = "order_%04d" % sequence
	order["sequence"] = sequence
	var requirements: Array[Dictionary] = []
	var total_dry_g := 0.0
	var minimum_quality := 1.0
	for raw_requirement in order.get("requirements", []):
		if not raw_requirement is Dictionary:
			continue
		var requirement: Dictionary = raw_requirement
		var canonical_requirement := {
			"species_id": str(requirement.get("species_id", "")),
			"min_dry_g": float(requirement.get("min_dry_g", 0.0)),
			"min_quality": float(requirement.get("min_quality", 0.0)),
		}
		requirements.append(canonical_requirement)
		total_dry_g += float(canonical_requirement["min_dry_g"])
		minimum_quality = minf(minimum_quality, float(canonical_requirement["min_quality"]))
	order["requirements"] = requirements
	# Compatibility summaries for consumers that have not yet switched to the
	# public requirement API. Fulfillment never trusts these aggregate values.
	order["min_dry_g"] = total_dry_g
	order["min_quality"] = minimum_quality
	return order


func _get_available_order_template(sequence: int, excluded_blend_ids: Dictionary = {}) -> Dictionary:
	sequence = _sanitize_order_sequence(sequence, 0)
	for offset in range(ORDER_TEMPLATES.size()):
		var template: Dictionary = ORDER_TEMPLATES[posmod(sequence + offset, ORDER_TEMPLATES.size())]
		if str(template.get("kind", "single")) == "blend" and excluded_blend_ids.has(str(template.get("blend_id", ""))):
			continue
		if _is_order_template_available(template):
			return template
	return ORDER_TEMPLATES[0] as Dictionary


func _is_order_template_available(template: Dictionary) -> bool:
	if str(template.get("kind", "single")) == "blend":
		var requirements = template.get("requirements", [])
		if not requirements is Array or (requirements as Array).size() != 2:
			return false
		var seen_species: Dictionary = {}
		for raw_requirement in requirements:
			if not raw_requirement is Dictionary:
				return false
			var species_id := str((raw_requirement as Dictionary).get("species_id", ""))
			if not plant_profiles.has(species_id) or seen_species.has(species_id):
				return false
			if bool(template.get("requires_discovery", false)) and not is_species_discovered(species_id):
				return false
			seen_species[species_id] = true
		return true
	var species_id := str(template.get("species_id", "any"))
	if species_id == "any":
		return true
	if not plant_profiles.has(species_id):
		return false
	return not bool(template.get("requires_discovery", false)) or is_species_discovered(species_id)


func _get_known_blend_template(blend_id: String) -> Dictionary:
	for raw_template in ORDER_TEMPLATES:
		var template: Dictionary = raw_template
		if str(template.get("kind", "single")) == "blend" and str(template.get("blend_id", "")) == blend_id:
			return template
	return {}


func _get_available_single_order_template(sequence: int, legacy_rotation := false) -> Dictionary:
	var single_templates: Array[Dictionary] = []
	for raw_template in ORDER_TEMPLATES:
		var template: Dictionary = raw_template
		if str(template.get("kind", "single")) != "blend":
			single_templates.append(template)
	var rotation_size := single_templates.size() if legacy_rotation else ORDER_TEMPLATES.size()
	for offset in range(rotation_size):
		var template: Dictionary = single_templates[posmod(sequence + offset, single_templates.size())] if legacy_rotation else ORDER_TEMPLATES[posmod(sequence + offset, ORDER_TEMPLATES.size())]
		if str(template.get("kind", "single")) == "blend":
			continue
		if _is_order_template_available(template):
			return template
	return single_templates[0]


func _is_order_species_available(species_id: String) -> bool:
	if species_id == "any":
		return true
	if not plant_profiles.has(species_id):
		return false
	for raw_template in ORDER_TEMPLATES:
		var template: Dictionary = raw_template
		if str(template.get("species_id", "any")) != species_id:
			continue
		if bool(template.get("requires_discovery", false)):
			return is_species_discovered(species_id)
	return true


func _fulfill_blend_order(index: int, plan: Dictionary) -> bool:
	var order := orders[index]
	var assignments: Array[Dictionary] = []
	for raw_assignment in plan.get("assignments", []):
		if raw_assignment is Dictionary:
			assignments.append((raw_assignment as Dictionary).duplicate(true))
	if assignments.size() != 2:
		return false
	var slot_indices: Array[int] = []
	var species_ids: Array[String] = []
	var total_dry_g := 0.0
	var minimum_quality := 1.0
	for assignment in assignments:
		var slot_index := int(assignment.get("slot_index", -1))
		if slot_index < 0 or slot_index >= plants.size() or slot_index in slot_indices:
			return false
		var slot := plants[slot_index]
		if slot.stage != PlantSimulation.Stage.PACKAGED:
			return false
		slot_indices.append(slot_index)
		species_ids.append(slot.get_species_id())
		total_dry_g += slot.dry_harvest_g
		minimum_quality = minf(minimum_quality, slot.harvest_quality)
	var customer := str(order.get("customer", "odběratele"))
	var reward_coins := get_order_reward(index)
	var reward_xp := int(order.get("bonus_xp", 8))
	var seed_drops: Dictionary = {}
	for assignment_index in range(assignments.size()):
		var slot_index := slot_indices[assignment_index]
		var slot := plants[slot_index]
		var species_id := species_ids[assignment_index]
		var should_drop := _roll_blend_order_seed_drop(slot, slot_index, int(order.get("sequence", 0)), assignment_index)
		seed_drops[species_id] = should_drop and _change_seed_count(species_id, 1)
	_change_coins(reward_coins, "customer_order")
	_grant_xp(reward_xp, "customer_order")
	for assignment_index in range(assignments.size()):
		var slot := plants[slot_indices[assignment_index]]
		_record_species_delivery(species_ids[assignment_index], slot.dry_harvest_g, true)
	orders_completed += 1
	var replacement_sequence := _allocate_order_sequence(order_rotation, _get_active_order_sequences(index))
	orders[index] = _build_order(replacement_sequence, _get_active_blend_ids(index))
	_advance_order_rotation_after(replacement_sequence)
	# Every prerequisite was checked before this point. Clearing has no failure
	# path, so the two exact assigned packages are consumed as one transaction.
	for slot_index in slot_indices:
		plants[slot_index].clear_after_sale()
	_capture_sample()
	var seed_drop_count := 0
	for species_id in seed_drops:
		if bool(seed_drops[species_id]):
			seed_drop_count += 1
	feedback_requested.emit("order_complete", selected_plant_index, {
		"order_kind": "blend",
		"blend_id": str(order.get("blend_id", "")),
		"ingredient_count": 2,
		"slot_indices": slot_indices.duplicate(),
		"species_ids": species_ids.duplicate(),
		"seed_drops": seed_drops.duplicate(true),
		"seed_dropped": seed_drop_count > 0,
		"customer": customer,
		"coins": reward_coins,
		"xp": reward_xp,
		"quality": minimum_quality,
		"dry_g": total_dry_g,
	})
	event_created.emit("Směs pro %s je hotová! Získáváš %d mincí a %d XP.%s" % [customer, reward_coins, reward_xp, " Navíc jsi našel %d semínka!" % seed_drop_count if seed_drop_count > 1 else (" Navíc jsi našel nové semínko!" if seed_drop_count == 1 else "")])
	_activate_professor_story_if_eligible(false)
	_record_professor_story_event(professor_story.record_specific_order("any"))
	_record_professor_research_event(professor_research.record_delivery(2))
	if _advance_journey(JourneyStep.SELL, JourneyStep.COMPLETE):
		_complete_journey()
	return true


func _roll_blend_order_seed_drop(slot: PlantSimulation, slot_index: int, order_sequence: int, requirement_index: int) -> bool:
	# Each ingredient owns an independent deterministic stream. Save/load yields
	# the same decision while different slots and recipe positions never share a
	# roll merely because their package weights match.
	var roll_seed := (harvest_count + 1) * 7919
	roll_seed += roundi(slot.fresh_harvest_g * 100.0) * 31
	roll_seed += roundi(slot.dry_harvest_g * 100.0) * 17
	var safe_order_sequence := _sanitize_order_sequence(order_sequence, 0)
	roll_seed += (safe_order_sequence + 1) * 104729
	roll_seed += (slot_index + 1) * 15485863
	roll_seed += (requirement_index + 1) * 32452843
	var rng := RandomNumberGenerator.new()
	rng.seed = posmod(roll_seed, BOTANICAL_PACK_RNG_MODULUS)
	return rng.randf() < slot.get_seed_drop_chance(0.58)


func get_max_order_dry_g(species_id: String) -> float:
	var species_ids: Array = plant_profiles.keys() if species_id == "any" else [species_id]
	var result := INF
	for candidate_id in species_ids:
		var normalized_id := str(candidate_id)
		if not plant_profiles.has(normalized_id):
			continue
		var candidate_profile := get_plant_profile(normalized_id)
		# The cap is achievable with baseline equipment at exactly the maximum
		# requested quality, not only with a perfect late-game harvest.
		var max_fresh := snappedf(float(candidate_profile.get("base_fresh_yield_g", 32.0)) * ORDER_MAX_QUALITY, 0.1)
		var max_dry := snappedf(max_fresh * float(candidate_profile.get("dry_matter_ratio", 0.16)), 0.1)
		result = minf(result, max_dry)
	return maxf(1.0, result if is_finite(result) else 1.0)


func _sanitize_order_species(species_id: String) -> String:
	if species_id == "any" or plant_profiles.has(species_id):
		return species_id
	return "any"


func _sanitize_finite_float(raw_value: Variant, fallback: float) -> float:
	if not raw_value is bool and (raw_value is int or raw_value is float):
		var numeric_value := float(raw_value)
		if is_finite(numeric_value):
			return numeric_value
	return fallback


func _sanitize_int(raw_value: Variant, fallback: int) -> int:
	return int(_sanitize_finite_float(raw_value, float(fallback)))


func _sanitize_nonnegative_int(raw_value: Variant, fallback: int) -> int:
	return maxi(0, _sanitize_int(raw_value, fallback))


func _sanitize_schema_version(raw_value: Variant, fallback: int) -> int:
	if raw_value is bool or not (raw_value is int or raw_value is float):
		return fallback
	var numeric := float(raw_value)
	if not is_finite(numeric) or numeric != floor(numeric) \
			or numeric < 1.0 or numeric > float(SAVE_SCHEMA):
		return fallback
	return int(numeric)


func _sanitize_utc_day(raw_value: Variant, fallback: int, allow_unset := false) -> int:
	var safe_fallback := -1 if allow_unset and fallback == -1 else clampi(fallback, 0, MAX_SUPPORTED_UTC_DAY)
	if raw_value is bool or not (raw_value is int or raw_value is float):
		return safe_fallback
	var numeric := float(raw_value)
	if not is_finite(numeric) or numeric != floor(numeric):
		return safe_fallback
	if allow_unset and numeric == -1.0:
		return -1
	if numeric < 0.0 or numeric > float(MAX_SUPPORTED_UTC_DAY):
		return safe_fallback
	return int(numeric)


func _sanitize_unix_time(raw_value: Variant, fallback: float) -> float:
	var safe_fallback := clampf(fallback, 0.0, MAX_SUPPORTED_UNIX_TIME) if is_finite(fallback) else 0.0
	var numeric_value := _sanitize_finite_float(raw_value, safe_fallback)
	return clampf(numeric_value, 0.0, MAX_SUPPORTED_UNIX_TIME) if numeric_value >= 0.0 else safe_fallback


func _sanitize_chart_sample(raw: Dictionary) -> Dictionary:
	var sanitized: Dictionary = {}
	for key in ["growth", "health", "moisture", "light", "co2", "oxygen", "biomass"]:
		sanitized[key] = _sanitize_finite_float(raw.get(key, 0.0), 0.0)
	return sanitized


func _sanitize_order(raw: Dictionary, stored_schema := SAVE_SCHEMA, excluded_blend_ids: Dictionary = {}) -> Dictionary:
	var sequence := _sanitize_order_sequence(raw.get("sequence", order_rotation), order_rotation)
	if stored_schema >= BLEND_ORDER_SCHEMA:
		var raw_kind = raw.get("kind", "single")
		if not (raw_kind is String or raw_kind is StringName):
			return _build_order(sequence, excluded_blend_ids)
		var kind := str(raw_kind)
		if kind == "blend":
			var blend_id := str(raw.get("blend_id", ""))
			var blend_template := _get_known_blend_template(blend_id)
			if not excluded_blend_ids.has(blend_id) and not blend_template.is_empty() and _is_order_template_available(blend_template):
				# The identifier selects a closed, authored recipe. Every other raw
				# blend field is untrusted and rebuilt from that canonical template.
				return _build_blend_order(blend_template, sequence)
			return _build_order(sequence, excluded_blend_ids)
		if kind != "single":
			return _build_order(sequence, excluded_blend_ids)
	return _sanitize_single_order(raw, sequence, stored_schema < BLEND_ORDER_SCHEMA)


func _sanitize_single_order(raw: Dictionary, sequence: int, preserve_legacy_id: bool) -> Dictionary:
	var template := _get_available_single_order_template(sequence, preserve_legacy_id)
	var fallback := template.duplicate(true)
	var cycle_size := LEGACY_SINGLE_ORDER_TEMPLATE_COUNT if preserve_legacy_id else ORDER_TEMPLATES.size()
	var cycle := int(sequence / cycle_size)
	fallback.erase("requires_discovery")
	fallback["id"] = "order_%04d" % sequence
	fallback["sequence"] = sequence
	fallback["min_quality"] = minf(ORDER_MAX_QUALITY, float(fallback["min_quality"]) + float(cycle) * 0.01)
	fallback["min_dry_g"] = minf(get_max_order_dry_g(str(fallback["species_id"])), float(fallback["min_dry_g"]) + float(cycle) * 0.15)
	fallback["flat_bonus"] = mini(ORDER_MAX_FLAT_BONUS, int(fallback["flat_bonus"]) + cycle * 2)
	fallback["bonus_xp"] = mini(ORDER_MAX_BONUS_XP, int(fallback["bonus_xp"]) + cycle)
	var species_id := _sanitize_order_species(str(raw.get("species_id", fallback.get("species_id", "any"))))
	if not _is_order_species_available(species_id):
		species_id = str(fallback.get("species_id", "any"))
	var result := {
		"id": str(raw.get("id", fallback["id"])) if preserve_legacy_id else str(fallback["id"]),
		"sequence": sequence,
		"kind": "single",
		"blend_id": "",
		"customer": str(raw.get("customer", template["customer"])),
		"title": str(raw.get("title", template["title"])),
		"species_id": species_id,
		"min_quality": clampf(_sanitize_finite_float(raw.get("min_quality", fallback["min_quality"]), float(fallback["min_quality"])), 0.45, ORDER_MAX_QUALITY),
		"min_dry_g": clampf(_sanitize_finite_float(raw.get("min_dry_g", fallback["min_dry_g"]), float(fallback["min_dry_g"])), 1.0, get_max_order_dry_g(species_id)),
		"reward_multiplier": clampf(_sanitize_finite_float(raw.get("reward_multiplier", template["reward_multiplier"]), float(template["reward_multiplier"])), 1.0, 2.5),
		"flat_bonus": clampi(int(_sanitize_finite_float(raw.get("flat_bonus", fallback["flat_bonus"]), float(fallback["flat_bonus"]))), 0, ORDER_MAX_FLAT_BONUS),
		"bonus_xp": clampi(int(_sanitize_finite_float(raw.get("bonus_xp", fallback["bonus_xp"]), float(fallback["bonus_xp"]))), 1, ORDER_MAX_BONUS_XP),
		"accent": str(raw.get("accent", template["accent"])),
	}
	result["requirements"] = [{
		"species_id": str(result["species_id"]),
		"min_dry_g": float(result["min_dry_g"]),
		"min_quality": float(result["min_quality"]),
	}]
	return result


func _capture_sample() -> void:
	chart_samples.append({
		"growth": plant.growth_percent,
		"health": plant.health,
		"moisture": plant.moisture,
		"light": plant.light_lux,
		"co2": plant.co2_ppm,
		"oxygen": plant.oxygen_balance_mg_h,
		"biomass": plant.get_biomass_g(),
	})
	if chart_samples.size() > 72:
		chart_samples.pop_front()


func _relay_event(message: String) -> void:
	event_created.emit(message)


func to_dict() -> Dictionary:
	var now_unix := _sanitize_unix_time(Time.get_unix_time_from_system(), 0.0)
	saved_at_unix = maxf(_sanitize_unix_time(saved_at_unix, 0.0), now_unix)
	order_refresh_day = _sanitize_utc_day(order_refresh_day, -1, true)
	shop_stock_day = _sanitize_utc_day(shop_stock_day, -1, true)
	daily_challenge_real_day = _sanitize_utc_day(daily_challenge_real_day, _get_real_shop_day_index(now_unix))
	daily_challenge_last_claimed_real_day = _sanitize_utc_day(daily_challenge_last_claimed_real_day, -1, true)
	_sync_professor_story_storage()
	professor_research.set_unlocked(_is_professor_research_unlocked(), _get_real_shop_day_index(now_unix))
	return {
		"schema": SAVE_SCHEMA,
		"coins": coins,
		"xp": xp,
		"seed_inventory": get_seed_inventory_snapshot(),
		"pending_botanical_packs": _sanitize_pending_botanical_packs(pending_botanical_packs),
		"next_botanical_pack_id": next_botanical_pack_id,
		"botanical_pack_rng_state": botanical_pack_rng_state,
		"botanical_pack_pity": botanical_pack_pity,
		"selected_seed_species": selected_seed_species,
		"fertilizer_doses": fertilizer_doses,
		"harvest_count": harvest_count,
		# Ke klíčům se starší build bezpečně vrátí, ale produkční save už nikdy
		# neuchovává hráčské zrychlení ani pauzu.
		"speed_multiplier": 1.0,
		"paused": false,
		"intro_completed": intro_completed,
		"journey_step": int(journey_step),
		"journey_completed": journey_completed,
		"journey_reward_claimed": journey_reward_claimed,
		"story_chapters": story_chapters.duplicate(true),
		"active_story_chapter_id": active_story_chapter_id,
		"professor_research": professor_research.to_dict(),
		"reduced_motion": reduced_motion,
		"music_enabled": music_enabled,
		"sfx_enabled": sfx_enabled,
		"haptics_enabled": haptics_enabled,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"visited_screens": visited_screens,
		"chart_samples": chart_samples,
		"orders": orders,
		"orders_completed": orders_completed,
		"order_rotation": order_rotation,
		"order_refresh_day": order_refresh_day,
		"order_refreshes_remaining": order_refreshes_remaining,
		"species_progress": species_progress,
		"world_elapsed_seconds": world_elapsed_seconds,
		"daily_challenge_id": daily_challenge_id,
		"daily_challenge_issued_day": daily_challenge_issued_day,
		"daily_challenge_real_day": daily_challenge_real_day,
		"daily_challenge_last_claimed_real_day": daily_challenge_last_claimed_real_day,
		"daily_challenge_weather": daily_challenge_weather,
		"daily_challenge_forecast_weather": daily_challenge_forecast_weather,
		"daily_challenge_completed": daily_challenge_completed,
		"daily_challenge_claimed": daily_challenge_claimed,
		"shop_stock_day": shop_stock_day,
		"shop_stock": shop_stock,
		"unlocked_room_themes": unlocked_room_themes,
		"selected_room_theme": selected_room_theme,
		"owned_room_decorations": owned_room_decorations.duplicate(),
		"room_decoration_slots": room_decoration_slots.duplicate(),
		"greenhouse_beds": greenhouse.to_dict(),
		"greenhouse_order": greenhouse_order.duplicate(true),
		"greenhouse_order_rotation": greenhouse_order_rotation,
		"greenhouse_orders_completed": greenhouse_orders_completed,
		"greenhouse_reputation_claimed_tier": greenhouse_reputation_claimed_tier,
		"claimed_level_rewards": claimed_level_rewards.duplicate(),
		"equipment_levels": equipment_levels.duplicate(true),
		"care_reminders_enabled": care_reminders_enabled,
		"fast_time_guard_enabled": false,
		"selected_plant_index": selected_plant_index,
		"plants": plants.map(func(slot: PlantSimulation) -> Dictionary: return slot.to_dict()),
		"saved_at_unix": saved_at_unix,
	}


func from_dict(data: Dictionary) -> void:
	_daily_challenge_refresh_accumulator = 0.0
	_care_attention_cache.clear()
	_care_attention_cache_initialized = false
	_offline_lifecycle_events.clear()
	_story_progress_events.clear()
	_story_return_summary_lines.clear()
	var has_guided_journey := data.has("journey_step")
	# A direct caller must not authorize newer trust boundaries with a
	# fractional, boolean, non-numeric, or unsupported schema value. Disk loads
	# apply the same rule in SaveManager before reaching this method.
	var stored_schema := _sanitize_schema_version(data.get("schema", 1), 1)
	_legacy_lifecycle_protection_pending = stored_schema < PLANT_LIFECYCLE_SCHEMA
	var now_unix := _sanitize_unix_time(Time.get_unix_time_from_system(), 0.0)
	var stored_saved_at_unix := _sanitize_unix_time(data.get("saved_at_unix", now_unix), now_unix)
	coins = _sanitize_nonnegative_int(data.get("coins", 30), 30)
	xp = _sanitize_nonnegative_int(data.get("xp", 0), 0)
	# Schemas 1–20 are migrated exclusively from their four fixed fields. A
	# partially backported seed_inventory key is intentionally ignored so old
	# saves cannot silently change meaning. Schema 21+ accepts the catalog plus a
	# bounded opaque set reserved for safe downgrade/upgrade round-trips.
	if stored_schema >= SEED_INVENTORY_SCHEMA:
		seed_inventory = _sanitize_current_seed_inventory(data.get("seed_inventory")) if data.has("seed_inventory") else _build_starter_seed_inventory()
	else:
		seed_inventory = _migrate_legacy_seed_inventory(data)
	selected_seed_species = str(data.get("selected_seed_species", "basil_genovese"))
	if not plant_profiles.has(selected_seed_species):
		selected_seed_species = "basil_genovese"
	fertilizer_doses = _sanitize_nonnegative_int(data.get("fertilizer_doses", 2), 2)
	harvest_count = _sanitize_nonnegative_int(data.get("harvest_count", 0), 0)
	# Schema 1–18 mohlo zůstat na 1000× nebo v ruční pauze. Nový reálný
	# pěstitelský čas vždy obnoví bezpečný běžící stav bez ztráty rostlin.
	speed_multiplier = 1.0
	paused = false
	intro_completed = bool(data.get("intro_completed", false))
	journey_step = clampi(_sanitize_int(data.get("journey_step", JourneyStep.PLANT_SEED), JourneyStep.PLANT_SEED), JourneyStep.PLANT_SEED, JourneyStep.COMPLETE)
	journey_completed = bool(data.get("journey_completed", journey_step == JourneyStep.COMPLETE))
	journey_reward_claimed = bool(data.get("journey_reward_claimed", journey_completed))
	reduced_motion = bool(data.get("reduced_motion", false))
	music_enabled = bool(data.get("music_enabled", true))
	sfx_enabled = bool(data.get("sfx_enabled", true))
	haptics_enabled = bool(data.get("haptics_enabled", true))
	music_volume = clampf(_sanitize_finite_float(data.get("music_volume", 0.55), 0.55), 0.0, 1.0)
	sfx_volume = clampf(_sanitize_finite_float(data.get("sfx_volume", 0.80), 0.80), 0.0, 1.0)
	visited_screens.clear()
	var stored_screens = data.get("visited_screens", [])
	if stored_screens is Array:
		for screen_index in stored_screens:
			if not (screen_index is int or screen_index is float):
				continue
			var numeric_index := float(screen_index)
			if not is_finite(numeric_index):
				continue
			var normalized_index := clampi(int(numeric_index), 0, 3)
			if normalized_index not in visited_screens:
				visited_screens.append(normalized_index)
	chart_samples.clear()
	var stored_samples = data.get("chart_samples", [])
	if stored_samples is Array:
		var first_sample_index := maxi(0, stored_samples.size() - 72)
		for sample_index in range(first_sample_index, stored_samples.size()):
			var sample = stored_samples[sample_index]
			if sample is Dictionary:
				chart_samples.append(_sanitize_chart_sample(sample))
	orders.clear()
	orders_completed = _sanitize_nonnegative_int(data.get("orders_completed", 0), 0)
	order_rotation = _sanitize_order_sequence(data.get("order_rotation", 0), 0)
	order_refresh_day = _sanitize_utc_day(data.get("order_refresh_day", -1), -1, true)
	order_refreshes_remaining = clampi(_sanitize_int(data.get("order_refreshes_remaining", DAILY_ORDER_REFRESHES), DAILY_ORDER_REFRESHES), 0, DAILY_ORDER_REFRESHES)
	refresh_order_declines_for_unix()
	var stored_progress = data.get("species_progress", {})
	_ensure_species_progress(stored_progress if stored_progress is Dictionary else {})
	world_elapsed_seconds = maxf(0.0, _sanitize_finite_float(data.get("world_elapsed_seconds", 0.0), 0.0))
	daily_challenge_id = _normalize_daily_challenge_id(str(data.get("daily_challenge_id", "")))
	daily_challenge_issued_day = _sanitize_nonnegative_int(data.get("daily_challenge_issued_day", get_world_day_index()), get_world_day_index())
	var migrated_real_day := _get_real_shop_day_index(stored_saved_at_unix)
	daily_challenge_real_day = _sanitize_utc_day(data.get("daily_challenge_real_day", migrated_real_day), migrated_real_day) if stored_schema >= DAILY_CHALLENGE_REAL_DAY_SCHEMA else migrated_real_day
	daily_challenge_completed = bool(data.get("daily_challenge_completed", false))
	daily_challenge_claimed = bool(data.get("daily_challenge_claimed", false))
	daily_challenge_last_claimed_real_day = _sanitize_utc_day(data.get("daily_challenge_last_claimed_real_day", daily_challenge_real_day if daily_challenge_claimed else -1), daily_challenge_real_day if daily_challenge_claimed else -1, true) if stored_schema >= DAILY_CHALLENGE_REAL_DAY_SCHEMA else (daily_challenge_real_day if daily_challenge_claimed else -1)
	var issued_environment_seconds := float(daily_challenge_issued_day) * PlantSimulation.ENVIRONMENT_DAY_SECONDS
	var legacy_issued_weather := PlantSimulation.get_weather_for_environment_seconds(issued_environment_seconds)
	var legacy_forecast_weather := PlantSimulation.get_weather_for_environment_seconds(issued_environment_seconds + PlantSimulation.ENVIRONMENT_DAY_SECONDS)
	daily_challenge_weather = _normalize_daily_challenge_weather(str(data.get("daily_challenge_weather", "")), legacy_issued_weather)
	daily_challenge_forecast_weather = _normalize_daily_challenge_weather(str(data.get("daily_challenge_forecast_weather", "")), legacy_forecast_weather)
	shop_stock_day = _sanitize_utc_day(data.get("shop_stock_day", -1), -1, true)
	shop_stock.clear()
	var stored_shop_stock = data.get("shop_stock", {})
	if stored_shop_stock is Dictionary and shop_stock_day >= 0:
		var allowed_stock := _build_shop_stock_for_day(shop_stock_day)
		for item_id in allowed_stock:
			# Catalog expansions may add a new item while an existing save still
			# belongs to the current real-world shop day. Preserve every stored
			# count, including zero, and only seed a genuinely missing known key.
			var restored_count := _sanitize_int(stored_shop_stock[item_id], int(allowed_stock[item_id])) \
				if stored_shop_stock.has(item_id) else int(allowed_stock[item_id])
			shop_stock[item_id] = clampi(restored_count, 0, int(allowed_stock[item_id]))
	refresh_shop_stock_for_unix()
	claimed_level_rewards.clear()
	var stored_level_rewards = data.get("claimed_level_rewards", [])
	if stored_level_rewards is Array:
		for raw_level in stored_level_rewards:
			var normalized_level := _sanitize_int(raw_level, 0)
			if normalized_level >= 1 and normalized_level <= mini(get_level(), LEVEL_REWARDS.size()) and normalized_level not in claimed_level_rewards:
				claimed_level_rewards.append(normalized_level)
	claimed_level_rewards.sort()
	var stored_equipment = data.get("equipment_levels", {})
	equipment_levels.clear()
	for equipment_id in EQUIPMENT_ORDER:
		var stored_level := 1
		if stored_equipment is Dictionary:
			stored_level = _sanitize_int((stored_equipment as Dictionary).get(equipment_id, 1), 1)
		equipment_levels[equipment_id] = clampi(stored_level, 1, EQUIPMENT_MAX_LEVEL)
	care_reminders_enabled = bool(data.get("care_reminders_enabled", true))
	fast_time_guard_enabled = false if stored_schema >= REAL_TIME_GROWTH_SCHEMA else bool(data.get("fast_time_guard_enabled", true))
	var stored_orders = data.get("orders", [])
	var restored_order_sequences: Dictionary = {}
	var restored_blend_ids: Dictionary = {}
	if stored_orders is Array:
		for stored_order in stored_orders:
			if orders.size() >= ACTIVE_ORDER_COUNT:
				break
			if not stored_order is Dictionary:
				continue
			var order_data: Dictionary = (stored_order as Dictionary).duplicate(true)
			if stored_schema >= BLEND_ORDER_SCHEMA:
				var normalized_sequence := _sanitize_order_sequence(order_data.get("sequence", order_rotation), order_rotation)
				if restored_order_sequences.has(normalized_sequence):
					normalized_sequence = _allocate_order_sequence(order_rotation, restored_order_sequences)
				order_data["sequence"] = normalized_sequence
				order_data["id"] = "order_%04d" % normalized_sequence
			var restored_order := _sanitize_order(order_data, stored_schema, restored_blend_ids)
			orders.append(restored_order)
			var restored_sequence := int(restored_order.get("sequence", -1))
			restored_order_sequences[restored_sequence] = true
			if str(restored_order.get("kind", "single")) == "blend":
				restored_blend_ids[str(restored_order.get("blend_id", ""))] = true
			if stored_schema >= BLEND_ORDER_SCHEMA:
				_advance_order_rotation_after(restored_sequence)
	_ensure_orders()
	greenhouse_order.clear()
	greenhouse_order_rotation = 0
	greenhouse_orders_completed = 0
	greenhouse_reputation_claimed_tier = 0
	if stored_schema >= GREENHOUSE_ORDER_SCHEMA:
		greenhouse_order_rotation = _sanitize_order_sequence(data.get("greenhouse_order_rotation", 0), 0)
		greenhouse_orders_completed = clampi(
			_sanitize_nonnegative_int(data.get("greenhouse_orders_completed", 0), 0),
			0,
			GREENHOUSE_ORDER_MAX_COMPLETIONS
		)
		greenhouse_order = _sanitize_greenhouse_order(data.get("greenhouse_order", {}), stored_schema >= GREENHOUSE_QUALITY_ORDER_SCHEMA)
		if not greenhouse_order.is_empty():
			greenhouse_order_rotation = maxi(
				greenhouse_order_rotation,
				_next_order_sequence(int(greenhouse_order.get("sequence", 0)))
			)
	# The count is the only authority. Schema 36 migrations and malformed schema
	# 37 tiers both receive the earned cosmetic title without retroactive coins.
	greenhouse_reputation_claimed_tier = _get_greenhouse_reputation_tier_for_count(greenhouse_orders_completed)
	_ensure_greenhouse_order()
	var stored_plants = data.get("plants", [])
	if stored_plants is Array and not stored_plants.is_empty():
		for index in range(mini(stored_plants.size(), plants.size())):
			var stored_plant = stored_plants[index]
			if stored_plant is Dictionary:
				var species_id := str(stored_plant.get("species_id", "basil_genovese"))
				plants[index].configure_profile(get_plant_profile(species_id))
				plants[index].from_dict(stored_plant)
	else:
		# Save schema 1 stored only one plant. It becomes the first room slot.
		var legacy_plant = data.get("plant", {})
		if legacy_plant is Dictionary:
			plants[0].from_dict(legacy_plant)
	if stored_schema < PLANT_LIFECYCLE_SCHEMA:
		# Schemas 1–19 never owned these clocks. Ignore even hostile or partially
		# backported fields so the update cannot impose a retroactive penalty.
		for slot in plants:
			slot.mature_elapsed_seconds = 0.0
			slot.critical_neglect_seconds = 0.0
	selected_plant_index = clampi(_sanitize_int(data.get("selected_plant_index", 0), 0), 0, plants.size() - 1)
	if not is_plant_slot_unlocked(selected_plant_index):
		selected_plant_index = 0
	plant = plants[selected_plant_index]
	_sync_equipment_effects()
	for slot in plants:
		slot.sync_environment(world_elapsed_seconds)
	_ensure_daily_challenge()
	if not has_guided_journey:
		_migrate_legacy_journey()
	_restore_botanical_pack_state(data, stored_schema)
	professor_story.load_state(
		data.get("story_chapters", {}),
		data.get("active_story_chapter_id", ""),
		journey_completed,
		stored_schema,
		get_available_species()
	)
	_sync_professor_story_storage()
	# A schema-26 finale claimed under a clock that later rolls back must offer
	# only the saved/current high-water week, never an older backlogged cycle.
	# Schema 27 additionally folds its own persisted max_seen_utc_day in load_state.
	var research_restore_utc_day := maxi(
		_get_real_shop_day_index(now_unix),
		_get_real_shop_day_index(stored_saved_at_unix)
	)
	professor_research.load_state(
		data.get("professor_research", {}),
		stored_schema,
		_is_professor_research_unlocked(),
		research_restore_utc_day
	)
	# Theme ownership is restored only after authoritative research history.
	# Schema 27 may contain an injected future ID, but cannot authorize it;
	# schema 28 additionally requires the six completed protocols it claims.
	unlocked_room_themes.clear()
	var stored_themes = data.get("unlocked_room_themes", ["sunrise"])
	if stored_themes is Array:
		for theme_id in stored_themes:
			if not (theme_id is String or theme_id is StringName):
				continue
			var normalized_theme := str(theme_id)
			if not ROOM_THEMES.has(normalized_theme) or normalized_theme in unlocked_room_themes:
				continue
			if normalized_theme == RESEARCH_STUDY_THEME_ID and (
					stored_schema < PROFESSOR_RESEARCH_VARIANT_SCHEMA
					or professor_research.get_completed_count() < RESEARCH_STUDY_COMPLETED_REQUIRED
			):
				continue
			unlocked_room_themes.append(normalized_theme)
	if "sunrise" not in unlocked_room_themes:
		unlocked_room_themes.push_front("sunrise")
	selected_room_theme = str(data.get("selected_room_theme", "sunrise"))
	if not ROOM_THEMES.has(selected_room_theme) or selected_room_theme not in unlocked_room_themes:
		selected_room_theme = "sunrise"
	owned_room_decorations.clear()
	room_decoration_slots.assign(_empty_room_decoration_slots())
	if stored_schema >= ROOM_DECORATION_SCHEMA:
		var stored_decorations = data.get("owned_room_decorations", [])
		if stored_decorations is Array:
			for raw_decoration_id in stored_decorations:
				if not (raw_decoration_id is String or raw_decoration_id is StringName):
					continue
				var decoration_id := str(raw_decoration_id)
				if _room_decoration_authorized_for_schema(decoration_id, stored_schema) and decoration_id not in owned_room_decorations:
					owned_room_decorations.append(decoration_id)
		var stored_decoration_slots = data.get("room_decoration_slots", [])
		var restored_placements: Dictionary = {}
		if stored_decoration_slots is Array:
			if stored_schema >= ROOM_THREE_PER_SHELF_SCHEMA:
				for slot_index in range(mini(ROOM_DECORATION_SLOT_COUNT, stored_decoration_slots.size())):
					var raw_slot_id = stored_decoration_slots[slot_index]
					if not (raw_slot_id is String or raw_slot_id is StringName):
						continue
					var slot_decoration_id := str(raw_slot_id)
					if (
							slot_decoration_id in owned_room_decorations
							and not restored_placements.has(slot_decoration_id)
							and is_room_decoration_compatible(slot_decoration_id, slot_index)
					):
						room_decoration_slots[slot_index] = slot_decoration_id
						restored_placements[slot_decoration_id] = true
			elif stored_schema >= ROOM_COLLECTION_SCHEMA:
				# Schema 38-39 used eight plants followed immediately by eight
				# fixed decorations. Preserve every legitimate placement while
				# inserting four new plant positions before the fixed section.
				for legacy_slot_index in range(mini(16, stored_decoration_slots.size())):
					var raw_slot_id = stored_decoration_slots[legacy_slot_index]
					if not (raw_slot_id is String or raw_slot_id is StringName):
						continue
					var slot_decoration_id := str(raw_slot_id)
					var migrated_slot_index := LEGACY_ROOM_COLLECTION_SLOT_MIGRATION[legacy_slot_index]
					if (
							slot_decoration_id in owned_room_decorations
							and not restored_placements.has(slot_decoration_id)
							and is_room_decoration_compatible(slot_decoration_id, migrated_slot_index)
					):
						room_decoration_slots[migrated_slot_index] = slot_decoration_id
						restored_placements[slot_decoration_id] = true
			else:
				# Schema 29-37 used five interchangeable floor slots. Preserve each
				# legitimate owned item, but remap it to the first compatible place
				# in the new stand/shelf topology instead of trusting the old index.
				for raw_slot_id in stored_decoration_slots:
					if not (raw_slot_id is String or raw_slot_id is StringName):
						continue
					var slot_decoration_id := str(raw_slot_id)
					if slot_decoration_id not in owned_room_decorations or restored_placements.has(slot_decoration_id):
						continue
					var compatible_slot := _first_empty_compatible_room_slot(slot_decoration_id)
					if compatible_slot >= 0:
						room_decoration_slots[compatible_slot] = slot_decoration_id
						restored_placements[slot_decoration_id] = true
	_normalize_phase159_botanical_cloche_legacy_state()
	var authorized_greenhouse_crop_ids: Array[String] = []
	if stored_schema >= GREENHOUSE_SCHEMA:
		authorized_greenhouse_crop_ids.append("cherry_tomato")
	if stored_schema >= GREENHOUSE_SECOND_CROP_SCHEMA:
		authorized_greenhouse_crop_ids.append("sweet_pepper")
	if stored_schema >= GREENHOUSE_PROGRESSION_SCHEMA:
		authorized_greenhouse_crop_ids.append("salad_cucumber")
	if stored_schema >= GREENHOUSE_RADISH_SCHEMA:
		authorized_greenhouse_crop_ids.append("garden_radish")
	if stored_schema >= GREENHOUSE_EGGPLANT_SCHEMA:
		authorized_greenhouse_crop_ids.append("garden_eggplant")
	greenhouse.load_state(data.get("greenhouse_beds", []), authorized_greenhouse_crop_ids)
	if stored_schema < REAL_TIME_GROWTH_SCHEMA:
		_migrate_first_guided_cycle_to_real_time()
	saved_at_unix = stored_saved_at_unix
	if chart_samples.is_empty():
		_capture_sample()


func _migrate_first_guided_cycle_to_real_time() -> void:
	if journey_completed or harvest_count > 0:
		return
	for slot in plants:
		if slot.stage == PlantSimulation.Stage.EMPTY:
			continue
		var tutorial_target := maxf(1.0, float(slot.profile.get("tutorial_growth_seconds", 720.0)))
		slot.growth_target_seconds = tutorial_target
		slot.tutorial_cycle = true
		slot.plant_age_seconds = tutorial_target * clampf(slot.growth_percent / 100.0, 0.0, 1.0)
		return


func _normalize_daily_challenge_weather(value: String, fallback: String) -> String:
	return value if value in DAILY_CHALLENGE_WEATHER_NAMES else fallback


static func format_duration(seconds: float) -> String:
	var whole_minutes := int(seconds / 60.0)
	if whole_minutes < 60:
		return "%d min" % maxi(1, whole_minutes)
	var hours := int(whole_minutes / 60)
	if hours < 24:
		return "%d h %d min" % [hours, whole_minutes % 60]
	return "%d d %d h" % [int(hours / 24), hours % 24]


static func format_care_duration(seconds: float) -> String:
	if seconds < 60.0:
		return "méně než 1 min"
	return format_duration(seconds)

