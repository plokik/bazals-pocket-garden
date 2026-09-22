extends Control

const Art := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const CLOVER_PETAL_ROTATIONS := [-PI * 0.5, 0.0, PI * 0.5, PI]
const TOP_CLOVER_DIAMETER := 28.0
const TOP_CLOVER_CENTER_INSET := 12.0
const RACK_WOOD_FILL := Color("#93420f")
const RACK_WOOD_DARK := Color("#4b2109")
const RACK_WOOD_HIGHLIGHT := Color("#d47a20")

const CARD_RECTS := [
	Rect2(0.005, 0.02, 0.324, 0.96),
	Rect2(0.335, 0.02, 0.319, 0.96),
	Rect2(0.659, 0.02, 0.336, 0.96),
]
var ornament_time := 0.0
var reduced_motion := false
var corner_ornaments_visible := true
var painted_gap_fill_active := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	set_meta("component", "painted_garden_hud_surface_v1")
	set_meta("ui_kit", "painted_detail_ui_v2")
	set_meta("top_corner_clover_count", 2)
	set_meta("top_corner_leaf_count", 8)
	set_meta("top_corner_flower_count", 2)
	set_meta("top_corner_seating", "painted_outer_hud_corners_v1")
	set_meta("top_corner_protection", "day_coin_level_content_drawn_above_ornaments")
	set_meta("top_corner_motion", "subtle_sway_1deg_reduced_motion_v1")
	set_meta("corner_ornaments_visible", corner_ornaments_visible)
	set_meta("rack_gap_fill_active", false)
	set_meta("rack_gap_fill", "opaque_painted_wood_seams_v1")
	queue_redraw()


func _process(delta: float) -> void:
	if reduced_motion:
		return
	ornament_time = fmod(ornament_time + delta, TAU * 8.0)
	queue_redraw()


func set_reduced_motion(enabled: bool) -> void:
	reduced_motion = enabled
	set_meta("reduced_motion", enabled)
	set_process(not enabled)
	queue_redraw()


func set_corner_ornaments_visible(enabled: bool, fill_painted_gaps: Variant = null) -> void:
	corner_ornaments_visible = enabled
	painted_gap_fill_active = not enabled if fill_painted_gaps == null else bool(fill_painted_gaps)
	set_meta("corner_ornaments_visible", enabled)
	set_meta("rack_gap_fill_active", painted_gap_fill_active)
	queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var base := Art.box("wood", 0)
	if painted_gap_fill_active:
		draw_rect(Rect2(Vector2.ZERO, size), RACK_WOOD_DARK)
	draw_style_box(base, Rect2(Vector2.ZERO, size))
	if painted_gap_fill_active:
		var seam_rect := Rect2(2.0, 3.0, maxf(0.0, size.x - 4.0), maxf(0.0, size.y - 6.0))
		draw_rect(seam_rect, RACK_WOOD_FILL)
		draw_line(Vector2(2.0, 4.0), Vector2(size.x - 2.0, 4.0), RACK_WOOD_HIGHLIGHT, 1.5, true)
		draw_line(Vector2(2.0, size.y - 4.0), Vector2(size.x - 2.0, size.y - 4.0), RACK_WOOD_DARK, 1.5, true)
	for index in range(CARD_RECTS.size()):
		var card_rect := _scaled_rect(CARD_RECTS[index]).grow(-2.0)
		var card := Art.box("sage" if index == 2 else "cream", 4)
		draw_style_box(card, card_rect)
	if corner_ornaments_visible:
		_draw_top_corner_clovers()
	_draw_day_icon(_scaled_rect(Rect2(0.038, 0.15, 0.130, 0.70)))


func _scaled_rect(normalized: Rect2) -> Rect2:
	return Rect2(normalized.position * size, normalized.size * size)


func _draw_top_corner_clovers() -> void:
	var texture := Art.texture("leaf")
	if texture == null:
		return
	var petal_size := Vector2.ONE * (TOP_CLOVER_DIAMETER * 0.62)
	var local_pivot := Vector2(petal_size.x * 0.13, petal_size.y * 0.87)
	for right_side in [false, true]:
		var center := Vector2(size.x - TOP_CLOVER_CENTER_INSET if right_side else TOP_CLOVER_CENTER_INSET, TOP_CLOVER_CENTER_INSET)
		var phase := PI if right_side else 0.0
		var base_rotation := 0.04 if right_side else -0.04
		var sway := 0.0 if reduced_motion else sin(ornament_time * 1.15 + phase) * 0.018
		for petal_rotation in CLOVER_PETAL_ROTATIONS:
			draw_set_transform(center, base_rotation + sway + petal_rotation)
			draw_texture_rect(texture, Rect2(-local_pivot, petal_size), false)
		draw_set_transform(center, 0.0, Vector2.ONE)
		_draw_corner_flower(Color("#f786bb") if right_side else Color("#ff789f"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_corner_flower(petal_color: Color) -> void:
	for index in range(5):
		var angle := -PI * 0.5 + TAU * float(index) / 5.0
		var petal_center := Vector2(cos(angle), sin(angle)) * 3.7
		draw_circle(petal_center, 3.35, Color("#15392e"))
		draw_circle(petal_center, 2.65, petal_color)
		draw_circle(petal_center + Vector2(-0.65, -0.75), 0.72, Color(1.0, 0.88, 0.94, 0.82))
	draw_circle(Vector2.ZERO, 3.25, Color("#4c2a11"))
	draw_circle(Vector2.ZERO, 2.55, Color("#ffd43b"))
	draw_circle(Vector2(-0.75, -0.8), 0.72, Color("#fff7ad"))


func _draw_day_icon(rect: Rect2) -> void:
	var texture := Art.texture("sun")
	if texture == null:
		return
	var texture_size := texture.get_size()
	var scale := minf(rect.size.x / texture_size.x, rect.size.y / texture_size.y)
	var painted_size := texture_size * scale
	var painted_rect := Rect2(rect.get_center() - painted_size * 0.5, painted_size)
	draw_texture_rect(texture, painted_rect, false)
