extends Control
## Presentation only. Raw generated PNGs stay unchanged; filling is a shader.

const Cup := preload("res://prototypes/teahouse/art/tea-cup-v2.png")
const Pot := preload("res://prototypes/teahouse/art/tea-pot-v2.png")
const FillShader := preload("res://prototypes/teahouse/tea_cup_fill.gdshader")
const MOUTH := Vector2(0.469, 0.292)
const SPOUT := Vector2(0.086, 0.406)
var cup: TextureRect
var pot: TextureRect
var stream_layer: Control
var fill_material: ShaderMaterial
var tilt := 0.0
var clock := 0.0
var liquid := 0.0
var active := false
var reduced := false
var celebration := -1.0


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	position = Vector2(32, 440)
	size = Vector2(368, 270)
	cup = _sprite(Cup, Rect2(8, 30, 280, 260))
	fill_material = ShaderMaterial.new()
	fill_material.shader = FillShader
	cup.material = fill_material
	stream_layer = Control.new()
	stream_layer.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(stream_layer)
	stream_layer.draw.connect(_draw_stream)
	pot = _sprite(Pot, Rect2(190, -24, 180, 180))
	pot.pivot_offset = pot.size * Vector2(0.64, 0.60)


func _sprite(texture: Texture2D, rect: Rect2) -> TextureRect:
	var result := TextureRect.new()
	result.texture = texture
	result.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	result.stretch_mode = TextureRect.STRETCH_SCALE
	result.texture_filter = TEXTURE_FILTER_LINEAR
	result.mouse_filter = MOUSE_FILTER_IGNORE
	result.position = rect.position
	result.size = rect.size
	add_child(result)
	return result


func update_visual(fill: float, pour_tilt: float, pouring: bool, animation_clock: float, success_age: float, calm: bool) -> void:
	if fill_material == null: return
	liquid = fill
	tilt = pour_tilt
	active = pouring
	reduced = calm
	clock = animation_clock
	celebration = success_age
	fill_material.set_shader_parameter("fill_ratio", fill)
	fill_material.set_shader_parameter("animation_time", 0.0 if calm else animation_clock)
	var ease := smoothstep(0.0, 1.0, pour_tilt)
	pot.size = Vector2.ONE * lerpf(140.0, 180.0, ease)
	pot.position = Vector2(238, 108).lerp(Vector2(190, -24), ease)
	pot.pivot_offset = pot.size * Vector2(0.64, 0.60)
	pot.rotation = -0.26 * ease
	stream_layer.queue_redraw()


func stream_origin() -> Vector2:
	return pot.position + pot.pivot_offset + (pot.size * SPOUT - pot.pivot_offset).rotated(pot.rotation)


func stream_destination() -> Vector2:
	return cup.position + cup.size * MOUTH + Vector2(0, 4)


func _draw_stream() -> void:
	var destination := stream_destination()
	# Its soft contact shadow stays on the counter as the pot lifts.
	var contact := Vector2(316, 226)
	for i in range(3):
		var radius := Vector2(37 - i * 6, 6 - i)
		stream_layer.draw_set_transform_matrix(Transform2D(Vector2(radius.x, 0), Vector2(0, radius.y), contact))
		stream_layer.draw_circle(Vector2.ZERO, 1, Color(0.34, 0.28, 0.10, (1.0 - tilt) * 0.05))
	stream_layer.draw_set_transform(Vector2.ZERO)
	if active and tilt > 0.15:
		var start := stream_origin()
		var control := start + Vector2(-30, 5)
		var points := PackedVector2Array()
		for i in range(25):
			var t := i / 24.0
			var point := (1.0 - t) * (1.0 - t) * start + 2.0 * (1.0 - t) * t * control + t * t * destination
			if not reduced:
				point.x += sin(t * 11.0 + clock * 9.0) * sin(t * PI) * 0.65
			points.append(point)
		var alpha := smoothstep(0.15, 0.85, tilt)
		stream_layer.draw_polyline(points, Color(0.84, 0.86, 0.61, alpha * 0.40), 7, true)
		stream_layer.draw_polyline(points, Color(0.99, 0.93, 0.70, alpha * 0.85), 2.8, true)
		if not reduced:
			for i in range(3):
				var progress := fmod(clock * 2.1 + i / 3.0, 1.0)
				var point := (1.0 - progress) * (1.0 - progress) * start + 2.0 * (1.0 - progress) * progress * control + progress * progress * destination
				stream_layer.draw_circle(point, 1.5, Color(1.0, 0.99, 0.87, 0.6))
	if liquid > 0.08 and not reduced:
		for i in range(3):
			var steam := PackedVector2Array()
			for step in range(18):
				var t := step / 17.0
				steam.append(destination + Vector2((i - 1) * 20 + sin(clock * 1.1 + t * 4.4 + i) * 7, -13 - t * 42))
			stream_layer.draw_polyline(steam, Color(0.65, 0.69, 0.48, 0.28), 2, true)
	if celebration >= 0 and celebration < 2.0 and not reduced:
		var fade := sin(celebration / 2.0 * PI)
		for i in range(7):
			var angle := i * TAU / 7.0 + 0.3
			var point := destination + Vector2(cos(angle) * 104, 35 + sin(angle) * 70 - celebration * 7)
			var radius := 2.5 + sin(celebration * 4 + i) * 1.2
			var diamond := PackedVector2Array([point + Vector2(0, -radius * 1.7), point + Vector2(radius, 0), point + Vector2(0, radius * 1.7), point + Vector2(-radius, 0)])
			stream_layer.draw_colored_polygon(diamond, Color(0.83, 0.65, 0.22, fade * 0.8))
