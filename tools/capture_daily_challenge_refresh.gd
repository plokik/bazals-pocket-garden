extends "res://.agents/skills/how-to-grow-validation/scripts/capture_validation.gd"
## Focused visual QA for the refreshed daily-challenge panel.


func _capture() -> void:
	var packed := load("res://main.tscn") as PackedScene
	var instance = packed.instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	_prepare_common_state(instance)
	instance._prepare_daily_challenge_capture()
	var saved := true
	for state in ["active", "ready", "ready_queue_full", "claimed", "unavailable"]:
		_prepare_phase161_daily_challenge_state(instance, state)
		instance.botanical_pack_launcher_button.text = "BALÍČKY · %d" % instance.session.get_botanical_pack_count()
		await _settle(instance)
		saved = _save_full_viewport("daily-challenge-%s.png" % state) and saved
	instance._finish_daily_challenge_capture()
	instance.queue_free()
	await process_frame
	if not saved:
		quit(2)
		return
	print("DAILY_CHALLENGE_REFRESH_CAPTURE=PASSED")
	call_deferred("_finish_capture_success")
