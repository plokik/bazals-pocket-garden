extends SceneTree

const OUTPUT_DIR := "res://.godot/startup-review"


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load("res://startup.tscn") as PackedScene
	if packed == null:
		push_error("STARTUP_LOADING=FAILED missing scene")
		quit(1)
		return
	var startup = packed.instantiate()
	root.add_child(startup)
	current_scene = startup
	await create_timer(0.12).timeout
	if not _save_frame("loading-start.png"):
		quit(1)
		return
	var early_progress: float = startup.progress_bar.value
	await create_timer(0.53).timeout
	if not _save_frame("loading-screen.png"):
		quit(1)
		return
	var waiting_progress: float = startup.progress_bar.value
	if early_progress <= 0.0 or waiting_progress <= early_progress or waiting_progress >= 95.0:
		push_error("STARTUP_LOADING=FAILED progress bar did not animate while waiting: %.1f -> %.1f" % [early_progress, waiting_progress])
		quit(1)
		return
	var deadline := Time.get_ticks_msec() + 8000
	while (current_scene == null or current_scene == startup) and Time.get_ticks_msec() < deadline:
		await create_timer(0.05).timeout
	var game = current_scene
	if game == null or game.name != "Main" or int(game.active_screen) != 0 or str(game.garden_location_id) != "player_room":
		push_error("STARTUP_LOADING=FAILED destination")
		quit(1)
		return
	if root.get_node_or_null("StartupCloudDissolve") == null:
		push_error("STARTUP_LOADING=FAILED cloud transition missing")
		quit(1)
		return
	await create_timer(0.35).timeout
	if not _save_frame("loading-dissolve.png"):
		quit(1)
		return
	await create_timer(0.8).timeout
	if root.get_node_or_null("StartupCloudDissolve") != null:
		push_error("STARTUP_LOADING=FAILED cloud transition not cleared")
		quit(1)
		return
	if not _save_frame("room-after-cloud.png"):
		quit(1)
		return
	print("STARTUP_LOADING=PASSED")
	print("STARTUP_CAPTURE=%s" % ProjectSettings.globalize_path(OUTPUT_DIR))
	quit(0)


func _save_frame(filename: String) -> bool:
	var output_path := ProjectSettings.globalize_path("%s/%s" % [OUTPUT_DIR, filename])
	DirAccess.make_dir_recursive_absolute(output_path.get_base_dir())
	if root.get_viewport().get_texture().get_image().save_png(output_path) == OK:
		return true
	push_error("STARTUP_LOADING=FAILED screenshot: %s" % filename)
	return false
