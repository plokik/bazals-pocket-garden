extends "res://.agents/skills/how-to-grow-validation/scripts/capture_validation.gd"
## Real-GPU evidence for the responsive day and coin HUD labels.

const HUD_CASES := [
	{"id": "short", "day": 7, "coins": 42},
	{"id": "current", "day": 1305, "coins": 1234567},
	{"id": "long", "day": 1000000, "coins": 999999999},
]


func _capture() -> void:
	var instance = load("res://main.tscn").instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	_prepare_common_state(instance)
	var saved := true
	var all_fit := true
	for compact in [false, true]:
		var logical := Vector2(360, 800) if compact else Vector2(432, 960)
		root.content_scale_size = Vector2i(logical)
		await process_frame
		await process_frame
		instance._apply_safe_area_rect(Rect2(Vector2.ZERO, logical), logical, logical)
		for test_case in HUD_CASES:
			instance._set_day_display(int(test_case.day))
			instance._set_coin_count(float(test_case.coins))
			await process_frame
			await process_frame
			all_fit = _report_label("day", instance.day_label) and all_fit
			all_fit = _report_label("coins", instance.coins_label) and all_fit
			var image := _viewport_image()
			var suffix := "%s-%s" % ["compact" if compact else "normal", test_case.id]
			saved = _save_hud(image, "phase175-hud-%s.png" % suffix, logical.x) and saved
	instance.queue_free()
	await process_frame
	await process_frame
	if not saved or not all_fit:
		quit(2)
		return
	print("PHASE175_HUD_CAPTURE=PASSED")
	call_deferred("_finish_capture_success")


func _report_label(label_id: String, label: Label) -> bool:
	var font := label.get_theme_font("font")
	var font_size := label.get_theme_font_size("font_size")
	var text_width := font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
	var paint_width := text_width + float(label.get_theme_constant("outline_size") * 2 + absi(label.get_theme_constant("shadow_offset_x")))
	var available_width := label.size.x - 4.0
	var fits := paint_width <= available_width + 0.01
	print("PHASE175_HUD_METRIC=%s text=%s size=%.2f available=%.2f paint=%.2f font=%d fits=%s" % [label_id, label.text, label.size.x, available_width, paint_width, font_size, fits])
	return fits


func _save_hud(image: Image, filename: String, logical_width: float) -> bool:
	var height := clampi(roundi(float(image.get_width()) * HUD_LOGICAL_HEIGHT / logical_width), 1, image.get_height())
	return _save_image(image.get_region(Rect2i(0, 0, image.get_width(), height)), filename)
