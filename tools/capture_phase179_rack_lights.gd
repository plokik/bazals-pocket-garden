extends "res://.agents/skills/how-to-grow-validation/scripts/capture_validation.gd"
## Deterministic real-GPU evidence for ten independent animated rack lights.

const Phase179Catalog := preload("res://scripts/plant_catalog_repository.gd")
const PHASE179_SPECIES := [
	"basil_genovese",
	"mint_peppermint",
	"rosemary_officinalis",
	"oregano_vulgare",
	"lavandula_angustifolia",
	"allium_schoenoprasum",
	"origanum_majorana",
	"petroselinum_crispum",
	"melissa_officinalis",
	"salvia_officinalis",
]
const ACTIVE_LIGHTS := [0, 2, 4, 6, 8]
const OFF_TRANSITION_LIGHTS := [0, 2, 4, 5, 7, 9]


func _capture() -> void:
	var instance = load("res://main.tscn").instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	_prepare_common_state(instance)
	if not _prepare_phase179_rack_state(instance):
		quit(2)
		return
	var saved := true
	var states_valid := true
	for compact in [false, true]:
		var logical := Vector2(360, 800) if compact else Vector2(432, 960)
		root.content_scale_size = Vector2i(logical)
		await process_frame
		await process_frame
		instance._apply_safe_area_rect(Rect2(Vector2.ZERO, logical), logical, logical)
		instance._change_screen(0)
		instance._open_rack_location()
		await _settle(instance)
		var room: PlantRoomOverview = instance.room_overview
		room.set_process(false)
		room.animation_time = 0.0
		for state_id in ["off", "alternating", "transition", "transition-off"]:
			_prepare_light_state(instance, state_id)
			states_valid = _validate_light_state(instance, state_id) and states_valid
			room.queue_redraw()
			await process_frame
			await RenderingServer.frame_post_draw
			var image := _viewport_image()
			var layout := "compact" if compact else "normal"
			var stem := "phase179-rack-lights-%s-%s" % [layout, state_id]
			saved = _save_image(image, "%s.png" % stem) and saved
			var crop := _room_crop_rect(room, image, logical)
			if crop.has_area():
				saved = _save_image(image.get_region(crop), "%s-crop.png" % stem) and saved
			else:
				saved = false
	instance.queue_free()
	await process_frame
	await process_frame
	if not saved or not states_valid:
		quit(2)
		return
	print("PHASE179_INDEPENDENT_LIGHT_STATES=PASSED")
	print("PHASE179_CONCURRENT_LIGHT_ANIMATION=PASSED")
	print("PHASE181_RACK_LIGHT_OFF_ANCHORS=PASSED")
	print("PHASE179_RACK_LIGHTS_CAPTURE=PASSED")
	call_deferred("_finish_capture_success")


func _prepare_phase179_rack_state(instance) -> bool:
	var catalog: Dictionary = Phase179Catalog.new().load_catalog()
	instance.session.xp = 100000
	instance.session.paused = true
	instance.session.world_elapsed_seconds = 0.0
	for index in range(GameSession.MAX_PLANT_SLOTS):
		var species_id: String = PHASE179_SPECIES[index]
		var profile: Dictionary = catalog.get(species_id, {})
		if profile.is_empty():
			push_error("PHASE179_MISSING_SPECIES=%s" % species_id)
			return false
		var plant: PlantSimulation = instance.session.plants[index]
		plant.reset()
		plant.configure_profile(profile)
		_set_stage(plant, PlantSimulation.Stage.VEGETATIVE, 68.0 + float(index % 5) * 3.0, 94.0, 3.0)
		plant.lamp_on = false
		plant.sync_environment(instance.session.world_elapsed_seconds)
	instance.session.select_plant(0)
	instance.room_overview.set_session(instance.session)
	instance.room_overview.set_cosmetic_theme("sunrise")
	instance.room_overview.set_reduced_motion(false)
	instance.room_overview.set_paused(true)
	instance.room_overview.refresh()
	return instance.session.get_unlocked_slot_count() == GameSession.MAX_PLANT_SLOTS


func _prepare_light_state(instance, state_id: String) -> void:
	var room: PlantRoomOverview = instance.room_overview
	room._ensure_light_animation_state()
	for index in range(GameSession.MAX_PLANT_SLOTS):
		instance.session.plants[index].lamp_on = false
		room.light_transition_elapsed[index] = -1.0
		room.light_transition_targets[index] = false
		room.light_transition_from_strength[index] = 0.0
		room.light_denied_elapsed[index] = -1.0
	if state_id == "alternating":
		for index in ACTIVE_LIGHTS:
			instance.session.plants[index].lamp_on = true
			room.light_transition_targets[index] = true
			room.light_transition_from_strength[index] = 1.0
	elif state_id == "transition":
		for index in ACTIVE_LIGHTS:
			instance.session.plants[index].lamp_on = true
			room.play_light_toggle(index, true)
			room.light_transition_elapsed[index] = PlantRoomOverview.LIGHT_TOGGLE_DURATION * 0.42
	elif state_id == "transition-off":
		for index in OFF_TRANSITION_LIGHTS:
			instance.session.plants[index].lamp_on = false
			room.light_transition_targets[index] = false
			room.light_transition_from_strength[index] = 1.0
			room.light_transition_elapsed[index] = PlantRoomOverview.LIGHT_TOGGLE_OFF_DURATION * 0.50


func _validate_light_state(instance, state_id: String) -> bool:
	var room: PlantRoomOverview = instance.room_overview
	var valid := true
	for index in range(GameSession.MAX_PLANT_SLOTS):
		var expected_on := state_id in ["alternating", "transition"] and index in ACTIVE_LIGHTS
		valid = valid and instance.session.plants[index].lamp_on == expected_on
		var strength := room._light_transition_strength(index, expected_on)
		if state_id == "transition" and expected_on:
			valid = valid and strength > 0.0 and strength < 1.0 and room._light_transition_pulse(index) > 0.0
		elif state_id == "transition-off" and index in OFF_TRANSITION_LIGHTS:
			var expected_center := room._active_light_lens_rect(room._light_fixture_rect(int(index / 5), index % 5)).get_center()
			valid = valid and strength > 0.0 and strength < 1.0 and room._light_transition_pulse(index) > 0.0 \
				and room._light_effect_center(index).distance_to(expected_center) <= 0.002
		else:
			valid = valid and is_equal_approx(strength, 1.0 if expected_on else 0.0)
	if not valid:
		push_error("PHASE179_INVALID_CAPTURE_STATE=%s" % state_id)
	return valid


func _room_crop_rect(room: PlantRoomOverview, image: Image, logical: Vector2) -> Rect2i:
	var scale := Vector2(image.get_size()) / logical
	var logical_rect := Rect2(room.global_position, room.size)
	var crop_position := Vector2i(
		floori(logical_rect.position.x * scale.x),
		floori(logical_rect.position.y * scale.y)
	)
	var crop_end := Vector2i(
		ceili(logical_rect.end.x * scale.x),
		ceili(logical_rect.end.y * scale.y)
	)
	return Rect2i(crop_position, crop_end - crop_position).intersection(Rect2i(Vector2i.ZERO, image.get_size()))
