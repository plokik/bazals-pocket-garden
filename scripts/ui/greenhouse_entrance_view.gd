class_name GreenhouseEntranceView
extends Control
## Painted exterior. Only the authored door target requests entry; no gameplay
## or save state is owned by this presentation component.

signal enter_requested
signal rack_requested
signal door_opened
signal decoration_requested

const Exterior := preload("res://assets/ui/greenhouse/greenhouse_exterior_v1.png")
const TEA_EXTERIOR_PATH := "res://assets/ui/greenhouse/tea_tree_exterior_v1.png"
const PaintedArt := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const TitleFont := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const Ink := Color("#264236")
const DoorEffect := preload("res://scripts/ui/greenhouse_door_effect.gdshader")
const Butterflies := preload("res://scripts/ui/greenhouse_butterflies.gd")
const OPEN_SECONDS := 0.56
const SHINE_CYCLE := 8.5
const SHINE_START := 2.0
const SHINE_SECONDS := 1.5
# Pixel bounds of the closed door in the unchanged 938x1677 source image.
const DOOR_SOURCE := Rect2(353.0, 577.0, 283.0, 658.0)

var door_button: Button
var back_button: Button
var title_panel: PanelContainer
var hint_panel: PanelContainer
var ambient_phase := 0.0
var animations_paused := false
var reduced_motion := false
var app_paused := false
var opening := false
var opening_progress := 0.0
var art_texture: TextureRect
var art_material: ShaderMaterial
var butterflies: GreenhouseButterflies
var decoration_button: Button
var tea_tree_owned := false
var tea_wind_phase := 0.0
var tea_exterior: Texture2D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	set_meta("component", "painted_greenhouse_entrance_v1")
	set_meta("location_id", "greenhouse_exterior")
	art_texture = TextureRect.new()
	art_texture.name = "PaintedExterior"
	art_texture.texture = Exterior
	art_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art_texture.stretch_mode = TextureRect.STRETCH_SCALE
	art_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_material = ShaderMaterial.new()
	art_material.shader = DoorEffect
	art_texture.material = art_material
	add_child(art_texture)
	butterflies = Butterflies.new()
	butterflies.name = "GardenButterflies"
	add_child(butterflies)
	title_panel = _plaque("SKLENÍK", "VENKOVNÍ ZAHRADA", "sage")
	hint_panel = _plaque("KLEPNI NA DVEŘE", "Vstup do svého skleníku", "cream")
	back_button = Button.new()
	back_button.text = "←  STOJAN"
	back_button.add_theme_font_override("font", TitleFont)
	back_button.add_theme_font_size_override("font_size", 12)
	for state in ["normal", "hover", "pressed", "disabled"]:
		back_button.add_theme_stylebox_override(state, PaintedArt.box("sage" if state == "pressed" else "cream", 6.0))
	for state in ["font_color", "font_hover_color", "font_pressed_color"]:
		back_button.add_theme_color_override(state, Ink)
	back_button.set_meta("touch_target_min", Vector2(124.0, 64.0))
	back_button.pressed.connect(func(): rack_requested.emit())
	add_child(back_button)
	decoration_button = Button.new()
	decoration_button.name = "GardenDecorations"
	decoration_button.text = "DEKORACE\nZAHRADY"
	decoration_button.tooltip_text = "Čajovníkový stromek · trvalá dekorace za mince"
	decoration_button.add_theme_font_override("font", TitleFont)
	decoration_button.add_theme_font_size_override("font_size", 11)
	for state in ["normal", "hover", "pressed", "disabled"]:
		decoration_button.add_theme_stylebox_override(state, PaintedArt.box("sage" if state == "pressed" else "cream", 6.0))
	for state in ["font_color", "font_hover_color", "font_pressed_color"]:
		decoration_button.add_theme_color_override(state, Ink)
	decoration_button.set_meta("touch_target_min", Vector2(124.0, 64.0))
	decoration_button.pressed.connect(func(): decoration_requested.emit())
	add_child(decoration_button)
	door_button = Button.new()
	door_button.name = "GreenhouseDoor"
	door_button.text = ""
	door_button.tooltip_text = "Vstoupit do skleníku"
	door_button.set_meta("component", "painted_greenhouse_door_target_v1")
	door_button.set_meta("touch_target_min", Vector2(64.0, 64.0))
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		door_button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	door_button.mouse_entered.connect(_refresh_art)
	door_button.mouse_exited.connect(_refresh_art)
	door_button.focus_entered.connect(_refresh_art)
	door_button.focus_exited.connect(_refresh_art)
	door_button.pressed.connect(func(): enter_requested.emit())
	add_child(door_button)
	resized.connect(_layout)
	visibility_changed.connect(_on_visibility_changed)
	_layout()


func _plaque(title: String, subtitle: String, kind: String) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", PaintedArt.box(kind, 6.0))
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var lines := VBoxContainer.new()
	lines.alignment = BoxContainer.ALIGNMENT_CENTER
	lines.add_theme_constant_override("separation", 0)
	lines.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for text in [title, subtitle]:
		var label := Label.new()
		label.text = text
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_font_override("font", TitleFont)
		label.add_theme_font_size_override("font_size", 17 if text == title else 9)
		label.add_theme_color_override("font_color", Ink)
		lines.add_child(label)
	panel.add_child(lines)
	add_child(panel)
	return panel


func _art_rect() -> Rect2:
	var source := Vector2(Exterior.get_size())
	var scale := maxf(size.x / source.x, size.y / source.y)
	var painted_size := source * scale
	return Rect2((size - painted_size) * 0.5, painted_size)


func door_rect() -> Rect2:
	var art := _art_rect()
	var scale := art.size.x / float(Exterior.get_width())
	return Rect2(art.position + DOOR_SOURCE.position * scale, DOOR_SOURCE.size * scale)


func visitor_visibility(feet: Vector2, half_width: float) -> float:
	# Cover framing can raise the foreground pots into the old horizontal route.
	# On those wider canvases visitors emerge only into the clear central path,
	# with a short soft entry/exit rather than crossing the painted ceramics.
	var art := _art_rect()
	var scale := art.size.x / float(Exterior.get_width())
	var pot_front := art.position.y + 1348.0 * scale
	if feet.y >= pot_front + 4.0:
		return 1.0
	var left := art.position.x + 349.0 * scale + half_width + 4.0
	var right := art.position.x + 700.0 * scale - half_width - 4.0
	if right - left < 24.0:
		return 0.0
	var fade := minf(18.0, (right - left) * 0.25)
	return smoothstep(left, left + fade, feet.x) * (1.0 - smoothstep(right - fade, right, feet.x))


func _layout() -> void:
	if door_button == null:
		return
	var art := _art_rect()
	art_texture.position = art.position
	art_texture.size = art.size
	butterflies.size = size
	var door := door_rect()
	door_button.position = door.position
	door_button.size = door.size
	title_panel.position = Vector2((size.x - 264.0) * 0.5, 8.0)
	title_panel.size = Vector2(264.0, 58.0)
	back_button.position = Vector2(10.0, 76.0)
	back_button.size = Vector2(124.0, 64.0)
	decoration_button.position = Vector2(size.x - 134.0, 76.0)
	decoration_button.size = Vector2(124.0, 64.0)
	hint_panel.position = Vector2((size.x - 280.0) * 0.5, size.y - 78.0)
	hint_panel.size = Vector2(280.0, 58.0)
	_refresh_art()


func set_paused(value: bool) -> void:
	animations_paused = value


func begin_opening() -> void:
	if opening or not is_visible_in_tree():
		return
	opening = true
	opening_progress = 0.0
	door_button.disabled = true
	if reduced_motion:
		_advance_opening(OPEN_SECONDS)
	_refresh_art()


func _on_visibility_changed() -> void:
	_sync_exterior_texture()
	if not is_visible_in_tree():
		if butterflies != null:
			butterflies.reset_visitors()
		opening = false
		opening_progress = 0.0
		if door_button != null:
			door_button.disabled = false
		_refresh_art()


func _advance_opening(delta: float) -> void:
	if not opening:
		return
	opening_progress = minf(1.0, opening_progress + maxf(0.0, delta) / OPEN_SECONDS)
	_refresh_art()
	if opening_progress >= 1.0:
		opening = false
		door_opened.emit()


func set_reduced_motion(value: bool) -> void:
	reduced_motion = value
	if butterflies != null:
		butterflies.set_reduced_motion(value)
	_refresh_art()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		app_paused = true
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		app_paused = false


func _process(delta: float) -> void:
	if not is_visible_in_tree() or animations_paused or app_paused:
		return
	if opening:
		_advance_opening(delta if not reduced_motion else OPEN_SECONDS)
	if reduced_motion:
		return
	if not opening:
		butterflies.advance(delta)
	if tea_tree_owned:
		tea_wind_phase = fposmod(tea_wind_phase + maxf(0.0, delta) * 0.65, TAU)
	ambient_phase = fmod(ambient_phase + maxf(0.0, delta), SHINE_CYCLE)
	_refresh_art()


func _handle_angle() -> float:
	if not opening or reduced_motion:
		return 0.0
	var pull := smoothstep(0.0, 0.42, opening_progress) * (1.0 - smoothstep(0.62, 1.0, opening_progress))
	return -deg_to_rad(24.0) * pull


func _shine_progress() -> float:
	if reduced_motion or opening or ambient_phase < SHINE_START or ambient_phase > SHINE_START + SHINE_SECONDS:
		return -1.0
	return (ambient_phase - SHINE_START) / SHINE_SECONDS


func _handle_magic_progress() -> float:
	return opening_progress if opening and not reduced_motion else -1.0


func _refresh_art() -> void:
	if art_material == null:
		return
	art_material.set_shader_parameter("handle_angle", _handle_angle())
	art_material.set_shader_parameter("handle_magic_phase", _handle_magic_progress())
	art_material.set_shader_parameter("shine_phase", _shine_progress())
	var hovered := door_button != null and not opening and (door_button.is_hovered() or door_button.has_focus())
	art_material.set_shader_parameter("focus_strength", 0.24 if hovered else 0.0)
	art_material.set_shader_parameter("tea_wind_phase", tea_wind_phase)
	art_material.set_shader_parameter("tea_motion_strength", 1.0 if tea_tree_owned and not reduced_motion else 0.0)


func set_tea_tree_owned(value: bool) -> void:
	tea_tree_owned = value
	_sync_exterior_texture()
	_refresh_art()


func _sync_exterior_texture() -> void:
	if art_texture == null:
		return
	# Defer this optional full-size painting until the player visits their
	# purchased decoration. The original startup and unpaid garden stay intact.
	if tea_tree_owned and is_visible_in_tree():
		if tea_exterior == null:
			tea_exterior = load(TEA_EXTERIOR_PATH) as Texture2D
		art_texture.texture = tea_exterior if tea_exterior != null else Exterior
	elif not tea_tree_owned:
		art_texture.texture = Exterior
