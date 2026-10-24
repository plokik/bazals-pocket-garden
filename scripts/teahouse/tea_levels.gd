extends RefCounted
## Authored first chapter. Saved progress never authorizes a future map node.

const COUNT := 10
const LEGACY_COUNT := 3
const FIRST_CLEAR_COINS := 30
const FIRST_CLEAR_SEEDS := 2
const REWARD_SPECIES := "melissa_officinalis"
const QUEST_STARS := 6
const QUEST_COINS := 40
const CHAPTER_COINS := 80
const LEVELS := [
	{"id": 1, "name": "Svěží ráno", "recipe_index": 0, "goals": {0: 6, 1: 3}, "moves": 20, "seed": 20261052},
	{"id": 2, "name": "Klidný večer", "recipe_index": 1, "goals": {3: 8, 2: 6}, "moves": 18, "seed": 20261169},
	{"id": 3, "name": "Zahradní posezení", "recipe_index": 2, "goals": {0: 6, 1: 6, 3: 6}, "moves": 18, "seed": 20261286},
	{"id": 4, "name": "Odpolední osvěžení", "recipe_index": 0, "goals": {0: 12, 1: 9}, "moves": 18, "seed": 20261417},
	{"id": 5, "name": "Květinová vůně", "recipe_index": 1, "goals": {3: 12, 2: 12}, "moves": 19, "seed": 20261524},
	{"id": 6, "name": "Čaj pro návštěvu", "recipe_index": 2, "goals": {0: 9, 1: 9, 3: 9}, "moves": 20, "seed": 20261641},
	{"id": 7, "name": "Svěží konvička", "recipe_index": 0, "goals": {0: 15, 1: 15}, "moves": 21, "seed": 20261757},
	{"id": 8, "name": "Večerní konvička", "recipe_index": 1, "goals": {3: 18, 2: 15}, "moves": 22, "seed": 20261883},
	{"id": 9, "name": "Zahradní konvička", "recipe_index": 2, "goals": {0: 12, 1: 12, 3: 12}, "moves": 23, "seed": 20261990},
	{"id": 10, "name": "Společný stůl", "recipe_index": 2, "goals": {0: 15, 1: 15, 3: 15}, "moves": 26, "seed": 20262109},
]


static func is_valid_id(level_id: Variant) -> bool:
	return level_id is int and level_id >= 1 and level_id <= COUNT


static func get_level(level_id: Variant) -> Dictionary:
	if not is_valid_id(level_id):
		return {}
	return LEVELS[int(level_id) - 1].duplicate(true)
