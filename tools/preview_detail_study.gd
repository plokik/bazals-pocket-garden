extends "res://tools/capture_phase172_detail.gd"
## Real Main scene, real presenters/actions/navigation, isolated generated garden.
## --verify runs GUI input checks and exits. Otherwise leave the game playable.

var checks := 0
var failed := false


func _capture() -> void:
	if not OS.get_environment("APPDATA").replace("\\", "/").contains("detail-study-appdata"):
		push_error("Preview requires isolated detail-study-appdata")
		quit(2)
		return
	root.title = "Bazal’s Pocket Garden · návrh detailu · testovací zahrada"
	var instance = load("res://main.tscn").instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	_prepare_common_state(instance)
	_prepare_detail_state(instance)
	var plant: PlantSimulation = instance.session.plant
	plant.stage = PlantSimulation.Stage.VEGETATIVE
	plant.growth_percent = 73.0
	plant.moisture = 48.0
	plant.ventilation = 22.0
	plant.disease_level = 0
	plant.disease_pressure = 0.0
	instance.session.fertilizer_doses = 2
	instance.session.coins = 30
	instance.session.speed_multiplier = 1.0
	instance._refresh_ui()
	await _settle(instance)
	# Let the ordinary HUD reward tween from fixture initialization complete.
	await create_timer(1.5).timeout
	_check(instance.plant_view.simulation == plant, "selected_live_simulation")
	_check(instance.plant_detail_panel.get_meta("detail_study", "") == "integrated_painted_game_v2", "presentation_adapter")
	_check(_save_full_viewport("detail-study-godot.png"), "capture")
	if not OS.get_cmdline_user_args().has("--verify"):
		instance.session.paused = false
		instance._refresh_ui()
		instance.plant_view.set_paused(false)
		instance.room_overview.set_paused(false)
		print("DETAIL_STUDY_PLAYABLE=READY")
		return
	for dimensions in [Vector2(432, 960), Vector2(360, 800)]:
		root.content_scale_size = Vector2i(dimensions)
		await process_frame
		instance._apply_safe_area_rect(Rect2(Vector2.ZERO, dimensions), dimensions, dimensions)
		await _settle(instance)
		for button: Button in [instance.water_button, instance.lamp_button, instance.fertilizer_button, instance.vent_button]:
			var rect := button.get_global_rect()
			_check(rect.size.x >= 44 and rect.size.y >= 64 and rect.position.x >= 0 and rect.end.x <= dimensions.x + 0.1 and rect.end.y <= dimensions.y, "action_touch_bounds_%s" % dimensions)
			var label: Label = button.get_meta("action_label")
			_check(button.get_global_rect().encloses(label.get_global_rect()), "action_label_inside_button")
		_check(_save_full_viewport("detail-study-%d.png" % dimensions.x), "responsive_capture")
	var before := plant.to_dict().duplicate(true)
	instance.plant_view.animation_time = 1.0
	var movement: float = instance.plant_view.canopy_offset(120.0, 640.0)
	_check(absf(movement) > 0.1, "canopy_moves")
	_check(is_zero_approx(instance.plant_view.canopy_offset(540.0, 640.0)), "pot_stays_anchored")
	instance.plant_view.set_reduced_motion(true)
	_check(is_zero_approx(instance.plant_view.canopy_offset(120.0, 640.0)), "reduced_motion_stops_canopy")
	instance.plant_view.set_reduced_motion(false)
	_check(before == plant.to_dict(), "animation_does_not_mutate_save")
	var moisture_before := plant.moisture
	await _click(instance.water_button)
	_check(plant.moisture > moisture_before and instance.plant_view.water_animation > 0, "water_real_action_and_feedback")
	var air_before := plant.ventilation
	await _click(instance.vent_button)
	_check(plant.ventilation > air_before and instance.plant_view.wind_animation > 0, "ventilation_real_action_and_feedback")
	var doses_before: int = instance.session.fertilizer_doses
	await _click(instance.fertilizer_button)
	_check(instance.session.fertilizer_doses == doses_before - 1, "fertilizer_real_inventory")
	var light_before := plant.lamp_on
	await _click(instance.lamp_button)
	_check(plant.lamp_on != light_before, "lamp_real_state")
	await _click(instance.herbarium_launcher_button)
	_check(instance.herbarium_open, "herbarium_navigation")
	instance._close_herbarium()
	await _click(instance.plant_detail_selector.get_child(1))
	_check(instance.session.plant != plant and instance.plant_view.simulation == instance.session.plant, "adjacent_plant_binding")
	await _click(instance.plant_detail_selector.get_child(0))
	_check(instance.plants_room_panel.visible and not instance.plant_detail_panel.visible, "back_to_real_rack")
	var catalog: Dictionary = load("res://scripts/plant_catalog_repository.gd").new().load_catalog()
	instance._open_plant_detail(2)
	for species in ["basil_genovese", "lavandula_angustifolia", "salvia_officinalis"]:
		plant.configure_profile(catalog[species])
		for stage in [PlantSimulation.Stage.EMPTY, PlantSimulation.Stage.VEGETATIVE, PlantSimulation.Stage.DEAD, PlantSimulation.Stage.DRYING]:
			plant.stage = stage
			if stage == PlantSimulation.Stage.EMPTY:
				plant.growth_percent = 0.0
				plant.health = 100.0
			instance._refresh_ui()
			await _settle(instance)
			_check(instance.plant_view.simulation == plant, "species_and_lifecycle_binding")
			var empty_hint := instance.seed_button.get_meta("empty_cycle_hint", null) as Label
			if stage == PlantSimulation.Stage.EMPTY:
				_check(empty_hint != null and empty_hint.visible and empty_hint.text == "Vyber semínko a založ nový cyklus", "empty_cycle_hint_combined")
				_check(not instance.growth_time_panel.visible and instance.seed_button.custom_minimum_size.y >= 140.0, "empty_cycle_two_bars_merged")
				_check(_save_full_viewport("detail-study-empty-seed.png"), "empty_cycle_capture")
			else:
				_check(empty_hint != null and not empty_hint.visible and instance.growth_time_panel.visible, "nonempty_growth_bar_restored")
	_check(_save_full_viewport("detail-study-lifecycle.png"), "lifecycle_capture")
	instance.queue_free()
	await process_frame
	print("DETAIL_STUDY_CHECKS=%d" % checks)
	if failed:
		quit(2)
	else:
		print("DETAIL_STUDY_INTEGRATION=PASSED")
		quit(0)


func _check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failed = true
		push_error("DETAIL_STUDY_FAILED=" + description)


func _click(button: Button) -> void:
	var position := button.get_global_rect().get_center()
	var motion := InputEventMouseMotion.new()
	motion.position = position
	root.push_input(motion, true)
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.position = position
	down.pressed = true
	root.push_input(down, true)
	await process_frame
	var up := InputEventMouseButton.new()
	up.button_index = MOUSE_BUTTON_LEFT
	up.position = position
	up.pressed = false
	root.push_input(up, true)
	await process_frame
	await create_timer(0.08).timeout
