extends "res://scripts/ui/plant_detail_header.gd"

const Art := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const SEAM_LEAF_ROTATIONS := [-1.42, -0.12, 1.18]
const SEAM_BACKING_OUTLINE := Color("#123c2a")
const SEAM_BACKING_GREEN := Color("#69bf32")
const SEAM_FLOWERS := [Color("#ff789f"), Color("#f786bb")]

var ornament_time := 0.0
var reduced_motion := false


func _ready() -> void:
	clip_contents = false
	set_meta("component", "painted_detail_header_bridge_v1")
	set_meta("outer_seam_ornament_count", 2)
	set_meta("outer_seam_coverage", "opaque_botanical_caps_over_white_hud_selector_wedges_v1")
	set_meta("outer_seam_content_protection", "drawn_behind_selector_controls_v1")
	set_meta("outer_seam_motion", "subtle_sway_1deg_reduced_motion_v1")
	resized.connect(queue_redraw)
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


func _draw() -> void:
	draw_style_box(Art.box("wood", 0), background_rect())
	_draw_outer_seam_botanicals()


func _draw_outer_seam_botanicals() -> void:
	var leaf := Art.texture("leaf")
	if leaf == null:
		return
	for side_index in range(2):
		var right_side := side_index == 1
		var center := Vector2(size.x if right_side else 0.0, 0.0)
		var phase := PI if right_side else 0.0
		var sway := 0.0 if reduced_motion else sin(ornament_time * 1.15 + phase) * 0.018
		# Child buttons paint over this backing. Only the exposed paper wedge stays
		# green, so the larger radius closes it without covering button content.
		draw_circle(center, 18.0, SEAM_BACKING_OUTLINE)
		draw_circle(center, 16.0, SEAM_BACKING_GREEN)
		for leaf_rotation in SEAM_LEAF_ROTATIONS:
			var mirrored_rotation: float = PI - float(leaf_rotation) if right_side else float(leaf_rotation)
			draw_set_transform(center, mirrored_rotation + sway)
			draw_texture_rect(leaf, Rect2(Vector2(-2.2, -12.8), Vector2(15.0, 15.0)), false)
		draw_set_transform(center, 0.0, Vector2.ONE)
		_draw_seam_flower(center, SEAM_FLOWERS[side_index])
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_seam_flower(center: Vector2, petal_color: Color) -> void:
	for index in range(5):
		var angle := -PI * 0.5 + TAU * float(index) / 5.0
		var petal_center := center + Vector2(cos(angle), sin(angle)) * 3.0
		draw_circle(petal_center, 2.65, Color("#15392e"))
		draw_circle(petal_center, 2.05, petal_color)
		draw_circle(petal_center + Vector2(-0.45, -0.5), 0.5, Color(1.0, 0.9, 0.95, 0.82))
	draw_circle(center, 2.8, Color("#4c2a11"))
	draw_circle(center, 2.15, Color("#ffd43b"))
	draw_circle(center + Vector2(-0.55, -0.6), 0.55, Color("#fff7ad"))
