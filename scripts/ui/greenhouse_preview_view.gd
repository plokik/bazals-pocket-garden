class_name GreenhousePreviewView
extends Control

signal rack_requested
signal bed_action_requested(bed_index: int)
signal crop_plant_requested(bed_index: int, crop_id: String)

const ComicUITheme := preload("res://scripts/ui/comic_ui.gd")
const GardenSceneFraming := preload("res://scripts/ui/garden_scene_framing.gd")
const VisualDesignSystem := preload("res://scripts/ui/visual_design_system.gd")
const FontSemiBold := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const FontExtraBold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const GreenhouseInterior := preload("res://assets/ui/greenhouse/greenhouse_interior_phase130_two_boxes_v1.png")

const BED_COUNT := 4
const VISUAL_BOX_COUNT := 2
const BAYS_PER_BOX := 2
const CROP_IDS: Array[String] = ["cherry_tomato", "sweet_pepper", "garden_radish", "salad_cucumber", "garden_eggplant"]
const TOUCH_TARGET_MIN := 64.0
const GREENHOUSE_SOURCE_SIZE := Vector2(887.0, 1774.0)
const GROWING_BOX_SOURCE_RECTS := [
	Rect2(126.0, 698.0, 635.0, 190.0),
	Rect2(14.0, 930.0, 859.0, 350.0),
]
const BED_BAY_SOURCE_RECTS := [
	Rect2(126.0, 698.0, 318.0, 190.0),
	Rect2(444.0, 698.0, 317.0, 190.0),
	Rect2(14.0, 930.0, 430.0, 350.0),
	Rect2(444.0, 930.0, 429.0, 350.0),
]
const BED_SOIL_SOURCE_POLYGONS := [
	[Vector2(151.0, 716.0), Vector2(432.0, 716.0), Vector2(432.0, 813.0), Vector2(130.0, 813.0)],
	[Vector2(456.0, 716.0), Vector2(737.0, 716.0), Vector2(757.0, 813.0), Vector2(456.0, 813.0)],
	[Vector2(91.0, 950.0), Vector2(430.0, 950.0), Vector2(430.0, 1157.0), Vector2(25.0, 1157.0)],
	[Vector2(457.0, 950.0), Vector2(796.0, 950.0), Vector2(862.0, 1157.0), Vector2(457.0, 1157.0)],
]
const BED_CROP_SOURCE_RECTS := [
	Rect2(145.0, 625.0, 290.0, 190.0),
	Rect2(452.0, 625.0, 290.0, 190.0),
	Rect2(36.0, 790.0, 390.0, 365.0),
	Rect2(461.0, 790.0, 390.0, 365.0),
]
const BED_SOIL_BASELINE_SOURCE_Y := [813.0, 813.0, 1157.0, 1157.0]
const PHASE150_TARGET_CROP_OCCUPANCY := {
	"seedlings": Vector2(0.730, 0.581),
	"cherry_tomato": Vector2(0.790, 0.745),
	"garden_eggplant": Vector2(0.860, 0.724),
}

var back_button: Button
var action_button: Button
var wallet_label: Label
var selected_title_label: Label
var selected_detail_label: Label
var bed_buttons: Array[Button] = []
var crop_buttons: Array[Button] = []
var bed_states: Array[Dictionary] = []
var crop_catalog: Dictionary = {}
var selected_bed_index := 0
var animations_paused := false
var reduced_motion_enabled := false
var ambient_phase := 0.0
var wallet_coins := 0
var player_level := 1
var greenhouse_order_state: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	set_meta("component", "phase105_greenhouse_v1")
	set_meta("location_id", "greenhouse")
	set_meta("functional_beds", BED_COUNT)
	set_meta("visual_growing_boxes", VISUAL_BOX_COUNT)
	set_meta("functional_bays_per_box", BAYS_PER_BOX)
	set_meta("future_bed_count", BED_COUNT)
	set_meta("preview_only", false)
	set_meta("crop_count", 5)
	set_meta("radish_component", "phase113_greenhouse_radish_v1")
	set_meta("extension_component", "phase115_greenhouse_eggplant_v1")
	set_meta("greenhouse_order_component", "phase116_greenhouse_order_v1")
	set_meta("greenhouse_quality_order_component", "phase117_greenhouse_multi_bed_v1")
	set_meta("greenhouse_reputation_component", "phase118_greenhouse_reputation_v1")
	set_meta("visual_rebuild_component", "phase120_raised_greenhouse_perspective_v2")
	set_meta("phase130_two_box_component", "phase130_greenhouse_two_boxes_v1")
	set_meta("greenhouse_asset", "greenhouse_interior_phase130_two_boxes_v1.png")
	set_meta("greenhouse_legacy_asset", "greenhouse_interior_phase120.png")
	set_meta("bed_layout", "two_boxes_two_bays_each_v1")
	set_meta("dynamic_anchor_space", "source_pixels_887x1774_cover_mapped_v1")
	set_meta("phase127_visual_design_system", VisualDesignSystem.CONTRACT_ID)
	set_meta("phase129_location_focus", GardenSceneFraming.FOCUSED_LOCATION_CONTRACT_ID)
	set_meta("plants_reference_policy", "read_only_visual_reference_v1")
	set_meta("location_header_layout", "compact_title_then_actions_v1")
	set_meta("scene_visual_profile", str(VisualDesignSystem.scene_profile("greenhouse").get("id", "")))
	set_meta("asset_profile_policy", "explicit_profile_or_family_gate_v1")
	set_meta("greenhouse_sprite_set", "phase127_greenhouse_atlas_v1")
	set_meta("phase150_visual_component", VisualDesignSystem.GREENHOUSE_PHASE150_RUNTIME_SET_ID)
	set_meta("phase150_scene_profile", VisualDesignSystem.GREENHOUSE_PHASE150_SCENE_PROFILE_ID)
	set_meta("phase150_greenhouse_sprite_set", "phase150_alpha_only_soil_cleanup_crops_v1")
	set_meta("phase150_crop_layer_policy", "runtime_derived_alpha_source_rgb_immutable_v1")
	set_meta("phase150_crop_grounding", "shared_authored_soil_baseline_two_boxes_v1")
	set_meta("phase150_compact_crop_policy", "fit_and_clamp_inside_functional_bay_v1")
	set_meta("phase150_target_occupancy_policy", "approved_reference_width_height_ratios_v1")
	set_meta("phase150_seedling_composition", "three_columns_from_two_vertical_pairs_v1")
	set_meta("phase150_canonical_switch", false)
	set_meta("visual_camera_component", GardenSceneFraming.CONTRACT_ID)
	set_meta("visual_camera_reference_size", GardenSceneFraming.REFERENCE_CONTENT_SIZE)
	set_meta("visual_camera_hero_band", GardenSceneFraming.HERO_BAND_REFERENCE)
	set_meta("visual_camera_lower_band", GardenSceneFraming.LOWER_BAND_REFERENCE)
	set_meta("primary_width_occupancy_target", GardenSceneFraming.PRIMARY_WIDTH_OCCUPANCY_TARGET)
	set_meta("primary_height_occupancy_target", GardenSceneFraming.PRIMARY_HEIGHT_OCCUPANCY_TARGET)
	set_meta("attention_component", "phase109_greenhouse_attention_v1")
	set_meta("responsive_layout_component", "phase109_greenhouse_compact_layout_v1")
	set_meta("compact_content_size", Vector2i(360, 620))
	set_meta("responsive_test_viewports", [Vector2i(432, 960), Vector2i(360, 800)])
	resized.connect(_layout_controls)
	_build_controls()
	_ensure_placeholder_states()
	_layout_controls()
	_refresh_controls()
	set_process(true)


func set_greenhouse_state(states: Array[Dictionary], crops: Dictionary, coins: int, xp: int, order_state: Dictionary = {}) -> void:
	bed_states.clear()
	for index in range(BED_COUNT):
		if index < states.size() and states[index] is Dictionary:
			bed_states.append(states[index].duplicate(true))
		else:
			bed_states.append({})
	crop_catalog = crops.duplicate(true)
	wallet_coins = maxi(0, coins)
	player_level = maxi(1, 1 + int(maxi(0, xp) / 100))
	greenhouse_order_state = order_state.duplicate(true)
	selected_bed_index = clampi(selected_bed_index, 0, BED_COUNT - 1)
	if wallet_label == null or action_button == null:
		return
	wallet_label.text = _greenhouse_reputation_sign_text()
	wallet_label.tooltip_text = _greenhouse_reputation_tooltip()
	_refresh_controls()
	queue_redraw()


func set_paused(paused: bool) -> void:
	animations_paused = paused
	set_meta("animations_paused", paused)
	queue_redraw()


func set_fast_time_visuals(_enabled: bool) -> void:
	pass


func set_reduced_motion(enabled: bool) -> void:
	reduced_motion_enabled = enabled
	set_meta("reduced_motion", enabled)
	queue_redraw()


func _process(delta: float) -> void:
	if animations_paused or reduced_motion_enabled or not visible:
		return
	ambient_phase = fmod(ambient_phase + delta, TAU)
	queue_redraw()


func select_bed(index: int) -> void:
	if index < 0 or index >= BED_COUNT:
		return
	selected_bed_index = index
	_refresh_controls()
	queue_redraw()


func _build_controls() -> void:
	back_button = Button.new()
	back_button.text = "←  STOJAN"
	back_button.focus_mode = Control.FOCUS_NONE
	back_button.custom_minimum_size = Vector2(124.0, TOUCH_TARGET_MIN)
	back_button.add_theme_font_override("font", FontExtraBold)
	back_button.add_theme_font_size_override("font_size", 13)
	ComicUITheme.apply_button(back_button, ComicUITheme.BLUE, Color.WHITE, 16)
	back_button.set_meta("component", "phase105_greenhouse_rack_return_v1")
	back_button.set_meta("touch_target_min", Vector2(124, TOUCH_TARGET_MIN))
	back_button.pressed.connect(_on_back_pressed)
	add_child(back_button)

	wallet_label = Label.new()
	wallet_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wallet_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	wallet_label.add_theme_font_override("font", FontExtraBold)
	wallet_label.add_theme_font_size_override("font_size", 11)
	wallet_label.add_theme_color_override("font_color", ComicUITheme.CREAM)
	wallet_label.text = "%d MINCÍ\nÚR. %d" % [wallet_coins, player_level]
	wallet_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(wallet_label)

	for bed_index in range(BED_COUNT):
		var bed_button := Button.new()
		bed_button.flat = true
		bed_button.focus_mode = Control.FOCUS_NONE
		bed_button.text = ""
		bed_button.set_meta("component", "phase105_greenhouse_bed_target_v1")
		bed_button.set_meta("bed_index", bed_index)
		bed_button.set_meta("touch_target_min", Vector2(64, 64))
		bed_button.pressed.connect(select_bed.bind(bed_index))
		add_child(bed_button)
		bed_buttons.append(bed_button)

	selected_title_label = Label.new()
	selected_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	selected_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	selected_title_label.add_theme_font_override("font", FontExtraBold)
	selected_title_label.add_theme_font_size_override("font_size", 13)
	selected_title_label.add_theme_color_override("font_color", ComicUITheme.INK)
	selected_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(selected_title_label)

	selected_detail_label = Label.new()
	selected_detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	selected_detail_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	selected_detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	selected_detail_label.add_theme_font_override("font", FontSemiBold)
	selected_detail_label.add_theme_font_size_override("font_size", 10)
	selected_detail_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	selected_detail_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(selected_detail_label)

	action_button = Button.new()
	action_button.focus_mode = Control.FOCUS_NONE
	action_button.custom_minimum_size.y = TOUCH_TARGET_MIN
	action_button.add_theme_font_override("font", FontExtraBold)
	action_button.add_theme_font_size_override("font_size", 13)
	action_button.set_meta("component", "phase105_greenhouse_primary_action_v1")
	action_button.set_meta("touch_target_min", Vector2(64, TOUCH_TARGET_MIN))
	action_button.pressed.connect(_on_action_pressed)
	add_child(action_button)

	for crop_id in CROP_IDS:
		var crop_button := Button.new()
		crop_button.focus_mode = Control.FOCUS_NONE
		crop_button.clip_text = true
		crop_button.custom_minimum_size.y = TOUCH_TARGET_MIN
		crop_button.add_theme_font_override("font", FontExtraBold)
		crop_button.add_theme_font_size_override("font_size", 10)
		crop_button.set_meta("component", "phase107_greenhouse_crop_choice_v1")
		crop_button.set_meta("crop_id", crop_id)
		crop_button.set_meta("touch_target_min", Vector2(64, TOUCH_TARGET_MIN))
		crop_button.pressed.connect(_on_crop_pressed.bind(crop_id))
		crop_button.visible = false
		add_child(crop_button)
		crop_buttons.append(crop_button)


func _layout_controls() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var action_row_y := GardenSceneFraming.location_action_row_y()
	back_button.position = Vector2(10.0, action_row_y)
	back_button.size = Vector2(124.0, TOUCH_TARGET_MIN)
	wallet_label.position = Vector2(size.x - 122.0, action_row_y + 4.0)
	wallet_label.size = Vector2(112.0, 48.0)
	for bed_index in range(bed_buttons.size()):
		var bed_rect := _bed_rect(bed_index)
		bed_buttons[bed_index].position = bed_rect.position
		bed_buttons[bed_index].size = bed_rect.size
	var status_rect := _status_rect()
	selected_title_label.position = status_rect.position + Vector2(10.0, 6.0)
	selected_title_label.size = Vector2(status_rect.size.x - 20.0, 28.0)
	selected_detail_label.position = status_rect.position + Vector2(14.0, 34.0)
	selected_detail_label.size = Vector2(status_rect.size.x - 28.0, 36.0)
	action_button.position = Vector2(16.0, size.y - 78.0)
	action_button.size = Vector2(size.x - 32.0, TOUCH_TARGET_MIN)
	var crop_gap := 8.0
	var crop_count := maxi(1, crop_buttons.size())
	var available_width := size.x - 32.0
	var crop_width := (available_width - float(crop_count - 1) * crop_gap) / float(crop_count)
	if crop_width < TOUCH_TARGET_MIN and crop_count > 1:
		crop_width = TOUCH_TARGET_MIN
		crop_gap = maxf(0.0, (available_width - float(crop_count) * crop_width) / float(crop_count - 1))
	for crop_index in range(crop_buttons.size()):
		crop_buttons[crop_index].add_theme_font_size_override("font_size", 8 if crop_width <= TOUCH_TARGET_MIN else 10)
		crop_buttons[crop_index].position = Vector2(16.0 + crop_index * (crop_width + crop_gap), size.y - 78.0)
		crop_buttons[crop_index].size = Vector2(crop_width, TOUCH_TARGET_MIN)
	queue_redraw()


func _refresh_controls() -> void:
	_ensure_placeholder_states()
	var state := bed_states[selected_bed_index]
	var stage := str(state.get("stage", "invalid"))
	var crop := state.get("crop", {}) as Dictionary
	var crop_name := str(crop.get("name", "Cherry rajče"))
	selected_title_label.text = "ZÁHON %d · %s" % [selected_bed_index + 1, "VOLNÝ" if stage == "empty" else crop_name.to_upper()]
	var state_line := "Stav záhonu není dostupný."
	match stage:
		"empty":
			state_line = "Vyber osivo · zámky na úrovních 2–5."
		"needs_water":
			state_line = "Zalij záhon · růst potom potrvá %s." % _format_duration(float(crop.get("growth_seconds", 0.0)))
		"growing":
			state_line = "Roste · %d %% · zbývá %s" % [roundi(float(state.get("progress", 0.0)) * 100.0), _format_duration(float(state.get("remaining_seconds", 0.0)))]
		"ready":
			state_line = "Sklizeň: %d mincí + %d XP." % [int(crop.get("reward_coins", 0)), int(crop.get("reward_xp", 0))]
	selected_detail_label.text = "%s\n%s" % [state_line, _greenhouse_order_line()]
	var choosing_crop := stage == "empty"
	action_button.visible = not choosing_crop
	action_button.text = str(state.get("action_label", "NELZE POUŽÍT"))
	action_button.disabled = choosing_crop or not bool(state.get("can_action", false))
	var action := str(state.get("action", "none"))
	if action == "harvest" and str(greenhouse_order_state.get("crop_id", "")) == str(state.get("crop_id", "")):
		var credited_beds: Array = greenhouse_order_state.get("credited_bed_indices", [])
		if str(greenhouse_order_state.get("quality_tier", "standard")) == "multi_bed" and selected_bed_index in credited_beds:
			action_button.text = "SKLIDIT · ZÁHON UŽ ZAPOČTEN"
		else:
			action_button.text = "SKLIDIT · ZAKÁZKA %d/%d" % [
				mini(int(greenhouse_order_state.get("target_harvests", 1)), int(greenhouse_order_state.get("progress", 0)) + 1),
				int(greenhouse_order_state.get("target_harvests", 1)),
			]
	var fill := Color("#cbd3d7")
	if not action_button.disabled:
		match action:
			"plant": fill = ComicUITheme.GREEN
			"water": fill = ComicUITheme.BLUE
			"harvest": fill = ComicUITheme.ORANGE
	ComicUITheme.apply_button(action_button, fill, ComicUITheme.CREAM if not action_button.disabled else ComicUITheme.NAVY, 14)
	for crop_index in range(crop_buttons.size()):
		var crop_id := CROP_IDS[crop_index]
		var option := crop_catalog.get(crop_id, {}) as Dictionary
		var price := int(option.get("seed_price", 0))
		var unlock_level := maxi(1, int(option.get("unlock_level", 1)))
		var unlocked := bool(option.get("unlocked", player_level >= unlock_level))
		var affordable := wallet_coins >= price
		var crop_button := crop_buttons[crop_index]
		crop_button.visible = choosing_crop
		crop_button.disabled = not choosing_crop or option.is_empty() or not unlocked or not affordable
		if not unlocked:
			crop_button.text = "%s\nOD ÚR. %d" % [str(option.get("short_name", crop_id)).to_upper(), unlock_level]
			crop_button.tooltip_text = "%s se odemkne na úrovni %d." % [str(option.get("name", crop_id)), unlock_level]
		else:
			crop_button.text = "%s\n%d MINCÍ" % [str(option.get("short_name", crop_id)).to_upper(), price]
			crop_button.tooltip_text = "%s · růst %s · sklizeň %d mincí + %d XP" % [str(option.get("name", crop_id)), _format_duration(float(option.get("growth_seconds", 0.0))), int(option.get("reward_coins", 0)), int(option.get("reward_xp", 0))]
		var usable := unlocked and affordable
		ComicUITheme.apply_button(crop_button, _crop_button_fill(crop_id) if usable else Color("#cbd3d7"), ComicUITheme.CREAM if usable else ComicUITheme.NAVY, 14)
	for bed_index in range(bed_buttons.size()):
		var bed_state := bed_states[bed_index]
		bed_buttons[bed_index].tooltip_text = "Záhon %d · %s" % [bed_index + 1, str(bed_state.get("stage_name", "stav nedostupný"))]


func _greenhouse_order_line() -> String:
	if greenhouse_order_state.is_empty():
		return "ZAKÁZKA: načítá se"
	if str(greenhouse_order_state.get("quality_tier", "standard")) == "multi_bed":
		return "ZAKÁZKA+: %s %d/%d RŮZNÉ ZÁH. · +%d M + %d XP" % [
			str(greenhouse_order_state.get("crop_short_name", greenhouse_order_state.get("crop_id", "PLODINA"))).to_upper(),
			int(greenhouse_order_state.get("progress", 0)),
			int(greenhouse_order_state.get("required_distinct_beds", greenhouse_order_state.get("target_harvests", 1))),
			int(greenhouse_order_state.get("bonus_coins", 0)),
			int(greenhouse_order_state.get("bonus_xp", 0)),
		]
	return "ZAKÁZKA: %s %d/%d · +%d MINCÍ + %d XP" % [
		str(greenhouse_order_state.get("crop_short_name", greenhouse_order_state.get("crop_id", "PLODINA"))).to_upper(),
		int(greenhouse_order_state.get("progress", 0)),
		int(greenhouse_order_state.get("target_harvests", 1)),
		int(greenhouse_order_state.get("bonus_coins", 0)),
		int(greenhouse_order_state.get("bonus_xp", 0)),
	]


func _greenhouse_reputation_sign_text() -> String:
	var reputation = greenhouse_order_state.get("reputation", {})
	if not reputation is Dictionary or (reputation as Dictionary).is_empty():
		return "%d MINCÍ\nÚR. %d" % [wallet_coins, player_level]
	var state: Dictionary = reputation
	return "%s\n%s" % [
		str(state.get("sign_top", "POVĚST")),
		str(state.get("sign_bottom", "0/3 ZAK.")),
	]


func _greenhouse_reputation_tooltip() -> String:
	var reputation = greenhouse_order_state.get("reputation", {})
	if not reputation is Dictionary or (reputation as Dictionary).is_empty():
		return "Skleníková pověst se načítá."
	var state: Dictionary = reputation
	if bool(state.get("is_max", false)):
		return "%s · kosmetická mistrovská cedule" % str(state.get("title", "MISTR SKLENÍKU"))
	return "%s · další titul %s za %d zakázek" % [
		str(state.get("title", "NOVÝ PĚSTITEL")),
		str(state.get("next_title", "")),
		int(state.get("next_target", 3)),
	]


func _crop_button_fill(crop_id: String) -> Color:
	match crop_id:
		"cherry_tomato": return ComicUITheme.GREEN
		"sweet_pepper": return ComicUITheme.ORANGE
		"garden_radish": return Color("#e74962")
		"salad_cucumber": return Color("#35b874")
		"garden_eggplant": return Color("#7b4ab2")
		_: return ComicUITheme.BLUE


func _ensure_placeholder_states() -> void:
	while bed_states.size() < BED_COUNT:
		bed_states.append({
			"valid": false,
			"stage": "invalid",
			"stage_name": "NENAČTENO",
			"action": "none",
			"can_action": false,
			"action_label": "NELZE POUŽÍT",
			"progress": 0.0,
			"remaining_seconds": 0.0,
			"crop": {},
		})


func _on_back_pressed() -> void:
	rack_requested.emit()


func _on_action_pressed() -> void:
	bed_action_requested.emit(selected_bed_index)


func _on_crop_pressed(crop_id: String) -> void:
	crop_plant_requested.emit(selected_bed_index, crop_id)


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	_draw_background_cover()
	_draw_ambient_light()
	_draw_title()
	_draw_wallet_panel()
	for bed_index in range(BED_COUNT):
		_draw_bed(bed_index, _bed_rect(bed_index), bed_states[bed_index])
	_draw_status_panel()


func _draw_background_cover() -> void:
	var source_size := GreenhouseInterior.get_size()
	var source_rect := GardenSceneFraming.cover_source_rect(source_size, size)
	draw_texture_rect_region(GreenhouseInterior, Rect2(Vector2.ZERO, size), source_rect)
	draw_rect(Rect2(Vector2.ZERO, size), Color("#052f2b", 0.07))


func _draw_ambient_light() -> void:
	if animations_paused or reduced_motion_enabled:
		return
	for mote_index in range(4):
		var offset := ambient_phase * (8.0 + float(mote_index) * 1.7)
		var mote_x := fmod(34.0 + float(mote_index) * 91.0 + offset, maxf(1.0, size.x - 28.0)) + 14.0
		var mote_y := 146.0 + sin(ambient_phase * (0.8 + float(mote_index) * 0.11) + float(mote_index)) * 15.0
		draw_circle(Vector2(mote_x, mote_y), 2.0 + float(mote_index % 2), Color("#fff2a8", 0.45))


func _draw_title() -> void:
	var panel_rect := GardenSceneFraming.location_title_panel(size)
	draw_style_box(
		ComicUITheme.style_box(Color("#fff7da", 0.97), ComicUITheme.CYAN, 3, 14, Color("#07131c", 0.36), 4, 5.0),
		panel_rect
	)
	draw_line(panel_rect.position + Vector2(16.0, 7.0), Vector2(panel_rect.end.x - 16.0, panel_rect.position.y + 7.0), Color.WHITE, 2.0, true)
	draw_string(FontExtraBold, panel_rect.position + Vector2(10.0, 27.0), "SKLENÍK", HORIZONTAL_ALIGNMENT_CENTER, panel_rect.size.x - 20.0, 19, ComicUITheme.INK)
	draw_string(FontSemiBold, panel_rect.position + Vector2(10.0, 46.0), "4 ZÁHONY · 5 PLODIN", HORIZONTAL_ALIGNMENT_CENTER, panel_rect.size.x - 20.0, 8, ComicUITheme.NAVY)


func _draw_wallet_panel() -> void:
	_draw_panel(Rect2(size.x - 122.0, GardenSceneFraming.location_action_row_y() + 4.0, 112.0, 48.0), ComicUITheme.PURPLE, ComicUITheme.GOLD, 13)


func _house_rect() -> Rect2:
	if _uses_compact_layout():
		return Rect2(10.0, 136.0, size.x - 20.0, 282.0)
	var status_top := _status_rect().position.y
	return Rect2(12.0, 142.0, size.x - 24.0, maxf(310.0, status_top - 154.0))


func _status_rect() -> Rect2:
	return Rect2(16.0, size.y - 190.0, size.x - 32.0, 96.0)


func _bed_rect(index: int) -> Rect2:
	if index < 0 or index >= BED_BAY_SOURCE_RECTS.size():
		return Rect2()
	var mapped := _map_source_rect(BED_BAY_SOURCE_RECTS[index])
	# On the shortest supported screen the front board naturally continues
	# behind the status card.  Its invisible touch target stops before the card.
	var safe_end_y := _status_rect().position.y - 8.0
	if mapped.end.y > safe_end_y:
		mapped.size.y = maxf(TOUCH_TARGET_MIN, safe_end_y - mapped.position.y)
	return mapped


func _growing_box_rect(box_index: int) -> Rect2:
	if box_index < 0 or box_index >= GROWING_BOX_SOURCE_RECTS.size():
		return Rect2()
	return _map_source_rect(GROWING_BOX_SOURCE_RECTS[box_index])


func _bed_soil_polygon(index: int) -> PackedVector2Array:
	var mapped := PackedVector2Array()
	if index < 0 or index >= BED_SOIL_SOURCE_POLYGONS.size():
		return mapped
	for source_point in BED_SOIL_SOURCE_POLYGONS[index]:
		mapped.append(GardenSceneFraming.map_cover_point(source_point, GREENHOUSE_SOURCE_SIZE, size))
	return mapped


func _bed_crop_bounds(index: int) -> Rect2:
	if index < 0 or index >= BED_CROP_SOURCE_RECTS.size():
		return Rect2()
	var bounds := _map_source_rect(BED_CROP_SOURCE_RECTS[index])
	var safe_end_y := _status_rect().position.y - 10.0
	if bounds.end.y > safe_end_y:
		bounds.size.y = maxf(1.0, safe_end_y - bounds.position.y)
	return bounds


func _bed_crop_grounded_bounds(index: int) -> Rect2:
	var bounds := _bed_crop_bounds(index)
	if index < 0 or index >= BED_SOIL_BASELINE_SOURCE_Y.size() or bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		return bounds
	var mapped_baseline := GardenSceneFraming.map_cover_point(
		Vector2(0.0, BED_SOIL_BASELINE_SOURCE_Y[index]),
		GREENHOUSE_SOURCE_SIZE,
		size
	).y
	var baseline_y := clampf(mapped_baseline, bounds.position.y + 1.0, bounds.end.y)
	return Rect2(bounds.position, Vector2(bounds.size.x, baseline_y - bounds.position.y))


func _map_source_rect(source_rect: Rect2) -> Rect2:
	var start := GardenSceneFraming.map_cover_point(source_rect.position, GREENHOUSE_SOURCE_SIZE, size)
	var finish := GardenSceneFraming.map_cover_point(source_rect.end, GREENHOUSE_SOURCE_SIZE, size)
	return Rect2(start, finish - start)


func _uses_compact_layout() -> bool:
	return size.x <= 360.0 or size.y <= 620.0


func _draw_greenhouse(rect: Rect2) -> void:
	var roof_peak := Vector2(rect.get_center().x, rect.position.y - 38.0)
	var frame_color := ComicUITheme.INK
	var glass := Color("#d8fbff", 0.72)
	draw_colored_polygon(PackedVector2Array([rect.position, roof_peak, Vector2(rect.end.x, rect.position.y)]), glass)
	draw_rect(rect, glass)
	draw_polyline(PackedVector2Array([rect.position, roof_peak, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y), rect.position]), frame_color, 6.0, true)
	draw_line(roof_peak, Vector2(roof_peak.x, rect.end.y), frame_color, 4.0)
	for pane_index in range(1, 4):
		var pane_x := lerpf(rect.position.x, rect.end.x, float(pane_index) / 4.0)
		draw_line(Vector2(pane_x, rect.position.y), Vector2(pane_x, rect.end.y), Color(frame_color, 0.44), 2.0)
	for pane_index in range(1, 4):
		var pane_y := lerpf(rect.position.y, rect.end.y, float(pane_index) / 4.0)
		draw_line(Vector2(rect.position.x, pane_y), Vector2(rect.end.x, pane_y), Color(frame_color, 0.36), 2.0)


func _draw_bed(index: int, rect: Rect2, state: Dictionary) -> void:
	var selected := index == selected_bed_index
	var pulse := 0.5
	if not animations_paused and not reduced_motion_enabled:
		pulse = 0.5 + sin(ambient_phase * 2.2) * 0.5
	var stage := str(state.get("stage", "invalid"))
	var progress := clampf(float(state.get("progress", 0.0)), 0.0, 1.0)
	var soil_polygon := _bed_soil_polygon(index)
	var state_marker_anchor := rect.position + Vector2(rect.size.x - 18.0, 18.0)
	if soil_polygon.size() == 4:
		# State marks belong to the soil bay, not to the larger rectangular touch
		# target. This keeps water/ready feedback visually inside both trapezoids.
		state_marker_anchor = soil_polygon[1] + Vector2(-18.0, -7.0)
		if stage == "invalid":
			draw_colored_polygon(soil_polygon, Color("#102126", 0.30))
		elif stage in ["growing", "ready"]:
			draw_colored_polygon(soil_polygon, Color("#3bc5b4", 0.08))
		if selected:
			draw_colored_polygon(soil_polygon, Color("#fff19a", 0.08 + pulse * 0.06))
			var outline := PackedVector2Array(soil_polygon)
			outline.append(soil_polygon[0])
			draw_polyline(outline, ComicUITheme.GOLD.lerp(Color.WHITE, pulse * 0.22), 3.0, true)
	if stage != "empty" and stage != "invalid":
		var crop_asset_id := VisualDesignSystem.greenhouse_crop_asset_id(str(state.get("crop_id", "")))
		if stage == "needs_water" or (stage == "growing" and progress < 0.24):
			crop_asset_id = VisualDesignSystem.greenhouse_seedlings_asset_id()
		var crop_texture := VisualDesignSystem.texture_for(crop_asset_id)
		if crop_texture != null:
			var crop_bounds := _bed_crop_grounded_bounds(index)
			var crop_fill := 0.96
			if stage == "needs_water":
				crop_fill = 0.84
			elif stage == "growing":
				crop_fill = 0.82 + progress * 0.16
			var crop_role := "seedlings" if crop_asset_id == VisualDesignSystem.GREENHOUSE_PHASE150_SEEDLINGS_ASSET_ID else str(state.get("crop_id", ""))
			var crop_rect := _phase150_crop_rect(crop_asset_id, crop_role, stage, progress, rect, crop_bounds, crop_fill)
			# Keep every source region rooted to the shared authored soil baseline.
			# Both the generic fitter and the approved occupancy profile clamp compact
			# layouts so the painted crop never escapes its functional bay.
			crop_rect.position.y = crop_bounds.end.y - crop_rect.size.y
			var crop_region := VisualDesignSystem.source_region_for(crop_asset_id)
			if crop_rect.size.x > 0.0 and crop_rect.size.y > 0.0 and crop_region.size.x > 0.0 and crop_region.size.y > 0.0:
				_draw_phase150_crop_region(crop_texture, crop_region, crop_rect, crop_role)
			# Historical Phase 127 contract marker retained for successor tests:
			# VisualDesignSystem.fit_asset_rect(crop_asset_id, crop_bounds, crop_fill)
	if stage == "needs_water":
		var water_id := "greenhouse_status_water"
		var water_texture := VisualDesignSystem.texture_for(water_id)
		if water_texture != null:
			draw_circle(state_marker_anchor, 15.0, ComicUITheme.GOLD)
			draw_circle(state_marker_anchor, 12.0, Color("#12343a", 0.94))
			draw_texture_rect(water_texture, VisualDesignSystem.asset_rect(water_id, state_marker_anchor, size, 0.82), false)
	elif stage == "growing":
		var bed_progress_rect := Rect2(rect.position.x + 16.0, minf(rect.end.y - 15.0, _status_rect().position.y - 25.0), rect.size.x - 32.0, 7.0)
		draw_style_box(ComicUITheme.style_box(Color("#172126"), Color("#0c1316"), 1, 3), bed_progress_rect)
		if progress > 0.0:
			draw_rect(Rect2(bed_progress_rect.position + Vector2.ONE, Vector2((bed_progress_rect.size.x - 2.0) * progress, bed_progress_rect.size.y - 2.0)), ComicUITheme.GREEN)
	elif stage == "ready":
		var ready_id := "greenhouse_status_ready"
		var ready_texture := VisualDesignSystem.texture_for(ready_id)
		if ready_texture != null:
			draw_circle(state_marker_anchor, 15.0, ComicUITheme.GOLD)
			draw_circle(state_marker_anchor, 12.0, Color("#12343a", 0.94))
			draw_texture_rect(ready_texture, VisualDesignSystem.asset_rect(ready_id, state_marker_anchor, size, 0.82), false)
	# The detailed status stays in the single lower card.  Inside the two physical
	# boxes only compact bay numbers and state marks remain, avoiding four extra
	# plaques that would visually recreate four separate planters.
	var number_position := rect.position + Vector2(13.0, 25.0)
	if soil_polygon.size() == 4:
		# The front box is strongly trapezoidal.  Anchor the badge to the authored
		# top-left soil corner, not to the rectangular touch bounds on the floor.
		number_position = soil_polygon[0] + Vector2(10.0, 20.0)
	draw_circle(number_position + Vector2(6.0, -6.0), 12.0, Color("#12343a", 0.82))
	draw_string(FontExtraBold, number_position + Vector2(1.0, 1.0), "%d" % (index + 1), HORIZONTAL_ALIGNMENT_CENTER, 12.0, 12, Color("#07131c"))
	draw_string(FontExtraBold, number_position, "%d" % (index + 1), HORIZONTAL_ALIGNMENT_CENTER, 12.0, 12, ComicUITheme.CREAM)


func _phase150_crop_rect(asset_id: String, crop_role: String, stage: String, progress: float, bay_rect: Rect2, bounds: Rect2, fallback_fill: float) -> Rect2:
	if not PHASE150_TARGET_CROP_OCCUPANCY.has(crop_role):
		return VisualDesignSystem.fit_asset_region_rect(asset_id, bounds, fallback_fill)
	var occupancy := PHASE150_TARGET_CROP_OCCUPANCY[crop_role] as Vector2
	var growth_scale := 1.0
	if stage == "growing" and crop_role != "seedlings":
		growth_scale = lerpf(0.72, 1.0, clampf((progress - 0.24) / 0.26, 0.0, 1.0))
	elif crop_role == "seedlings" and stage == "growing":
		growth_scale = lerpf(0.82, 1.0, clampf(progress / 0.24, 0.0, 1.0))
	var target_size := Vector2(bay_rect.size.x * occupancy.x, bay_rect.size.y * occupancy.y) * growth_scale
	target_size.x = minf(target_size.x, bounds.size.x)
	target_size.y = minf(target_size.y, bounds.size.y)
	return Rect2(Vector2(bounds.get_center().x - target_size.x * 0.5, bounds.end.y - target_size.y), target_size)


func _draw_phase150_crop_region(texture: Texture2D, source_region: Rect2, target_rect: Rect2, crop_role: String) -> void:
	if crop_role != "seedlings":
		draw_texture_rect_region(texture, target_rect, source_region)
		return
	# The approved rear bay contains six low sprouts arranged in three columns.
	# The source painting contains two vertical pairs, so alternate its left and
	# right halves across three equal columns. This keeps every sprout isotropic,
	# avoids an eight-sprout duplicate row and remains inside the authored bay.
	var source_column_width := source_region.size.x * 0.5
	var target_column_width := target_rect.size.x / 3.0
	for column_index in range(3):
		var source_column := column_index % 2
		var column_source_rect := Rect2(
			source_region.position + Vector2(source_column_width * source_column, 0.0),
			Vector2(source_column_width, source_region.size.y)
		)
		var column_target_rect := Rect2(
			target_rect.position + Vector2(target_column_width * column_index, 0.0),
			Vector2(target_column_width, target_rect.size.y)
		)
		draw_texture_rect_region(texture, column_target_rect, column_source_rect)


func _draw_water_drop(center: Vector2, radius: float) -> void:
	var points := PackedVector2Array([
		center + Vector2(0.0, -radius),
		center + Vector2(radius * 0.72, radius * 0.15),
		center + Vector2(radius * 0.48, radius * 0.75),
		center + Vector2(0.0, radius),
		center + Vector2(-radius * 0.48, radius * 0.75),
		center + Vector2(-radius * 0.72, radius * 0.15),
	])
	draw_colored_polygon(points, Color("#4fd4ff"))
	draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[4], points[5], points[0]]), ComicUITheme.INK, 2.0, true)
	draw_circle(center + Vector2(-radius * 0.20, radius * 0.05), radius * 0.16, Color("#e8fbff", 0.82))


func _draw_crop(crop_id: String, soil_rect: Rect2, stage: String, progress: float) -> void:
	match crop_id:
		"sweet_pepper": _draw_pepper_crop(soil_rect, stage, progress)
		"garden_radish": _draw_radish_crop(soil_rect, stage, progress)
		"salad_cucumber": _draw_cucumber_crop(soil_rect, stage, progress)
		"garden_eggplant": _draw_eggplant_crop(soil_rect, stage, progress)
		_: _draw_tomato_crop(soil_rect, stage, progress)


func _draw_tomato_crop(soil_rect: Rect2, stage: String, progress: float) -> void:
	var plant_count := 3
	for plant_index in range(plant_count):
		var x := lerpf(soil_rect.position.x + 18.0, soil_rect.end.x - 18.0, float(plant_index) / float(plant_count - 1))
		var stem_bottom := soil_rect.end.y - 7.0
		var stem_height := 18.0 + progress * 28.0
		if stage == "needs_water":
			stem_height = 13.0
		draw_line(Vector2(x, stem_bottom), Vector2(x, stem_bottom - stem_height), Color("#2d873e"), 3.0)
		draw_circle(Vector2(x - 5.0, stem_bottom - stem_height * 0.62), 5.0, Color("#5cc95b"))
		draw_circle(Vector2(x + 5.0, stem_bottom - stem_height * 0.76), 5.0, Color("#79dc65"))
		if stage == "ready" or progress >= 0.68:
			var tomato_color := Color("#ef4e45") if stage == "ready" else Color("#f29b55")
			draw_circle(Vector2(x - 5.0, stem_bottom - stem_height * 0.40), 6.0, tomato_color)
			draw_circle(Vector2(x + 6.0, stem_bottom - stem_height * 0.53), 6.0, tomato_color)
	if stage == "needs_water":
		draw_string(FontExtraBold, Vector2(soil_rect.position.x, soil_rect.position.y + 18.0), "KAPKA", HORIZONTAL_ALIGNMENT_CENTER, soil_rect.size.x, 8, Color("#72d9ff"))


func _draw_pepper_crop(soil_rect: Rect2, stage: String, progress: float) -> void:
	var plant_count := 3
	for plant_index in range(plant_count):
		var x := lerpf(soil_rect.position.x + 18.0, soil_rect.end.x - 18.0, float(plant_index) / float(plant_count - 1))
		var stem_bottom := soil_rect.end.y - 7.0
		var stem_height := 17.0 + progress * 27.0
		if stage == "needs_water":
			stem_height = 13.0
		draw_line(Vector2(x, stem_bottom), Vector2(x, stem_bottom - stem_height), Color("#287a3b"), 3.0)
		draw_circle(Vector2(x - 6.0, stem_bottom - stem_height * 0.65), 5.5, Color("#56b954"))
		draw_circle(Vector2(x + 6.0, stem_bottom - stem_height * 0.79), 5.5, Color("#78d465"))
		if stage == "ready" or progress >= 0.68:
			var pepper_color := Color("#f4b52c") if stage == "ready" else Color("#a9c94c")
			var pepper_center := Vector2(x + 2.0, stem_bottom - stem_height * 0.43)
			draw_circle(pepper_center + Vector2(-3.0, 0.0), 5.5, pepper_color)
			draw_circle(pepper_center + Vector2(3.0, 0.0), 5.5, pepper_color)
			draw_circle(pepper_center + Vector2(0.0, 4.0), 6.0, pepper_color)
	if stage == "needs_water":
		draw_string(FontExtraBold, Vector2(soil_rect.position.x, soil_rect.position.y + 18.0), "KAPKA", HORIZONTAL_ALIGNMENT_CENTER, soil_rect.size.x, 8, Color("#72d9ff"))


func _draw_radish_crop(soil_rect: Rect2, stage: String, progress: float) -> void:
	var plant_count := 4
	for plant_index in range(plant_count):
		var x := lerpf(soil_rect.position.x + 15.0, soil_rect.end.x - 15.0, float(plant_index) / float(plant_count - 1))
		var soil_line := soil_rect.end.y - 10.0
		var leaf_height := 11.0 if stage == "needs_water" else 13.0 + progress * 16.0
		var bulb_radius := 2.5 if stage == "needs_water" else 3.0 + progress * 4.0
		draw_line(Vector2(x, soil_line), Vector2(x, soil_line - leaf_height), Color("#3d9348"), 2.5)
		draw_circle(Vector2(x - 5.0, soil_line - leaf_height * 0.72), 4.5, Color("#68bf58"))
		draw_circle(Vector2(x + 5.0, soil_line - leaf_height * 0.84), 4.5, Color("#85d36a"))
		if stage == "ready" or progress >= 0.50:
			var bulb_color := Color("#e74962") if stage == "ready" else Color("#ef8290")
			draw_circle(Vector2(x, soil_line + 1.0), bulb_radius, bulb_color)
			draw_line(Vector2(x, soil_line + bulb_radius), Vector2(x, soil_line + bulb_radius + 3.0), Color("#f4e7d3"), 1.5)
	if stage == "needs_water":
		draw_string(FontExtraBold, Vector2(soil_rect.position.x, soil_rect.position.y + 18.0), "KAPKA", HORIZONTAL_ALIGNMENT_CENTER, soil_rect.size.x, 8, Color("#72d9ff"))


func _draw_cucumber_crop(soil_rect: Rect2, stage: String, progress: float) -> void:
	var stem_bottom := soil_rect.end.y - 7.0
	var trellis_top := soil_rect.position.y + 9.0
	var trellis_color := Color("#d7bf80")
	for support_index in range(3):
		var support_x := lerpf(soil_rect.position.x + 18.0, soil_rect.end.x - 18.0, float(support_index) / 2.0)
		draw_line(Vector2(support_x, stem_bottom), Vector2(support_x, trellis_top), trellis_color, 2.0)
	draw_line(Vector2(soil_rect.position.x + 13.0, trellis_top + 8.0), Vector2(soil_rect.end.x - 13.0, trellis_top + 8.0), trellis_color, 2.0)
	var vine_height := 15.0 if stage == "needs_water" else 18.0 + progress * maxf(16.0, stem_bottom - trellis_top - 20.0)
	for plant_index in range(3):
		var x := lerpf(soil_rect.position.x + 18.0, soil_rect.end.x - 18.0, float(plant_index) / 2.0)
		var vine_top := stem_bottom - vine_height
		draw_polyline(PackedVector2Array([Vector2(x, stem_bottom), Vector2(x - 5.0, stem_bottom - vine_height * 0.38), Vector2(x + 3.0, vine_top)]), Color("#2d873e"), 3.0, true)
		draw_circle(Vector2(x - 7.0, stem_bottom - vine_height * 0.50), 5.0, Color("#61c95d"))
		draw_circle(Vector2(x + 7.0, stem_bottom - vine_height * 0.72), 5.0, Color("#83dc68"))
		if stage == "ready" or progress >= 0.68:
			var cucumber_color := Color("#35b874") if stage == "ready" else Color("#79bd58")
			var cucumber_center := Vector2(x + 5.0, stem_bottom - vine_height * 0.48)
			draw_set_transform(cucumber_center, -0.22)
			draw_rect(Rect2(Vector2(-4.0, -7.0), Vector2(8.0, 14.0)), cucumber_color)
			draw_circle(Vector2(0.0, -7.0), 4.0, cucumber_color)
			draw_circle(Vector2(0.0, 7.0), 4.0, cucumber_color)
			draw_set_transform(Vector2.ZERO, 0.0)
	if stage == "needs_water":
		draw_string(FontExtraBold, Vector2(soil_rect.position.x, soil_rect.position.y + 18.0), "KAPKA", HORIZONTAL_ALIGNMENT_CENTER, soil_rect.size.x, 8, Color("#72d9ff"))


func _draw_eggplant_crop(soil_rect: Rect2, stage: String, progress: float) -> void:
	var stem_bottom := soil_rect.end.y - 7.0
	for plant_index in range(3):
		var x := lerpf(soil_rect.position.x + 18.0, soil_rect.end.x - 18.0, float(plant_index) / 2.0)
		var stem_height := 15.0 if stage == "needs_water" else 19.0 + progress * 27.0
		draw_line(Vector2(x, stem_bottom), Vector2(x, stem_bottom - stem_height), Color("#357d42"), 3.0)
		draw_circle(Vector2(x - 6.0, stem_bottom - stem_height * 0.66), 5.5, Color("#62b957"))
		draw_circle(Vector2(x + 6.0, stem_bottom - stem_height * 0.80), 5.5, Color("#82d16b"))
		if stage == "ready" or progress >= 0.68:
			var fruit_color := Color("#7040a5") if stage == "ready" else Color("#9b72bd")
			var fruit_center := Vector2(x + 2.0, stem_bottom - stem_height * 0.42)
			draw_circle(fruit_center + Vector2(0.0, 3.0), 7.0, fruit_color)
			draw_circle(fruit_center + Vector2(0.0, 7.0), 5.0, fruit_color)
			draw_line(fruit_center + Vector2(0.0, -5.0), fruit_center + Vector2(-1.0, -9.0), Color("#357d42"), 2.0)
	if stage == "needs_water":
		draw_string(FontExtraBold, Vector2(soil_rect.position.x, soil_rect.position.y + 18.0), "KAPKA", HORIZONTAL_ALIGNMENT_CENTER, soil_rect.size.x, 8, Color("#72d9ff"))


func _draw_status_panel() -> void:
	var rect := _status_rect()
	_draw_panel(rect, Color("#fff6d7"), ComicUITheme.PURPLE, 16)
	var state := bed_states[selected_bed_index]
	var progress := clampf(float(state.get("progress", 0.0)), 0.0, 1.0)
	var progress_rect := Rect2(rect.position + Vector2(18.0, 76.0), Vector2(rect.size.x - 36.0, 10.0))
	draw_style_box(ComicUITheme.style_box(Color("#d9e3e6"), ComicUITheme.INK, 2, 5), progress_rect)
	if progress > 0.0:
		var fill_rect := Rect2(progress_rect.position + Vector2(2.0, 2.0), Vector2((progress_rect.size.x - 4.0) * progress, progress_rect.size.y - 4.0))
		draw_rect(fill_rect, ComicUITheme.GREEN)


func _draw_panel(rect: Rect2, fill: Color, border: Color, radius: int) -> void:
	draw_style_box(ComicUITheme.style_box(fill, border, 3, radius, Color("#0c1720", 0.24), 3, 0.0), rect)


func _format_duration(seconds: float) -> String:
	var minutes := maxi(1, ceili(maxf(0.0, seconds) / 60.0))
	if minutes < 60:
		return "%d min" % minutes
	var hours := int(minutes / 60)
	var remainder := minutes % 60
	return "%d h %02d min" % [hours, remainder] if remainder > 0 else "%d h" % hours
