extends RefCounted
## Real controls and routed input. No gameplay/saves or simulated ScreenDrag claim.
const View := preload("res://scripts/ui/greenhouse_preview_view.gd")
const Simulation := preload("res://scripts/greenhouse_simulation.gd")
const BoldFont := preload("res://assets/fonts/Poppins-ExtraBold.ttf")


static func _frames(tree: SceneTree, count := 4) -> void:
	for i in count: await tree.process_frame


static func _rect(node: Control) -> Rect2:
	return node.get_global_transform_with_canvas() * Rect2(Vector2.ZERO, node.size)


static func _touch(viewport: SubViewport, point: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.position = point
	event.index = 0
	event.pressed = pressed
	viewport.push_input(event, true)


static func _tap(tree: SceneTree, viewport: SubViewport, button: Control) -> void:
	var point := _rect(button).get_center()
	_touch(viewport, point, true)
	await _frames(tree, 1)
	_touch(viewport, point, false)
	await _frames(tree)


static func _wheel(tree: SceneTree, viewport: SubViewport, point: Vector2) -> void:
	for i in 4:
		var event := InputEventMouseButton.new()
		event.position = point
		event.global_position = point
		event.shift_pressed = true
		event.button_index = MOUSE_BUTTON_WHEEL_DOWN
		event.pressed = true
		viewport.push_input(event, true)
		event = event.duplicate()
		event.pressed = false
		viewport.push_input(event, true)
		await _frames(tree, 1)
	await _frames(tree)


static func run(tree: SceneTree, check: Callable) -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(432, 700)
	viewport.handle_input_locally = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	tree.root.add_child(viewport)
	var view := View.new()
	view.size = Vector2(432, 700)
	viewport.add_child(view)
	view.set_process(false)
	var states: Array[Dictionary] = []
	for i in 4: states.append({"stage":"empty", "stage_name":"VOLNÝ", "crop":{}, "action":"none", "can_action":false})
	var catalog: Dictionary = Simulation.CROP_CATALOG.duplicate(true)
	var emitted: Array[Dictionary] = []
	view.crop_plant_requested.connect(func(bed: int, crop: String): emitted.append({"bed":bed,"crop":crop}))
	for width in [320, 334, 360, 406, 432, 600]:
		viewport.size = Vector2i(width, 700)
		view.size = Vector2(width, 700)
		view.selected_bed_index = 2
		view.set_greenhouse_state(states, catalog, 9999, 900)
		await _frames(tree, 7)
		var label := "Skleníkové osivo %d" % width
		var bounds := Rect2(Vector2.ZERO, view.size)
		var scroll_rect := _rect(view.crop_scroll)
		check.call(view.crop_scroll.visible and view.crop_scroll.clip_contents and bounds.encloses(scroll_rect), label+": celá ořezová oblast voliče je uvnitř obrazovky")
		check.call(scroll_rect.position.y >= view._status_rect().end.y + 9.9 and scroll_rect.end.y <= view.size.y - 13.9, label+": volič nezasahuje do statusu ani pod dolní okraj")
		var text_fits := true
		var large_targets := true
		for button in view.crop_buttons:
			var font_size := button.get_theme_font_size("font_size")
			var style := button.get_theme_stylebox("normal")
			var text_width := button.size.x - style.get_content_margin(SIDE_LEFT) - style.get_content_margin(SIDE_RIGHT)
			for line: String in button.text.split("\n"):
				text_fits = text_fits and font_size >= 10 and BoldFont.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= text_width - 1
			large_targets = large_targets and button.size.x >= 64 and is_equal_approx(button.size.y, 64)
		check.call(text_fits and large_targets, label+": celé názvy i ceny mají font alespoň10, odstup od malby a cíle alespoň64×64")
		var bar := view.crop_scroll.get_h_scroll_bar()
		check.call(bar.visible == view.crop_selector_scrollable and (not bar.visible or bar.size.y <= 6.1), label+": posuvník je tenký a objeví se pouze při nedostatku místa")
		if view.crop_selector_scrollable:
			view.crop_scroll.scroll_horizontal = 0
			await _frames(tree)
			await _wheel(tree, viewport, scroll_rect.get_center())
			check.call(view.crop_scroll.scroll_horizontal > 0, label+": skutečné vodorovné kolečko posune obsah")
		else:
			check.call(is_equal_approx(scroll_rect.position.y, view.size.y-78) and is_equal_approx(scroll_rect.size.y,64) and view.crop_scroll.scroll_horizontal == 0, label+": při dostatku místa zůstane původní výška a poloha řádku")
		var before_count := emitted.size()
		for index in range(view.crop_buttons.size()):
			var button := view.crop_buttons[index]
			view.crop_scroll.ensure_control_visible(button)
			await _frames(tree)
			var button_rect := _rect(button)
			var visible_content := Rect2(scroll_rect.position, Vector2(scroll_rect.size.x,64))
			check.call(visible_content.grow(.5).encloses(button_rect), label+": celá volba %s je dosažitelná posunem" % View.CROP_IDS[index])
			await _tap(tree, viewport, button)
		check.call(emitted.size() == before_count+5 and emitted.slice(before_count).map(func(event: Dictionary): return event.crop) == View.CROP_IDS and emitted.slice(before_count).all(func(event: Dictionary): return event.bed == 2), label+": skutečný dotyk všech5voleb jednou předá správnou plodinu i záhon")
		var held_button := view.crop_buttons[-1]
		var held_point := _rect(held_button).get_center()
		var old_scroll := view.crop_scroll
		var old_offset := old_scroll.scroll_horizontal
		_touch(viewport, held_point, true)
		await _frames(tree, 1)
		view.set_greenhouse_state(states, catalog, 9999, 900)
		await _frames(tree)
		_touch(viewport, held_point, false)
		await _frames(tree)
		check.call(view.crop_scroll == old_scroll and view.crop_scroll.scroll_horizontal == old_offset and emitted.size() == before_count+6, label+": stejná průběžná obnova zachová posun i podržený dotyk")
	# Hidden crop choices cannot sit over the action for an already planted bed.
	states[2] = {"stage":"growing", "stage_name":"ROSTE", "crop":catalog.cherry_tomato, "action":"none", "can_action":false, "action_label":"ROSTE"}
	view.set_greenhouse_state(states, catalog, 9999, 900)
	await _frames(tree)
	check.call(not view.crop_scroll.visible and view.action_button.visible and view.action_button.get_rect() == Rect2(16,622,568,64), "Skleníkové osivo: osazený záhon skryje celý posuvný volič a zachová původní akci")
	states[2] = {"stage":"empty", "stage_name":"VOLNÝ", "crop":{}, "action":"none", "can_action":false}
	view.set_greenhouse_state(states, catalog, 0, 0)
	await _frames(tree)
	var unavailable_before := emitted.size()
	view.crop_scroll.ensure_control_visible(view.crop_buttons[-1])
	await _frames(tree)
	await _tap(tree, viewport, view.crop_buttons[-1])
	check.call(view.crop_scroll.visible and view.crop_buttons.all(func(button: Button): return button.disabled) and emitted.size() == unavailable_before, "Skleníkové osivo: chybějící mince a zámky zůstávají čitelné, posuvné a nenakoupí")
	viewport.queue_free()
	await _frames(tree)
