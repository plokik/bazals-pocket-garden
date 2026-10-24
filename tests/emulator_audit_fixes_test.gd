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
	await _check_palette_lifecycle(host, game)
	surface.queue_free()
	await host.process_frame


static func _check_palette_lifecycle(host: SceneTree, game: Control) -> void:
	const Palette := preload("res://scripts/ui/sage_ui_palette.gd")
	const ComicUITheme := preload("res://scripts/ui/comic_ui.gd")
	var palette: Node
	for child: Node in game.get_children():
		if child.get_script() == Palette:
			palette = child
			break
	host._check(palette != null, "Paleta lifecycle: skutečná hra má nainstalovaný posluchač dynamických prvků")
	if palette == null:
		return
	var cards := Control.new()
	game.add_child(cards)
	var surviving := Button.new()
	surviving.text = "ŽIVÁ AKCE"
	# Match customer_orders_panel's real bright action before palette conversion.
	# An unstyled Button inherits INK, which the palette intentionally preserves.
	ComicUITheme.apply_button(surviving, ComicUITheme.GREEN, ComicUITheme.CREAM, 13)
	surviving.set_meta("component", "customer_order_action_v1")
	cards.add_child(surviving)
	var dark_text := Button.new()
	dark_text.text = "TMAVÝ TEXT"
	ComicUITheme.apply_button(dark_text, ComicUITheme.GREEN, ComicUITheme.INK, 13)
	cards.add_child(dark_text)
	var custom_styled := Button.new()
	var original_material := CanvasItemMaterial.new()
	custom_styled.material = original_material
	cards.add_child(custom_styled)
	var detached: Array[Button] = []
	var removed_ids: Array[int] = []
	for index in range(12):
		var ephemeral := Button.new()
		cards.add_child(ephemeral)
		removed_ids.append(ephemeral.get_instance_id())
		ephemeral.free()
		var queued := Label.new()
		cards.add_child(queued)
		removed_ids.append(queued.get_instance_id())
		queued.queue_free()
		var moved := Button.new()
		cards.add_child(moved)
		cards.remove_child(moved)
		detached.append(moved)
	await host.process_frame
	await host.process_frame
	var detached_untouched := true
	for button: Button in detached:
		detached_untouched = detached_untouched and button.material == null
		button.free()
	host._check(removed_ids.all(func(id: int) -> bool: return not is_instance_id_valid(id)) and detached_untouched, "Paleta lifecycle: odložené stylování bezpečně přeskočí uvolněné i odpojené karty")
	host._check(surviving.material is ShaderMaterial and surviving.get_meta("sage_palette_role", "") == "primary" and surviving.material.get_shader_parameter("primary_action") == true and surviving.get_theme_color("font_color") == Palette.FOREST, "Paleta lifecycle: přeživší dynamická akce zachová původní shader, roli a čitelnou barvu")
	host._check(dark_text.material is ShaderMaterial and dark_text.get_theme_color("font_color") == ComicUITheme.INK, "Paleta lifecycle: existující tmavý text dynamického tlačítka se nepřebarví")
	host._check(custom_styled.material == original_material, "Paleta lifecycle: vlastní materiál prvku zůstane nedotčený")
	var heading := Label.new()
	heading.text = "NADPIS"
	heading.set_meta("sage_readable_heading", true)
	heading.add_theme_color_override("font_color", ComicUITheme.CREAM)
	cards.add_child(heading)
	await host.process_frame
	await host.process_frame
	# A live theme refresh must still reach both new instance-ID adapters.
	ComicUITheme.apply_button(surviving, ComicUITheme.GREEN, ComicUITheme.CREAM, 13)
	heading.add_theme_color_override("font_color", ComicUITheme.CREAM)
	await host.process_frame
	await host.process_frame
	host._check(surviving.get_theme_color("font_color") == Palette.FOREST and heading.get_theme_color("font_color") == Palette.FOREST, "Paleta lifecycle: živé theme callbacky tlačítka i nadpisu stále obnovují čitelné barvy")
	# Dispatch both deferred theme listeners, then rebuild before they run.
	surviving.theme_changed.emit()
	heading.theme_changed.emit()
	surviving.free()
	heading.free()
	await host.process_frame
	await host.process_frame
	var replacement := Button.new()
	replacement.text = "NOVÁ KARTA"
	ComicUITheme.apply_button(replacement, ComicUITheme.GREEN, ComicUITheme.CREAM, 13)
	cards.add_child(replacement)
	await host.process_frame
	await host.process_frame
	host._check(replacement.material is ShaderMaterial and replacement.get_theme_color("font_color") == Palette.FOREST, "Paleta lifecycle: stylování funguje i po zrušení odložených theme callbacků tlačítka a popisku")
	cards.queue_free()
	await host.process_frame
