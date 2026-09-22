class_name GrowerProgressTreeView
extends Control

signal level_selected(level: int)

const BLOOM_TEXTURE := preload("res://assets/ui/grower_progress_bloom_v1/legendary_progress_bloom_v2_tiered.png")
const LEVEL_TEN_TEXTURE := preload("res://assets/ui/grower_progress_bloom_v1/legendary_progress_bloom_v2_level10_open.png")
const SEED_TEXTURE := preload("res://assets/ui/grower_progress_tree_v1/sprouting_seed_v1.png")
const SANCTUARY_TEXTURE := preload("res://assets/ui/grower_progress_tree_v1/progress_tree_sanctuary_v1.png")
const PaintedDetailArt := preload("res://scripts/ui/plant_detail_painted_assets.gd")

const INK := Color("#173f35")
const DEEP_GREEN := Color("#236f3a")
const LEAF_GREEN := Color("#70cf35")
const CREAM := Color("#fff6cf")
const GOLD := Color("#ffd342")
const TEAL := Color("#32c9d4")
const LOCKED := Color("#d9dfb7")
const TIER_FRACTIONS := [0.0, 0.30, 0.38, 0.46, 0.54, 0.62, 0.69, 0.75, 0.79, 1.0]
const LEVEL_BLOOM_ANCHORS := [
	Vector2(0.41, 0.81), Vector2(0.61, 0.68), Vector2(0.39, 0.57), Vector2(0.63, 0.47),
	Vector2(0.42, 0.37), Vector2(0.60, 0.29), Vector2(0.43, 0.23), Vector2(0.56, 0.20),
]
const LEVEL_BLOOM_COLORS := [
	Color("#8fe34b"), Color("#55d9c8"), Color("#ff91ad"), Color("#ffd65c"),
	Color("#c89cff"), Color("#63c8ff"), Color("#ff9b69"), Color("#ffe47a"),
]
const DEBUG_GROWTH_SPEED := 0.42
const ACHIEVEMENT_BLOOM_SPEED := 0.82
const SEED_LEVEL_TWO_FOOTPRINT_RATIO := 0.60
const SEED_MIN_WIDTH := 72.0
const SOIL_ROOT_ANCHOR_RATIO := Vector2(0.5, 0.80)

var current_level := 1
var xp_progress := 0.0
var selected_level := 1
var claimed_levels: Array[int] = []
var claimable_levels: Array[int] = []
var completed_achievements := 0
var level_buttons: Dictionary = {}
var stage_textures: Dictionary = {}
var caption_style: StyleBoxTexture
var animation_time := 0.0
var state_initialized := false
var actual_visual_fraction := 0.0
var actual_target_fraction := 0.0
var actual_growth_animating := false
var actual_growth_flash := 0.0
var achievement_bloom_animating := false
var achievement_bloom_progress := 1.0
var achievement_bloom_index := -1
var debug_level_preview_enabled := false
var debug_preview_level := 0
var debug_preview_flash := 0.0
var debug_preview_visual_fraction := 0.0
var debug_preview_target_fraction := 0.0
var debug_preview_animating := false


func _ready() -> void:
	custom_minimum_size = Vector2(0.0, 292.0)
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	set_process(true)
	set_meta("component", "grower_progress_tree_v1")
	set_meta("growth_model", "seed_to_eight_branch_tiers_sparse_nine_legendary_ten_v3")
	set_meta("visual_subject", "tiered_legendary_progress_flower_v2")
	set_meta("achievement_language", "living_flower_blossoms_v2")
	set_meta("special_animation", "stem_reveal_bud_crossfade_crown_bloom_v2")
	set_meta("seed_scale_policy", "reduced_level_one_footprint_v4")
	set_meta("stage_identity_policy", "painted_branch_layer_plus_colored_bloom_v2")
	set_meta("final_crown_policy", "level_nine_closed_bud_crossfades_to_level_ten_open_crown_v3")
	set_meta("level_ten_bud_transition", "crossfade_closed_bud_to_open_crown_v1")
	caption_style = PaintedDetailArt.box("cream", 2.0, Color(1.0, 1.0, 1.0, 0.92))
	_create_level_buttons()
	_update_contract_metadata()
	call_deferred("_layout_level_buttons")


func set_state(level: int, progress: float, claimed: Array, claimable: Array, achievement_count: int) -> void:
	var previous_current_level := current_level
	var previous_achievement_count := completed_achievements
	var was_initialized := state_initialized
	current_level = clampi(level, 1, 10)
	var next_actual_fraction := _tier_fraction(current_level)
	if not state_initialized:
		state_initialized = true
		actual_visual_fraction = next_actual_fraction
		actual_target_fraction = next_actual_fraction
	elif current_level > previous_current_level:
		actual_target_fraction = next_actual_fraction
		actual_growth_animating = not is_equal_approx(actual_visual_fraction, actual_target_fraction)
		actual_growth_flash = 1.0
	elif current_level < previous_current_level:
		actual_visual_fraction = next_actual_fraction
		actual_target_fraction = next_actual_fraction
		actual_growth_animating = false
		actual_growth_flash = 0.0
	else:
		actual_target_fraction = next_actual_fraction
	var preview_was_following_actual := debug_preview_level == previous_current_level and not debug_preview_animating
	if not debug_level_preview_enabled or debug_preview_level <= 0:
		debug_preview_level = current_level
		debug_preview_visual_fraction = actual_visual_fraction
		debug_preview_target_fraction = debug_preview_visual_fraction
	elif preview_was_following_actual and current_level != previous_current_level:
		debug_preview_level = current_level
		debug_preview_target_fraction = next_actual_fraction
		if current_level > previous_current_level:
			debug_preview_animating = not is_equal_approx(debug_preview_visual_fraction, debug_preview_target_fraction)
			debug_preview_flash = 1.0
		else:
			debug_preview_visual_fraction = debug_preview_target_fraction
			debug_preview_animating = false
	xp_progress = clampf(progress, 0.0, 100.0)
	claimed_levels.clear()
	for value in claimed:
		var normalized := int(value)
		if normalized >= 1 and normalized <= 10 and normalized not in claimed_levels:
			claimed_levels.append(normalized)
	claimable_levels.clear()
	for value in claimable:
		var normalized := int(value)
		if normalized >= 1 and normalized <= 10 and normalized not in claimable_levels:
			claimable_levels.append(normalized)
	completed_achievements = clampi(achievement_count, 0, 10)
	if was_initialized and completed_achievements > previous_achievement_count:
		achievement_bloom_index = completed_achievements - 1
		achievement_bloom_progress = 0.0
		achievement_bloom_animating = true
	elif completed_achievements < previous_achievement_count:
		achievement_bloom_index = -1
		achievement_bloom_progress = 1.0
		achievement_bloom_animating = false
	selected_level = clampi(selected_level, 1, 10)
	_update_level_button_styles()
	_update_contract_metadata()
	queue_redraw()


func select_level(level: int, notify := false) -> void:
	selected_level = clampi(level, 1, 10)
	if notify and debug_level_preview_enabled:
		debug_preview_level = selected_level
		debug_preview_target_fraction = _tier_fraction(debug_preview_level)
		debug_preview_animating = not is_equal_approx(debug_preview_visual_fraction, debug_preview_target_fraction)
		debug_preview_flash = 1.0
	_update_level_button_styles()
	_update_contract_metadata()
	queue_redraw()
	if notify:
		level_selected.emit(selected_level)


func set_debug_level_preview_enabled(enabled: bool) -> void:
	debug_level_preview_enabled = enabled and OS.is_debug_build()
	debug_preview_level = current_level if debug_level_preview_enabled else 0
	debug_preview_visual_fraction = actual_visual_fraction
	debug_preview_target_fraction = actual_target_fraction
	debug_preview_animating = actual_growth_animating if debug_level_preview_enabled else false
	debug_preview_flash = 0.0
	_update_contract_metadata()
	queue_redraw()


func reset_debug_level_preview(level := -1) -> void:
	if not debug_level_preview_enabled:
		return
	debug_preview_level = clampi(current_level if level < 1 else level, 1, 10)
	debug_preview_visual_fraction = _tier_fraction(debug_preview_level)
	debug_preview_target_fraction = debug_preview_visual_fraction
	debug_preview_animating = false
	debug_preview_flash = 0.0
	_update_contract_metadata()
	queue_redraw()


func _rendered_level() -> int:
	if debug_level_preview_enabled and debug_preview_level > 0:
		return clampi(debug_preview_level, 1, 10)
	return current_level


func _tier_fraction(level: int) -> float:
	return float(TIER_FRACTIONS[clampi(level, 1, 10) - 1])


func _soil_root(area: Rect2) -> Vector2:
	return area.position + area.size * SOIL_ROOT_ANCHOR_RATIO


func _level_ten_transition_progress(visible_fraction: float) -> float:
	var linear_progress := inverse_lerp(_tier_fraction(9), _tier_fraction(10), visible_fraction)
	linear_progress = clampf(linear_progress, 0.0, 1.0)
	return linear_progress * linear_progress * (3.0 - 2.0 * linear_progress)


func get_level_button(level: int) -> Button:
	return level_buttons.get(level) as Button


func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	animation_time = fmod(animation_time + delta, TAU * 20.0)
	actual_growth_flash = maxf(0.0, actual_growth_flash - delta * 1.35)
	if actual_growth_animating:
		actual_visual_fraction = move_toward(actual_visual_fraction, actual_target_fraction, DEBUG_GROWTH_SPEED * delta)
		if is_equal_approx(actual_visual_fraction, actual_target_fraction):
			actual_visual_fraction = actual_target_fraction
			actual_growth_animating = false
			actual_growth_flash = 0.72
		_update_contract_metadata()
	if achievement_bloom_animating:
		achievement_bloom_progress = minf(1.0, achievement_bloom_progress + ACHIEVEMENT_BLOOM_SPEED * delta)
		if achievement_bloom_progress >= 1.0:
			achievement_bloom_progress = 1.0
			achievement_bloom_animating = false
		_update_contract_metadata()
	debug_preview_flash = maxf(0.0, debug_preview_flash - delta * 1.6)
	if debug_level_preview_enabled and debug_preview_animating:
		debug_preview_visual_fraction = move_toward(debug_preview_visual_fraction, debug_preview_target_fraction, DEBUG_GROWTH_SPEED * delta)
		if is_equal_approx(debug_preview_visual_fraction, debug_preview_target_fraction):
			debug_preview_visual_fraction = debug_preview_target_fraction
			debug_preview_animating = false
			debug_preview_flash = 0.55
		_update_contract_metadata()
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_level_buttons()


func _create_level_buttons() -> void:
	for level in range(1, 11):
		var button := Button.new()
		button.name = "GrowthTier%d" % level
		button.text = str(level)
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(46.0, 44.0)
		button.add_theme_font_size_override("font_size", 12)
		button.set_meta("growth_level", level)
		button.set_meta("touch_target_min_height", 44)
		button.tooltip_text = "Zobrazit úroveň %d" % level
		button.pressed.connect(select_level.bind(level, true))
		add_child(button)
		level_buttons[level] = button
	_update_level_button_styles()


func _layout_level_buttons() -> void:
	if level_buttons.is_empty() or size.x <= 0.0 or size.y <= 0.0:
		return
	var button_height := clampf(minf(44.0, (size.y - 28.0) / 5.25), 40.0, 44.0)
	var button_width := clampf(size.x * 0.125, 46.0, 54.0)
	var gap := maxf(3.0, (size.y - button_height * 5.0 - 20.0) / 4.0)
	var right_edge := size.x - 10.0
	for level in range(1, 11):
		var column := 0 if level <= 5 else 1
		# The path climbs 1–5 on the left and returns 6–10 down the right.
		# This makes one continuous growing vine instead of two unrelated rails.
		var row := level - 1 if level <= 5 else 10 - level
		var x := right_edge - button_width * float(2 - column) - 5.0 * float(1 - column)
		var y := size.y - 10.0 - button_height - float(row) * (button_height + gap)
		var button := level_buttons[level] as Button
		button.position = Vector2(x, y)
		button.size = Vector2(button_width, button_height)
	queue_redraw()


func _update_level_button_styles() -> void:
	for level in level_buttons:
		var button := level_buttons[level] as Button
		var kind := "cream"
		var tint := Color(0.78, 0.80, 0.70)
		var font_color := INK
		if int(level) <= current_level:
			kind = "sage"
			tint = Color("#e8f3c9")
		if int(level) in claimed_levels:
			kind = "sage"
			tint = Color("#d9efa4")
		if int(level) in claimable_levels:
			kind = "cream"
			tint = Color("#fff0a2")
		if int(level) == selected_level:
			kind = "teal"
			tint = Color.WHITE
		button.add_theme_stylebox_override("normal", PaintedDetailArt.box(kind, 2.0, tint))
		button.add_theme_stylebox_override("hover", PaintedDetailArt.box(kind, 2.0, tint.lightened(0.06)))
		button.add_theme_stylebox_override("pressed", PaintedDetailArt.box("sage", 2.0, Color("#d7efba")))
		button.add_theme_color_override("font_color", font_color)
		button.add_theme_color_override("font_hover_color", font_color)
		button.add_theme_color_override("font_pressed_color", font_color)
		button.set_meta("tree_state", _level_state(int(level)))
		button.set_meta("flower_state", _level_state(int(level)))
func _level_state(level: int) -> String:
	if level == selected_level:
		return "selected"
	if level in claimable_levels:
		return "claimable"
	if level in claimed_levels:
		return "claimed"
	if level <= current_level:
		return "reached"
	if level == current_level + 1:
		return "next_hint"
	return "locked"


func _update_contract_metadata() -> void:
	set_meta("current_level", current_level)
	set_meta("selected_level", selected_level)
	set_meta("visible_tiers", _rendered_level())
	set_meta("next_tier_hint", mini(10, current_level + 1))
	set_meta("xp_progress", xp_progress)
	set_meta("claimed_ornaments", claimed_levels.size())
	set_meta("claimable_fruits", claimable_levels.size())
	set_meta("achievement_ornaments", completed_achievements)
	set_meta("touch_node_count", level_buttons.size())
	set_meta("debug_level_preview_enabled", debug_level_preview_enabled)
	set_meta("debug_preview_level", _rendered_level())
	set_meta("debug_preview_persists", false)
	set_meta("debug_preview_animating", debug_preview_animating)
	set_meta("debug_preview_visual_fraction", debug_preview_visual_fraction)
	set_meta("actual_growth_animating", actual_growth_animating)
	set_meta("actual_growth_visual_fraction", actual_visual_fraction)
	set_meta("actual_growth_target_fraction", actual_target_fraction)
	var rendered_fraction := debug_preview_visual_fraction if debug_level_preview_enabled else actual_visual_fraction
	set_meta("level_ten_bud_fade_progress", _level_ten_transition_progress(rendered_fraction) if _rendered_level() == 10 else 0.0)
	set_meta("growth_animation_visibility_policy", "hold_until_progress_screen_visible_v1")
	set_meta("achievement_bloom_animating", achievement_bloom_animating)
	set_meta("achievement_bloom_progress", achievement_bloom_progress)
	set_meta("achievement_bloom_index", achievement_bloom_index)
	set_meta("achievement_bloom_visual", "painted_petal_unfurl_pollen_glow_v1")
	set_meta("growth_caption_policy", "removed_redundant_floating_test_label_v1")
	set_meta("level_path_layout", "serpentine_vine_1_to_10_v1")
	set_meta("level_path_reached", _rendered_level())
	set_meta("stage_height_fractions", TIER_FRACTIONS.duplicate())
	set_meta("seed_target_width_ratio", SEED_LEVEL_TWO_FOOTPRINT_RATIO)
	set_meta("seed_min_width", SEED_MIN_WIDTH)
	set_meta("soil_root_anchor_ratio", SOIL_ROOT_ANCHOR_RATIO)
	set_meta("soil_root_policy", "shared_seed_and_bloom_centered_in_planter_soil_v1")
	set_meta("distinct_growth_tiers", 10)


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	_draw_garden_backdrop()
	var marker_width := minf(124.0, size.x * 0.32)
	var art_area := Rect2(Vector2(8.0, 8.0), Vector2(maxf(96.0, size.x - marker_width - 18.0), size.y - 16.0))
	var rendered_level := _rendered_level()
	var visible_fraction := debug_preview_visual_fraction if debug_level_preview_enabled else actual_visual_fraction
	var growth_is_animating := debug_preview_animating if debug_level_preview_enabled else actual_growth_animating
	if visible_fraction <= 0.001:
		_draw_seed_state(art_area)
	else:
		_draw_bloom_state(art_area, rendered_level, visible_fraction, growth_is_animating)
	var active_flash := debug_preview_flash if debug_level_preview_enabled else actual_growth_flash
	if active_flash > 0.0:
		draw_rect(art_area, Color(GOLD, 0.08 * active_flash))


func _draw_garden_backdrop() -> void:
	var texture_size := SANCTUARY_TEXTURE.get_size()
	var target_aspect := size.x / maxf(1.0, size.y)
	var source_aspect := texture_size.x / maxf(1.0, texture_size.y)
	var source := Rect2(Vector2.ZERO, texture_size)
	if source_aspect > target_aspect:
		var wanted_width := texture_size.y * target_aspect
		source.position.x = (texture_size.x - wanted_width) * 0.5
		source.size.x = wanted_width
	else:
		var wanted_height := texture_size.x / target_aspect
		source.position.y = (texture_size.y - wanted_height) * 0.5
		source.size.y = wanted_height
	draw_texture_rect_region(SANCTUARY_TEXTURE, Rect2(Vector2.ZERO, size), source)
	draw_rect(Rect2(Vector2.ZERO, size), Color("#163f32", 0.045))
	_draw_level_vines()


func _draw_level_vines() -> void:
	var centers: Dictionary = {}
	for level in range(1, 11):
		var button := level_buttons.get(level) as Button
		if button != null:
			centers[level] = button.position + button.size * 0.5
	if centers.size() != 10:
		return
	var rendered_level := _rendered_level()
	# First draw one quiet future vine, then paint the reached part over it.
	for level in range(1, 10):
		var segment := _vine_segment_points(centers[level], centers[level + 1], level)
		draw_polyline(segment, Color("#173e29", 0.74), 6.0, true)
		draw_polyline(segment, Color("#83966c", 0.66), 2.4, true)
	for level in range(1, mini(rendered_level, 10)):
		var segment := _vine_segment_points(centers[level], centers[level + 1], level)
		draw_polyline(segment, Color("#1d5b2e", 0.96), 5.0, true)
		draw_polyline(segment, Color("#8ddd43", 0.98), 2.4, true)
		_draw_vine_leaf(segment[1], segment[2], level)
	var selected_button := level_buttons.get(selected_level) as Button
	if selected_button != null:
		var selected_center := selected_button.position + selected_button.size * 0.5
		var pulse := 1.0 + sin(animation_time * 2.6) * 0.08
		draw_circle(selected_center, 27.0 * pulse, Color(TEAL, 0.16))
		draw_circle(selected_center, 22.0 * pulse, Color("#e8ffff", 0.11))


func _vine_segment_points(from: Vector2, to: Vector2, level: int) -> PackedVector2Array:
	var direction := to - from
	var perpendicular := Vector2(-direction.y, direction.x).normalized()
	var wobble := 5.5 * (-1.0 if level % 2 == 0 else 1.0)
	var first := from.lerp(to, 0.34) + perpendicular * wobble
	var second := from.lerp(to, 0.68) - perpendicular * wobble * 0.72
	if level == 5:
		# The crown bridge joins levels 5 and 6 in a small upward arch.
		first += Vector2(0.0, -8.0)
		second += Vector2(0.0, -8.0)
	return PackedVector2Array([from, first, second, to])


func _draw_vine_leaf(from: Vector2, to: Vector2, level: int) -> void:
	var direction := (to - from).normalized()
	var normal := Vector2(-direction.y, direction.x)
	var side := -1.0 if level % 2 == 0 else 1.0
	var center := from.lerp(to, 0.5) + normal * 4.5 * side
	var tip := center + direction * 6.5
	var base := center - direction * 4.5
	var leaf_points := PackedVector2Array([
		base,
		center + normal * 4.2 * side,
		tip,
		center - normal * 2.2 * side,
	])
	draw_colored_polygon(leaf_points, Color("#78ce3d", 0.96))
	draw_polyline(PackedVector2Array([base, tip]), Color("#2f6b30", 0.92), 1.2, true)


func _draw_seed_state(area: Rect2) -> void:
	var pulse := 1.0 + sin(animation_time * 1.8) * 0.018
	var soil_root := _soil_root(area)
	var bloom_ratio := float(BLOOM_TEXTURE.get_width()) / float(BLOOM_TEXTURE.get_height())
	var bloom_height := minf(area.size.y * 0.96, area.size.x * 0.96 / bloom_ratio)
	# The seed sprite is almost square while the level-two crop is wide. Match
	# their painted footprints by width so level one does not look undersized.
	var bloom_width := bloom_height * bloom_ratio
	var target_width := maxf(SEED_MIN_WIDTH, bloom_width * SEED_LEVEL_TWO_FOOTPRINT_RATIO) * pulse
	target_width = minf(target_width, area.size.x * 0.76)
	var target_height := target_width * float(SEED_TEXTURE.get_height()) / float(SEED_TEXTURE.get_width())
	var target := Rect2(
		Vector2(soil_root.x - target_width * 0.5, soil_root.y - target_height),
		Vector2(target_width, target_height)
	)
	draw_texture_rect(SEED_TEXTURE, target, false)
	var glow_center := Vector2(soil_root.x, target.position.y + target.size.y * 0.23)
	draw_circle(glow_center, 18.0 + sin(animation_time * 2.2) * 3.0, Color(GOLD, 0.11))


func _draw_bloom_state(area: Rect2, rendered_level: int, visible_fraction: float, animated_growth: bool) -> void:
	var sway := sin(animation_time * 0.82) * 1.8
	var soil_root := _soil_root(area)
	var texture_ratio := float(BLOOM_TEXTURE.get_width()) / float(BLOOM_TEXTURE.get_height())
	var current_fraction := clampf(visible_fraction, 0.02, 1.0)
	# The bulb stays planted at one stable scale while the stem, side blossoms
	# and final crown are progressively revealed from the soil upward.
	var full_height := minf(area.size.y * 0.96, area.size.x * 0.96 / texture_ratio)
	var full_width := full_height * texture_ratio
	var full_rect := Rect2(
		Vector2(soil_root.x - full_width * 0.5 + sway, soil_root.y - full_height),
		Vector2(full_width, full_height)
	)
	var top_y := full_rect.end.y - full_rect.size.y * current_fraction
	var visible_rect := Rect2(Vector2(full_rect.position.x, top_y), Vector2(full_rect.size.x, full_rect.size.y * current_fraction))
	_draw_bloom_aura(full_rect, top_y, rendered_level, animated_growth)
	if animated_growth and rendered_level == 10:
		var crown_transition := _level_ten_transition_progress(current_fraction)
		var level_nine_fraction := _tier_fraction(9)
		var level_nine_top := full_rect.end.y - full_rect.size.y * level_nine_fraction
		var level_nine_rect := Rect2(
			Vector2(full_rect.position.x, level_nine_top),
			Vector2(full_rect.size.x, full_rect.size.y * level_nine_fraction)
		)
		if crown_transition < 0.999:
			draw_texture_rect(_stage_texture(9, level_nine_fraction), level_nine_rect, false, Color(1.0, 1.0, 1.0, 1.0 - crown_transition))
		if crown_transition > 0.001:
			draw_texture_rect(LEVEL_TEN_TEXTURE, full_rect, false, Color(1.0, 1.0, 1.0, crown_transition))
	elif animated_growth:
		var source_y := float(BLOOM_TEXTURE.get_height()) * (1.0 - current_fraction)
		var source_rect := Rect2(
			Vector2(0.0, source_y),
			Vector2(float(BLOOM_TEXTURE.get_width()), float(BLOOM_TEXTURE.get_height()) - source_y)
		)
		draw_texture_rect_region(BLOOM_TEXTURE, visible_rect, source_rect)
	else:
		draw_texture_rect(_stage_texture(rendered_level, _tier_fraction(rendered_level)), visible_rect, false)
	_draw_level_identity_blooms(full_rect, rendered_level, current_fraction)
	var stem_x := full_rect.get_center().x
	if animated_growth:
		_draw_growth_front(Vector2(stem_x, top_y + 4.0))
	elif rendered_level < 10:
		_draw_next_growth_bud(Vector2(stem_x, top_y + 4.0))
	var base_y := full_rect.end.y - full_rect.size.y * 0.055
	var sap_y := lerpf(base_y, top_y + 8.0, xp_progress / 100.0)
	var sap_x := stem_x + sin(animation_time * 2.2 + sap_y * 0.035) * full_width * 0.055
	draw_circle(Vector2(sap_x, sap_y), 10.0 + sin(animation_time * 3.0) * 1.8, Color(GOLD, 0.12))
	draw_circle(Vector2(sap_x, sap_y), 4.8 + sin(animation_time * 3.0) * 0.8, Color("#fff5a0", 0.92))
	_draw_reward_fruits(full_rect, current_fraction)
	_draw_achievement_flowers(full_rect, current_fraction)


func _draw_level_identity_blooms(tree_rect: Rect2, rendered_level: int, visible_fraction: float) -> void:
	for level in range(2, mini(rendered_level, 9) + 1):
		var index := level - 2
		var anchor: Vector2 = LEVEL_BLOOM_ANCHORS[index]
		if 1.0 - anchor.y > visible_fraction + 0.02:
			continue
		var center := tree_rect.position + anchor * tree_rect.size
		var color: Color = LEVEL_BLOOM_COLORS[index]
		var pulse := 1.0 + sin(animation_time * (1.15 + float(level) * 0.035) + float(level)) * 0.035
		if level == 9:
			# A closed top bud prepares the final legendary crown without revealing it early.
			draw_line(center + Vector2(0.0, 7.0), center + Vector2(0.0, -3.0), Color("#2c6b32"), 2.2, true)
			draw_circle(center + Vector2(0.0, -5.0), 5.5 * pulse, Color("#503322"))
			draw_circle(center + Vector2(0.0, -5.5), 4.1 * pulse, color)
			draw_circle(center + Vector2(-1.2, -6.8), 1.2 * pulse, color.lightened(0.30))
			continue
		var petal_count := 3 + index % 4
		var radius := 3.3 + float(index % 3) * 0.35
		for petal_index in range(petal_count):
			var angle := float(petal_index) * TAU / float(petal_count) - PI * 0.5
			var petal := center + Vector2.from_angle(angle) * 4.5 * pulse
			draw_circle(petal, radius * pulse, Color("#5c3827"))
			draw_circle(petal, (radius - 0.8) * pulse, color)
		draw_circle(center, 2.8 * pulse, Color("#6d431e"))
		draw_circle(center + Vector2(-0.4, -0.5), 1.9 * pulse, GOLD)


func _draw_bloom_aura(bloom_rect: Rect2, top_y: float, rendered_level: int, animated_growth: bool) -> void:
	var flower_center := Vector2(bloom_rect.get_center().x, top_y + minf(28.0, bloom_rect.size.y * 0.10))
	var intensity := 0.05 + float(rendered_level) * 0.006
	if animated_growth:
		intensity += 0.08
	if rendered_level >= 8:
		var crown_pulse := 1.0 + sin(animation_time * 2.4) * 0.08
		draw_circle(flower_center, 38.0 * crown_pulse, Color("#ff9fc0", intensity))
		draw_circle(flower_center, 26.0 * crown_pulse, Color(GOLD, intensity * 0.85))
	var spark_count := 8 if animated_growth or rendered_level >= 7 else 4
	for spark_index in range(spark_count):
		var phase := animation_time * (1.2 + 0.06 * float(spark_index)) + float(spark_index) * TAU / float(spark_count)
		var height_span := bloom_rect.size.y * clampf(float(rendered_level) / 10.0, 0.20, 1.0)
		var spark_y := bloom_rect.end.y - fmod(float(spark_index) * 31.0 + animation_time * 18.0, maxf(28.0, height_span))
		if spark_y < top_y + 5.0:
			continue
		var spark_x := bloom_rect.get_center().x + sin(phase) * bloom_rect.size.x * 0.42
		var radius := 1.8 + 0.9 * (0.5 + 0.5 * sin(phase * 1.7))
		draw_circle(Vector2(spark_x, spark_y), radius + 2.5, Color(GOLD, 0.08))
		draw_circle(Vector2(spark_x, spark_y), radius, Color("#fff2a1", 0.78))
	if rendered_level == 10 and not animated_growth:
		for ray_index in range(10):
			var angle := float(ray_index) * TAU / 10.0 + sin(animation_time * 0.7) * 0.08
			var ray_from := flower_center + Vector2.from_angle(angle) * 31.0
			var ray_to := flower_center + Vector2.from_angle(angle) * (42.0 + 4.0 * sin(animation_time * 2.0 + float(ray_index)))
			draw_line(ray_from, ray_to, Color("#fff3a3", 0.38), 2.0, true)


func _draw_growth_front(center: Vector2) -> void:
	var pulse := 1.0 + sin(animation_time * 4.6) * 0.12
	draw_circle(center, 27.0 * pulse, Color(GOLD, 0.11))
	draw_circle(center, 16.0 * pulse, Color("#fff39a", 0.16))
	_draw_next_growth_bud(center)
	for spark_index in range(5):
		var angle := animation_time * 1.8 + float(spark_index) * TAU / 5.0
		var spark := center + Vector2.from_angle(angle) * (20.0 + 4.0 * sin(animation_time * 2.0 + float(spark_index)))
		draw_circle(spark, 2.4, Color("#fff4a8", 0.82))


func _draw_next_growth_bud(center: Vector2) -> void:
	var pulse := 1.0 + sin(animation_time * 2.0) * 0.07
	draw_circle(center, 18.0 * pulse, Color(GOLD, 0.10))
	draw_line(center + Vector2(0.0, 14.0), center + Vector2(0.0, -5.0), Color("#2d642c", 0.46), 3.2, true)
	var left := center + Vector2(-6.5, -5.5)
	var right := center + Vector2(6.5, -7.0)
	for leaf_center in [left, right]:
		draw_circle(leaf_center, 6.2 * pulse, Color("#214f2d", 0.52))
		draw_circle(leaf_center, 4.8 * pulse, Color("#83d843", 0.52))
	draw_circle(center + Vector2(0.0, -10.0), 4.5 * pulse, Color("#ffd75a", 0.68))


func _stage_texture(level: int, fraction: float) -> Texture2D:
	if stage_textures.has(level):
		return stage_textures[level] as Texture2D
	if level >= 10:
		stage_textures[level] = LEVEL_TEN_TEXTURE
		return LEVEL_TEN_TEXTURE
	var source := BLOOM_TEXTURE.get_image()
	source.convert(Image.FORMAT_RGBA8)
	var crop_y := clampi(roundi(float(source.get_height()) * (1.0 - fraction)), 0, source.get_height() - 1)
	var part := source.get_region(Rect2i(0, crop_y, source.get_width(), source.get_height() - crop_y))
	var fade_rows := mini(54, maxi(12, roundi(float(part.get_height()) * 0.08)))
	for y in range(fade_rows):
		var fade := pow(float(y) / float(fade_rows), 1.45)
		for x in range(part.get_width()):
			var pixel := part.get_pixel(x, y)
			pixel.a *= fade
			part.set_pixel(x, y, pixel)
	part.fix_alpha_edges()
	var texture := ImageTexture.create_from_image(part)
	stage_textures[level] = texture
	return texture


func _draw_reward_fruits(tree_rect: Rect2, visible_fraction: float) -> void:
	var anchors := [
		Vector2(0.32, 0.82), Vector2(0.68, 0.80), Vector2(0.28, 0.70), Vector2(0.72, 0.67), Vector2(0.33, 0.58),
		Vector2(0.67, 0.54), Vector2(0.30, 0.45), Vector2(0.70, 0.40), Vector2(0.38, 0.28), Vector2(0.62, 0.18),
	]
	for level in range(1, 11):
		if level not in claimed_levels and level not in claimable_levels:
			continue
		var anchor: Vector2 = anchors[level - 1]
		if 1.0 - anchor.y > visible_fraction + 0.06:
			continue
		var center := tree_rect.position + anchor * tree_rect.size
		var pulse := 1.0
		if level in claimable_levels:
			pulse += sin(animation_time * 3.2 + float(level)) * 0.12
			draw_circle(center, 12.0 * pulse, Color(GOLD, 0.18))
		draw_line(center + Vector2(0.0, -9.0), center + Vector2(0.0, -4.0), Color("#28552d", 0.86), 2.2, true)
		var leaf_side := -1.0 if level % 2 == 0 else 1.0
		var leaf_center := center + Vector2(4.5 * leaf_side, -7.0)
		draw_circle(leaf_center, 3.2 * pulse, Color("#28552d"))
		draw_circle(leaf_center + Vector2(0.4 * leaf_side, -0.4), 2.35 * pulse, Color("#79d43e"))
		draw_circle(center + Vector2(0.0, 1.5), 7.0 * pulse, Color("#9c5319"))
		draw_circle(center, 5.6 * pulse, GOLD if level in claimable_levels else Color("#f0a92e"))
		draw_circle(center + Vector2(-1.8, -1.8), 1.4 * pulse, Color("#fff6aa"))


func _draw_achievement_flowers(tree_rect: Rect2, visible_fraction: float) -> void:
	var anchors := [
		Vector2(0.42, 0.84), Vector2(0.58, 0.75), Vector2(0.39, 0.65), Vector2(0.61, 0.57), Vector2(0.43, 0.50),
		Vector2(0.57, 0.42), Vector2(0.44, 0.34), Vector2(0.56, 0.27), Vector2(0.46, 0.20), Vector2(0.54, 0.12),
	]
	for index in range(completed_achievements):
		var anchor: Vector2 = anchors[index]
		if 1.0 - anchor.y > visible_fraction + 0.06:
			continue
		var center := tree_rect.position + anchor * tree_rect.size
		var reveal := 1.0
		var unfurl := 0.0
		if achievement_bloom_animating and index == achievement_bloom_index:
			reveal = sin(achievement_bloom_progress * PI * 0.5)
			unfurl = (1.0 - achievement_bloom_progress) * sin(animation_time * 9.0) * 0.34
			draw_circle(center, 18.0 + achievement_bloom_progress * 7.0, Color(GOLD, 0.16 * (1.0 - achievement_bloom_progress)))
			for pollen_index in range(6):
				var pollen_angle := animation_time * 2.4 + float(pollen_index) * TAU / 6.0
				var pollen_center := center + Vector2.from_angle(pollen_angle) * (11.0 + achievement_bloom_progress * 9.0)
				draw_circle(pollen_center, 1.8, Color("#fff0a0", 0.82 * (1.0 - achievement_bloom_progress)))
		var scale_unit := reveal * (1.0 + sin(animation_time * 1.4 + float(index)) * 0.045)
		if scale_unit <= 0.03:
			continue
		var petal_color: Color = [Color("#ff83a6"), Color("#ffd85a"), Color("#54d9c2"), Color("#c996ff")][index % 4]
		draw_line(center + Vector2(0.0, 7.0 * scale_unit), center + Vector2(0.0, 12.0 * scale_unit), Color("#28552d"), 2.0 * scale_unit, true)
		for petal_index in range(6):
			var angle := float(petal_index) * TAU / 6.0 - PI * 0.5 + unfurl
			var petal := center + Vector2.from_angle(angle) * 5.8 * scale_unit
			draw_circle(petal, 4.4 * scale_unit, Color("#5f3528"))
			draw_circle(petal, 3.35 * scale_unit, petal_color)
			draw_circle(petal + Vector2(-0.6, -0.8), 1.0 * scale_unit, petal_color.lightened(0.28))
		draw_circle(center, 3.8 * scale_unit, Color("#70411d"))
		draw_circle(center, 2.65 * scale_unit, GOLD)
		draw_circle(center + Vector2(-0.7, -0.8), 0.8 * scale_unit, Color("#fff5a4"))
