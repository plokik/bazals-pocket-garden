extends RefCounted

const Decorations := preload("res://scripts/greenhouse_decorations.gd")


static func _session(catalog: Dictionary) -> GameSession:
	var session := GameSession.new(catalog)
	session.coins = 160
	session.xp = 400
	session.workshop_products.products.tea = 2
	session.workshop_products.quest = "active"
	session.owned_room_decorations.append("room_orchid")
	session.greenhouse.plant(0, "cherry_tomato")
	return session


static func _snapshot(session: GameSession) -> Dictionary:
	var data := session.to_dict().duplicate(true)
	# Wall-clock timestamps are checked explicitly around failed persistence.
	data.erase("saved_at_unix")
	return data


static func run(host: SceneTree) -> void:
	var catalog: Dictionary = host._load_plant_catalog()
	var before_checks: int = host.checks
	var was_blocked := SaveManager.writes_blocked
	SaveManager.writes_blocked = false
	host._check(Decorations.PRICE == 60 and Decorations.DECORATION_ID == "tea_tree", "Venkovní dekorace: pevná cena a ID čajovníku")
	host._check(GameSession.SAVE_SCHEMA == 46 and GameSession.GREENHOUSE_DECORATIONS_SCHEMA == Decorations.OWNERSHIP_SCHEMA and GameSession.GUIDED_TUTORIAL_SCHEMA == 45, "Venkovní dekorace: vlastní nová schema hranice nemění starší důvěryhodná data")
	var session := _session(catalog)
	host._check(not Decorations.is_owned(session) and session.owned_greenhouse_decorations.is_empty(), "Venkovní dekorace: nová hra nemá zakoupený čajovník")
	host._check(not Decorations.is_owned(null) and Decorations.purchase(null, Decorations.DECORATION_ID, func(): return true).reason == "invalid_session", "Venkovní dekorace: chybějící profil neprovede nákup")
	var calls := [0]
	var persist := func() -> bool:
		calls[0] += 1
		return true
	var before := _snapshot(session)
	for id: String in ["", "unknown", "Tea_tree", "tea_tree ", "room_orchid", "../tea_tree"]:
		var unknown := Decorations.purchase(session, id, persist)
		host._check(not unknown.ok and unknown.reason == "unknown_decoration" and calls[0] == 0 and before == _snapshot(session), "Venkovní dekorace: neznámé ID nic neodečte ani neukládá: " + id)
	host._check(Decorations.purchase(session, Decorations.DECORATION_ID, Callable()).reason == "persist_required" and before == _snapshot(session), "Venkovní dekorace: placený nákup vyžaduje platný synchronní zápis")
	SaveManager.writes_blocked = true
	var blocked := Decorations.purchase(session, Decorations.DECORATION_ID, persist)
	host._check(not blocked.ok and blocked.reason == "save_unavailable" and calls[0] == 0 and before == _snapshot(session), "Venkovní dekorace: ochrana save blokuje nákup před odečtením")
	SaveManager.writes_blocked = false
	for balance: int in [0, Decorations.PRICE - 1]:
		session.coins = balance
		before = _snapshot(session)
		var poor := Decorations.purchase(session, Decorations.DECORATION_ID, persist)
		host._check(not poor.ok and poor.reason == "insufficient_coins" and calls[0] == 0 and before == _snapshot(session), "Venkovní dekorace: nedostatek mincí zachová celý profil: %d" % balance)

	# An actual serializer call in the failing callback exercises timestamp
	# mutation too; failed purchase must emit no irreversible spend feedback.
	session = _session(catalog)
	before = _snapshot(session)
	session.saved_at_unix = 123.0
	var events: Array[Dictionary] = []
	var collect_feedback := func(kind: String, index: int, payload: Dictionary) -> void:
		events.append({"kind": kind, "index": index, "payload": payload.duplicate(true)})
	session.feedback_requested.connect(collect_feedback)
	var failing_save_observations: Array[Dictionary] = []
	var failed := Decorations.purchase(session, Decorations.DECORATION_ID, func() -> bool:
		failing_save_observations.append(session.to_dict().duplicate(true))
		return false)
	host._check(not failed.ok and failed.reason == "save_failed" and failing_save_observations.size() == 1, "Venkovní dekorace: skutečný neúspěšný callback vrátí chybu nákupu")
	host._check(failing_save_observations[0].coins == before.coins - Decorations.PRICE and failing_save_observations[0].owned_greenhouse_decorations == [Decorations.DECORATION_ID], "Venkovní dekorace: persist dostane společně zaplacené mince i nové vlastnictví")
	host._check(session.saved_at_unix == 123.0 and session.coins == before.coins and session.owned_greenhouse_decorations.is_empty(), "Venkovní dekorace: selhání vrátí mince, vlastnictví i čas posledního zápisu")
	host._check(before == _snapshot(session) and events.is_empty(), "Venkovní dekorace: rollback nezasáhne XP, rostliny, suroviny, staré dekorace ani feedback")
	var commit_order: Array[String] = []
	var nested: Array[Dictionary] = []
	var committed_payload: Dictionary = {}
	var success := Decorations.purchase(session, Decorations.DECORATION_ID, func() -> bool:
		commit_order.append("persist")
		committed_payload.assign(session.to_dict().duplicate(true))
		nested.append(Decorations.purchase(session, Decorations.DECORATION_ID, persist))
		host._check(events.is_empty(), "Venkovní dekorace: oslavný feedback nezačne před úspěšným uložením")
		return true)
	host._check(success.ok and str(success.reason).is_empty() and commit_order == ["persist"], "Venkovní dekorace: opakování po neúspěšném zápisu uspěje")
	host._check(nested.size() == 1 and not nested[0].ok and nested[0].reason == "busy" and calls[0] == 0, "Venkovní dekorace: vnořený callback nezaplatí nebo neuloží dekoraci podruhé")
	var expected := before.duplicate(true)
	expected.coins = before.coins - Decorations.PRICE
	expected.owned_greenhouse_decorations = [Decorations.DECORATION_ID]
	host._check(_snapshot(session) == expected, "Venkovní dekorace: úspěšný nákup mění jen peněženku a kosmetické vlastnictví")
	host._check(events.size() == 1 and events[0].kind == "spend" and events[0].payload.amount == -Decorations.PRICE and events[0].payload.source == "greenhouse_decoration" and events[0].payload.decoration_id == Decorations.DECORATION_ID, "Venkovní dekorace: po zápisu vznikne právě jeden správný spend feedback")
	before = _snapshot(session)
	var duplicate := Decorations.purchase(session, Decorations.DECORATION_ID, persist)
	host._check(not duplicate.ok and duplicate.reason == "already_owned" and before == _snapshot(session) and calls[0] == 0 and events.size() == 1, "Venkovní dekorace: dvojklik ani pozdější nákup neodečte další mince")
	session.feedback_requested.disconnect(collect_feedback)

	# The same guard also covers synchronous listeners of the post-commit signal.
	var exact := _session(catalog)
	exact.coins = Decorations.PRICE
	var feedback_nested: Array[Dictionary] = []
	var on_spend := func(_kind: String, _index: int, _payload: Dictionary) -> void:
		feedback_nested.append(Decorations.purchase(exact, Decorations.DECORATION_ID, persist))
	exact.feedback_requested.connect(on_spend)
	host._check(Decorations.purchase(exact, Decorations.DECORATION_ID, persist).ok and exact.coins == 0 and Decorations.is_owned(exact), "Venkovní dekorace: přesně 60 mincí stačí bez dluhu")
	host._check(feedback_nested.size() == 1 and feedback_nested[0].reason == "busy" and calls[0] == 1, "Venkovní dekorace: signal listener nespustí další transakci")
	exact.feedback_requested.disconnect(on_spend)
	for result: Variant in [null, 1, "true", {"ok": false}]:
		var invalid_result := _session(catalog)
		before = _snapshot(invalid_result)
		var not_saved := Decorations.purchase(invalid_result, Decorations.DECORATION_ID, func(): return result)
		host._check(not not_saved.ok and not_saved.reason == "save_failed" and before == _snapshot(invalid_result), "Venkovní dekorace: neplatný návrat callbacku není potvrzení uložení")

	# JSON round-trip follows the real persisted data representation, without
	# touching a player's save files or reconstructing a profile for rollback.
	var round_trip: Variant = JSON.parse_string(JSON.stringify(committed_payload))
	host._check(round_trip is Dictionary and int(round_trip.get("schema", 0)) == 46, "Venkovní dekorace: serializovaný save má aktuální schema46")
	var restored := GameSession.new(catalog)
	if round_trip is Dictionary:
		restored.from_dict(round_trip)
	host._check(Decorations.is_owned(restored) and restored.owned_greenhouse_decorations == [Decorations.DECORATION_ID] and restored.coins == session.coins, "Venkovní dekorace: save/load zachová zaplacení a jedno vlastnictví")
	host._check(restored.owned_room_decorations == session.owned_room_decorations and restored.workshop_products.to_dict() == session.workshop_products.to_dict() and restored.greenhouse.to_dict() == session.greenhouse.to_dict() and restored.get_seed_inventory_snapshot() == session.get_seed_inventory_snapshot() and restored.xp == session.xp, "Venkovní dekorace: round-trip zachová staré dekorace, výrobky, záhony, semena a XP")
	before = _snapshot(restored)
	host._check(Decorations.purchase(restored, Decorations.DECORATION_ID, persist).reason == "already_owned" and before == _snapshot(restored), "Venkovní dekorace: restart hry nepovolí znovu placený unlock")
	var detached := restored.to_dict()
	detached.owned_greenhouse_decorations.clear()
	host._check(Decorations.is_owned(restored), "Venkovní dekorace: výstup save nedává volný přístup k živému vlastnictví")

	var trusted := _snapshot(session)
	trusted.owned_greenhouse_decorations = [Decorations.DECORATION_ID, "unknown", Decorations.DECORATION_ID, null, true, 1, {"id": Decorations.DECORATION_ID}, [Decorations.DECORATION_ID]]
	var trusted_before := trusted.duplicate(true)
	restored.from_dict(trusted)
	host._check(restored.owned_greenhouse_decorations == [Decorations.DECORATION_ID] and trusted == trusted_before, "Venkovní dekorace: whitelist odstraní duplikáty a cizí typy bez změny vstupních dat")
	for raw: Variant in [null, true, 1, 60.0, "tea_tree", {"tea_tree": true}, PackedStringArray([Decorations.DECORATION_ID])]:
		var hostile := trusted.duplicate(true)
		hostile.owned_greenhouse_decorations = raw
		restored.from_dict(hostile)
		host._check(restored.owned_greenhouse_decorations.is_empty(), "Venkovní dekorace: neplatný typ vlastnictví nezíská kosmetiku")
	for entries: Array in [[], ["unknown"], ["Tea_tree", "tea_tree ", "../tea_tree"], [{"id": Decorations.DECORATION_ID, "price": 0}], [[Decorations.DECORATION_ID]], [StringName(Decorations.DECORATION_ID)]]:
		host._check(Decorations.sanitize_owned(entries, 46).is_empty(), "Venkovní dekorace: pouze přesný známý String autorizuje vlastnictví")
	var sanitized := Decorations.sanitize_owned([Decorations.DECORATION_ID, Decorations.DECORATION_ID], 46)
	host._check(sanitized == [Decorations.DECORATION_ID] and sanitized.is_typed(), "Venkovní dekorace: sanitizace vytvoří nové unikátní Array[String]")
	for schema: int in range(1, 46):
		host._check(Decorations.sanitize_owned([Decorations.DECORATION_ID], schema).is_empty(), "Venkovní dekorace: schema%d nepřijme budoucí kosmetické vlastnictví" % schema)
	var legacy := trusted.duplicate(true)
	legacy.schema = 45
	restored.from_dict(legacy)
	host._check(restored.owned_greenhouse_decorations.is_empty() and restored.coins == session.coins and restored.owned_room_decorations == session.owned_room_decorations and restored.workshop_products.to_dict() == session.workshop_products.to_dict() and restored.greenhouse.to_dict() == session.greenhouse.to_dict() and restored.guided_tutorial_enabled == session.guided_tutorial_enabled, "Venkovní dekorace: schema45 ignoruje injekci a zachová původní hru i tutorial")
	for invalid_schema: Variant in [true, "46", 46.5, NAN, INF, -1, 0, GameSession.SAVE_SCHEMA + 1]:
		var invalid_data := trusted.duplicate(true)
		invalid_data.schema = invalid_schema
		restored.from_dict(invalid_data)
		host._check(not Decorations.is_owned(restored), "Venkovní dekorace: neplatná schema neotevře novou trust hranici")
	var no_key := trusted.duplicate(true)
	no_key.erase("owned_greenhouse_decorations")
	restored.from_dict(trusted)
	restored.from_dict(no_key)
	host._check(not Decorations.is_owned(restored), "Venkovní dekorace: opakované načtení bez klíče nepřenese vlastnictví z jiného profilu")
	host._check(not GameSession.ROOM_DECORATIONS.has(Decorations.DECORATION_ID) and Decorations.DECORATION_ID not in restored.owned_room_decorations, "Venkovní dekorace: čajovník nezmění pokojové sloty a jejich historické schema hranice")
	SaveManager.writes_blocked = was_blocked
	print("GREENHOUSE_DECORATIONS_CHECKS=%d" % (host.checks - before_checks))
