extends "res://scripts/teahouse/tea_board_model.gd"
## Isolated review mechanic. No session, inventory, save or economy access.

const LEAF_CHAIN_LENGTH := 6
const LEAF_HERBS := 3
var leaf_charges := 0


func reset(next_recipe_index: int, next_seed: int) -> void:
	leaf_charges = 0
	super.reset(next_recipe_index, next_seed)


func reset_level(definition: Dictionary) -> void:
	leaf_charges = 0
	super.reset_level(definition)


func submit_chain(chain: Array[int]) -> Dictionary:
	var response := super.submit_chain(chain)
	var earned: bool = bool(response.get("accepted", false)) and chain.size() >= LEAF_CHAIN_LENGTH and phase == "matching" and leaf_charges == 0
	if earned:
		leaf_charges = 1
	response["leaf_earned"] = earned
	return response


func use_leaf(herb: Variant) -> Dictionary:
	if phase != "matching":
		return _leaf_rejected("phase")
	if leaf_charges != 1:
		return _leaf_rejected("no_charge")
	if not herb is int or herb < 0 or herb >= HERB_COUNT:
		return _leaf_rejected("herb")
	var remaining: int = int(goals.get(herb, 0)) - int(collected.get(herb, 0))
	if remaining <= 0:
		return _leaf_rejected("goal_complete")
	var count := mini(LEAF_HERBS, remaining)
	collected[herb] = int(collected.get(herb, 0)) + count
	score += count * 10
	leaf_charges = 0
	var complete := _goals_complete()
	if complete:
		phase = "pouring"
	return {"accepted": true, "reason": "", "herb": herb, "count": count, "score_gain": count * 10, "bonus": 0, "complete": complete, "leaf_used": true}


func _leaf_rejected(reason: String) -> Dictionary:
	var response := _rejected(reason)
	response["leaf_used"] = false
	return response
