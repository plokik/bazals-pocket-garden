extends "res://tests/test_runner.gd"
## The only entrypoint for this review. Never called from the production scene.
const OrderPanel := preload("order_panel.gd")
const NextStep := preload("next_step.gd")
const ReviewGoods := preload("res://scripts/workshop_products.gd")
const OUTPUT := "res://tmp/garden-teahouse-loop-v1"
var game: Control
var panel: Control
var serving := false
var served_view: Control
var events: Array[Dictionary] = []
var review_clock := 0.0
var automatic := true

func _process(delta: float) -> bool:
	review_clock += delta
	if serving and is_instance_valid(served_view) and served_view.model.phase == "result":
		served_view.next_button.text = "ZPĚT K DODÁVCE"
	return false

func _run_all() -> void:
	if not OS.get_user_data_dir().replace(char(92), "/").contains("garden-teahouse-loop-v1"):
		push_error("REVIEW_REFUSES_PLAYER_PROFILE")
		quit(2)
		return
	automatic = not "--interactive" in OS.get_cmdline_user_args()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	root.size = Vector2i(432, 960)
	root.content_scale_size = Vector2i(432, 960)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	root.title = "Bazal – návrh cesty do čajovny (oddělený profil)"
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await _frames(6)
	_finish_phase92_startup_for_test(game)
	game._close_save_recovery()
	game._close_return_summary()
	game._set_guide_modal_open(false, false)
	game.set_process(false)
	var session := GameSession.new(_load_plant_catalog())
	session.intro_completed = true
	session.journey_completed = true
	session.journey_reward_claimed = true
	session.guided_tutorial_enabled = false
	session.xp = 900
	session.coins = 100
	for i in range(4):
		var species: String = ["lavandula_angustifolia", "mint_peppermint", "melissa_officinalis", "rosemary_officinalis"][i]
		var plant := PlantSimulation.new(session.get_plant_profile(species))
		plant.plant_seed()
		plant.stage = PlantSimulation.Stage.MATURE
		plant.growth_percent = 100
		plant.health = 96
		plant.moisture = 65
		session.plants[i] = plant
	session.selected_plant_index = 0
	session.plant = session.plants[0]
	game._activate_session(session)
	_test_advice(session)
	var old: Control = game.workshop_modal.products_panel
	old.get_parent().remove_child(old)
	old.queue_free()
	panel = OrderPanel.new()
	panel.bind(game.workshop_modal)
	panel.serve_callback = _open_serving
	game.workshop_modal.products_panel = panel
	game.workshop_modal.add_child(panel)
	game._change_screen(0)
	game._open_player_room()
	game.audio_haptics.apply_settings(true, true, false, 0.45, 0.8)
	await _frames(8)
	game.workshop_modal.open_products()
	panel.show_quest()
	await _mark("01-order-offer")
	if "--edge-checks" in OS.get_cmdline_user_args():
		await _empty_cup_check()
		print("GARDEN_TEAHOUSE_EDGE_CHECKS=%d FAILURES=%d" % [checks, failures])
		quit(1 if failures else 0)
		return
	if "--layout-only" in OS.get_cmdline_user_args():
		await _layout_checks()
		print("GARDEN_TEAHOUSE_LAYOUT_CHECKS=%d FAILURES=%d" % [checks, failures])
		quit(1 if failures else 0)
		return
	if not automatic:
		# The playable review starts with dried herbs so approval need not wait
		# through real hours. This is an isolated fixture, never a player option.
		for index in range(4):
			session.select_plant(index)
			session.harvest()
			session.start_drying()
		var dry_seconds := 0.0
		for batch in session.plants:
			if batch.stage == PlantSimulation.Stage.DRYING: dry_seconds = maxf(dry_seconds, batch.get_drying_target_seconds())
		session.advance_offline(dry_seconds+2)
		game._refresh_ui()
		game.set_process(true)
		return
	await _demo()

func _open_serving() -> void:
	if not game.teahouse_modal.open(): return
	serving = true
	served_view = game.teahouse_modal.view
	for connection in served_view.next_button.pressed.get_connections():
		served_view.next_button.pressed.disconnect(connection.callable)
	served_view.next_button.pressed.connect(_return_from_serving)

func _return_from_serving() -> void:
	if not serving or not is_instance_valid(served_view): return
	if served_view.model.phase != "result": return
	panel.served = float(served_view.pour_result.get("fill", 0)) > 0
	serving = false
	game.teahouse_modal.close()
	served_view = null
	panel.show_quest()

func _frames(count: int) -> void:
	for i in range(count): await process_frame

func _wait(seconds: float) -> void:
	await _frames(ceili(seconds*30))

func _tap(control: Control) -> void:
	if control.get_parent() is VBoxContainer and panel.visible:
		panel.scroll.ensure_control_visible(control)
	await _frames(3)
	var point := control.get_global_rect().get_center()
	for pressed in [true, false]:
		var input := InputEventMouseButton.new()
		input.position = point
		input.global_position = point
		input.button_index = MOUSE_BUTTON_LEFT
		input.pressed = pressed
		input.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
		root.push_input(input)
		await _frames(2)
	await _frames(5)

func _mark(label: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUTPUT.path_join(label+".png"))
	events.append({"time":review_clock, "label":label, "coins":game.session.coins, "goods":game.session.workshop_products.to_dict()})

func _demo() -> void:
	await _wait(2)
	await _tap(panel.action)
	_check(game.session.workshop_products.quest == "active", "Návrh: zakázka přijata skutečným tlačítkem")
	await _mark("02-next-harvest")
	await _wait(2)
	game.workshop_modal.close()
	game._change_screen(0)
	game._open_plant_detail(1)
	await _wait(1)
	var moisture: float = game.session.plant.moisture
	await _tap(game.water_button)
	_check(game.session.plant.moisture > moisture, "Návrh: běžná péče zalije vlastní rostlinu")
	await _mark("02b-plant-care")
	await _wait(3)
	# Four already mature plants are QA fixtures. Harvesting uses the real UI.
	for index in range(4):
		game.workshop_modal.close()
		game.session.select_plant(index)
		game._change_screen(1)
		game._refresh_ui()
		await _frames(4)
		game.storage_scroll.ensure_control_visible(game.storage_action_button)
		await _wait(0.4)
		await _tap(game.storage_action_button)
		_check(game.session.plant.stage == PlantSimulation.Stage.HARVESTED, "Návrh: skutečná sklizeň byliny %d" % index)
		await _wait(0.5)
		await _tap(game.storage_action_button)
		_check(game.session.plant.stage == PlantSimulation.Stage.DRYING, "Návrh: skutečný začátek sušení %d" % index)
		_check(game.session.plants[index].stage == PlantSimulation.Stage.EMPTY, "Návrh: sklizeň uvolňuje květináč")
	await _mark("03-drying")
	await _wait(2)
	# Explicit time cut: the same offline simulation used on normal return.
	var elapsed := 0.0
	for batch in game.session.plants:
		if batch.stage == PlantSimulation.Stage.DRYING: elapsed = maxf(elapsed, batch.get_drying_target_seconds())
	game.session.advance_offline(elapsed+2)
	game._refresh_ui()
	events.append({"time":review_clock,"time_cut_offline_seconds":elapsed+2})
	await _mark("04-dry-herbs-after-time-cut")
	await _wait(1.5)
	game._change_screen(0)
	game._open_player_room()
	game.workshop_modal.open_products()
	panel.show_quest()
	await _frames(4)
	_check(NextStep.resolve(game.session).kind == "craft", "Návrh: další krok pozná připravené suché byliny")
	await _mark("05-next-craft")
	await _wait(2)
	for id in ReviewGoods.ORDER:
		await _tap(panel.action)
		_check(panel.page == "products" and panel.selected == id, "Návrh: přímý odkaz na chybějící výrobek " + id)
		await _wait(0.5)
		await _tap(panel.action)
		await _wait(2.0)
		_check(game.session.workshop_products.count(id) == 1, "Návrh: vyroben skutečný kus " + id)
		await _mark("06-crafted-"+id)
		await _tap(panel.order_button)
		await _wait(0.5)
	_check(NextStep.resolve(game.session).kind == "serve", "Návrh: tři výrobky směřují k obsluze hosta")
	await _mark("07-next-serve")
	await _wait(2)
	var before := _snapshot()
	await _tap(panel.action)
	_check(game.teahouse_open, "Návrh: obsluha otevře skutečnou schválenou minihru")
	game.teahouse_modal.close()
	_check(not panel.served and NextStep.resolve(game.session).kind == "serve" and before == _snapshot(), "Návrh: zavření rozehrané obsluhy neudělí odměnu ani nenahradí dokončení")
	await _tap(panel.action)
	await _wait(1)
	await _mark("08-teahouse-matching")
	var view: Control = game.teahouse_modal.view
	for turn in range(18):
		if view.model.phase != "matching": break
		var path: Array[int] = view.find_needed_chain()
		_check(path.size() >= 3, "Návrh: legální potřebný řetězec")
		if path.size() < 3: break
		await _chain(view, path)
		await _wait(0.95)
	_check(view.model.phase == "pouring", "Návrh: skutečné tahy dokončí recept")
	await _mark("09-pour")
	await _wait(1)
	var point: Vector2 = view.pour_button.get_global_rect().get_center()
	_mouse_at(point, true)
	var limit := 180
	while view.fill < 0.72 and limit > 0:
		await process_frame
		limit -= 1
	_mouse_at(point, false)
	await _wait(2)
	_check(view.model.phase == "result" and view.pour_result.quality == "perfect", "Návrh: skutečné držení nalije úspěšný šálek")
	_check(before == _snapshot(), "Návrh: samotné hraní neodečte další zásoby ani nepřidá odměnu")
	await _mark("10-served")
	await _tap(view.next_button)
	_check(panel.served and NextStep.resolve(game.session, true).kind == "deliver", "Návrh: po obsluze lze předat dodávku")
	await _mark("11-next-delivery")
	await _wait(2)
	var coins: int = game.session.coins
	var seeds: int = game.session.get_seed_count(ReviewGoods.REWARD_SPECIES)
	await _tap(panel.action)
	_check(game.session.workshop_products.quest == "completed" and game.session.coins == coins+80 and game.session.get_seed_count(ReviewGoods.REWARD_SPECIES) == seeds+2, "Návrh: původní odměna předána jednou")
	_check(not game.session.workshop_products.deliver(game.session).ok, "Návrh: nelze převzít odměnu podruhé")
	await _mark("12-reward")
	await _wait(3)
	var data: Dictionary = game.session.to_dict()
	var restored := GameSession.new(_load_plant_catalog())
	restored.from_dict(data)
	_check(restored.workshop_products.quest == "completed" and restored.coins == game.session.coins, "Návrh: výsledek existující dodávky přežije načtení")
	var output := FileAccess.open(OUTPUT.path_join("verification.json"), FileAccess.WRITE)
	output.store_string(JSON.stringify({"checks":checks,"failures":failures,"events":events,"duration":review_clock,"production_files_changed":false,"new_serving_flag_persisted":false}, "\t"))
	print("GARDEN_TEAHOUSE_REVIEW_CHECKS=%d FAILURES=%d" % [checks, failures])
	quit(1 if failures else 0)

func _test_advice(session: GameSession) -> void:
	var before: Dictionary = session.to_dict()
	before.erase("saved_at_unix")
	var probe := GameSession.new(_load_plant_catalog())
	probe.from_dict(session.to_dict())
	_check(NextStep.resolve(probe).kind == "accept", "Návrh: dostupná dodávka nabídne přijetí")
	probe.workshop_products.quest = "active"
	_check(NextStep.resolve(probe).kind == "harvest", "Návrh: vlastní zralá bylinka nabídne sklizeň")
	probe.select_plant(0)
	probe.plant.stage = PlantSimulation.Stage.VEGETATIVE
	_check(NextStep.resolve(probe).kind == "grow", "Návrh: mladá rostlina vede k péči")
	probe.plant.reset()
	_check(NextStep.resolve(probe).kind == "plant", "Návrh: chybějící bylinka vede k nové výsadbě")
	probe.plant.plant_seed()
	probe.plant.stage = PlantSimulation.Stage.MATURE
	probe.plant.growth_percent = 100
	_check(probe.harvest() and NextStep.resolve(probe).kind == "start_drying", "Návrh: čerstvá sklizeň vede k sušení")
	_check(probe.start_drying() and NextStep.resolve(probe).kind == "drying" and NextStep.resolve(probe).index >= GameSession.MAX_PLANT_SLOTS, "Návrh: sušení nalezne skutečnou šarži ve skladu")
	probe.plant.stage = PlantSimulation.Stage.DRY
	probe.plant.dry_harvest_g = 4
	_check(NextStep.resolve(probe).kind == "craft", "Návrh: dostatek sušené byliny vede k výrobě")
	probe.coins = 0
	_check(NextStep.resolve(probe).kind == "blocked", "Návrh: skutečný nedostatek mincí zachová blokaci")
	var after: Dictionary = session.to_dict()
	after.erase("saved_at_unix")
	_check(before == after, "Návrh: výpočet dalšího kroku nemění původní herní relaci")

func _layout_checks() -> void:
	for dimensions in [Vector2i(432, 960), Vector2i(360, 800), Vector2i(360, 640), Vector2i(600, 900)]:
		root.size = dimensions
		root.content_scale_size = dimensions
		await _frames(6)
		game._apply_safe_area_rect(Rect2(Vector2.ZERO, Vector2(dimensions)), Vector2(dimensions), Vector2(dimensions))
		panel.show_quest()
		await _frames(6)
		panel.scroll.ensure_control_visible(panel.action)
		await _frames(5)
		var bounds := Rect2(Vector2.ZERO, Vector2(dimensions))
		for item in [panel.action, panel.products_button, panel.order_button, panel.back_button]:
			_check(bounds.grow(1).encloses(item.get_global_rect()), "Návrh: ovládání dostupné na %s" % dimensions)
		await _mark("layout-%dx%d" % [dimensions.x, dimensions.y])

func _empty_cup_check() -> void:
	game.session.workshop_products.quest = "active"
	for id in ReviewGoods.ORDER: game.session.workshop_products.products[id] = 1
	panel.show_quest()
	await _frames(4)
	var before := _snapshot()
	await _tap(panel.action)
	_check(game.teahouse_open, "Návrh: okrajová kontrola otevře obsluhu")
	var view: Control = game.teahouse_modal.view
	# A result-screen fixture isolates the callback for an empty cup. The main
	# movie above completes the actual board and pour without this fixture.
	view.model.phase = "result"
	view.displayed_phase = "result"
	view.pour_result = {"fill":0.0, "quality":"empty"}
	view._sync_buttons()
	await _frames(3)
	await _tap(view.next_button)
	_check(not game.teahouse_open, "Návrh: i prázdný šálek dovolí návrat z výsledku")
	_check(not panel.served and NextStep.resolve(game.session).kind == "serve" and before == _snapshot(), "Návrh: prázdný šálek neoznačí hosta za obslouženého a nesáhne na zásoby")

func _snapshot() -> Dictionary:
	return {"coins":game.session.coins,"goods":game.session.workshop_products.to_dict(),"seeds":game.session.seed_inventory.duplicate(true)}

func _mouse_at(point: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.position = point
	event.global_position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	event.pressed = pressed
	root.push_input(event)

func _chain(view: Control, path: Array[int]) -> void:
	for i in range(path.size()):
		var point: Vector2 = view.get_global_transform_with_canvas()*(view.origin+view._center(path[i])*view.zoom)
		if i == 0: _mouse_at(point, true)
		else:
			var motion := InputEventMouseMotion.new()
			motion.position = point
			motion.global_position = point
			motion.button_mask = MOUSE_BUTTON_MASK_LEFT
			root.push_input(motion)
		await _frames(4)
	var last: Vector2 = view.get_global_transform_with_canvas()*(view.origin+view._center(path[-1])*view.zoom)
	_mouse_at(last, false)
