extends Control
## Small painted highlight follows the real progress value, including zero.

func _draw() -> void:
	var progress := get_parent() as ProgressBar
	if progress == null or progress.ratio <= 0.04:
		return
	var end := (size.x - 4.0) * progress.ratio - 4.0
	if end > 6.0:
		draw_line(Vector2(6, 4), Vector2(end, 4), Color("#b5f45b"), 2.0, true)
