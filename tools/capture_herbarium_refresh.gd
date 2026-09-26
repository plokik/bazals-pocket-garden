extends "res://.agents/skills/how-to-grow-validation/scripts/capture_validation.gd"
## Focused visual QA for the refreshed herbarium, including lower species cards.


func _capture() -> void:
	var packed := load("res://main.tscn") as PackedScene
	var instance = packed.instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	_prepare_common_state(instance)
	_prepare_phase12_herbarium_state(instance)
	await _settle(instance)
	var saved := _save_full_viewport("herbarium-overview.png")
	instance.herbarium_scroll.scroll_vertical = 1300
	await _settle(instance)
	saved = _save_full_viewport("herbarium-middle.png") and saved
	instance.herbarium_scroll.scroll_vertical = 4096
	await _settle(instance)
	saved = _save_full_viewport("herbarium-bottom.png") and saved
	instance.queue_free()
	await process_frame
	if not saved:
		quit(2)
		return
	print("HERBARIUM_REFRESH_CAPTURE=PASSED")
	call_deferred("_finish_capture_success")
