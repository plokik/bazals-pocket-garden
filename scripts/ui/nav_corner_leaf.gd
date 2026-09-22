extends Control
## Compact four-leaf ornament seated into the painted content/navigation corner.

const Art := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const PETAL_ROTATIONS := [-PI * 0.5, 0.0, PI * 0.5, PI]


class PaintedCornerFlower:
	extends Control

	var petal_color := Color("#ff78ad")

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		resized.connect(queue_redraw)
		set_meta("component", "painted_corner_flower_v1")
		queue_redraw()

	func _draw() -> void:
		var center := size * 0.5
		var scale_unit := minf(size.x, size.y) / 15.0
		for index in range(5):
			var angle := -PI * 0.5 + TAU * float(index) / 5.0
			var petal_center := center + Vector2(cos(angle), sin(angle)) * 3.7 * scale_unit
			draw_circle(petal_center, 3.35 * scale_unit, Color("#15392e"))
			draw_circle(petal_center, 2.65 * scale_unit, petal_color)
			draw_circle(petal_center + Vector2(-0.65, -0.75) * scale_unit, 0.72 * scale_unit, Color(1.0, 0.88, 0.94, 0.82))
		draw_circle(center, 3.25 * scale_unit, Color("#4c2a11"))
		draw_circle(center, 2.55 * scale_unit, Color("#ffd43b"))
		draw_circle(center + Vector2(-0.75, -0.8) * scale_unit, 0.72 * scale_unit, Color("#fff7ad"))

var base_rotation := 0.0
var motion_time := 0.0
var motion_phase := 0.0
var reduced_motion := false
var botanical_visible := true
var petals: Array[TextureRect] = []
var gap_seat: PanelContainer
var corner_flower: PaintedCornerFlower


func configure(right_side: bool) -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 3
	base_rotation = 0.04 if right_side else -0.04
	motion_phase = PI if right_side else 0.0
	rotation = base_rotation
	set_meta("component", "painted_nav_corner_clover_v3")
	set_meta("leaf_count", 4)
	set_meta("flower_count", 1)
	set_meta("coverage", "white_corner_gap_without_nav_content_overlap")
	set_meta("seating", "painted_wood_corner_inlay_v1")
	set_meta("idle_motion", "subtle_sway_1deg_reduced_motion_v1")
	set_meta("botanical_visible", botanical_visible)
	set_meta("gap_seat_visible", true)
	set_meta("blocks_input", false)
	set_meta("right_side", right_side)
	gap_seat = PanelContainer.new()
	gap_seat.name = "PaintedCornerSeat"
	gap_seat.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gap_seat.add_theme_stylebox_override("panel", Art.box("wood", 0))
	gap_seat.set_meta("component", "painted_corner_gap_seat_v1")
	add_child(gap_seat)
	for petal_rotation in PETAL_ROTATIONS:
		var petal := TextureRect.new()
		petal.texture = Art.texture("leaf")
		petal.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		petal.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		petal.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		petal.mouse_filter = Control.MOUSE_FILTER_IGNORE
		petal.set_meta("clover_petal", true)
		petal.set_meta("petal_rotation", petal_rotation)
		add_child(petal)
		petals.append(petal)
	corner_flower = PaintedCornerFlower.new()
	corner_flower.name = "PaintedCornerFlower"
	corner_flower.petal_color = Color("#f786bb") if right_side else Color("#ff789f")
	add_child(corner_flower)


func _ready() -> void:
	resized.connect(_sync_transform)
	call_deferred("_sync_transform")


func _process(delta: float) -> void:
	if reduced_motion:
		return
	motion_time = fmod(motion_time + delta, TAU * 8.0)
	rotation = base_rotation + sin(motion_time * 1.15 + motion_phase) * 0.018


func set_reduced_motion(enabled: bool) -> void:
	reduced_motion = enabled
	set_meta("reduced_motion", enabled)
	set_process(not enabled)
	if enabled:
		rotation = base_rotation


func set_botanical_visible(enabled: bool, show_gap_seat: Variant = null) -> void:
	var gap_seat_enabled := enabled if show_gap_seat == null else bool(show_gap_seat)
	botanical_visible = enabled
	set_meta("botanical_visible", enabled)
	set_meta("gap_seat_visible", gap_seat_enabled)
	for petal in petals:
		petal.visible = enabled
	if gap_seat != null:
		gap_seat.visible = gap_seat_enabled
	if corner_flower != null:
		corner_flower.visible = enabled
	set_process(enabled and not reduced_motion)
	if not enabled:
		rotation = base_rotation


func _sync_transform() -> void:
	pivot_offset = size * 0.5
	var right_side := bool(get_meta("right_side", false))
	if gap_seat != null:
		gap_seat.position = Vector2(size.x - 20.0 if right_side else 0.0, size.y * 0.30)
		gap_seat.size = Vector2(20.0, size.y * 0.48)
	var petal_size := Vector2(minf(size.x, size.y) * 0.62, minf(size.x, size.y) * 0.62)
	for petal in petals:
		petal.size = petal_size
		petal.pivot_offset = Vector2(petal_size.x * 0.13, petal_size.y * 0.87)
		petal.position = size * 0.5 - petal.pivot_offset
		petal.rotation = float(petal.get_meta("petal_rotation", 0.0))
	if corner_flower != null:
		corner_flower.size = Vector2.ONE * 15.0
		corner_flower.position = size * 0.5 - corner_flower.size * 0.5
