class_name PlayerRoomCollectionView
extends Control

signal rack_requested
signal theme_requested
signal decoration_slot_requested(slot_index: int)
signal plant_move_requested(source_slot: int, target_slot: int, decoration_id: String)
signal plant_drag_started

const ComicUITheme := preload("res://scripts/ui/comic_ui.gd")
const GardenSceneFraming := preload("res://scripts/ui/garden_scene_framing.gd")
const VisualDesignSystem := preload("res://scripts/ui/visual_design_system.gd")
const TooltipPolicy := preload("res://scripts/ui/tooltip_policy.gd")
const PlantDragController := preload("res://scripts/ui/room_plant_drag_controller.gd")
const PlantRenderGeometry := preload("res://scripts/ui/room_plant_render_geometry.gd")
const PaintedDetailArt := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const FontSemiBold := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const FontExtraBold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const PlayerRoomInterior := preload("res://assets/ui/player_room/player_room_phase149_target_clean_v1.png")
const PlayerRoomForegroundOcclusion := preload("res://assets/ui/visual/phase158/player_room/player_room_furniture_foreground_phase158_v2.png")
const PlayerRoomPhase146Interior := preload("res://assets/ui/player_room/player_room_interior_phase146_approved_empty_v1.png")
const PlayerRoomApprovedFullMaster := preload("res://assets/ui/player_room/player_room_interior_phase146_approved_full_v1.png")
const PlayerRoomFixedDecorLayer := preload("res://assets/ui/visual/phase146/player_room_fixed_decor_layer_v3.png")
const PlayerRoomTopShelfProof := preload("res://assets/ui/player_room/player_room_interior_phase139_top_shelf_proof_v1.png")

const SUPPORTED_THEMES := ["sunrise", "lagoon", "amethyst", "research_study"]
const DECORATION_SLOT_COUNT := 20
const PLANT_SLOT_COUNT := 12
const PHASE159_RETIRED_POTS_SLOT_INDEX := 14
const PHASE159_BOTANICAL_CLOCHE_SLOT_INDEX := 15
const PHASE160_DORMANT_DECORATION_SLOT_INDICES: Array[int] = [17, 19]
const PHASE149_CANONICAL_SLOT_IDS := [
	"room_orchid",
	"mini_monstera",
	"snake_plant",
	"room_fern",
	"flowering_begonia",
	"round_leaf_pilea",
	"striped_calathea",
	"lemon_maranta",
	"silver_aglaonema",
	"pink_fittonia",
	"climbing_pothos",
	"colorful_coleus",
	"botanical_books",
	"fertilizer_collection",
	"nested_pots",
	"golden_lamp",
	"botanical_print",
	"plastic_watering_can",
	"preserved_herb_jars",
	"cat_corner",
]
const TOUCH_TARGET_SIZE := Vector2(64.0, 64.0)
const DECORATION_TOUCH_TARGET_MIN := Vector2(56.0, 56.0)
const PHASE146_TITLE_RECT := Rect2(8.0, 8.0, 204.0, 58.0)
const PHASE146_BACK_RECT := Rect2(8.0, 76.0, 96.0, 60.0)
const PHASE146_THEME_RECT := Rect2(112.0, 76.0, 108.0, 60.0)
const PHASE149_BACK_RECT := Rect2(14.0, 76.0, 91.0, 58.0)
const PHASE149_THEME_RECT := Rect2(112.0, 76.0, 104.0, 59.0)
const PHASE146_NESTED_POTS_SHELF_OCCLUSION := Rect2(700.0, 1108.0, 150.0, 18.0)
const PHASE146_FIXED_MASTER_REGIONS := {
	12: [Rect2(535.0, 240.0, 165.0, 135.0)], # knihy
	13: [Rect2(535.0, 415.0, 180.0, 130.0)], # hnojiva
	14: [Rect2(700.0, 955.0, 148.0, 165.0)], # vnořené květináče
	15: [Rect2(575.0, 950.0, 105.0, 160.0)], # lampička
	16: [Rect2(724.0, 414.0, 145.0, 140.0)], # botanický obraz
	17: [Rect2(538.0, 1245.0, 150.0, 165.0)], # konvička
	18: [Rect2(695.0, 245.0, 180.0, 120.0)], # sklenice s bylinkami
	19: [
		Rect2(671.0, 1255.0, 216.0, 165.0), # pelíšek
		Rect2(615.0, 1395.0, 215.0, 110.0), # obě misky
	],
}
const PHASE146_FIXED_MASTER_OFFSETS := {
	12: Vector2.ZERO,
	13: Vector2.ZERO,
	14: Vector2(0.0, 8.0),
	15: Vector2.ZERO,
	16: Vector2.ZERO,
	17: Vector2.ZERO,
	18: Vector2.ZERO,
	19: Vector2.ZERO,
}

var selected_theme_id := "sunrise"
var back_button: Button
var theme_button: Button
var decoration_slots: Array[String] = ["", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""]
var decoration_catalog: Dictionary = {}
var achievement_badge_ids: Array[String] = []
var achievement_badge_icons: Dictionary = {}
var decoration_buttons: Array[Button] = []
var animations_paused := false
var reduced_motion_enabled := false
var ambient_phase := 0.0
var plant_drag := PlantDragController.new()
var plant_drag_enabled := true
var plant_drag_notice := ""
var plant_drag_notice_seconds := 0.0
var _plant_mesh_cache: Dictionary = {}
var _plant_mesh_cache_size := Vector2.ZERO


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	set_meta("component", "phase124_player_room_living_collection_v1")
	set_meta("location_id", "player_room")
	set_meta("decoration_slots", DECORATION_SLOT_COUNT)
	set_meta("phase166_room_plant_drag", "hold_450ms_owned_plant_move_or_swap_save_safe_v2")
	set_meta("phase167_room_plant_geometry", PlantRenderGeometry.CONTRACT)
	set_meta("phase167_room_plant_alpha", "restored_original_atlas_petals_same_canvas_v1")
	set_meta("phase168_render_work", "static_until_changed_hold_and_notice_ticks_cached_mesh_v1")
	set_meta("plant_display_slots", PLANT_SLOT_COUNT)
	set_meta("fixed_display_slots", DECORATION_SLOT_COUNT - PLANT_SLOT_COUNT)
	set_meta("achievement_display_slots", 6)
	set_meta("achievement_display_ready", true)
	set_meta("pet_display_slots", 1)
	set_meta("future_pet_purchase_ready", true)
	set_meta("pet_care_active", false)
	set_meta("window_life_component", "phase124_ambient_window_life_v1")
	set_meta("window_life_pauses", true)
	set_meta("window_life_reduced_motion_static", true)
	set_meta("gameplay_bonuses", false)
	set_meta("painted_title_overlay", "compact_wood_replaces_white_plate_font_safe_v3")
	set_meta("phase104_room_decorations", "purchase_once_move_free_v1")
	set_meta("phase123_room_visual", "painted_interior_dynamic_collection_v1")
	set_meta("phase124_room_living_details", "pet_corner_herb_jars_window_life_v1")
	set_meta("phase126_room_framing", "close_display_wall_source_anchored_v1")
	set_meta("phase127_visual_design_system", VisualDesignSystem.CONTRACT_ID)
	set_meta("phase128_style_parity", VisualDesignSystem.PLANTS_STYLE_PARITY_ID)
	set_meta("phase128_style_reference", VisualDesignSystem.PLANTS_STYLE_REFERENCE_ID)
	set_meta("phase128_style_refinement", VisualDesignSystem.PLANTS_STYLE_REFINEMENT_ID)
	set_meta("phase129_location_focus", GardenSceneFraming.FOCUSED_LOCATION_CONTRACT_ID)
	set_meta("phase132_room_living_visual", VisualDesignSystem.PLAYER_ROOM_LIVING_VISUAL_ID)
	set_meta("phase133_shelf_plant_display", VisualDesignSystem.PLAYER_ROOM_SHELF_PLANT_DISPLAY_ID)
	set_meta("phase134_shelf_fit", VisualDesignSystem.PLAYER_ROOM_SHELF_FIT_DISPLAY_ID)
	set_meta("phase135_reference_regraph", VisualDesignSystem.PLAYER_ROOM_REFERENCE_REGRAPH_ID)
	set_meta("phase136_shelf_prominence", VisualDesignSystem.PLAYER_ROOM_SHELF_PROMINENCE_ID)
	set_meta("phase137_integrated_shelf_set", VisualDesignSystem.PLAYER_ROOM_INTEGRATED_SHELF_SET_ID)
	set_meta("phase139_top_shelf_unified_proof", "phase139_top_shelf_unified_proof_v1")
	set_meta("phase139_unified_room_set", VisualDesignSystem.PLAYER_ROOM_UNIFIED_ROOM_SET_ID)
	set_meta("phase139_framing", GardenSceneFraming.PLAYER_ROOM_PHASE139_FRAMING_ID)
	set_meta("phase140_shared_decor_set", VisualDesignSystem.PLAYER_ROOM_SHARED_DECOR_SET_ID)
	set_meta("phase140_decor_framing", GardenSceneFraming.PLAYER_ROOM_PHASE140_DECOR_FRAMING_ID)
	set_meta("phase140_achievement_holders", "six_integrated_empty_wood_brass_holders_v1")
	set_meta("phase140_pet_corner", "empty_cat_bed_only_no_bowls_v1")
	set_meta("phase140_floor_clearance", "watering_can_and_bed_outside_rug_center_path_v1")
	set_meta("phase141_final_rack_set", VisualDesignSystem.PLAYER_ROOM_FINAL_RACK_SET_ID)
	set_meta("phase141_purchasable_plant_count", PLANT_SLOT_COUNT)
	set_meta("phase141_plant_geometry", "four_shelves_three_slots_shared_pot_saucer_v1")
	set_meta("phase141_rendering", "approved_painterly_rgba_no_checkerboard_no_halo_v1")
	set_meta("plants_reference_policy", "read_only_visual_reference_v1")
	set_meta("phase141_rack_runtime_policy", "approved_phase141_final_rack_runtime_v1")
	set_meta("phase142_reference_exact_set", VisualDesignSystem.PLAYER_ROOM_REFERENCE_EXACT_SET_ID)
	set_meta("phase142_reference_exact_count", PLANT_SLOT_COUNT)
	set_meta("phase142_reference_exact_framing", GardenSceneFraming.PLAYER_ROOM_PHASE142_FRAMING_ID)
	set_meta("phase142_reference_exact_policy", "approved_reference_rgb_mask_alpha_no_repaint_v1")
	set_meta("phase143_approved_uniform_set", VisualDesignSystem.PLAYER_ROOM_APPROVED_UNIFORM_SET_ID)
	set_meta("phase143_approved_uniform_count", PLANT_SLOT_COUNT)
	set_meta("phase143_approved_uniform_framing", GardenSceneFraming.PLAYER_ROOM_PHASE143_FRAMING_ID)
	set_meta("phase143_approved_uniform_policy", "approved_preview_rgb_mask_alpha_isotropic_two_thirds_v1")
	set_meta("phase145_layered_room_details", VisualDesignSystem.PLAYER_ROOM_LAYERED_DETAILS_ID)
	set_meta("phase145_details_framing", GardenSceneFraming.PLAYER_ROOM_PHASE145_DETAILS_FRAMING_ID)
	set_meta("phase145_pet_corner", "separate_floor_shadow_bed_and_paired_bowls_v1")
	set_meta("phase145_nested_pots", "shelf_shadow_sprite_front_lip_v1")
	set_meta("phase145_save_schema", "unchanged_41_single_cat_corner_purchase_v1")
	set_meta("phase146_approved_room_master", VisualDesignSystem.PLAYER_ROOM_APPROVED_MASTER_ID)
	set_meta("phase146_master_dimensions", Vector2i(887, 1774))
	set_meta("phase146_render_policy", "empty_master_base_isolated_rgba_fixed_layer_contact_shadows_and_phase143_movable_plants_v3")
	set_meta("phase146_fixed_decor_cleanup", "isolated_shadow_free_source_separate_runtime_contact_shadows_v3")
	set_meta("phase146_save_schema", "unchanged_41_twenty_existing_purchase_slots_v1")
	set_meta("phase148_painted_cartoon_set", VisualDesignSystem.PLAYER_ROOM_PAINTED_CARTOON_SET_ID)
	set_meta("phase148_style_id", VisualDesignSystem.APPROVED_PAINTED_CARTOON_STYLE_ID)
	set_meta("phase148_framing", GardenSceneFraming.PLAYER_ROOM_PHASE148_FRAMING_ID)
	set_meta("phase148_render_policy", "painted_empty_environment_independent_rgba_plants_and_decor_preserved_ui_chrome_v1")
	set_meta("phase148_alpha_policy", "deterministic_checker_background_alpha_only_source_rgb_preserved_v1")
	set_meta("phase148_save_schema", "unchanged_41_twenty_existing_purchase_slots_v1")
	set_meta("phase149_exact_target_set", VisualDesignSystem.PLAYER_ROOM_EXACT_TARGET_SET_ID)
	set_meta("phase149_framing", GardenSceneFraming.PLAYER_ROOM_PHASE149_FRAMING_ID)
	set_meta("phase149_render_policy", "exact_target_clean_plate_twenty_slots_twenty_one_target_rgba_layers_foreground_occlusion_v1")
	set_meta("phase149_canonical_full_policy", "byte_exact_target_master_when_twenty_slots_match_dynamic_layers_otherwise_v1")
	set_meta("phase149_interaction_policy", "baked_chrome_transparent_functional_hitboxes_purchase_move_free_v1")
	set_meta("phase149_save_schema", "unchanged_41_twenty_existing_purchase_slots_v1")
	set_meta("phase158_room_compositing_fix", "object_free_clean_plate_foreground_same_geometry_v2")
	set_meta("phase158_dynamic_collectible_fix", "phase148_clean_rgba_target_native_layout_v3")
	set_meta("phase158_fern_alpha_fix", "phase148_orthogonal_envelope_margin4_bottom_right_contour_alpha_only_v3")
	set_meta("phase158_save_schema", "unchanged_41_visual_only_v1")
	set_meta("phase160_room_floor_declutter", "dormant_watering_can_pet_corner_no_runtime_draw_v1")
	set_meta("phase160_future_pet_contract", "preserve_receipt_and_slot_until_integrated_pet_purchase_v1")
	set_meta("phase160_source_asset_policy", "historical_png_unchanged_runtime_suppression_v1")
	set_meta("location_header_layout", "phase149_target_baked_header_transparent_hitboxes_v1")
	set_meta("scene_visual_profile", str(VisualDesignSystem.scene_profile("player_room").get("id", "")))
	set_meta("asset_profile_policy", "explicit_profile_or_family_gate_v1")
	set_meta("room_sprite_set", VisualDesignSystem.PLAYER_ROOM_EXACT_TARGET_SET_ID)
	set_meta("decoration_sprite_set", VisualDesignSystem.PLAYER_ROOM_EXACT_TARGET_SET_ID)
	set_meta("visual_camera_component", GardenSceneFraming.CONTRACT_ID)
	set_meta("visual_camera_reference_size", GardenSceneFraming.REFERENCE_CONTENT_SIZE)
	set_meta("visual_camera_hero_band", GardenSceneFraming.HERO_BAND_REFERENCE)
	set_meta("visual_camera_lower_band", GardenSceneFraming.LOWER_BAND_REFERENCE)
	set_meta("primary_width_occupancy_target", GardenSceneFraming.PRIMARY_WIDTH_OCCUPANCY_TARGET)
	set_meta("primary_height_occupancy_target", GardenSceneFraming.PRIMARY_HEIGHT_OCCUPANCY_TARGET)
	set_meta("room_asset", "player_room_phase149_target_clean_v1.png")
	set_meta("room_foreground_asset", "player_room_furniture_foreground_phase158_v2.png")
	set_meta("room_previous_asset", "player_room_interior_phase146_approved_empty_v1.png")
	set_meta("room_full_master_asset", "player_room_interior_phase146_approved_full_v1.png")
	set_meta("room_legacy_asset", "player_room_interior_phase135_reference_regraph_v1.png")
	set_meta("room_source_asset", "player_room_interior_phase126.png")
	set_meta("dynamic_anchor_space", "source_pixels_rect_0_137_853_1548_exact_mapped_v1")
	set_meta("plant_layout", "three_columns_four_shelves_v1")
	set_meta("plant_saucer_asset", "target_integrated_pot_saucer_and_contact_shadow_v1")
	set_meta("plant_grounding", "target_native_baseline_with_object_free_furniture_front_occlusion_v2")
	set_meta("plant_compositing", "phase167_recovered_rgba_measured_mesh_linear_mipmaps_v1")
	set_meta("plant_fit_policy", "measured_shared_ceramic_isotropic_crown_per_shelf_v1")
	set_meta("plant_prominence_policy", "approved_phase143_uniform_pots_saucers_baselines_v1")
	set_meta("plant_integration_policy", "phase167_measured_contact_continuous_uv_object_free_foreground_v1")
	set_meta("pixel_art_policy", "forbidden_for_room_environment_and_collectibles_v1")
	set_meta("touch_anchor_policy", "source_anchor_clamped_to_surface_v1")
	set_meta("responsive_test_viewports", [Vector2i(432, 960), Vector2i(360, 800)])
	resized.connect(_on_resized)
	visibility_changed.connect(_on_drag_visibility_changed)
	_build_navigation()
	_build_decoration_buttons()
	_layout_decoration_buttons()
	queue_redraw()
	_sync_plant_processing()


func _build_navigation() -> void:
	back_button = Button.new()
	back_button.text = ""
	TooltipPolicy.apply(back_button, "Zpět na stojan")
	back_button.focus_mode = Control.FOCUS_NONE
	back_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
	back_button.position = PHASE149_BACK_RECT.position
	back_button.size = PHASE149_BACK_RECT.size
	var empty_style := StyleBoxEmpty.new()
	for style_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		back_button.add_theme_stylebox_override(style_name, empty_style)
	back_button.set_meta("component", "phase103_player_room_rack_return_v1")
	back_button.set_meta("touch_target_min", PHASE149_BACK_RECT.size)
	back_button.set_meta("visual_policy", "phase149_baked_chrome_transparent_hitbox_v1")
	back_button.pressed.connect(_on_back_pressed)
	add_child(back_button)

	theme_button = Button.new()
	theme_button.text = ""
	TooltipPolicy.apply(theme_button, "Vzhled pokoje")
	theme_button.focus_mode = Control.FOCUS_NONE
	theme_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
	theme_button.position = PHASE149_THEME_RECT.position
	theme_button.size = PHASE149_THEME_RECT.size
	for style_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		theme_button.add_theme_stylebox_override(style_name, empty_style)
	theme_button.set_meta("component", "phase103_player_room_theme_launcher_v1")
	theme_button.set_meta("touch_target_min", PHASE149_THEME_RECT.size)
	theme_button.set_meta("visual_policy", "phase149_baked_chrome_transparent_hitbox_v1")
	theme_button.pressed.connect(_on_theme_pressed)
	add_child(theme_button)


func set_cosmetic_theme(theme_id: String) -> void:
	var normalized_theme := theme_id if theme_id in SUPPORTED_THEMES else "sunrise"
	if selected_theme_id == normalized_theme and has_meta("selected_theme_id"):
		return
	selected_theme_id = normalized_theme
	set_meta("selected_theme_id", selected_theme_id)
	queue_redraw()


func set_room_decorations(slot_ids: Array[String], catalog: Dictionary) -> void:
	# The main UI refreshes live values regularly, but this collection changes
	# only on purchase, placement or restore. Keep its own deep snapshot without
	# repeatedly cloning the catalog or rebuilding an identical canvas.
	var same_catalog := catalog == decoration_catalog
	if same_catalog and slot_ids == decoration_slots and has_meta("stored_placed_decoration_count"):
		return
	var normalized_slots := _empty_decoration_slots()
	var stored_placed_count := 0
	var visible_placed_count := 0
	for slot_index in range(mini(DECORATION_SLOT_COUNT, slot_ids.size())):
		var decoration_id := str(slot_ids[slot_index])
		if decoration_id.is_empty() or catalog.has(decoration_id):
			normalized_slots[slot_index] = decoration_id
			if not decoration_id.is_empty():
				stored_placed_count += 1
				if not _is_hidden_decoration_slot(slot_index):
					visible_placed_count += 1
	if same_catalog and normalized_slots == decoration_slots and has_meta("stored_placed_decoration_count"):
		return
	if plant_drag.is_tracking():
		cancel_plant_drag()
	if not same_catalog:
		decoration_catalog = catalog.duplicate(true)
	decoration_slots.assign(normalized_slots)
	set_meta("placed_decoration_count", visible_placed_count)
	set_meta("stored_placed_decoration_count", stored_placed_count)
	queue_redraw()


func set_achievement_display(badge_ids: Array[String], icons: Dictionary) -> void:
	var displayed: Array[String] = []
	# The painted shelf has six holders. Keep the newest earned milestone visible
	# when the player eventually completes more than six permanent goals.
	for index in range(maxi(0, badge_ids.size() - 6), badge_ids.size()):
		var badge_id := badge_ids[index]
		if icons.has(badge_id) and icons[badge_id] is Texture2D:
			displayed.append(badge_id)
	if displayed == achievement_badge_ids:
		return
	achievement_badge_ids = displayed
	achievement_badge_icons = icons
	set_meta("achievement_display_count", achievement_badge_ids.size())
	queue_redraw()


func _empty_decoration_slots() -> Array[String]:
	var result: Array[String] = []
	result.resize(DECORATION_SLOT_COUNT)
	result.fill("")
	return result


func set_paused(paused: bool) -> void:
	animations_paused = paused
	set_meta("animations_paused", paused)


func set_fast_time_visuals(_enabled: bool) -> void:
	pass


func set_reduced_motion(enabled: bool) -> void:
	reduced_motion_enabled = enabled
	set_meta("reduced_motion", enabled)


func _process(delta: float) -> void:
	if not is_visible_in_tree():
		_sync_plant_processing()
		return
	if _plant_hold_needs_ticks():
		if plant_drag.advance_hold(delta):
			plant_drag_started.emit()
		queue_redraw()
	if plant_drag_notice_seconds > 0.0:
		plant_drag_notice_seconds = maxf(0.0, plant_drag_notice_seconds - maxf(0.0, delta))
		if plant_drag_notice_seconds == 0.0:
			queue_redraw()
	_sync_plant_processing()


func _plant_hold_needs_ticks() -> bool:
	return plant_drag_enabled and plant_drag.is_tracking() and not plant_drag.cancelled and not plant_drag.dragging


func _sync_plant_processing() -> void:
	# The approved painted composition has no time-dependent ambient draw.
	# Only the hold ring animates. Pointer events redraw a lifted plant; a static
	# notice needs a timeout, but no redraw until it disappears. Input is routed
	# by main._input independently of this view's process callback.
	set_process(is_visible_in_tree() and (_plant_hold_needs_ticks() or plant_drag_notice_seconds > 0.0))


func _on_back_pressed() -> void:
	rack_requested.emit()


func _on_theme_pressed() -> void:
	theme_requested.emit()


func _on_decoration_slot_pressed(slot_index: int) -> void:
	if plant_drag.is_tracking():
		return
	decoration_slot_requested.emit(slot_index)


func set_plant_drag_enabled(enabled: bool) -> void:
	plant_drag_enabled = enabled
	if not enabled and plant_drag.is_tracking():
		cancel_plant_drag()
	_sync_plant_processing()


func cancel_plant_drag(reset_contacts := false) -> void:
	var had_visible_feedback := plant_drag.is_tracking() or plant_drag_notice_seconds > 0.0
	plant_drag.cancel(reset_contacts)
	plant_drag_notice_seconds = 0.0
	_sync_plant_processing()
	if had_visible_feedback:
		queue_redraw()


func _on_drag_visibility_changed() -> void:
	if not is_visible_in_tree():
		cancel_plant_drag()
	_sync_plant_processing()


func plant_slot_hit_rect(slot_index: int) -> Rect2:
	if slot_index < 0 or slot_index >= PLANT_SLOT_COUNT:
		return Rect2()
	var opening := PlantRenderGeometry.shelf_opening(slot_index, size)
	var center := PlantRenderGeometry.slot_center(slot_index, size)
	var bottom := center.y + 16.0
	if slot_index < PLANT_SLOT_COUNT - 3:
		bottom = minf(bottom, PlantRenderGeometry.shelf_opening(slot_index + 3, size).position.y - 1.0)
	return Rect2(opening.position, Vector2(opening.size.x, bottom - opening.position.y))


func plant_render_geometry(asset_id: String, slot_index: int, offset := Vector2.ZERO) -> Dictionary:
	return PlantRenderGeometry.placement(asset_id, slot_index, size, offset)


func plant_slot_at_position(position_value: Vector2, occupied_only := false) -> int:
	for slot_index in range(PLANT_SLOT_COUNT):
		if occupied_only:
			var id := decoration_slots[slot_index]
			if id.is_empty() or str((decoration_catalog.get(id, {}) as Dictionary).get("slot_group", "")) != "plant":
				continue
		if plant_slot_hit_rect(slot_index).has_point(position_value):
			return slot_index
	return -1


func handle_plant_drag_input(event: InputEvent) -> bool:
	var can_start := plant_drag_enabled and is_visible_in_tree()
	# _input supplies viewport coordinates; the room sits below HUD and safe area.
	var local_event := event.xformed_by(get_global_transform_with_canvas().affine_inverse())
	var source := -1
	if can_start and (local_event is InputEventScreenTouch or local_event is InputEventMouseButton):
		source = plant_slot_at_position(local_event.position, true)
	var item_id := decoration_slots[source] if source >= 0 else ""
	# Drain canceled contacts even while a modal or another screen is visible.
	var was_tracking := plant_drag.is_tracking()
	var result := plant_drag.handle_event(local_event, source, item_id, can_start)
	if not was_tracking and plant_drag.is_tracking():
		plant_drag_notice_seconds = 0.0
	_sync_plant_processing()
	if not bool(result.get("handled", false)):
		return false
	queue_redraw()
	match str(result.get("kind", "")):
		"tap":
			decoration_slot_requested.emit(int(result.source_slot))
		"drop":
			var destination := plant_slot_at_position(result.position)
			if destination == int(result.source_slot):
				return true
			if destination >= 0:
				plant_move_requested.emit(int(result.source_slot), destination, str(result.decoration_id))
			else:
				show_plant_move_result(false)
	return true


func show_plant_move_result(moved: bool, swapped := false) -> void:
	plant_drag_notice = ("ROSTLINY VYMĚNĚNY" if swapped else "ROSTLINA PŘESUNUTA") if moved else "PŘESUN ZRUŠEN · VYBER MÍSTO VE STOJANU"
	plant_drag_notice_seconds = 1.6
	_sync_plant_processing()
	queue_redraw()


func plant_drag_will_swap() -> bool:
	if not plant_drag.dragging:
		return false
	var destination := plant_slot_at_position(plant_drag.pointer_position)
	return destination >= 0 and destination != plant_drag.source_slot and not decoration_slots[destination].is_empty()


func _on_resized() -> void:
	_plant_mesh_cache.clear()
	_plant_mesh_cache_size = size
	cancel_plant_drag()
	_layout_navigation()
	_layout_decoration_buttons()
	queue_redraw()


func _layout_navigation() -> void:
	if back_button == null or theme_button == null:
		return
	_layout_phase149_navigation_button(back_button, PHASE149_BACK_RECT)
	_layout_phase149_navigation_button(theme_button, PHASE149_THEME_RECT)


func _layout_phase149_navigation_button(button: Button, painted_rect: Rect2) -> void:
	var hitbox := phase149_navigation_hitbox(painted_rect, size)
	button.position = hitbox.position
	button.size = hitbox.size


static func phase149_navigation_hitbox(painted_rect: Rect2, viewport_size: Vector2) -> Rect2:
	var scaled_rect := phase149_scaled_painted_rect(painted_rect, viewport_size)
	var hitbox_size := Vector2(
		maxf(TOUCH_TARGET_SIZE.x, scaled_rect.size.x),
		maxf(TOUCH_TARGET_SIZE.y, scaled_rect.size.y)
	)
	var hitbox_position := Vector2(
		scaled_rect.get_center().x - hitbox_size.x * 0.5,
		scaled_rect.position.y
	)
	hitbox_position.x = clampf(hitbox_position.x, 0.0, maxf(0.0, viewport_size.x - hitbox_size.x))
	hitbox_position.y = clampf(hitbox_position.y, 0.0, maxf(0.0, viewport_size.y - hitbox_size.y))
	return Rect2(hitbox_position, hitbox_size)


static func phase149_scaled_painted_rect(painted_rect: Rect2, viewport_size: Vector2) -> Rect2:
	var responsive_scale := Vector2(
		viewport_size.x / maxf(1.0, VisualDesignSystem.REFERENCE_CONTENT_SIZE.x),
		viewport_size.y / maxf(1.0, VisualDesignSystem.REFERENCE_CONTENT_SIZE.y)
	)
	return Rect2(painted_rect.position * responsive_scale, painted_rect.size * responsive_scale)


func _build_decoration_buttons() -> void:
	for slot_index in range(DECORATION_SLOT_COUNT):
		var button := Button.new()
		button.name = "DecorationSlot%d" % (slot_index + 1)
		button.text = ""
		button.flat = true
		button.focus_mode = Control.FOCUS_NONE
		button.mouse_filter = Control.MOUSE_FILTER_STOP
		button.z_index = 6
		TooltipPolicy.apply(button, "Pokojové místo %d" % (slot_index + 1))
		if slot_index < PLANT_SLOT_COUNT:
			TooltipPolicy.apply(button, "Klikni pro výběr dekorace. Podrž a přetáhni rostlinu; obsazené místo obě rostliny prohodí.")
		button.set_meta("component", "phase123_room_decoration_slot_v1")
		button.set_meta("slot_index", slot_index)
		button.set_meta("slot_group", _slot_group(slot_index))
		button.set_meta("touch_target_min", DECORATION_TOUCH_TARGET_MIN)
		button.custom_minimum_size = DECORATION_TOUCH_TARGET_MIN
		if _is_hidden_decoration_slot(slot_index):
			button.visible = false
			button.disabled = true
			button.mouse_filter = Control.MOUSE_FILTER_IGNORE
			if slot_index == PHASE159_RETIRED_POTS_SLOT_INDEX:
				button.set_meta("retired_visual_slot", true)
			else:
				button.set_meta("dormant_visual_slot", true)
				button.set_meta("future_redesign_reserved", true)
		var empty_style := StyleBoxEmpty.new()
		for style_name in ["normal", "hover", "pressed", "focus", "disabled"]:
			button.add_theme_stylebox_override(style_name, empty_style)
		button.pressed.connect(_on_decoration_slot_pressed.bind(slot_index))
		add_child(button)
		decoration_buttons.append(button)


func _layout_decoration_buttons() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var centers := _decoration_slot_centers(size)
	var touch_size := decoration_touch_target_size(size)
	for slot_index in range(mini(decoration_buttons.size(), centers.size())):
		var button := decoration_buttons[slot_index]
		var half_target := touch_size * 0.5
		var clamped_center := Vector2(
			clampf(centers[slot_index].x, half_target.x, maxf(half_target.x, size.x - half_target.x)),
			clampf(centers[slot_index].y, half_target.y, maxf(half_target.y, size.y - half_target.y))
		)
		button.position = clamped_center - half_target
		button.size = touch_size
		if _is_hidden_decoration_slot(slot_index):
			button.visible = false
			button.disabled = true
			button.mouse_filter = Control.MOUSE_FILTER_IGNORE
			continue


static func decoration_touch_target_size(viewport_size: Vector2) -> Vector2:
	var responsive_width := clampf(
		viewport_size.x * TOUCH_TARGET_SIZE.x / maxf(1.0, VisualDesignSystem.REFERENCE_CONTENT_SIZE.x),
		DECORATION_TOUCH_TARGET_MIN.x,
		TOUCH_TARGET_SIZE.x
	)
	return Vector2(responsive_width, TOUCH_TARGET_SIZE.y)


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var palette := _palette_for_theme(selected_theme_id)
	var canonical_target := _is_phase149_canonical_target_state()
	var canonical_texture := VisualDesignSystem.texture_for("player_room_canonical_full") if canonical_target else null
	if canonical_texture != null:
		draw_texture_rect(canonical_texture, Rect2(Vector2.ZERO, size), false)
	else:
		_draw_background_cover()
		# The Phase 149 plate already contains the approved title, buttons, window,
		# furniture and achievement stands. Runtime draws only functional purchases;
		# old primitive motes/title chrome would visibly diverge from the target.
		_draw_decoration_slots(palette, false)
		_draw_phase149_foreground_occlusion()
		# Empty-slot markers are interaction chrome, not room objects. They must sit
		# above the furniture occlusion plate; otherwise shelves cut the circles in
		# half and the room looks like it contains damaged textures.
		_draw_decoration_slots(palette, true)
		_draw_plant_drag_preview(palette)
	_draw_painted_title_overlay()
	_draw_earned_achievements()
	# Optional owned room themes tint the complete composition as one surface.
	# Sunrise stays byte-neutral for the approved Phase 149 target capture.
	if palette.tint.a > 0.0:
		draw_rect(Rect2(Vector2.ZERO, size), palette.tint)
	_draw_plant_drag_hint()


func _draw_plant_drag_preview(palette: Dictionary) -> void:
	if not plant_drag.is_tracking() or plant_drag.cancelled:
		return
	var centers := _decoration_visual_centers(size)
	if not plant_drag.dragging:
		var hold_ratio := plant_drag.hold_elapsed / PlantDragController.HOLD_SECONDS
		if hold_ratio > 0.12:
			draw_arc(centers[plant_drag.source_slot] + Vector2(0.0, -22.0), 25.0, -PI * 0.5, -PI * 0.5 + TAU * hold_ratio, 32, ComicUITheme.CYAN, 3.0, true)
		return
	var hovered := plant_slot_at_position(plant_drag.pointer_position)
	for slot_index in range(PLANT_SLOT_COUNT):
		var free := decoration_slots[slot_index].is_empty() or slot_index == plant_drag.source_slot
		if not free and slot_index != hovered:
			continue
		var color := Color("#67d453") if free else Color("#ffc34d")
		var width := 3.0 if slot_index == hovered else 1.5
		var outline := PackedVector2Array()
		for segment in range(37):
			var angle := TAU * float(segment) / 36.0
			outline.append(centers[slot_index] + Vector2(cos(angle) * 28.0, sin(angle) * 9.0 - 3.0))
		# Build the ellipse in local pixels: scaling the canvas would also squash
		# the stroke and make the target ring look broken on a narrow phone.
		draw_polyline(outline, color, width, true)
	# Reuse the exact existing plant renderer. Its source is hidden while lifted;
	# only after a valid drop does the target shelf apply its foliage-height fit.
	var lifted_center := centers[plant_drag.source_slot] + plant_drag.pointer_position - plant_drag.start_position + Vector2(0.0, -10.0)
	_draw_decoration_item(plant_drag.decoration_id, lifted_center, palette, plant_drag.source_slot)


func _draw_plant_drag_hint() -> void:
	var message := plant_drag_notice
	if plant_drag.dragging:
		message = "PUŠTĚNÍM SI ROSTLINY VYMĚNÍ MÍSTA" if plant_drag_will_swap() else "VOLNÉ MÍSTO: PŘESUN · OBSAZENÉ: VÝMĚNA"
	if not plant_drag.dragging and plant_drag_notice_seconds <= 0.0:
		return
	var hint_rect := Rect2(8.0, size.y - 34.0, maxf(1.0, size.x - 16.0), 28.0)
	draw_rect(hint_rect, Color(0.03, 0.14, 0.18, 0.92))
	draw_string(FontSemiBold, hint_rect.position + Vector2(5.0, 18.0), message, HORIZONTAL_ALIGNMENT_CENTER, hint_rect.size.x - 10.0, 10, ComicUITheme.CREAM)


func _is_phase149_canonical_target_state() -> bool:
	# The byte-exact full master remains immutable historical evidence. It still
	# contains the Phase145 watering can and pet vignette, so production must not
	# select it after Phase160; only the explicit Phase149 report capture may.
	if str(get_meta("capture_state", "")) != "phase149_exact_player_room_target_report_only_v1":
		return false
	if _is_phase139_top_shelf_proof() or _is_phase146_capture():
		return false
	if decoration_slots.size() != PHASE149_CANONICAL_SLOT_IDS.size():
		return false
	for slot_index in range(PHASE149_CANONICAL_SLOT_IDS.size()):
		if decoration_slots[slot_index] != str(PHASE149_CANONICAL_SLOT_IDS[slot_index]):
			return false
	return true


func _draw_background_cover() -> void:
	if _is_phase139_top_shelf_proof():
		var source_rect := GardenSceneFraming.cover_source_rect(PlayerRoomTopShelfProof.get_size(), size)
		draw_texture_rect_region(PlayerRoomTopShelfProof, Rect2(Vector2.ZERO, size), source_rect)
		return
	elif _is_phase146_capture():
		var source_rect := GardenSceneFraming.cover_source_rect(PlayerRoomPhase146Interior.get_size(), size)
		draw_texture_rect_region(PlayerRoomPhase146Interior, Rect2(Vector2.ZERO, size), source_rect)
		return
	draw_texture_rect(PlayerRoomInterior, Rect2(Vector2.ZERO, size), false)


func _draw_phase149_foreground_occlusion() -> void:
	draw_texture_rect(PlayerRoomForegroundOcclusion, Rect2(Vector2.ZERO, size), false)


func _is_phase139_top_shelf_proof() -> bool:
	return str(get_meta("capture_state", "")) == "phase139_top_shelf_unified_proof_report_only_v1"


func _is_phase146_capture() -> bool:
	return str(get_meta("capture_state", "")) == "phase146_approved_room_master_report_only_v1"


func _palette_for_theme(theme_id: String) -> Dictionary:
	match theme_id:
		"lagoon":
			return {"tint": Color("#26c9cf", 0.11), "accent": ComicUITheme.TEAL, "accent_2": ComicUITheme.CYAN, "ink": ComicUITheme.INK}
		"amethyst":
			return {"tint": Color("#a85bea", 0.12), "accent": ComicUITheme.PURPLE, "accent_2": Color("#f0a7e9"), "ink": ComicUITheme.INK}
		"research_study":
			return {"tint": Color("#173c50", 0.18), "accent": Color("#d9a441"), "accent_2": Color("#79c8c4"), "ink": Color("#17212b")}
		_:
			return {"tint": Color(0.0, 0.0, 0.0, 0.0), "accent": ComicUITheme.ORANGE, "accent_2": ComicUITheme.GOLD, "ink": ComicUITheme.INK}


func _draw_sun_motes(palette: Dictionary) -> void:
	if animations_paused or reduced_motion_enabled:
		return
	for mote_index in range(4):
		var drift := ambient_phase * (5.0 + float(mote_index))
		var mote_x := fmod(size.x * 0.08 + float(mote_index) * size.x * 0.13 + drift, maxf(1.0, size.x * 0.48))
		var mote_y := size.y * 0.22 + sin(ambient_phase + float(mote_index)) * 12.0 + float(mote_index) * 18.0
		draw_circle(Vector2(mote_x, mote_y), 2.0, Color(palette.accent_2, 0.42))


func _draw_window_life(palette: Dictionary) -> void:
	# Všechno zůstává uvnitř skleněné části okna. Při pauze nebo volbě
	# Méně pohybu se zachová živá kompozice, pouze se zastaví její čas.
	var phase := 0.0 if animations_paused or reduced_motion_enabled else ambient_phase
	var window_left := size.x * 0.045
	var window_width := size.x * 0.54
	var cloud_x := window_left + fmod(size.x * 0.07 + phase * 7.0, window_width * 0.72)
	var cloud_y := size.y * 0.17 + sin(phase * 0.35) * 3.0
	var cloud_color := Color("#fff9df", 0.46)
	for cloud_part in [Vector2(0.0, 2.0), Vector2(12.0, -2.0), Vector2(24.0, 3.0), Vector2(35.0, 4.0)]:
		draw_circle(Vector2(cloud_x, cloud_y) + cloud_part, 9.0 if cloud_part.x < 30.0 else 7.0, cloud_color)
	var bird_x := window_left + fmod(size.x * 0.16 + phase * 18.0, window_width * 0.78)
	var bird_y := size.y * 0.235 + sin(phase * 0.8) * 7.0
	var wing := 4.0 + sin(phase * 5.0) * 2.0
	var bird_ink := Color(palette.ink, 0.58)
	draw_line(Vector2(bird_x - 7.0, bird_y + wing), Vector2(bird_x, bird_y), bird_ink, 2.0, true)
	draw_line(Vector2(bird_x, bird_y), Vector2(bird_x + 7.0, bird_y + wing), bird_ink, 2.0, true)
	var butterfly_center := Vector2(size.x * 0.25 + sin(phase * 0.7) * 13.0, size.y * 0.31 + cos(phase * 0.9) * 8.0)
	var flutter := 2.0 + absf(sin(phase * 6.0)) * 3.0
	draw_circle(butterfly_center + Vector2(-flutter, 0.0), 3.5, Color("#f4a4c8", 0.82))
	draw_circle(butterfly_center + Vector2(flutter, 0.0), 3.5, Color("#f7cb55", 0.82))
	draw_line(butterfly_center + Vector2(0.0, -3.0), butterfly_center + Vector2(0.0, 4.0), bird_ink, 1.4, true)


func _draw_painted_title_overlay() -> void:
	var shared_panel := GardenSceneFraming.location_title_panel(size)
	var panel_rect := Rect2(PHASE146_TITLE_RECT.position - Vector2(4.0, 4.0), Vector2(minf(PHASE146_TITLE_RECT.size.x, shared_panel.size.x) + 8.0, PHASE146_TITLE_RECT.size.y + 8.0))
	var title_style := PaintedDetailArt.box("wood", 0.0)
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		title_style.set_texture_margin(side, 12.0)
	draw_style_box(title_style, panel_rect)
	var text_width := panel_rect.size.x - 32.0
	var title_line := Rect2(panel_rect.position + Vector2(16.0, 15.0), Vector2(text_width, 20.0))
	var subtitle_line := Rect2(panel_rect.position + Vector2(16.0, 38.0), Vector2(text_width, 10.0))
	draw_string(FontExtraBold, PaintedDetailArt.centered_text_baseline(FontExtraBold, 17, title_line), "MŮJ POKOJ", HORIZONTAL_ALIGNMENT_CENTER, text_width, 17, ComicUITheme.INK)
	draw_string(FontSemiBold, PaintedDetailArt.centered_text_baseline(FontSemiBold, 8, subtitle_line), "DEKORACE · ÚSPĚCHY · MAZLÍČEK", HORIZONTAL_ALIGNMENT_CENTER, text_width, 8, ComicUITheme.NAVY)


func _draw_title(_palette: Dictionary) -> void:
	_draw_painted_title_overlay()


func _draw_phase140_secondary_wall_shelf() -> void:
	var shelf_texture := VisualDesignSystem.texture_for("room_secondary_wall_shelf")
	if shelf_texture == null:
		return
	var shelf_anchor := GardenSceneFraming.map_player_room_point(GardenSceneFraming.PLAYER_ROOM_SECONDARY_WALL_SHELF_SOURCE, size)
	var shelf_rect := VisualDesignSystem.asset_rect("room_secondary_wall_shelf", shelf_anchor, size)
	draw_texture_rect_region(shelf_texture, shelf_rect, VisualDesignSystem.source_region_for("room_secondary_wall_shelf"))


func _draw_achievement_display(palette: Dictionary) -> void:
	var achievement_centers := GardenSceneFraming.map_player_room_anchors(GardenSceneFraming.PLAYER_ROOM_ACHIEVEMENT_SOURCE_ANCHORS, size)
	var holder_texture := VisualDesignSystem.texture_for("room_achievement_holder")
	for center in achievement_centers:
		if holder_texture != null:
			var holder_rect := VisualDesignSystem.asset_rect("room_achievement_holder", center, size)
			draw_texture_rect_region(holder_texture, holder_rect, VisualDesignSystem.source_region_for("room_achievement_holder"))
		else:
			var fallback_scale := VisualDesignSystem.design_scale(size)
			var wood := Color("#a95818")
			var brass := Color("#e7ad28")
			draw_line(center + Vector2(-12.0, 8.0) * fallback_scale, center + Vector2(-12.0, -8.0) * fallback_scale, wood, 5.0 * fallback_scale, true)
			draw_line(center + Vector2(12.0, 8.0) * fallback_scale, center + Vector2(12.0, -8.0) * fallback_scale, wood, 5.0 * fallback_scale, true)
			draw_line(center + Vector2(-12.0, 8.0) * fallback_scale, center + Vector2(12.0, 8.0) * fallback_scale, brass, 4.0 * fallback_scale, true)


func _draw_earned_achievements() -> void:
	if achievement_badge_ids.is_empty():
		return
	var centers := GardenSceneFraming.map_player_room_anchors(GardenSceneFraming.PLAYER_ROOM_ACHIEVEMENT_SOURCE_ANCHORS, size)
	var scale_factor := VisualDesignSystem.design_scale(size)
	for index in range(mini(achievement_badge_ids.size(), centers.size())):
		var icon := achievement_badge_icons.get(achievement_badge_ids[index]) as Texture2D
		if icon == null:
			continue
		var center := centers[index] + Vector2(0.0, -13.0) * scale_factor
		draw_circle(center + Vector2(0.0, 2.0) * scale_factor, 17.0 * scale_factor, Color("#45250e", 0.38))
		draw_circle(center, 16.0 * scale_factor, Color("#75401a"))
		draw_circle(center, 13.5 * scale_factor, Color("#eab649"))
		draw_circle(center, 11.5 * scale_factor, Color("#fff4d1"))
		var icon_size := Vector2(24.0, 24.0) * scale_factor
		draw_texture_rect(icon, Rect2(center - icon_size * 0.5, icon_size), false)


func _draw_decoration_slots(palette: Dictionary, empty_pass := false) -> void:
	var centers := _decoration_visual_centers(size)
	for slot_index in range(DECORATION_SLOT_COUNT):
		if _is_hidden_decoration_slot(slot_index):
			continue
		if plant_drag.dragging and slot_index == plant_drag.source_slot:
			continue
		# The Phase 139 report-only proof bakes the complete top shelf into one
		# coherent painting. Live gameplay never enters this branch; the three
		# dynamic slot sprites remain authoritative until the visual is approved.
		if _is_phase139_top_shelf_proof() and slot_index < 3:
			continue
		var center := centers[slot_index]
		var decoration_id := decoration_slots[slot_index] if slot_index < decoration_slots.size() else ""
		var slot_is_empty := decoration_id.is_empty() or not decoration_catalog.has(decoration_id)
		if slot_is_empty and empty_pass:
			var empty_center := center + (Vector2(0.0, -2.0) if slot_index < PLANT_SLOT_COUNT else Vector2.ZERO)
			_draw_empty_decoration_slot(empty_center, palette, _slot_group(slot_index))
		elif not slot_is_empty and not empty_pass:
			_draw_decoration_item(decoration_id, center, palette, slot_index)


func _decoration_slot_centers(viewport_size: Vector2) -> PackedVector2Array:
	var centers := GardenSceneFraming.map_player_room_phase149_anchors(GardenSceneFraming.PLAYER_ROOM_PHASE149_PLANT_SOURCE_ANCHORS, viewport_size)
	centers.append_array(GardenSceneFraming.map_player_room_phase149_anchors(GardenSceneFraming.PLAYER_ROOM_PHASE149_FIXED_SOURCE_ANCHORS, viewport_size))
	centers[PHASE159_BOTANICAL_CLOCHE_SLOT_INDEX] = GardenSceneFraming.map_player_room_phase149_point(
		GardenSceneFraming.PLAYER_ROOM_PHASE159_BOTANICAL_CLOCHE_SOURCE,
		viewport_size
	)
	return centers


func _decoration_visual_centers(viewport_size: Vector2) -> PackedVector2Array:
	var centers := GardenSceneFraming.map_player_room_phase149_anchors(GardenSceneFraming.PLAYER_ROOM_PHASE149_PLANT_SOURCE_ANCHORS, viewport_size)
	centers.append_array(GardenSceneFraming.map_player_room_phase149_anchors(GardenSceneFraming.PLAYER_ROOM_PHASE149_FIXED_SOURCE_ANCHORS, viewport_size))
	centers[PHASE159_BOTANICAL_CLOCHE_SLOT_INDEX] = GardenSceneFraming.map_player_room_phase149_point(
		GardenSceneFraming.PLAYER_ROOM_PHASE159_BOTANICAL_CLOCHE_SOURCE,
		viewport_size
	)
	return centers


func _slot_group(slot_index: int) -> String:
	if slot_index < PLANT_SLOT_COUNT:
		return "plant"
	match slot_index:
		12: return "books"
		13: return "fertilizer"
		14: return "retired"
		15: return "lamp"
		16: return "art"
		17: return "watering_can"
		18: return "herb_jars"
		19: return "pet_corner"
		_: return ""


static func _is_hidden_decoration_slot(slot_index: int) -> bool:
	return slot_index == PHASE159_RETIRED_POTS_SLOT_INDEX or slot_index in PHASE160_DORMANT_DECORATION_SLOT_INDICES


func _draw_empty_decoration_slot(center: Vector2, palette: Dictionary, group: String) -> void:
	var visual_scale := clampf(size.x / GardenSceneFraming.REFERENCE_CONTENT_SIZE.x, 0.82, 1.18)
	var radius := (6.0 if group == "plant" else 12.0) * visual_scale
	draw_circle(center, radius, Color("#fff8df", 0.38 if group == "plant" else 0.52))
	draw_arc(center, radius, 0.0, TAU, 24, Color(palette.accent_2, 0.60 if group == "plant" else 0.72), (1.4 if group == "plant" else 2.0) * visual_scale, true)
	var plus_half := 3.0 if group == "plant" else 4.0
	draw_line(center + Vector2(-plus_half, 0.0) * visual_scale, center + Vector2(plus_half, 0.0) * visual_scale, palette.ink, 1.7 * visual_scale)
	draw_line(center + Vector2(0.0, -plus_half) * visual_scale, center + Vector2(0.0, plus_half) * visual_scale, palette.ink, 1.7 * visual_scale)


func _draw_plant_saucer(center: Vector2) -> void:
	var saucer_texture := VisualDesignSystem.texture_for("room_plant_saucer")
	if saucer_texture == null:
		return
	var visual_scale := clampf(size.x / GardenSceneFraming.REFERENCE_CONTENT_SIZE.x, 0.82, 1.18)
	var shadow_center := center + Vector2(0.0, 10.0) * visual_scale
	draw_set_transform(shadow_center, 0.0, Vector2(1.75, 0.40) * visual_scale)
	draw_circle(Vector2.ZERO, 13.0, Color("#4a2715", 0.20))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var saucer_anchor := center + Vector2(0.0, 8.0)
	var saucer_rect := VisualDesignSystem.asset_rect("room_plant_saucer", saucer_anchor, size)
	draw_texture_rect_region(saucer_texture, saucer_rect, VisualDesignSystem.source_region_for("room_plant_saucer"), Color(1.0, 0.97, 0.90, 0.96))


func _draw_plant_saucer_front(center: Vector2) -> void:
	var saucer_texture := VisualDesignSystem.texture_for("room_plant_saucer")
	if saucer_texture == null:
		return
	var saucer_anchor := center + Vector2(0.0, 8.0)
	var full_rect := VisualDesignSystem.asset_rect("room_plant_saucer", saucer_anchor, size)
	var full_region := VisualDesignSystem.source_region_for("room_plant_saucer")
	var front_fraction := 0.46
	var front_rect := Rect2(
		full_rect.position + Vector2(0.0, full_rect.size.y * (1.0 - front_fraction)),
		Vector2(full_rect.size.x, full_rect.size.y * front_fraction)
	)
	var front_region := Rect2(
		full_region.position + Vector2(0.0, full_region.size.y * (1.0 - front_fraction)),
		Vector2(full_region.size.x, full_region.size.y * front_fraction)
	)
	draw_texture_rect_region(saucer_texture, front_rect, front_region, Color(1.0, 0.97, 0.90, 0.98))


func _plant_fit_multiplier(slot_index: int, visual_asset_id: String) -> float:
	if slot_index < 0 or slot_index >= PLANT_SLOT_COUNT:
		return 1.0
	var profile := VisualDesignSystem.asset_profile(visual_asset_id)
	if (
		str(profile.get("exact_target_set", "")) == VisualDesignSystem.PLAYER_ROOM_EXACT_TARGET_SET_ID
		and not bool(profile.get("dynamic_noncanonical_layout", false))
	):
		return 1.0
	if str(profile.get("painted_cartoon_set", "")) == VisualDesignSystem.PLAYER_ROOM_PAINTED_CARTOON_SET_ID:
		return 1.0
	if str(profile.get("approved_uniform_set", "")) == VisualDesignSystem.PLAYER_ROOM_APPROVED_UNIFORM_SET_ID:
		return 1.0
	if str(profile.get("reference_exact_set", "")) == VisualDesignSystem.PLAYER_ROOM_REFERENCE_EXACT_SET_ID:
		return 1.0
	if str(profile.get("unified_room_set", "")) == VisualDesignSystem.PLAYER_ROOM_UNIFIED_ROOM_SET_ID:
		return 1.0
	var authored_size := profile.get("design_size", Vector2.ZERO) as Vector2
	if authored_size.x <= 0.0 or authored_size.y <= 0.0:
		return 1.0
	var row_index := clampi(slot_index / 3, 0, GardenSceneFraming.PLAYER_ROOM_PLANT_ROW_MAX_HEIGHTS.size() - 1)
	var max_height := float(GardenSceneFraming.PLAYER_ROOM_PLANT_ROW_MAX_HEIGHTS[row_index])
	return minf(
		1.0,
		minf(
			GardenSceneFraming.PLAYER_ROOM_PLANT_SLOT_MAX_WIDTH / authored_size.x,
			max_height / authored_size.y
		)
	)


func _draw_measured_shelf_plant(
	texture: Texture2D,
	asset_id: String,
	center: Vector2,
	slot_index: int,
	modulate: Color
) -> bool:
	var offset := center - PlantRenderGeometry.slot_center(slot_index, size)
	var mesh := _plant_mesh_for(asset_id, slot_index)
	if mesh == null:
		return false
	# The geometry and mesh are both reused. Dragging only translates the
	# approved vertices and UVs; it does not allocate a new placement dictionary.
	draw_mesh(mesh, texture, Transform2D(0.0, offset), modulate)
	return true


func _plant_mesh_for(asset_id: String, slot_index: int) -> ArrayMesh:
	if _plant_mesh_cache_size != size:
		_plant_mesh_cache.clear()
		_plant_mesh_cache_size = size
	var key := "%s:%d" % [asset_id, slot_index]
	if not _plant_mesh_cache.has(key):
		var geometry := plant_render_geometry(asset_id, slot_index)
		if geometry.is_empty():
			return null
		_plant_mesh_cache[key] = _build_plant_mesh(geometry)
	return _plant_mesh_cache[key]


func _build_plant_mesh(geometry: Dictionary) -> ArrayMesh:
	var canvas: Vector2 = geometry.canvas
	var bands := PlantRenderGeometry.source_bands(geometry)
	var columns := PlantRenderGeometry.source_columns(geometry)
	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()
	# Adjacent bands share identical source/destination edges. The top is one
	# isotropic quad; only the small low-foliage join changes width smoothly.
	# This is the same path for a resting pot, a lifted pot and a swapped pot.
	for index in range(bands.size() - 1):
		for column in range(columns.size() - 1):
			var source_points := PackedVector2Array([
				Vector2(columns[column], bands[index]), Vector2(columns[column + 1], bands[index]),
				Vector2(columns[column + 1], bands[index + 1]), Vector2(columns[column], bands[index + 1]),
			])
			var first := vertices.size()
			for point in source_points:
				var projected := PlantRenderGeometry.project_source_point(geometry, point)
				vertices.append(Vector3(projected.x, projected.y, 0.0))
				uvs.append(point / canvas)
			indices.append_array(PackedInt32Array([first, first + 1, first + 2, first, first + 2, first + 3]))
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


func _draw_decoration_item(decoration_id: String, center: Vector2, palette: Dictionary, slot_index := -1) -> void:
	var decoration: Dictionary = decoration_catalog.get(decoration_id, {})
	var kind := str(decoration.get("kind", "books"))
	var accent := Color(str(decoration.get("accent", "#55b85a")))
	if _is_phase146_capture() and slot_index >= PLANT_SLOT_COUNT and _draw_phase146_fixed_decoration(slot_index):
		return
	var visual_asset_id := VisualDesignSystem.decoration_asset_id(decoration_id)
	var visual_texture := VisualDesignSystem.texture_for(visual_asset_id)
	if visual_texture != null:
		var is_shelf_plant := slot_index >= 0 and slot_index < PLANT_SLOT_COUNT
		var visual_multiplier := _plant_fit_multiplier(slot_index, visual_asset_id) if is_shelf_plant else 1.0
		var asset_profile := VisualDesignSystem.asset_profile(visual_asset_id)
		var phase149_asset := str(asset_profile.get("exact_target_set", "")) == VisualDesignSystem.PLAYER_ROOM_EXACT_TARGET_SET_ID
		var dynamic_clean_plant := is_shelf_plant and bool(asset_profile.get("dynamic_noncanonical_layout", false))
		var visual_rect := VisualDesignSystem.target_native_asset_rect(visual_asset_id, center, size) if phase149_asset and not dynamic_clean_plant else VisualDesignSystem.asset_rect(visual_asset_id, center, size, visual_multiplier)
		var source_region := VisualDesignSystem.source_region_for(visual_asset_id)
		var phase148_asset := str(asset_profile.get("painted_cartoon_set", "")) == VisualDesignSystem.PLAYER_ROOM_PAINTED_CARTOON_SET_ID
		var phase148_plant := is_shelf_plant and phase148_asset
		var approved_uniform_plant := is_shelf_plant and str(asset_profile.get("approved_uniform_set", "")) == VisualDesignSystem.PLAYER_ROOM_APPROVED_UNIFORM_SET_ID
		var reference_exact_plant := is_shelf_plant and str(asset_profile.get("reference_exact_set", "")) == VisualDesignSystem.PLAYER_ROOM_REFERENCE_EXACT_SET_ID
		var phase139_plant := is_shelf_plant and not approved_uniform_plant and not reference_exact_plant and str(asset_profile.get("unified_room_set", "")) == VisualDesignSystem.PLAYER_ROOM_UNIFIED_ROOM_SET_ID
		if (
				decoration_id == "golden_lamp"
				and str(asset_profile.get("phase159_botanical_cloche", "")) == VisualDesignSystem.PLAYER_ROOM_PHASE159_BOTANICAL_CLOCHE_ID
		):
			_draw_room_contact_shadow(center + Vector2(0.0, -1.0), 48.0, 5.0, 0.20)
		elif decoration_id == "nested_pots" and not phase148_asset and not phase149_asset:
			_draw_room_contact_shadow(center + Vector2(0.0, 1.5), 58.0, 9.0, 0.30)
		elif decoration_id == "cat_corner" and not phase148_asset and not phase149_asset:
			_draw_room_contact_shadow(center + Vector2(0.0, 3.0), 102.0, 15.0, 0.31)
		if phase139_plant:
			var row_index := clampi(slot_index / 3, 0, GardenSceneFraming.PLAYER_ROOM_PLANT_ROW_MAX_HEIGHTS.size() - 1)
			var row_height := float(GardenSceneFraming.PLAYER_ROOM_PLANT_ROW_MAX_HEIGHTS[row_index]) * VisualDesignSystem.design_scale(size)
			var clipped_top := center.y - row_height
			if visual_rect.position.y < clipped_top and visual_rect.size.y > 0.0:
				var crop_pixels := clipped_top - visual_rect.position.y
				var crop_fraction := clampf(crop_pixels / visual_rect.size.y, 0.0, 0.98)
				visual_rect.position.y += crop_pixels
				visual_rect.size.y -= crop_pixels
				source_region.position.y += source_region.size.y * crop_fraction
				source_region.size.y *= 1.0 - crop_fraction
			_draw_phase139_shelf_shadow(center)
		var ambient_modulate := Color.WHITE if phase149_asset or phase148_plant or phase139_plant or reference_exact_plant or approved_uniform_plant else (Color(1.0, 0.965, 0.90, 1.0) if is_shelf_plant else Color.WHITE)
		var dynamic_plant_drawn := dynamic_clean_plant and _draw_measured_shelf_plant(
			visual_texture,
			visual_asset_id,
			center,
			slot_index,
			ambient_modulate
		)
		if not dynamic_plant_drawn:
			draw_texture_rect_region(visual_texture, visual_rect, source_region, ambient_modulate)
		if decoration_id == "nested_pots" and not phase148_asset and not phase149_asset:
			_draw_shelf_front_occlusion(center, 45.0)
		elif decoration_id == "cat_corner":
			_draw_phase145_pet_bowls()
		return
	# Legacy vector fallback is retained only as a safe recovery path.  The Phase
	# 127 contract tests require every live catalog id to resolve before release.
	var responsive_scale := clampf(size.x / GardenSceneFraming.REFERENCE_CONTENT_SIZE.x, 0.82, 1.18)
	if kind == "climbing_vine":
		_draw_plant_shadow(center, 0.88 * responsive_scale)
		draw_set_transform(center, 0.0, Vector2.ONE * 0.88 * responsive_scale)
		_draw_potted_decoration(kind, Vector2.ZERO, accent, palette)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	var is_plant := str(decoration.get("slot_group", "")) == "plant"
	var item_scale := (0.88 if is_plant else 0.94) * responsive_scale
	if is_plant:
		_draw_plant_shadow(center, item_scale)
	draw_set_transform(center, 0.0, Vector2(item_scale, item_scale))
	match kind:
		"books": _draw_books(Vector2.ZERO, accent, palette)
		"fertilizer": _draw_fertilizer(Vector2.ZERO, accent, palette)
		"nested_pots": _draw_nested_pots(Vector2.ZERO, accent, palette)
		"lamp": _draw_lamp(Vector2.ZERO, accent, palette)
		"botanical_art": _draw_botanical_art(Vector2.ZERO, accent, palette)
		"plastic_watering_can": _draw_plastic_watering_can(Vector2.ZERO, accent, palette)
		"herb_jars": _draw_herb_jars(Vector2.ZERO, accent, palette)
		"cat_corner": _draw_cat_corner(Vector2.ZERO, accent, palette)
		_: _draw_potted_decoration(kind, Vector2.ZERO, accent, palette)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_phase146_fixed_decoration(slot_index: int) -> bool:
	if not PHASE146_FIXED_MASTER_REGIONS.has(slot_index):
		return false
	var regions: Array = PHASE146_FIXED_MASTER_REGIONS[slot_index]
	var source_offset: Vector2 = PHASE146_FIXED_MASTER_OFFSETS.get(slot_index, Vector2.ZERO)
	for source_region_variant in regions:
		var source_region: Rect2 = source_region_variant
		var target_region := Rect2(source_region.position + source_offset, source_region.size)
		var destination_top_left := GardenSceneFraming.map_player_room_point(target_region.position, size)
		var destination_bottom_right := GardenSceneFraming.map_player_room_point(target_region.end, size)
		var destination_rect := Rect2(destination_top_left, destination_bottom_right - destination_top_left)
		_draw_phase146_fixed_contact_shadow(destination_rect, slot_index)
		draw_texture_rect_region(PlayerRoomFixedDecorLayer, destination_rect, source_region)
		if slot_index == 14:
			_draw_phase146_nested_pots_shelf_occlusion()
	return true


func _draw_phase146_fixed_contact_shadow(destination_rect: Rect2, slot_index: int) -> void:
	var is_floor_item := slot_index >= 17
	var width_factor := 0.34 if is_floor_item else 0.30
	var radius := destination_rect.size.x * width_factor
	var center := Vector2(destination_rect.get_center().x, destination_rect.end.y - destination_rect.size.y * 0.08)
	draw_set_transform(center, 0.0, Vector2(1.0, 0.24 if is_floor_item else 0.18))
	draw_circle(Vector2.ZERO, radius, Color("#3b2012", 0.20 if is_floor_item else 0.15))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_phase146_nested_pots_shelf_occlusion() -> void:
	if _is_phase139_top_shelf_proof():
		return
	var destination_top_left := GardenSceneFraming.map_player_room_point(PHASE146_NESTED_POTS_SHELF_OCCLUSION.position, size)
	var destination_bottom_right := GardenSceneFraming.map_player_room_point(PHASE146_NESTED_POTS_SHELF_OCCLUSION.end, size)
	var destination_rect := Rect2(destination_top_left, destination_bottom_right - destination_top_left)
	draw_texture_rect_region(
		PlayerRoomPhase146Interior,
		destination_rect,
		PHASE146_NESTED_POTS_SHELF_OCCLUSION
	)
	draw_rect(destination_rect, _palette_for_theme(selected_theme_id).tint)


func _draw_plant_shadow(center: Vector2, item_scale: float) -> void:
	draw_set_transform(center + Vector2(0.0, 11.0 * item_scale), 0.0, Vector2(1.0, 0.32))
	draw_circle(Vector2.ZERO, 17.0 * item_scale, Color("#2a170d", 0.22))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_phase139_shelf_shadow(center: Vector2) -> void:
	var responsive_scale := VisualDesignSystem.design_scale(size)
	draw_set_transform(
		center + Vector2(0.0, 2.0 * responsive_scale),
		0.0,
		Vector2(1.55, 0.22) * responsive_scale
	)
	draw_circle(Vector2.ZERO, 17.0, Color("#3b1d0e", 0.24))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_room_contact_shadow(center: Vector2, width: float, height: float, alpha: float) -> void:
	var responsive_scale := VisualDesignSystem.design_scale(size)
	draw_set_transform(center, 0.0, Vector2(width / maxf(height, 1.0), 1.0) * responsive_scale)
	draw_circle(Vector2.ZERO, height * 0.5, Color("#3b1d0e", alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_shelf_front_occlusion(center: Vector2, width: float) -> void:
	var responsive_scale := VisualDesignSystem.design_scale(size)
	var half_width := width * 0.5 * responsive_scale
	var y := center.y + 1.5 * responsive_scale
	draw_line(
		Vector2(center.x - half_width, y),
		Vector2(center.x + half_width, y),
		Color("#6d3515", 0.46),
		1.6 * responsive_scale,
		true
	)


func _draw_phase145_pet_bowls() -> void:
	var bowls_texture := VisualDesignSystem.texture_for("room_pet_bowls")
	if bowls_texture == null:
		return
	var bowls_center := GardenSceneFraming.map_player_room_phase149_point(GardenSceneFraming.PLAYER_ROOM_PHASE149_PET_BOWLS_SOURCE, size)
	var bowls_profile := VisualDesignSystem.asset_profile("room_pet_bowls")
	if not bool(bowls_profile.get("embedded_contact_shadow", false)):
		_draw_room_contact_shadow(bowls_center + Vector2(0.0, 1.5), 72.0, 8.0, 0.29)
	var bowls_rect := VisualDesignSystem.target_native_asset_rect("room_pet_bowls", bowls_center, size)
	draw_texture_rect_region(bowls_texture, bowls_rect, VisualDesignSystem.source_region_for("room_pet_bowls"))


func _draw_books(center: Vector2, accent: Color, palette: Dictionary) -> void:
	for book_index in range(4):
		var book_width := 42.0 - float(book_index % 2) * 6.0
		var book_y := center.y + 12.0 - float(book_index) * 9.0
		draw_rect(Rect2(center.x - book_width * 0.5, book_y - 7.0, book_width, 8.0), accent.lightened(float(book_index) * 0.10))
		draw_line(Vector2(center.x - book_width * 0.5, book_y + 1.0), Vector2(center.x + book_width * 0.5, book_y + 1.0), palette.ink, 2.0)


func _draw_fertilizer(center: Vector2, accent: Color, palette: Dictionary) -> void:
	_draw_panel(Rect2(center + Vector2(-24.0, -28.0), Vector2(27.0, 40.0)), Color("#d8ae65"), palette.ink, 5)
	_draw_panel(Rect2(center + Vector2(4.0, -24.0), Vector2(21.0, 36.0)), accent, palette.ink, 5)
	draw_circle(center + Vector2(-10.0, -8.0), 5.0, Color("#4d8f45"))
	draw_circle(center + Vector2(14.0, -6.0), 4.0, Color("#f4d969"))


func _draw_nested_pots(center: Vector2, _accent: Color, palette: Dictionary) -> void:
	for pot_index in range(3):
		var offset := Vector2(float(pot_index) * 8.0 - 8.0, float(pot_index) * 4.0 - 8.0)
		var pot_center := center + offset
		draw_colored_polygon(PackedVector2Array([pot_center + Vector2(-15, -8), pot_center + Vector2(15, -8), pot_center + Vector2(11, 12), pot_center + Vector2(-11, 12)]), Color("#d87836").lightened(float(pot_index) * 0.07))
		draw_polyline(PackedVector2Array([pot_center + Vector2(-15, -8), pot_center + Vector2(15, -8), pot_center + Vector2(11, 12), pot_center + Vector2(-11, 12), pot_center + Vector2(-15, -8)]), palette.ink, 2.0)


func _draw_lamp(center: Vector2, accent: Color, palette: Dictionary) -> void:
	draw_circle(center + Vector2(0.0, -25.0), 22.0, Color(accent, 0.24))
	draw_colored_polygon(PackedVector2Array([center + Vector2(-18.0, -30.0), center + Vector2(18.0, -30.0), center + Vector2(11.0, -11.0), center + Vector2(-11.0, -11.0)]), accent)
	draw_polyline(PackedVector2Array([center + Vector2(-18.0, -30.0), center + Vector2(18.0, -30.0), center + Vector2(11.0, -11.0), center + Vector2(-11.0, -11.0), center + Vector2(-18.0, -30.0)]), palette.ink, 3.0)
	draw_line(center + Vector2(0.0, -11.0), center + Vector2(0.0, 13.0), palette.ink, 4.0)
	draw_line(center + Vector2(-13.0, 13.0), center + Vector2(13.0, 13.0), palette.ink, 4.0)


func _draw_botanical_art(center: Vector2, accent: Color, palette: Dictionary) -> void:
	_draw_panel(Rect2(center + Vector2(-24.0, -31.0), Vector2(48.0, 62.0)), Color("#fff4ce"), Color("#7c4d26"), 5)
	draw_line(center + Vector2(0, 18), center + Vector2(0, -17), Color("#34743f"), 3.0)
	for offset in [Vector2(-10, -7), Vector2(10, -14), Vector2(-9, 6), Vector2(9, 1)]:
		draw_circle(center + offset, 7.0, accent)
		draw_line(center, center + offset, Color("#34743f"), 2.0)


func _draw_plastic_watering_can(center: Vector2, accent: Color, palette: Dictionary) -> void:
	_draw_panel(Rect2(center + Vector2(-19.0, -12.0), Vector2(38.0, 30.0)), accent, palette.ink, 8)
	draw_arc(center + Vector2(2.0, -11.0), 18.0, PI, TAU, 20, palette.ink, 4.0, true)
	draw_colored_polygon(PackedVector2Array([center + Vector2(-18, -4), center + Vector2(-39, -18), center + Vector2(-43, -12), center + Vector2(-19, 6)]), accent.lightened(0.08))
	draw_polyline(PackedVector2Array([center + Vector2(-18, -4), center + Vector2(-39, -18), center + Vector2(-43, -12), center + Vector2(-19, 6)]), palette.ink, 3.0)


func _draw_herb_jars(center: Vector2, accent: Color, palette: Dictionary) -> void:
	var herb_colors := [Color("#6f9f45"), Color("#9a7041"), Color("#b3a24d")]
	for jar_index in range(3):
		var jar_center := center + Vector2(float(jar_index - 1) * 18.0, 0.0)
		_draw_panel(Rect2(jar_center + Vector2(-7.0, -17.0), Vector2(14.0, 29.0)), Color("#e9f1d8", 0.72), palette.ink, 4)
		draw_rect(Rect2(jar_center + Vector2(-8.0, -20.0), Vector2(16.0, 5.0)), Color("#bb8652"))
		draw_rect(Rect2(jar_center + Vector2(-5.0, -7.0), Vector2(10.0, 15.0)), herb_colors[jar_index])
		draw_circle(jar_center + Vector2(0.0, -1.0), 2.4, accent.lightened(float(jar_index) * 0.08))


func _draw_cat_corner(center: Vector2, accent: Color, palette: Dictionary) -> void:
	# Bezpečný fallback Phase 140 zobrazuje pouze prázdný pelíšek. Misky, voda,
	# krmivo i samotný mazlíček zůstávají samostatným budoucím obsahem.
	_draw_panel(Rect2(center + Vector2(-41.0, -20.0), Vector2(82.0, 40.0)), accent.darkened(0.20), palette.ink, 18)
	draw_circle(center + Vector2(0.0, 1.0), 22.0, Color("#f3d7ae"))


func _draw_climbing_vine(center: Vector2, accent: Color, palette: Dictionary) -> void:
	var target := GardenSceneFraming.map_player_room_point(GardenSceneFraming.PLAYER_ROOM_VINE_TARGET_SOURCE, size)
	var start := center + Vector2(0.0, -8.0)
	var support_entry := Vector2(target.x, start.y - 56.0)
	var points := PackedVector2Array([
		start,
		Vector2(lerpf(start.x, target.x, 0.58), start.y - 22.0),
		support_entry,
		Vector2(target.x - 4.0, lerpf(support_entry.y, target.y, 0.34)),
		Vector2(target.x + 4.0, lerpf(support_entry.y, target.y, 0.67)),
		target,
	])
	draw_polyline(points, Color("#2f7d3d"), 4.0, true)
	for point_index in range(1, points.size()):
		var point := points[point_index]
		var side := -1.0 if point_index % 2 == 0 else 1.0
		draw_circle(point + Vector2(8.0 * side, 1.0), 6.0, accent)
		draw_line(point, point + Vector2(8.0 * side, 1.0), palette.ink, 1.5)


func _draw_potted_decoration(kind: String, center: Vector2, accent: Color, palette: Dictionary) -> void:
	var pot_color := ComicUITheme.CYAN if kind == "broad_leaf_plant" else (ComicUITheme.PURPLE if kind == "striped_leaf_plant" else Color("#d97835"))
	draw_colored_polygon(PackedVector2Array([center + Vector2(-15.0, -5.0), center + Vector2(15.0, -5.0), center + Vector2(11.0, 14.0), center + Vector2(-11.0, 14.0)]), pot_color)
	draw_polyline(PackedVector2Array([center + Vector2(-15.0, -5.0), center + Vector2(15.0, -5.0), center + Vector2(11.0, 14.0), center + Vector2(-11.0, 14.0), center + Vector2(-15.0, -5.0)]), palette.ink, 2.5)
	if kind == "orchid":
		for offset in [Vector2(-12.0, -37.0), Vector2(0.0, -48.0), Vector2(13.0, -35.0)]:
			draw_line(center + Vector2(0.0, -5.0), center + offset, Color("#317343"), 2.5)
			draw_circle(center + offset, 8.0, accent)
			draw_circle(center + offset, 2.5, ComicUITheme.GOLD)
		return
	if kind == "tall_leaf_plant":
		for leaf_x in [-10.0, -4.0, 4.0, 10.0]:
			draw_colored_polygon(PackedVector2Array([center + Vector2(leaf_x - 4.0, -6.0), center + Vector2(leaf_x, -46.0 + absf(leaf_x) * 0.5), center + Vector2(leaf_x + 5.0, -6.0)]), accent)
		return
	if kind == "fern":
		for angle in [-1.1, -0.72, -0.34, 0.34, 0.72, 1.1]:
			var tip := center + Vector2(cos(angle) * 29.0, -12.0 - sin(absf(angle)) * 24.0)
			draw_line(center + Vector2(0.0, -5.0), tip, Color("#24733b"), 3.0)
			draw_circle(tip, 5.0, accent)
		return
	if kind == "flowering_plant":
		for offset in [Vector2(-14.0, -25.0), Vector2(0.0, -38.0), Vector2(14.0, -24.0)]:
			draw_line(center + Vector2(0.0, -5.0), center + offset, Color("#24733b"), 2.5)
			draw_circle(center + offset, 7.0, accent)
			draw_circle(center + offset, 2.3, ComicUITheme.GOLD)
		return
	var offsets := [Vector2(-15.0, -24.0), Vector2(12.0, -35.0), Vector2(16.0, -18.0), Vector2(-7.0, -41.0)]
	if kind == "round_leaf_plant":
		offsets = [Vector2(-16.0, -20.0), Vector2(-9.0, -37.0), Vector2(8.0, -42.0), Vector2(17.0, -25.0)]
	for offset in offsets:
		draw_line(center + Vector2(0.0, -5.0), center + offset, Color("#24733b"), 2.5)
		draw_circle(center + offset, 8.0, accent)
		if kind == "striped_leaf_plant":
			draw_line(center + offset + Vector2(-5, 0), center + offset + Vector2(5, 0), Color("#4f3868"), 1.6)


func _draw_panel(rect: Rect2, fill: Color, border: Color, radius: int) -> void:
	draw_style_box(ComicUITheme.style_box(fill, border, 3, radius, Color("#0c1720", 0.24), 3, 0.0), rect)
