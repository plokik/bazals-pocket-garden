extends "res://scripts/ui/plant_view.gd"
## The actual species/stage art and measured planter geometry remain shared.

func canopy_offset(source_y: float, texture_height: float) -> float:
	if reduced_motion or simulation == null or not simulation.is_growing() or _uses_sick_visual():
		return 0.0
	var weight := pow(maxf(0.0, (0.58 - source_y / texture_height) / 0.58), 1.6)
	return weight * (sin(animation_time * 1.35 + source_y * 0.006) * 3.1 + sin(animation_time * 5.5) * wind_animation * 8.0)


func canopy_vertical_offset(source_y: float, texture_height: float, display_height: float) -> float:
	if reduced_motion or simulation == null or not simulation.is_growing() or _uses_sick_visual():
		return 0.0
	# The painted pot occupies the lower third of the sheet and stays grounded.
	var weight := pow(maxf(0.0, (0.67 - source_y / texture_height) / 0.67), 1.5)
	var growth_progress := 1.0 - growth_burst_animation
	var growth_pop := sin(clampf(growth_progress / 0.72, 0.0, 1.0) * PI) * growth_burst_animation * display_height * 0.075
	var water_progress := 1.0 - water_animation
	var water_spring := sin(water_progress * PI * 2.5) * water_animation * display_height * 0.027
	return weight * (water_spring - growth_pop)


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
		var top_y := target.position.y + row * scale_factor + canopy_vertical_offset(float(row), source_size.y, target.size.y)
		var bottom_y := target.position.y + (row + height) * scale_factor + canopy_vertical_offset(float(row) + height, source_size.y, target.size.y)
		var dest := Rect2(Vector2(target.position.x + offset, top_y), Vector2(target.size.x, maxf(0.5, bottom_y - top_y + 0.25)))
		draw_texture_rect_region(texture, dest, Rect2(0, row, source_size.x, height), tint)
