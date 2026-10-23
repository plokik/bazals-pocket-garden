extends "res://.agents/skills/how-to-grow-validation/scripts/capture_validation.gd"
const Preview := preload("res://docs/visual-proposals/20261017-teahouse-products-v1/prototype/preview.gd")
func _init() -> void: call_deferred("launch")
func launch() -> void:
	DisplayServer.window_set_title("Bazal — výrobky a čajovna · oddělený návrh")
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	await process_frame
	_prepare_common_state(game)
	game.set_process(false)
	game.session.paused = true
	game.garden_cat_companion.set_process(false)
	game._open_player_room()
	game._refresh_ui()
	var view := Preview.new()
	root.add_child(view)
	view.back_button.text = "ZAVŘÍT NÁVRH"
	view.back_button.pressed.connect(func(): quit())
