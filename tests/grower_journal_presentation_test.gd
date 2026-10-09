extends RefCounted


static func run(host: SceneTree) -> void:
	var game = load("res://main.tscn").instantiate()
	host.root.add_child(game)
	await host.process_frame
	await host.process_frame
	game._skip_garden_handover()
	game._set_guide_modal_open(false, false)
	game._close_return_summary()
	game.session.paused = true
	game.session.journey_completed = true
	game.session.intro_completed = true
	game.session.harvest_count = 12
	game.session.orders_completed = 7
	game.session.xp = 540
	game._open_grower_journal()
	host._check(game.grower_journal_skill_tree.screen_presentation != null and game.grower_journal_skill_tree.nodes[0].screen_presentation == game.grower_journal_skill_tree.screen_presentation, "Deník: schválený vzhled je zapojený do běžného startu hry")
	var session_before: Dictionary = game.session.to_dict().duplicate(true)
	session_before.erase("saved_at_unix")
	var original_nodes: Array = game.grower_journal_skill_tree.nodes.duplicate()
	var textures: Dictionary = {}
	for id in game.grower_journal_cards:
		textures[id] = game.grower_journal_cards[id].icon.texture
	var skin = game.grower_journal_skill_tree.screen_presentation
	preload("res://scripts/ui/grower_journal_screen_presentation.gd").new().apply(game)
	game._refresh_grower_journal()
	var session_after: Dictionary = game.session.to_dict().duplicate(true)
	session_after.erase("saved_at_unix")
	host._check(session_before == session_after and original_nodes == game.grower_journal_skill_tree.nodes, "Deník: nový vzhled nemění úplný postup ani původní ovládací prvky")
	var original_art := true
	var live_values := true
	var selection_ok := true
	for badge: Dictionary in game.session.get_grower_journal_snapshot().badges:
		var card: Dictionary = game.grower_journal_cards[badge.id]
		original_art = original_art and card.icon.texture == textures[badge.id]
		var expected := "SPLNĚNO" if bool(badge.achieved) else "%d/%d" % [int(badge.current), int(badge.target)]
		live_values = live_values and card.value.text == expected and is_equal_approx(card.progress.value, snappedf(float(badge.progress) * 100, card.progress.step))
		card.panel.pressed.emit()
		selection_ok = selection_ok and game.grower_journal_presenter.selected_badge_id == badge.id and game.grower_journal_dashboard.goal_description_label.text == str(badge.description) and game.grower_journal_dashboard.goal_progress_label.text == expected
		for other: GrowerJournalSkillNode in original_nodes:
			selection_ok = selection_ok and other.selected == (other.badge_id == badge.id)
	host._check(original_art and live_values and selection_ok, "Deník: všech deset dovedností zachová obrázky, živý postup a právě jeden vybraný cíl")
	game.session.orders_completed = 10
	game._refresh_grower_journal()
	host._check(game.grower_journal_cards.trusted_supplier.value.text == "SPLNĚNO" and game.grower_journal_cards.trusted_supplier.panel.achieved, "Deník: nově splněná dovednost se obnoví ze skutečného postupu")
	game._select_grower_journal_badge("species_collection")
	var before_navigation: Dictionary = game.session.to_dict().duplicate(true)
	before_navigation.erase("saved_at_unix")
	game.grower_journal_target_button.pressed.emit()
	var after_navigation: Dictionary = game.session.to_dict().duplicate(true)
	after_navigation.erase("saved_at_unix")
	host._check(game.herbarium_open and not game.grower_journal_open and before_navigation == after_navigation, "Deník: Otevřít herbář zachovává původní cíl a nemění ekonomiku či postup")
	game._close_herbarium()
	game._open_grower_journal()
	preload("res://scripts/ui/grower_journal_screen_presentation.gd").new().apply(game)
	host._check(game.grower_journal_skill_tree.screen_presentation == skin and game.grower_journal_skill_tree.nodes.size() == 10 and game.grower_journal_scroll.get_meta("touch_drag_enabled", false), "Deník: opakované zapnutí neduplikuje dovednosti a zachovává posuv")
	skin.close_button.pressed.emit()
	host._check(not game.grower_journal_open and not game.grower_journal_modal.visible, "Deník: původní křížek zavře také nový náhled")
	game.queue_free()
	await host.process_frame
