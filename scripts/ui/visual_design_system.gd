class_name VisualDesignSystem
extends RefCounted

## Phase 127 source of truth for the game's visual language.  Assets are never
## positioned from their raw pixel size: a family profile supplies technical
## defaults and explicit profiles supply the authored footprint and pivot used
## by the three main garden locations.

const CONTRACT_ID := "phase127_final_visual_system_v1"
const RoomPlantGeometry := preload("res://scripts/ui/room_plant_render_geometry.gd")
const STYLE_ID := "bazal_sunny_botanical_comic_v1"
const MASTER_ART_DIRECTION_ID := "phase131_living_botanical_master_v1"
const MASTER_REFERENCE_ASSET := "res://assets/ui/visual/phase128/measurement_corner_backdrop_v1.png"
const MASTER_REFERENCE_SHA256 := "ff3e920e8cc432240ebe9c0620e570a12b7e19aafaafb5faed7a817e849dd0f5"
const APPROVED_PAINTED_CARTOON_STYLE_ID := "phase147_approved_painted_cartoon_v1"
const APPROVED_PAINTED_CARTOON_MASTER_ID := "phase147_approved_painted_cartoon_master_v1"
const APPROVED_PAINTED_CARTOON_MASTER_ASSET := "res://docs/visual-proposals/phase147/approved-painted-cartoon-style-master-v1.png"
const APPROVED_PAINTED_CARTOON_MASTER_SHA256 := "20e5251d8a967d09d4ad6bbfd8bfb40a4cf2093adc120774114f4d925b9c5f80"
const PLANTS_STYLE_PARITY_ID := "phase128_plants_style_parity_v1"
const PLANTS_STYLE_REFERENCE_ID := "measurement_corner_backdrop_v1"
const PLANTS_STYLE_REFINEMENT_ID := "phase128_measurement_led_refinement_v1"
const PLAYER_ROOM_LIVING_VISUAL_ID := "phase132_room_living_visual_v1"
const PLAYER_ROOM_SHELF_PLANT_DISPLAY_ID := "phase133_three_per_shelf_saucer_display_v1"
const PLAYER_ROOM_SHELF_FIT_DISPLAY_ID := "phase134_full_shelf_fit_v1"
const PLAYER_ROOM_REFERENCE_REGRAPH_ID := "phase135_reference_regraph_v1"
const PLAYER_ROOM_SHELF_PROMINENCE_ID := "phase136_reference_b_shelf_fill_v1"
const PLAYER_ROOM_INTEGRATED_SHELF_SET_ID := "phase137_approved_integrated_shelf_set_v1"
const PLAYER_ROOM_UNIFIED_ROOM_SET_ID := "phase139_unified_room_set_v1"
const PLAYER_ROOM_SHARED_DECOR_SET_ID := "phase140_shared_room_decor_set_v1"
const PLAYER_ROOM_FINAL_RACK_SET_ID := "phase141_final_purchasable_rack_set_v1"
const PLAYER_ROOM_REFERENCE_EXACT_SET_ID := "phase142_reference_exact_rack_set_v1"
const PLAYER_ROOM_APPROVED_UNIFORM_SET_ID := "phase143_user_approved_uniform_rack_set_v1"
const PLAYER_ROOM_LAYERED_DETAILS_ID := "phase145_layered_room_details_v1"
const PLAYER_ROOM_APPROVED_MASTER_ID := "phase146_player_room_approved_master_v1"
const PLAYER_ROOM_PAINTED_CARTOON_SET_ID := "phase148_player_room_painted_cartoon_v1"
const PLAYER_ROOM_EXACT_TARGET_SET_ID := "phase149_player_room_exact_target_layers_v1"
const PLAYER_ROOM_PHASE159_BOTANICAL_CLOCHE_ID := "phase159_botanical_cloche_dynamic_v1"
const PLAYER_ROOM_PHASE159_BOTANICAL_CLOCHE_SCALE := 1.15
const PLAYER_ROOM_EXACT_TARGET_ASSET := "res://docs/visual-proposals/phase147/player-room-painted-cartoon-production-target-v1.png"
const PLAYER_ROOM_EXACT_TARGET_SHA256 := "26a4387743aeba8b9f464493d2563bf584620d28e2539e13e73eb076b421794d"
const PLAYER_ROOM_CANONICAL_FULL_ASSET := "res://assets/ui/player_room/player_room_phase149_target_full_v1.png"
const PLAYER_ROOM_CANONICAL_FULL_SHA256 := "82d14a3b872c218b37b860f22e3980466974461a8a05784784bbd7acebded8f7"
const PLAYER_ROOM_SCENE_PROFILE_ID := "player_room_phase149_exact_target_v1"
const GREENHOUSE_PHASE150_RUNTIME_SET_ID := "phase150_greenhouse_dynamic_runtime_v1"
const GREENHOUSE_PHASE150_SCENE_PROFILE_ID := "greenhouse_phase150_dynamic_alpha_v1"
const GREENHOUSE_PHASE150_TARGET_ASSET := "res://docs/visual-proposals/phase150/greenhouse-exact-content-target-v1.png"
const GREENHOUSE_PHASE150_TARGET_SHA256 := "0a780e8c4a707966ed694c7933a15ee5a61b5ed04e88179687d4f46940de2eb2"
const GREENHOUSE_PHASE150_CANONICAL_CONTENT_ASSET := "res://assets/ui/visual/phase150/greenhouse/greenhouse_phase150_canonical_content_v1.png"
const GREENHOUSE_PHASE150_CANONICAL_CONTENT_SHA256 := "0a780e8c4a707966ed694c7933a15ee5a61b5ed04e88179687d4f46940de2eb2"
const GREENHOUSE_PHASE150_SEEDLINGS_ASSET_ID := "greenhouse_phase150_crop_seedlings"
const RACK_PHASE151_RUNTIME_SET_ID := "phase151_rack_dynamic_painted_v1"
const RACK_PHASE151_SCENE_PROFILE_ID := "rack_phase151_dynamic_painted_v1"
const RACK_PHASE151_TARGET_ASSET := "res://docs/visual-proposals/phase151/user-approved-painted-rack-screen-v1.png"
const RACK_PHASE151_TARGET_SHA256 := "7540369ad83e2dcb0a707052c649e8c0e919d621086b970985ea891eff02697c"
const PLANT_DETAIL_PHASE151_SCENE_PROFILE_ID := "plant_detail_phase151_dynamic_painted_v1"
const PLANT_DETAIL_PHASE151_TARGET_ASSET := "res://docs/visual-proposals/phase151/user-approved-painted-detail-screen-v1.png"
const PLANT_DETAIL_PHASE151_TARGET_SHA256 := "599283f38afd50cfc6d121613f9687e15707cdf56ed1de6fe743765727bcafde"
const STORAGE_PHASE152_RUNTIME_SET_ID := "phase152_storage_painted_workshop_v1"
const STORAGE_PHASE152_SCENE_PROFILE_ID := "storage_phase152_painted_workshop_v1"
const STORAGE_PHASE152_TARGET_ASSET := "res://docs/visual-proposals/phase152/user-approved-painted-storage-screen-v1.png"
const STORAGE_PHASE152_TARGET_SHA256 := "d19d7ea1fdc95ae7a69289b555363f0e104fbe029911e46335bdcce567292d28"
const SHOP_PHASE153_RUNTIME_SET_ID := "phase153_shop_painted_botanical_runtime_v1"
const SHOP_PHASE153_SCENE_PROFILE_ID := "shop_phase153_painted_botanical_v1"
const SHOP_PHASE153_TARGET_ASSET := "res://docs/visual-proposals/phase153/user-approved-painted-shop-screen-v1.png"
const SHOP_PHASE153_TARGET_SHA256 := "5a69e32d9ba3ee96feb911f653c4f21cb41d972af5f6599da173eb0dea41d972"
const MEASUREMENT_PHASE154_RUNTIME_SET_ID := "phase154_measurement_painted_botanical_runtime_v1"
const MEASUREMENT_PHASE154_SCENE_PROFILE_ID := "measurement_phase154_painted_botanical_lab_v1"
const MEASUREMENT_PHASE154_TARGET_ASSET := "res://docs/visual-proposals/phase154/user-approved-painted-measurement-screen-v1.png"
const MEASUREMENT_PHASE154_TARGET_SHA256 := "d690acb3d1bcf174f856e7d72498f976991879e24714f9bb1a68d81b5ab46ffb"
const HERBARIUM_PHASE155_RUNTIME_SET_ID := "phase155_herbarium_painted_dynamic_collection_v1"
const HERBARIUM_PHASE155_SCENE_PROFILE_ID := "herbarium_phase155_painted_botanical_book_v1"
const HERBARIUM_PHASE155_TARGET_ASSET := "res://docs/visual-proposals/phase155/user-approved-painted-herbarium-screen-v1.png"
const HERBARIUM_PHASE155_TARGET_SHA256 := "9aba0f190f2acfc3c7795616b8e9a6c0e2f3805c10b3f0bdc8fc6a9cfdd4c697"
const HERBARIUM_PHASE155_BACKDROP_ASSET := "res://assets/ui/visual/phase155/herbarium_clean_backdrop_v1.png"
const HERBARIUM_PHASE155_BACKDROP_SHA256 := "9f2bf8a11d0191fca4867ef56e56120ed36eff2f66de2722f574de2606d04a48"
const DAILY_CHALLENGE_PHASE161_RUNTIME_SET_ID := "phase161_daily_challenge_painted_dynamic_v1"
const DAILY_CHALLENGE_PHASE161_SCENE_PROFILE_ID := "daily_challenge_phase161_painted_dynamic_v1"
const DAILY_CHALLENGE_PHASE161_TARGET_ASSET := "res://docs/visual-proposals/phase161/user-approved-painted-daily-challenge-screen-v1.png"
const DAILY_CHALLENGE_PHASE161_TARGET_SHA256 := "7972356773a32026e400c97c27df4f70881723f50b2e74e28a010d696a12533e"
const DAILY_CHALLENGE_PHASE161_BACKDROP_ASSET := "res://assets/ui/visual/phase161/daily_challenge/daily_challenge_clean_backdrop_v3.png"
const DAILY_CHALLENGE_PHASE161_BACKDROP_SHA256 := "678fa27debe01723aad39e6abc775b847015d321115a7754796e8ed33c4c72b6"
const COSMETIC_SHOWROOM_PHASE162_RUNTIME_SET_ID := "phase162_cosmetic_showroom_painted_dynamic_v1"
const COSMETIC_SHOWROOM_PHASE162_SCENE_PROFILE_ID := "cosmetic_showroom_phase162_painted_dynamic_v1"
const COSMETIC_SHOWROOM_PHASE162_TARGET_ASSET := "res://docs/visual-proposals/phase162/user-approved-painted-cosmetic-showroom-v1.png"
const COSMETIC_SHOWROOM_PHASE162_TARGET_SHA256 := "bc524f1d2c3111630385256481a4acb04cc51d99c2e4cf342d7fa468c3fc5dc0"
const COSMETIC_SHOWROOM_PHASE162_BACKDROP_ASSET := "res://assets/ui/visual/phase162/cosmetic_showroom/cosmetic_showroom_clean_backdrop_v1.png"
const COSMETIC_SHOWROOM_PHASE162_BACKDROP_SHA256 := "a696d1759ef1fe830984e0dc2c8c292fcedc3b9b4cfeb55dbcb7e2849542fcf6"
const RACK_PHASE163_RUNTIME_SET_ID := "phase163_rack_approved_locked_planter_v1"
const RACK_PHASE183_DOCK_RUNTIME_SET_ID := "phase183_rack_compact_four_icon_dock_v1"
const RACK_PHASE163_SCENE_PROFILE_ID := "rack_phase163_approved_locked_planter_v1"
const RACK_PHASE163_TARGET_ASSET := "res://docs/visual-proposals/phase163/user-approved-locked-planter-rack-screen-v1.png"
const RACK_PHASE163_TARGET_SHA256 := "bd906524ed677fb996098578e3efbed3f19c797ac8078cbc8c7db86aeb1bc349"
const RACK_PHASE163_LOCKED_PLANTER_ASSET := "res://assets/ui/visual/phase163/rack/rack_locked_planter_phase163_v1.png"
const RACK_PHASE163_GROW_LIGHT_ASSET := "res://assets/ui/visual/phase163/rack/rack_grow_light_phase163_v1.png"
const REFERENCE_VIEWPORT := Vector2(432.0, 960.0)
const REFERENCE_CONTENT_SIZE := Vector2(432.0, 780.0)
const SAFE_TOUCH_SIZE := Vector2(64.0, 64.0)

const MASTER_ART_DIRECTION_PROFILE := {
	"id": MASTER_ART_DIRECTION_ID,
	"reference_asset": MASTER_REFERENCE_ASSET,
	"reference_sha256": MASTER_REFERENCE_SHA256,
	"medium": "polished_colorful_2d_mobile_game_illustration",
	"palette": "warm_honey_wood_sky_cyan_leaf_green_cream_accents_v1",
	"linework": "smooth_antialiased_illustrated_contour_no_pixel_edges_v2",
	"lighting": "sunny_upper_left_warm_highlight_contact_shadow_v1",
	"materials": "readable_wood_glass_metal_ceramic_soil_leaf_texture_v1",
	"composition": "living_botanical_edges_clear_interaction_center_v1",
	"scene_life": "layered_vegetation_light_motes_weather_and_small_ambient_motion_v1",
	"ui_relationship": "cream_cards_teal_chrome_dark_ink_strong_depth_v1",
	"future_asset_policy": "unified_environment_material_light_and_contact_before_runtime_use_v2",
	"avoid": ["flat_placeholder_geometry", "muddy_low_contrast", "photorealism", "empty_dead_backgrounds", "unprofiled_runtime_png", "pixel_art", "pasted_cutout_collage", "white_sprite_halo", "inconsistent_pot_or_saucer_geometry"],
}

## Phase 147 is a user-approved target, not a retroactive label for the current
## runtime art. A screen can bind to this profile only after every visible
## environment and gameplay layer on that screen has been repainted, isolated
## and verified in Godot. Existing UI chrome is intentionally preserved.
const APPROVED_PAINTED_CARTOON_PROFILE := {
	"id": APPROVED_PAINTED_CARTOON_MASTER_ID,
	"style_id": APPROVED_PAINTED_CARTOON_STYLE_ID,
	"reference_asset": APPROVED_PAINTED_CARTOON_MASTER_ASSET,
	"reference_sha256": APPROVED_PAINTED_CARTOON_MASTER_SHA256,
	"medium": "vivid_hand_painted_2d_cartoon_mobile_illustration",
	"linework": "strong_dark_olive_brown_antialiased_contours_no_pixel_art_v1",
	"color": "saturated_shaped_color_planes_with_crisp_botanical_detail_v1",
	"shading": "two_to_four_step_painted_cel_shading_selective_soft_transitions_v1",
	"lighting": "warm_upper_left_highlight_deep_controlled_contact_shadow_v1",
	"materials": "hand_painted_leaf_ceramic_wood_glass_metal_and_soil_v1",
	"scale": "believable_real_world_relative_scale_with_shared_baselines_v1",
	"composition": "clear_mobile_silhouettes_integrated_layers_no_pasted_cutouts_v1",
	"ui_policy": "preserve_current_buttons_icons_and_navigation_chrome_v1",
	"runtime_policy": "complete_screen_family_migration_only_no_mixed_style_release_v1",
	"source_policy": "preserve_source_pngs_version_new_rgba_layers_and_derivations_v1",
	"avoid": ["pixel_art", "pasted_cutout_collage", "baked_checkerboard", "white_sprite_halo", "glossy_3d_render", "flat_placeholder_geometry", "inconsistent_light", "unshared_baseline"],
}

const APPROVED_PAINTED_CARTOON_TRANSITION_ORDER := [
	"player_room",
	"greenhouse",
	"rack",
	"plant_detail",
	"storage",
	"shop",
	"measurement",
	"modals",
]

const COLOR_TOKENS := {
	"ink": Color("#17212b"),
	"navy": Color("#123f5b"),
	"paper": Color("#fff8df"),
	"cream": Color("#fff0bd"),
	"cyan": Color("#39d8ee"),
	"teal": Color("#18bfc7"),
	"blue": Color("#138fc7"),
	"green": Color("#76d91d"),
	"gold": Color("#ffd51e"),
	"orange": Color("#ff8c22"),
	"purple": Color("#a64fe0"),
	"shadow": Color("#0c1720", 0.34),
}

const TYPOGRAPHY_TOKENS := {
	"display": 25,
	"title": 23,
	"section": 16,
	"body": 12,
	"caption": 10,
	"micro": 8,
}

const SPACING_TOKENS := {
	"xs": 4.0,
	"sm": 8.0,
	"md": 12.0,
	"lg": 16.0,
	"xl": 24.0,
}

const PLANTS_SURFACE_TOKENS := {
	"status_ribbon": {
		"fill": Color("#fff6d8", 0.90),
		"border_width": 3,
		"radius": 12,
		"shadow_size": 3,
		"content_margin": 4.0,
	},
	"information_card": {
		"fill": Color("#fff4c8", 0.90),
		"border_width": 4,
		"radius": 14,
		"shadow_size": 4,
		"content_margin": 6.0,
	},
	"primary_work_surface": {
		"fill": Color("#fff5ce", 0.92),
		"border_width": 4,
		"radius": 16,
		"shadow_size": 5,
		"content_margin": 8.0,
	},
}

const LAYER_ORDER := {
	"environment": 0,
	"ambient": 10,
	"furniture": 20,
	"shadow": 30,
	"collectible": 40,
	"status": 50,
	"interaction": 60,
	"navigation": 70,
	"modal": 100,
}

const FAMILY_PROFILES := {
	"environment_plate": {
		"style_id": STYLE_ID,
		"master_art_direction": MASTER_ART_DIRECTION_ID,
		"filter": true,
		"mipmaps": false,
		"repeat": false,
		"color_space": "srgb",
		"crop_mode": "cover_source_anchored",
		"outline_px": Vector2(0.0, 0.0),
		"lighting_id": "sunny_upper_left_warm_v1",
	},
	"gameplay_plant": {
		"style_id": STYLE_ID,
		"master_art_direction": MASTER_ART_DIRECTION_ID,
		"filter": true,
		"mipmaps": true,
		"repeat": false,
		"color_space": "srgb_alpha",
		"crop_mode": "contain_baseline",
		"outline_px": Vector2(2.0, 5.0),
		"lighting_id": "sunny_upper_left_warm_v1",
	},
	"room_collectible": {
		"style_id": STYLE_ID,
		"master_art_direction": MASTER_ART_DIRECTION_ID,
		"filter": true,
		"mipmaps": false,
		"repeat": false,
		"color_space": "srgb_alpha",
		"crop_mode": "contain_baseline",
		"outline_px": Vector2(2.0, 5.0),
		"lighting_id": "sunny_upper_left_warm_v1",
	},
	"greenhouse_collectible": {
		"style_id": STYLE_ID,
		"master_art_direction": MASTER_ART_DIRECTION_ID,
		"filter": true,
		"mipmaps": false,
		"repeat": false,
		"color_space": "srgb_alpha",
		"crop_mode": "contain_baseline",
		"outline_px": Vector2(2.0, 5.0),
		"lighting_id": "greenhouse_upper_left_warm_v1",
	},
	"ui_chrome": {
		"style_id": STYLE_ID,
		"master_art_direction": MASTER_ART_DIRECTION_ID,
		"filter": true,
		"mipmaps": false,
		"repeat": false,
		"color_space": "srgb_alpha",
		"crop_mode": "contain_center",
		"outline_px": Vector2(2.0, 5.0),
		"lighting_id": "ui_neutral_v1",
	},
	"legacy_reference": {
		"style_id": "legacy_reference_only_v1",
		"master_art_direction": "archive_only_no_new_runtime_assets_v1",
		"filter": true,
		"mipmaps": false,
		"repeat": false,
		"color_space": "srgb",
		"crop_mode": "reference_only",
		"outline_px": Vector2.ZERO,
		"lighting_id": "legacy_locked_v1",
	},
}

const PATH_FAMILY_RULES := [
	{"prefix": "res://assets/ui/visual/phase167/", "family": "room_collectible"},
	{"prefix": "res://assets/ui/visual/phase158/", "family": "room_collectible"},
	{"prefix": "res://assets/ui/visual/phase151/", "family": "ui_chrome"},
	{"prefix": "res://assets/ui/visual/phase150/", "family": "environment_plate"},
	{"prefix": "res://assets/ui/visual/phase149/", "family": "room_collectible"},
	{"prefix": "res://assets/ui/visual/phase146/", "family": "room_collectible"},
	{"prefix": "res://assets/ui/visual/phase148/", "family": "room_collectible"},
	{"prefix": "res://assets/ui/visual/phase145/", "family": "room_collectible"},
	{"prefix": "res://assets/ui/visual/phase143/", "family": "room_collectible"},
	{"prefix": "res://assets/ui/visual/phase142/", "family": "room_collectible"},
	{"prefix": "res://assets/ui/visual/phase141/", "family": "room_collectible"},
	{"prefix": "res://assets/ui/visual/phase140/", "family": "room_collectible"},
	{"prefix": "res://assets/ui/visual/phase139/", "family": "room_collectible"},
	{"prefix": "res://assets/ui/visual/phase137/", "family": "room_collectible"},
	{"prefix": "res://assets/ui/visual/phase135/", "family": "room_collectible"},
	{"prefix": "res://assets/ui/visual/phase128/", "family": "environment_plate"},
	{"prefix": "res://assets/ui/visual/phase127/room_decor_sprites/", "family": "room_collectible"},
	{"prefix": "res://assets/ui/visual/phase127/greenhouse_sprites/", "family": "greenhouse_collectible"},
	{"prefix": "res://assets/ui/visual/phase127/", "family": "legacy_reference"},
	{"prefix": "res://assets/backgrounds/", "family": "environment_plate"},
	{"prefix": "res://assets/plants/comic/", "family": "gameplay_plant"},
	{"prefix": "res://assets/plants/", "family": "legacy_reference"},
	{"prefix": "res://assets/ui/player_room/", "family": "environment_plate"},
	{"prefix": "res://assets/ui/greenhouse/", "family": "environment_plate"},
	{"prefix": "res://assets/ui/comic/", "family": "ui_chrome"},
	{"prefix": "res://assets/ui/icons/", "family": "ui_chrome"},
	{"prefix": "res://assets/ui/rack/", "family": "ui_chrome"},
	{"prefix": "res://assets/ui/slots/", "family": "ui_chrome"},
	{"prefix": "res://assets/ui/guide/", "family": "ui_chrome"},
	{"prefix": "res://assets/ui/merchant/", "family": "ui_chrome"},
	{"prefix": "res://assets/ui/garden_workshop/", "family": "ui_chrome"},
	{"prefix": "res://assets/ui/v3/", "family": "ui_chrome"},
	{"prefix": "res://assets/ui/target_b_exact/", "family": "ui_chrome"},
	{"prefix": "res://assets/ui/target_b/", "family": "legacy_reference"},
	{"prefix": "res://assets/ui/", "family": "ui_chrome"},
]

const SCENE_PROFILES := {
	"rack": {
		"id": RACK_PHASE163_SCENE_PROFILE_ID,
		"reference_size": REFERENCE_CONTENT_SIZE,
		"camera_mode": "source_exact_width",
		"title_band": Rect2(0.0, 74.0, 432.0, 70.0),
		"hero_band": Rect2(12.0, 142.0, 408.0, 438.0),
		"lower_band": Rect2(16.0, 590.0, 400.0, 96.0),
		"palette_id": "sunny_botanical",
		"lighting_id": "sunny_upper_left_warm_v1",
		"allowed_families": ["environment_plate", "gameplay_plant", "ui_chrome"],
		"phase151_runtime_set": RACK_PHASE151_RUNTIME_SET_ID,
		"phase163_runtime_set": RACK_PHASE163_RUNTIME_SET_ID,
		"approved_target_asset": RACK_PHASE163_TARGET_ASSET,
		"approved_target_sha256": RACK_PHASE163_TARGET_SHA256,
		"painted_cartoon_style_id": APPROVED_PAINTED_CARTOON_STYLE_ID,
		"painted_cartoon_master": APPROVED_PAINTED_CARTOON_MASTER_ID,
		"migration_status": "dynamic_slots_states_and_approved_locked_planter_phase163_v1",
		"plant_grounding": "shared_saucer_contact_shadow_shelf_baseline_v1",
		"active_plant_grounding": "phase170_measured_ceramic_saucer_fixed_contact_v1",
		"active_stand_layout": "phase171_painted_stand_front_contact_common_fascia_v1",
		"active_environment": "res://assets/ui/visual/phase171/rack/rack_stand_painted_phase171_v1.png",
		"active_dock": RACK_PHASE183_DOCK_RUNTIME_SET_ID,
		"active_dock_background": "res://assets/ui/visual/phase183/rack_dock/rack_floor_extension_phase183_v1.png",
		"locked_slot_policy": "single_approved_compact_planter_master_reused_all_slots_v1",
		"grow_light_policy": "single_approved_brass_fixture_master_reused_all_sockets_v1",
		"style_id": APPROVED_PAINTED_CARTOON_STYLE_ID,
		"master_art_direction": APPROVED_PAINTED_CARTOON_MASTER_ID,
	},
	"plant_detail": {
		"id": PLANT_DETAIL_PHASE151_SCENE_PROFILE_ID,
		"reference_size": REFERENCE_CONTENT_SIZE,
		"camera_mode": "dynamic_hero_contain_baseline",
		"title_band": Rect2(0.0, 0.0, 432.0, 74.0),
		"hero_band": Rect2(0.0, 74.0, 432.0, 445.0),
		"lower_band": Rect2(0.0, 519.0, 432.0, 171.0),
		"palette_id": "sunny_botanical",
		"lighting_id": "sunny_upper_left_warm_v1",
		"allowed_families": ["environment_plate", "gameplay_plant", "ui_chrome"],
		"phase151_runtime_set": RACK_PHASE151_RUNTIME_SET_ID,
		"approved_target_asset": PLANT_DETAIL_PHASE151_TARGET_ASSET,
		"approved_target_sha256": PLANT_DETAIL_PHASE151_TARGET_SHA256,
		"plant_grounding": "painted_saucer_contact_shadow_window_ledge_v1",
		"active_plant_grounding": "phase172_shared_ceramic_measured_window_sill_v1",
		"active_saucer_asset": "res://assets/ui/visual/phase170/rack/rack_ceramic_saucer_phase170_v1.png",
		"painted_cartoon_style_id": APPROVED_PAINTED_CARTOON_STYLE_ID,
		"painted_cartoon_master": APPROVED_PAINTED_CARTOON_MASTER_ID,
		"style_id": APPROVED_PAINTED_CARTOON_STYLE_ID,
		"master_art_direction": APPROVED_PAINTED_CARTOON_MASTER_ID,
	},
	"greenhouse": {
		"id": GREENHOUSE_PHASE150_SCENE_PROFILE_ID,
		"reference_size": REFERENCE_CONTENT_SIZE,
		"camera_mode": "cover_source_anchored",
		"title_band": Rect2(0.0, 74.0, 432.0, 70.0),
		"hero_band": Rect2(12.0, 142.0, 408.0, 438.0),
		"lower_band": Rect2(16.0, 590.0, 400.0, 96.0),
		"palette_id": "sunny_botanical",
		"lighting_id": "greenhouse_upper_left_warm_v1",
		"allowed_families": ["environment_plate", "greenhouse_collectible", "ui_chrome"],
		"phase150_runtime_set": GREENHOUSE_PHASE150_RUNTIME_SET_ID,
		"approved_target_asset": GREENHOUSE_PHASE150_TARGET_ASSET,
		"approved_target_sha256": GREENHOUSE_PHASE150_TARGET_SHA256,
		"canonical_content_asset": GREENHOUSE_PHASE150_CANONICAL_CONTENT_ASSET,
		"canonical_content_sha256": GREENHOUSE_PHASE150_CANONICAL_CONTENT_SHA256,
		"target_style_id": APPROVED_PAINTED_CARTOON_STYLE_ID,
		"target_master_art_direction": APPROVED_PAINTED_CARTOON_MASTER_ID,
		"painted_cartoon_style_id": APPROVED_PAINTED_CARTOON_STYLE_ID,
		"painted_cartoon_master": APPROVED_PAINTED_CARTOON_MASTER_ID,
		"style_id": STYLE_ID,
		"master_art_direction": MASTER_ART_DIRECTION_ID,
		"runtime_style_id": STYLE_ID,
		"runtime_master_art_direction": MASTER_ART_DIRECTION_ID,
		"migration_status": "dynamic_phase130_environment_phase150_alpha_only_crops_v1",
		"crop_layer_policy": "phase150_alpha_only_soil_cleanup_source_rgb_immutable_v1",
		"interaction_layer_policy": "four_functional_bays_two_visual_boxes_preserved_v1",
	},
	"player_room": {
		"id": PLAYER_ROOM_SCENE_PROFILE_ID,
		"reference_size": REFERENCE_CONTENT_SIZE,
		"camera_mode": "exact_target_native_crop",
		"title_band": Rect2(0.0, 74.0, 432.0, 70.0),
		"hero_band": Rect2(12.0, 142.0, 408.0, 438.0),
		"lower_band": Rect2(16.0, 590.0, 400.0, 96.0),
		"palette_id": "sunny_botanical",
		"lighting_id": "sunny_upper_left_warm_v1",
		"allowed_families": ["environment_plate", "room_collectible", "ui_chrome"],
		"detail_layer_set": PLAYER_ROOM_LAYERED_DETAILS_ID,
		"approved_master_set": PLAYER_ROOM_APPROVED_MASTER_ID,
		"painted_cartoon_set": PLAYER_ROOM_PAINTED_CARTOON_SET_ID,
		"exact_target_set": PLAYER_ROOM_EXACT_TARGET_SET_ID,
		"exact_target_asset": PLAYER_ROOM_EXACT_TARGET_ASSET,
		"exact_target_sha256": PLAYER_ROOM_EXACT_TARGET_SHA256,
		"painted_cartoon_style_id": APPROVED_PAINTED_CARTOON_STYLE_ID,
		"painted_cartoon_master": APPROVED_PAINTED_CARTOON_MASTER_ID,
		"painted_cartoon_migration": "complete_environment_plants_and_decor_preserved_ui_chrome_v1",
		"interaction_layer_policy": "phase149_target_clean_plate_twenty_slots_twenty_one_rgba_layers_transparent_hitboxes_v1",
		"style_id": APPROVED_PAINTED_CARTOON_STYLE_ID,
		"master_art_direction": APPROVED_PAINTED_CARTOON_MASTER_ID,
	},
	"storage": {
		"id": STORAGE_PHASE152_SCENE_PROFILE_ID,
		"reference_size": REFERENCE_CONTENT_SIZE,
		"camera_mode": "phase152_top_workshop_crop_with_dynamic_panels",
		"title_band": Rect2(16.0, 16.0, 400.0, 82.0),
		"hero_band": Rect2(10.0, 8.0, 412.0, 410.0),
		"lower_band": Rect2(10.0, 426.0, 412.0, 348.0),
		"palette_id": "sunny_botanical",
		"lighting_id": "sunny_upper_left_warm_v1",
		"allowed_families": ["environment_plate", "ui_chrome"],
		"phase152_runtime_set": STORAGE_PHASE152_RUNTIME_SET_ID,
		"approved_target_asset": STORAGE_PHASE152_TARGET_ASSET,
		"approved_target_sha256": STORAGE_PHASE152_TARGET_SHA256,
		"painted_cartoon_style_id": APPROVED_PAINTED_CARTOON_STYLE_ID,
		"painted_cartoon_master": APPROVED_PAINTED_CARTOON_MASTER_ID,
		"style_id": APPROVED_PAINTED_CARTOON_STYLE_ID,
		"master_art_direction": APPROVED_PAINTED_CARTOON_MASTER_ID,
		"interaction_policy": "dynamic_inventory_pipeline_and_scroll_preserved_v1",
	},
	"shop": {
		"id": SHOP_PHASE153_SCENE_PROFILE_ID,
		"reference_size": REFERENCE_CONTENT_SIZE,
		"camera_mode": "phase153_integrated_merchant_counter_dynamic_catalog_v1",
		"title_band": Rect2(18.0, 14.0, 184.0, 76.0),
		"hero_band": Rect2(8.0, 6.0, 416.0, 245.0),
		"lower_band": Rect2(8.0, 258.0, 416.0, 514.0),
		"palette_id": "sunny_botanical",
		"lighting_id": "sunny_upper_left_warm_v1",
		"allowed_families": ["environment_plate", "ui_chrome", "gameplay_plant"],
		"phase153_runtime_set": SHOP_PHASE153_RUNTIME_SET_ID,
		"approved_target_asset": SHOP_PHASE153_TARGET_ASSET,
		"approved_target_sha256": SHOP_PHASE153_TARGET_SHA256,
		"painted_cartoon_style_id": APPROVED_PAINTED_CARTOON_STYLE_ID,
		"painted_cartoon_master": APPROVED_PAINTED_CARTOON_MASTER_ID,
		"style_id": APPROVED_PAINTED_CARTOON_STYLE_ID,
		"master_art_direction": APPROVED_PAINTED_CARTOON_MASTER_ID,
		"interaction_policy": "dynamic_wallet_catalog_stock_categories_buy_sell_equipment_and_scroll_preserved_v1",
	},
	"measurement": {
		"id": MEASUREMENT_PHASE154_SCENE_PROFILE_ID,
		"reference_size": REFERENCE_CONTENT_SIZE,
		"camera_mode": "phase154_integrated_botanical_lab_dynamic_metrics_v1",
		"title_band": Rect2(16.0, 12.0, 400.0, 76.0),
		"hero_band": Rect2(10.0, 8.0, 412.0, 248.0),
		"lower_band": Rect2(10.0, 266.0, 412.0, 414.0),
		"palette_id": "sunny_botanical",
		"lighting_id": "sunny_upper_left_warm_v1",
		"allowed_families": ["environment_plate", "ui_chrome"],
		"phase154_runtime_set": MEASUREMENT_PHASE154_RUNTIME_SET_ID,
		"approved_target_asset": MEASUREMENT_PHASE154_TARGET_ASSET,
		"approved_target_sha256": MEASUREMENT_PHASE154_TARGET_SHA256,
		"painted_cartoon_style_id": APPROVED_PAINTED_CARTOON_STYLE_ID,
		"painted_cartoon_master": APPROVED_PAINTED_CARTOON_MASTER_ID,
		"style_id": APPROVED_PAINTED_CARTOON_STYLE_ID,
		"master_art_direction": APPROVED_PAINTED_CARTOON_MASTER_ID,
		"interaction_policy": "dynamic_live_sensor_values_graph_knowledge_and_scroll_preserved_v1",
	},
	"herbarium": {
		"id": HERBARIUM_PHASE155_SCENE_PROFILE_ID,
		"reference_size": REFERENCE_VIEWPORT,
		"camera_mode": "phase155_fullscreen_painted_herbarium_dynamic_scroll_v1",
		"title_band": Rect2(78.0, 28.0, 278.0, 104.0),
		"hero_band": Rect2(50.0, 138.0, 334.0, 118.0),
		"lower_band": Rect2(50.0, 258.0, 334.0, 686.0),
		"summary_band": Rect2(58.0, 146.0, 316.0, 72.0),
		"scroll_band": Rect2(50.0, 258.0, 334.0, 558.0),
		"action_band": Rect2(76.0, 866.0, 280.0, 78.0),
		"palette_id": "sunny_botanical",
		"lighting_id": "sunny_upper_left_warm_v1",
		"allowed_families": ["environment_plate", "ui_chrome", "gameplay_plant"],
		"phase155_runtime_set": HERBARIUM_PHASE155_RUNTIME_SET_ID,
		"approved_target_asset": HERBARIUM_PHASE155_TARGET_ASSET,
		"approved_target_sha256": HERBARIUM_PHASE155_TARGET_SHA256,
		"clean_backdrop_asset": HERBARIUM_PHASE155_BACKDROP_ASSET,
		"clean_backdrop_sha256": HERBARIUM_PHASE155_BACKDROP_SHA256,
		"painted_cartoon_style_id": APPROVED_PAINTED_CARTOON_STYLE_ID,
		"painted_cartoon_master": APPROVED_PAINTED_CARTOON_MASTER_ID,
		"style_id": APPROVED_PAINTED_CARTOON_STYLE_ID,
		"master_art_direction": APPROVED_PAINTED_CARTOON_MASTER_ID,
		"interaction_policy": "dynamic_eleven_species_mastery_rewards_descriptions_progress_and_mobile_scroll_v1",
	},
	"daily_challenge": {
		"id": DAILY_CHALLENGE_PHASE161_SCENE_PROFILE_ID,
		"reference_size": REFERENCE_VIEWPORT,
		"camera_mode": "phase161_compact_fullscreen_modal_live_hud_and_navigation_scrim_v1",
		"plate_band": Rect2(10.0, 78.0, 412.0, 808.0),
		"title_band": Rect2(44.0, 124.0, 344.0, 64.0),
		"weather_band": Rect2(42.0, 198.0, 348.0, 42.0),
		"challenge_title_band": Rect2(48.0, 243.0, 336.0, 44.0),
		"challenge_body_band": Rect2(48.0, 285.0, 336.0, 58.0),
		"status_band": Rect2(48.0, 334.0, 336.0, 32.0),
		"hero_band": Rect2(58.0, 342.0, 316.0, 212.0),
		"lower_band": Rect2(42.0, 564.0, 348.0, 310.0),
		"action_band": Rect2(42.0, 564.0, 348.0, 64.0),
		"reward_band": Rect2(42.0, 625.0, 348.0, 68.0),
		"packs_band": Rect2(42.0, 688.0, 348.0, 64.0),
		"warning_band": Rect2(44.0, 753.0, 344.0, 52.0),
		"close_band": Rect2(42.0, 810.0, 348.0, 64.0),
		"palette_id": "sunny_botanical",
		"lighting_id": "sunny_upper_left_warm_v1",
		"allowed_families": ["environment_plate", "ui_chrome", "gameplay_plant"],
		"phase161_runtime_set": DAILY_CHALLENGE_PHASE161_RUNTIME_SET_ID,
		"approved_target_asset": DAILY_CHALLENGE_PHASE161_TARGET_ASSET,
		"approved_target_sha256": DAILY_CHALLENGE_PHASE161_TARGET_SHA256,
		"clean_backdrop_asset": DAILY_CHALLENGE_PHASE161_BACKDROP_ASSET,
		"clean_backdrop_sha256": DAILY_CHALLENGE_PHASE161_BACKDROP_SHA256,
		"painted_cartoon_style_id": APPROVED_PAINTED_CARTOON_STYLE_ID,
		"painted_cartoon_master": APPROVED_PAINTED_CARTOON_MASTER_ID,
		"style_id": APPROVED_PAINTED_CARTOON_STYLE_ID,
		"master_art_direction": APPROVED_PAINTED_CARTOON_MASTER_ID,
		"interaction_policy": "dynamic_fourteen_challenges_weather_target_status_actions_rewards_pack_count_and_modal_exclusivity_v1",
	},
	"cosmetic_showroom": {
		"id": COSMETIC_SHOWROOM_PHASE162_SCENE_PROFILE_ID,
		"reference_size": REFERENCE_VIEWPORT,
		"camera_mode": "phase162_compact_fullscreen_catalog_live_room_scrim_v1",
		"plate_band": Rect2(5.0, 38.0, 422.0, 878.0),
		"title_band": Rect2(50.0, 64.0, 332.0, 82.0),
		"hero_band": Rect2(42.0, 185.0, 348.0, 648.0),
		"lower_band": Rect2(72.0, 836.0, 288.0, 86.0),
		"palette_id": "sunny_botanical",
		"lighting_id": "sunny_upper_left_warm_v1",
		"allowed_families": ["environment_plate", "ui_chrome"],
		"phase162_runtime_set": COSMETIC_SHOWROOM_PHASE162_RUNTIME_SET_ID,
		"approved_target_asset": COSMETIC_SHOWROOM_PHASE162_TARGET_ASSET,
		"approved_target_sha256": COSMETIC_SHOWROOM_PHASE162_TARGET_SHA256,
		"clean_backdrop_asset": COSMETIC_SHOWROOM_PHASE162_BACKDROP_ASSET,
		"clean_backdrop_sha256": COSMETIC_SHOWROOM_PHASE162_BACKDROP_SHA256,
		"painted_cartoon_style_id": APPROVED_PAINTED_CARTOON_STYLE_ID,
		"painted_cartoon_master": APPROVED_PAINTED_CARTOON_MASTER_ID,
		"style_id": APPROVED_PAINTED_CARTOON_STYLE_ID,
		"master_art_direction": APPROVED_PAINTED_CARTOON_MASTER_ID,
		"interaction_policy": "dynamic_four_theme_wallet_selection_purchase_research_lock_and_modal_exclusivity_v1",
	},
}

const DECORATION_ASSET_IDS := {
	"room_orchid": "room_orchid",
	"botanical_books": "room_books",
	"mini_monstera": "room_broad_leaf",
	"snake_plant": "room_tall_leaf",
	"golden_lamp": "room_botanical_cloche",
	"room_fern": "room_fern",
	"flowering_begonia": "room_flowering",
	"round_leaf_pilea": "room_round_leaf",
	"striped_calathea": "room_striped_leaf",
	"climbing_pothos": "room_climbing_vine",
	"silver_aglaonema": "room_aglaonema",
	"pink_fittonia": "room_fittonia",
	"lemon_maranta": "room_lemon_maranta",
	"colorful_coleus": "room_coleus",
	"fertilizer_collection": "room_fertilizer",
	"nested_pots": "room_nested_pots",
	"botanical_print": "room_botanical_art",
	"plastic_watering_can": "room_watering_can",
	"preserved_herb_jars": "room_herb_jars",
	"cat_corner": "room_cat_corner",
}

const GREENHOUSE_CROP_ASSET_IDS := {
	"cherry_tomato": "greenhouse_phase150_crop_tomato",
	"sweet_pepper": "greenhouse_phase150_crop_pepper",
	"garden_radish": "greenhouse_phase150_crop_radish",
	"salad_cucumber": "greenhouse_phase150_crop_cucumber",
	"garden_eggplant": "greenhouse_phase150_crop_eggplant",
}

static var ASSET_PROFILES := {
	"rack_ceramic_saucer_phase170": _rack_phase170_saucer_profile(),
	"rack_background": _profile("environment_plate", "res://assets/backgrounds/comic_room_rack_v1.png", Vector2(432.0, 780.0), Vector2(0.5, 0.5), 0),
	"rack_phase151_locked_cylinder": _rack_phase151_asset_profile("res://assets/ui/visual/phase151/rack/rack_locked_cylinder_phase151_v1.png", Vector2(55.0, 95.0), Vector2(0.5, 1.0), "locked_cylinder"),
	"rack_stand_phase171": _rack_phase171_stand_profile(),
	"rack_phase183_dock_background": _rack_phase183_dock_profile("res://assets/ui/visual/phase183/rack_dock/rack_floor_extension_phase183_v1.png", "environment_plate", Vector2(432.0, 90.0), "painted_floor_extension", 0),
	"rack_phase183_pet_icon": _rack_phase183_dock_profile("res://assets/ui/visual/phase183/rack_dock/pet_paw_phase183_v1.png", "ui_chrome", Vector2(48.0, 48.0), "pet_and_addons_launcher", 60),
	"rack_phase183_professor_icon": _rack_phase183_dock_profile("res://assets/ui/visual/phase183/rack_dock/professor_bazal_phase183_v1.png", "ui_chrome", Vector2(48.0, 48.0), "professor_research_launcher", 60),
	"rack_phase183_care_icon": _rack_phase183_dock_profile("res://assets/ui/visual/phase183/rack_dock/care_leaf_phase183_v1.png", "ui_chrome", Vector2(48.0, 48.0), "care_center_launcher", 60),
	"rack_phase183_settings_icon": _rack_phase183_dock_profile("res://assets/ui/icons/settings_gear_phase125.png", "ui_chrome", Vector2(48.0, 48.0), "player_settings_launcher", 60),
	"rack_phase163_locked_planter": _rack_phase163_asset_profile(RACK_PHASE163_LOCKED_PLANTER_ASSET, Vector2(63.0, 77.0), Vector2(0.5, 1.0), "locked_planter"),
	"rack_phase163_grow_light": _rack_phase163_asset_profile(RACK_PHASE163_GROW_LIGHT_ASSET, Vector2(49.0, 22.0), Vector2(0.5, 0.5), "grow_light_fixture"),
	"greenhouse_background": _profile("environment_plate", "res://assets/ui/greenhouse/greenhouse_interior_phase130_two_boxes_v1.png", Vector2(432.0, 780.0), Vector2(0.5, 0.5), 0),
	"greenhouse_phase150_canonical_content_reference": _greenhouse_phase150_reference_profile(GREENHOUSE_PHASE150_CANONICAL_CONTENT_ASSET),
	"player_room_background": _phase149_environment_profile("res://assets/ui/player_room/player_room_phase149_target_clean_v1.png"),
	"player_room_canonical_full": _phase149_environment_profile("res://assets/ui/player_room/player_room_phase149_target_full_v1.png", 40),
	"player_room_foreground_occlusion": _phase149_environment_profile("res://assets/ui/visual/phase158/player_room/player_room_furniture_foreground_phase158_v2.png", 60),
	"player_room_approved_full_master": _profile("environment_plate", "res://assets/ui/player_room/player_room_interior_phase146_approved_full_v1.png", Vector2(432.0, 780.0), Vector2(0.5, 0.5), 20),
	"player_room_fixed_decor_layer": _profile("room_collectible", "res://assets/ui/visual/phase146/player_room_fixed_decor_layer_v3.png", Vector2(432.0, 780.0), Vector2(0.5, 0.5), 40),
	"storage_workshop_background": _profile("environment_plate", "res://assets/ui/visual/phase128/storage_workshop_backdrop_v2.png", Vector2(432.0, 780.0), Vector2(0.5, 0.5), 0),
	"measurement_corner_background": _measurement_phase154_environment_profile("res://assets/ui/visual/phase128/measurement_corner_backdrop_v1.png"),
	"shop_merchant_background": _shop_phase153_environment_profile("res://assets/ui/merchant/botanist_shop_counter_v2.png"),
	"herbarium_phase155_background": _herbarium_phase155_environment_profile(HERBARIUM_PHASE155_BACKDROP_ASSET),
	"daily_challenge_phase161_background": _daily_challenge_phase161_environment_profile(DAILY_CHALLENGE_PHASE161_BACKDROP_ASSET),
	"cosmetic_showroom_phase162_background": _cosmetic_showroom_phase162_environment_profile(COSMETIC_SHOWROOM_PHASE162_BACKDROP_ASSET),
	# Legacy target rectangles remain archival metadata. The live rack uses actual
	# ceramic landmarks and continuous UV geometry, never these unrelated crops.
	"room_orchid": _room_rack_phase167_profile("room_orchid", "orchid", Rect2(80.0, 499.0, 127.0, 310.0), Vector2(130.0, 811.0)),
	"room_fern": _room_rack_phase167_profile("room_fern", "fern", Rect2(58.0, 826.0, 158.0, 208.0), Vector2(130.0, 1046.0)),
	"room_broad_leaf": _room_rack_phase167_profile("room_broad_leaf", "glossy_broadleaf", Rect2(197.0, 582.0, 145.0, 228.0), Vector2(274.0, 811.0)),
	"room_striped_leaf": _room_rack_phase167_profile("room_striped_leaf", "striped_calathea", Rect2(58.0, 1072.0, 156.0, 214.0), Vector2(130.0, 1286.0)),
	"room_tall_leaf": _room_rack_phase167_profile("room_tall_leaf", "snake_plant", Rect2(330.0, 542.0, 139.0, 267.0), Vector2(416.0, 811.0)),
	"room_flowering": _room_rack_phase167_profile("room_flowering", "flowering_begonia", Rect2(199.0, 826.0, 158.0, 208.0), Vector2(274.0, 1046.0)),
	"room_round_leaf": _room_rack_phase167_profile("room_round_leaf", "roundleaf_pilea", Rect2(339.0, 829.0, 136.0, 205.0), Vector2(416.0, 1046.0)),
	"room_climbing_vine": _room_rack_phase167_profile("room_climbing_vine", "pothos", Rect2(199.0, 1308.0, 157.0, 199.0), Vector2(274.0, 1507.0)),
	"room_aglaonema": _room_rack_phase167_profile("room_aglaonema", "compact_aglaonema", Rect2(341.0, 1082.0, 134.0, 204.0), Vector2(414.0, 1286.0)),
	"room_fittonia": _room_rack_phase167_profile("room_fittonia", "fittonia", Rect2(63.0, 1315.0, 149.0, 193.0), Vector2(130.0, 1507.0)),
	"room_lemon_maranta": _room_rack_phase167_profile("room_lemon_maranta", "lemon_maranta", Rect2(199.0, 1087.0, 155.0, 199.0), Vector2(274.0, 1286.0)),
	"room_coleus": _room_rack_phase167_profile("room_coleus", "coleus", Rect2(339.0, 1308.0, 138.0, 199.0), Vector2(414.0, 1507.0)),
	"room_plant_saucer": _profile("room_collectible", "res://assets/ui/visual/phase133/room_plant_saucer_v1.png", Vector2(50.0, 18.0), Vector2(0.5, 0.58), 35),
	"room_books": _room_target_phase149_profile("res://assets/ui/visual/phase148/player_room/decor/room_decor_books_phase148.png", Rect2(512.0, 282.0, 145.0, 129.0), Vector2(584.0, 412.0), "wall_shelf_clean_dynamic_v3"),
	"room_fertilizer": _room_target_phase149_profile("res://assets/ui/visual/phase148/player_room/decor/room_decor_fertilizer_bags_phase148.png", Rect2(512.0, 474.0, 172.0, 133.0), Vector2(598.0, 608.0), "wall_shelf_clean_dynamic_v3"),
	"room_nested_pots": _room_target_phase149_profile("res://assets/ui/visual/phase148/player_room/decor/room_decor_nested_pots_phase148.png", Rect2(678.0, 1052.0, 122.0, 158.0), Vector2(739.0, 1212.0), "cabinet_shelf_clean_dynamic_v3"),
	"room_lamp": _room_target_phase149_profile("res://assets/ui/visual/phase148/player_room/decor/room_decor_table_lamp_phase148.png", Rect2(550.0, 1044.0, 99.0, 164.0), Vector2(600.0, 1210.0), "cabinet_shelf_clean_dynamic_v3"),
	"room_botanical_cloche": _room_botanical_cloche_phase159_profile("res://assets/ui/visual/phase159/player_room/decor/botanical_cloche_phase159_v1.png"),
	"room_botanical_art": _room_target_phase149_profile("res://assets/ui/visual/phase148/player_room/decor/room_decor_botanical_print_phase148.png", Rect2(709.0, 472.0, 118.0, 136.0), Vector2(768.0, 608.0), "wall_shelf_clean_dynamic_v3"),
	"room_watering_can": _room_target_phase149_profile("res://assets/ui/visual/phase148/player_room/decor/room_decor_watering_can_phase148.png", Rect2(520.0, 1360.0, 140.0, 150.0), Vector2(590.0, 1511.0), "floor_clean_dynamic_v3"),
	"room_herb_jars": _room_target_phase149_profile("res://assets/ui/visual/phase148/player_room/decor/room_decor_herb_jars_phase148.png", Rect2(670.0, 298.0, 159.0, 113.0), Vector2(750.0, 412.0), "wall_shelf_clean_dynamic_v3"),
	"room_cat_corner": _room_target_phase149_profile("res://assets/ui/visual/phase148/player_room/decor/room_decor_cat_bed_phase148.png", Rect2(638.0, 1355.0, 200.0, 155.0), Vector2(736.0, 1511.0), "floor_clean_dynamic_v3"),
	"room_pet_bowls": _room_target_phase149_profile("res://assets/ui/visual/phase148/player_room/decor/room_decor_paired_bowls_phase148.png", Rect2(574.0, 1505.0, 205.0, 105.0), Vector2(681.0, 1610.0), "floor_clean_dynamic_v3"),
	"room_achievement_holder": _room_decor_phase140_profile("res://assets/ui/visual/phase140/room_achievement_holder_phase140_v1.png", Vector2(46.0, 31.0), Vector2(0.5, 0.95)),
	"room_secondary_wall_shelf": _room_decor_phase140_profile("res://assets/ui/visual/phase140/room_secondary_wall_shelf_phase140_v1.png", Vector2(164.0, 55.0), Vector2(0.5, 0.18)),
	"greenhouse_bed_empty": _profile("greenhouse_collectible", "res://assets/ui/visual/phase127/greenhouse_sprites/greenhouse_bed_empty_v1.png", Vector2(178.0, 126.0), Vector2(0.5, 0.92), 20),
	"greenhouse_bed_watered": _profile("greenhouse_collectible", "res://assets/ui/visual/phase127/greenhouse_sprites/greenhouse_bed_watered_v1.png", Vector2(178.0, 126.0), Vector2(0.5, 0.92), 20),
	"greenhouse_bed_locked": _profile("greenhouse_collectible", "res://assets/ui/visual/phase127/greenhouse_sprites/greenhouse_bed_locked_v1.png", Vector2(178.0, 126.0), Vector2(0.5, 0.92), 20),
	"greenhouse_bed_selected": _profile("greenhouse_collectible", "res://assets/ui/visual/phase127/greenhouse_sprites/greenhouse_bed_selected_v1.png", Vector2(178.0, 126.0), Vector2(0.5, 0.92), 20),
	"greenhouse_crop_seedlings": _profile("greenhouse_collectible", "res://assets/ui/visual/phase127/greenhouse_sprites/greenhouse_crop_seedlings_v1.png", Vector2(118.0, 72.0), Vector2(0.5, 0.94), 40),
	"greenhouse_crop_tomato": _profile("greenhouse_collectible", "res://assets/ui/visual/phase127/greenhouse_sprites/greenhouse_crop_tomato_v1.png", Vector2(126.0, 88.0), Vector2(0.5, 0.94), 40),
	"greenhouse_crop_pepper": _profile("greenhouse_collectible", "res://assets/ui/visual/phase127/greenhouse_sprites/greenhouse_crop_pepper_v1.png", Vector2(126.0, 88.0), Vector2(0.5, 0.94), 40),
	"greenhouse_crop_radish": _profile("greenhouse_collectible", "res://assets/ui/visual/phase127/greenhouse_sprites/greenhouse_crop_radish_v1.png", Vector2(126.0, 78.0), Vector2(0.5, 0.94), 40),
	"greenhouse_crop_cucumber": _profile("greenhouse_collectible", "res://assets/ui/visual/phase127/greenhouse_sprites/greenhouse_crop_cucumber_v1.png", Vector2(126.0, 90.0), Vector2(0.5, 0.94), 40),
	"greenhouse_crop_eggplant": _profile("greenhouse_collectible", "res://assets/ui/visual/phase127/greenhouse_sprites/greenhouse_crop_eggplant_v1.png", Vector2(126.0, 90.0), Vector2(0.5, 0.94), 40),
	# Phase 150 keeps every source RGB pixel byte-for-byte unchanged and derives
	# only a tighter alpha channel from the immutable Phase 127 paintings. This
	# removes the detached soil mounds while retaining the authored plant, stakes,
	# fruit and leaf painting. Historical profiles above remain available for
	# regression coverage and archive captures.
	"greenhouse_phase150_crop_seedlings": _greenhouse_phase150_crop_profile("res://assets/ui/visual/phase150/greenhouse/crops/greenhouse_crop_seedlings_phase150_v1.png", Vector2(118.0, 72.0), Rect2(0.0, 0.0, 1.0, 1.0), "seedlings"),
	"greenhouse_phase150_crop_tomato": _greenhouse_phase150_crop_profile("res://assets/ui/visual/phase150/greenhouse/crops/greenhouse_crop_tomato_phase150_v1.png", Vector2(166.0, 126.0), Rect2(0.0, 0.0, 1.0, 1.0), "cherry_tomato"),
	"greenhouse_phase150_crop_pepper": _greenhouse_phase150_crop_profile("res://assets/ui/visual/phase150/greenhouse/crops/greenhouse_crop_pepper_phase150_v1.png", Vector2(166.0, 126.0), Rect2(0.0, 0.0, 1.0, 1.0), "sweet_pepper"),
	"greenhouse_phase150_crop_radish": _greenhouse_phase150_crop_profile("res://assets/ui/visual/phase150/greenhouse/crops/greenhouse_crop_radish_phase150_v1.png", Vector2(166.0, 118.0), Rect2(0.0, 0.0, 1.0, 1.0), "garden_radish"),
	"greenhouse_phase150_crop_cucumber": _greenhouse_phase150_crop_profile("res://assets/ui/visual/phase150/greenhouse/crops/greenhouse_crop_cucumber_phase150_v1.png", Vector2(172.0, 130.0), Rect2(0.0, 0.0, 1.0, 1.0), "salad_cucumber"),
	"greenhouse_phase150_crop_eggplant": _greenhouse_phase150_crop_profile("res://assets/ui/visual/phase150/greenhouse/crops/greenhouse_crop_eggplant_phase150_v1.png", Vector2(180.0, 126.0), Rect2(0.0, 0.0, 1.0, 1.0), "garden_eggplant"),
	"greenhouse_status_water": _profile("greenhouse_collectible", "res://assets/ui/visual/phase127/greenhouse_sprites/greenhouse_status_water_v1.png", Vector2(24.0, 26.0), Vector2(0.5, 0.5), 50),
	"greenhouse_status_ready": _profile("greenhouse_collectible", "res://assets/ui/visual/phase127/greenhouse_sprites/greenhouse_status_ready_v1.png", Vector2(26.0, 30.0), Vector2(0.5, 0.5), 50),
	"greenhouse_status_plaque": _profile("greenhouse_collectible", "res://assets/ui/visual/phase127/greenhouse_sprites/greenhouse_status_plaque_v1.png", Vector2(118.0, 31.0), Vector2(0.5, 0.5), 50),
}

static var _texture_cache: Dictionary = {}


static func _profile(family: String, texture_path: String, design_size: Vector2, pivot: Vector2, z_layer: int) -> Dictionary:
	return {
		"family": family,
		"texture": texture_path,
		"design_size": design_size,
		"pivot": pivot,
		"z_layer": z_layer,
		"scale_range": Vector2(0.72, 1.28),
	}


static func _profile_region(family: String, texture_path: String, design_size: Vector2, pivot: Vector2, z_layer: int, source_uv: Rect2) -> Dictionary:
	var result := _profile(family, texture_path, design_size, pivot, z_layer)
	result["source_uv"] = source_uv
	return result


static func _greenhouse_phase150_crop_profile(texture_path: String, design_size: Vector2, source_uv: Rect2, crop_role: String) -> Dictionary:
	var result := _profile_region("greenhouse_collectible", texture_path, design_size, Vector2(0.5, 1.0), 40, source_uv)
	result["style_id"] = APPROVED_PAINTED_CARTOON_STYLE_ID
	result["master_art_direction"] = APPROVED_PAINTED_CARTOON_MASTER_ID
	result["phase150_runtime_set"] = GREENHOUSE_PHASE150_RUNTIME_SET_ID
	result["crop_role"] = crop_role
	result["source_pixel_policy"] = "phase127_source_rgb_byte_exact_phase150_alpha_only_cleanup_v1"
	result["crop_policy"] = "remove_detached_soil_mound_preserve_painted_plant_v1"
	result["grounding"] = "shared_authored_bay_soil_baseline_v1"
	result["compact_policy"] = "fit_and_clamp_inside_functional_bay_v1"
	result["rendering"] = "smooth_derived_rgba_linear_mipmaps_no_checkerboard_no_halo_v1"
	result["texture_filter"] = "linear_with_mipmaps_v1"
	result["mipmaps"] = true
	result["embedded_contact_shadow"] = false
	match crop_role:
		"seedlings":
			result["approved_reference_occupancy"] = Vector2(0.730, 0.581)
			result["approved_reference_composition"] = "three_columns_from_two_vertical_pairs_v1"
		"cherry_tomato":
			result["approved_reference_occupancy"] = Vector2(0.790, 0.745)
		"garden_eggplant":
			result["approved_reference_occupancy"] = Vector2(0.860, 0.724)
	result["scale_range"] = Vector2(0.72, 1.28)
	return result


static func _rack_phase171_stand_profile() -> Dictionary:
	var result := _profile("environment_plate", "res://assets/ui/visual/phase171/rack/rack_stand_painted_phase171_v1.png", Vector2(432.0, 691.6), Vector2.ZERO, 0)
	result["style_id"] = APPROVED_PAINTED_CARTOON_STYLE_ID
	result["master_art_direction"] = APPROVED_PAINTED_CARTOON_MASTER_ID
	result["source_pixel_policy"] = "phase171_generated_painting_unchanged_contiguous_construction_bands_v1"
	result["geometry_contract"] = "phase171_painted_stand_front_contact_common_fascia_v1"
	result["texture_filter"] = "linear_with_mipmaps_v1"
	result["mipmaps"] = true
	result["lighting_id"] = "sunny_upper_left_warm_v1"
	return result


static func _rack_phase183_dock_profile(texture_path: String, family: String, design_size: Vector2, layer_role: String, z_layer: int) -> Dictionary:
	var result := _profile(family, texture_path, design_size, Vector2(0.5, 0.5), z_layer)
	result["style_id"] = APPROVED_PAINTED_CARTOON_STYLE_ID
	result["master_art_direction"] = APPROVED_PAINTED_CARTOON_MASTER_ID
	result["phase183_runtime_set"] = RACK_PHASE183_DOCK_RUNTIME_SET_ID
	result["source_pixel_policy"] = "phase183_versioned_imagegen_source_unchanged_v1"
	result["layer_role"] = layer_role
	result["rendering"] = "vivid_hand_painted_linear_mipmaps_no_checkerboard_no_halo_v1"
	result["texture_filter"] = "linear_with_mipmaps_v1"
	result["mipmaps"] = true
	result["lighting_id"] = "sunny_upper_left_warm_v1"
	result["geometry_contract"] = "phase183_centered_four_by_68_icon_dock_v1"
	return result


static func _rack_phase170_saucer_profile() -> Dictionary:
	var result := _profile("ui_chrome", "res://assets/ui/visual/phase170/rack/rack_ceramic_saucer_phase170_v1.png", Vector2(48.0, 48.0 * 528.0 / 2062.0), Vector2(0.5, 1.0), 38)
	result["style_id"] = APPROVED_PAINTED_CARTOON_STYLE_ID
	result["master_art_direction"] = APPROVED_PAINTED_CARTOON_MASTER_ID
	result["source_pixel_policy"] = "phase170_generated_rgba_source_unchanged_runtime_roi_v1"
	result["layer_role"] = "rack_saucer"
	result["source_rect"] = Rect2(56.0, 98.0, 2062.0, 528.0)
	result["texture_filter"] = "linear_with_mipmaps_v1"
	result["mipmaps"] = true
	result["embedded_contact_shadow"] = false
	result["lighting_id"] = "sunny_upper_left_warm_v1"
	result["geometry_contract"] = "phase170_measured_ceramic_saucer_fixed_contact_v1"
	return result


static func _rack_phase151_asset_profile(texture_path: String, design_size: Vector2, pivot: Vector2, layer_role: String) -> Dictionary:
	var result := _profile("ui_chrome", texture_path, design_size, pivot, 40)
	result["style_id"] = APPROVED_PAINTED_CARTOON_STYLE_ID
	result["master_art_direction"] = APPROVED_PAINTED_CARTOON_MASTER_ID
	result["phase151_runtime_set"] = RACK_PHASE151_RUNTIME_SET_ID
	result["source_pixel_policy"] = "phase151_generated_rgba_immutable_v1"
	result["layer_role"] = layer_role
	result["rendering"] = "vivid_hand_painted_rgba_linear_mipmaps_no_checkerboard_no_halo_v1"
	result["texture_filter"] = "linear_with_mipmaps_v1"
	result["mipmaps"] = true
	result["embedded_contact_shadow"] = true
	return result


static func _rack_phase163_asset_profile(texture_path: String, design_size: Vector2, pivot: Vector2, layer_role: String) -> Dictionary:
	var result := _profile("ui_chrome", texture_path, design_size, pivot, 42)
	result["style_id"] = APPROVED_PAINTED_CARTOON_STYLE_ID
	result["master_art_direction"] = APPROVED_PAINTED_CARTOON_MASTER_ID
	result["phase163_runtime_set"] = RACK_PHASE163_RUNTIME_SET_ID
	result["approved_reference"] = RACK_PHASE163_TARGET_ASSET
	result["source_pixel_policy"] = "phase163_approved_reference_rgb_preserved_alpha_only_v1"
	result["layer_role"] = layer_role
	result["rendering"] = "vivid_hand_painted_rgba_linear_mipmaps_single_master_reuse_v1"
	result["texture_filter"] = "linear_with_mipmaps_v1"
	result["mipmaps"] = true
	result["embedded_contact_shadow"] = layer_role == "locked_planter"
	return result


static func _shop_phase153_environment_profile(texture_path: String) -> Dictionary:
	var result := _profile("environment_plate", texture_path, Vector2(416.0, 245.0), Vector2(0.5, 0.5), 0)
	result["style_id"] = APPROVED_PAINTED_CARTOON_STYLE_ID
	result["master_art_direction"] = APPROVED_PAINTED_CARTOON_MASTER_ID
	result["phase153_runtime_set"] = SHOP_PHASE153_RUNTIME_SET_ID
	result["source_pixel_policy"] = "existing_painted_merchant_png_byte_exact_import_sidecar_only_v1"
	result["rendering"] = "vivid_hand_painted_scene_linear_mipmaps_integrated_dynamic_chrome_v1"
	result["texture_filter"] = "linear_with_mipmaps_v1"
	result["mipmaps"] = true
	result["embedded_contact_shadow"] = true
	return result


static func _measurement_phase154_environment_profile(texture_path: String) -> Dictionary:
	var result := _profile("environment_plate", texture_path, Vector2(412.0, 248.0), Vector2(0.5, 0.5), 0)
	result["style_id"] = APPROVED_PAINTED_CARTOON_STYLE_ID
	result["master_art_direction"] = APPROVED_PAINTED_CARTOON_MASTER_ID
	result["phase154_runtime_set"] = MEASUREMENT_PHASE154_RUNTIME_SET_ID
	result["source_pixel_policy"] = "existing_painted_measurement_png_byte_exact_import_sidecar_only_v1"
	result["rendering"] = "vivid_hand_painted_scene_linear_mipmaps_integrated_dynamic_metrics_v1"
	result["texture_filter"] = "linear_with_mipmaps_v1"
	result["mipmaps"] = true
	result["embedded_contact_shadow"] = true
	return result


static func _herbarium_phase155_environment_profile(texture_path: String) -> Dictionary:
	var result := _profile("environment_plate", texture_path, REFERENCE_VIEWPORT, Vector2(0.5, 0.5), 0)
	result["style_id"] = APPROVED_PAINTED_CARTOON_STYLE_ID
	result["master_art_direction"] = APPROVED_PAINTED_CARTOON_MASTER_ID
	result["phase155_runtime_set"] = HERBARIUM_PHASE155_RUNTIME_SET_ID
	result["source_pixel_policy"] = "phase155_generated_clean_plate_no_baked_text_values_or_plants_v1"
	result["rendering"] = "vivid_hand_painted_fullscreen_book_linear_mipmaps_dynamic_overlays_v1"
	result["texture_filter"] = "linear_with_mipmaps_v1"
	result["mipmaps"] = true
	result["embedded_contact_shadow"] = true
	return result


static func _daily_challenge_phase161_environment_profile(texture_path: String) -> Dictionary:
	var result := _profile("environment_plate", texture_path, Vector2(412.0, 808.0), Vector2(0.5, 0.5), 0)
	result["style_id"] = APPROVED_PAINTED_CARTOON_STYLE_ID
	result["master_art_direction"] = APPROVED_PAINTED_CARTOON_MASTER_ID
	result["phase161_runtime_set"] = DAILY_CHALLENGE_PHASE161_RUNTIME_SET_ID
	result["source_pixel_policy"] = "phase161_generated_neutral_clean_plate_no_baked_text_values_or_hud_v1"
	result["rendering"] = "vivid_hand_painted_rgba_plate_linear_mipmaps_dynamic_text_buttons_and_context_overlay_v1"
	result["texture_filter"] = "linear_with_mipmaps_v1"
	result["mipmaps"] = true
	result["embedded_contact_shadow"] = true
	result["alpha_policy"] = "deterministic_edge_connected_background_only_rgb_unchanged_v1"
	return result


static func _cosmetic_showroom_phase162_environment_profile(texture_path: String) -> Dictionary:
	var result := _profile("environment_plate", texture_path, Vector2(422.0, 878.0), Vector2(0.5, 0.5), 0)
	result["style_id"] = APPROVED_PAINTED_CARTOON_STYLE_ID
	result["master_art_direction"] = APPROVED_PAINTED_CARTOON_MASTER_ID
	result["phase162_runtime_set"] = COSMETIC_SHOWROOM_PHASE162_RUNTIME_SET_ID
	result["source_pixel_policy"] = "phase162_generated_clean_plate_no_baked_copy_values_states_or_icons_v1"
	result["rendering"] = "vivid_hand_painted_catalog_linear_mipmaps_dynamic_copy_wallet_states_and_buttons_v1"
	result["texture_filter"] = "linear_with_mipmaps_v1"
	result["mipmaps"] = true
	result["embedded_contact_shadow"] = true
	result["crop_policy"] = "runtime_atlas_region_removes_baked_hud_and_navigation_background_v1"
	return result


static func _painted_cartoon_profile(family: String, texture_path: String, design_size: Vector2, pivot: Vector2, z_layer: int) -> Dictionary:
	var result := _profile(family, texture_path, design_size, pivot, z_layer)
	result["style_id"] = APPROVED_PAINTED_CARTOON_STYLE_ID
	result["master_art_direction"] = APPROVED_PAINTED_CARTOON_MASTER_ID
	result["painted_cartoon_set"] = PLAYER_ROOM_PAINTED_CARTOON_SET_ID
	result["rendering"] = "vivid_hand_painted_rgba_linear_mipmaps_no_checkerboard_no_halo_v1"
	return result


static func _phase149_environment_profile(texture_path: String, z_layer := 0) -> Dictionary:
	var result := _painted_cartoon_profile("environment_plate", texture_path, REFERENCE_CONTENT_SIZE, Vector2(0.5, 0.5), z_layer)
	result["exact_target_set"] = PLAYER_ROOM_EXACT_TARGET_SET_ID
	result["source_pixel_policy"] = "phase147_target_rgb_unchanged_outside_approved_object_masks_v1"
	result["rendering"] = "target_native_linear_mipmaps_sunrise_untinted_whole_scene_theme_overlay_v1"
	result["mipmaps"] = true
	return result


static func _greenhouse_phase150_reference_profile(texture_path: String) -> Dictionary:
	var result := _profile("environment_plate", texture_path, REFERENCE_CONTENT_SIZE, Vector2(0.5, 0.5), 0)
	result["style_id"] = APPROVED_PAINTED_CARTOON_STYLE_ID
	result["master_art_direction"] = APPROVED_PAINTED_CARTOON_MASTER_ID
	result["phase150_runtime_set"] = GREENHOUSE_PHASE150_RUNTIME_SET_ID
	result["reference_only"] = true
	result["runtime_authorized"] = false
	result["baked_state_policy"] = "never_draw_as_dynamic_runtime_background_v1"
	result["rendering"] = "target_native_linear_mipmaps_reference_only_v1"
	result["texture_filter"] = "linear_with_mipmaps_v1"
	result["mipmaps"] = true
	return result


static func _room_target_phase149_profile(texture_path: String, target_source_rect: Rect2, target_source_anchor: Vector2, layer_role: String) -> Dictionary:
	var target_crop_size := Vector2(853.0, 1548.0)
	var design_size := target_source_rect.size * (REFERENCE_CONTENT_SIZE / target_crop_size)
	var normalized_pivot := (target_source_anchor - target_source_rect.position) / target_source_rect.size
	normalized_pivot.x = clampf(normalized_pivot.x, 0.0, 1.0)
	normalized_pivot.y = clampf(normalized_pivot.y, 0.0, 1.0)
	var result := _painted_cartoon_profile("room_collectible", texture_path, design_size, normalized_pivot, 40)
	result["scale_range"] = Vector2(0.82, 1.18)
	result["exact_target_set"] = PLAYER_ROOM_EXACT_TARGET_SET_ID
	result["target_source_rect"] = target_source_rect
	result["target_source_anchor"] = target_source_anchor
	result["target_crop_size"] = target_crop_size
	result["source_pixel_policy"] = "phase148_clean_rgba_dynamic_noncanonical_phase158_v3"
	result["dynamic_noncanonical_layout"] = true
	result["dynamic_pot_top_fraction"] = 0.55
	result["embedded_contact_shadow"] = true
	result["layer_role"] = layer_role
	result["texture_filter"] = "linear_with_mipmaps_v1"
	result["mipmaps"] = true
	return result


static func _room_rack_phase167_profile(asset_id: String, source_id: String, target_source_rect: Rect2, target_source_anchor: Vector2) -> Dictionary:
	# Phase169 only removes verified source-background alpha. The Phase167
	# canvas, measured ceramic/crown geometry and all painted RGB stay intact.
	var texture_path := "res://assets/ui/visual/phase169/player_room/plants/room_plant_%s_phase169.png" % source_id
	var result := _room_target_phase149_profile(texture_path, target_source_rect, target_source_anchor, "rack_plant_measured_geometry_v1")
	var measured: Array = RoomPlantGeometry.LANDMARKS[asset_id]
	var canvas: Vector2 = measured[0]
	var preview_scale := minf(RoomPlantGeometry.CERAMIC_DESIGN_SIZE.x / float(measured[2]), RoomPlantGeometry.CERAMIC_DESIGN_SIZE.y / (float(measured[3]) - float(measured[4])))
	result["design_size"] = canvas * preview_scale
	result["pivot"] = Vector2(float(measured[1]), float(measured[3])) / canvas
	result.erase("dynamic_pot_top_fraction")
	result["rack_geometry_contract"] = RoomPlantGeometry.CONTRACT
	result["rack_geometry_asset_id"] = asset_id
	result["source_pixel_policy"] = "phase169_alpha_only_matte_and_seeded_holes_same_canvas_v1"
	result["alpha_provenance"] = "res://assets/ui/visual/phase169/player_room/phase169_plant_edges_manifest.json"
	result["ceramic_design_size"] = RoomPlantGeometry.CERAMIC_DESIGN_SIZE
	result["ceramic_reference_asset"] = "room_broad_leaf"
	result["ceramic_alignment"] = "measured_saucer_center_and_contact_v1"
	return result


static func _room_botanical_cloche_phase159_profile(texture_path: String) -> Dictionary:
	var target_source_anchor := Vector2(675.0, 1212.0)
	var original_target_size := Vector2(112.0, 168.0)
	var enlarged_target_size := original_target_size * PLAYER_ROOM_PHASE159_BOTANICAL_CLOCHE_SCALE
	var target_source_rect := Rect2(
		Vector2(
			target_source_anchor.x - enlarged_target_size.x * 0.5,
			target_source_anchor.y - enlarged_target_size.y
		),
		enlarged_target_size
	)
	var result := _room_target_phase149_profile(
		texture_path,
		target_source_rect,
		target_source_anchor,
		"cabinet_shelf_clean_dynamic_v4"
	)
	result["phase159_botanical_cloche"] = PLAYER_ROOM_PHASE159_BOTANICAL_CLOCHE_ID
	result["phase159_visual_scale"] = PLAYER_ROOM_PHASE159_BOTANICAL_CLOCHE_SCALE
	result["phase159_baseline_policy"] = "center_bottom_preserved_v1"
	result["source_pixel_policy"] = "phase159_approved_chroma_key_alpha_despill_v1"
	result["embedded_contact_shadow"] = false
	result["dynamic_noncanonical_layout"] = false
	return result


static func _room_painted_phase148_profile(texture_path: String, source_size: Vector2, pivot: Vector2, source_to_design: float, layer_role: String) -> Dictionary:
	var result := _painted_cartoon_profile("room_collectible", texture_path, source_size * source_to_design, pivot, 40)
	result["scale_range"] = Vector2(0.82, 1.18)
	result["source_pixel_policy"] = "approved_rgb_byte_exact_alpha_only_background_removal_v1"
	result["embedded_contact_shadow"] = true
	result["layer_role"] = layer_role
	result["texture_filter"] = "linear_with_mipmaps_v1"
	return result


static func _room_plant_profile(texture_path: String, design_size: Vector2, pivot: Vector2, source_uv := Rect2(0.0, 0.0, 1.0, 1.0)) -> Dictionary:
	var result := _profile_region("room_collectible", texture_path, design_size, pivot, 40, source_uv)
	# Bottom-shelf fitting on the compact 360 px layout legitimately needs a
	# smaller multiplier than generic decorations, while the authored maximum
	# remains large enough to fill the upper shelf bays.
	result["scale_range"] = Vector2(0.48, 1.20)
	return result


static func _room_plant_phase139_profile(texture_path: String) -> Dictionary:
	var result := _profile("room_collectible", texture_path, Vector2(84.0, 126.0), Vector2(0.5, 0.9583), 40)
	result["scale_range"] = Vector2(0.82, 1.18)
	result["unified_room_set"] = PLAYER_ROOM_UNIFIED_ROOM_SET_ID
	result["pot_geometry"] = "shared_591x887_equal_pot_saucer_canvas_v1"
	result["texture_filter"] = "linear_with_mipmaps_v1"
	return result


static func _room_plant_phase141_profile(texture_path: String) -> Dictionary:
	var result := _room_plant_phase139_profile(texture_path)
	result["final_rack_set"] = PLAYER_ROOM_FINAL_RACK_SET_ID
	result["pot_geometry"] = "shared_591x887_saucer_340_contact_850_v1"
	result["rendering"] = "approved_painterly_rgba_no_checkerboard_no_halo_v1"
	return result


static func _room_plant_phase142_profile(texture_path: String, source_size: Vector2, pivot: Vector2) -> Dictionary:
	var source_to_design := REFERENCE_CONTENT_SIZE.x / 887.0
	var result := _room_plant_profile(texture_path, source_size * source_to_design, pivot)
	result["scale_range"] = Vector2(0.82, 1.18)
	result["reference_exact_set"] = PLAYER_ROOM_REFERENCE_EXACT_SET_ID
	result["source_pixel_policy"] = "approved_reference_rgb_mask_alpha_v1"
	result["pot_geometry"] = "reference_equal_ceramic_pot_and_saucer_v1"
	result["rendering"] = "reference_exact_painterly_rgba_no_repaint_v1"
	return result


static func _room_plant_phase143_profile(texture_path: String, source_size: Vector2, pivot: Vector2) -> Dictionary:
	# The approved rack-only preview uses columns roughly 216 source pixels apart,
	# while the live room rack uses 144 source pixels. A single isotropic 2/3
	# conversion preserves the approved pot proportions without widening or
	# vertically compressing individual rows.
	var source_to_design := (REFERENCE_CONTENT_SIZE.x / 887.0) * (2.0 / 3.0)
	var result := _room_plant_profile(texture_path, source_size * source_to_design, pivot)
	result["scale_range"] = Vector2(0.82, 1.18)
	result["approved_uniform_set"] = PLAYER_ROOM_APPROVED_UNIFORM_SET_ID
	result["source_pixel_policy"] = "user_approved_rgb_generated_mask_alpha_v1"
	result["source_scale"] = "rack_preview_to_live_room_isotropic_two_thirds_v1"
	result["pot_geometry"] = "shared_visible_height_width_saucer_baseline_shadow_v1"
	result["rendering"] = "user_approved_painterly_rgba_no_repaint_v1"
	return result


static func _room_decor_phase140_profile(texture_path: String, design_size: Vector2, pivot: Vector2) -> Dictionary:
	var result := _profile("room_collectible", texture_path, design_size, pivot, 40)
	result["scale_range"] = Vector2(0.82, 1.18)
	result["shared_decor_set"] = PLAYER_ROOM_SHARED_DECOR_SET_ID
	result["rendering"] = "smooth_rgba_linear_mipmaps_no_sticker_halo_v1"
	return result


static func _room_detail_phase145_profile(texture_path: String, design_size: Vector2, pivot: Vector2, layer_role: String) -> Dictionary:
	var result := _room_decor_phase140_profile(texture_path, design_size, pivot)
	result["detail_layer_set"] = PLAYER_ROOM_LAYERED_DETAILS_ID
	result["layer_role"] = layer_role
	result["grounding"] = "painted_contact_shadow_and_surface_occlusion_v1"
	return result


static func asset_profile(asset_id: String) -> Dictionary:
	return (ASSET_PROFILES.get(asset_id, {}) as Dictionary).duplicate(true)


static func scene_profile(scene_id: String) -> Dictionary:
	return (SCENE_PROFILES.get(scene_id, {}) as Dictionary).duplicate(true)


static func decoration_asset_id(decoration_id: String) -> String:
	return str(DECORATION_ASSET_IDS.get(decoration_id, ""))


static func greenhouse_crop_asset_id(crop_id: String) -> String:
	return str(GREENHOUSE_CROP_ASSET_IDS.get(crop_id, GREENHOUSE_PHASE150_SEEDLINGS_ASSET_ID))


static func greenhouse_seedlings_asset_id() -> String:
	return GREENHOUSE_PHASE150_SEEDLINGS_ASSET_ID


static func family_id_for_path(path: String) -> String:
	var normalized := path.replace("\\", "/")
	for rule in PATH_FAMILY_RULES:
		if normalized.begins_with(str(rule.prefix)):
			return str(rule.family)
	return ""


static func profile_for_path(path: String) -> Dictionary:
	for asset_id in ASSET_PROFILES:
		var explicit := ASSET_PROFILES[asset_id] as Dictionary
		if str(explicit.texture) == path:
			var result := (FAMILY_PROFILES.get(str(explicit.family), {}) as Dictionary).duplicate(true)
			result.merge(explicit, true)
			result["asset_id"] = asset_id
			return result
	var family_id := family_id_for_path(path)
	if family_id.is_empty():
		return {}
	var family_profile := (FAMILY_PROFILES.get(family_id, {}) as Dictionary).duplicate(true)
	family_profile["family"] = family_id
	family_profile["asset_id"] = "family_default"
	return family_profile


static func texture_for(asset_id: String) -> Texture2D:
	if _texture_cache.has(asset_id):
		return _texture_cache[asset_id] as Texture2D
	var profile := ASSET_PROFILES.get(asset_id, {}) as Dictionary
	var path := str(profile.get("texture", ""))
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	var texture := load(path) as Texture2D
	_texture_cache[asset_id] = texture
	return texture


static func source_region_for(asset_id: String) -> Rect2:
	var texture := texture_for(asset_id)
	if texture == null:
		return Rect2()
	var profile := ASSET_PROFILES.get(asset_id, {}) as Dictionary
	var source_uv := profile.get("source_uv", Rect2(0.0, 0.0, 1.0, 1.0)) as Rect2
	var texture_size := texture.get_size()
	var source_region := Rect2(source_uv.position * texture_size, source_uv.size * texture_size)
	# Clamp explicit regions defensively. Invalid metadata is reported by
	# contract_errors(), but rendering should still never sample outside a texture.
	return source_region.intersection(Rect2(Vector2.ZERO, texture_size))


static func design_scale(viewport_size: Vector2) -> float:
	return clampf(viewport_size.x / REFERENCE_CONTENT_SIZE.x, 0.82, 1.18)


static func asset_rect(asset_id: String, anchor: Vector2, viewport_size: Vector2, multiplier := 1.0) -> Rect2:
	var profile := ASSET_PROFILES.get(asset_id, {}) as Dictionary
	if profile.is_empty():
		return Rect2(anchor, Vector2.ZERO)
	var scale_limits := profile.get("scale_range", Vector2(0.72, 1.28)) as Vector2
	var scale := clampf(design_scale(viewport_size) * multiplier, scale_limits.x, scale_limits.y)
	var display_size := (profile.get("design_size", Vector2.ZERO) as Vector2) * scale
	var pivot := profile.get("pivot", Vector2(0.5, 0.5)) as Vector2
	return Rect2(anchor - display_size * pivot, display_size)


static func target_native_asset_rect(asset_id: String, anchor: Vector2, viewport_size: Vector2) -> Rect2:
	var profile := ASSET_PROFILES.get(asset_id, {}) as Dictionary
	if str(profile.get("exact_target_set", "")) != PLAYER_ROOM_EXACT_TARGET_SET_ID:
		return asset_rect(asset_id, anchor, viewport_size)
	var source_rect := profile.get("target_source_rect", Rect2()) as Rect2
	var source_anchor := profile.get("target_source_anchor", source_rect.get_center()) as Vector2
	var crop_size := profile.get("target_crop_size", Vector2(853.0, 1548.0)) as Vector2
	if source_rect.size.x <= 0.0 or source_rect.size.y <= 0.0 or crop_size.x <= 0.0 or crop_size.y <= 0.0:
		return Rect2(anchor, Vector2.ZERO)
	var scale := viewport_size / crop_size
	return Rect2(anchor + (source_rect.position - source_anchor) * scale, source_rect.size * scale)


static func fit_asset_rect(asset_id: String, bounds: Rect2, fill := 1.0) -> Rect2:
	var texture := texture_for(asset_id)
	if texture == null or bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		return Rect2(bounds.get_center(), Vector2.ZERO)
	var texture_size := texture.get_size()
	var scale := minf(bounds.size.x / texture_size.x, bounds.size.y / texture_size.y) * clampf(fill, 0.05, 1.0)
	var fitted_size := texture_size * scale
	return Rect2(bounds.get_center() - fitted_size * 0.5, fitted_size)


static func fit_asset_region_rect(asset_id: String, bounds: Rect2, fill := 1.0) -> Rect2:
	if bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		return Rect2(bounds.get_center(), Vector2.ZERO)
	var source_region := source_region_for(asset_id)
	if source_region.size.x <= 0.0 or source_region.size.y <= 0.0:
		return Rect2(bounds.get_center(), Vector2.ZERO)
	var scale := minf(bounds.size.x / source_region.size.x, bounds.size.y / source_region.size.y) * clampf(fill, 0.05, 1.0)
	var fitted_size := source_region.size * scale
	return Rect2(bounds.get_center() - fitted_size * 0.5, fitted_size)


static func contract_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	if not ResourceLoader.exists(MASTER_REFERENCE_ASSET):
		errors.append("Master art-direction reference is missing.")
	elif FileAccess.get_sha256(MASTER_REFERENCE_ASSET) != MASTER_REFERENCE_SHA256:
		errors.append("Master art-direction reference hash changed.")
	if not FileAccess.file_exists(APPROVED_PAINTED_CARTOON_MASTER_ASSET):
		errors.append("Approved Phase 147 painted-cartoon master is missing.")
	elif FileAccess.get_sha256(APPROVED_PAINTED_CARTOON_MASTER_ASSET) != APPROVED_PAINTED_CARTOON_MASTER_SHA256:
		errors.append("Approved Phase 147 painted-cartoon master hash changed.")
	if not FileAccess.file_exists(PLAYER_ROOM_EXACT_TARGET_ASSET):
		errors.append("Approved Phase 149 exact player-room target is missing.")
	elif FileAccess.get_sha256(PLAYER_ROOM_EXACT_TARGET_ASSET) != PLAYER_ROOM_EXACT_TARGET_SHA256:
		errors.append("Approved Phase 149 exact player-room target hash changed.")
	if not FileAccess.file_exists(PLAYER_ROOM_CANONICAL_FULL_ASSET):
		errors.append("Phase 149 canonical player-room runtime master is missing.")
	elif FileAccess.get_sha256(PLAYER_ROOM_CANONICAL_FULL_ASSET) != PLAYER_ROOM_CANONICAL_FULL_SHA256:
		errors.append("Phase 149 canonical player-room runtime master hash changed.")
	if not FileAccess.file_exists(GREENHOUSE_PHASE150_TARGET_ASSET):
		errors.append("Approved Phase 150 greenhouse target is missing.")
	elif FileAccess.get_sha256(GREENHOUSE_PHASE150_TARGET_ASSET) != GREENHOUSE_PHASE150_TARGET_SHA256:
		errors.append("Approved Phase 150 greenhouse target hash changed.")
	if not FileAccess.file_exists(GREENHOUSE_PHASE150_CANONICAL_CONTENT_ASSET):
		errors.append("Phase 150 canonical greenhouse content master is missing.")
	elif FileAccess.get_sha256(GREENHOUSE_PHASE150_CANONICAL_CONTENT_ASSET) != GREENHOUSE_PHASE150_CANONICAL_CONTENT_SHA256:
		errors.append("Phase 150 canonical greenhouse content master hash changed.")
	for key in ["id", "style_id", "reference_asset", "reference_sha256", "medium", "linework", "color", "shading", "lighting", "materials", "scale", "composition", "ui_policy", "runtime_policy", "source_policy", "avoid"]:
		if not APPROVED_PAINTED_CARTOON_PROFILE.has(key):
			errors.append("Approved Phase 147 painted-cartoon profile misses %s." % key)
	if APPROVED_PAINTED_CARTOON_TRANSITION_ORDER.size() != 8 or APPROVED_PAINTED_CARTOON_TRANSITION_ORDER[0] != "player_room":
		errors.append("Approved Phase 147 screen transition order changed.")
	for family_id in FAMILY_PROFILES:
		var family := FAMILY_PROFILES[family_id] as Dictionary
		if family_id != "legacy_reference" and (str(family.get("style_id", "")) != STYLE_ID or str(family.get("master_art_direction", "")) != MASTER_ART_DIRECTION_ID):
			errors.append("Live family %s is not bound to the master art direction." % family_id)
	for scene_id in SCENE_PROFILES:
		var scene := SCENE_PROFILES[scene_id] as Dictionary
		for key in ["id", "reference_size", "camera_mode", "title_band", "hero_band", "lower_band", "palette_id", "lighting_id", "allowed_families"]:
			if not scene.has(key):
				errors.append("Scene %s misses %s." % [scene_id, key])
	for asset_id in ASSET_PROFILES:
		var profile := ASSET_PROFILES[asset_id] as Dictionary
		for key in ["family", "texture", "design_size", "pivot", "z_layer", "scale_range"]:
			if not profile.has(key):
				errors.append("Asset %s misses %s." % [asset_id, key])
		if not FAMILY_PROFILES.has(str(profile.get("family", ""))):
			errors.append("Asset %s uses an unknown family." % asset_id)
		var path := str(profile.get("texture", ""))
		if path.is_empty() or not ResourceLoader.exists(path):
			errors.append("Asset %s has no importable texture." % asset_id)
		var design_size := profile.get("design_size", Vector2.ZERO) as Vector2
		if design_size.x <= 0.0 or design_size.y <= 0.0:
			errors.append("Asset %s has an invalid design size." % asset_id)
		var pivot := profile.get("pivot", Vector2(-1.0, -1.0)) as Vector2
		if pivot.x < 0.0 or pivot.x > 1.0 or pivot.y < 0.0 or pivot.y > 1.0:
			errors.append("Asset %s has an invalid normalized pivot." % asset_id)
		if profile.has("source_uv"):
			var source_uv := profile.source_uv as Rect2
			if source_uv.position.x < 0.0 or source_uv.position.y < 0.0 or source_uv.end.x > 1.0 or source_uv.end.y > 1.0 or source_uv.size.x <= 0.0 or source_uv.size.y <= 0.0:
				errors.append("Asset %s has an invalid source UV region." % asset_id)
	for runtime_path in runtime_referenced_png_paths():
		var runtime_profile := profile_for_path(runtime_path)
		if runtime_profile.is_empty():
			errors.append("Runtime PNG has no visual profile: %s" % runtime_path)
		else:
			var runtime_style := str(runtime_profile.get("style_id", ""))
			var runtime_master := str(runtime_profile.get("master_art_direction", ""))
			var current_style := runtime_style == STYLE_ID and runtime_master == MASTER_ART_DIRECTION_ID
			var painted_style := runtime_style == APPROVED_PAINTED_CARTOON_STYLE_ID and runtime_master == APPROVED_PAINTED_CARTOON_MASTER_ID
			if not current_style and not painted_style:
				errors.append("Runtime PNG is outside the master art direction: %s" % runtime_path)
	return errors


static func runtime_referenced_png_paths() -> PackedStringArray:
	var found := {}
	var matcher := RegEx.new()
	if matcher.compile("res://assets/[A-Za-z0-9_./-]+\\.png") != OK:
		return PackedStringArray()
	for root_path in ["res://scripts", "res://data"]:
		_collect_runtime_png_references(root_path, matcher, found)
	var paths := PackedStringArray()
	for path in found:
		paths.append(str(path))
	paths.sort()
	return paths


static func _collect_runtime_png_references(path: String, matcher: RegEx, found: Dictionary) -> void:
	var directory := DirAccess.open(path)
	if directory == null:
		return
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		if entry != "." and entry != "..":
			var child_path := path.path_join(entry)
			if directory.current_is_dir():
				_collect_runtime_png_references(child_path, matcher, found)
			elif entry.get_extension().to_lower() in ["gd", "json", "tres", "tscn"]:
				var source := FileAccess.get_file_as_string(child_path)
				for result in matcher.search_all(source):
					found[(result as RegExMatch).get_string()] = true
		entry = directory.get_next()
	directory.list_dir_end()


static func unprofiled_png_paths(root := "res://assets") -> PackedStringArray:
	var png_paths := profiled_png_paths(root)
	var missing := PackedStringArray()
	for path in png_paths:
		if profile_for_path(path).is_empty():
			missing.append(path)
	return missing


static func profiled_png_paths(root := "res://assets") -> PackedStringArray:
	var png_paths := PackedStringArray()
	_collect_png_paths(root, png_paths)
	png_paths.sort()
	return png_paths


static func _collect_png_paths(path: String, output: PackedStringArray) -> void:
	var directory := DirAccess.open(path)
	if directory == null:
		return
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		if entry != "." and entry != "..":
			var child_path := path.path_join(entry)
			if directory.current_is_dir():
				_collect_png_paths(child_path, output)
			elif entry.get_extension().to_lower() == "png":
				output.append(child_path)
		entry = directory.get_next()
	directory.list_dir_end()
