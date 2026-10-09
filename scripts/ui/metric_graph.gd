class_name MetricGraph
extends Control

const ComicUI := preload("res://scripts/ui/comic_ui.gd")
const PaintedPanels := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const FontSemiBold := preload("res://assets/fonts/Poppins-SemiBold.ttf")

var samples: Array[Dictionary] = []
var painted_style := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	set_meta("component", "comic_metric_graph_v1")
	set_meta("ui_kit", "comic_ui_v1")


func set_samples(value: Array[Dictionary]) -> void:
	samples = value
	queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var graph_rect := Rect2(28, 36, maxf(40.0, size.x - 42.0), maxf(70.0, size.y - 82.0))
	var graph_style: StyleBox = PaintedPanels.box("cream", 0) if painted_style else ComicUI.style_box(Color("#123f5b"), ComicUI.INK, 3, 12, Color("#0c1720", 0.26), 2, 0.0)
	draw_style_box(graph_style, graph_rect)
	for row in range(5):
		var y := graph_rect.position.y + graph_rect.size.y * float(row) / 4.0
		draw_line(Vector2(graph_rect.position.x + 4.0, y), Vector2(graph_rect.end.x - 4.0, y), Color("#355b40", 0.16) if painted_style else Color(1, 1, 1, 0.14), 1.0, true)
	for column in range(7):
		var x := graph_rect.position.x + graph_rect.size.x * float(column) / 6.0
		draw_line(Vector2(x, graph_rect.position.y + 4.0), Vector2(x, graph_rect.end.y - 4.0), Color("#355b40", 0.12) if painted_style else Color(1, 1, 1, 0.10), 1.0, true)
	if samples.size() >= 2:
		_draw_series(graph_rect, "biomass", 42.0, _series_color(0))
		_draw_series(graph_rect, "light", 30000.0, _series_color(1))
		_draw_series(graph_rect, "co2", 520.0, _series_color(2), 380.0)
		_draw_series(graph_rect, "oxygen", 5.0, _series_color(3), -2.0)
	else:
		draw_string(FontSemiBold, graph_rect.get_center() + Vector2(-72, 4), "SBÍRÁM PRVNÍ DATA…", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, ComicUI.NAVY if painted_style else ComicUI.CREAM)
	draw_string(FontSemiBold, Vector2(29, 23), "POSLEDNÍCH 72 MĚŘENÍ", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, ComicUI.INK)
	_draw_legend(Vector2(30, size.y - 17), maxf(78.0, (size.x - 48.0) / 4.0))


func _draw_series(rect: Rect2, key: String, max_value: float, color: Color, min_value := 0.0) -> void:
	var points := PackedVector2Array()
	var count := samples.size()
	for index in range(count):
		var sample: Dictionary = samples[index]
		var normalized := inverse_lerp(min_value, max_value, float(sample.get(key, min_value)))
		var x := rect.position.x + rect.size.x * float(index) / float(maxi(1, count - 1))
		var y := rect.end.y - rect.size.y * clampf(normalized, 0.0, 1.0)
		points.append(Vector2(x, y))
	if points.size() >= 2:
		draw_polyline(points, Color("#07131c", 0.55), 5.0, true)
		draw_polyline(points, color, 2.5, true)


func _draw_legend(start: Vector2, entry_width: float) -> void:
	var entries := [
		["BIOMASA", _series_color(0)],
		["SVĚTLO", _series_color(1)],
		["CO₂", _series_color(2)],
		["O₂ BIL.", _series_color(3)],
	]
	for index in range(entries.size()):
		var x := start.x + entry_width * index
		draw_circle(Vector2(x + 5, start.y - 4), 4.0, entries[index][1])
		draw_string(FontSemiBold, Vector2(x + 13, start.y), entries[index][0], HORIZONTAL_ALIGNMENT_LEFT, entry_width - 15.0, 8, ComicUI.NAVY)


func _series_color(index: int) -> Color:
	var palette := [Color("#388132"), Color("#b9740b"), Color("#127c93"), Color("#9953ac")] if painted_style else [ComicUI.GREEN, ComicUI.GOLD, ComicUI.CYAN, Color("#f7a8ff")]
	return palette[index]
