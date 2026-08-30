extends "res://.agents/skills/how-to-grow-validation/scripts/capture_validation.gd"
## Focused real-GPU evidence. The main full validation remains unchanged.

const Phase171Catalog := preload("res://scripts/plant_catalog_repository.gd")


func _capture() -> void:
	var packed := load("res://main.tscn") as PackedScene
	var instance = packed.instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	_prepare_common_state(instance)
	_prepare_room_state(instance)
	instance._change_screen(0)
	instance._open_rack_location()
	await _settle(instance)
	var saved := _save_full_viewport("phase171-rack-runtime.png")
	if not _prepare_phase125_post_harvest_rack_state(instance):
		quit(2)
		return
	await _settle(instance)
	saved = _save_full_viewport("phase171-rack-post-harvest.png") and saved
	var catalog := Phase171Catalog.new().load_catalog()
	var species: Array = catalog.keys()
	species.sort()
	instance.session.xp = 100000
	instance.session.paused = true
	var viewport := SubViewport.new()
	viewport.disable_3d = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var room := PlantRoomOverview.new()
	room.size = Vector2(432, 780)
	room.set_paused(true)
	room.set_reduced_motion(true)
	viewport.add_child(room)
	room.set_cosmetic_theme("sunrise")
	for compact in [false, true]:
		room.size = Vector2(360, 620) if compact else Vector2(432, 780)
		viewport.size = Vector2i(1080, 1860) if compact else Vector2i(1080, 1950)
		var density := 3.0 if compact else 2.5
		viewport.canvas_transform = Transform2D(0.0, Vector2.ZERO).scaled(Vector2.ONE * density)
		for fixture in range(3):
			for index in range(10):
				var plant: PlantSimulation = instance.session.plants[index]
				plant.reset()
				var species_id: String = str(species[index % species.size()]) if fixture == 0 else "basil_genovese"
				if fixture == 2:
					species_id = "lavandula_angustifolia" if index < 5 else str(species[-1])
				plant.configure_profile(catalog[species_id])
				_set_stage(plant, PlantSimulation.Stage.VEGETATIVE, 78.0, 100.0, 3.0)
				if fixture > 0:
					match index % 5:
						0: plant.stage = PlantSimulation.Stage.EMPTY
						1: _set_stage(plant, PlantSimulation.Stage.GERMINATING, 0.0, 100.0, 0.0)
						2: _set_stage(plant, PlantSimulation.Stage.VEGETATIVE, 48.0, 100.0, 2.0)
						3: plant.disease_level = 1
						4: plant.stage = PlantSimulation.Stage.HARVESTED if index < 5 else PlantSimulation.Stage.DEAD
			room.set_session(instance.session)
			room.animation_time = 0.0
			room.refresh()
			await process_frame
			await RenderingServer.frame_post_draw
			var image := viewport.get_texture().get_image()
			saved = image.get_size() == viewport.size and _save_image(image, "phase171-rack-native-%s-fixture-%d.png" % ["compact" if compact else "normal", fixture]) and saved
	viewport.queue_free()
	instance.queue_free()
	await process_frame
	await process_frame
	if not saved:
		quit(2)
		return
	print("PHASE171_RACK_CAPTURE=PASSED")
	call_deferred("_finish_capture_success")
