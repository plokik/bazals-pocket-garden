extends "res://scripts/ui/plant_view.gd"
## The actual species/stage art and measured planter geometry remain shared.

func canopy_offset(source_y: float, texture_height: float) -> float:
	if reduced_motion or simulation == null or not simulation.is_growing() or _uses_sick_visual():
		return 0.0
	var weight := pow(maxf(0.0, (0.58 - source_y / texture_height) / 0.58), 1.6)
	return weight * (sin(animation_time * 1.35 + source_y * 0.006) * 3.1 + sin(animation_time * 5.5) * wind_animation * 8.0)


func _draw_grounded_plant(geometry: Dictionary) -> void:
	if simulation.stage == PlantSimulation.Stage.EMPTY or _uses_sick_visual():
		super._draw_grounded_plant(geometry)
		return
	var texture: Texture2D = geometry.texture
	var target: Rect2 = geometry.plant_rect
	var source_size := texture.get_size()
	var scale_factor := target.size.y / source_size.y
	var stress := maxf(0.0, 1.0 - simulation.health / 100.0) * 0.22
	var tint := Color.WHITE.lerp(Color("#d2b773"), stress).lerp(_state_tint(), 0.62)
	if golden_shine_animation > 0.0:
		tint = tint.lerp(Color("#ffe36a"), sin((1.0 - golden_shine_animation) * PI) * 0.46)
	# Horizontal strips move only the upper leaves. Pot, soil and saucer stay still.
	# Clamp to the viewport independently of the immutable geometry contract.
	for row in range(0, int(source_size.y), 8):
		var height := minf(8.0, source_size.y - row)
		var offset := clampf(canopy_offset(float(row), source_size.y), -target.position.x, size.x - target.end.x)
		var dest := Rect2(target.position + Vector2(offset, row * scale_factor), Vector2(target.size.x, height * scale_factor))
		draw_texture_rect_region(texture, dest, Rect2(0, row, source_size.x, height), tint)
