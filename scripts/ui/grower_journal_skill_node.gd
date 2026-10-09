class_name GrowerJournalSkillNode
extends Button
## Illustrated botanical milestone used by the Grower Journal skill tree.

const PaintedDetailArt := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const PreparedIcons := preload("res://scripts/ui/prepared_startup_icons.gd")
const FontSemiBold := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const FontExtraBold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")

const NODE_SIZE := Vector2(124.0, 146.0)
const NORMALIZED_ICON_SIZE := Vector2i(80, 80)

static var normalized_icon_cache: Dictionary = {}

var badge_id := ""
var badge_index := 0
var accent := Color("#70cf35")
var icon_outer: PanelContainer
var icon_frame: PanelContainer
var icon_shadow: TextureRect
var icon_rect: TextureRect
var title_panel: PanelContainer
var title_label: Label
var value_panel: PanelContainer
var value_label: Label
var progress_bar: ProgressBar
var stage_badge: PanelContainer
var state_badge: PanelContainer
var state_label: Label
var achieved := false
var selected := false


func configure(id: String, index: int, texture: Texture2D, color: Color) -> void:
	badge_id = id
	badge_index = index
	accent = color
	custom_minimum_size = NODE_SIZE
	size = NODE_SIZE
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_PASS
	clip_contents = false
	tooltip_text = "Otevřít detail dovednosti"
	set_meta("component", "grower_journal_skill_node_v2")
	set_meta("badge_id", badge_id)
	set_meta("stage", badge_index + 1)
	set_meta("touch_target_min_height", int(NODE_SIZE.y))
	set_meta("illustrated", true)
	set_meta("visual_form", "painted_botanical_medallion_v2")
	set_meta("runtime_asset_normalization", "alpha_trim_uniform_80px_v1")
	set_meta("source_png_untouched", true)

	var empty_style := StyleBoxEmpty.new()
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		add_theme_stylebox_override(state, empty_style)

	icon_outer = PanelContainer.new()
	icon_outer.position = Vector2(19.0, 3.0)
	icon_outer.size = Vector2(86.0, 86.0)
	icon_outer.custom_minimum_size = icon_outer.size
	icon_outer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(icon_outer)
	var icon_margin := MarginContainer.new()
	icon_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		icon_margin.add_theme_constant_override(side, 7)
	icon_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_outer.add_child(icon_margin)
	icon_frame = PanelContainer.new()
	icon_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_margin.add_child(icon_frame)
	var art_layer := Control.new()
	art_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_frame.add_child(art_layer)
	var normalized_texture := normalized_icon_texture(texture)
	icon_shadow = TextureRect.new()
	icon_shadow.texture = normalized_texture
	icon_shadow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon_shadow.offset_left = 3.0
	icon_shadow.offset_top = 4.0
	icon_shadow.offset_right = 3.0
	icon_shadow.offset_bottom = 4.0
	icon_shadow.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_shadow.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_shadow.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	icon_shadow.modulate = Color(0.15, 0.10, 0.04, 0.30)
	icon_shadow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_layer.add_child(icon_shadow)
	icon_rect = TextureRect.new()
	icon_rect.texture = normalized_texture
	icon_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_layer.add_child(icon_rect)

	stage_badge = PanelContainer.new()
	stage_badge.position = Vector2(0.0, 7.0)
	stage_badge.size = Vector2(34.0, 28.0)
	stage_badge.custom_minimum_size = stage_badge.size
	stage_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stage_badge)
	var stage_label := Label.new()
	stage_label.text = "%02d" % (badge_index + 1)
	stage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stage_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	stage_label.add_theme_font_override("font", FontExtraBold)
	stage_label.add_theme_font_size_override("font_size", 9)
	stage_label.add_theme_color_override("font_color", Color("#173f35"))
	stage_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage_badge.add_child(stage_label)

	state_badge = PanelContainer.new()
	state_badge.position = Vector2(91.0, 7.0)
	state_badge.size = Vector2(33.0, 28.0)
	state_badge.custom_minimum_size = state_badge.size
	state_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(state_badge)
	state_label = Label.new()
	state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	state_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	state_label.add_theme_font_override("font", FontExtraBold)
	state_label.add_theme_font_size_override("font_size", 13)
	state_label.add_theme_color_override("font_color", Color("#173f35"))
	state_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	state_badge.add_child(state_label)

	title_panel = PanelContainer.new()
	title_panel.position = Vector2(0.0, 88.0)
	title_panel.size = Vector2(124.0, 34.0)
	title_panel.custom_minimum_size = title_panel.size
	title_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(title_panel)
	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.add_theme_font_override("font", FontExtraBold)
	title_label.add_theme_font_size_override("font_size", 8)
	title_label.add_theme_color_override("font_color", Color("#173f35"))
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_panel.add_child(title_label)

	value_panel = PanelContainer.new()
	value_panel.position = Vector2(17.0, 120.0)
	value_panel.size = Vector2(90.0, 19.0)
	value_panel.custom_minimum_size = value_panel.size
	value_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(value_panel)
	value_label = Label.new()
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	value_label.add_theme_font_override("font", FontExtraBold)
	value_label.add_theme_font_size_override("font_size", 8)
	value_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	value_panel.add_child(value_label)

	progress_bar = ProgressBar.new()
	progress_bar.position = Vector2(10.0, 138.0)
	progress_bar.size = Vector2(104.0, 8.0)
	progress_bar.custom_minimum_size.y = 8.0
	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0
	progress_bar.show_percentage = false
	progress_bar.mouse_filter = Control.MOUSE_FILTER_PASS
	progress_bar.visible = false
	add_child(progress_bar)
	_apply_visual_state()


func set_skill_progress(is_achieved: bool, progress_value: float) -> void:
	achieved = is_achieved
	progress_bar.value = clampf(progress_value, 0.0, 100.0)
	set_meta("achieved", achieved)
	set_meta("progress", progress_bar.value)
	_apply_visual_state()


func set_selected(is_selected: bool) -> void:
	selected = is_selected
	set_meta("selected", selected)
	_apply_visual_state()


func _apply_visual_state() -> void:
	if icon_outer == null:
		return
	var outer_kind := "teal" if selected else ("sage" if achieved else "wood")
	var inner_tint := Color("#edf7cc") if achieved else Color("#fff3c7")
	if selected:
		inner_tint = Color("#effff6")
	var outer_fill := Color("#45c9bc") if selected else (Color("#8dc64e") if achieved else Color("#b87931"))
	icon_outer.add_theme_stylebox_override("panel", _round_medallion_style(outer_fill, Color("#3b2417"), 4, 4))
	icon_frame.add_theme_stylebox_override("panel", _round_medallion_style(inner_tint, Color("#789354") if achieved else Color("#d3a54a"), 2, 0))
	title_panel.add_theme_stylebox_override("panel", PaintedDetailArt.box("teal" if selected else ("sage" if achieved else "cream"), 3.0))
	stage_badge.add_theme_stylebox_override("panel", _small_badge_style(Color("#dff0b6") if achieved else Color("#fff0bd"), Color("#3b2417")))
	state_badge.visible = achieved or selected
	state_badge.add_theme_stylebox_override("panel", _small_badge_style(Color("#dff0b6") if achieved else Color("#66ddd3"), Color("#3b2417")))
	state_label.text = "✓" if achieved else "!"
	icon_rect.modulate = Color.WHITE if achieved or selected or progress_bar.value > 0.0 else Color(0.56, 0.61, 0.53, 0.68)
	icon_shadow.visible = icon_rect.modulate.a > 0.70
	value_panel.add_theme_stylebox_override("panel", _status_pill_style(achieved, selected))
	value_label.add_theme_color_override("font_color", Color("#236f3d") if achieved else Color("#8d4818"))
	queue_redraw()
	var parent := get_parent()
	if parent != null:
		parent.queue_redraw()


func _draw() -> void:
	var leaf_color := Color("#81c84b", 0.96) if achieved else (Color("#44c8b9", 0.94) if selected else Color("#a8b78e", 0.62))
	_draw_medallion_leaf(Vector2(21.0, 77.0), -1.0, leaf_color)
	_draw_medallion_leaf(Vector2(103.0, 77.0), 1.0, leaf_color)
	draw_arc(Vector2(62.0, 46.0), 39.0, PI * 1.08, PI * 1.82, 18, Color(1.0, 1.0, 0.86, 0.58), 1.6, true)
	var track_rect := Rect2(10.0, 138.0, 104.0, 7.0)
	var track := StyleBoxFlat.new()
	track.bg_color = Color("#d9d7b4")
	track.border_color = Color("#4b321d")
	track.set_border_width_all(1)
	track.set_corner_radius_all(4)
	draw_style_box(track, track_rect)
	var progress_ratio := clampf(float(progress_bar.value) / 100.0, 0.0, 1.0) if progress_bar != null else 0.0
	if progress_ratio <= 0.0:
		return
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color("#35cbbd") if selected else accent
	fill.border_color = Color("#254f38")
	fill.set_border_width_all(1)
	fill.set_corner_radius_all(4)
	draw_style_box(fill, Rect2(track_rect.position, Vector2(track_rect.size.x * progress_ratio, track_rect.size.y)))


func _draw_medallion_leaf(center: Vector2, side: float, color: Color) -> void:
	var leaf := PackedVector2Array([
		center,
		center + Vector2(7.0 * side, -6.0),
		center + Vector2(13.0 * side, -1.0),
		center + Vector2(9.0 * side, 7.0),
		center + Vector2(2.0 * side, 5.0),
	])
	draw_colored_polygon(leaf, color)
	draw_line(center, center + Vector2(10.0 * side, 0.0), color.darkened(0.30), 1.0, true)


func _round_medallion_style(fill: Color, border: Color, border_width: int, shadow_size: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(43)
	style.shadow_color = Color("#2e1a10", 0.28)
	style.shadow_size = shadow_size
	style.shadow_offset = Vector2(0.0, 2.0)
	return style


func _small_badge_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(14)
	style.shadow_color = Color("#2e1a10", 0.22)
	style.shadow_size = 2
	style.shadow_offset = Vector2(0.0, 1.0)
	return style


func _status_pill_style(is_achieved: bool, is_selected: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#e7f5cb") if is_achieved else (Color("#dffaf5") if is_selected else Color("#fff2cb"))
	style.border_color = Color("#2f7a43") if is_achieved else (Color("#237f78") if is_selected else Color("#9a621c"))
	style.set_border_width_all(1)
	style.set_corner_radius_all(9)
	style.shadow_color = Color("#2e1a10", 0.16)
	style.shadow_size = 1
	style.shadow_offset = Vector2(0.0, 1.0)
	return style


static func normalized_icon_texture(source: Texture2D) -> Texture2D:
	if source == null:
		return source
	if PreparedIcons.JOURNAL_TEXTURES.has(source.resource_path):
		return PreparedIcons.JOURNAL_TEXTURES[source.resource_path] as Texture2D
	var cache_key := source.resource_path if not source.resource_path.is_empty() else str(source.get_instance_id())
	if normalized_icon_cache.has(cache_key):
		return normalized_icon_cache[cache_key] as Texture2D
	var normalized := normalized_icon_image(source)
	if normalized == null:
		normalized_icon_cache[cache_key] = source
		return source
	var normalized_texture := ImageTexture.create_from_image(normalized)
	normalized_icon_cache[cache_key] = normalized_texture
	return normalized_texture


static func normalized_icon_image(source: Texture2D) -> Image:
	# Original conversion, retained for the offline baker and unknown textures.
	var source_image := source.get_image()
	if source_image == null or source_image.is_empty():
		return null
	source_image.convert(Image.FORMAT_RGBA8)
	var used_rect := source_image.get_used_rect()
	if not used_rect.has_area():
		return null
	var trimmed := source_image.get_region(used_rect)
	var maximum_art_size := 70.0
	var scale_factor := minf(maximum_art_size / float(trimmed.get_width()), maximum_art_size / float(trimmed.get_height()))
	var target_size := Vector2i(
		maxi(1, roundi(float(trimmed.get_width()) * scale_factor)),
		maxi(1, roundi(float(trimmed.get_height()) * scale_factor))
	)
	trimmed.resize(target_size.x, target_size.y, Image.INTERPOLATE_LANCZOS)
	var normalized := Image.create(NORMALIZED_ICON_SIZE.x, NORMALIZED_ICON_SIZE.y, false, Image.FORMAT_RGBA8)
	normalized.fill(Color.TRANSPARENT)
	var destination := Vector2i((NORMALIZED_ICON_SIZE.x - target_size.x) / 2, (NORMALIZED_ICON_SIZE.y - target_size.y) / 2)
	normalized.blit_rect(trimmed, Rect2i(Vector2i.ZERO, target_size), destination)
	normalized.fix_alpha_edges()
	normalized.generate_mipmaps()
	return normalized
