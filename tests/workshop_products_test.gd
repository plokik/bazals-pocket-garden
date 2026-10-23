extends RefCounted
const Goods := preload("res://scripts/workshop_products.gd")

static func _session(catalog: Dictionary) -> GameSession:
	var session := GameSession.new(catalog)
	session.xp = 400
	session.coins = 100
	return session

static func _batch(session: GameSession, species: String, grams: float, stage := PlantSimulation.Stage.DRY) -> PlantSimulation:
	var batch := PlantSimulation.new(session.get_plant_profile(species))
	batch.stage = stage
	batch.dry_harvest_g = grams
	batch.fresh_harvest_g = grams*5
	batch.harvest_quality = 0.88
	session.plants.append(batch)
	return batch

static func _ingredients(session: GameSession) -> void:
	for herb in Goods.SPECIES: _batch(session,Goods.SPECIES[herb],8)

static func _snapshot(session: GameSession) -> Dictionary:
	var data := session.to_dict().duplicate(true)
	data.erase("saved_at_unix")
	return data

static func run(host: SceneTree) -> void:
	var catalog: Dictionary = host._load_plant_catalog()
	var was_blocked := SaveManager.writes_blocked
	SaveManager.writes_blocked = false
	var seed_session := _session(catalog)
	var legacy := _snapshot(seed_session)
	legacy.schema = 43
	legacy.workshop_products = {"products":{"tea":500},"teahouse":"completed"}
	var migrated := GameSession.new(catalog)
	migrated.from_dict(legacy)
	host._check(migrated.workshop_products.total_count() == 0 and migrated.workshop_products.quest == "available","Výrobky: schema 43 nepřijímá podstrčené budoucí zásoby ani hotovou zakázku")
	host._check(migrated.coins == seed_session.coins and migrated.xp == seed_session.xp and migrated.get_seed_inventory_snapshot() == seed_session.get_seed_inventory_snapshot(),"Výrobky: migrace zachová mince, XP a semínka")
	for invalid_schema in [true,44.5,GameSession.SAVE_SCHEMA+1]:
		legacy.schema = invalid_schema
		migrated.from_dict(legacy)
		host._check(migrated.workshop_products.total_count() == 0,"Výrobky: neplatné schema neautorizuje nové klíče")
	var malformed := Goods.new()
	for raw in [null,true,[],"broken"]:
		malformed.from_dict(raw)
		host._check(malformed.total_count() == 0,"Výrobky: chybný typ zásoby zůstane prázdný")
	for raw in [true,-1,2.5,NAN,INF,"8"]:
		malformed.from_dict({"products":{"tea":raw,"gift":2},"teahouse":true})
		host._check(malformed.count("tea") == 0 and malformed.count("gift") == 2 and malformed.quest == "completed","Výrobky: chybný počet se odmítne a neplatný stav neotevře odměnu")
	malformed.from_dict({"products":{"tea":100000,"unknown":50},"teahouse":"active"})
	host._check(malformed.count("tea") == 9999 and malformed.to_dict().products.size() == 3 and malformed.count("unknown") == 0,"Výrobky: omezení počtu a whitelist druhů")
	var direct_economy := {"lavender":19.6,"tea":15.2,"gift":26.4}
	for id in Goods.ORDER:
		var session := _session(catalog)
		var goods = session.workshop_products
		_ingredients(session)
		var before := _snapshot(session)
		session.xp = 0
		var locked := _snapshot(session)
		host._check(not goods.craft(session,id).ok and locked == _snapshot(session),"Výrobky: recept před odemčením bylin nic nespotřebuje: "+id)
		session.xp = 400
		host._check(goods.craft(session,id).ok,"Výrobky: skutečná výroba "+id)
		host._check(session.coins == before.coins-Goods.PRODUCTS[id].cost and goods.count(id) == 1,"Výrobky: přesná cena a jeden kus "+id)
		for herb in Goods.HERBS:
			host._check(is_equal_approx(goods.available_grams(session,herb),8-Goods.PRODUCTS[id].ingredients.get(herb,0)),"Výrobky: správný druh a množství "+id+" "+herb)
		host._check(session.xp == 400 and session.harvest_count == before.harvest_count and session.fertilizer_doses == before.fertilizer_doses,"Výrobky: výroba nepřidává XP, sklizně ani hnojivo")
		before = _snapshot(session)
		host._check(not goods.craft(session,id,func(): return false).ok and before == _snapshot(session),"Výrobky: selhání zápisu přesně vrátí šarže a mince "+id)
		host._check(not goods.sell(session,id,func(): return false).ok and before == _snapshot(session),"Výrobky: selhání prodeje vrátí kus i mince "+id)
		var reentered := []
		host._check(goods.sell(session,id,func(): reentered.append(goods.sell(session,id).ok); return true).ok and reentered == [false],"Výrobky: reentrantní callback nemůže prodat kus podruhé "+id)
		host._check(session.coins == before.coins+Goods.PRODUCTS[id].sale and goods.count(id) == 0,"Výrobky: pevná schválená cena bez dvojího bonusu "+id)
		before = _snapshot(session)
		host._check(not goods.sell(session,id).ok and before == _snapshot(session),"Výrobky: prázdnou zásobu nelze prodat "+id)
		host._check(Goods.PRODUCTS[id].sale > direct_economy[id],"Výrobky: cena pokrývá základní hodnotu bylin a přípravy "+id)
		session = _session(catalog)
		goods = session.workshop_products
		for herb in Goods.HERBS:
			for stage in [PlantSimulation.Stage.HARVESTED,PlantSimulation.Stage.DRYING,PlantSimulation.Stage.PACKAGED]: _batch(session,Goods.SPECIES[herb],10,stage)
		before = _snapshot(session)
		host._check(not goods.craft(session,id).ok and before == _snapshot(session),"Výrobky: odmítne čerstvou, sušící se a zabalenou sklizeň "+id)
		_ingredients(session)
		session.coins = Goods.PRODUCTS[id].cost-1
		before = _snapshot(session)
		host._check(not goods.craft(session,id).ok and before == _snapshot(session),"Výrobky: nedostatek mincí je atomický "+id)
		session.coins = 100
		goods.products[id] = 9999
		before = _snapshot(session)
		host._check(not goods.craft(session,id).ok and before == _snapshot(session),"Výrobky: plná zásoba nepohltí suroviny "+id)
	var partial := _session(catalog)
	_ingredients(partial)
	var nested := []
	host._check(partial.workshop_products.craft(partial,"tea",func(): nested.append(partial.workshop_products.craft(partial,"tea").ok); return true).ok and nested == [false] and partial.workshop_products.count("tea") == 1,"Výrobky: vnořený callback výroby nepřidá druhý kus")
	partial = _session(catalog)
	var first := _batch(partial,Goods.SPECIES.lavender,0.4)
	var second := _batch(partial,Goods.SPECIES.lavender,2.6)
	var before := _snapshot(partial)
	host._check(not partial.workshop_products.craft(partial,"lavender",func(): return false).ok and before == _snapshot(partial),"Výrobky: rollback po úplném vyčerpání první šarže vrátí i runtime hodnoty")
	host._check(partial.workshop_products.craft(partial,"lavender").ok and first.stage == PlantSimulation.Stage.EMPTY and is_equal_approx(second.dry_harvest_g,1.0) and is_equal_approx(second.fresh_harvest_g,5.0) and second.harvest_quality == 0.88,"Výrobky: přesná částečná spotřeba napříč šaržemi zachová kvalitu")
	var session := _session(catalog)
	var goods = session.workshop_products
	_ingredients(session)
	before = _snapshot(session)
	host._check(not goods.deliver(session).ok and before == _snapshot(session),"Čajovna: nepřijatá dodávka nedává odměnu")
	host._check(not goods.accept(session,func(): return false).ok and before == _snapshot(session),"Čajovna: selhání uložení přijetí zachová nabídku")
	host._check(goods.accept(session).ok and not goods.accept(session).ok,"Čajovna: zakázku lze přijmout právě jednou")
	before = _snapshot(session)
	host._check(not goods.deliver(session).ok and before == _snapshot(session),"Čajovna: neúplná dodávka nic neodečte")
	for id in Goods.ORDER: goods.craft(session,id)
	goods.craft(session,"tea")
	before = _snapshot(session)
	host._check(not goods.deliver(session,func(): return false).ok and before == _snapshot(session),"Čajovna: chyba zápisu vrátí výrobky, stav, mince a celou zásobu semen")
	var seeds_before := session.get_seed_count(Goods.REWARD_SPECIES)
	nested.clear()
	host._check(goods.deliver(session,func(): nested.append(goods.deliver(session).ok); return true).ok and session.coins == before.coins+80 and session.get_seed_count(Goods.REWARD_SPECIES) == seeds_before+2 and nested == [false],"Čajovna: přesně 80 mincí a dvě semínka bez reentrantní odměny")
	host._check(goods.count("tea") == 1 and goods.count("lavender") == 0 and goods.count("gift") == 0 and goods.quest == "completed","Čajovna: odečte právě jeden kus a přebytky ponechá")
	before = _snapshot(session)
	host._check(not goods.deliver(session).ok and not goods.accept(session).ok and before == _snapshot(session),"Čajovna: opakované kliknutí nezopakuje odměnu")
	var paths := ["user://teahouse-products.json","user://teahouse-products.backup.json","user://teahouse-products.tmp.json"]
	host._check(SaveManager._save_session_to_paths(session,paths[0],paths[1],paths[2]),"Výrobky: skutečný atomický zápis na disk")
	var restored := GameSession.new(catalog)
	restored.from_dict(SaveManager._read_supported_data(paths[0]))
	host._check(restored.workshop_products.to_dict() == goods.to_dict() and restored.coins == session.coins and restored.get_seed_count(Goods.REWARD_SPECIES) == session.get_seed_count(Goods.REWARD_SPECIES),"Čajovna: po diskovém načtení zůstane výsledek i odměna")
	host._check(not restored.workshop_products.deliver(restored).ok,"Čajovna: restart neotevře vybranou odměnu znovu")
	var active := _session(catalog)
	_ingredients(active)
	active.workshop_products.accept(active)
	active.workshop_products.craft(active,"tea")
	var active_copy := GameSession.new(catalog)
	active_copy.from_dict(active.to_dict())
	host._check(active_copy.workshop_products.quest == "active" and active_copy.workshop_products.count("tea") == 1,"Čajovna: uložená rozpracovaná zakázka a výrobek se obnoví")
	for id in Goods.ORDER: active.workshop_products.products[id] = 1
	active.set_seed_count(Goods.REWARD_SPECIES,9998)
	before = _snapshot(active)
	host._check(not active.workshop_products.deliver(active).ok and before == _snapshot(active),"Čajovna: plná zásoba semen neztratí žádnou část odměny")
	active.set_seed_count(Goods.REWARD_SPECIES,9997)
	host._check(active.workshop_products.deliver(active).ok and active.get_seed_count(Goods.REWARD_SPECIES) == 9999,"Čajovna: dvě uvolněná místa umožní celé předání")
	SaveManager.writes_blocked = true
	before = _snapshot(session)
	host._check(not goods.craft(session,"tea").ok and not goods.sell(session,"tea").ok and before == _snapshot(session),"Výrobky: chráněný save nepovolí spotřebu ani prodej")
	var blocked_order := _session(catalog)
	for id in Goods.ORDER: blocked_order.workshop_products.products[id] = 1
	before = _snapshot(blocked_order)
	host._check(not blocked_order.workshop_products.accept(blocked_order).ok and before == _snapshot(blocked_order),"Čajovna: chráněný save nepřijme zakázku")
	blocked_order.workshop_products.quest = "active"
	before = _snapshot(blocked_order)
	host._check(not blocked_order.workshop_products.deliver(blocked_order).ok and before == _snapshot(blocked_order),"Čajovna: chráněný save nepředá výrobky")
	SaveManager.writes_blocked = false
	await _ui(host)
	SaveManager.writes_blocked = was_blocked

static func _ui(host: SceneTree) -> void:
	var game = load("res://main.tscn").instantiate()
	host.root.add_child(game)
	await host.process_frame
	await host.process_frame
	host._finish_phase92_startup_for_test(game)
	game.set_process(false)
	game.session.paused = true
	game.session.xp = 400
	game.session.coins = 100
	_ingredients(game.session)
	game._open_player_room()
	var modal = game.workshop_modal
	modal.persist_override = func(): return true
	modal.open()
	var before := _snapshot(game.session)
	modal.products_button.pressed.emit()
	var panel = modal.products_panel
	host._check(panel.visible and not modal.care_content.visible and before == _snapshot(game.session) and game._is_blocking_modal_open(),"Výrobky UI: přechod z receptů pouze otevře výrobky a blokuje pozadí")
	panel.selected = "tea"
	panel.show_products()
	panel.craft_selected()
	var crafted := _snapshot(game.session)
	panel.craft_selected()
	host._check(panel.busy and modal.busy and crafted == _snapshot(game.session) and game.session.workshop_products.count("tea") == 1,"Výrobky UI: dvojklik během animace vyrobí jeden kus")
	modal.close()
	host._check(not panel.busy and not modal.busy and not panel.visible and game.session.workshop_products.count("tea") == 1,"Výrobky UI: zavření ukončí animaci a zachová uložený výrobek")
	modal.open_products("tea")
	game.session.reduced_motion = true
	panel.reduced_motion = true
	panel.craft_selected()
	await host.create_timer(0.25).timeout
	host._check(not panel.busy and panel.effect.active and panel.effect.calm and game.session.workshop_products.count("tea") == 2,"Výrobky UI: omezené animace ukáží klidné schválené dokončení")
	modal.persist_override = func(): return false
	before = _snapshot(game.session)
	panel.craft_selected()
	host._check(not panel.busy and before == _snapshot(game.session) and panel.status.text.contains("nepodařilo uložit"),"Výrobky UI: selhání save zachová byliny a nezahájí animaci")
	modal.persist_override = func(): return true
	panel.care_button.pressed.emit()
	host._check(not panel.visible and modal.care_content.visible and modal.recipe_buttons.size() == 4,"Výrobky UI: tlačítko Péče zachová všechny čtyři původní recepty")
	modal.close()
	game._change_screen(1)
	game._update_storage_panel()
	host._check(game.workshop_stock_panel.visible and game.workshop_stock_panel.quantities.tea.text == "2 ks","Výrobky UI: sklad ukáže skutečnou zásobu")
	game.workshop_stock_panel.workshop_requested.emit()
	host._check(game.workshop_open and panel.visible and game.garden_location_id == "player_room","Výrobky UI: sklad otevře přímo výrobky v dílně")
	host._check(game._consume_mobile_back_navigation() and not game.workshop_open and not panel.visible,"Výrobky UI: systémové Zpět zavře celý dialog")
	modal.open_for_herb("lavandula_angustifolia")
	host._check(panel.visible and panel.selected == "lavender","Výrobky UI: levandule ve skladu vede na správný výrobek")
	game.session = GameSession.new(host._load_plant_catalog())
	modal.refresh()
	host._check(not game.workshop_open and not panel.visible,"Výrobky UI: výměna profilu zavře starý výsledek")
	game.queue_free()
	await host.process_frame
