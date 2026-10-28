extends VBoxContainer
## Candidate presentation; it never owns or mutates simulation state.

const Art := preload("res://scripts/ui/plant_detail_painted_assets.gd")

var compact_scroll: ScrollContainer
var _body: VBoxContainer
var _items: Array[Control] = []
var _layout_queued := false
var _compact := false


func _ready() -> void:
	set_meta("component", "painted_detail_surface_bridge_v1")
	resized.connect(queue_redraw)
	resized.connect(_request_layout)
	minimum_size_changed.connect(_request_layout)
	child_entered_tree.connect(func(_child: Node): _request_layout())
	if get_parent() is Control:
		get_parent().resized.connect(_request_layout)
	_request_layout()
	queue_redraw()


func _request_layout() -> void:
	if not is_node_ready() or _layout_queued: return
	_layout_queued = true
	_sync_layout.call_deferred()


func _sync_layout() -> void:
	_layout_queued = false
	if not is_inside_tree() or not get_parent() is Control: return
	for child in get_children():
		if child is Control and child != compact_scroll and not _items.has(child): _items.append(child)
	if _items.size() < 2: return
	var available: Vector2 = get_parent().size
	var needed := 0.0
	var visible_count := 0
	for item in _items:
		if item.visible:
			needed += item.get_combined_minimum_size().y
			visible_count += 1
	needed += maxf(0, visible_count - 1) * get_theme_constant("separation")
	var wants_compact := needed > available.y + 1
	if wants_compact != _compact:
		_compact = wants_compact
		if _compact:
			if compact_scroll == null:
				compact_scroll = ScrollContainer.new()
				compact_scroll.name = "PlantDetailScroll"
				compact_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
				compact_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
				compact_scroll.scroll_deadzone = 8
				compact_scroll.follow_focus = true
				compact_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
				var padding := StyleBoxEmpty.new()
				padding.set_content_margin(SIDE_LEFT,4)
				padding.set_content_margin(SIDE_RIGHT,8)
				padding.set_content_margin(SIDE_BOTTOM,6)
				compact_scroll.add_theme_stylebox_override("panel",padding)
				_body = VBoxContainer.new()
				_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				_body.mouse_filter = Control.MOUSE_FILTER_PASS
				_body.add_theme_constant_override("separation", get_theme_constant("separation"))
				compact_scroll.add_child(_body)
				add_child(compact_scroll)
			compact_scroll.show()
			for index in range(1, _items.size()): _items[index].reparent(_body, false)
		else:
			for item in _items:
				if item.get_parent() != self: item.reparent(self, false)
			compact_scroll.hide()
	set_meta("compact_detail_scroll", _compact)
	if _compact and not size.is_equal_approx(available):
		set_deferred("size",available)
	queue_redraw()


func _draw() -> void:
	draw_style_box(Art.box("wood", 0), Rect2(Vector2.ZERO, size))
