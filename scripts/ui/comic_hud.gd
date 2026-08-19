extends Control

const ComicUI := preload("res://scripts/ui/comic_ui.gd")

const CARD_RECTS := [
	Rect2(0.005, 0.02, 0.324, 0.96),
	Rect2(0.335, 0.02, 0.319, 0.96),
	Rect2(0.659, 0.02, 0.336, 0.96),
]
const CARD_FILLS := [
	Color("#147d91"),
	Color("#176f96"),
	Color("#5d43a7"),
]
const CARD_ACCENTS := [ComicUI.CYAN, ComicUI.GOLD, Color("#d77cff")]


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	set_meta("component", "comic_hud_surface_v1")
	set_meta("ui_kit", "comic_ui_v1")
	queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var base := ComicUI.style_box(ComicUI.NAVY, ComicUI.INK, 3, 0, Color("#07131c", 0.42), 3, 0.0)
	draw_style_box(base, Rect2(Vector2.ZERO, size))
	for index in range(CARD_RECTS.size()):
		var card_rect := _scaled_rect(CARD_RECTS[index]).grow(-3.0)
		var card := ComicUI.style_box(CARD_FILLS[index], ComicUI.INK, 3, 13, Color("#07131c", 0.38), 3, 0.0)
		draw_style_box(card, card_rect)
		var highlight_start := Vector2(card_rect.position.x + 12.0, card_rect.position.y + 7.0)
		var highlight_end := Vector2(card_rect.end.x - 12.0, card_rect.position.y + 7.0)
		draw_line(highlight_start, highlight_end, Color(CARD_ACCENTS[index], 0.90), 2.0, true)
	_draw_day_emblem(_scaled_rect(Rect2(0.024, 0.12, 0.145, 0.76)))


func _scaled_rect(normalized: Rect2) -> Rect2:
	return Rect2(normalized.position * size, normalized.size * size)


func _draw_day_emblem(rect: Rect2) -> void:
	var center := rect.get_center()
	var radius := minf(rect.size.x, rect.size.y) * 0.29
	for ray_index in range(8):
		var angle := TAU * float(ray_index) / 8.0
		var ray_start := center + Vector2.from_angle(angle) * (radius + 2.0)
		var ray_end := center + Vector2.from_angle(angle) * (radius + 7.0)
		draw_line(ray_start, ray_end, ComicUI.GOLD, 3.0, true)
	draw_circle(center + Vector2(1.5, 2.5), radius + 3.0, Color("#07131c", 0.40))
	draw_circle(center, radius + 3.0, ComicUI.INK)
	draw_circle(center, radius, ComicUI.GOLD)
	draw_circle(center - Vector2(radius * 0.22, radius * 0.24), radius * 0.42, Color("#fff8a6", 0.75))
