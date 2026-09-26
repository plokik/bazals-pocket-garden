extends "res://.agents/skills/how-to-grow-validation/scripts/capture_validation.gd"
## Mobile-layout snapshots of the replacement entry point and its confirmation.


func _capture() -> void:
	var packed := load("res://main.tscn") as PackedScene
	var instance = packed.instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	_prepare_common_state(instance)
	_prepare_detail_state(instance)
	instance.session.journey_completed = true
	instance.session.set_seed_count("mint_peppermint", 1)
	instance._refresh_ui()
	await _settle(instance)
	var saved := _save_full_viewport("replacement-detail.png")
	instance._open_replace_plant_selector()
	await _settle(instance)
	saved = _save_full_viewport("replacement-pick-seed.png") and saved
	instance._on_seed_species_selected("mint_peppermint")
	await _settle(instance)
	saved = _save_full_viewport("replacement-confirm.png") and saved
	instance.queue_free()
	await process_frame
	if not saved:
		quit(2)
		return
	print("PLANT_REPLACEMENT_CAPTURE=PASSED")
	call_deferred("_finish_capture_success")
