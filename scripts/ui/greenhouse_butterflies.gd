class_name GreenhouseButterflies
extends Control
## Occasional painted visitors. This presentation layer has no gameplay state.

const Butterfly := preload("res://assets/ui/greenhouse/butterfly_flight_v2.png")
const Wings := preload("res://scripts/ui/greenhouse_butterfly_wings.gdshader")
const Aura := preload("res://scripts/ui/greenhouse_butterfly_aura.gdshader")
const FLIGHT_SECONDS := 12.0
const VISITOR_SIZES := [58.0, 54.0, 56.0]
const VISITOR_DELAYS := [0.0, 0.85, 1.7]
const VISITOR_DURATIONS := [9.4, 9.8, 10.0]
const MAX_BANK := PI / 12.0
const PAINT_PIXELS := 320.0
const FRAME_COUNT := 12
var quiet_remaining := 5.0
var flight_elapsed := -1.0
var pass_index := 0
var reduced_motion := false
var visitors: Array[Sprite2D] = []
var auras: Array[ColorRect] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip_contents = true
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	for index in range(VISITOR_SIZES.size()):
		var visitor := Sprite2D.new()
		visitor.name = "PaintedButterfly%d" % index
		visitor.texture = Butterfly
		visitor.hframes = 4
		visitor.vframes = 3
		visitor.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		var wings := ShaderMaterial.new()
		wings.shader = Wings
		visitor.material = wings
		visitor.scale = Vector2.ONE * VISITOR_SIZES[index] / PAINT_PIXELS
		visitor.visible = false
		add_child(visitor)
		visitors.append(visitor)
		# A separate, soft backdrop preserves the painted wings and body.
		var aura := ColorRect.new()
		aura.name = "GoldenAura"
		aura.mouse_filter = Control.MOUSE_FILTER_IGNORE
		aura.size = Vector2.ONE * PAINT_PIXELS * 1.6
		aura.position = -aura.size * 0.5
		aura.show_behind_parent = true
		var glow := ShaderMaterial.new()
		glow.shader = Aura
		glow.set_shader_parameter("butterfly_texture_image", Butterfly)
		aura.material = glow
		visitor.add_child(aura)
		auras.append(aura)
	resized.connect(refresh)


func advance(delta: float) -> void:
	if reduced_motion:
		return
	var step := maxf(0.0, delta)
	if flight_elapsed < 0.0:
		quiet_remaining -= step
		if quiet_remaining > 0.0:
			return
		flight_elapsed = 0.0
		pass_index += 1
	else:
		flight_elapsed += step
	if flight_elapsed >= FLIGHT_SECONDS:
		flight_elapsed = -1.0
		quiet_remaining = 15.0 + float(pass_index % 4) * 2.0
	refresh()


func set_reduced_motion(value: bool) -> void:
	reduced_motion = value
	refresh()


func reset_visitors() -> void:
	flight_elapsed = -1.0
	quiet_remaining = 5.0
	refresh()


func flight_position(index: int, progress: float) -> Vector2:
	var t := clampf(progress, 0.0, 1.0)
	var points := [Vector2(-0.08, 0.58), Vector2(0.20, 0.46), Vector2(0.34, 0.29), Vector2(1.08, 0.40)]
	if index == 1:
		points = [Vector2(1.08, 0.72), Vector2(0.82, 0.49), Vector2(0.70, 0.44), Vector2(-0.08, 0.63)]
	elif index == 2:
		points = [Vector2(-0.08, 0.75), Vector2(0.32, 0.57), Vector2(0.65, 0.70), Vector2(1.08, 0.53)]
	var position: Vector2 = points[0].bezier_interpolate(points[1], points[2], points[3], t)
	if pass_index % 2 == 0:
		position.x = 1.0 - position.x
	position *= size
	position.y += sin(t * TAU * 2.0 + index) * 5.0 * sin(t * PI)
	return position


func flight_rotation(index: int, progress: float) -> float:
	var tangent := flight_position(index, minf(1.0, progress + 0.002)) - flight_position(index, maxf(0.0, progress - 0.002))
	# A front/three-quarter painted view banks gently; it must not roll as a card.
	var heading := atan2(tangent.y, maxf(absf(tangent.x), 0.001))
	return clampf(signf(tangent.x) * deg_to_rad(10.0) + heading * 0.22, -MAX_BANK, MAX_BANK)


func refresh() -> void:
	for index in range(visitors.size()):
		var visitor := visitors[index]
		var progress: float = (flight_elapsed - VISITOR_DELAYS[index]) / VISITOR_DURATIONS[index]
		visitor.visible = not reduced_motion and flight_elapsed >= 0.0 and progress >= 0.0 and progress <= 1.0
		if not visitor.visible:
			continue
		visitor.position = flight_position(index, progress)
		visitor.rotation = flight_rotation(index, progress)
		visitor.modulate.a = smoothstep(0.0, 0.07, progress) * (1.0 - smoothstep(0.93, 1.0, progress))
		var wing_phase := flight_elapsed * TAU * (2.8 + index * 0.15) + index * 1.6
		var material := visitor.material as ShaderMaterial
		var frame_position := fposmod(wing_phase / TAU, 1.0) * FRAME_COUNT
		var current_frame := int(floor(frame_position))
		var next_frame := (current_frame + 1) % FRAME_COUNT
		var frame_mix := frame_position - current_frame
		visitor.frame = current_frame
		material.set_shader_parameter("current_frame", current_frame)
		material.set_shader_parameter("next_frame", next_frame)
		material.set_shader_parameter("frame_mix", frame_mix)
		# Use the same paused clock as flight, rather than the shader TIME clock.
		var glow := auras[index].material as ShaderMaterial
		glow.set_shader_parameter("phase", flight_elapsed * 1.7 + index * 2.1)
		glow.set_shader_parameter("current_frame", current_frame)
		glow.set_shader_parameter("next_frame", next_frame)
		glow.set_shader_parameter("frame_mix", frame_mix)
