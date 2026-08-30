extends RefCounted

const PLANT_IDS: Array[String] = [
	"room_orchid", "mini_monstera", "snake_plant", "room_fern",
	"flowering_begonia", "round_leaf_pilea", "striped_calathea", "climbing_pothos",
	"silver_aglaonema", "pink_fittonia", "lemon_maranta", "colorful_coleus",
]
const PRIMARY_PATH := "user://phase166-model-primary.json"
const BACKUP_PATH := "user://phase166-model-backup.json"
const TEMP_PATH := "user://phase166-model-temp.json"
const RECOVERY_PATH := "user://phase166-model-recovery.json"
const ROTATION_PATH := "user://phase166-model-backup.json.rotation"
const DISK_PATHS: Array[String] = [PRIMARY_PATH, BACKUP_PATH, TEMP_PATH, RECOVERY_PATH, ROTATION_PATH]


static func run(suite: SceneTree, catalog: Dictionary) -> void:
	var catalog_session := GameSession.new(catalog)
	suite._check(
		GameSession.ROOM_PLANT_SLOT_COUNT == 12
		and catalog_session.get_room_decoration_ids_for_slot(0) == PLANT_IDS,
		"Fáze 166 model přesunu pokrývá všech dvanáct koupitelných rostlin a dvanáct míst stojanu"
	)
	for plant_index in range(PLANT_IDS.size()):
		var plant_id := PLANT_IDS[plant_index]
		var other_id := PLANT_IDS[(plant_index + 1) % PLANT_IDS.size()]
		for target_slot in range(12):
			var source_slot := (target_slot + 1) % 12
			var other_slot := (target_slot + 2) % 12
			var session := _new_session(catalog)
			var bought_source := session.purchase_or_place_room_decoration(plant_id, source_slot)
			var bought_other := session.purchase_or_place_room_decoration(other_id, other_slot)
			var bought_books := session.purchase_or_place_room_decoration("botanical_books", 12)
			var bought_cloche := session.purchase_or_place_room_decoration("golden_lamp", 15)
			# Every legal move must also work with an empty wallet.
			session.coins = 0
			var expected := _snapshot(session)
			var expected_slots: Array = expected["room_decoration_slots"]
			expected_slots[source_slot] = ""
			expected_slots[target_slot] = plant_id
			var moved := session.move_room_plant(source_slot, target_slot, plant_id)
			suite._check(
				bought_source and bought_other and bought_books and bought_cloche and moved,
				"Fáze 166 přesune vlastněnou %s z místa %d do prázdného místa %d bez mincí" % [plant_id, source_slot, target_slot]
			)
			suite._check(
				_snapshot(session) == expected
				and session.room_decoration_slots.count(plant_id) == 1
				and session.room_decoration_slots.count(other_id) == 1,
				"Fáze 166 přesun %s do místa %d mění pouze oba konce, bez duplikace nebo změny mincí, XP, vlastnictví a ostatního stavu" % [plant_id, target_slot]
			)
	_test_swaps(suite, catalog)
	_test_full_rack_swap(suite, catalog)
	_test_rejections(suite, catalog)
	_test_disk_roundtrip(suite, catalog)


static func _test_swaps(suite: SceneTree, catalog: Dictionary) -> void:
	for plant_index in range(PLANT_IDS.size()):
		var plant_id := PLANT_IDS[plant_index]
		var target_id := PLANT_IDS[(plant_index + 1) % PLANT_IDS.size()]
		var unchanged_id := PLANT_IDS[(plant_index + 2) % PLANT_IDS.size()]
		for target_slot in range(12):
			# Mirrored endpoints include both extreme rows and slots 0 <-> 11.
			var source_slot := 11 - target_slot
			var unchanged_slot := (target_slot + 1) % 12
			if unchanged_slot == source_slot:
				unchanged_slot = (unchanged_slot + 1) % 12
			var session := _new_session(catalog)
			var bought_source := session.purchase_or_place_room_decoration(plant_id, source_slot)
			var bought_target := session.purchase_or_place_room_decoration(target_id, target_slot)
			var bought_unchanged := session.purchase_or_place_room_decoration(unchanged_id, unchanged_slot)
			var bought_books := session.purchase_or_place_room_decoration("botanical_books", 12)
			var bought_cloche := session.purchase_or_place_room_decoration("golden_lamp", 15)
			session.coins = 0
			var before := _snapshot(session)
			var expected := before.duplicate(true)
			var expected_slots: Array = expected["room_decoration_slots"]
			expected_slots[source_slot] = target_id
			expected_slots[target_slot] = plant_id
			var swapped := session.move_room_plant(source_slot, target_slot, plant_id)
			suite._check(
				bought_source and bought_target and bought_unchanged and bought_books and bought_cloche and swapped,
				"Fáze 166 prohodí %s z místa %d s vlastněnou %s v místě %d i bez mincí" % [plant_id, source_slot, target_id, target_slot]
			)
			suite._check(
				_snapshot(session) == expected
				and session.room_decoration_slots.count(plant_id) == 1
				and session.room_decoration_slots.count(target_id) == 1
				and session.room_decoration_slots.count(unchanged_id) == 1,
				"Fáze 166 swap %s do místa %d změní pouze oba konce a zachová přesně všechen ostatní stav bez duplikace" % [plant_id, target_slot]
			)
			var swapped_back := session.move_room_plant(target_slot, source_slot, plant_id)
			suite._check(
				swapped_back,
				"Fáze 166 dovolí zpětný swap %s z místa %d do místa %d" % [plant_id, target_slot, source_slot]
			)
			suite._check(
				_snapshot(session) == before
				and session.room_decoration_slots.count(plant_id) == 1
				and session.room_decoration_slots.count(target_id) == 1
				and session.room_decoration_slots.count(unchanged_id) == 1,
				"Fáze 166 zpětný swap %s z místa %d obnoví přesně původní stav včetně mincí, XP a vlastnictví" % [plant_id, target_slot]
			)


static func _test_full_rack_swap(suite: SceneTree, catalog: Dictionary) -> void:
	var session := _new_session(catalog)
	var bought_all := true
	for slot_index in range(PLANT_IDS.size()):
		var bought := session.purchase_or_place_room_decoration(PLANT_IDS[slot_index], slot_index)
		bought_all = bought and bought_all
	var bought_books := session.purchase_or_place_room_decoration("botanical_books", 12)
	var bought_cloche := session.purchase_or_place_room_decoration("golden_lamp", 15)
	session.coins = 0
	suite._check(
		bought_all and bought_books and bought_cloche
		and session.get_room_decoration_slots().slice(0, 12) == PLANT_IDS,
		"Fáze 166 připraví plný stojan 12/12 bez jediného volného rostlinného místa a s nulovou peněženkou"
	)
	var before := _snapshot(session)
	var expected := before.duplicate(true)
	var expected_slots: Array = expected["room_decoration_slots"]
	expected_slots[0] = PLANT_IDS[11]
	expected_slots[11] = PLANT_IDS[0]
	suite._check(
		session.move_room_plant(0, 11, PLANT_IDS[0]),
		"Fáze 166 prohodí krajní místa 0 a 11 i na úplně plném stojanu"
	)
	suite._check(
		_snapshot(session) == expected and _all_plants_placed_once(session),
		"Fáze 166 krajní swap plného stojanu zachová všech dvanáct rostlin právě jednou a ostatní stav přesně beze změny"
	)
	suite._check(
		session.move_room_plant(11, 0, PLANT_IDS[0]),
		"Fáze 166 plný stojan dovolí také zpětný krajní swap 11 do 0"
	)
	suite._check(
		_snapshot(session) == before and _all_plants_placed_once(session),
		"Fáze 166 zpětný krajní swap plného stojanu obnoví přesně výchozí rozmístění i celý serializovaný stav"
	)


static func _all_plants_placed_once(session: GameSession) -> bool:
	for plant_id in PLANT_IDS:
		if session.room_decoration_slots.count(plant_id) != 1:
			return false
	return not session.get_room_decoration_slots().slice(0, 12).has("")


static func _new_session(catalog: Dictionary) -> GameSession:
	var session := GameSession.new(catalog)
	session.coins = 5000
	session.xp = 237
	# to_dict() normally advances this high-water mark. Freeze it in the
	# synthetic fixture so full-state comparisons remain exact, including time.
	session.saved_at_unix = GameSession.MAX_SUPPORTED_UNIX_TIME
	return session


static func _snapshot(session: GameSession) -> Dictionary:
	# Several serialized dictionaries/arrays are shared with the live session.
	# A deep copy is essential to detect in-place mutations in rejected moves.
	return session.to_dict().duplicate(true)


static func _check_rejected(suite: SceneTree, session: GameSession, source_slot: int, target_slot: int, expected_id: String, reason: String) -> void:
	var before := _snapshot(session)
	var moved := session.move_room_plant(source_slot, target_slot, expected_id)
	suite._check(
		not moved and _snapshot(session) == before,
		"Fáze 166 odmítne %s a zachová celý stav beze změny" % reason
	)


static func _test_rejections(suite: SceneTree, catalog: Dictionary) -> void:
	var session := _new_session(catalog)
	var bought_source := session.purchase_or_place_room_decoration("room_orchid", 0)
	var bought_other := session.purchase_or_place_room_decoration("mini_monstera", 1)
	var bought_books := session.purchase_or_place_room_decoration("botanical_books", 12)
	var bought_cloche := session.purchase_or_place_room_decoration("golden_lamp", 15)
	suite._check(
		bought_source and bought_other and bought_books and bought_cloche,
		"Fáze 166 připraví vlastněný zdroj, obsazený cíl a dvě ostatní dekorace pro odmítnuté přesuny"
	)
	for invalid_slot in [-1, -17, 12, 13, 19, 20, 2147483647]:
		_check_rejected(suite, session, int(invalid_slot), 2, "room_orchid", "zdroj mimo stojan %d" % int(invalid_slot))
		_check_rejected(suite, session, 0, int(invalid_slot), "room_orchid", "cíl mimo stojan %d" % int(invalid_slot))
	_check_rejected(suite, session, 0, 0, "room_orchid", "stejný zdroj a cíl")
	_check_rejected(suite, session, 0, 1, "mini_monstera", "zastaralé očekávané ID při obsazeném cíli bez částečného swapu")
	_check_rejected(suite, session, 0, 2, "mini_monstera", "zastaralé očekávané ID jiné vlastněné rostliny")
	_check_rejected(suite, session, 0, 2, "future_room_plant", "neznámé očekávané ID")
	_check_rejected(suite, session, 0, 2, "", "prázdné očekávané ID")
	_check_rejected(suite, session, 2, 3, "room_orchid", "prázdný zdroj")

	# Deliberately inconsistent in-memory fixtures isolate ownership and kind
	# checks from the source-ID and slot-range checks above.
	var unowned := _new_session(catalog)
	unowned.room_decoration_slots[0] = "room_orchid"
	_check_rejected(suite, unowned, 0, 2, "room_orchid", "nevlastněnou rostlinu i při shodě zdrojového ID")
	unowned.owned_room_decorations.append("mini_monstera")
	unowned.room_decoration_slots[1] = "mini_monstera"
	_check_rejected(suite, unowned, 0, 1, "room_orchid", "nevlastněný zdroj proti vlastněnému obsazenému cíli bez částečného swapu")
	var nonplant := _new_session(catalog)
	nonplant.owned_room_decorations.append("botanical_books")
	nonplant.room_decoration_slots[0] = "botanical_books"
	_check_rejected(suite, nonplant, 0, 2, "botanical_books", "vlastněnou nerostlinnou dekoraci podvrženou v rostlinném slotu")
	nonplant.owned_room_decorations.append("mini_monstera")
	nonplant.room_decoration_slots[1] = "mini_monstera"
	_check_rejected(suite, nonplant, 0, 1, "botanical_books", "nerostlinný zdroj proti vlastněnému obsazenému cíli bez částečného swapu")
	for nonrack_slot in range(12, GameSession.ROOM_DECORATION_SLOT_COUNT):
		var misplaced := _new_session(catalog)
		misplaced.owned_room_decorations.append("room_orchid")
		misplaced.room_decoration_slots[nonrack_slot] = "room_orchid"
		_check_rejected(suite, misplaced, nonrack_slot, 2, "room_orchid", "rostlinu podvrženou do dekoračního zdroje %d" % nonrack_slot)

	var bad_target := _new_session(catalog)
	var bought_valid_source := bad_target.purchase_or_place_room_decoration("room_orchid", 0)
	var bought_unchanged := bad_target.purchase_or_place_room_decoration("silver_aglaonema", 4)
	var bought_unchanged_books := bad_target.purchase_or_place_room_decoration("botanical_books", 12)
	suite._check(
		bought_valid_source and bought_unchanged and bought_unchanged_books,
		"Fáze 166 připraví platný vlastněný zdroj a ostatní umístění pro neplatné cíle swapu"
	)
	bad_target.coins = 0
	bad_target.room_decoration_slots[11] = "future_room_plant"
	_check_rejected(suite, bad_target, 0, 11, "room_orchid", "neznámé ID v cílovém místě bez vyprázdnění zdroje")
	bad_target.owned_room_decorations.append("future_room_plant")
	_check_rejected(suite, bad_target, 0, 11, "room_orchid", "neznámé cílové ID i při podvrženém vlastnictví")
	bad_target.owned_room_decorations.erase("future_room_plant")
	bad_target.room_decoration_slots[11] = " "
	_check_rejected(suite, bad_target, 0, 11, "room_orchid", "neplatné cílové ID tvořené mezerou bez částečného swapu")
	bad_target.room_decoration_slots[11] = "mini_monstera"
	_check_rejected(suite, bad_target, 0, 11, "room_orchid", "známou ale nevlastněnou cílovou rostlinu bez částečné mutace")
	bad_target.room_decoration_slots[12] = ""
	bad_target.room_decoration_slots[11] = "botanical_books"
	_check_rejected(suite, bad_target, 0, 11, "room_orchid", "vlastněnou nerostlinnou cílovou dekoraci bez částečné mutace")
	bad_target.room_decoration_slots[11] = "room_orchid"
	_check_rejected(suite, bad_target, 0, 11, "room_orchid", "duplicitní stejné ID ve zdroji i cíli bez změny nekonzistentního stavu")


static func _test_disk_roundtrip(suite: SceneTree, catalog: Dictionary) -> void:
	var preserved_files: Dictionary = {}
	for path in DISK_PATHS:
		if FileAccess.file_exists(path):
			var original_file := FileAccess.open(path, FileAccess.READ)
			if original_file == null:
				suite._check(false, "Fáze 166 nesmí měnit existující testovací soubor, jehož obsah nelze bezpečně zachovat")
				return
			var original_size := original_file.get_length()
			var original_bytes := original_file.get_buffer(original_size)
			original_file.close()
			if original_bytes.size() != original_size:
				suite._check(false, "Fáze 166 nesmí měnit testovací soubory po neúplném přečtení původního obsahu")
				return
			preserved_files[path] = original_bytes
	var manager_state := {
		"last_load_status": SaveManager.last_load_status,
		"last_load_message": SaveManager.last_load_message,
		"writes_blocked": SaveManager.writes_blocked,
		"last_successful_save_unix": SaveManager.last_successful_save_unix,
		"last_save_error_message": SaveManager.last_save_error_message,
		"last_load_offline_seconds_applied": SaveManager.last_load_offline_seconds_applied,
	}
	var prepared := true
	for path in DISK_PATHS:
		if FileAccess.file_exists(path):
			var remove_error := DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
			prepared = remove_error == OK and prepared
	suite._check(prepared, "Fáze 166 připraví pouze pět přesných izolovaných phase166-model souborů")
	if prepared:
		var disk_session := _new_session(catalog)
		var bought_source := disk_session.purchase_or_place_room_decoration("colorful_coleus", 0)
		var bought_other := disk_session.purchase_or_place_room_decoration("silver_aglaonema", 4)
		var bought_books := disk_session.purchase_or_place_room_decoration("botanical_books", 12)
		var bought_cloche := disk_session.purchase_or_place_room_decoration("golden_lamp", 15)
		disk_session.coins = 17
		suite._check(bought_source and bought_other and bought_books and bought_cloche, "Fáze 166 diskový test připraví dvě rostliny, knihy a terárium")
		var before := _snapshot(disk_session)
		suite._check(
			SaveManager._save_session_to_paths(disk_session, PRIMARY_PATH, BACKUP_PATH, TEMP_PATH),
			"Fáze 166 skutečně uloží původní rozmístění do izolovaného primary souboru"
		)
		var moved := disk_session.move_room_plant(0, 11, "colorful_coleus")
		var saved := SaveManager._save_session_to_paths(disk_session, PRIMARY_PATH, BACKUP_PATH, TEMP_PATH)
		suite._check(
			moved and saved and FileAccess.file_exists(BACKUP_PATH),
			"Fáze 166 skutečně uloží přesun do krajního místa 11 a zachová předchozí rozmístění v záloze"
		)
		var expected := _snapshot(disk_session)
		var loaded := SaveManager._load_session_from_paths(catalog, PRIMARY_PATH, BACKUP_PATH, RECOVERY_PATH, disk_session.saved_at_unix)
		suite._check(
			SaveManager.last_load_status == SaveManager.STATUS_PRIMARY
			and not SaveManager.writes_blocked
			and is_zero_approx(SaveManager.last_load_offline_seconds_applied)
			and loaded.get_room_decoration_slots() == expected["room_decoration_slots"]
			and loaded.owned_room_decorations == expected["owned_room_decorations"]
			and loaded.coins == int(expected["coins"])
			and loaded.xp == int(expected["xp"])
			and loaded.room_decoration_slots[0].is_empty()
			and loaded.room_decoration_slots[11] == "colorful_coleus"
			and loaded.room_decoration_slots.count("colorful_coleus") == 1,
			"Fáze 166 reálný diskový save/load zachová přesně přesunutou rostlinu, ostatní místa, vlastnictví, mince a XP bez offline posunu"
		)
		var backup_data := SaveManager._read_supported_data(BACKUP_PATH)
		suite._check(
			backup_data.get("room_decoration_slots", []) == before["room_decoration_slots"]
			and backup_data.get("owned_room_decorations", []) == before["owned_room_decorations"]
			and int(backup_data.get("coins", -1)) == int(before["coins"])
			and int(backup_data.get("xp", -1)) == int(before["xp"]),
			"Fáze 166 atomický zápis zachová v backup přesný stav před přesunem bez ztráty vlastnictví nebo měny"
		)
		# Reuse only the same isolated test paths for a real occupied-target
		# roundtrip, with both extreme slots occupied before the second save.
		var swap_ready := loaded.move_room_plant(4, 0, "silver_aglaonema")
		loaded.coins = 0
		var swap_before := _snapshot(loaded)
		var saved_swap_before := SaveManager._save_session_to_paths(loaded, PRIMARY_PATH, BACKUP_PATH, TEMP_PATH)
		suite._check(
			swap_ready and saved_swap_before,
			"Fáze 166 skutečně uloží výchozí obsazená krajní místa 0 a 11 pro diskový swap bez mincí"
		)
		var swap_expected := swap_before.duplicate(true)
		var swap_expected_slots: Array = swap_expected["room_decoration_slots"]
		swap_expected_slots[0] = "colorful_coleus"
		swap_expected_slots[11] = "silver_aglaonema"
		var swapped := loaded.move_room_plant(0, 11, "silver_aglaonema")
		var saved_swap := SaveManager._save_session_to_paths(loaded, PRIMARY_PATH, BACKUP_PATH, TEMP_PATH)
		suite._check(
			swapped and saved_swap and FileAccess.file_exists(BACKUP_PATH),
			"Fáze 166 atomicky zapíše krajní swap a zachová předchozí rozmístění v diskové záloze"
		)
		var swap_loaded := SaveManager._load_session_from_paths(catalog, PRIMARY_PATH, BACKUP_PATH, RECOVERY_PATH, loaded.saved_at_unix)
		suite._check(
			SaveManager.last_load_status == SaveManager.STATUS_PRIMARY
			and not SaveManager.writes_blocked
			and is_zero_approx(SaveManager.last_load_offline_seconds_applied)
			and swap_loaded.get_room_decoration_slots() == swap_expected["room_decoration_slots"]
			and swap_loaded.owned_room_decorations == swap_expected["owned_room_decorations"]
			and swap_loaded.coins == int(swap_expected["coins"])
			and swap_loaded.xp == int(swap_expected["xp"])
			and swap_loaded.room_decoration_slots.count("colorful_coleus") == 1
			and swap_loaded.room_decoration_slots.count("silver_aglaonema") == 1,
			"Fáze 166 skutečný diskový save/load zachová obě prohozené rostliny přesně jednou, ostatní místa, vlastnictví, mince a XP"
		)
		var swap_backup := SaveManager._read_supported_data(BACKUP_PATH)
		suite._check(
			swap_backup.get("room_decoration_slots", []) == swap_before["room_decoration_slots"]
			and swap_backup.get("owned_room_decorations", []) == swap_before["owned_room_decorations"]
			and int(swap_backup.get("coins", -1)) == int(swap_before["coins"])
			and int(swap_backup.get("xp", -1)) == int(swap_before["xp"]),
			"Fáze 166 disková záloha swapu obsahuje přesné původní rozmístění obou rostlin i původní vlastnictví, mince a XP"
		)
		suite._check(
			not FileAccess.file_exists(TEMP_PATH)
			and not FileAccess.file_exists(ROTATION_PATH)
			and not FileAccess.file_exists(RECOVERY_PATH),
			"Fáze 166 platný diskový roundtrip nezanechá temp, rotation ani recovery soubor"
		)

	# Restore even pre-existing malformed/binary test files byte-for-byte.
	# Never enumerate or remove the user directory or production save paths.
	var restored_files := true
	for path in DISK_PATHS:
		if preserved_files.has(path):
			var original_bytes: PackedByteArray = preserved_files[path]
			var already_restored := FileAccess.file_exists(path) and FileAccess.get_file_as_bytes(path) == original_bytes
			if not already_restored:
				var file := FileAccess.open(path, FileAccess.WRITE)
				if file != null:
					file.store_buffer(original_bytes)
					file.close()
			restored_files = FileAccess.file_exists(path) and FileAccess.get_file_as_bytes(path) == original_bytes and restored_files
		elif FileAccess.file_exists(path):
			var remove_error := DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
			restored_files = remove_error == OK and restored_files
	SaveManager.last_load_status = str(manager_state["last_load_status"])
	SaveManager.last_load_message = str(manager_state["last_load_message"])
	SaveManager.writes_blocked = bool(manager_state["writes_blocked"])
	SaveManager.last_successful_save_unix = float(manager_state["last_successful_save_unix"])
	SaveManager.last_save_error_message = str(manager_state["last_save_error_message"])
	SaveManager.last_load_offline_seconds_applied = float(manager_state["last_load_offline_seconds_applied"])
	suite._check(restored_files, "Fáze 166 uklidí pouze své přesné soubory a původní obsah případných testovacích souborů obnoví bajtově")
