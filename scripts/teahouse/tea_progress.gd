extends RefCounted
## The host supplies synchronous durable persistence. The board has no wallet.

const Levels := preload("res://scripts/teahouse/tea_levels.gd")
const MAX_COINS := 9223372036854775807
var best_stars: Array[int] = []
var reward_claimed: Array[bool] = []
var quest_claimed := false
var chapter_claimed := false
var _mutating := false


func _init() -> void:
	_reset()


func _reset() -> void:
	best_stars.resize(Levels.COUNT)
	best_stars.fill(0)
	reward_claimed.resize(Levels.COUNT)
	reward_claimed.fill(false)
	quest_claimed = false
	chapter_claimed = false


func to_dict() -> Dictionary:
	return {"best_stars": best_stars.duplicate(), "reward_claimed": reward_claimed.duplicate(), "quest_claimed": quest_claimed, "chapter_claimed": chapter_claimed}


func load_data(raw: Variant, available_levels: int = Levels.COUNT) -> void:
	if _mutating:
		return
	_reset()
	if not raw is Dictionary:
		return
	var stars: Variant = raw.get("best_stars", [])
	var claimed: Variant = raw.get("reward_claimed", [])
	var preceding_complete := true
	for index in range(clampi(available_levels, 0, Levels.COUNT)):
		var value: Variant = stars[index] if stars is Array and index < stars.size() else 0
		# JSON numbers can be integral floats. Fractional, nonfinite and boolean
		# values must not grant progress; public gameplay methods require int.
		var numeric := 0
		if (value is int or value is float) and is_finite(float(value)) and float(value) == floor(float(value)) and value >= 0 and value <= 3:
			numeric = int(value)
		best_stars[index] = numeric if preceding_complete else 0
		preceding_complete = preceding_complete and best_stars[index] > 0
		var flag: Variant = claimed[index] if claimed is Array and index < claimed.size() else false
		reward_claimed[index] = best_stars[index] > 0 and flag is bool and flag == true
	var quest: Variant = raw.get("quest_claimed", false)
	quest_claimed = quest is bool and quest == true and total_stars() >= Levels.QUEST_STARS
	var chapter: Variant = raw.get("chapter_claimed", false)
	chapter_claimed = chapter is bool and chapter == true and chapter_complete()


func completed_levels() -> int:
	var total := 0
	for stars in best_stars:
		if stars > 0: total += 1
	return total


func chapter_complete() -> bool:
	return completed_levels() == Levels.COUNT


func total_stars() -> int:
	var total := 0
	for stars in best_stars:
		total += stars
	return total


func unlocked_level() -> int:
	for index in range(Levels.COUNT):
		if best_stars[index] == 0:
			return index + 1
	return Levels.COUNT


func is_unlocked(level_id: Variant) -> bool:
	return Levels.is_valid_id(level_id) and level_id <= unlocked_level()


func reward_pending(level_id: Variant = 0) -> bool:
	if level_id is int and level_id == 0:
		for index in range(Levels.COUNT):
			if best_stars[index] > 0 and not reward_claimed[index]:
				return true
		return false
	return Levels.is_valid_id(level_id) and best_stars[int(level_id) - 1] > 0 and not reward_claimed[int(level_id) - 1]


func complete_level(session, level_id: Variant, stars: Variant, persist: Callable) -> Dictionary:
	var rejection := _check_transaction(session, persist)
	if not rejection.is_empty():
		return rejection
	if not Levels.is_valid_id(level_id):
		return _failure("invalid_level", "Tato úroveň není dostupná.")
	if not stars is int or stars < 1 or stars > 3:
		return _failure("invalid_stars", "Výsledek úrovně není platný.")
	if not is_unlocked(level_id):
		return _failure("locked", "Nejprve dokonči předchozí úroveň.")
	var index := int(level_id) - 1
	var improves: bool = stars > best_stars[index]
	var grants: bool = not reward_claimed[index] and _level_reward_available(session)
	if not improves and not grants:
		return _success(level_id, false, 0, 0)
	_mutating = true
	var before := _snapshot(session)
	best_stars[index] = maxi(best_stars[index], int(stars))
	if grants:
		_stage_level_reward(session, index)
	return _commit(session, persist, before, level_id, Levels.FIRST_CLEAR_COINS if grants else 0, Levels.FIRST_CLEAR_SEEDS if grants else 0)


func claim_level_reward(session, level_id: Variant, persist: Callable) -> Dictionary:
	var rejection := _check_transaction(session, persist)
	if not rejection.is_empty():
		return rejection
	if not Levels.is_valid_id(level_id):
		return _failure("invalid_level", "Tato úroveň není dostupná.")
	if not reward_pending(level_id):
		return _failure("no_reward", "Odměna už je vyzvednutá nebo úroveň není dokončená.")
	if not _level_reward_available(session):
		return _failure("seed_capacity", "Uvolni dvě místa v zásobě semínek meduňky. Odměna na tebe počká.")
	_mutating = true
	var before := _snapshot(session)
	_stage_level_reward(session, int(level_id) - 1)
	return _commit(session, persist, before, level_id, Levels.FIRST_CLEAR_COINS, Levels.FIRST_CLEAR_SEEDS)


func claim_quest(session, persist: Callable) -> Dictionary:
	var rejection := _check_transaction(session, persist)
	if not rejection.is_empty():
		return rejection
	if quest_claimed:
		return _failure("already_claimed", "Odměna za hvězdy už je vyzvednutá.")
	if total_stars() < Levels.QUEST_STARS:
		return _failure("incomplete", "Nasbírej šest hvězd v čajovně.")
	if session.coins > MAX_COINS - Levels.QUEST_COINS:
		return _failure("wallet_full", "Zásoba mincí je plná. Odměna na tebe počká.")
	_mutating = true
	var before := _snapshot(session)
	quest_claimed = true
	session.coins += Levels.QUEST_COINS
	return _commit(session, persist, before, 0, Levels.QUEST_COINS, 0)


func claim_chapter(session, persist: Callable) -> Dictionary:
	var rejection := _check_transaction(session, persist)
	if not rejection.is_empty():
		return rejection
	if chapter_claimed:
		return _failure("already_claimed", "Odměna za zahradu už je vyzvednutá.")
	if not chapter_complete():
		return _failure("incomplete", "Dokonči všech deset úrovní bylinkové zahrady.")
	if session.coins > MAX_COINS - Levels.CHAPTER_COINS:
		return _failure("wallet_full", "Zásoba mincí je plná. Odměna na tebe počká.")
	_mutating = true
	var before := _snapshot(session)
	chapter_claimed = true
	session.coins += Levels.CHAPTER_COINS
	return _commit(session, persist, before, 0, Levels.CHAPTER_COINS, 0)


func _check_transaction(session, persist: Callable) -> Dictionary:
	if session == null:
		return _failure("invalid_session", "Herní postup není dostupný.")
	if _mutating:
		return _failure("busy", "Počkej na dokončení ukládání.")
	if SaveManager.writes_blocked:
		return _failure("save_unavailable", "Uložený postup je chráněný. Odměna na tebe počká.")
	if not persist.is_valid():
		return _failure("persist_required", "Výsledek teď nelze bezpečně uložit.")
	return {}


func _level_reward_available(session) -> bool:
	return session.plant_profiles.has(Levels.REWARD_SPECIES) and session.get_seed_count(Levels.REWARD_SPECIES) <= session.MAX_SEEDS_PER_SPECIES - Levels.FIRST_CLEAR_SEEDS and session.coins <= MAX_COINS - Levels.FIRST_CLEAR_COINS


func _stage_level_reward(session, index: int) -> void:
	session.coins += Levels.FIRST_CLEAR_COINS
	session.seed_inventory[Levels.REWARD_SPECIES] = session.get_seed_count(Levels.REWARD_SPECIES) + Levels.FIRST_CLEAR_SEEDS
	# As with authored workshop rewards, stage discovery without sending story
	# events from a transaction that may still be rejected by the filesystem.
	var discovered: Dictionary = session.get_species_progress(Levels.REWARD_SPECIES)
	discovered["discovered"] = true
	session.species_progress[Levels.REWARD_SPECIES] = discovered
	session._normalize_botanical_pack_pity_after_discovery()
	reward_claimed[index] = true


func _snapshot(session) -> Dictionary:
	return {"progress": to_dict(), "coins": session.coins, "seeds": session.seed_inventory.duplicate(true), "species": session.species_progress.duplicate(true), "pity": session.botanical_pack_pity, "saved_at": session.saved_at_unix}


func _commit(session, persist: Callable, before: Dictionary, level_id: int, coins: int, seeds: int) -> Dictionary:
	var persisted: Variant = persist.call()
	if not persisted is bool or persisted != true:
		best_stars.assign(before.progress.best_stars)
		reward_claimed.assign(before.progress.reward_claimed)
		quest_claimed = before.progress.quest_claimed
		chapter_claimed = before.progress.chapter_claimed
		session.coins = before.coins
		session.seed_inventory = before.seeds
		session.species_progress = before.species
		session.botanical_pack_pity = before.pity
		session.saved_at_unix = before.saved_at
		_mutating = false
		return _failure("save_failed", "Výsledek se nepodařilo uložit. Postup i odměna zůstaly beze změny.")
	if coins > 0:
		session.feedback_requested.emit("coins", session.selected_plant_index, {"amount": coins, "source": "teahouse_quest" if level_id == 0 else "teahouse_first_clear", "level_id": level_id})
	var result := _success(level_id, true, coins, seeds)
	_mutating = false
	return result


func _success(level_id: int, changed: bool, coins: int, seeds: int) -> Dictionary:
	var pending := reward_pending(level_id) if level_id > 0 else false
	return {"ok": true, "reason": "", "changed": changed, "level_id": level_id, "best_stars": best_stars[level_id - 1] if level_id > 0 else 0, "total_stars": total_stars(), "coins": coins, "seeds": seeds, "reward_granted": coins > 0, "reward_pending": pending, "message": "Úroveň je uložená. Odměna počká, až bude místo na semínka." if pending else ("Odměna je uložená." if coins > 0 else "Nejlepší výsledek zůstává uložený.")}


static func _failure(reason: String, message: String) -> Dictionary:
	return {"ok": false, "reason": reason, "message": message, "changed": false, "coins": 0, "seeds": 0, "reward_granted": false}
