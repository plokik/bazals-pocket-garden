extends RefCounted

const Layout := preload("res://scripts/ui/compact_dialog_layout.gd")

class AuditHost extends Control:
	var safe_area_insets := Vector4.ZERO


static func _frames(tree: SceneTree, count := 8) -> void:
	for i in count: await tree.process_frame


static func _rect(control: Control) -> Rect2:
	return control.get_global_transform_with_canvas()*Rect2(Vector2.ZERO,control.size)


static func _touch(viewport: SubViewport, point: Vector2, pressed: bool) -> void:
	var event := InputEventScreenTouch.new()
	event.index = 0
	event.position = point
	event.pressed = pressed
	viewport.push_input(event,true)


static func _fixture(tree: SceneTree, kind: String) -> Dictionary:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(432,960)
	viewport.handle_input_locally = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	tree.root.add_child(viewport)
	var host := AuditHost.new()
	host.size = Vector2(432,960)
	viewport.add_child(host)
	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	host.add_child(overlay)
	var parent: Control = overlay
	if kind != "anchored":
		var margin := MarginContainer.new()
		margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		for side in ["left","right","top","bottom"]: margin.add_theme_constant_override("margin_"+side,8)
		overlay.add_child(margin)
		parent = margin
		if kind == "centered":
			var center := CenterContainer.new()
			margin.add_child(center)
			parent = center
	var card := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#fff4cb")
	for side in [SIDE_LEFT,SIDE_TOP,SIDE_RIGHT,SIDE_BOTTOM]: style.set_content_margin(side,12)
	card.add_theme_stylebox_override("panel",style)
	if kind == "anchored":
		card.set_anchor(SIDE_LEFT,.045)
		card.set_anchor(SIDE_TOP,.07)
		card.set_anchor(SIDE_RIGHT,.955)
		card.set_anchor(SIDE_BOTTOM,.91)
	elif kind == "centered":
		card.custom_minimum_size.x = 380
	parent.add_child(card)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",8)
	card.add_child(column)
	for minimum in [72,480,40]:
		var body := Panel.new()
		body.custom_minimum_size = Vector2(100,minimum)
		column.add_child(body)
	var taps := [0]
	var action := Button.new()
	action.text = "POTVRDIT"
	action.custom_minimum_size.y = 64
	action.pressed.connect(func(): taps[0] += 1)
	column.add_child(action)
	var close := Button.new()
	close.text = "ZAVŘÍT"
	close.custom_minimum_size.y = 64
	close.pressed.connect(func(): taps[0] += 10)
	column.add_child(close)
	var order := column.get_children().duplicate()
	var layout := Layout.new()
	overlay.add_child(layout)
	var footers: Array[Control] = [action,close]
	layout.bind(overlay,card,column,footers,host)
	await _frames(tree,12)
	return {"viewport":viewport,"host":host,"overlay":overlay,"parent":parent,"card":card,"column":column,"action":action,"close":close,"layout":layout,"taps":taps,"order":order}


static func run(tree: SceneTree, check: Callable) -> void:
	for kind in ["anchored","margin","centered"]:
		var f := await _fixture(tree,kind)
		var layout = f.layout
		check.call(not layout.compact and f.card.get_parent() == f.parent and f.column.get_children() == f.order,"Kompaktní dialog %s: běžný telefon zachová původní strom a pořadí" % kind)
		var state := {"xp":1785,"coins":42,"save_marker":123}
		var before := state.duplicate(true)
		for dims in [Vector2i(360,640),Vector2i(360,800)]:
			f.viewport.size = dims
			f.host.size = Vector2(dims)
			f.host.safe_area_insets = Vector4(12,24,14,32)
			await _frames(tree,12)
			var safe := Rect2(12,24,dims.x-26,dims.y-56)
			check.call(layout.compact and safe.grow(.5).encloses(_rect(f.card)),"Kompaktní dialog %s %s: celý rám zůstane uvnitř bezpečných okrajů" % [kind,dims])
			check.call(safe.grow(.5).encloses(_rect(f.action)) and safe.grow(.5).encloses(_rect(f.close)) and f.action.size.y >= 64 and f.close.size.y >= 64 and _rect(f.close).position.y-_rect(f.action).end.y >= 7.5,"Kompaktní dialog %s %s: původní velké akce jsou dostupné a oddělené" % [kind,dims])
			check.call(_rect(layout.body_scroll).end.y+7.5 <= _rect(layout.footer_column).position.y,"Kompaktní dialog %s %s: obsah neposouvá ani nepřekrývá pevné akce" % [kind,dims])
			var scroll: ScrollContainer = layout.body_scroll
			var offset := scroll.scroll_vertical
			for i in 4:
				var wheel := InputEventMouseButton.new()
				wheel.position = _rect(scroll).get_center()
				wheel.global_position = wheel.position
				wheel.button_index = MOUSE_BUTTON_WHEEL_UP if offset > 0 else MOUSE_BUTTON_WHEEL_DOWN
				wheel.pressed = true
				f.viewport.push_input(wheel,true)
				wheel = wheel.duplicate()
				wheel.pressed = false
				f.viewport.push_input(wheel,true)
				await _frames(tree,1)
			await _frames(tree)
			check.call(scroll.scroll_vertical != offset,"Kompaktní dialog %s %s: skutečné kolečko zpřístupní zbytek obsahu" % [kind,dims])
			var saved_offset := scroll.scroll_vertical
			var target: Button = f.close
			var taps_before: int = f.taps[0]
			var point := _rect(target).get_center()
			_touch(f.viewport,point,true)
			await _frames(tree,1)
			layout.refresh_layout()
			await _frames(tree,2)
			_touch(f.viewport,point,false)
			await _frames(tree)
			check.call(is_instance_valid(target) and f.close == target and f.taps[0] == taps_before+10 and scroll.scroll_vertical == saved_offset,"Kompaktní dialog %s %s: obnova zachová podržený dotyk, callback i posunutí" % [kind,dims])
		f.host.safe_area_insets = Vector4.ZERO
		f.viewport.size = Vector2i(432,960)
		f.host.size = Vector2(432,960)
		await _frames(tree,12)
		check.call(not layout.compact and f.card.get_parent() == f.parent and f.column.get_children() == f.order,"Kompaktní dialog %s: návrat obnoví původní schválené rozložení" % kind)
		f.viewport.size = Vector2i(600,900)
		f.host.size = Vector2(600,900)
		await _frames(tree,12)
		check.call(Rect2(0,0,600,900).grow(.5).encloses(_rect(f.card)) and state == before,"Kompaktní dialog %s: široký pohled zachová rám i stav modelu" % kind)
		f.viewport.queue_free()
		await _frames(tree)
