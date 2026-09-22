extends VBoxContainer
## Candidate presentation; it never owns or mutates simulation state.

const Art := preload("res://scripts/ui/plant_detail_painted_assets.gd")


func _ready() -> void:
	set_meta("component", "painted_detail_surface_bridge_v1")
	resized.connect(queue_redraw)
	queue_redraw()


func _draw() -> void:
	draw_style_box(Art.box("wood", 0), Rect2(Vector2.ZERO, size))
