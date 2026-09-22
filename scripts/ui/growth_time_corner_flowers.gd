extends Control
## Small opaque floral caps for the four exposed cream corners around the sage time card.

const CORNER_INSET := 5.5
const BACKING_OUTLINE := Color("#123c2a")
const BACKING_GREEN := Color("#65bd32")
const PETAL_OUTLINE := Color("#4b2918")
const PETAL_COLORS := [Color("#ff78a5"), Color("#f58bd0"), Color("#ff8bb3"), Color("#ef79c0")]
const GOLD := Color("#ffd43b")


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 2
	resized.connect(queue_redraw)
	set_meta("component", "growth_time_floral_corner_caps_v1")
	set_meta("flower_count", 4)
	set_meta("coverage", "full_left_and_right_cream_corner_pockets")
	queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var centers := [
		Vector2(CORNER_INSET, CORNER_INSET),
		Vector2(size.x - CORNER_INSET, CORNER_INSET),
		Vector2(CORNER_INSET, size.y - CORNER_INSET),
		Vector2(size.x - CORNER_INSET, size.y - CORNER_INSET),
	]
	_draw_side_vine(CORNER_INSET)
	_draw_side_vine(size.x - CORNER_INSET)
	for index in range(centers.size()):
		_draw_floral_cap(centers[index], PETAL_COLORS[index])


func _draw_side_vine(x: float) -> void:
	var top := Vector2(x, CORNER_INSET)
	var bottom := Vector2(x, size.y - CORNER_INSET)
	draw_line(top, bottom, BACKING_OUTLINE, 17.0)
	draw_circle(top, 8.5, BACKING_OUTLINE)
	draw_circle(bottom, 8.5, BACKING_OUTLINE)
	draw_line(top, bottom, BACKING_GREEN, 14.0)
	draw_circle(top, 7.0, BACKING_GREEN)
	draw_circle(bottom, 7.0, BACKING_GREEN)
	var middle := (top + bottom) * 0.5
	# Two small leaf veins keep the opaque cover botanical instead of panel-like.
	draw_line(middle + Vector2(-4.5, -5.0), middle + Vector2(3.0, -0.5), Color("#2b7d2d"), 1.2)
	draw_line(middle + Vector2(4.5, 5.0), middle + Vector2(-3.0, 0.5), Color("#2b7d2d"), 1.2)


func _draw_floral_cap(center: Vector2, petal_color: Color) -> void:
	# The opaque green calyx removes the last cream triangle; the flower keeps it decorative.
	draw_circle(center, 8.0, BACKING_OUTLINE)
	draw_circle(center, 6.7, BACKING_GREEN)
	for index in range(5):
		var angle := -PI * 0.5 + TAU * float(index) / 5.0
		var petal_center := center + Vector2(cos(angle), sin(angle)) * 2.8
		draw_circle(petal_center, 2.25, PETAL_OUTLINE)
		draw_circle(petal_center, 1.7, petal_color)
		draw_circle(petal_center + Vector2(-0.35, -0.42), 0.45, Color(1.0, 0.90, 0.95, 0.85))
	draw_circle(center, 2.4, PETAL_OUTLINE)
	draw_circle(center, 1.8, GOLD)
	draw_circle(center + Vector2(-0.45, -0.50), 0.45, Color("#fff7ad"))
