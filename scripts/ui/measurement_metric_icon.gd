class_name MeasurementMetricIcon
extends Control

const FontExtraBold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")

var metric_id := "temperature"
var accent := Color("#ff8a1f")
var compact_draw := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(24.0, 24.0) if compact_draw else Vector2(42.0, 42.0)
	set_meta("component", "phase154_painted_metric_icon_v1")
	set_meta("rendering", "smooth_vector_ui_icon_no_pixel_art_v1")
	resized.connect(queue_redraw)


func configure(value: String, color: Color) -> void:
	metric_id = value
	accent = color
	set_meta("metric_id", metric_id)
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.43
	if compact_draw:
		draw_set_transform(center, 0.0, Vector2.ONE * minf(size.x, size.y) / 42.0)
		center = Vector2.ZERO
		radius = 42.0 * 0.43
	draw_circle(center + Vector2(0.0, 2.0), radius, Color("#3d2514", 0.22))
	draw_circle(center, radius, Color("#fff5cf"))
	draw_arc(center, radius, 0.0, TAU, 48, accent.darkened(0.28), 2.0, true)
	match metric_id:
		"temperature":
			_draw_thermometer(center)
		"humidity":
			_draw_drop(center, accent)
		"ph":
			_draw_drop(center, accent)
			draw_string(FontExtraBold, center + Vector2(-10.0, 5.0), "pH", HORIZONTAL_ALIGNMENT_CENTER, 20.0, 9, Color("#fff8dc"))
		"ec":
			_draw_lightning(center)
		"light":
			_draw_sun(center)
		"co2":
			_draw_leaf(center + Vector2(0.0, -2.0))
			draw_string(FontExtraBold, center + Vector2(-12.0, 13.0), "CO₂", HORIZONTAL_ALIGNMENT_CENTER, 24.0, 7, Color("#17462b"))
		"oxygen":
			_draw_bubbles(center)
		"oxygen_balance":
			_draw_balance(center)
		"biomass":
			_draw_sprout(center)
		"weather":
			_draw_weather(center)


func _draw_thermometer(center: Vector2) -> void:
	draw_line(center + Vector2(0.0, -12.0), center + Vector2(0.0, 6.0), Color("#7b2c18"), 7.0, true)
	draw_line(center + Vector2(0.0, -12.0), center + Vector2(0.0, 6.0), Color("#ff7d1f"), 3.0, true)
	draw_circle(center + Vector2(0.0, 9.0), 7.0, Color("#7b2c18"))
	draw_circle(center + Vector2(0.0, 9.0), 4.5, Color("#ff7d1f"))


func _draw_drop(center: Vector2, color: Color) -> void:
	var points := PackedVector2Array([
		center + Vector2(0.0, -14.0),
		center + Vector2(-10.0, 1.0),
		center + Vector2(-8.0, 9.0),
		center + Vector2(0.0, 13.0),
		center + Vector2(8.0, 9.0),
		center + Vector2(10.0, 1.0),
	])
	draw_colored_polygon(points, color.darkened(0.25))
	var inner := PackedVector2Array([
		center + Vector2(0.0, -10.0),
		center + Vector2(-6.0, 2.0),
		center + Vector2(-4.0, 7.0),
		center + Vector2(1.0, 9.0),
		center + Vector2(6.0, 4.0),
	])
	draw_colored_polygon(inner, color)


func _draw_lightning(center: Vector2) -> void:
	var bolt := PackedVector2Array([
		center + Vector2(2.0, -15.0),
		center + Vector2(-9.0, 2.0),
		center + Vector2(-1.0, 2.0),
		center + Vector2(-5.0, 15.0),
		center + Vector2(10.0, -4.0),
		center + Vector2(2.0, -4.0),
	])
	draw_colored_polygon(bolt, Color("#7a4a00"))
	var inner := bolt
	for index in range(inner.size()):
		inner[index] = center + (inner[index] - center) * 0.78
	draw_colored_polygon(inner, Color("#ffd928"))


func _draw_sun(center: Vector2) -> void:
	draw_circle(center, 8.0, Color("#f7a51b"))
	draw_circle(center + Vector2(-2.0, -2.0), 4.0, Color("#ffe34d"))
	for index in range(8):
		var direction := Vector2.RIGHT.rotated(TAU * float(index) / 8.0)
		draw_line(center + direction * 11.0, center + direction * 15.0, Color("#c66a11"), 2.0, true)


func _draw_leaf(center: Vector2) -> void:
	var leaf := PackedVector2Array([
		center + Vector2(-12.0, 5.0),
		center + Vector2(-7.0, -10.0),
		center + Vector2(8.0, -12.0),
		center + Vector2(12.0, 2.0),
		center + Vector2(2.0, 10.0),
	])
	draw_colored_polygon(leaf, Color("#4fae36"))
	draw_line(center + Vector2(-9.0, 6.0), center + Vector2(9.0, -8.0), Color("#174f2a"), 2.0, true)


func _draw_bubbles(center: Vector2) -> void:
	for bubble in [
		[Vector2(-7.0, 6.0), 7.0],
		[Vector2(5.0, 0.0), 5.0],
		[Vector2(-2.0, -9.0), 4.0],
	]:
		var bubble_center: Vector2 = center + bubble[0]
		var bubble_radius: float = bubble[1]
		draw_circle(bubble_center, bubble_radius, Color("#5ecfe0", 0.78))
		draw_arc(bubble_center, bubble_radius, 0.0, TAU, 24, Color("#247a95"), 1.5, true)


func _draw_balance(center: Vector2) -> void:
	draw_line(center + Vector2(0.0, -11.0), center + Vector2(0.0, 11.0), Color("#315628"), 2.5, true)
	draw_line(center + Vector2(-13.0, -6.0), center + Vector2(13.0, -6.0), Color("#315628"), 2.5, true)
	draw_line(center + Vector2(-10.0, -5.0), center + Vector2(-13.0, 5.0), Color("#315628"), 1.5, true)
	draw_line(center + Vector2(10.0, -5.0), center + Vector2(13.0, 5.0), Color("#315628"), 1.5, true)
	draw_arc(center + Vector2(-13.0, 6.0), 5.0, 0.0, PI, 16, Color("#6bb342"), 2.5, true)
	draw_arc(center + Vector2(13.0, 6.0), 5.0, 0.0, PI, 16, Color("#6bb342"), 2.5, true)
	draw_line(center + Vector2(-6.0, 11.0), center + Vector2(6.0, 11.0), Color("#315628"), 2.5, true)


func _draw_sprout(center: Vector2) -> void:
	draw_line(center + Vector2(0.0, 13.0), center + Vector2(0.0, -8.0), Color("#22542d"), 3.0, true)
	var left := PackedVector2Array([
		center + Vector2(-1.0, -3.0), center + Vector2(-13.0, -11.0), center + Vector2(-13.0, 2.0),
	])
	var right := PackedVector2Array([
		center + Vector2(1.0, -7.0), center + Vector2(13.0, -14.0), center + Vector2(12.0, -1.0),
	])
	draw_colored_polygon(left, Color("#79bd3f"))
	draw_colored_polygon(right, Color("#4f9f35"))


func _draw_weather(center: Vector2) -> void:
	draw_circle(center + Vector2(-6.0, -6.0), 7.0, Color("#ffd43b"))
	for index in range(6):
		var direction := Vector2.RIGHT.rotated(TAU * float(index) / 6.0)
		draw_line(center + Vector2(-6.0, -6.0) + direction * 9.0, center + Vector2(-6.0, -6.0) + direction * 12.0, Color("#d98512"), 1.5, true)
	draw_circle(center + Vector2(-5.0, 7.0), 7.0, Color("#e7f4e7"))
	draw_circle(center + Vector2(3.0, 3.0), 9.0, Color("#f7fbeb"))
	draw_circle(center + Vector2(11.0, 8.0), 6.0, Color("#e7f4e7"))
	draw_line(center + Vector2(-11.0, 12.0), center + Vector2(16.0, 12.0), Color("#78939a"), 2.0, true)
