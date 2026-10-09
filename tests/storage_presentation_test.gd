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
	game._change_screen(1, false)
	host._check(game.storage_pipeline_presenter.screen_presentation != null and game.customer_orders_panel.screen_presentation == game.storage_pipeline_presenter.screen_presentation, "Sklad: schválená klidnější podoba se zapojí při běžném startu")
	var before: Dictionary = _data(game)
	var button: Button = game.storage_action_button
	var picker: OptionButton = game.storage_batch_picker
	var skin = game.storage_pipeline_presenter.screen_presentation
	preload("res://scripts/ui/storage_screen_presentation.gd").new().apply(game)
	host._check(before == _data(game) and button == game.storage_action_button and picker == game.storage_batch_picker, "Sklad: náhled zachová celý postup, původní akci i volbu sklizně")
	game.session.set_seed_count("basil_genovese", 8)
	game.session.fertilizer_doses = 12
	game.session.harvest_count = 17
	game._refresh_ui()
	host._check(game.inventory_value_labels.seeds.text == str(game.session.get_total_seed_count()) and game.inventory_value_labels.fertilizer.text == "12" and game.inventory_value_labels.harvests.text == "17", "Sklad: původní údaje zásob se nadále obnovují ze skutečné hry")
	var original = preload("res://scripts/ui/storage_pipeline_presenter.gd").new()
	var label := Label.new()
	var action := Button.new()
	var progress := ProgressBar.new()
	var steps: Array[Label] = []
	original.bind(label, action, progress, steps)
	var all_states_ok := true
	for stage in [PlantSimulation.Stage.EMPTY, PlantSimulation.Stage.MATURE, PlantSimulation.Stage.HARVESTED, PlantSimulation.Stage.DRYING, PlantSimulation.Stage.DRY, PlantSimulation.Stage.PACKAGED, PlantSimulation.Stage.DEAD]:
		game.session.plant.stage = stage
		game.session.plant.fresh_harvest_g = 32.0
		game.session.plant.dry_harvest_g = 5.4
		game.session.plant.drying_progress = 46.0
		game._update_storage_panel()
		original.refresh(game.session)
		all_states_ok = all_states_ok and label.text == game.harvest_label.text and action.text == button.text and action.disabled == button.disabled and is_equal_approx(progress.value, game.storage_progress_bar.value)
		var active_step := -1
		match stage:
			PlantSimulation.Stage.MATURE: active_step = 0
			PlantSimulation.Stage.HARVESTED, PlantSimulation.Stage.DRYING: active_step = 1
			PlantSimulation.Stage.DRY: active_step = 2
			PlantSimulation.Stage.PACKAGED: active_step = 3
		for index in range(4):
			var expected := "active" if index == active_step else ("complete" if index < active_step else "upcoming")
			all_states_ok = all_states_ok and skin.step_panels[index].get_meta("step_state") == expected
	host._check(all_states_ok, "Sklad: všech sedm stavů zachová texty, procenta a dostupnost akce a zvýrazní správný obrázkový krok")
	label.free()
	action.free()
	progress.free()
	game.session.select_plant(0)
	game.session.plant.reset()
	game.session.plant.stage = PlantSimulation.Stage.MATURE
	game.session.plant.growth_percent = 100.0
	game.session.plant.condition_score = 0.92
	var harvests_before: int = game.session.harvest_count
	game._on_storage_action()
	host._check(game.session.plant.stage == PlantSimulation.Stage.HARVESTED and game.session.harvest_count == harvests_before + 1, "Sklad: původní akce sklidí jednou a správně započítá sklizeň")
	game._on_storage_action()
	var first_batch: int = game.session.selected_plant_index
	host._check(first_batch >= GameSession.MAX_PLANT_SLOTS and game.session.plants[0].stage == PlantSimulation.Stage.EMPTY and game.session.plant.stage == PlantSimulation.Stage.DRYING and button.disabled, "Sklad: sušení nadále přesune úrodu do skladu a uvolní původní květináč")
	var second := PlantSimulation.new(game.plant_catalog.mint_peppermint)
	second.stage = PlantSimulation.Stage.DRY
	second.dry_harvest_g = 4.8
	second.harvest_quality = 0.91
	game.session.plants.append(second)
	game._refresh_ui()
	var target_item := -1
	for item in range(picker.item_count):
		if picker.get_item_id(item) == game.session.plants.size() - 1:
			target_item = item
	if target_item >= 0:
		picker.item_selected.emit(target_item)
	host._check(target_item >= 0 and picker.visible and game.session.plant == second and game.session.plants[first_batch].stage == PlantSimulation.Stage.DRYING, "Sklad: původní přepínač vybere konkrétní sklizeň bez změny souběžného sušení")
	game._on_storage_action()
	var packaged := second.stage == PlantSimulation.Stage.PACKAGED
	var coins_before: int = game.session.coins
	var sale_value: int = game.session.get_sale_value()
	game._on_storage_action()
	host._check(packaged and second.stage == PlantSimulation.Stage.EMPTY and game.session.coins == coins_before + sale_value, "Sklad: původní akce zabalí a prodá vybranou bylinku za nezměněnou cenu")
	game.session.select_plant(first_batch)
	game._refresh_ui()
	var drying_before: Dictionary = _data(game)
	game._on_storage_action()
	host._check(button.disabled and drying_before == _data(game), "Sklad: během sušení je akce nedostupná a neoprávněný pokus nezmění data")
	preload("res://scripts/ui/storage_screen_presentation.gd").new().apply(game)
	host._check(game.storage_pipeline_presenter.screen_presentation == skin and skin.step_panels.size() == 4 and game.storage_scroll.get_meta("touch_drag_enabled", false), "Sklad: opakované zapnutí nepřidává karty a zachovává dotykový posuv")
	var baseline := CustomerOrdersPanel.new()
	baseline.refresh(game.session)
	game.customer_orders_panel.refresh(game.session)
	var orders_match := true
	for index in range(baseline.card_panels.size()):
		orders_match = orders_match and baseline.customer_labels[index].text == game.customer_orders_panel.customer_labels[index].text and baseline.requirement_labels[index].text == game.customer_orders_panel.requirement_labels[index].text and baseline.reward_labels[index].text == game.customer_orders_panel.reward_labels[index].text and baseline.action_buttons[index].disabled == game.customer_orders_panel.action_buttons[index].disabled and baseline.decline_buttons[index].text == game.customer_orders_panel.decline_buttons[index].text and baseline.decline_buttons[index].disabled == game.customer_orders_panel.decline_buttons[index].disabled
	host._check(orders_match and game.customer_orders_panel.screen_presentation == skin, "Sklad: malovaná nástěnka zachovává všechny požadavky, odměny, dostupnost odevzdání i denní výměny")
	baseline.free()
	game.queue_free()
	await host.process_frame


static func _data(game: Control) -> Dictionary:
	var data: Dictionary = game.session.to_dict().duplicate(true)
	data.erase("saved_at_unix")
	return data
