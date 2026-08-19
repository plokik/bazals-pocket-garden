extends SceneTree


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var packed := load("res://main.tscn") as PackedScene
	var instance = packed.instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame

	# Approved starting state: only the first pot is available, slots 2-10 are locked.
	for plant in instance.session.plants:
		plant.reset()
	instance.session.xp = 0
	instance.session.select_plant(0)
	instance.room_overview.refresh()
	instance._refresh_ui()
	await process_frame
	await process_frame
	_save_viewport("res://docs/locked_slots_level1_actual.png")

	# A deterministic showcase state makes visual regressions easy to compare.
	instance.session.xp = 300
	instance.last_xp_seen = 300
	_set_stage(instance.session.plants[0], PlantSimulation.Stage.SPROUT, 18.0, 96.0)
	instance.session.plants[0].moisture = 31.0
	_set_stage(instance.session.plants[1], PlantSimulation.Stage.VEGETATIVE, 48.0, 82.0)
	instance.session.plants[1].lamp_on = true
	_set_stage(instance.session.plants[2], PlantSimulation.Stage.MATURE, 73.0, 91.0)
	_set_stage(instance.session.plants[3], PlantSimulation.Stage.MATURE, 100.0, 94.0)
	instance.session.plants[3].moisture = 31.0
	instance.room_overview.previous_unlocked_count = 4
	instance.session.select_plant(2)
	instance.room_overview.refresh()
	instance.room_overview.displayed_growth_percent = 73.0
	instance._refresh_ui()
	await process_frame
	await process_frame
	_save_viewport("res://docs/rack_room_v1_actual.png")
	_save_viewport("res://docs/mvp_preview_v3_room.png")

	instance._open_plant_detail(2)
	await process_frame
	await process_frame
	await create_timer(0.25).timeout
	instance.plant_detail_panel.modulate.a = 1.0
	await process_frame
	_save_viewport("res://docs/mvp_preview_v3_detail.png")
	quit(0)


func _set_stage(plant: PlantSimulation, stage: PlantSimulation.Stage, growth: float, health: float) -> void:
	plant.stage = stage
	plant.growth_percent = growth
	plant.health = health
	plant.moisture = 64.0
	plant.condition_score = health / 100.0


func _save_viewport(path: String) -> void:
	var image := root.get_viewport().get_texture().get_image()
	if image.get_size() != Vector2i(1080, 2400):
		image.resize(1080, 2400, Image.INTERPOLATE_LANCZOS)
	var error := image.save_png(ProjectSettings.globalize_path(path))
	if error != OK:
		push_error("Preview could not be saved: %s" % error_string(error))
