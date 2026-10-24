extends "res://scripts/ui/player_room_collection_view.gd"
## Fixed painted workshop composition. Historical owned decorations and slot
## data remain available without placing old sprites over the new painting.

signal workshop_requested
signal teahouse_embedding_changed(embedded: bool)
const WorkshopBackground := preload("res://assets/ui/workshop/bazal_workshop_painted_shelves_v2.png")
var teahouse_embedded := false
var workbench_button: Button
var title_card: PanelContainer
var title_label: Label
var hint: Label


func _ready() -> void:
	super._ready()
	set_meta("workshop_room", true)
	set_meta("workshop_visual", "bazal_workshop_proposal_v1")
	set_meta("fixed_workshop_shelves", true)
	set_meta("workshop_shelf_art", "integrated_plants_and_tools_v2")
	set_plant_drag_enabled(false)
	title_card = PanelContainer.new()
	title_card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_card.add_theme_stylebox_override("panel", PaintedDetailArt.box("cream", 8))
	add_child(title_card)
	title_label = Label.new()
	title_label.text = "BAZALOVA DÍLNA"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.add_theme_font_override("font", FontExtraBold)
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.add_theme_color_override("font_color", Color("#243b2b"))
	title_card.add_child(title_label)
	workbench_button = _workshop_button("PŘIPRAVIT SMĚS")
	workbench_button.set_meta("component", "workshop_workbench_launcher_v1")
	# The 128px painted source still curves at the generic 19px slice. Keep
	# the whole rounded corner in each cap, so its outline joins continuously.
	workbench_button.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	for state in ["normal", "hover", "pressed", "disabled"]:
		var frame := PaintedDetailArt.box("cream" if state == "hover" else "sage", 5)
		for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
			frame.set_texture_margin(side, 26.0)
		if state == "pressed":
			frame.modulate_color = Color(0.90, 0.96, 0.87)
		workbench_button.add_theme_stylebox_override(state, frame)
	workbench_button.pressed.connect(func(): workshop_requested.emit())
	TooltipPolicy.apply(workbench_button, "Otevřít recepty a připravit směs ze suchých bylin")
	add_child(workbench_button)
	hint = Label.new()
	hint.text = "Tvoje bylinky mají další využití."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_override("font", FontSemiBold)
	hint.add_theme_font_size_override("font_size", 10)
	hint.add_theme_color_override("font_color", Color("#f5f5dc"))
	hint.add_theme_color_override("font_outline_color", Color("#25412b"))
	hint.add_theme_constant_override("outline_size", 3)
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(hint)
	_layout_navigation()
	_layout_decoration_buttons()


func _workshop_button(caption: String) -> Button:
	var button := Button.new()
	button.text = caption
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font", FontExtraBold)
	button.add_theme_font_size_override("font_size", 11)
	button.add_theme_color_override("font_color", Color("#243b2b"))
	button.add_theme_stylebox_override("normal", PaintedDetailArt.box("sage", 5))
	button.add_theme_stylebox_override("hover", PaintedDetailArt.box("cream", 5))
	button.add_theme_stylebox_override("pressed", PaintedDetailArt.box("sage", 5, Color(0.90, 0.96, 0.87)))
	button.z_index = 8
	return button


func _build_navigation() -> void:
	back_button = _workshop_button("←\nSTOJAN")
	back_button.set_meta("component", "phase103_player_room_rack_return_v1")
	back_button.pressed.connect(_on_back_pressed)
	add_child(back_button)
	theme_button = _workshop_button("VZHLED")
	theme_button.set_meta("component", "phase103_player_room_theme_launcher_v1")
	theme_button.pressed.connect(_on_theme_pressed)
	add_child(theme_button)
	# A single calm header, with two inset hit targets, leaves the cabinet
	# ledges fully visible instead of covering bought books and framed art.
	for button in [back_button,theme_button]:
		button.add_theme_stylebox_override("normal",StyleBoxEmpty.new())
		button.add_theme_font_size_override("font_size",9)


func _layout_navigation() -> void:
	if back_button == null or theme_button == null:
		return
	back_button.visible = not teahouse_embedded
	theme_button.visible = not teahouse_embedded
	if title_card != null:
		title_card.visible = not teahouse_embedded
	if teahouse_embedded:
		if workbench_button != null:
			workbench_button.position = Vector2(106, 508)
			workbench_button.size = Vector2(220, 54)
		if hint != null:
			hint.position = Vector2(54, 574)
			hint.size = Vector2(324, 24)
		return
	back_button.position = Vector2(12, 10)
	back_button.size = Vector2(64, 64)
	theme_button.position = Vector2(size.x - 76, 10)
	theme_button.size = Vector2(64, 64)
	if title_card != null:
		title_card.position = Vector2(12, 10)
		title_card.size = Vector2(size.x - 24, 64)
	if workbench_button != null:
		workbench_button.position = Vector2(size.x * 0.5 - 102, size.y * 0.637).round()
		workbench_button.size = Vector2(204, 56)
	if hint != null:
		hint.position = Vector2(12, size.y * 0.637 + 60)
		hint.size = Vector2(size.x - 24, 20)


func set_teahouse_embedded(embedded: bool) -> void:
	if teahouse_embedded == embedded:
		return
	teahouse_embedded = embedded
	set_meta("teahouse_embedded", embedded)
	_layout_navigation()
	queue_redraw()
	teahouse_embedding_changed.emit(embedded)


func _decoration_visual_centers(viewport_size: Vector2) -> PackedVector2Array:
	var centers := PackedVector2Array()
	for side in range(2):
		for row in range(3):
			for column in range(2):
				# Contact points measured on the painted ledges, inside both posts.
				var shelf_x: float = [[0.094, 0.219], [0.789, 0.915]][side][column]
				centers.append(Vector2(shelf_x * viewport_size.x, [0.288, 0.368, 0.447][row] * viewport_size.y))
	# Existing slot IDs are preserved, so previously owned items need no migration.
	centers.append_array(PackedVector2Array([
		Vector2(0.77,0.196), Vector2(0.90,0.196), Vector2(0.10,0.565),
		Vector2(0.14,0.565), Vector2(0.94,0.565), Vector2(0.10,0.85),
		Vector2(0.77,0.565), Vector2(0.77,0.92),
	]))
	for index in range(12, centers.size()):
		centers[index] *= viewport_size
	return centers


func _decoration_slot_centers(viewport_size: Vector2) -> PackedVector2Array:
	var centers := _decoration_visual_centers(viewport_size)
	for index in range(12):
		var row := (index % 6) / 2
		# Retain separate 56px touch targets while the painted pots use their
		# own measured contacts. Small phones cannot fit two 56px targets into
		# each narrow cabinet opening without this slight target offset.
		centers[index].x = (0.10 if index < 6 else 0.75) * viewport_size.x + (index % 2) * maxf(viewport_size.x * 0.15, 58.0)
		centers[index].y = viewport_size.y * 0.284 - 5.0 + row * maxf(58.0, viewport_size.y * 0.08)
	# Keep purchased ledge props clear of the top shelf and header controls.
	centers[12] = Vector2(0.70, 0.176) * viewport_size
	centers[13] = Vector2(0.90, 0.176) * viewport_size
	centers[18].x = viewport_size.x * 0.72
	return centers


func _layout_decoration_buttons() -> void:
	if size.x <= 0 or size.y <= 0:
		return
	var centers := _decoration_slot_centers(size)
	for index in range(decoration_buttons.size()):
		var button: Button = decoration_buttons[index]
		button.position = centers[index] - Vector2(28,28)
		button.size = Vector2(56,56)
	# Safe-area transforms can leave fractional edges. Keep a small real inset
	# rather than letting an outer decoration's hitbox round past the surface.
	for button in decoration_buttons:
		button.position.x = clampf(button.position.x, 2.0, maxf(2.0,size.x-button.size.x-2.0))
		button.position.y = clampf(button.position.y, 2.0, maxf(2.0,size.y-button.size.y-2.0))
		button.hide()
		button.disabled = true
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE


func plant_slot_hit_rect(_slot_index: int) -> Rect2:
	return Rect2()


func set_plant_drag_enabled(_enabled: bool) -> void:
	# Fixed composition approved by the user; legacy input can never lift a
	# saved, invisible decoration or overwrite its old slot.
	super.set_plant_drag_enabled(false)


func set_room_decorations(slot_ids: Array[String], catalog: Dictionary) -> void:
	super.set_room_decorations(slot_ids, catalog)
	set_meta("placed_decoration_count", 0)


func _draw() -> void:
	if size.x <= 0 or size.y <= 0:
		return
	var art := scene_art_rect()
	# Preserve the approved phone canvas. Quiet sage margins on wide screens keep
	# the complete painting visible without stretching its furniture or tools.
	if art.position.x > 0.0:
		draw_rect(Rect2(Vector2.ZERO,size),Color("#24382c"))
		for step in range(6):
			var alpha := 0.18 * (1.0 - float(step) / 6.0)
			draw_rect(Rect2(art.position.x - float(step + 1) * 2.0,0,2,size.y),Color(0,0,0,alpha))
			draw_rect(Rect2(art.end.x + float(step) * 2.0,0,2,size.y),Color(0,0,0,alpha))
	draw_texture_rect(WorkshopBackground, art, false)
	var palette := _palette_for_theme(selected_theme_id)
	if palette.tint.a > 0:
		draw_rect(Rect2(Vector2.ZERO, size), palette.tint)


func scene_art_rect(canvas := Vector2.ZERO) -> Rect2:
	if canvas == Vector2.ZERO:
		canvas = size
	if canvas.x / maxf(canvas.y, 1.0) <= 0.60:
		return Rect2(Vector2.ZERO, canvas)
	var width := canvas.y * float(WorkshopBackground.get_width()) / float(WorkshopBackground.get_height())
	return Rect2((canvas.x - width) * 0.5, 0, width, canvas.y)
