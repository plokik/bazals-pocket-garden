extends "res://.agents/skills/how-to-grow-validation/scripts/capture_validation.gd"
const Preview := preload("res://docs/visual-proposals/20261017-teahouse-products-v1/prototype/preview.gd")
const OUTPUT := "res://docs/visual-proposals/20261017-teahouse-products-v1/"
var layout_checks := 0
var layout_failures: Array[String] = []
func _init() -> void: call_deferred("review")
func review() -> void:
	if not OS.get_user_data_dir().replace(char(92),"/").contains("teahouse-products-20261017/capture-user"):
		quit(2)
		return
	var surface := SubViewport.new()
	surface.size = Vector2i(432,960)
	surface.size_2d_override = surface.size
	surface.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(surface)
	var game = load("res://main.tscn").instantiate()
	surface.add_child(game)
	await process_frame
	await process_frame
	_prepare_common_state(game)
	game.set_process(false)
	game.session.paused = true
	game.garden_cat_companion.set_process(false)
	game._open_player_room()
	game._refresh_ui()
	var view := Preview.new()
	surface.add_child(view)
	await create_timer(0.6).timeout
	for width in [360,432]:
		surface.size = Vector2i(width,int(width/0.45))
		surface.size_2d_override = surface.size
		for id in Preview.Demo.ORDER:
			view.select_product(id)
			await settle()
			await shot(surface,"product-%s-%d" % [id,width])
			check_layout(view,width)
		view.show_quest()
		await settle()
		await shot(surface,"teahouse-offer-%d" % width)
		check_layout(view,width)
	await click(surface,view.action)
	await settle()
	await shot(surface,"teahouse-active-432")
	for id in Preview.Demo.ORDER:
		await click(surface,view.products_button)
		await click(surface,view.product_buttons[id])
		assert(view.selected == id,"Product tab pointer input")
		await settle()
		await click(surface,view.action)
		var spent: int = view.model.coins
		view.action.pressed.emit()
		assert(view.model.coins == spent,"Double click must not spend twice")
		await create_timer(0.85).timeout
		if id == "tea": await shot(surface,"tea-mixing-432")
		await create_timer(1.0).timeout
		assert(not view.model.busy)
		assert(not view.order_button.disabled and not view.back_button.disabled)
		if id == "tea": await shot(surface,"tea-success-432")
	await click(surface,view.order_button)
	await settle()
	await shot(surface,"teahouse-ready-432")
	surface.size = Vector2i(360,800)
	surface.size_2d_override = surface.size
	await settle()
	await shot(surface,"teahouse-ready-360")
	await click(surface,view.action)
	await settle()
	await shot(surface,"teahouse-completed-360")
	surface.size = Vector2i(432,960)
	surface.size_2d_override = surface.size
	await settle()
	await shot(surface,"teahouse-completed-432")
	check_layout(view,432)
	assert(view.model.quest == "completed" and view.model.coins == 111 and view.model.lemonbalm_seeds == 2)
	# Check shorter display, longest card, scroll reach and reduced motion.
	surface.size = Vector2i(360,640)
	surface.size_2d_override = surface.size
	view.selected = "gift"
	view.show_products()
	await settle()
	view.scroll.scroll_vertical = 10000
	await settle()
	await shot(surface,"compact-scrolled-360x640")
	assert(view.action.get_global_rect().position.y >= view.scroll.get_global_rect().position.y)
	assert(view.action.get_global_rect().end.y <= view.scroll.get_global_rect().end.y+1)
	view.reduced_motion = true
	await click(surface,view.action)
	await create_timer(0.3).timeout
	assert(not view.model.busy)
	await shot(surface,"reduced-motion-360x640")
	await click(surface,view.back_button)
	assert(not view.visible)
	view.queue_free()
	game.queue_free()
	await process_frame
	print("TEAHOUSE_LAYOUT_CHECKS=%d FAILURES=%d" % [layout_checks,layout_failures.size()])
	for failure in layout_failures: push_error(failure)
	print("TEAHOUSE_NATIVE_PREVIEW="+("PASSED" if layout_failures.is_empty() else "FAILED"))
	quit(0 if layout_failures.is_empty() else 1)
func check_layout(view: Control, width: int) -> void:
	for item in view.find_children("*","Button",true,false):
		if not item.is_visible_in_tree(): continue
		layout_checks += 1
		var rect: Rect2 = item.get_global_rect()
		if rect.position.x < 39 or rect.end.x > width-39 or rect.size.y < 43:
			layout_failures.append("button outside content: "+item.text+" "+str(rect))
	for item in view.find_children("*","Label",true,false):
		layout_checks += 1
		if item.get_line_count() > item.get_visible_line_count(): layout_failures.append("clipped text: "+item.text)
func settle() -> void:
	for frame in range(8): await process_frame
	await RenderingServer.frame_post_draw
func click(surface: SubViewport, item: Button) -> void:
	var location := item.get_global_rect().get_center()
	var event := InputEventMouseButton.new()
	event.position = location
	event.global_position = location
	event.button_index = MOUSE_BUTTON_LEFT
	event.button_mask = MOUSE_BUTTON_MASK_LEFT
	event.pressed = true
	surface.push_input(event,true)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	event.button_mask = 0
	surface.push_input(event,true)
	await process_frame
func shot(surface: SubViewport, filename: String) -> void:
	await RenderingServer.frame_post_draw
	surface.get_texture().get_image().save_png(OUTPUT+filename+".png")
