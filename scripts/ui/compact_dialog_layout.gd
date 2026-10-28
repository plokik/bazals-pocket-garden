extends Node
## Keeps approved large-screen dialogs intact and provides a scrollable body
## with the original reachable footer controls when their natural height fails.

const EDGE := 8.0
const FOOTER_GAP := 8

var compact := false
var body_scroll: ScrollContainer
var footer_column: VBoxContainer
var compact_column: VBoxContainer

var _overlay: Control
var _card: PanelContainer
var _column: VBoxContainer
var _host: Control
var _footers: Array[Control] = []
var _children: Array[Control] = []
var _parent: Control
var _parent_index := 0
var _anchors := Vector4.ZERO
var _offsets := Vector4.ZERO
var _card_min := Vector2.ZERO
var _column_flags := Vector2i.ZERO
var _footer_flags: Dictionary = {}
var _queued := false
var _updating := false
var _safe_property := false
var _last_insets := Vector4.ZERO
var _saved_scroll := 0


func bind(overlay: Control, card: PanelContainer, column: VBoxContainer, pinned_footer: Array[Control], host: Control) -> void:
	assert(_overlay == null, "A dialog layout can only be bound once.")
	_overlay = overlay
	_card = card
	_column = column
	_host = host
	_parent = card.get_parent() as Control
	assert(_parent != null)
	_parent_index = card.get_index()
	_anchors = Vector4(card.anchor_left,card.anchor_top,card.anchor_right,card.anchor_bottom)
	_offsets = Vector4(card.offset_left,card.offset_top,card.offset_right,card.offset_bottom)
	_card_min = card.custom_minimum_size
	_column_flags = Vector2i(column.size_flags_horizontal,column.size_flags_vertical)
	for child in column.get_children():
		if child is Control: _children.append(child)
	for footer in pinned_footer:
		assert(footer.get_parent() == column, "Pinned footer must be a direct column child.")
		_footers.append(footer)
		_footer_flags[footer] = Vector2i(footer.size_flags_horizontal,footer.size_flags_vertical)
	if is_instance_valid(host):
		for property in host.get_property_list():
			if str(property.name) == "safe_area_insets": _safe_property = true
	compact_column = VBoxContainer.new()
	compact_column.name = "CompactDialogColumn"
	compact_column.add_theme_constant_override("separation",FOOTER_GAP)
	compact_column.hide()
	card.add_child(compact_column)
	body_scroll = ScrollContainer.new()
	body_scroll.name = "CompactDialogBodyScroll"
	body_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_scroll.follow_focus = false
	body_scroll.scroll_deadzone = 6
	body_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	compact_column.add_child(body_scroll)
	footer_column = VBoxContainer.new()
	footer_column.name = "CompactDialogFooter"
	footer_column.add_theme_constant_override("separation",FOOTER_GAP)
	compact_column.add_child(footer_column)
	overlay.resized.connect(refresh_layout)
	overlay.visibility_changed.connect(_visibility_changed)
	column.minimum_size_changed.connect(refresh_layout)
	card.minimum_size_changed.connect(refresh_layout)
	if _parent != overlay: _parent.resized.connect(refresh_layout)
	for child in _children:
		child.minimum_size_changed.connect(refresh_layout)
		child.visibility_changed.connect(refresh_layout)
	set_process(false)
	refresh_layout()


func refresh_layout() -> void:
	if _updating or _queued: return
	_queued = true
	_update_layout.call_deferred()


func _visibility_changed() -> void:
	set_process(is_instance_valid(_overlay) and _overlay.is_visible_in_tree())
	refresh_layout()


func _process(_delta: float) -> void:
	if _insets() != _last_insets: refresh_layout()


func _insets() -> Vector4:
	if not _safe_property or not is_instance_valid(_host): return Vector4.ZERO
	var value: Variant = _host.get("safe_area_insets")
	if value is Vector4:
		return Vector4(maxf(0,value.x),maxf(0,value.y),maxf(0,value.z),maxf(0,value.w))
	return Vector4.ZERO


func _natural_size() -> Vector2:
	var total := Vector2.ZERO
	var count := 0
	for child in _children:
		if not is_instance_valid(child) or not child.visible: continue
		var minimum := child.get_combined_minimum_size()
		total.x = maxf(total.x,minimum.x)
		total.y += minimum.y
		count += 1
	total.y += maxi(0,count-1) * _column.get_theme_constant("separation")
	total = total.max(_column.custom_minimum_size)
	var style: StyleBox = _card.get_theme_stylebox("panel")
	total += style.get_minimum_size()
	return total.max(_card_min)


func _normal_rect(natural: Vector2) -> Rect2:
	var parent_rect := Rect2(Vector2.ZERO,_parent.size)
	if _parent is MarginContainer:
		var left := _parent.get_theme_constant("margin_left")
		var top := _parent.get_theme_constant("margin_top")
		var right := _parent.get_theme_constant("margin_right")
		var bottom := _parent.get_theme_constant("margin_bottom")
		parent_rect = Rect2(left,top,maxf(0,_parent.size.x-left-right),maxf(0,_parent.size.y-top-bottom))
		parent_rect.size = parent_rect.size.max(natural)
	elif _parent is CenterContainer:
		parent_rect = Rect2((_parent.size-natural)*0.5,natural)
	else:
		var start := Vector2(_parent.size.x*_anchors.x+_offsets.x,_parent.size.y*_anchors.y+_offsets.y)
		var end := Vector2(_parent.size.x*_anchors.z+_offsets.z,_parent.size.y*_anchors.w+_offsets.w)
		parent_rect = Rect2(start,(end-start).max(natural))
	var transform := _overlay.get_global_transform_with_canvas().affine_inverse() * _parent.get_global_transform_with_canvas()
	return transform * parent_rect


func _update_layout() -> void:
	_queued = false
	if not is_instance_valid(_overlay) or not _overlay.is_inside_tree() or _overlay.size.x <= 0 or _overlay.size.y <= 0: return
	_updating = true
	_last_insets = _insets()
	set_process(_overlay.is_visible_in_tree())
	var safe := Rect2(Vector2(_last_insets.x,_last_insets.y),Vector2(maxf(1,_overlay.size.x-_last_insets.x-_last_insets.z),maxf(1,_overlay.size.y-_last_insets.y-_last_insets.w)))
	var natural := _natural_size()
	var legacy := _normal_rect(natural)
	var needs_compact := not safe.grow(.5).encloses(legacy)
	if needs_compact != compact:
		if needs_compact: _enter_compact()
		else: _restore_normal()
	if compact:
		var room := safe.grow(-EDGE)
		var width := minf(room.size.x,maxf(1,legacy.size.x))
		_card.custom_minimum_size = Vector2.ZERO
		_card.position = Vector2(room.position.x+(room.size.x-width)*.5,room.position.y)
		_card.size = Vector2(width,room.size.y)
		_overlay.set_meta("compact_dialog_layout",true)
	else:
		_overlay.set_meta("compact_dialog_layout",false)
	_updating = false


func _enter_compact() -> void:
	compact = true
	_column.reparent(body_scroll,false)
	_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_column.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	for footer in _footers:
		footer.reparent(footer_column,false)
		footer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		footer.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	compact_column.show()
	if _card.get_parent() != _overlay: _card.reparent(_overlay,false)
	_card.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_restore_scroll.call_deferred()


func _restore_scroll() -> void:
	if compact and is_instance_valid(body_scroll): body_scroll.scroll_vertical = _saved_scroll


func _restore_normal() -> void:
	_saved_scroll = body_scroll.scroll_vertical
	compact = false
	for child in _children:
		if is_instance_valid(child):
			if child.get_parent() != _column: child.reparent(_column,false)
			_column.move_child(child,_children.find(child))
	for footer in _footers:
		var flags: Vector2i = _footer_flags[footer]
		footer.size_flags_horizontal = flags.x
		footer.size_flags_vertical = flags.y
	_column.size_flags_horizontal = _column_flags.x
	_column.size_flags_vertical = _column_flags.y
	_column.reparent(_card,false)
	_card.move_child(_column,0)
	compact_column.hide()
	if _card.get_parent() != _parent: _card.reparent(_parent,false)
	_parent.move_child(_card,_parent_index)
	_card.custom_minimum_size = _card_min
	_card.set_anchor(SIDE_LEFT,_anchors.x)
	_card.set_anchor(SIDE_TOP,_anchors.y)
	_card.set_anchor(SIDE_RIGHT,_anchors.z)
	_card.set_anchor(SIDE_BOTTOM,_anchors.w)
	_card.offset_left = _offsets.x
	_card.offset_top = _offsets.y
	_card.offset_right = _offsets.z
	_card.offset_bottom = _offsets.w


func get_debug_snapshot() -> Dictionary:
	return {"compact":compact,"card":_card.get_global_rect(),"body":body_scroll.get_global_rect(),"footer":footer_column.get_global_rect(),"scroll_vertical":body_scroll.scroll_vertical,"safe_insets":_last_insets}
