extends RefCounted
const Recipes := preload("res://scripts/workshop_recipes.gd")


static func _snapshot(session: GameSession) -> Dictionary:
	var data := session.to_dict().duplicate(true)
	data.erase("saved_at_unix")
	return data


static func _batch(session: GameSession, grams: float, stage := PlantSimulation.Stage.DRY, species_id := "basil_genovese") -> PlantSimulation:
	var batch := PlantSimulation.new(session.get_plant_profile(species_id))
	batch.stage = stage
	batch.dry_harvest_g = grams
	batch.fresh_harvest_g = grams * 5
	batch.harvest_quality = 0.9
	session.plants.append(batch)
	return batch


static func run(host: SceneTree) -> void:
	var catalog: Dictionary = host._load_plant_catalog()
	var session := GameSession.new(catalog)
	var unchanged := _snapshot(session)
	for id in ["unknown","fertilizer","tonic"]:
		host._check(not Recipes.craft(session,id).ok and unchanged == _snapshot(session),"Dílna: neplatný recept nebo chybějící byliny nic neodečtou: "+id)
	var packed := _batch(session,20,PlantSimulation.Stage.PACKAGED)
	var drying := _batch(session,20,PlantSimulation.Stage.DRYING)
	var fresh := _batch(session,20,PlantSimulation.Stage.HARVESTED)
	unchanged = _snapshot(session)
	host._check(Recipes.usable_herbs(session) == 0 and not Recipes.craft(session,"fertilizer").ok and unchanged == _snapshot(session),"Dílna: nepoužije čerstvou, sušící se ani zabalenou sklizeň")
	var batch := _batch(session,12)
	var before_coins := session.coins
	var before_doses := session.fertilizer_doses
	var before_xp := session.xp
	var before_harvests := session.harvest_count
	host._check(Recipes.craft(session,"fertilizer").ok,"Dílna: připraví hnojivo z použitelné suché sklizně")
	host._check(batch.dry_harvest_g == 11 and batch.fresh_harvest_g == 55 and batch.harvest_quality == 0.9,"Dílna: odečte přesně 1 g a udrží čerstvou hmotnost i kvalitu dávky")
	host._check(session.coins == before_coins-2 and session.fertilizer_doses == before_doses+1,"Dílna: hnojivo stojí přesně dvě mince a přidá jedinou běžnou dávku")
	host._check(packed.dry_harvest_g == 20 and drying.dry_harvest_g == 20 and fresh.dry_harvest_g == 20,"Dílna: ostatní fáze sklizně zůstávají beze změny")
	host._check(session.xp == before_xp and session.harvest_count == before_harvests,"Dílna: výroba nefarmí XP, sklizně ani odměny")
	session.coins = 0
	unchanged = _snapshot(session)
	host._check(not Recipes.craft(session,"fertilizer").ok and unchanged == _snapshot(session),"Dílna: nedostatek mincí zachová hmotnost i všechny zásoby")
	session.coins = 30
	var target: PlantSimulation = session.plants[0]
	target.plant_seed()
	target.health = 62
	batch.dry_harvest_g = 1
	batch.fresh_harvest_g = 5
	_batch(session,4)
	for index in [-1,GameSession.MAX_PLANT_SLOTS,999]:
		unchanged = _snapshot(session)
		host._check(not Recipes.craft(session,"tonic",index).ok and unchanged == _snapshot(session),"Dílna: nepoužije tonikum na neplatný nebo skladový cíl %d" % index)
	var grams_before := Recipes.usable_herbs(session)
	before_coins = session.coins
	host._check(Recipes.craft(session,"tonic",0).ok and target.health == 74,"Dílna: tonikum použije přímo na zvolenou živou oslabenou rostlinu")
	host._check(Recipes.usable_herbs(session) == grams_before-2 and session.coins == before_coins-3,"Dílna: tonikum spotřebuje přesně 2 g napříč dávkami a tři mince")
	host._check(batch.stage == PlantSimulation.Stage.EMPTY,"Dílna: zcela spotřebovaná skladová dávka nezůstane jako prodejná prázdná sklizeň")
	_batch(session,30)
	for stage in [PlantSimulation.Stage.EMPTY,PlantSimulation.Stage.DEAD,PlantSimulation.Stage.DRY]:
		target.stage = stage
		unchanged = _snapshot(session)
		host._check(not Recipes.craft(session,"tonic",0).ok and unchanged == _snapshot(session),"Dílna: tonikum neoživuje mrtvou rostlinu ani neošetřuje prázdný květináč nebo sklizeň")
	target.stage = PlantSimulation.Stage.VEGETATIVE
	target.health = 100
	unchanged = _snapshot(session)
	host._check(not Recipes.craft(session,"tonic",0).ok and unchanged == _snapshot(session),"Dílna: zdravá rostlina neplýtvá tonikem")
	var once := GameSession.new(catalog)
	_batch(once,1)
	host._check(Recipes.craft(once,"fertilizer").ok,"Dílna: přesná dávka bylin vystačí na jednu výrobu")
	unchanged = _snapshot(once)
	host._check(not Recipes.craft(once,"fertilizer").ok and unchanged == _snapshot(once),"Dílna: opakovaný klik bez zásob nevytvoří druhou dávku")
	var data := session.to_dict()
	var restored := GameSession.new(catalog)
	restored.from_dict(data)
	host._check(data.schema == GameSession.SAVE_SCHEMA and restored.fertilizer_doses == session.fertilizer_doses and restored.coins == session.coins and restored.plants[0].health == session.plants[0].health,"Dílna: výsledky výroby zachová současné ukládání schema 42")
	_run_mint(host,catalog)
	_run_rosemary(host,catalog)
	await _run_ui(host)


static func _run_rosemary(host: SceneTree, catalog: Dictionary) -> void:
	var session := GameSession.new(catalog)
	session.coins = 40
	var target: PlantSimulation = session.plants[1]
	target.plant_seed()
	target.health = 60
	_batch(session,10,PlantSimulation.Stage.DRY,"mint_peppermint")
	_batch(session,10,PlantSimulation.Stage.PACKAGED,"rosemary_officinalis")
	_batch(session,10,PlantSimulation.Stage.DRYING,"rosemary_officinalis")
	var before := _snapshot(session)
	host._check(not Recipes.craft(session,"rosemary_tonic",1).ok and before == _snapshot(session),"Rozmarýn: nepoužije mátu, zabalené ani sušící se byliny")
	var first := _batch(session,0.75,PlantSimulation.Stage.DRY,"rosemary_officinalis")
	before = _snapshot(session)
	host._check(not Recipes.craft(session,"rosemary_tonic",1).ok and before == _snapshot(session),"Rozmarýn: neúplné množství se neodečte")
	var second := _batch(session,3.25,PlantSimulation.Stage.DRY,"rosemary_officinalis")
	before = _snapshot(session)
	for invalid in [-1,0,GameSession.MAX_PLANT_SLOTS,999]:
		host._check(not Recipes.craft(session,"rosemary_tonic",invalid).ok and before == _snapshot(session),"Rozmarýn: neplatný či prázdný cíl %d nezmění zásoby" % invalid)
	var result := Recipes.craft(session,"rosemary_tonic",1,func() -> bool: return false)
	host._check(not result.ok and before == _snapshot(session) and target.health == 60,"Rozmarýn: selhání save vrátí zdraví, mince a přesné šarže")
	var other_health: float = session.plants[0].health
	var doses: int = session.fertilizer_doses
	result = Recipes.craft(session,"rosemary_tonic",1,func() -> bool: return true)
	host._check(result.ok and target.health == 80 and session.coins == 36 and Recipes.usable_herbs(session,"rosemary_officinalis") == 2,"Rozmarýn: 2 g a 4 mince obnoví cíli právě 20 zdraví")
	host._check(first.stage == PlantSimulation.Stage.EMPTY and second.dry_harvest_g == 2 and second.fresh_harvest_g == 10 and session.plants[0].health == other_health and session.fertilizer_doses == doses,"Rozmarýn: částečná šarže, jiná rostlina a hnojivo zůstanou správně")
	target.health = 84
	result = Recipes.craft(session,"rosemary_tonic",1)
	host._check(result.ok and target.health == 100 and str(result.message).contains("(+16)"),"Rozmarýn: zastaví zdraví na 100 a oznámí skutečných 16 bodů")
	_batch(session,2,PlantSimulation.Stage.DRY,"rosemary_officinalis")
	for stage in [PlantSimulation.Stage.EMPTY,PlantSimulation.Stage.DEAD,PlantSimulation.Stage.DRY]:
		target.stage = stage
		target.health = 30
		before = _snapshot(session)
		host._check(not Recipes.craft(session,"rosemary_tonic",1).ok and before == _snapshot(session),"Rozmarýn: nepoužije směs na prázdný, mrtvý či sklizený cíl")
	target.stage = PlantSimulation.Stage.VEGETATIVE
	target.health = 85
	before = _snapshot(session)
	host._check(not Recipes.craft(session,"rosemary_tonic",1).ok and before == _snapshot(session),"Rozmarýn: zdravá rostlina s 85 body tonikum nepotřebuje")
	target.health = 40
	session.coins = 3
	before = _snapshot(session)
	host._check(not Recipes.craft(session,"rosemary_tonic",1).ok and before == _snapshot(session),"Rozmarýn: chybějící mince zachovají zdraví i byliny")
	var restored := GameSession.new(catalog)
	restored.from_dict(session.to_dict())
	host._check(restored.coins == session.coins and restored.plants[1].health == target.health and Recipes.usable_herbs(restored,"rosemary_officinalis") == 2,"Rozmarýn: současný save formát zachová výsledek i zbytek bylin")


static func _run_mint(host: SceneTree, catalog: Dictionary) -> void:
	var session := GameSession.new(catalog)
	session.coins = 30
	var basil := _batch(session,10)
	var packed := _batch(session,10,PlantSimulation.Stage.PACKAGED,"mint_peppermint")
	var drying := _batch(session,10,PlantSimulation.Stage.DRYING,"mint_peppermint")
	var before := _snapshot(session)
	host._check(Recipes.usable_herbs(session,"mint_peppermint") == 0 and not Recipes.craft(session,"mint_feed").ok and before == _snapshot(session),"Máta: bazalka, zabalená a sušící se máta nenahradí sušenou nezabalenou mátu")
	var mint_a := _batch(session,0.75,PlantSimulation.Stage.DRY,"mint_peppermint")
	before = _snapshot(session)
	host._check(not Recipes.craft(session,"mint_feed").ok and before == _snapshot(session),"Máta: neúplná dávka nic neodečte")
	var mint_b := _batch(session,1.25,PlantSimulation.Stage.DRY,"mint_peppermint")
	before = _snapshot(session)
	var failed := Recipes.craft(session,"mint_feed",-1,func() -> bool: return false)
	host._check(not failed.ok and before == _snapshot(session),"Máta: neúspěšný zápis vrátí i zcela spotřebované dávky, mince a hnojivo")
	var doses := session.fertilizer_doses
	var coins := session.coins
	host._check(Recipes.craft(session,"mint_feed",-1,func() -> bool: return true).ok,"Máta: úspěšný uložený recept se dokončí")
	host._check(session.coins == coins-3 and session.fertilizer_doses == doses+2 and mint_a.stage == PlantSimulation.Stage.EMPTY and mint_b.stage == PlantSimulation.Stage.EMPTY,"Máta: 2 g napříč dávkami a tři mince vytvoří právě dvě dávky hnojiva")
	host._check(basil.dry_harvest_g == 10 and packed.dry_harvest_g == 10 and drying.dry_harvest_g == 10,"Máta: jiné druhy a fáze sklizně zůstávají nedotčené")
	before = _snapshot(session)
	host._check(not Recipes.craft(session,"mint_feed").ok and before == _snapshot(session),"Máta: opakovaný klik bez surovin nevytvoří další odměnu")
	var restored := GameSession.new(catalog)
	restored.from_dict(session.to_dict())
	host._check(restored.fertilizer_doses == session.fertilizer_doses and restored.coins == session.coins and Recipes.usable_herbs(restored,"mint_peppermint") == 0,"Máta: restart zachová výsledek i spotřebu")
	_batch(session,4,PlantSimulation.Stage.DRY,"mint_peppermint")
	session.coins = 2
	before = _snapshot(session)
	host._check(not Recipes.craft(session,"mint_feed").ok and before == _snapshot(session),"Máta: nedostatek mincí nezmění zásoby")
	session.coins = 30
	session.plants[0].plant_seed()
	session.plants[0].health = 60
	before = _snapshot(session)
	host._check(not Recipes.craft(session,"tonic",0,func() -> bool: return false).ok and before == _snapshot(session),"Dílna: při chybě uložení se vrátí také zdraví cíle tonika")


static func _run_ui(host: SceneTree) -> void:
	var surface := SubViewport.new()
	surface.size = Vector2i(432,960)
	host.root.add_child(surface)
	var game = load("res://main.tscn").instantiate()
	surface.add_child(game)
	await host.process_frame
	await host.process_frame
	host._finish_phase92_startup_for_test(game)
	game.session.intro_completed = true
	game.session.paused = true
	game.set_process(false)
	game.session.coins = 100
	game.session.purchase_or_place_room_decoration("room_orchid",0)
	game.session.purchase_or_place_room_decoration("botanical_books",12)
	game._open_player_room()
	await host.process_frame
	var room = game.player_room_view
	var before_owned = game.session.owned_room_decorations.duplicate()
	var before_slots = game.session.get_room_decoration_slots().duplicate()
	var purchase_balance: int = game.session.coins
	game._on_room_plant_move_requested(0,1,"room_orchid")
	host._check(game.session.room_decoration_slots == before_slots and game.session.coins == purchase_balance and not game._room_plant_drag_available(),"Dílna: pevná malba odmítne přesun skryté dekorace a zachová nákupy i uložené sloty")
	game._on_room_plant_move_requested(1,0,"room_orchid")
	host._check(room.material == null,"Dílna: na nové malbě není maska starých zapečených tlačítek pokoje")
	for viewport in [Vector2(432,960),Vector2(360,800)]:
		surface.size = Vector2i(viewport)
		game.size = viewport
		await host.process_frame
		await host.process_frame
		var safe_local := Rect2(0,24,viewport.x,viewport.y-56) if viewport.x == 360 else Rect2(Vector2.ZERO,viewport)
		game._apply_safe_area_rect(safe_local,viewport,viewport)
		game.teahouse_hub._layout_scene()
		await host.process_frame
		var room_rect: Rect2 = room.get_global_transform_with_canvas() * Rect2(Vector2.ZERO,room.size)
		var bench_rect: Rect2 = room.workbench_button.get_global_transform_with_canvas() * Rect2(Vector2.ZERO,room.workbench_button.size)
		var bench_local := Rect2(room.workbench_button.position,room.workbench_button.size)
		host._check(room.get_meta("workshop_room",false) and room.teahouse_embedded and room_rect.encloses(bench_rect) and bench_local.is_equal_approx(Rect2(106,508,220,54)),"Dílna: schválený pracovní stůl má cíl 220×54 uvnitř vložené místnosti na %s" % viewport)
		var hub: Control = game.teahouse_hub
		var back: Button = hub.buttons.back
		var back_rect: Rect2 = back.get_global_transform_with_canvas() * Rect2(Vector2.ZERO,back.size)
		var safe_global: Rect2 = game.get_global_transform_with_canvas() * safe_local
		host._check(not room.back_button.visible and not room.theme_button.visible and not room.title_card.visible and hub.active and hub.page == "workshop" and back.is_visible_in_tree() and safe_global.encloses(back_rect) and back.size.is_equal_approx(Vector2(44,44)),"Dílna: sdílené záhlaví má dostupný návrat v safe area a neskládá skryté staré ovládání")
		var hidden_targets := true
		for target: Button in room.decoration_buttons:
			hidden_targets = hidden_targets and not target.visible and target.disabled and target.mouse_filter == Control.MOUSE_FILTER_IGNORE
		host._check(hidden_targets and not room.plant_drag_enabled and room.plant_slot_at_position(room._decoration_visual_centers(room.size)[0],true) == -1,"Dílna: namalované police nemají neviditelné nákupní ani přesouvací cíle")
		room.workbench_button.pressed.emit()
		await host.process_frame
		host._check(game.workshop_open and game.workshop_modal.visible and game._is_blocking_modal_open() and not game._room_plant_drag_available(),"Dílna: recepty blokují pozadí, péči, přesuny dekorací a průchody kocoura")
		game.garden_cat_companion._process(0)
		host._check(not game.garden_cat_companion.visible,"Dílna: kocour neleze přes otevřené recepty")
		host._check(game._consume_mobile_back_navigation() and not game.workshop_open and not game.workshop_modal.visible,"Dílna: systémové Zpět zavře recepty a zůstane v dílně")
		host._check(game.garden_location_id == "player_room" and game.player_room_panel.visible,"Dílna: zavření receptů nezmění místo")
	host._check(before_owned == game.session.owned_room_decorations and before_slots == game.session.get_room_decoration_slots(),"Dílna: procházení místností a recepty zachová zakoupené dekorace i jejich sloty")
	game._open_settings_modal()
	var appearance: Button
	for button: Button in game.settings_modal.find_children("*","Button",true,false):
		if button.get_meta("component","") == "phase14_cosmetic_showroom_launcher_v1":
			appearance = button
			break
	if appearance != null:
		appearance.pressed.emit()
	host._check(appearance != null and game.cosmetic_modal_open and game.cosmetic_modal.visible and game.teahouse_hub.active and game.teahouse_hub.page == "workshop","Dílna: vzhled zůstává dostupný přes hráčské nastavení i bez starého tlačítka místnosti")
	game._close_cosmetic_modal()
	game._close_settings_modal()
	room.workbench_button.pressed.emit()
	var modal = game.workshop_modal
	modal.persist_override = func() -> bool: return true
	game.session.coins = 30
	_batch(game.session,4,PlantSimulation.Stage.DRY,"mint_peppermint")
	modal.refresh()
	var doses: int = game.session.fertilizer_doses
	game.session.reduced_motion = false
	modal._craft("mint_feed")
	var after := _snapshot(game.session)
	modal._craft("mint_feed")
	host._check(modal.busy and game.session.fertilizer_doses == doses+2 and _snapshot(game.session) == after,"Máta UI: během animace druhé kliknutí nic neodečte")
	host._check(game._consume_mobile_back_navigation() and not modal.busy and not modal.craft_visual.mortar_glow.active and game.session.fertilizer_doses == doses+2,"Máta UI: Zpět ukončí animaci i záři, ale nezruší uložený výsledek")
	modal.open()
	game.session.reduced_motion = true
	modal._craft("mint_feed")
	var mint_finished := await _wait_for_craft_completion(host,modal)
	host._check(mint_finished and not modal.busy and game.session.fertilizer_doses == doses+4 and modal.craft_visual.phase == 2.4,"Máta UI: omezený pohyb ukáže klidný hotový výsledek")
	_batch(game.session,2,PlantSimulation.Stage.DRY,"mint_peppermint")
	modal.persist_override = func() -> bool: return false
	after = _snapshot(game.session)
	modal._craft("mint_feed")
	host._check(not modal.busy and after == _snapshot(game.session) and modal.status_label.text.contains("nepodařilo uložit"),"Máta UI: chyba zápisu nezahájí animaci a zachová zásoby")
	_batch(game.session,6,PlantSimulation.Stage.DRY,"rosemary_officinalis")
	for slot in [0,1]:
		game.session.plants[slot].plant_seed()
		game.session.plants[slot].health = 50
	game.session.coins = 30
	modal.persist_override = func() -> bool: return true
	game.session.reduced_motion = false
	modal.refresh()
	var picker: OptionButton = modal.target_pickers.rosemary_tonic
	modal._on_target_selected(1,"rosemary_tonic")
	await host.process_frame
	modal._craft("rosemary_tonic")
	after = _snapshot(game.session)
	modal._craft("rosemary_tonic")
	host._check(modal.busy and _snapshot(game.session) == after and game.session.plants[1].health == 70 and game.session.plants[0].health == 50 and picker.disabled,"Rozmarýn UI: výběr druhé rostliny a dvojklik použijí právě jednu dávku")
	host._check(game._consume_mobile_back_navigation() and not modal.busy and not modal.craft_visuals.rosemary_tonic.mortar_glow.active and game.session.plants[1].health == 70,"Rozmarýn UI: Zpět ukončí prezentaci i záři a zachová uložený účinek")
	modal.open()
	game.session.reduced_motion = true
	modal._craft("rosemary_tonic")
	var rosemary_finished := await _wait_for_craft_completion(host,modal)
	host._check(rosemary_finished and not modal.busy and game.session.plants[1].health == 90 and modal.status_label.text.contains("(+20)") and modal.craft_visuals.rosemary_tonic.phase == 2.4,"Rozmarýn UI: omezený pohyb ukáže hotový výsledek a správnou zprávu")
	host._check(modal.selected_target == 1 and picker.get_selected_id() == 1 and modal.recipe_buttons.rosemary_tonic.disabled,"Dílna: uzdravený cíl zůstane vybraný a další dávka neskočí na jiný květináč")
	after = _snapshot(game.session)
	modal._craft("rosemary_tonic")
	host._check(after == _snapshot(game.session) and game.session.plants[0].health == 50,"Dílna: opakování bez nové volby po uzdravení nic neodečte ani neposílí jiný cíl")
	for item in range(picker.item_count):
		if picker.get_item_id(item) == 0: modal._on_target_selected(item,"rosemary_tonic")
	await host.process_frame
	host._check(modal.selected_target == 0 and modal.target_picker.get_selected_id() == 0 and not modal.recipe_buttons.rosemary_tonic.disabled,"Dílna: výslovný výběr jiného květináče synchronizuje obě tonika")
	modal.persist_override = func() -> bool: return false
	after = _snapshot(game.session)
	modal._craft("rosemary_tonic")
	host._check(not modal.busy and after == _snapshot(game.session) and modal.status_label.text.contains("nepodařilo uložit"),"Rozmarýn UI: nezdařené uložení nepřipraví rostlinu ani hráče o zásoby")
	for batch in game.session.plants:
		if batch.stage == PlantSimulation.Stage.DRY and str(batch.profile.get("id","")) == "rosemary_officinalis":
			batch.dry_harvest_g = 0.5
			batch.fresh_harvest_g = 2.5
	game.session.coins = 1
	after = _snapshot(game.session)
	modal.refresh()
	var state := Recipes.state(game.session,"rosemary_tonic",modal.selected_target)
	host._check(state.missing_g == 1.5 and state.missing_coins == 3 and state.target_ready,"Dílna: stav vrátí všechny scházející suroviny při platném cíli")
	host._check(modal.recipe_stocks.rosemary_tonic.text.contains("0,5 / 2 g") and modal.recipe_stocks.rosemary_tonic.text.contains("1 / 4") and modal.recipe_reasons.rosemary_tonic.text.contains("1,5 g rozmarýnu a 3 mince"),"Dílna: současně ukáže zásobu, cenu i přesný nedostatek bylin a mincí")
	host._check(modal._stock_grams(1.96) == "1,9" and modal._stock_grams(1.9999999) == "2,0","Dílna: zobrazení zásob nezaokrouhlí nedostatek na plné množství a respektuje toleranci receptu")
	host._check(after == _snapshot(game.session),"Dílna: aktualizace dostupnosti je pouze čtení, nemění uložený postup")
	modal.persist_override = func() -> bool: return true
	game.session.coins = 20
	_batch(game.session,3,PlantSimulation.Stage.DRY,"rosemary_officinalis")
	modal.refresh()
	host._check(not modal.recipe_buttons.rosemary_tonic.disabled and modal.recipe_reasons.rosemary_tonic.text.begins_with("Připraveno"),"Dílna: doplnění surovin obnoví připravený stav bez zavření dialogu")
	game.session.reduced_motion = false
	modal._craft("rosemary_tonic")
	host._check(modal.recipe_buttons.rosemary_tonic.text == "MÍCHÁM…" and modal.recipe_buttons.mint_feed.disabled,"Dílna: při přípravě jasně označí právě míchaný recept a blokuje ostatní")
	modal.close()
	modal.open()
	SaveManager.writes_blocked = true
	after = _snapshot(game.session)
	modal.refresh()
	modal._craft("rosemary_tonic")
	host._check(modal.recipe_buttons.rosemary_tonic.disabled and modal.recipe_reasons.rosemary_tonic.text.contains("Ukládání není dostupné") and after == _snapshot(game.session),"Dílna: blokované ukládání je vysvětlené a nespotřebuje suroviny")
	SaveManager.writes_blocked = false
	game._change_screen(1)
	host._check(not game.workshop_open and not game.workshop_modal.visible,"Dílna: programový odchod do jiné záložky zavře recepty")
	await _check_storage_link(host,game)
	await _check_result_navigation(host,game)
	await _check_success_feedback(host,game)
	await _check_completion_wait_guards(host,game)
	game.queue_free()
	surface.queue_free()
	await host.process_frame


static func _check_storage_link(host: SceneTree, game: Control) -> void:
	var batch := _batch(game.session,4,PlantSimulation.Stage.DRY,"mint_peppermint")
	game.session.select_plant(game.session.plants.size()-1)
	game.session.coins = 0
	game.session.reduced_motion = true
	var modal = game.workshop_modal
	for stage in [PlantSimulation.Stage.HARVESTED,PlantSimulation.Stage.DRYING,PlantSimulation.Stage.PACKAGED,PlantSimulation.Stage.EMPTY]:
		batch.stage = stage
		game._update_storage_panel()
		game.storage_workshop_button.pressed.emit()
		host._check(not game.storage_workshop_button.visible and game.active_screen == 1 and not game.workshop_open,"Sklad → dílna: čerstvé, sušené v procesu, zabalené a prázdné dávky neotevřou recept: %d" % stage)
	batch.stage = PlantSimulation.Stage.DRY
	for grams in [0.0,-1.0,NAN,INF]:
		batch.dry_harvest_g = grams
		game._update_storage_panel()
		game.storage_workshop_button.pressed.emit()
		host._check(not game.storage_workshop_button.visible and game.active_screen == 1 and not game.workshop_open,"Sklad → dílna: prázdné nebo neplatné množství nenabídne spotřebu: %s" % grams)
	batch.dry_harvest_g = 4
	game._update_storage_panel()
	game.swipe_action_suppressed = true
	game.storage_workshop_button.pressed.emit()
	host._check(game.active_screen == 1 and not game.workshop_open,"Sklad → dílna: tažení skladu nezpůsobí otevření receptů")
	game.swipe_action_suppressed = false
	game.dialog_open = true
	game.storage_workshop_button.pressed.emit()
	host._check(game.active_screen == 1 and not game.workshop_open,"Sklad → dílna: překrývající dialog blokuje přechod")
	game.dialog_open = false
	for viewport in [Vector2(360,800),Vector2(432,960)]:
		game.size = viewport
		await host.process_frame
		await host.process_frame
		var link: Button = game.storage_workshop_button
		var primary: Button = game.storage_action_button
		host._check(link.visible and link.size.y >= 56 and link.get_parent().get_global_rect().encloses(link.get_global_rect()) and not link.get_global_rect().intersects(primary.get_global_rect()),"Sklad → dílna: samostatný 56px cíl s odstupem od balení na %s" % viewport)
	for species in {"mint_peppermint":"mint_feed","rosemary_officinalis":"rosemary_tonic","basil_genovese":"fertilizer"}:
		var recipe_id: String = {"mint_peppermint":"mint_feed","rosemary_officinalis":"rosemary_tonic","basil_genovese":"fertilizer"}[species]
		batch.reset()
		batch.configure_profile(game.session.get_plant_profile(species))
		batch.stage = PlantSimulation.Stage.DRY
		batch.dry_harvest_g = 4
		batch.fresh_harvest_g = 20
		game._change_screen(1)
		game._update_storage_panel()
		var before := _snapshot(game.session)
		game.storage_workshop_button.pressed.emit()
		game.storage_workshop_button.pressed.emit()
		await host.process_frame
		await host.process_frame
		await host.process_frame
		var after := _snapshot(game.session)
		before.erase("visited_screens")
		after.erase("visited_screens")
		host._check(game.active_screen == 0 and game.garden_location_id == "player_room" and modal.visible and modal.scroll.get_global_rect().encloses(modal.recipe_cards[recipe_id].get_global_rect()),"Sklad → dílna: skutečné tlačítko ukáže celou kartu odpovídajícího receptu i bez mincí: "+species)
		host._check(before == after and modal.recipe_buttons[recipe_id].disabled,"Sklad → dílna: dvojklik ani prohlédnutí receptu nemění zásoby, rostliny ani mince: "+species)
		host._check(game._consume_mobile_back_navigation() and not modal.visible and game.garden_location_id == "player_room","Sklad → dílna: Zpět bezpečně zavře recept a ponechá dílnu")
	# An old delayed scroll must not affect a subsequently reopened dialog.
	modal.open_for_herb("rosemary_officinalis")
	modal.close()
	modal.open()
	await host.process_frame
	await host.process_frame
	await host.process_frame
	host._check(modal.scroll.scroll_vertical == 0,"Sklad → dílna: rychlé zavření zruší odložený přesun na recept a běžné otevření začíná nahoře")
	modal.close()


static func _result_resources(session: GameSession) -> Array:
	var health: Array = []
	for plant in session.plants: health.append(plant.health)
	return [session.coins,session.fertilizer_doses,Recipes.usable_herbs(session),health]


static func _check_result_navigation(host: SceneTree, game: Control) -> void:
	var modal = game.workshop_modal
	game.session.coins = 100
	game.session.xp = 100
	_batch(game.session,8,PlantSimulation.Stage.DRY,"mint_peppermint")
	_batch(game.session,8,PlantSimulation.Stage.DRY,"rosemary_officinalis")
	modal.persist_override = func() -> bool: return true
	game.session.reduced_motion = false
	modal.open()
	host._check(not modal.result_button.visible and modal.close_button.text == "ZPĚT DO DÍLNY","Výsledek dílny: při otevření se nenabízí stará odměna")
	var doses: int = game.session.fertilizer_doses
	modal.recipe_buttons.mint_feed.pressed.emit()
	modal.result_button.pressed.emit()
	host._check(modal.busy and not modal.result_button.visible and game.workshop_open and game.session.fertilizer_doses == doses+2,"Výsledek dílny: navigace neukončí probíhající animaci ani nespotřebuje hnojivo")
	await host.create_timer(2.6).timeout
	host._check(not modal.busy and modal.result_button.visible and modal.result_button.text == "K ROSTLINÁM","Výsledek dílny: po celé animaci máty nabídne výběr rostliny")
	for viewport in [Vector2(360,800),Vector2(432,960)]:
		game.size = viewport
		await host.process_frame
		await host.process_frame
		var link: Button = modal.result_button
		var back: Button = modal.close_button
		var footer: Rect2 = link.get_parent().get_global_rect()
		host._check(footer.encloses(link.get_global_rect()) and footer.encloses(back.get_global_rect()) and link.size.y >= 56 and back.size.y >= 56 and back.global_position.x-link.get_global_rect().end.x >= 8,"Výsledek dílny: oba 56px cíle mají odstup a zůstávají v rámečku na %s" % viewport)
	var resources := _result_resources(game.session)
	modal.result_button.pressed.emit()
	host._check(not game.workshop_open and game.plants_room_panel.visible and not game.player_room_panel.visible,"Výsledek dílny: tlačítko po hnojivu otevře výběr květináče")
	modal.result_button.pressed.emit()
	host._check(resources == _result_resources(game.session),"Výsledek dílny: přechod ani dvojklik nic znovu nevyrobí, neodečte a nehnojí")
	game._open_player_room()
	modal.open()
	await host.process_frame
	await host.process_frame
	host._check(not modal.result_button.visible and is_equal_approx(modal.close_button.size.x,modal.close_button.get_parent().size.x),"Výsledek dílny: nové otevření vrátí původní plnou šířku návratu")
	modal.recipe_buttons.fertilizer.pressed.emit()
	host._check(not modal.busy and modal.result_button.visible and modal.result_button.text == "K ROSTLINÁM","Výsledek dílny: běžné hnojivo má stejnou návaznost bez zvláštní animace")
	modal.persist_override = func() -> bool: return false
	resources = _result_resources(game.session)
	modal.recipe_buttons.fertilizer.pressed.emit()
	host._check(not modal.result_button.visible and resources == _result_resources(game.session),"Výsledek dílny: neúspěšné uložení nenabídne výsledek předchozího receptu")
	modal.persist_override = func() -> bool: return true
	modal.recipe_buttons.mint_feed.pressed.emit()
	modal.close_button.pressed.emit()
	modal.open()
	await host.create_timer(2.6).timeout
	host._check(not modal.busy and not modal.result_button.visible and modal.close_button.text == "ZPĚT DO DÍLNY","Výsledek dílny: zrušená animace nevrátí staré tlačítko po opětovném otevření")
	for slot in [0,1]:
		game.session.plants[slot].reset()
		game.session.plants[slot].plant_seed()
		game.session.plants[slot].health = 50
	game.session.reduced_motion = true
	modal.selected_target = 0
	modal.refresh()
	modal.recipe_buttons.rosemary_tonic.pressed.emit()
	var rosemary_finished := await _wait_for_craft_completion(host,modal)
	host._check(rosemary_finished and modal.result_button.visible and modal.result_button.text == "K ROSTLINĚ" and game.session.plants[0].health == 70,"Výsledek dílny: tonikum i s omezeným pohybem nabídne ošetřenou rostlinu")
	var picker: OptionButton = modal.target_pickers.rosemary_tonic
	for item in range(picker.item_count):
		if picker.get_item_id(item) == 1: modal._on_target_selected(item,"rosemary_tonic")
	await host.process_frame
	resources = _result_resources(game.session)
	modal.result_button.pressed.emit()
	host._check(game.session.selected_plant_index == 0 and game.plant_detail_panel.visible and not game.workshop_open,"Výsledek dílny: změna výběru dalšího receptu nepřesměruje odkaz od skutečně ošetřené rostliny")
	host._check(resources == _result_resources(game.session),"Výsledek dílny: otevření detailu neaplikuje účinek tonika podruhé")
	game._open_player_room()
	modal.open()
	modal.selected_target = 1
	modal.refresh()
	modal.recipe_buttons.tonic.pressed.emit()
	host._check(modal.result_button.visible and modal.result_button.text == "K ROSTLINĚ" and game.session.plants[1].health == 62,"Výsledek dílny: i běžné tonikum vede ke správnému cíli")
	# A replaced slot is a different plant, even when its index matches.
	game.session.plants[1] = PlantSimulation.new(game.session.get_plant_profile("basil_genovese"))
	game.session.plants[1].plant_seed()
	modal.refresh()
	host._check(modal.result_button.text == "K ROSTLINÁM","Výsledek dílny: nahrazení ošetřené rostliny změní odkaz na přehled")
	modal.result_button.pressed.emit()
	host._check(game.plants_room_panel.visible and not game.plant_detail_panel.visible,"Výsledek dílny: odkaz neotevře jinou rostlinu ve stejném květináči")
	game._open_player_room()
	modal.open()
	modal.selected_target = 0
	modal.refresh()
	modal.recipe_buttons.tonic.pressed.emit()
	game.session.plants[0].reset()
	modal.result_button.pressed.emit()
	host._check(game.plants_room_panel.visible and not game.plant_detail_panel.visible,"Výsledek dílny: odstraněný cíl je znovu ověřen přímo při kliknutí")
	game._open_player_room()
	modal.open()
	modal.recipe_buttons.fertilizer.pressed.emit()
	var original_session: GameSession = game.session
	game.session = GameSession.new(host._load_plant_catalog())
	modal.result_button.pressed.emit()
	host._check(game.workshop_open and game.player_room_panel.visible,"Výsledek dílny: obnovený profil odmítne odkaz z předchozího stavu")
	modal.refresh()
	host._check(not modal.result_button.visible,"Výsledek dílny: obnovení profilu vyčistí starý výsledek")
	game.session = original_session
	modal.close()


static func _all_success_effects_inactive(modal: Control) -> bool:
	for effect in modal.success_effects.values():
		if effect.active: return false
	return true


static func _check_success_feedback(host: SceneTree, game: Control) -> void:
	var modal = game.workshop_modal
	game._open_player_room()
	game.session.coins = 100
	game.session.reduced_motion = false
	_batch(game.session,4,PlantSimulation.Stage.DRY,"mint_peppermint")
	_batch(game.session,4)
	modal.persist_override = func() -> bool: return true
	modal.open()
	host._check(_all_success_effects_inactive(modal) and not modal.craft_visual.mortar_glow.active,"Radost z receptu: běžné otevření nemá falešný efekt úspěchu ani záři")
	modal.recipe_buttons.mint_feed.pressed.emit()
	var saved_resources := _result_resources(game.session)
	await host.create_timer(1.0).timeout
	host._check(modal.busy and _all_success_effects_inactive(modal) and modal.craft_visual.mortar_glow.active,"Radost z receptu: při míchání září hmoždíř a oslava čeká na dokončení")
	await host.create_timer(1.08).timeout
	host._check(modal.craft_visual.mortar_glow.active and modal.busy,"Záře hmoždíře: je aktivní i po dvou sekundách a nezkrátí míchání")
	await host.create_timer(0.47).timeout
	host._check(not modal.busy and modal.result_button.visible and modal.success_effects.mint_feed.active and not modal.success_effects.rosemary_tonic.active,"Radost z receptu: pouze hotová směs slaví a hráč už může pokračovat")
	await host.create_timer(1.5).timeout
	host._check(_all_success_effects_inactive(modal) and not modal.craft_visual.mortar_glow.active and saved_resources == _result_resources(game.session),"Radost z receptu: záře i oslava samy skončí a nezmění odměnu ani zásoby")
	game.session.reduced_motion = true
	modal.recipe_buttons.mint_feed.pressed.emit()
	var mint_finished := await _wait_for_craft_completion(host,modal)
	host._check(mint_finished and not modal.busy and modal.success_effects.mint_feed.active and modal.success_effects.mint_feed.calm and modal.success_effects.mint_feed.result_scale() == 1 and modal.craft_visual.mortar_glow.active and modal.craft_visual.mortar_glow.calm,"Radost z receptu: omezený pohyb ponechá klidné potvrzení a záři bez pulzování")
	modal.persist_override = func() -> bool: return false
	saved_resources = _result_resources(game.session)
	modal.recipe_buttons.fertilizer.pressed.emit()
	host._check(_all_success_effects_inactive(modal) and not modal.craft_visual.mortar_glow.active and saved_resources == _result_resources(game.session),"Radost z receptu: chyba uložení zruší předchozí oslavu i záři a nespustí nové")
	modal.persist_override = func() -> bool: return true
	game.session.reduced_motion = false
	modal.recipe_buttons.fertilizer.pressed.emit()
	host._check(modal.success_effects.fertilizer.active and not modal.busy and modal.success_effects.fertilizer.mouse_filter == Control.MOUSE_FILTER_IGNORE,"Radost z receptu: běžný recept má malé potvrzení a efekt neodchytává ovládání")
	modal.close_button.pressed.emit()
	modal.open()
	await host.create_timer(1.6).timeout
	host._check(_all_success_effects_inactive(modal) and not modal.craft_visual.mortar_glow.active,"Radost z receptu: zavření a nové otevření odstraní všechny staré částice i záři")
	modal.close()


static func _wait_for_craft_completion(host: SceneTree, modal, timeout_msec: int = 2000) -> bool:
	# The recipe transaction is synchronous; presentation finishes from a tween
	# callback. Observe that callback's state rather than assuming a frame rate.
	var revision: int = modal.open_revision
	var session: GameSession = modal.game.session
	var recipe: String = modal.completed_recipe
	var deadline := Time.get_ticks_msec() + timeout_msec
	while is_instance_valid(modal) and is_instance_valid(modal.game):
		if not modal.visible or modal.open_revision != revision or modal.game.session != session \
				or recipe.is_empty() or modal.completed_recipe != recipe:
			return false
		if not modal.busy:
			return true
		if Time.get_ticks_msec() >= deadline:
			return false
		await host.process_frame
	return false


static func _check_completion_wait_guards(host: SceneTree, game: Control) -> void:
	var modal = game.workshop_modal
	game._open_player_room()
	game.session.coins = 100
	game.session.reduced_motion = false
	_batch(game.session,4,PlantSimulation.Stage.DRY,"mint_peppermint")
	modal.persist_override = func() -> bool: return true
	modal.open()
	modal._craft("mint_feed")
	var resources := _result_resources(game.session)
	var timed_out := not await _wait_for_craft_completion(host,modal,0)
	host._check(timed_out and modal.busy and resources == _result_resources(game.session),"Čekání dílny: timeout neoznačí rozpracovanou animaci za dokončenou a nezmění zásoby")
	modal.call_deferred("close")
	var cancelled := not await _wait_for_craft_completion(host,modal)
	host._check(cancelled and not modal.visible and not modal.busy and resources == _result_resources(game.session),"Čekání dílny: zavření bez signálu finished ukončí čekání jako zrušené, bez dalšího odečtu")
