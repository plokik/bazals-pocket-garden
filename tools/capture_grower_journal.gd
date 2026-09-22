extends "res://.agents/skills/how-to-grow-validation/scripts/capture_validation.gd"
## Focused GPU capture for the Grower Journal screen.


func _capture() -> void:
	var instance = load("res://main.tscn").instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	_prepare_common_state(instance)
	instance._prepare_grower_journal_capture()
	await _settle(instance)
	var saved := _save_full_viewport("grower-journal-skill-tree-top.png")
	instance.grower_journal_scroll.scroll_vertical = 9999
	instance.grower_journal_presenter.select_badge("research_partner")
	await process_frame
	await process_frame
	saved = _save_full_viewport("grower-journal-skill-tree-bottom.png") and saved
	instance.queue_free()
	await process_frame
	await process_frame
	if not saved:
		quit(2)
		return
	print("GROWER_JOURNAL_CAPTURE=PASSED")
	call_deferred("_finish_capture_success")
