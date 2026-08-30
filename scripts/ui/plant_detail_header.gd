extends HBoxContainer
## Rounded controls reveal the same dark surface as the surrounding HUD,
## never the global paper surface. This adds no child or input-catching layer.

const ComicTheme := preload("res://scripts/ui/comic_ui.gd")


func background_rect() -> Rect2:
	var gap := 0.0
	if get_parent() is VBoxContainer:
		gap = float(get_parent().get_theme_constant("separation"))
	return Rect2(Vector2.ZERO, size + Vector2(0.0, gap))


func _draw() -> void:
	draw_rect(background_rect(), ComicTheme.NAVY)
