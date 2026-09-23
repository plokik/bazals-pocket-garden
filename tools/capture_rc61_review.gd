extends SceneTree

const OUTPUT_DIR := "res://.godot/rc61-review"


func _init() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var instance = (load("res://main.tscn") as PackedScene).instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))

	instance.session.xp = 600
	instance.session.journey_completed = true
	instance.session.harvest_count = 25
	instance.session.orders_completed = 10
	instance.session.unlocked_room_themes.assign(GameSession.CORE_ROOM_THEME_IDS)
	for equipment_id in GameSession.EQUIPMENT_ORDER:
		instance.session.equipment_levels[equipment_id] = GameSession.EQUIPMENT_MAX_LEVEL
	for species_id in instance.session.get_available_species():
		var progress: Dictionary = instance.session.get_species_progress(species_id)
		progress["discovered"] = true
		progress["best_quality"] = 0.90
		instance.session.species_progress[species_id] = progress
	instance._change_screen(0)
	instance._open_player_room()
	instance._refresh_ui()
	await process_frame
	await process_frame
	_save("room-earned-badges.png")

	var fresh_session := GameSession.new(instance.plant_catalog)
	fresh_session.intro_completed = true
	fresh_session.paused = true
	instance._activate_session(fresh_session)
	instance._open_rack_location()
	instance._refresh_ui()
	instance._show_dialog(instance.session.get_journey_dialog_text())
	instance._set_guide_modal_open(true, false)
	await process_frame
	await process_frame
	instance._close_return_summary()
	_save("first-step-guide.png")
	instance._set_guide_modal_open(false, false)
	instance._open_grower_journal()
	await process_frame
	await process_frame
	_save("journal-goal-navigation.png")
	quit(0)


func _save(filename: String) -> void:
	var image := root.get_viewport().get_texture().get_image()
	var path := ProjectSettings.globalize_path("%s/%s" % [OUTPUT_DIR, filename])
	if image.save_png(path) != OK:
		push_error("RC61 review capture failed: %s" % path)
