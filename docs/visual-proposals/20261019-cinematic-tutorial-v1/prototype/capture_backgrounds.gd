extends "res://.agents/skills/how-to-grow-validation/scripts/capture_validation.gd"
const OUT := "res://docs/visual-proposals/20261019-cinematic-tutorial-v1/assets/"
func _capture() -> void:
	if not OS.get_user_data_dir().replace(char(92),"/").contains("cinematic-tutorial-20261019"):
		push_error("Cinematic capture requires its isolated user-data directory")
		quit(2)
		return
	root.size = Vector2i(432,960)
	root.content_scale_size = Vector2i(432,960)
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
	_prepare_common_state(game)
	game.session.xp = 0
	game.session.guided_tutorial_enabled = false
	game.session.paused = true
	game.set_process(false)
	game._refresh_ui()
	game._open_rack_location()
	await _settle(game)
	await RenderingServer.frame_post_draw
	var err := root.get_texture().get_image().save_png(OUT+"background-rack.png")
	assert(err == OK)
	game._open_player_room()
	await _settle(game)
	await RenderingServer.frame_post_draw
	err = root.get_texture().get_image().save_png(OUT+"background-workshop.png")
	assert(err == OK)
	game.queue_free()
	await process_frame
	print("CINEMATIC_ISOLATED_BACKGROUNDS=PASSED")
	quit(0)
