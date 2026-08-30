class_name PlayerRoomView
extends Control

signal rack_requested
signal theme_requested
signal decoration_slot_requested(slot_index: int)

const ComicUITheme := preload("res://scripts/ui/comic_ui.gd")
const TooltipPolicy := preload("res://scripts/ui/tooltip_policy.gd")
const FontSemiBold := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const FontExtraBold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")

const SUPPORTED_THEMES := ["sunrise", "lagoon", "amethyst", "research_study"]
const DECORATION_SLOT_COUNT := 5

var selected_theme_id := "sunrise"
var back_button: Button
var theme_button: Button
var decoration_slots: Array[String] = ["", "", "", "", ""]
var decoration_catalog: Dictionary = {}
var decoration_buttons: Array[Button] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_meta("component", "phase103_player_room_v1")
	set_meta("location_id", "player_room")
	set_meta("decoration_slots", DECORATION_SLOT_COUNT)
	set_meta("gameplay_bonuses", false)
	set_meta("phase104_room_decorations", "purchase_once_move_free_v1")
	set_meta("responsive_test_viewports", [Vector2i(432, 960), Vector2i(360, 800)])
	resized.connect(_on_resized)
	_build_navigation()
	_build_decoration_buttons()
	_layout_decoration_buttons()
	queue_redraw()


func _build_navigation() -> void:
	back_button = Button.new()
	back_button.text = "←  STOJAN"
	back_button.focus_mode = Control.FOCUS_NONE
	back_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
	back_button.position = Vector2(10.0, 12.0)
	back_button.size = Vector2(118.0, 60.0)
	back_button.add_theme_font_override("font", FontExtraBold)
	back_button.add_theme_font_size_override("font_size", 13)
	ComicUITheme.apply_button(back_button, ComicUITheme.BLUE, Color.WHITE, 16)
	back_button.set_meta("component", "phase103_player_room_rack_return_v1")
	back_button.set_meta("touch_target_min", Vector2(118, 60))
	back_button.pressed.connect(_on_back_pressed)
	add_child(back_button)

	theme_button = Button.new()
	theme_button.text = "VZHLED POKOJE"
	theme_button.focus_mode = Control.FOCUS_NONE
	theme_button.set_anchor(SIDE_LEFT, 1.0)
	theme_button.set_anchor(SIDE_RIGHT, 1.0)
	theme_button.offset_left = -166.0
	theme_button.offset_right = -10.0
	theme_button.offset_top = 12.0
	theme_button.offset_bottom = 72.0
	theme_button.add_theme_font_override("font", FontExtraBold)
	theme_button.add_theme_font_size_override("font_size", 11)
	ComicUITheme.apply_button(theme_button, ComicUITheme.PURPLE, Color.WHITE, 16)
	theme_button.set_meta("component", "phase103_player_room_theme_launcher_v1")
	theme_button.set_meta("touch_target_min", Vector2(156, 60))
	theme_button.pressed.connect(_on_theme_pressed)
	add_child(theme_button)


func set_cosmetic_theme(theme_id: String) -> void:
	selected_theme_id = theme_id if theme_id in SUPPORTED_THEMES else "sunrise"
	set_meta("selected_theme_id", selected_theme_id)
	queue_redraw()


func set_room_decorations(slot_ids: Array[String], catalog: Dictionary) -> void:
	decoration_catalog = catalog.duplicate(true)
	decoration_slots.assign(["", "", "", "", ""])
	for slot_index in range(mini(DECORATION_SLOT_COUNT, slot_ids.size())):
		var decoration_id := str(slot_ids[slot_index])
		if decoration_id.is_empty() or decoration_catalog.has(decoration_id):
			decoration_slots[slot_index] = decoration_id
	set_meta("placed_decoration_count", decoration_slots.filter(func(decoration_id: String) -> bool: return not decoration_id.is_empty()).size())
	queue_redraw()


func set_paused(_paused: bool) -> void:
	pass


func set_fast_time_visuals(_enabled: bool) -> void:
	pass


func set_reduced_motion(enabled: bool) -> void:
	set_meta("reduced_motion", enabled)


func _on_back_pressed() -> void:
	rack_requested.emit()


func _on_theme_pressed() -> void:
	theme_requested.emit()


func _on_decoration_slot_pressed(slot_index: int) -> void:
	decoration_slot_requested.emit(slot_index)


func _on_resized() -> void:
	_layout_decoration_buttons()
	queue_redraw()


func _build_decoration_buttons() -> void:
	for slot_index in range(DECORATION_SLOT_COUNT):
		var button := Button.new()
		button.name = "DecorationSlot%d" % (slot_index + 1)
		button.text = ""
		button.flat = true
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.z_index = 6
		TooltipPolicy.apply(button, "Dekorační místo %d" % (slot_index + 1))
		button.set_meta("component", "phase104_room_decoration_slot_v1")
		button.set_meta("slot_index", slot_index)
		button.set_meta("touch_target_min", Vector2(56, 56))
		var empty_style := StyleBoxEmpty.new()
		for style_name in ["normal", "hover", "pressed", "focus", "disabled"]:
			button.add_theme_stylebox_override(style_name, empty_style)
		button.pressed.connect(_on_decoration_slot_pressed.bind(slot_index))
		add_child(button)
		decoration_buttons.append(button)


func _layout_decoration_buttons() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var centers := _decoration_slot_centers(size)
	for slot_index in range(mini(decoration_buttons.size(), centers.size())):
		var button := decoration_buttons[slot_index]
		button.position = centers[slot_index] - Vector2(28.0, 28.0)
		button.size = Vector2(56.0, 56.0)


func _draw() -> void:
	var viewport_size := size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var palette := _palette_for_theme(selected_theme_id)
	draw_rect(Rect2(Vector2.ZERO, viewport_size), palette.wall)
	_draw_wallpaper(viewport_size, palette)
	var floor_y := viewport_size.y * 0.58
	draw_rect(Rect2(0.0, floor_y, viewport_size.x, viewport_size.y - floor_y), palette.floor)
	for plank_index in range(1, 7):
		var plank_y := lerpf(floor_y, viewport_size.y, float(plank_index) / 7.0)
		draw_line(Vector2(0.0, plank_y), Vector2(viewport_size.x, plank_y), palette.ink.lightened(0.16), 2.0)
	_draw_title(viewport_size, palette)
	_draw_window(Rect2(viewport_size.x * 0.29, 146.0, viewport_size.x * 0.42, viewport_size.y * 0.27), palette)
	_draw_bed(Rect2(18.0, floor_y - 24.0, viewport_size.x * 0.44, viewport_size.y * 0.29), palette)
	_draw_desk(Rect2(viewport_size.x * 0.63, floor_y + 16.0, viewport_size.x * 0.32, viewport_size.y * 0.20), palette)
	_draw_rug(Rect2(viewport_size.x * 0.27, viewport_size.y * 0.72, viewport_size.x * 0.48, viewport_size.y * 0.18), palette)
	_draw_decoration_slots(viewport_size, palette)


func _palette_for_theme(theme_id: String) -> Dictionary:
	match theme_id:
		"lagoon":
			return {"wall": Color("#a6e5df"), "wall_accent": Color("#5bc3c5"), "floor": Color("#c68b54"), "accent": ComicUITheme.TEAL, "accent_2": ComicUITheme.CYAN, "ink": ComicUITheme.INK, "sky": Color("#73d7ef")}
		"amethyst":
			return {"wall": Color("#d9c4ed"), "wall_accent": Color("#aa78d4"), "floor": Color("#8e668b"), "accent": ComicUITheme.PURPLE, "accent_2": Color("#f4b4eb"), "ink": ComicUITheme.INK, "sky": Color("#a9dbff")}
		"research_study":
			return {"wall": Color("#24455b"), "wall_accent": Color("#366982"), "floor": Color("#775238"), "accent": Color("#d9a441"), "accent_2": Color("#79c8c4"), "ink": Color("#17212b"), "sky": Color("#77b9d4")}
		_:
			return {"wall": Color("#ffe1ad"), "wall_accent": Color("#f4aa69"), "floor": Color("#bd7545"), "accent": ComicUITheme.ORANGE, "accent_2": ComicUITheme.GOLD, "ink": ComicUITheme.INK, "sky": Color("#79d7f3")}


func _draw_wallpaper(viewport_size: Vector2, palette: Dictionary) -> void:
	for stripe_index in range(7):
		var stripe_x := float(stripe_index) * viewport_size.x / 6.0
		draw_line(Vector2(stripe_x, 78.0), Vector2(stripe_x, viewport_size.y * 0.58), Color(palette.wall_accent, 0.28), 3.0)


func _draw_title(viewport_size: Vector2, palette: Dictionary) -> void:
	draw_string(FontExtraBold, Vector2(0.0, 103.0), "MŮJ POKOJ", HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, 22, palette.ink)
	draw_string(FontSemiBold, Vector2(0.0, 123.0), "Vlastní prostor pro vzhled a pokojové rostliny", HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, 10, palette.ink)


func _draw_window(rect: Rect2, palette: Dictionary) -> void:
	_draw_panel(rect, palette.sky, palette.ink, 18)
	draw_circle(rect.position + Vector2(rect.size.x * 0.72, rect.size.y * 0.28), 18.0, Color("#fff1a6"))
	for cloud_offset in [Vector2(24, 45), Vector2(62, 68), Vector2(104, 42)]:
		draw_circle(rect.position + cloud_offset, 13.0, Color("#fffdf4", 0.88))
	draw_line(rect.position + Vector2(rect.size.x * 0.5, 4.0), rect.position + Vector2(rect.size.x * 0.5, rect.size.y - 4.0), palette.ink, 4.0)
	draw_line(rect.position + Vector2(4.0, rect.size.y * 0.54), rect.position + Vector2(rect.size.x - 4.0, rect.size.y * 0.54), palette.ink, 4.0)
	draw_colored_polygon(PackedVector2Array([rect.position + Vector2(-22, -4), rect.position + Vector2(22, -4), rect.position + Vector2(2, rect.size.y), rect.position + Vector2(-38, rect.size.y)]), palette.accent)
	draw_colored_polygon(PackedVector2Array([rect.position + Vector2(rect.size.x - 22, -4), rect.position + Vector2(rect.size.x + 22, -4), rect.position + Vector2(rect.size.x + 38, rect.size.y), rect.position + Vector2(rect.size.x - 2, rect.size.y)]), palette.accent)


func _draw_bed(rect: Rect2, palette: Dictionary) -> void:
	_draw_panel(rect, Color("#f6efe0"), palette.ink, 18)
	draw_rect(Rect2(rect.position + Vector2(0.0, rect.size.y * 0.56), Vector2(rect.size.x, rect.size.y * 0.44)), palette.accent)
	_draw_panel(Rect2(rect.position + Vector2(12.0, 14.0), Vector2(rect.size.x * 0.42, rect.size.y * 0.30)), ComicUITheme.PAPER, palette.ink, 12)
	draw_line(rect.position + Vector2(12.0, rect.size.y), rect.position + Vector2(12.0, rect.size.y + 18.0), palette.ink, 6.0)
	draw_line(rect.position + Vector2(rect.size.x - 12.0, rect.size.y), rect.position + Vector2(rect.size.x - 12.0, rect.size.y + 18.0), palette.ink, 6.0)


func _draw_desk(rect: Rect2, palette: Dictionary) -> void:
	_draw_panel(Rect2(rect.position, Vector2(rect.size.x, 30.0)), palette.accent_2, palette.ink, 8)
	draw_line(rect.position + Vector2(12.0, 26.0), rect.position + Vector2(12.0, rect.size.y), palette.ink, 7.0)
	draw_line(rect.position + Vector2(rect.size.x - 12.0, 26.0), rect.position + Vector2(rect.size.x - 12.0, rect.size.y), palette.ink, 7.0)
	_draw_panel(Rect2(rect.position + Vector2(18.0, -44.0), Vector2(rect.size.x - 36.0, 42.0)), Color("#f2ddaa"), palette.ink, 8)
	for book_index in range(4):
		draw_rect(Rect2(rect.position + Vector2(24.0 + book_index * 18.0, -34.0), Vector2(12.0, 30.0)), palette.accent if book_index % 2 == 0 else palette.accent_2)


func _draw_rug(rect: Rect2, palette: Dictionary) -> void:
	draw_style_box(ComicUITheme.style_box(palette.accent_2, palette.ink, 3, 34, Color("#0c1720", 0.20), 2, 0.0), rect)
	draw_arc(rect.get_center(), minf(rect.size.x, rect.size.y) * 0.31, 0.0, TAU, 48, palette.accent, 8.0, true)


func _draw_decoration_slots(viewport_size: Vector2, palette: Dictionary) -> void:
	var centers := _decoration_slot_centers(viewport_size)
	for slot_index in range(DECORATION_SLOT_COUNT):
		var center := centers[slot_index]
		var decoration_id := decoration_slots[slot_index] if slot_index < decoration_slots.size() else ""
		if decoration_id.is_empty() or not decoration_catalog.has(decoration_id):
			_draw_empty_decoration_slot(center, palette)
		else:
			_draw_decoration_item(decoration_id, center, palette)
	draw_string(FontExtraBold, Vector2(0.0, viewport_size.y - 20.0), "KLEPNI NA MÍSTO A VYBER DEKORACI", HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, 10, palette.ink)


func _decoration_slot_centers(viewport_size: Vector2) -> PackedVector2Array:
	var centers := PackedVector2Array()
	var slot_y := viewport_size.y - 60.0
	var left_margin := 30.0
	var available_width := maxf(0.0, viewport_size.x - left_margin * 2.0)
	for slot_index in range(DECORATION_SLOT_COUNT):
		centers.append(Vector2(left_margin + available_width * (float(slot_index) / float(DECORATION_SLOT_COUNT - 1)), slot_y))
	return centers


func _draw_empty_decoration_slot(center: Vector2, palette: Dictionary) -> void:
	draw_circle(center, 17.0, Color("#fff8df", 0.92))
	draw_arc(center, 17.0, 0.0, TAU, 28, palette.ink, 3.0, true)
	draw_line(center + Vector2(-6.0, 0.0), center + Vector2(6.0, 0.0), palette.ink, 3.0)
	draw_line(center + Vector2(0.0, -6.0), center + Vector2(0.0, 6.0), palette.ink, 3.0)


func _draw_decoration_item(decoration_id: String, center: Vector2, palette: Dictionary) -> void:
	var decoration: Dictionary = decoration_catalog.get(decoration_id, {})
	var kind := str(decoration.get("kind", "books"))
	var accent := Color(str(decoration.get("accent", "#55b85a")))
	draw_circle(center, 20.0, Color("#fff8df", 0.74))
	match kind:
		"books":
			for book_index in range(3):
				var book_width := 38.0 - float(book_index) * 5.0
				draw_rect(Rect2(center.x - book_width * 0.5, center.y - 8.0 - float(book_index) * 8.0, book_width, 7.0), accent.lightened(float(book_index) * 0.12))
				draw_line(Vector2(center.x - book_width * 0.5, center.y - 2.0 - float(book_index) * 8.0), Vector2(center.x + book_width * 0.5, center.y - 2.0 - float(book_index) * 8.0), palette.ink, 2.0)
		"lamp":
			draw_circle(center + Vector2(0.0, -28.0), 21.0, Color(accent, 0.20))
			draw_colored_polygon(PackedVector2Array([center + Vector2(-16.0, -31.0), center + Vector2(16.0, -31.0), center + Vector2(10.0, -13.0), center + Vector2(-10.0, -13.0)]), accent)
			draw_polyline(PackedVector2Array([center + Vector2(-16.0, -31.0), center + Vector2(16.0, -31.0), center + Vector2(10.0, -13.0), center + Vector2(-10.0, -13.0), center + Vector2(-16.0, -31.0)]), palette.ink, 3.0)
			draw_line(center + Vector2(0.0, -13.0), center + Vector2(0.0, 8.0), palette.ink, 4.0)
			draw_line(center + Vector2(-12.0, 8.0), center + Vector2(12.0, 8.0), palette.ink, 4.0)
		_:
			_draw_potted_decoration(kind, center, accent, palette)
	draw_arc(center, 20.0, 0.0, TAU, 32, palette.ink, 2.0, true)


func _draw_potted_decoration(kind: String, center: Vector2, accent: Color, palette: Dictionary) -> void:
	var pot_color := Color("#e87932") if kind != "broad_leaf_plant" else ComicUITheme.CYAN
	draw_colored_polygon(PackedVector2Array([center + Vector2(-14.0, -5.0), center + Vector2(14.0, -5.0), center + Vector2(10.0, 12.0), center + Vector2(-10.0, 12.0)]), pot_color)
	draw_polyline(PackedVector2Array([center + Vector2(-14.0, -5.0), center + Vector2(14.0, -5.0), center + Vector2(10.0, 12.0), center + Vector2(-10.0, 12.0), center + Vector2(-14.0, -5.0)]), palette.ink, 2.5)
	var stem_top := -40.0 if kind == "tall_leaf_plant" else -30.0
	draw_line(center + Vector2(0.0, -5.0), center + Vector2(0.0, stem_top), Color("#24733b"), 3.0)
	if kind == "tall_leaf_plant":
		for leaf_x in [-9.0, -3.0, 4.0, 10.0]:
			draw_colored_polygon(PackedVector2Array([center + Vector2(leaf_x - 4.0, -7.0), center + Vector2(leaf_x, -43.0 + absf(leaf_x) * 0.45), center + Vector2(leaf_x + 5.0, -7.0)]), accent)
	elif kind == "fern":
		for angle in [-1.15, -0.75, -0.35, 0.35, 0.75, 1.15]:
			var tip := center + Vector2(cos(angle) * 28.0, -10.0 - sin(absf(angle)) * 24.0)
			draw_line(center + Vector2(0.0, -5.0), tip, Color("#24733b"), 3.0)
			draw_circle(tip, 6.0, accent)
	elif kind == "flowering_plant":
		for offset in [Vector2(-14.0, -25.0), Vector2(0.0, -36.0), Vector2(14.0, -24.0)]:
			draw_line(center + Vector2(0.0, -5.0), center + offset, Color("#24733b"), 2.5)
			draw_circle(center + offset, 7.0, accent)
			draw_circle(center + offset, 2.5, ComicUITheme.GOLD)
	else:
		for offset in [Vector2(-14.0, -24.0), Vector2(12.0, -34.0), Vector2(15.0, -17.0), Vector2(-7.0, -39.0)]:
			draw_line(center + Vector2(0.0, -5.0), center + offset, Color("#24733b"), 2.5)
			draw_circle(center + offset, 8.0, accent)


func _draw_panel(rect: Rect2, fill: Color, border: Color, radius: int) -> void:
	draw_style_box(ComicUITheme.style_box(fill, border, 3, radius, Color("#0c1720", 0.24), 3, 0.0), rect)
