extends Node
## Presentation only: no layout, input, animation or session ownership.
## Existing painted source textures remain immutable.

const PaletteShader := preload("res://scripts/ui/sage_ui_palette.gdshader")
const Framing := preload("res://scripts/ui/garden_scene_framing.gd")
const RoomView := preload("res://scripts/ui/player_room_collection_view.gd")
const FOREST := Color("#243b2b")
const SECONDARY_PROPERTIES := [
	"settings_modal", "local_backup_modal", "seed_selector_modal",
	"customer_orders_panel", "professor_story_modal", "return_summary_modal",
]
const SECONDARY_ACTION_COMPONENTS := [
	"customer_order_action_v1", "professor_story_context_action_v1",
	"sage_backup_export_action_v1", "sage_settings_done_action_v1",
	"phase109_return_summary_garden_cta_v1",
]
const PRIMARY_PROPERTIES := [
	"seed_button", "water_button", "fertilizer_button", "storage_action_button", "daily_challenge_action_button",
	"shop_sell_button", "seed_selector_confirm_button", "daily_challenge_claim_button",
	"botanical_pack_open_button", "plant_diagnosis_action_button", "grower_journal_target_button",
]

var game: Control
var surface_material: ShaderMaterial
var primary_material: ShaderMaterial
var text_material: ShaderMaterial


func install(owner_control: Control) -> void:
	game = owner_control
	surface_material = _material()
	primary_material = _material()
	primary_material.set_shader_parameter("primary_action", true)
	text_material = _material()
	text_material.set_shader_parameter("text_only", true)
	for property_name in PRIMARY_PROPERTIES:
		var button = game.get(property_name)
		if button is BaseButton:
			button.set_meta("sage_palette_role", "primary")
	for property_name in SECONDARY_PROPERTIES:
		var screen = game.get(property_name)
		if screen is Control:
			_configure_secondary_tree(screen)
	_apply_tree(game)
	_install_regions(game.hud_background, "hud")
	_install_regions(game.player_room_view, "room")
	_install_regions(game.greenhouse_preview_view, "greenhouse")
	_install_regions(game.plant_detail_panel, "surface")
	_install_regions(game.plant_detail_selector, "detail_header")
	get_tree().node_added.connect(_on_node_added)
	game.set_meta("ui_palette", "sage_green_v1")


func _material() -> ShaderMaterial:
	var result := ShaderMaterial.new()
	result.shader = PaletteShader
	return result


func _apply_tree(node: Node) -> void:
	_apply_control(node)
	for child in node.get_children():
		_apply_tree(child)


func _configure_secondary_tree(node: Node) -> void:
	# These dialogs retain their geometry and wording; only colour roles change.
	if node is Label and node.get_theme_color("font_color").get_luminance() > 0.60:
		node.set_meta("sage_readable_heading", true)
	elif node is Slider:
		node.set_meta("sage_palette_slider", true)
	elif node is Button:
		if str(node.get_meta("component", "")) in SECONDARY_ACTION_COMPONENTS:
			node.set_meta("sage_palette_role", "primary")
			node.set_meta("sage_secondary_action", true)
		if node.toggle_mode:
			node.set_meta("sage_secondary_toggle", true)
	for child in node.get_children():
		_configure_secondary_tree(child)


func _on_node_added(node: Node) -> void:
	# Cards/rewards created later receive the same palette after their builder.
	if is_instance_valid(game) and game.is_ancestor_of(node):
		_apply_control.call_deferred(node)


func _apply_control(node: Node) -> void:
	if not is_instance_valid(node) or not (node is CanvasItem) or node.material != null:
		return
	if node is PanelContainer or node is Panel or node is BaseButton or node is ProgressBar or node is ScrollBar or bool(node.get_meta("sage_palette_slider", false)):
		node.material = primary_material if str(node.get_meta("sage_palette_role", "")) == "primary" else surface_material
		if node is Button:
			# A native Button icon shares its canvas with the frame. Identify its
			# texture rather than masking a rectangle behind it.
			node.material = node.material.duplicate()
			_sync_button_text(node)
			_sync_native_icon(node)
			node.theme_changed.connect(_sync_button_text.bind(node), CONNECT_DEFERRED)
			node.draw.connect(_sync_native_icon.bind(node))
	elif node is Label:
		_sync_label(node)
		node.theme_changed.connect(_sync_label.bind(node), CONNECT_DEFERRED)


func _sync_label(label: Label) -> void:
	if not is_instance_valid(label):
		return
	var framed := label.has_theme_stylebox_override("normal")
	var desired := surface_material if framed else text_material
	if label.material != desired:
		label.material = desired
	if bool(label.get_meta("sage_readable_heading", false)):
		if label.get_theme_color("font_color") != FOREST:
			label.add_theme_color_override("font_color", FOREST)
		# Preserve outline metrics so removing its paint cannot shift the title.
		for key in ["font_outline_color", "font_shadow_color"]:
			if label.has_theme_color_override(key) and label.get_theme_color(key).a > 0.0:
				label.add_theme_color_override(key, Color.TRANSPARENT)
	if framed:
		var previous := label.get_theme_color("font_color")
		var warning := previous.r > previous.g+0.15 and previous.r > previous.b+0.15
		if not warning and previous != Color(FOREST, previous.a):
			label.add_theme_color_override("font_color", Color(FOREST, previous.a))


func _sync_button_text(button: Button) -> void:
	if not is_instance_valid(button) or button.text.is_empty():
		return
	if bool(button.get_meta("sage_secondary_toggle", false)):
		button.material.set_shader_parameter("primary_action", button.button_pressed)
	elif bool(button.get_meta("sage_secondary_action", false)):
		button.material.set_shader_parameter("unify_action_accent", true)
		button.material.set_shader_parameter("primary_action", not button.disabled)
	elif bool(button.get_meta("sage_neutral_navigation", false)):
		button.material.set_shader_parameter("unify_action_accent", true)
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
		var previous := button.get_theme_color(state)
		if previous.get_luminance() > 0.60:
			button.add_theme_color_override(state, Color(FOREST, previous.a))


func _sync_native_icon(button: Button) -> void:
	var pixels := Vector2.ZERO if button.icon == null else Vector2.ONE / button.icon.get_size()
	if button.material.get_shader_parameter("native_icon_pixel_size") != pixels:
		button.material.set_shader_parameter("native_icon_pixel_size", pixels)


func _install_regions(control: Control, kind: String) -> void:
	if control == null or control.material != null:
		return
	control.material = _material()
	control.material.set_shader_parameter("restrict_regions", true)
	control.resized.connect(_update_regions.bind(control, kind))
	_update_regions(control, kind)


func _update_regions(control: Control, kind: String) -> void:
	var regions: Array[Rect2] = []
	var exclusions: Array[Rect2] = []
	match kind:
		"hud":
			regions = [Rect2(Vector2.ZERO, control.size)]
			exclusions = [Rect2(control.size * Vector2(0.038,0.15),control.size * Vector2(0.130,0.70)),Rect2(0,0,30,30),Rect2(control.size.x-30,0,30,30)]
		"room":
			var plaque_width := 204.0 * maxf(1.0, control.size.x / 432.0)
			regions = [Rect2(4,4,minf(plaque_width,Framing.location_title_panel(control.size).size.x)+8.0,66),RoomView.phase149_scaled_painted_rect(RoomView.PHASE149_BACK_RECT,control.size),RoomView.phase149_scaled_painted_rect(RoomView.PHASE149_THEME_RECT,control.size)]
			control.material.set_shader_parameter("room_action_text", true)
		"greenhouse":
			var reputation: Rect2 = control._reputation_panel_rect()
			regions = [Framing.location_title_panel(control.size), reputation, control._status_rect()]
			exclusions = [Rect2(reputation.position+Vector2(13,17),Vector2(22,22))]
		"detail_header":
			regions = [control.background_rect()]
			exclusions = [Rect2(-20,-20,40,40),Rect2(control.size.x-20,-20,40,40)]
		"surface":
			regions = [Rect2(Vector2.ZERO,control.size)]
	for index in range(3):
		_set_rect(control.material, "region_" + ["a","b","c"][index], regions[index] if index < regions.size() else Rect2())
		_set_rect(control.material, "exclude_" + ["a","b","c"][index], exclusions[index] if index < exclusions.size() else Rect2())


func _set_rect(mat: ShaderMaterial, key: String, rect: Rect2) -> void:
	mat.set_shader_parameter(key, Vector4(rect.position.x, rect.position.y, rect.size.x, rect.size.y))
