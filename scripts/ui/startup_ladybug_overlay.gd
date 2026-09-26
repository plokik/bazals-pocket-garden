extends Control
## Two tiny hand-drawn ladybugs flying along the margins of the loading screen.

var elapsed := 0.0


func _draw() -> void:
	var safe_width := minf(size.x - 24.0, 408.0)
	var left := (size.x - safe_width) * 0.5
	var flight_a := elapsed * 1.55
	var flight_b := elapsed * 1.25 + 2.4
	var first := Vector2(left + safe_width * 0.22 + sin(flight_a) * 20.0, size.y * 0.26 + cos(flight_a * 0.83) * 17.0)
	var second := Vector2(left + safe_width * 0.78 + sin(flight_b) * 20.0, size.y * 0.66 + cos(flight_b * 0.91) * 16.0)
	_draw_ladybug(first, sin(flight_a * 0.8) * 0.28, flight_a * 16.0, 0.94)
	_draw_ladybug(second, -sin(flight_b * 0.8) * 0.26, flight_b * 16.0, 0.83)


func _draw_ladybug(point: Vector2, tilt: float, wing_phase: float, visual_scale: float) -> void:
	draw_set_transform(point, tilt, Vector2.ONE * visual_scale)
	var wing_lift := 3.0 + absf(sin(wing_phase)) * 3.0
	var wing_color := Color("#f5e8b5", 0.76)
	draw_colored_polygon(PackedVector2Array([Vector2(-1.0, -2.0), Vector2(-wing_lift - 8.0, -6.0), Vector2(-wing_lift - 7.0, 2.0)]), wing_color)
	draw_colored_polygon(PackedVector2Array([Vector2(1.0, -2.0), Vector2(wing_lift + 8.0, -6.0), Vector2(wing_lift + 7.0, 2.0)]), wing_color)
	draw_circle(Vector2(0.0, 2.0), 7.5, Color("#2c291b"))
	draw_colored_polygon(PackedVector2Array([Vector2(-0.5, -4.0), Vector2(-6.5, -1.5), Vector2(-6.0, 5.0), Vector2(-1.0, 8.0)]), Color("#d83b2d"))
	draw_colored_polygon(PackedVector2Array([Vector2(0.5, -4.0), Vector2(6.5, -1.5), Vector2(6.0, 5.0), Vector2(1.0, 8.0)]), Color("#f45131"))
	draw_line(Vector2(0.0, -3.0), Vector2(0.0, 7.0), Color("#291d17"), 1.2, true)
	for spot in [Vector2(-3.5, 0.0), Vector2(-3.0, 4.5), Vector2(3.5, 0.0), Vector2(3.0, 4.5)]:
		draw_circle(spot, 1.1, Color("#332119"))
	draw_circle(Vector2(0.0, -5.0), 3.1, Color("#2c291b"))
	draw_line(Vector2(-1.6, -6.8), Vector2(-3.5, -9.5), Color("#2c291b"), 1.0, true)
	draw_line(Vector2(1.6, -6.8), Vector2(3.5, -9.5), Color("#2c291b"), 1.0, true)
	draw_circle(Vector2(-3.2, -1.8), 1.2, Color("#ffaf79", 0.75))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
