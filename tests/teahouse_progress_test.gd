extends RefCounted

const Levels := preload("res://scripts/teahouse/tea_levels.gd")
const Progress := preload("res://scripts/teahouse/tea_progress.gd")
const Board := preload("res://scripts/teahouse/tea_board_model.gd")


static func _stars(prefix: Array = []) -> Array[int]:
	var result: Array[int] = []
	result.resize(Levels.COUNT)
	result.fill(0)
	for index in range(mini(prefix.size(), Levels.COUNT)):
		result[index] = int(prefix[index])
	return result


static func _rewards(prefix: Array = []) -> Array[bool]:
	var result: Array[bool] = []
	result.resize(Levels.COUNT)
	result.fill(false)
	for index in range(mini(prefix.size(), Levels.COUNT)):
		result[index] = bool(prefix[index])
	return result


static func _all_stars(value := 3) -> Array[int]:
	var result := _stars()
	result.fill(value)
	return result


static func _all_rewards() -> Array[bool]:
	var result := _rewards()
	result.fill(true)
	return result


static func _session(catalog: Dictionary) -> GameSession:
	var session := GameSession.new(catalog)
	session.coins = 100
	session.xp = 400
	session.seed_inventory[Levels.REWARD_SPECIES] = 0
	return session


static func _snapshot(session: GameSession) -> Dictionary:
	var result := session.to_dict().duplicate(true)
	result.erase("saved_at_unix")
	return result


static func _path(board: RefCounted, chain: Array[int]) -> Array[int]:
	if chain.size() == 3:
		return chain
	for index in range(36):
		if board.can_extend(chain, index):
			var candidate: Array[int] = chain.duplicate()
			candidate.append(index)
			var found := _path(board, candidate)
			if not found.is_empty():
				return found
	return []


static func _needed_path(board: RefCounted) -> Array[int]:
	for needed in [true, false]:
		for index in range(36):
			var herb: int = board.board[index]
			if needed and int(board.collected.get(herb, 0)) >= int(board.goals.get(herb, 0)):
				continue
			var start: Array[int] = [index]
			var found := _path(board, start)
			if not found.is_empty():
				return found
	return []


static func run(tree: SceneTree, check: Callable = Callable()) -> void:
	var verify := check if check.is_valid() else Callable(tree, "_check")
	var before_checks: int = tree.checks
	var catalog: Dictionary = tree._load_plant_catalog()
	var was_blocked := SaveManager.writes_blocked
	SaveManager.writes_blocked = false
	verify.call(GameSession.TEAHOUSE_PROGRESS_SCHEMA == 47 and GameSession.TEAHOUSE_CHAPTER_SCHEMA == 48 and GameSession.SAVE_SCHEMA == 48, "Čajovna postup: schema48 rozšíří kapitolu bez posunu historické trust hranice47")
	verify.call(Levels.COUNT == 10 and Levels.FIRST_CLEAR_COINS == 30 and Levels.FIRST_CLEAR_SEEDS == 2 and Levels.QUEST_STARS == 6 and Levels.QUEST_COINS == 40 and Levels.CHAPTER_COINS == 80, "Čajovna postup: deset úrovní zachová první i hvězdové odměny a přidá80mincí za kapitolu")
	var original_levels := [
		{"id": 1, "name": "Svěží ráno", "recipe_index": 0, "goals": {0: 6, 1: 3}, "moves": 20, "seed": 20261052},
		{"id": 2, "name": "Klidný večer", "recipe_index": 1, "goals": {3: 8, 2: 6}, "moves": 18, "seed": 20261169},
		{"id": 3, "name": "Zahradní posezení", "recipe_index": 2, "goals": {0: 6, 1: 6, 3: 6}, "moves": 18, "seed": 20261286},
	]
	for index in range(3):
		verify.call(Levels.get_level(index + 1) == original_levels[index], "Čajovna katalog: původní zadání, tahy i seed úrovně%d se nemění" % (index + 1))
	for id: Variant in [null, true, false, 0, -1, Levels.COUNT + 1, 1.0, "1", {}, []]:
		verify.call(not Levels.is_valid_id(id) and Levels.get_level(id).is_empty(), "Čajovna katalog: neplatné ID není budoucí úroveň: " + str(id))
	for id in range(1, Levels.COUNT + 1):
		var definition := Levels.get_level(id)
		var board := Board.new()
		board.reset_level(definition)
		for turn in range(int(definition.moves)):
			if board.phase != "matching":
				break
			var path := _needed_path(board)
			if path.is_empty():
				break
			board.submit_chain(path)
		verify.call(board.phase == "pouring" and board.finish_pour(0.72).accepted, "Čajovna katalog: deterministická úroveň%d se dá vyhrát skutečnými tahy a nalitím" % id)
		definition.goals.clear()
		verify.call(not Levels.get_level(id).goals.is_empty(), "Čajovna katalog: volající nemění sdílené zadání%d" % id)

	var session := _session(catalog)
	var progress = session.teahouse_progress
	var calls := [0]
	var persist := func() -> bool:
		calls[0] += 1
		return true
	var before := _snapshot(session)
	verify.call(progress.best_stars == _stars() and progress.reward_claimed == _rewards() and progress.total_stars() == 0 and progress.unlocked_level() == 1 and progress.completed_levels() == 0 and not progress.chapter_complete() and not progress.chapter_claimed and not progress.reward_pending(), "Čajovna postup: čerstvý profil má deset nulovaných pozic, jen první úroveň a žádnou odměnu")
	for id: Variant in [null, true, 0, -1, Levels.COUNT + 1, 1.0, "1"]:
		verify.call(not progress.complete_level(session, id, 3, persist).ok and before == _snapshot(session) and calls[0] == 0, "Čajovna postup: chybná úroveň nic nezmění")
	for stars: Variant in [null, true, false, 0, -1, 4, 3.0, 1.5, NAN, INF, "3"]:
		verify.call(not progress.complete_level(session, 1, stars, persist).ok and before == _snapshot(session) and calls[0] == 0, "Čajovna postup: vyžaduje skutečný int1..3 bez záměny bool a float")
	verify.call(progress.complete_level(session, 2, 3, persist).reason == "locked" and before == _snapshot(session), "Čajovna postup: nelze přeskočit první úroveň")
	verify.call(progress.complete_level(null, 1, 3, persist).reason == "invalid_session" and progress.complete_level(session, 1, 3, Callable()).reason == "persist_required", "Čajovna postup: chybějící session ani persistence neudělí výsledek")
	verify.call(not progress.claim_quest(session, persist).ok and not progress.claim_level_reward(session, 1, persist).ok and calls[0] == 0, "Čajovna postup: bez dokončení ani šesti hvězd není odměna")

	var events: Array[Dictionary] = []
	var feedback := func(kind: String, _index: int, payload: Dictionary) -> void:
		events.append({"kind": kind, "payload": payload.duplicate(true)})
	session.feedback_requested.connect(feedback)
	session.saved_at_unix = 123.0
	var attempted: Array[Dictionary] = []
	var failed: Dictionary = progress.complete_level(session, 1, 3, func() -> bool:
		attempted.append(session.to_dict().duplicate(true))
		verify.call(events.is_empty(), "Čajovna postup: před zápisem není žádný oslavný signál")
		return false)
	verify.call(not failed.ok and failed.reason == "save_failed" and session.saved_at_unix == 123.0 and events.is_empty(), "Čajovna postup: neúspěšný zápis obnoví timestamp a nevydá feedback")
	verify.call(attempted.size() == 1 and attempted[0].coins == 130 and attempted[0].teahouse_progress.best_stars == _stars([3]) and attempted[0].teahouse_progress.reward_claimed == _rewards([true]) and attempted[0].seed_inventory[Levels.REWARD_SPECIES] == 2, "Čajovna postup: disk dostane hvězdy, reward flag, mince i semena společně")
	verify.call(before == _snapshot(session), "Čajovna postup: rollback vrátí celý ekonomický a herní stav")
	for invalid: Variant in [null, 1, "true", {}, []]:
		verify.call(not progress.complete_level(session, 1, 3, func(): return invalid).ok and before == _snapshot(session) and events.is_empty(), "Čajovna postup: pouze booltrue potvrzuje durable zápis")

	var nested: Array[Dictionary] = []
	var success: Dictionary = progress.complete_level(session, 1, 2, func() -> bool:
		nested.append(progress.complete_level(session, 2, 3, persist))
		verify.call(events.is_empty(), "Čajovna postup: ani první úspěch neoslaví před callbackem")
		return true)
	verify.call(success.ok and success.changed and success.coins == 30 and success.seeds == 2 and session.coins == 130 and session.get_seed_count(Levels.REWARD_SPECIES) == 2 and progress.best_stars == _stars([2]) and progress.is_unlocked(2) and not progress.is_unlocked(3), "Čajovna postup: první výhra uloží přesně2hvězdy,30mincí,2semínka a další úroveň")
	verify.call(nested.size() == 1 and nested[0].reason == "busy" and events.size() == 1, "Čajovna postup: vnořený callback nic nezdvojí a feedback přijde jednou")
	var calls_before: int = calls[0]
	verify.call(progress.complete_level(session, 1, 1, persist).ok and not progress.complete_level(session, 1, 2, persist).changed and calls[0] == calls_before and session.coins == 130 and progress.best_stars[0] == 2, "Čajovna postup: horší a stejný replay nebere nejlepší hvězdy ani neopakuje odměnu/zápis")
	verify.call(not progress.claim_level_reward(session, 1, persist).ok and session.coins == 130, "Čajovna postup: dvojklik na první odměnu nic nevydá")
	verify.call(progress.complete_level(session, 2, 3, persist).ok and progress.total_stars() == 5 and not progress.claim_quest(session, persist).ok, "Čajovna postup: hvězdy se sčítají z nejlepších výsledků a5 nestačí")
	verify.call(progress.complete_level(session, 1, 3, persist).ok and progress.total_stars() == 6 and session.coins == 160 and session.get_seed_count(Levels.REWARD_SPECIES) == 4, "Čajovna postup: zlepšení na3hvězdy otevře quest bez další první odměny")
	before = _snapshot(session)
	verify.call(not progress.claim_quest(session, func(): return false).ok and before == _snapshot(session), "Čajovna postup: neúspěch quest odměny vrátí flag i mince")
	verify.call(progress.claim_quest(session, persist).ok and progress.quest_claimed and session.coins == 200, "Čajovna postup: šest hvězd udělí přesně40mincí jednou")
	before = _snapshot(session)
	verify.call(not progress.claim_quest(session, persist).ok and before == _snapshot(session), "Čajovna postup: opakování questu nemění peněženku")
	session.feedback_requested.disconnect(feedback)

	var pending_session := _session(catalog)
	var pending = pending_session.teahouse_progress
	pending_session.seed_inventory[Levels.REWARD_SPECIES] = pending_session.MAX_SEEDS_PER_SPECIES
	var pending_result: Dictionary = pending.complete_level(pending_session, 1, 3, persist)
	verify.call(pending_result.ok and pending_result.reward_pending and pending.reward_pending(1) and pending.reward_pending() and pending.best_stars == _stars([3]) and pending.unlocked_level() == 2 and pending_session.coins == 100, "Čajovna postup: plná semena uloží výhru a odemčení, celá první odměna počká")
	var pending_copy := GameSession.new(catalog)
	pending_copy.from_dict(JSON.parse_string(JSON.stringify(pending_session.to_dict())))
	verify.call(pending_copy.teahouse_progress.best_stars == _stars([3]) and pending_copy.teahouse_progress.reward_pending(1) and pending_copy.coins == 100 and not pending_copy.teahouse_progress.claim_level_reward(pending_copy, 1, persist).ok, "Čajovna postup: čekající první odměna i její výhra přežijí restart při plných semenech")
	before = _snapshot(pending_session)
	verify.call(not pending.claim_level_reward(pending_session, 1, persist).ok and before == _snapshot(pending_session), "Čajovna postup: plná zásoba nespotřebuje ani část čekající odměny")
	pending_session.seed_inventory[Levels.REWARD_SPECIES] -= 2
	before = _snapshot(pending_session)
	verify.call(not pending.claim_level_reward(pending_session, 1, func(): return false).ok and before == _snapshot(pending_session) and pending.reward_pending(1), "Čajovna postup: neúspěšné vyzvednutí ponechá čekající odměnu")
	verify.call(pending.claim_level_reward(pending_session, 1, persist).ok and not pending.reward_pending() and pending_session.coins == 130 and pending_session.get_seed_count(Levels.REWARD_SPECIES) == pending_session.MAX_SEEDS_PER_SPECIES, "Čajovna postup: dvě volná místa umožní pozdější celou odměnu")

	SaveManager.writes_blocked = true
	before = _snapshot(pending_session)
	verify.call(not pending.complete_level(pending_session, 2, 3, persist).ok and not pending.claim_level_reward(pending_session, 2, persist).ok and not pending.claim_quest(pending_session, persist).ok and before == _snapshot(pending_session), "Čajovna postup: chráněný profil blokuje všechny tři transakce")
	SaveManager.writes_blocked = false
	_test_load(verify, catalog, session)
	_test_schema47(verify, catalog)
	_test_chapter(verify, catalog)
	SaveManager.writes_blocked = was_blocked
	print("TEAHOUSE_PROGRESS_CHECKS=%d" % (tree.checks - before_checks))


static func _test_load(verify: Callable, catalog: Dictionary, source: GameSession) -> void:
	var progress := Progress.new()
	for raw: Variant in [null, true, 1, "progress", []]:
		progress.load_data(raw)
		verify.call(progress.best_stars == _stars() and not progress.quest_claimed and not progress.chapter_claimed and not progress.reward_pending(), "Čajovna save: neplatný typ bezpečně vytvoří čistý postup")
	for bad: Variant in [true, false, "3", 3.5, -1, 4, NAN, INF, [], {}]:
		progress.load_data({"best_stars": [bad, 3, 3], "reward_claimed": [true, true, true], "quest_claimed": true})
		verify.call(progress.best_stars == _stars() and progress.reward_claimed == _rewards() and not progress.quest_claimed, "Čajovna save: chybná první hvězda neodemkne další úrovně ani reward flags")
	progress.load_data({"best_stars": [3, 0, 3], "reward_claimed": [true, true, true], "quest_claimed": true})
	verify.call(progress.best_stars == _stars([3]) and progress.reward_claimed == _rewards([true]) and not progress.quest_claimed, "Čajovna save: úrovně musí mít souvislý dokončený prefix")
	progress.load_data({"best_stars": [3.0, 3.0, 2.0], "reward_claimed": [true, 1, "true"], "quest_claimed": 1})
	verify.call(progress.best_stars == _stars([3, 3, 2]) and progress.reward_claimed == _rewards([true]) and not progress.quest_claimed, "Čajovna save: integrální JSON čísla zachová, claim flags musí být skutečné bool")
	var detached := progress.to_dict()
	detached.best_stars[0] = 0
	detached.reward_claimed[0] = false
	verify.call(progress.best_stars[0] == 3 and progress.reward_claimed[0], "Čajovna save: serializovaný výstup nemění živý postup")
	progress.load_data({})
	verify.call(progress.best_stars == _stars() and progress.reward_claimed == _rewards() and not progress.chapter_claimed, "Čajovna save: opakovaný load bez polí nepřenese starý profil")
	progress.load_data({"best_stars": [3, 3, 3, 3], "reward_claimed": [true, true, true, true], "quest_claimed": true, "chapter_claimed": true}, 3)
	verify.call(progress.best_stars == _stars([3, 3, 3]) and progress.reward_claimed == _rewards([true, true, true]) and progress.total_stars() == 9 and progress.best_stars.size() == Levels.COUNT and progress.reward_claimed.size() == Levels.COUNT and progress.quest_claimed and not progress.chapter_claimed, "Čajovna save: starý prefix3 neautorizuje čtvrtou úroveň ani novou kapitolovou odměnu")
	for schema in range(1, 47):
		var restored := GameSession.new(catalog)
		restored.from_dict({"schema": schema, "coins": 123, "teahouse_progress": {"best_stars": [3, 3, 3], "reward_claimed": [true, true, true], "quest_claimed": true}})
		verify.call(restored.coins == 123 and restored.teahouse_progress.total_stars() == 0 and not restored.teahouse_progress.quest_claimed and not restored.teahouse_progress.reward_pending(), "Čajovna migrace: schema%d nevěří budoucím klíčům a nevydá mince" % schema)
	var source_data := source.to_dict().duplicate(true)
	var legacy_data := source_data.duplicate(true)
	legacy_data.schema = 46
	var legacy := GameSession.new(catalog)
	legacy.from_dict(legacy_data)
	verify.call(legacy.coins == source.coins and legacy.xp == source.xp and legacy.get_seed_inventory_snapshot() == source.get_seed_inventory_snapshot() and legacy.greenhouse.to_dict() == source.greenhouse.to_dict() and legacy.workshop_products.to_dict() == source.workshop_products.to_dict() and legacy.owned_greenhouse_decorations == source.owned_greenhouse_decorations and legacy.teahouse_progress.total_stars() == 0, "Čajovna migrace: skutečný schema46 profil zachová peněženku, semena, záhony, výrobky a dekorace")
	var encoded: Variant = JSON.parse_string(JSON.stringify(source_data))
	var restored := GameSession.new(catalog)
	restored.from_dict(encoded)
	verify.call(restored.teahouse_progress.to_dict() == source.teahouse_progress.to_dict() and restored.coins == source.coins and restored.get_seed_inventory_snapshot() == source.get_seed_inventory_snapshot(), "Čajovna save: skutečný JSON roundtrip zachová hvězdy i jednorázové odměny")
	var before := _snapshot(restored)
	verify.call(not restored.teahouse_progress.claim_quest(restored, func(): return true).ok and not restored.teahouse_progress.claim_level_reward(restored, 1, func(): return true).ok and before == _snapshot(restored), "Čajovna save: restart znovu nevydá první ani hvězdovou odměnu")
	for schema: Variant in [true, "47", 47.5, NAN, INF, 0, -1, GameSession.SAVE_SCHEMA + 1]:
		var hostile := source_data.duplicate(true)
		hostile.schema = schema
		restored.from_dict(hostile)
		verify.call(restored.teahouse_progress.total_stars() == 0 and not restored.teahouse_progress.quest_claimed, "Čajovna migrace: chybná schema neautorizuje nový postup")
	var no_key := source_data.duplicate(true)
	no_key.erase("teahouse_progress")
	restored.from_dict(source_data)
	restored.from_dict(no_key)
	verify.call(restored.teahouse_progress.total_stars() == 0 and not restored.teahouse_progress.quest_claimed, "Čajovna migrace: profil bez nového klíče vždy začne čistým postupem")
	var paths := ["user://tea-progress-primary.json", "user://tea-progress-backup.json", "user://tea-progress-temp.json"]
	for path in paths:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	verify.call(SaveManager._save_session_to_paths(source, paths[0], paths[1], paths[2]), "Čajovna save: reálný atomický zápis hotového postupu")
	restored.from_dict(SaveManager._read_supported_data(paths[0]))
	verify.call(restored.teahouse_progress.to_dict() == source.teahouse_progress.to_dict() and restored.coins == source.coins, "Čajovna save: disk obnoví jednorázové flags se stejnou peněženkou")
	for path in paths:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))


static func _test_schema47(verify: Callable, catalog: Dictionary) -> void:
	var persist := func() -> bool: return true
	var paid := _session(catalog)
	for id in range(1, 4):
		verify.call(paid.teahouse_progress.complete_level(paid, id, 3, persist).ok, "Čajovna migrace47: připraví skutečně zaplacenou starou úroveň%d" % id)
	verify.call(paid.teahouse_progress.claim_quest(paid, persist).ok, "Čajovna migrace47: připraví jednou vyzvednutý původní quest")
	var old_paid := paid.to_dict().duplicate(true)
	old_paid.schema = 47
	old_paid.teahouse_progress.best_stars = old_paid.teahouse_progress.best_stars.slice(0, 3)
	old_paid.teahouse_progress.reward_claimed = old_paid.teahouse_progress.reward_claimed.slice(0, 3)
	old_paid.teahouse_progress.erase("chapter_claimed")
	var restored := GameSession.new(catalog)
	restored.from_dict(JSON.parse_string(JSON.stringify(old_paid)))
	verify.call(restored.teahouse_progress.best_stars == _stars([3, 3, 3]) and restored.teahouse_progress.reward_claimed == _rewards([true, true, true]) and restored.teahouse_progress.quest_claimed and not restored.teahouse_progress.chapter_claimed and restored.teahouse_progress.unlocked_level() == 4, "Čajovna migrace47: tři placené úrovně i quest zůstanou vybrané a nová čtvrtá se odemkne")
	verify.call(restored.coins == paid.coins and restored.get_seed_inventory_snapshot() == paid.get_seed_inventory_snapshot() and restored.xp == paid.xp and restored.greenhouse.to_dict() == paid.greenhouse.to_dict() and restored.workshop_products.to_dict() == paid.workshop_products.to_dict(), "Čajovna migrace47: načtení nic nepřidělí a zachová ekonomiku i původní zahradu")
	var calls := [0]
	var counted_persist := func() -> bool:
		calls[0] += 1
		return true
	var before := _snapshot(restored)
	verify.call(restored.teahouse_progress.complete_level(restored, 1, 3, counted_persist).ok and not restored.teahouse_progress.claim_level_reward(restored, 2, counted_persist).ok and not restored.teahouse_progress.claim_quest(restored, counted_persist).ok and calls[0] == 0 and before == _snapshot(restored), "Čajovna migrace47: replay a dvojklik znovu nevydají staré první ani quest odměny")
	verify.call(restored.teahouse_progress.complete_level(restored, 4, 1, counted_persist).ok and restored.coins == paid.coins + 30 and restored.get_seed_count(Levels.REWARD_SPECIES) == paid.get_seed_count(Levels.REWARD_SPECIES) + 2 and restored.teahouse_progress.best_stars == _stars([3, 3, 3, 1]) and calls[0] == 1, "Čajovna migrace47: první nová čtvrtá výhra vydá jen svou vlastní odměnu")

	var pending := _session(catalog)
	pending.seed_inventory[Levels.REWARD_SPECIES] = pending.MAX_SEEDS_PER_SPECIES
	for id in range(1, 4):
		verify.call(pending.teahouse_progress.complete_level(pending, id, id, persist).ok, "Čajovna migrace47: výhra%d se uchová i s čekajícími semeny" % id)
	verify.call(pending.teahouse_progress.claim_quest(pending, persist).ok, "Čajovna migrace47: šest skutečných hvězd dovolí původní quest i při plných semenech")
	pending.seed_inventory[Levels.REWARD_SPECIES] -= 2
	verify.call(pending.teahouse_progress.claim_level_reward(pending, 1, persist).ok, "Čajovna migrace47: smíšený starý profil má první odměnu vybranou a další dvě čekající")
	var old_pending := pending.to_dict().duplicate(true)
	old_pending.schema = 47
	for index in range(3, Levels.COUNT):
		old_pending.teahouse_progress.best_stars[index] = 3
		old_pending.teahouse_progress.reward_claimed[index] = true
	old_pending.teahouse_progress.chapter_claimed = true
	restored.from_dict(JSON.parse_string(JSON.stringify(old_pending)))
	verify.call(restored.teahouse_progress.best_stars == _stars([1, 2, 3]) and restored.teahouse_progress.reward_claimed == _rewards([true]) and restored.teahouse_progress.quest_claimed and not restored.teahouse_progress.chapter_claimed and restored.teahouse_progress.completed_levels() == 3 and restored.teahouse_progress.unlocked_level() == 4 and restored.teahouse_progress.reward_pending(2) and restored.teahouse_progress.reward_pending(3), "Čajovna migrace47: zachová placené i pending flags, ale odmítne podvržené4..10 a chapter flag")
	verify.call(restored.coins == pending.coins and restored.get_seed_inventory_snapshot() == pending.get_seed_inventory_snapshot(), "Čajovna migrace47: odříznutí cizího postupu neodebere ani nevytvoří mince/semena")
	before = _snapshot(restored)
	calls[0] = 0
	verify.call(not restored.teahouse_progress.claim_level_reward(restored, 2, counted_persist).ok and calls[0] == 0 and before == _snapshot(restored), "Čajovna migrace47: plná zásoba nevybere čekající odměnu při načtení nebo kliknutí")
	restored.seed_inventory[Levels.REWARD_SPECIES] -= 2
	verify.call(restored.teahouse_progress.claim_level_reward(restored, 2, counted_persist).ok and restored.coins == pending.coins + 30 and restored.teahouse_progress.reward_claimed == _rewards([true, true]) and restored.teahouse_progress.reward_pending(3) and calls[0] == 1, "Čajovna migrace47: uvolněná semena dovolí vybrat právě jednu zachovanou pending odměnu")
	var upgraded := GameSession.new(catalog)
	upgraded.from_dict(JSON.parse_string(JSON.stringify(restored.to_dict())))
	verify.call(upgraded.teahouse_progress.to_dict() == restored.teahouse_progress.to_dict() and upgraded.coins == restored.coins and upgraded.teahouse_progress.reward_pending(3), "Čajovna migrace47: po prvním schema48 roundtrip zůstane poslední pending odměna čekat")

	var progress := Progress.new()
	var extra_stars: Array = _all_stars()
	var extra_rewards: Array = _all_rewards()
	extra_stars.append(3)
	extra_rewards.append(true)
	progress.load_data({"best_stars": extra_stars, "reward_claimed": extra_rewards, "quest_claimed": true, "chapter_claimed": true})
	verify.call(progress.best_stars == _all_stars() and progress.reward_claimed == _all_rewards() and progress.total_stars() == 30 and progress.completed_levels() == 10 and progress.chapter_complete() and progress.chapter_claimed, "Čajovna save48: pouze deset známých pozic, jedenáctá nevytvoří hvězdy ani odměnu")
	for index in range(Levels.COUNT):
		for invalid: Variant in [true, "3", 3.5, -1, 4, NAN, INF]:
			var malformed: Array = []
			for _index in range(Levels.COUNT):
				malformed.append(3)
			malformed[index] = invalid
			progress.load_data({"best_stars": malformed, "reward_claimed": _all_rewards(), "chapter_claimed": true})
			var expected_stars := _stars()
			var expected_rewards := _rewards()
			for preceding in range(index):
				expected_stars[preceding] = 3
				expected_rewards[preceding] = true
			verify.call(progress.best_stars == expected_stars and progress.reward_claimed == expected_rewards and progress.completed_levels() == index and not progress.chapter_complete() and not progress.chapter_claimed, "Čajovna save48: chyba v pozici%d nepustí další úrovně ani kapitolovou odměnu: %s" % [index + 1, str(invalid)])
	for flag: Variant in [null, 0, 1, 1.0, "true", {}, [], false]:
		progress.load_data({"best_stars": _all_stars(1), "reward_claimed": _all_rewards(), "chapter_claimed": flag})
		verify.call(progress.chapter_complete() and progress.total_stars() == 10 and not progress.chapter_claimed, "Čajovna save48: chapter claim vyžaduje skutečné booltrue: " + str(flag))
	progress.load_data({"best_stars": _all_stars(1), "reward_claimed": _all_rewards(), "chapter_claimed": true})
	var detached := progress.to_dict()
	detached.chapter_claimed = false
	verify.call(progress.chapter_claimed, "Čajovna save48: detached výstup neodemkne již vyzvednutou kapitolovou odměnu")
	progress.load_data({})
	verify.call(progress.best_stars == _stars() and progress.reward_claimed == _rewards() and not progress.quest_claimed and not progress.chapter_claimed, "Čajovna save48: opakovaný prázdný load nezachová žádný chráněný flag")


static func _test_chapter(verify: Callable, catalog: Dictionary) -> void:
	var session := _session(catalog)
	var progress = session.teahouse_progress
	var paths := ["user://tea-chapter-primary.json", "user://tea-chapter-backup.json", "user://tea-chapter-temp.json"]
	for path in paths:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	var saves := [0]
	var persist := func() -> bool:
		saves[0] += 1
		return SaveManager._save_session_to_paths(session, paths[0], paths[1], paths[2])
	var before := _snapshot(session)
	verify.call(not progress.claim_chapter(session, persist).ok and before == _snapshot(session) and saves[0] == 0, "Čajovna kapitola: prázdný profil nedostane80mincí")
	verify.call(progress.claim_chapter(null, persist).reason == "invalid_session" and progress.claim_chapter(session, Callable()).reason == "persist_required", "Čajovna kapitola: chybějící profil ani durable callback nevydají odměnu")
	for id in range(1, Levels.COUNT + 1):
		var outcome: Dictionary = progress.complete_level(session, id, 1, persist)
		var restored := GameSession.new(catalog)
		restored.from_dict(SaveManager._read_supported_data(paths[0]))
		var expected_stars := _stars()
		var expected_rewards := _rewards()
		for index in range(id):
			expected_stars[index] = 1
			expected_rewards[index] = true
		verify.call(outcome.ok and outcome.reward_granted and progress.completed_levels() == id and progress.best_stars == expected_stars and progress.reward_claimed == expected_rewards and session.coins == 100 + id * 30 and session.get_seed_count(Levels.REWARD_SPECIES) == id * 2 and saves[0] == id, "Čajovna kapitola: skutečný durable výsledek%d vydá právě svou první odměnu" % id)
		verify.call(restored.teahouse_progress.to_dict() == progress.to_dict() and restored.coins == session.coins and restored.get_seed_count(Levels.REWARD_SPECIES) == session.get_seed_count(Levels.REWARD_SPECIES), "Čajovna kapitola: diskový reload%d zachová přesné hvězdy, flags a peněženku" % id)
		if id < Levels.COUNT:
			before = _snapshot(session)
			verify.call(not progress.chapter_complete() and not progress.claim_chapter(session, persist).ok and before == _snapshot(session) and saves[0] == id, "Čajovna kapitola: ani%d hotových úrovní nespotřebuje kapitolový flag" % id)
	verify.call(progress.chapter_complete() and progress.completed_levels() == 10 and progress.total_stars() == 10 and not progress.chapter_claimed and not progress.quest_claimed and session.coins == 400 and progress.unlocked_level() == 10, "Čajovna kapitola: deset1hvězdových výher stačí, kapitola ani quest se nevyberou automaticky")

	var protected_before := _snapshot(session)
	SaveManager.writes_blocked = true
	verify.call(not progress.claim_chapter(session, persist).ok and not progress.claim_quest(session, persist).ok and not progress.complete_level(session, 10, 3, persist).ok and not progress.claim_level_reward(session, 1, persist).ok and protected_before == _snapshot(session) and saves[0] == 10, "Čajovna kapitola: ochrana save nedovolí změnit chapter/quest/reward flags ani nejlepší hvězdy")
	SaveManager.writes_blocked = false
	var events: Array[Dictionary] = []
	var nested: Array[Dictionary] = []
	var feedback := func(kind: String, _index: int, payload: Dictionary) -> void:
		events.append({"kind": kind, "payload": payload.duplicate(true)})
		if int(payload.get("amount", 0)) == 80:
			nested.append(progress.claim_chapter(session, persist))
			var disk := SaveManager._read_supported_data(paths[0])
			verify.call(not disk.is_empty() and disk.teahouse_progress.chapter_claimed and int(disk.coins) == 480, "Čajovna kapitola: oslava80mincí nastane až po společném zápisu flagu a peněženky")
	session.feedback_requested.connect(feedback)
	before = _snapshot(session)
	session.saved_at_unix = 222.0
	var rejected_payloads: Array[Dictionary] = []
	var rejected: Dictionary = progress.claim_chapter(session, func() -> bool:
		rejected_payloads.append(session.to_dict().duplicate(true))
		verify.call(events.is_empty(), "Čajovna kapitola: čekající durable callback ještě nevydá oslavný signál")
		return false)
	verify.call(not rejected.ok and rejected.reason == "save_failed" and session.saved_at_unix == 222.0 and events.is_empty() and not progress.chapter_claimed and session.coins == 400, "Čajovna kapitola: selhání vrátí80mincí, chapter flag i timestamp")
	verify.call(rejected_payloads.size() == 1 and rejected_payloads[0].teahouse_progress.chapter_claimed and rejected_payloads[0].coins == 480 and before == _snapshot(session), "Čajovna kapitola: persist vidí atomickou odměnu, rollback nezmění žádný starší stav")
	for invalid: Variant in [null, 1, "true", {}, []]:
		verify.call(not progress.claim_chapter(session, func(): return invalid).ok and before == _snapshot(session) and events.is_empty(), "Čajovna kapitola: neplatný callback není durable potvrzení80mincí")
	var committed: Dictionary = progress.claim_chapter(session, func() -> bool:
		nested.append(progress.claim_chapter(session, persist))
		verify.call(events.is_empty(), "Čajovna kapitola: úspěšný callback musí předcházet feedbacku")
		return persist.call())
	verify.call(committed.ok and committed.coins == 80 and session.coins == 480 and progress.chapter_claimed and saves[0] == 11 and session.get_seed_count(Levels.REWARD_SPECIES) == 20 and progress.best_stars == _all_stars(1), "Čajovna kapitola: opakování uloží přesně80mincí bez podmínky3hvězd nebo změny semen")
	verify.call(nested.size() == 2 and nested[0].reason == "busy" and nested[1].reason == "busy" and events.size() == 1, "Čajovna kapitola: callback ani posluchač feedbacku nesmí vybrat kapitolu podruhé")
	session.feedback_requested.disconnect(feedback)
	before = _snapshot(session)
	verify.call(not progress.claim_chapter(session, persist).ok and before == _snapshot(session) and saves[0] == 11, "Čajovna kapitola: dvojklik na vybranou odměnu neudělá další zápis")
	var loaded := GameSession.new(catalog)
	loaded.from_dict(JSON.parse_string(JSON.stringify(SaveManager._read_supported_data(paths[0]))))
	var loaded_before := _snapshot(loaded)
	verify.call(loaded.teahouse_progress.chapter_claimed and loaded.coins == 480 and loaded.teahouse_progress.best_stars == _all_stars(1) and not loaded.teahouse_progress.claim_chapter(loaded, func(): return true).ok and loaded_before == _snapshot(loaded), "Čajovna kapitola: JSON i diskový restart zachovají vybraný flag a nepřidělí80znovu")
	verify.call(progress.complete_level(session, 1, 3, persist).ok and progress.best_stars == _stars([3, 1, 1, 1, 1, 1, 1, 1, 1, 1]) and progress.total_stars() == 12 and session.coins == 480 and session.get_seed_count(Levels.REWARD_SPECIES) == 20 and progress.chapter_claimed, "Čajovna kapitola: lepší replay po finále nepřidělí první ani kapitolovou odměnu")
	verify.call(progress.claim_quest(session, persist).ok and session.coins == 520 and progress.quest_claimed and progress.chapter_claimed, "Čajovna kapitola: původní40mincový quest se vybírá nezávisle a zůstává jednorázový")
	loaded.from_dict(SaveManager._read_supported_data(paths[0]))
	verify.call(loaded.teahouse_progress.quest_claimed and loaded.teahouse_progress.chapter_claimed and loaded.coins == 520 and not loaded.teahouse_progress.claim_quest(loaded, func(): return true).ok and not loaded.teahouse_progress.claim_chapter(loaded, func(): return true).ok, "Čajovna kapitola: poslední reload uzamkne obě samostatné jednorázové odměny")

	var full_wallet := _session(catalog)
	full_wallet.teahouse_progress.load_data({"best_stars": _all_stars(1), "reward_claimed": _all_rewards()})
	full_wallet.coins = Progress.MAX_COINS - Levels.CHAPTER_COINS + 1
	before = _snapshot(full_wallet)
	verify.call(not full_wallet.teahouse_progress.claim_chapter(full_wallet, func(): return true).ok and before == _snapshot(full_wallet) and not full_wallet.teahouse_progress.chapter_claimed, "Čajovna kapitola: téměř plná peněženka nepřeteče ani nespotřebuje odměnu")
	full_wallet.coins = Progress.MAX_COINS - Levels.CHAPTER_COINS
	verify.call(full_wallet.teahouse_progress.claim_chapter(full_wallet, func(): return true).ok and full_wallet.coins == Progress.MAX_COINS and full_wallet.teahouse_progress.chapter_claimed, "Čajovna kapitola: přesně80volných mincí bezpečně přijme celou odměnu")
	for path in paths:
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
