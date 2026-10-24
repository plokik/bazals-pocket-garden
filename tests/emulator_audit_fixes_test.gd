extends RefCounted

static func run(host: SceneTree) -> void:
	var guide = preload("res://scripts/ui/guided_tutorial.gd")
	var target := Rect2(20, 528, 392, 68)
	var safe := Rect2(6, 6, 420, 948)
	var professor := Rect2(24, 88, 384, 180)
	var obstacles: Array[Rect2] = [Rect2(145, 552, 145, 20), Rect2(20, 606, 392, 56)]
	var hand: Dictionary = guide.resolve_hand_layout(target, safe, professor, obstacles)
	host._check(not hand.is_empty(), "Audit A05: balení má čitelnou ukazující ruku i s následujícím tlačítkem dílny")
	if not hand.is_empty():
		host._check(target.has_point(hand.finger) and safe.encloses(hand.bounds), "Audit A05: prst míří dovnitř správného tlačítka a celý pohyb zůstává v bezpečné ploše")
		for obstacle in obstacles:
			host._check(not obstacle.intersects(hand.bounds), "Audit A05: ruka včetně pulzu nepřekrývá popisek ani sousední akci")
	var filled: Array[Rect2] = [safe]
	host._check(guide.resolve_hand_layout(target, safe, professor, filled).is_empty(), "Audit A05: při nedostatku místa zůstane zvýraznění bez překrývající ruky")
	var surface := SubViewport.new()
	surface.size = Vector2i(432, 960)
	host.root.add_child(surface)
	var game = load("res://main.tscn").instantiate()
	surface.add_child(game)
	for i in range(4): await host.process_frame
	host._finish_phase92_startup_for_test(game)
	game._close_save_recovery()
	game._close_return_summary()
	game._set_guide_modal_open(false, false)
	game.set_process(false)
	game.garden_cat_companion.set_process(false)
	game.audio_haptics.set_capture_mode(true)
	var session := GameSession.new(host._load_plant_catalog())
	session.intro_completed = true
	session.journey_completed = true
	session.guided_tutorial_enabled = false
	session.plant.plant_seed()
	session.plant.health = 60
	game._activate_session(session)
	game._open_player_room()
	game.workshop_modal.open()
	var picker: OptionButton = game.workshop_modal.target_pickers.tonic
	for i in range(3): await host.process_frame
	var snapshot := session.to_dict().duplicate(true)
	snapshot.erase("saved_at_unix")
	picker.show_popup()
	await host.process_frame
	host._check(picker.get_popup().visible, "Audit A01: skutečný výběr cílové rostliny je otevřený")
	var consumed: bool = game._consume_mobile_back_navigation()
	host._check(consumed and not picker.get_popup().visible and game.workshop_open and game.workshop_modal.visible, "Audit A01: první systémové Zpět zavře pouze výběr a zachová recepty")
	host._check(game._consume_mobile_back_navigation() and not game.workshop_open, "Audit A01: druhé systémové Zpět správně zavře recepty")
	var after := session.to_dict().duplicate(true)
	after.erase("saved_at_unix")
	host._check(snapshot == after, "Audit A01: zavírání nabídky ani dialogu nemění postup a zásoby")
	# The same priority must protect the storage screen's harvest chooser.
	game._change_screen(1)
	game.storage_batch_picker.add_item("Testovací šarže", 0)
	game.storage_batch_picker.show()
	game.storage_batch_picker.show_popup()
	await host.process_frame
	host._check(game._consume_mobile_back_navigation() and game.active_screen == 1 and not game.storage_batch_picker.get_popup().visible, "Audit A01: Zpět zavře také skladovou nabídku bez odchodu ze skladu")
	game._change_screen(0)
	game._open_player_room()
	game._open_cosmetic_modal()
	var room = preload("res://scripts/ui/player_room_collection_view.gd")
	var artwork = preload("res://scripts/ui/workshop_room_view.gd").WorkshopBackground
	for id in ["sunrise", "lagoon", "amethyst", "research_study"]:
		var preview = game.cosmetic_theme_cards[id].preview
		host._check(preview.Artwork == artwork and preview.theme_id == id, "Audit A03: náhled %s používá aktuální malovanou dílnu a správný vzhled" % id)
		host._check(preview.Room._palette_for_theme(id).tint == room._palette_for_theme(id).tint, "Audit A03: náhled %s má stejný barevný tón jako skutečná místnost" % id)
	host._check(GameSession.ROOM_THEMES.lagoon.price == 35 and GameSession.ROOM_THEMES.amethyst.price == 55 and GameSession.ROOM_THEMES.research_study.research_completed_required == 6, "Audit A03: aktualizace náhledů zachovává ceny, ID a podmínky odemčení")
	surface.queue_free()
	await host.process_frame
