extends SceneTree

const OUTPUT_SIZE := Vector2i(1080, 2400)
const HUD_LOGICAL_HEIGHT := 74.0
const NAV_LOGICAL_HEIGHT := 97.0
const LOGICAL_WIDTH := 432.0
const LAVENDER_SPECIES_ID := "lavandula_angustifolia"
const LAVENDER_BEHAVIOR_ID := "fragrant_bloom"
const LAVENDER_BEHAVIOR_LABEL := "VOŇAVÝ KVĚT"
const LAVENDER_ACTIVE_THRESHOLD := 0.85
const MINT_SPECIES_ID := "mint_peppermint"
const MINT_BEHAVIOR_ID := "refreshing_water"
const MINT_BEHAVIOR_LABEL := "MÁTOVÉ VZPRUŽENÍ"
const CHIVES_SPECIES_ID := "allium_schoenoprasum"
const CHIVES_BEHAVIOR_ID := "clumping_vigor"
const CHIVES_BEHAVIOR_LABEL := "SÍLA TRSU"
const CHIVES_MOISTURE_MIN := 46.0
const CHIVES_MOISTURE_MAX := 78.0
const CHIVES_STAGE_TEXTURES := {
	"seed": "res://assets/plants/comic/chives_seed_v1.png",
	"sprout": "res://assets/plants/comic/chives_sprout_v1.png",
	"young": "res://assets/plants/comic/chives_young_v1.png",
	"mature": "res://assets/plants/comic/chives_mature_v1.png",
	"sick": "res://assets/plants/comic/chives_sick_v1.png",
	"harvest_ready": "res://assets/plants/comic/chives_harvest_ready_v1.png",
}
const PROFESSOR_STORY_CHAPTER_ID := "lost_herbarium_pages"
const MARJORAM_SPECIES_ID := "origanum_majorana"
const MARJORAM_BEHAVIOR_ID := "aroma_preservation"
const MARJORAM_BEHAVIOR_LABEL := "VŮNĚ PO USUŠENÍ"
const MARJORAM_QUALITY_THRESHOLD := 0.80
const MARJORAM_DRYING_MULTIPLIER := 0.80
const MARJORAM_STAGE_TEXTURES := {
	"seed": "res://assets/plants/comic/marjoram_seed_v1.png",
	"sprout": "res://assets/plants/comic/marjoram_sprout_v1.png",
	"young": "res://assets/plants/comic/marjoram_young_v1.png",
	"mature": "res://assets/plants/comic/marjoram_mature_v1.png",
	"sick": "res://assets/plants/comic/marjoram_sick_v1.png",
	"harvest_ready": "res://assets/plants/comic/marjoram_harvest_ready_v1.png",
}
const PARSLEY_SPECIES_ID := "petroselinum_crispum"
const PARSLEY_BEHAVIOR_ID := "shade_tolerance"
const PARSLEY_BEHAVIOR_LABEL := "TOLERANCE POLOSTÍNU"
const PARSLEY_LIGHT_THRESHOLD_LUX := 5400.0
const PARSLEY_LIGHT_FACTOR_FLOOR := 0.60
const PARSLEY_STAGE_TEXTURES := {
	"seed": "res://assets/plants/comic/parsley_seed_v1.png",
	"sprout": "res://assets/plants/comic/parsley_sprout_v1.png",
	"young": "res://assets/plants/comic/parsley_young_v1.png",
	"mature": "res://assets/plants/comic/parsley_mature_v1.png",
	"sick": "res://assets/plants/comic/parsley_sick_v1.png",
	"harvest_ready": "res://assets/plants/comic/parsley_harvest_ready_v1.png",
}
const LEMON_BALM_SPECIES_ID := "melissa_officinalis"
const LEMON_BALM_BEHAVIOR_ID := "self_seeding"
const LEMON_BALM_BEHAVIOR_LABEL := "BOHATÝ SAMOVÝSEV"
const BASE_SEED_DROP_CHANCE := 0.58
const LEMON_BALM_SEED_DROP_BONUS := 0.17
const LEMON_BALM_SEED_DROP_CHANCE := 0.75
const LEMON_BALM_STAGE_TEXTURES := {
	"seed": "res://assets/plants/comic/lemon_balm_seed_v1.png",
	"sprout": "res://assets/plants/comic/lemon_balm_sprout_v1.png",
	"young": "res://assets/plants/comic/lemon_balm_young_v1.png",
	"mature": "res://assets/plants/comic/lemon_balm_mature_v1.png",
	"sick": "res://assets/plants/comic/lemon_balm_sick_v1.png",
	"harvest_ready": "res://assets/plants/comic/lemon_balm_harvest_ready_v1.png",
}
const SAGE_SPECIES_ID := "salvia_officinalis"
const SAGE_BEHAVIOR_ID := "modest_feeding"
const SAGE_BEHAVIOR_LABEL := "STŘÍDMÁ VÝŽIVA"
const SAGE_NUTRIENT_LOSS_MULTIPLIER := 0.75
const SAGE_STAGE_TEXTURES := {
	"seed": "res://assets/plants/comic/sage_seed_v1.png",
	"sprout": "res://assets/plants/comic/sage_sprout_v1.png",
	"young": "res://assets/plants/comic/sage_young_v1.png",
	"mature": "res://assets/plants/comic/sage_mature_v1.png",
	"sick": "res://assets/plants/comic/sage_sick_v1.png",
	"harvest_ready": "res://assets/plants/comic/sage_harvest_ready_v1.png",
}
const PROFESSOR_STORY_CHAPTER_TWO_ID := "silver_sage_legacy"
const PROFESSOR_STORY_CHAPTER_THREE_ID := "grand_herbarium_exhibition"
const PHASE97_STORY_GOAL_IDS := ["complete_collection", "expert_circle", "preparation_days", "exhibition_orders", "showcase_samples"]
const PHASE97_STORY_GOAL_TARGETS := [10, 3, 3, 3, 4]
const PHASE97_RESPONSIVE_TEST_VIEWPORTS := [Vector2i(432, 960), Vector2i(360, 800)]
const PHASE98_RESEARCH_CAPTURE_UTC_DAY := 100000
const PHASE98_RESEARCH_GOAL_IDS := ["care_variety", "quality_samples", "packaged_samples", "delivered_packages", "observation_days"]

var output_directory := ""


func _init() -> void:
	output_directory = _read_output_directory()
	if output_directory.is_empty():
		push_error("Missing required --output-dir argument.")
		quit(2)
		return
	var directory_error := DirAccess.make_dir_recursive_absolute(output_directory)
	if directory_error != OK:
		push_error("Could not create validation output directory: %s" % error_string(directory_error))
		quit(2)
		return
	call_deferred("_capture")


func _capture() -> void:
	var packed := load("res://main.tscn") as PackedScene
	if packed == null:
		push_error("Could not load res://main.tscn")
		quit(2)
		return
	var instance = packed.instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame

	_prepare_common_state(instance)
	_prepare_locked_state(instance)
	await _settle(instance)
	if not _save_full_viewport("locked-slots.png"):
		quit(2)
		return

	_prepare_room_state(instance)
	await _settle(instance)
	var room_image := _viewport_image()
	if not _save_image(room_image, "room.png"):
		quit(2)
		return
	if not _save_bottom_region(room_image, "navigation.png", NAV_LOGICAL_HEIGHT):
		quit(2)
		return

	_prepare_phase103_player_room_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-player-room.png"):
		quit(2)
		return

	_prepare_phase104_decorated_player_room_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-player-room-decorated.png"):
		quit(2)
		return

	_prepare_phase104_decoration_shop_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-room-decoration-shop.png"):
		quit(2)
		return
	instance._close_room_decoration_modal()

	_prepare_phase105_greenhouse_empty_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-greenhouse-preview.png"):
		quit(2)
		return

	_prepare_phase105_greenhouse_growing_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-greenhouse-growing.png"):
		quit(2)
		return

	_prepare_phase105_greenhouse_ready_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-greenhouse-ready.png"):
		quit(2)
		return

	_prepare_phase106_greenhouse_pepper_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-greenhouse-pepper-growing.png"):
		quit(2)
		return

	_prepare_phase107_greenhouse_locked_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-greenhouse-locked-crops.png"):
		quit(2)
		return

	_prepare_phase107_greenhouse_cucumber_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-greenhouse-cucumber-growing.png"):
		quit(2)
		return

	var phase109_compact_capture_ok := await _capture_phase109_greenhouse_level2_compact(instance)
	if not phase109_compact_capture_ok:
		quit(2)
		return

	_prepare_room_state(instance)
	instance._open_rack_location()
	await _settle(instance)

	_prepare_phase6_guide_state(instance, GuideCharacter.Mood.EXPLAIN, "Každý list něco prozradí. Sleduj vláhu, světlo a růst.", 0.44)
	await _settle(instance)
	if not _save_full_viewport("comic-guide-explain.png"):
		quit(2)
		return

	_prepare_phase6_guide_state(instance, GuideCharacter.Mood.CELEBRATE, "Sklizeno! Bazalka i odměna jsou připravené.", 0.62)
	await _settle(instance)
	if not _save_full_viewport("comic-guide-celebrate.png"):
		quit(2)
		return

	_prepare_phase6_guide_state(instance, GuideCharacter.Mood.WARNING, "Pozor, bazalka má málo vody. Ještě ji ale snadno zachráníme.", 0.53)
	await _settle(instance)
	if not _save_full_viewport("comic-guide-warning.png"):
		quit(2)
		return
	instance._finish_guide_capture()

	instance._prepare_audio_settings_capture()
	await _settle(instance)
	if not _save_full_viewport("comic-audio-settings.png"):
		quit(2)
		return
	instance._finish_audio_settings_capture()

	_prepare_phase5_storage_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-storage.png"):
		quit(2)
		return

	_prepare_phase10_order_state(instance)
	await _settle(instance)
	# Apply the deterministic scroll after layout has reported its final height,
	# so the evidence frame shows the cards rather than only their header.
	instance.storage_scroll.scroll_vertical = 620
	await process_frame
	if not _save_full_viewport("comic-customer-orders.png"):
		quit(2)
		return

	_prepare_phase5_shop_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-shop.png"):
		quit(2)
		return
	instance._set_shop_legacy_capture(false)
	instance._set_shop_mode("buy")
	await _settle(instance)
	if not _save_full_viewport("comic-botanist-shop-buy.png"):
		quit(2)
		return
	_prepare_phase40_equipment_shop_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-equipment-shop.png"):
		quit(2)
		return
	_finish_phase40_equipment_shop_state(instance)

	_prepare_botanist_shop_sell_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-botanist-shop-sell.png"):
		quit(2)
		return

	_prepare_phase11_seed_selector_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-seed-selector.png"):
		quit(2)
		return

	_prepare_phase11_mint_room_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-mint-room.png"):
		quit(2)
		return

	_prepare_phase11_mint_detail_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-mint-detail.png"):
		quit(2)
		return

	_prepare_phase12_herbarium_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-herbarium.png"):
		quit(2)
		return
	instance._set_herbarium_open(false)

	_prepare_phase5_measurement_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-measurement.png"):
		quit(2)
		return

	_prepare_detail_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-detail-idle.png"):
		quit(2)
		return

	_prepare_phase75_late_harvest_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-detail-late-harvest.png"):
		quit(2)
		return

	_prepare_phase75_wilted_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-detail-wilted.png"):
		quit(2)
		return

	_prepare_phase75_dead_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-detail-dead.png"):
		quit(2)
		return

	_prepare_phase75_care_center_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-care-center-wilted.png"):
		quit(2)
		return
	instance._set_care_center_open(false)

	_prepare_phase62_treatment_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-detail-treatment.png"):
		quit(2)
		return
	_prepare_phase63_diagnosis_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-plant-diagnosis.png"):
		quit(2)
		return
	instance._set_plant_diagnosis_open(false)

	_prepare_phase64_diagnosis_action_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-plant-diagnosis-action.png"):
		quit(2)
		return
	instance._set_plant_diagnosis_open(false)

	_prepare_phase79_plant_behavior_state(instance)
	await _settle(instance)
	# The behavior card is deliberately last so it never changes care priority.
	# Scroll only after layout settles to make that report-only card deterministic.
	instance.plant_diagnosis_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-plant-behavior.png"):
		quit(2)
		return
	instance._set_plant_diagnosis_open(false)

	_prepare_detail_state(instance)
	_prepare_detail_water_frame(instance)
	await process_frame
	if not _save_full_viewport("comic-detail-water.png"):
		quit(2)
		return

	_prepare_detail_growth_frame(instance)
	await process_frame
	if not _save_full_viewport("comic-detail-growth.png"):
		quit(2)
		return

	_prepare_detail_ladybug_frame(instance)
	await process_frame
	if not _save_full_viewport("comic-detail-ladybug.png"):
		quit(2)
		return

	_prepare_detail_state(instance)
	instance.feedback_layer.set_capture_feedback("water", 0.44, Vector2(0.50, 0.50), 0.75)
	await process_frame
	if not _save_full_viewport("comic-feedback-water.png"):
		quit(2)
		return

	instance.feedback_layer.set_capture_feedback("growth", 0.48, Vector2(0.50, 0.48), 1.0)
	await process_frame
	if not _save_full_viewport("comic-feedback-growth.png"):
		quit(2)
		return

	_prepare_phase5_storage_state(instance)
	instance.feedback_layer.finish_all()
	instance.feedback_layer.set_capture_feedback("coins", 0.30, Vector2(0.55, 0.64), 1.0)
	await process_frame
	if not _save_full_viewport("comic-feedback-coins.png"):
		quit(2)
		return

	_prepare_room_state(instance)
	instance._change_screen(0, false)
	instance._open_room()
	instance.feedback_layer.finish_all()
	instance.feedback_layer.set_capture_feedback("unlock", 0.46, Vector2(0.66, 0.42), 1.0)
	await process_frame
	if not _save_full_viewport("comic-feedback-unlock.png"):
		quit(2)
		return

	instance.feedback_layer.set_capture_transition(0.52, 1)
	await process_frame
	if not _save_full_viewport("comic-screen-transition.png"):
		quit(2)
		return
	instance.feedback_layer.finish_all()

	_prepare_hud_state(instance)
	await _settle(instance)
	var hud_image := _viewport_image()
	if not _save_top_region(hud_image, "hud.png", HUD_LOGICAL_HEIGHT):
		quit(2)
		return

	instance._prepare_daily_challenge_capture()
	await _settle(instance)
	if not _save_full_viewport("comic-daily-challenge.png"):
		quit(2)
		return
	instance._finish_daily_challenge_capture()

	_prepare_phase78_botanical_pack_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-botanical-pack.png"):
		quit(2)
		return
	instance._set_botanical_pack_open(false)

	instance._prepare_cosmetic_showroom_capture()
	await _settle(instance)
	if not _save_full_viewport("comic-cosmetic-showroom.png"):
		quit(2)
		return
	instance._finish_cosmetic_showroom_capture()

	instance._prepare_return_summary_capture()
	await _settle(instance)
	if not _save_full_viewport("comic-return-summary.png"):
		quit(2)
		return
	instance._finish_return_summary_capture()

	if not _prepare_phase109_return_summary_greenhouse_state(instance):
		quit(2)
		return
	await _settle(instance)
	if not _save_full_viewport("comic-return-summary-greenhouse-ready.png"):
		quit(2)
		return
	instance._finish_return_summary_capture()

	if not _prepare_phase109_rack_attention_state(instance):
		quit(2)
		return
	await _settle(instance)
	if not _save_full_viewport("comic-rack-greenhouse-attention.png"):
		quit(2)
		return
	_finish_phase109_rack_attention_state(instance)

	instance._prepare_save_failure_capture()
	await _settle(instance)
	if not _save_full_viewport("comic-save-failure.png"):
		quit(2)
		return
	instance._finish_save_failure_capture()

	instance._prepare_local_backup_capture()
	await _settle(instance)
	if not _save_full_viewport("comic-local-backup.png"):
		quit(2)
		return
	instance._finish_local_backup_capture()

	_prepare_phase41_level_progression_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-level-progression.png"):
		quit(2)
		return
	instance._set_level_progression_open(false)

	_prepare_phase42_care_center_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-care-center.png"):
		quit(2)
		return
	instance._set_care_center_open(false)

	_prepare_phase65_fast_time_guard_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-fast-time-guard.png"):
		quit(2)
		return
	instance._set_care_center_open(false)

	_prepare_phase16_rosemary_shop_state(instance)
	await _settle(instance)
	instance.shop_catalog_scroll.scroll_vertical = 166
	await process_frame
	if not _save_full_viewport("comic-rosemary-shop.png"):
		quit(2)
		return

	_prepare_phase16_rosemary_detail_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-rosemary-detail.png"):
		quit(2)
		return

	_prepare_phase71_oregano_shop_state(instance)
	await _settle(instance)
	instance.shop_catalog_scroll.scroll_vertical = 120
	await process_frame
	if not _save_full_viewport("comic-oregano-shop.png"):
		quit(2)
		return

	_prepare_phase71_oregano_room_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-oregano-room.png"):
		quit(2)
		return

	_prepare_phase71_oregano_detail_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-oregano-detail.png"):
		quit(2)
		return

	instance._prepare_grower_journal_capture()
	await _settle(instance)
	if not _save_full_viewport("comic-grower-journal.png"):
		quit(2)
		return
	instance._finish_grower_journal_capture()

	# Phase 81 diagnostics are intentionally report-only. They run after every
	# approved capture so the extra manifest species cannot change older frames.
	if not _validate_phase81_lavender_contract(instance):
		quit(2)
		return
	if not _prepare_phase81_lavender_seed_selector_state(instance, false):
		quit(2)
		return
	await _settle(instance)
	instance.seed_selector_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-lavender-seed-selector-locked.png"):
		quit(2)
		return

	if not _prepare_phase81_lavender_seed_selector_state(instance, true):
		quit(2)
		return
	await _settle(instance)
	instance.seed_selector_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-lavender-seed-selector-discovered.png"):
		quit(2)
		return
	instance._set_seed_selector_open(false)

	if not _prepare_phase81_lavender_herbarium_state(instance, false):
		quit(2)
		return
	await _settle(instance)
	instance.herbarium_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-lavender-herbarium-locked.png"):
		quit(2)
		return

	if not _prepare_phase81_lavender_herbarium_state(instance, true):
		quit(2)
		return
	await _settle(instance)
	instance.herbarium_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-lavender-herbarium-discovered.png"):
		quit(2)
		return
	instance._set_herbarium_open(false)

	if not _prepare_phase81_lavender_shop_state(instance):
		quit(2)
		return
	await _settle(instance)
	# Lavender is the second tile on the second seed row. Keep that row visible
	# instead of snapping to the equipment cards at the bottom of the catalog.
	instance.shop_catalog_scroll.scroll_vertical = 180
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-lavender-shop-stock.png"):
		quit(2)
		return

	if not _prepare_phase81_lavender_room_state(instance):
		quit(2)
		return
	await _settle(instance)
	if not _save_full_viewport("comic-lavender-room-mature.png"):
		quit(2)
		return

	if not _prepare_phase81_lavender_detail_trait_state(instance):
		quit(2)
		return
	await _settle(instance)
	# The behavior card is the eighth and last diagnosis card. Scrolling after
	# layout proves the Epic trait without changing care priority or actions.
	instance.plant_diagnosis_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-lavender-detail-trait-active.png"):
		quit(2)
		return
	instance._set_plant_diagnosis_open(false)

	# Phase 82 diagnostics are deliberately appended after every approved and
	# earlier report-only frame. They never change an existing fixture, crop,
	# visual manifest entry or reference image.
	if not _prepare_phase82_behavior_active_badge_state(instance):
		quit(2)
		return
	await _settle(instance)
	if not _save_full_viewport("comic-behavior-active-badge.png"):
		quit(2)
		return

	if not _prepare_phase82_behavior_active_badge_state(instance):
		quit(2)
		return
	instance.feedback_layer.finish_all()
	instance.plant_view.set_behavior_state(true, false, MINT_BEHAVIOR_LABEL)
	instance.plant_view.play_behavior_trigger(MINT_BEHAVIOR_ID, MINT_BEHAVIOR_LABEL)
	# Freeze the public pulse at its most legible bounded midpoint while the
	# shared feedback layer uses its existing deterministic capture API.
	instance.plant_view.behavior_pulse = 0.54
	instance.plant_view.queue_redraw()
	instance.feedback_layer.set_capture_feedback("plant_behavior", 0.46, Vector2(0.50, 0.36), 1.0)
	instance.feedback_layer.set_meta("capture_state", "phase82_plant_behavior_feedback_diagnostic_v1")
	await process_frame
	if not _save_full_viewport("comic-feedback-plant-behavior.png"):
		quit(2)
		return

	# Phase 83 Chives diagnostics remain report-only and are appended after all
	# approved and earlier diagnostic frames. They exercise only manifest-backed
	# runtime UI; no reference, crop, tolerance or visual gate depends on them.
	if not _validate_phase83_chives_contract(instance):
		quit(2)
		return

	if not _prepare_phase83_chives_seed_selector_state(instance, false):
		quit(2)
		return
	await _settle(instance)
	instance.seed_selector_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-chives-seed-selector-locked.png"):
		quit(2)
		return

	if not _prepare_phase83_chives_seed_selector_state(instance, true):
		quit(2)
		return
	await _settle(instance)
	instance.seed_selector_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-chives-seed-selector-discovered.png"):
		quit(2)
		return
	instance._set_seed_selector_open(false)

	if not _prepare_phase83_chives_herbarium_state(instance, false):
		quit(2)
		return
	await _settle(instance)
	instance.herbarium_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-chives-herbarium-locked.png"):
		quit(2)
		return

	if not _prepare_phase83_chives_herbarium_state(instance, true):
		quit(2)
		return
	await _settle(instance)
	instance.herbarium_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-chives-herbarium-discovered.png"):
		quit(2)
		return
	instance._set_herbarium_open(false)

	if not _prepare_phase83_chives_shop_state(instance):
		quit(2)
		return
	instance.shop_catalog_scroll.scroll_vertical = 0
	await _settle(instance)
	var chives_shop_button := instance.shop_seed_buttons.get(CHIVES_SPECIES_ID) as Button
	instance.shop_catalog_scroll.ensure_control_visible(chives_shop_button)
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-chives-shop-stock.png"):
		quit(2)
		return

	if not _prepare_phase83_chives_room_state(instance):
		quit(2)
		return
	await _settle(instance)
	if not _save_full_viewport("comic-chives-room-mature.png"):
		quit(2)
		return

	if not _prepare_phase83_chives_detail_trait_state(instance):
		quit(2)
		return
	await _settle(instance)
	instance.plant_diagnosis_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-chives-detail-trait-active.png"):
		quit(2)
		return
	instance._set_plant_diagnosis_open(false)

	# Phase 84 Marjoram diagnostics are append-only and report-only. They do not
	# alter the approved manifest, reference PNGs, crops or pixel tolerances.
	if not _validate_phase84_marjoram_contract(instance):
		quit(2)
		return

	if not _prepare_phase84_marjoram_seed_selector_state(instance, false):
		quit(2)
		return
	await _settle(instance)
	instance.seed_selector_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-marjoram-seed-selector-locked.png"):
		quit(2)
		return

	if not _prepare_phase84_marjoram_seed_selector_state(instance, true):
		quit(2)
		return
	await _settle(instance)
	instance.seed_selector_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-marjoram-seed-selector-discovered.png"):
		quit(2)
		return
	instance._set_seed_selector_open(false)

	if not _prepare_phase84_marjoram_herbarium_state(instance, false):
		quit(2)
		return
	await _settle(instance)
	instance.herbarium_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-marjoram-herbarium-locked.png"):
		quit(2)
		return

	if not _prepare_phase84_marjoram_herbarium_state(instance, true):
		quit(2)
		return
	await _settle(instance)
	instance.herbarium_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-marjoram-herbarium-discovered.png"):
		quit(2)
		return
	instance._set_herbarium_open(false)

	if not _prepare_phase84_marjoram_shop_state(instance):
		quit(2)
		return
	instance.shop_catalog_scroll.scroll_vertical = 0
	await _settle(instance)
	var marjoram_shop_button := instance.shop_seed_buttons.get(MARJORAM_SPECIES_ID) as Button
	instance.shop_catalog_scroll.ensure_control_visible(marjoram_shop_button)
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-marjoram-shop-stock.png"):
		quit(2)
		return

	if not _prepare_phase84_marjoram_room_state(instance):
		quit(2)
		return
	await _settle(instance)
	if not _save_full_viewport("comic-marjoram-room-mature.png"):
		quit(2)
		return

	if not _prepare_phase84_marjoram_detail_trait_state(instance):
		quit(2)
		return
	await _settle(instance)
	instance.plant_diagnosis_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-marjoram-detail-trait-active.png"):
		quit(2)
		return
	instance._set_plant_diagnosis_open(false)

	# Phase 85 Parsley diagnostics are append-only and report-only. They do not
	# alter the approved manifest, reference PNGs, crops or pixel tolerances.
	if not _validate_phase85_parsley_contract(instance):
		quit(2)
		return

	if not _prepare_phase85_parsley_seed_selector_state(instance, false):
		quit(2)
		return
	await _settle(instance)
	instance.seed_selector_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-parsley-seed-selector-locked.png"):
		quit(2)
		return

	if not _prepare_phase85_parsley_seed_selector_state(instance, true):
		quit(2)
		return
	await _settle(instance)
	instance.seed_selector_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-parsley-seed-selector-discovered.png"):
		quit(2)
		return
	instance._set_seed_selector_open(false)

	if not _prepare_phase85_parsley_herbarium_state(instance, false):
		quit(2)
		return
	await _settle(instance)
	instance.herbarium_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-parsley-herbarium-locked.png"):
		quit(2)
		return

	if not _prepare_phase85_parsley_herbarium_state(instance, true):
		quit(2)
		return
	await _settle(instance)
	instance.herbarium_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-parsley-herbarium-discovered.png"):
		quit(2)
		return
	instance._set_herbarium_open(false)

	if not _prepare_phase85_parsley_shop_state(instance):
		quit(2)
		return
	instance.shop_catalog_scroll.scroll_vertical = 0
	await _settle(instance)
	var parsley_shop_button := instance.shop_seed_buttons.get(PARSLEY_SPECIES_ID) as Button
	instance.shop_catalog_scroll.ensure_control_visible(parsley_shop_button)
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-parsley-shop-stock.png"):
		quit(2)
		return

	if not _prepare_phase85_parsley_room_state(instance):
		quit(2)
		return
	await _settle(instance)
	if not _save_full_viewport("comic-parsley-room-mature.png"):
		quit(2)
		return

	if not _prepare_phase85_parsley_detail_trait_state(instance):
		quit(2)
		return
	await _settle(instance)
	instance.plant_diagnosis_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-parsley-detail-trait-active.png"):
		quit(2)
		return
	instance._set_plant_diagnosis_open(false)

	# Phase 86 Lemon Balm diagnostics are append-only and report-only. They run
	# after every Parsley frame and never alter approved references, crops,
	# masks, pixel tolerances or visual gate configuration.
	if not _validate_phase86_lemon_balm_contract(instance):
		quit(2)
		return

	if not _prepare_phase86_lemon_balm_seed_selector_state(instance, false):
		quit(2)
		return
	await _settle(instance)
	instance.seed_selector_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-lemon-balm-seed-selector-locked.png"):
		quit(2)
		return

	if not _prepare_phase86_lemon_balm_seed_selector_state(instance, true):
		quit(2)
		return
	await _settle(instance)
	instance.seed_selector_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-lemon-balm-seed-selector-discovered.png"):
		quit(2)
		return
	instance._set_seed_selector_open(false)

	if not _prepare_phase86_lemon_balm_herbarium_state(instance, false):
		quit(2)
		return
	await _settle(instance)
	instance.herbarium_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-lemon-balm-herbarium-locked.png"):
		quit(2)
		return

	if not _prepare_phase86_lemon_balm_herbarium_state(instance, true):
		quit(2)
		return
	await _settle(instance)
	instance.herbarium_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-lemon-balm-herbarium-discovered.png"):
		quit(2)
		return
	instance._set_herbarium_open(false)

	if not _prepare_phase86_lemon_balm_shop_state(instance):
		quit(2)
		return
	instance.shop_catalog_scroll.scroll_vertical = 0
	await _settle(instance)
	var lemon_balm_shop_button := instance.shop_seed_buttons.get(LEMON_BALM_SPECIES_ID) as Button
	instance.shop_catalog_scroll.ensure_control_visible(lemon_balm_shop_button)
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-lemon-balm-shop-stock.png"):
		quit(2)
		return

	if not _prepare_phase86_lemon_balm_room_state(instance):
		quit(2)
		return
	await _settle(instance)
	if not _save_full_viewport("comic-lemon-balm-room-mature.png"):
		quit(2)
		return

	if not _prepare_phase86_lemon_balm_detail_trait_state(instance):
		quit(2)
		return
	await _settle(instance)
	instance.plant_diagnosis_scroll.scroll_vertical = 4096
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-lemon-balm-detail-trait-active.png"):
		quit(2)
		return
	instance._set_plant_diagnosis_open(false)

	# Fáze 92: nové snímky jsou pouze diagnostické a záměrně se přidávají až
	# za všechny existující schválené i report-only případy. Nejsou součástí
	# manifestu referencí, masek ani tolerancí.
	for page_number in range(1, 4):
		_prepare_phase92_garden_handover_state(instance, page_number)
		await _settle(instance)
		if not _save_full_viewport("comic-garden-handover-%d.png" % page_number):
			quit(2)
			return
	_finish_phase92_garden_handover_state(instance)
	_prepare_phase92_herbarium_completion_state(instance)
	await _settle(instance)
	if not _save_full_viewport("comic-herbarium-completion.png"):
		quit(2)
		return
	instance._set_herbarium_open(false)

	# Fáze 93: Profesorova výzkumná kapitola je zatím pouze report-only.
	# Oba snímky jsou připojené až za schváleným a starším report-only blokem,
	# aby nezměnily ani refy ani tolerance stávajících vizuálních kontraktů.
	if not _prepare_phase93_professor_story_active_state(instance):
		quit(2)
		return
	await _settle(instance)
	instance.professor_story_scroll.scroll_vertical = 4096
	await process_frame
	if not _save_full_viewport("comic-professor-research-active.png"):
		quit(2)
		return
	if not _prepare_phase93_professor_story_ready_state(instance):
		quit(2)
		return
	await _settle(instance)
	instance.professor_story_scroll.scroll_vertical = 0
	await process_frame
	if not _save_full_viewport("comic-professor-research-ready.png"):
		quit(2)
		return

	# Phase 95 remains append-only and report-only. These frames are intentionally
	# after Phase 93 and never alter the approved manifest, references, crops,
	# masks, tolerances or visual-gate configuration.
	if not _validate_phase95_sage_contract(instance):
		quit(2)
		return

	if not _prepare_phase95_sage_seed_selector_state(instance, false):
		quit(2)
		return
	await _settle(instance)
	var sage_seed_button := instance.seed_species_buttons.get(SAGE_SPECIES_ID) as Button
	instance.seed_selector_scroll.ensure_control_visible(sage_seed_button)
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-sage-seed-selector-locked.png"):
		quit(2)
		return

	if not _prepare_phase95_sage_seed_selector_state(instance, true):
		quit(2)
		return
	await _settle(instance)
	sage_seed_button = instance.seed_species_buttons.get(SAGE_SPECIES_ID) as Button
	instance.seed_selector_scroll.ensure_control_visible(sage_seed_button)
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-sage-seed-selector-discovered.png"):
		quit(2)
		return
	instance._set_seed_selector_open(false)

	if not _prepare_phase95_sage_herbarium_state(instance, false):
		quit(2)
		return
	await _settle(instance)
	var sage_card: Dictionary = instance.herbarium_cards.get(SAGE_SPECIES_ID, {})
	instance.herbarium_scroll.ensure_control_visible(sage_card.get("panel") as Control)
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-sage-herbarium-locked.png"):
		quit(2)
		return

	if not _prepare_phase95_sage_herbarium_state(instance, true):
		quit(2)
		return
	await _settle(instance)
	sage_card = instance.herbarium_cards.get(SAGE_SPECIES_ID, {})
	instance.herbarium_scroll.ensure_control_visible(sage_card.get("panel") as Control)
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-sage-herbarium-discovered.png"):
		quit(2)
		return
	instance._set_herbarium_open(false)

	if not _prepare_phase95_sage_shop_state(instance):
		quit(2)
		return
	await _settle(instance)
	var sage_shop_button := instance.shop_seed_buttons.get(SAGE_SPECIES_ID) as Button
	instance.shop_catalog_scroll.ensure_control_visible(sage_shop_button)
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-sage-shop-stock.png"):
		quit(2)
		return

	if not _prepare_phase95_sage_room_state(instance):
		quit(2)
		return
	await _settle(instance)
	if not _save_full_viewport("comic-sage-room-mature.png"):
		quit(2)
		return

	if not _prepare_phase95_sage_detail_trait_state(instance):
		quit(2)
		return
	await _settle(instance)
	var sage_behavior_card := _find_diagnosis_behavior_card(instance)
	if sage_behavior_card != null:
		instance.plant_diagnosis_scroll.ensure_control_visible(sage_behavior_card)
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-sage-detail-trait-active.png"):
		quit(2)
		return
	instance._set_plant_diagnosis_open(false)

	if not _prepare_phase95_professor_story_active_state(instance):
		quit(2)
		return
	await _settle(instance)
	var last_story_card: Dictionary = instance.professor_story_cards.get(4, {})
	instance.professor_story_scroll.ensure_control_visible(last_story_card.get("panel") as Control)
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-professor-silver-sage-active.png"):
		quit(2)
		return

	if not _prepare_phase95_professor_story_ready_state(instance):
		quit(2)
		return
	await _settle(instance)
	instance.professor_story_scroll.scroll_vertical = 0
	await process_frame
	if not _save_full_viewport("comic-professor-silver-sage-ready.png"):
		quit(2)
		return

	# Phase 96 remains append-only and report-only. The board fixture is placed
	# after every Phase 95 frame and does not change approved references, crops,
	# masks, tolerances or any existing visual gate.
	if not _prepare_phase96_herbal_blend_order_state(instance):
		quit(2)
		return
	await _settle(instance)
	instance.storage_scroll.scroll_vertical = 620
	await process_frame
	await process_frame
	if not _save_full_viewport("comic-herbal-blend-order.png"):
		quit(2)
		return

	# Phase 97 remains append-only and report-only. Its three finale states and
	# completed journal are captured only after the Phase 96 blend board, while
	# all existing references, manifest entries, tolerances and gates stay intact.
	if not _prepare_phase97_professor_exhibition_state(instance, "active"):
		quit(2)
		return
	last_story_card = instance.professor_story_cards.get(4, {})
	var phase97_capture_ok := await _capture_phase97_overlay(
		instance,
		instance.professor_story_modal,
		instance.professor_story_scroll,
		last_story_card.get("panel") as Control,
		"comic-professor-exhibition-active.png"
	)
	if not phase97_capture_ok:
		quit(2)
		return

	if not _prepare_phase97_professor_exhibition_state(instance, "ready"):
		quit(2)
		return
	phase97_capture_ok = await _capture_phase97_overlay(
		instance,
		instance.professor_story_modal,
		instance.professor_story_scroll,
		null,
		"comic-professor-exhibition-ready.png"
	)
	if not phase97_capture_ok:
		quit(2)
		return

	if not _prepare_phase97_professor_exhibition_claimed_state(instance):
		quit(2)
		return
	phase97_capture_ok = await _capture_phase97_overlay(
		instance,
		instance.professor_story_modal,
		instance.professor_story_scroll,
		null,
		"comic-professor-exhibition-claimed.png"
	)
	if not phase97_capture_ok:
		quit(2)
		return

	if not _prepare_phase97_herbarium_master_journal_state(instance):
		quit(2)
		return
	var herbarium_master_card: Dictionary = instance.grower_journal_cards.get("herbarium_master", {})
	phase97_capture_ok = await _capture_phase97_overlay(
		instance,
		instance.grower_journal_modal,
		instance.grower_journal_scroll,
		herbarium_master_card.get("panel") as Control,
		"comic-grower-journal-herbarium-master.png"
	)
	if not phase97_capture_ok:
		quit(2)
		return

	# Phase 98 is append-only and report-only. The repeatable protocol reuses the
	# existing five-card Professor overlay and does not add a reference, crop,
	# mask, tolerance or gate to the approved visual manifest.
	if not _prepare_phase98_professor_research_state(instance, "active"):
		quit(2)
		return
	last_story_card = instance.professor_story_cards.get(4, {})
	var phase98_capture_ok := await _capture_phase97_overlay(
		instance,
		instance.professor_story_modal,
		instance.professor_story_scroll,
		last_story_card.get("panel") as Control,
		"comic-professor-weekly-research-active.png"
	)
	if not phase98_capture_ok:
		quit(2)
		return

	if not _prepare_phase98_professor_research_state(instance, "ready"):
		quit(2)
		return
	phase98_capture_ok = await _capture_phase97_overlay(
		instance,
		instance.professor_story_modal,
		instance.professor_story_scroll,
		null,
		"comic-professor-weekly-research-ready.png"
	)
	if not phase98_capture_ok:
		quit(2)
		return

	if not _prepare_phase98_professor_research_state(instance, "cooldown"):
		quit(2)
		return
	phase98_capture_ok = await _capture_phase97_overlay(
		instance,
		instance.professor_story_modal,
		instance.professor_story_scroll,
		null,
		"comic-professor-weekly-research-cooldown.png"
	)
	if not phase98_capture_ok:
		quit(2)
		return

	if not _prepare_phase99_professor_research_variant(instance, 0, "variant_balanced"):
		quit(2)
		return
	var phase99_capture_ok := await _capture_phase97_overlay(
		instance,
		instance.professor_story_modal,
		instance.professor_story_scroll,
		null,
		"comic-professor-weekly-research-variant-balanced.png"
	)
	if not phase99_capture_ok:
		quit(2)
		return

	if not _prepare_phase99_professor_research_variant(instance, 1, "variant_quality"):
		quit(2)
		return
	phase99_capture_ok = await _capture_phase97_overlay(
		instance,
		instance.professor_story_modal,
		instance.professor_story_scroll,
		null,
		"comic-professor-weekly-research-variant-quality.png"
	)
	if not phase99_capture_ok:
		quit(2)
		return

	if not _prepare_phase99_professor_research_variant(instance, 2, "variant_processing"):
		quit(2)
		return
	phase99_capture_ok = await _capture_phase97_overlay(
		instance,
		instance.professor_story_modal,
		instance.professor_story_scroll,
		null,
		"comic-professor-weekly-research-variant-processing.png"
	)
	if not phase99_capture_ok:
		quit(2)
		return

	instance._prepare_research_study_showroom_locked_capture()
	await _settle(instance)
	if not _save_full_viewport("comic-cosmetic-showroom-research-study-locked.png"):
		quit(2)
		return
	instance._finish_research_study_showroom_capture()

	if not instance._prepare_research_study_showroom_selected_capture():
		quit(2)
		return
	await _settle(instance)
	if not _save_full_viewport("comic-cosmetic-showroom-research-study-selected.png"):
		quit(2)
		return
	instance._finish_research_study_showroom_capture()

	instance.queue_free()
	await process_frame
	await process_frame
	instance = null
	packed = null
	room_image = null
	hud_image = null
	call_deferred("_finish_capture_success")


func _finish_capture_success() -> void:
	# Quit only after _capture() has returned, so its local Images, PackedScene
	# and coroutine state are released before renderer/ObjectDB shutdown.
	print("HOW_TO_GROW_CAPTURE=PASSED")
	print("HOW_TO_GROW_CAPTURE_DIR=%s" % output_directory)
	quit(0)


func _prepare_common_state(instance) -> void:
	for plant in instance.session.plants:
		plant.reset()
		plant.configure_profile(instance.profile)
	instance.session.coins = 6
	instance.session.set_seed_count("basil_genovese", 1)
	instance.session.set_seed_count("mint_peppermint", 0)
	instance.session.set_seed_count("rosemary_officinalis", 0)
	instance.session.set_seed_count("oregano_vulgare", 0)
	instance.session.fertilizer_doses = 2
	instance.session.harvest_count = 0
	instance.session.speed_multiplier = 1.0
	instance.session.paused = true
	instance.session.world_elapsed_seconds = 0.0
	instance.session.daily_challenge_issued_day = -1
	instance.session.daily_challenge_id = ""
	instance.session.daily_challenge_completed = false
	instance.session.daily_challenge_claimed = false
	instance.session._ensure_daily_challenge()
	instance.session.intro_completed = true
	instance.session.chart_samples.clear()
	instance.is_garden_handover_active = false
	instance.return_to_herbarium_after_handover = false
	instance.garden_handover_presenter.reset()
	instance._apply_normal_guide_mode()
	instance._set_guide_modal_open(false, false)
	instance._set_herbarium_open(false)
	instance._set_daily_challenge_open(false)
	instance._set_botanical_pack_open(false)
	instance._set_level_progression_open(false)
	instance._set_grower_journal_open(false)
	instance._set_care_center_open(false)
	instance._set_cosmetic_modal_open(false)
	instance._close_return_summary()
	instance.herbarium_launcher_button.visible = false
	instance.last_coins_seen = instance.session.coins
	instance.plant_view.set_paused(true)
	instance.room_overview.set_paused(true)
	instance._change_screen(0)
	instance._open_room()


func _prepare_phase92_garden_handover_state(instance, page_number: int) -> void:
	if instance.is_garden_handover_active:
		instance._skip_garden_handover()
	instance._set_guide_modal_open(false, false)
	instance._set_settings_modal_open(false)
	instance._set_seed_selector_open(false)
	instance._set_herbarium_open(false)
	instance._set_daily_challenge_open(false)
	instance._set_botanical_pack_open(false)
	instance._set_level_progression_open(false)
	instance._set_grower_journal_open(false)
	instance._set_care_center_open(false)
	instance._set_cosmetic_modal_open(false)
	instance._close_return_summary()
	instance.session.intro_completed = true
	instance.session.reduced_motion = true
	instance._apply_motion_preference()
	instance._change_screen(0)
	instance._open_room()
	instance._start_garden_handover(true)
	for _step in range(clampi(page_number, 1, 3) - 1):
		instance._progress_garden_handover()
	var state: Dictionary = instance.garden_handover_presenter.state()
	instance.guide_modal_character.set_capture_state(int(state.get("mood", GuideCharacter.Mood.EXPLAIN)), 0.28 + float(page_number) * 0.11)
	instance._set_guide_modal_open(true, false)
	instance.guide_modal.set_meta("capture_state", "phase92_garden_handover_page_%d_report_only_v1" % page_number)


func _finish_phase92_garden_handover_state(instance) -> void:
	if instance.is_garden_handover_active:
		instance._skip_garden_handover()
	instance._set_guide_modal_open(false, false)
	instance._set_herbarium_open(false)
	instance.guide_modal_character.resume_live_animation()


func _prepare_phase92_herbarium_completion_state(instance) -> void:
	for species_id in instance.session.get_collection_species_ids():
		instance.session._discover_species(species_id)
	instance._set_guide_modal_open(false, false)
	instance._set_herbarium_open(true)
	instance._refresh_herbarium()
	instance.herbarium_scroll.scroll_vertical = 0
	instance.herbarium_modal.set_meta("capture_state", "phase92_herbarium_completion_report_only_v1")


func _prepare_professor_story_common_state(instance) -> bool:
	instance._set_guide_modal_open(false, false)
	instance._set_settings_modal_open(false)
	instance._set_seed_selector_open(false)
	instance._set_herbarium_open(false)
	instance._set_daily_challenge_open(false)
	instance._set_botanical_pack_open(false)
	instance._set_level_progression_open(false)
	instance._set_grower_journal_open(false)
	instance._set_care_center_open(false)
	instance._set_cosmetic_modal_open(false)
	instance._close_return_summary()
	instance._set_professor_story_open(false)
	instance._set_plant_diagnosis_open(false)
	instance.session.journey_completed = true
	for species_id in instance.session.get_collection_species_ids():
		instance.session._discover_species(species_id)
	instance._refresh_ui()
	return true


func _prepare_phase93_professor_story_active_state(instance) -> bool:
	if not _prepare_professor_story_common_state(instance):
		return false
	var quality_species: Array[String] = []
	var collection_species: Array[String] = instance.session.get_available_species()
	if not collection_species.is_empty():
		quality_species.append(collection_species[0])
	var chapter_state := {
		"seen": false,
		"claimed": false,
		"patient_return_completed": true,
		"quality_species": quality_species,
		"specific_order_completed": false,
		"specific_order_species_id": "",
		"daily_claim_days": [1],
	}
	instance.session.professor_story.load_state(
		{PROFESSOR_STORY_CHAPTER_ID: chapter_state},
		PROFESSOR_STORY_CHAPTER_ID,
		true,
		true,
		instance.session.get_available_species()
	)
	instance.professor_story_open = false
	instance.professor_story_modal.set_meta("capture_state", "phase93_professor_story_active_report_only_v1")
	instance._set_professor_story_open(true)
	return instance.professor_story_modal.visible


func _prepare_phase93_professor_story_ready_state(instance) -> bool:
	var collection_species: Array[String] = instance.session.get_available_species()
	if collection_species.is_empty():
		push_error("Phase 93 professor story ready capture requires at least one species.")
		return false
	var discovered_target: int = mini(5, collection_species.size())
	var discovery_species: Array[String] = []
	var quality_species: Array[String] = []
	for species_id in collection_species:
		if quality_species.size() < 2:
			quality_species.append(species_id)
		if discovery_species.size() < discovered_target:
			discovery_species.append(species_id)
	if quality_species.size() < 2:
		push_error("Phase 93 professor story ready capture requires two available species for quality progress.")
		return false
	var chapter_state := {
		"seen": true,
		"claimed": false,
		"patient_return_completed": true,
		"quality_species": quality_species,
		"specific_order_completed": true,
		"specific_order_species_id": collection_species[0] if not collection_species.is_empty() else "",
		"daily_claim_days": [1, 2],
	}
	instance.session.professor_story.load_state(
		{PROFESSOR_STORY_CHAPTER_ID: chapter_state},
		PROFESSOR_STORY_CHAPTER_ID,
		true,
		true,
		instance.session.get_available_species()
	)
	for species_id in discovery_species:
		instance.session._discover_species(species_id)
	instance._refresh_ui()
	instance.professor_story_modal.set_meta("capture_state", "phase93_professor_story_ready_report_only_v1")
	instance.professor_story_scroll.scroll_vertical = 0
	instance._refresh_professor_story()
	return instance.professor_story_modal.visible


func _prepare_phase95_professor_story_active_state(instance) -> bool:
	return _prepare_phase95_professor_story_state(instance, false)


func _prepare_phase95_professor_story_ready_state(instance) -> bool:
	return _prepare_phase95_professor_story_state(instance, true)


func _prepare_phase95_professor_story_state(instance, ready: bool) -> bool:
	if not _prepare_professor_story_common_state(instance):
		return false
	var collection_species: Array[String] = instance.session.get_available_species()
	if collection_species.size() < 7 or SAGE_SPECIES_ID not in collection_species:
		push_error("Phase 95 professor story capture requires Sage and at least seven available species.")
		return false
	for index in range(collection_species.size()):
		var species_id := collection_species[index]
		var progress: Dictionary = instance.session.get_species_progress(species_id)
		progress["discovered"] = index < 7 or species_id == SAGE_SPECIES_ID
		if index == 0:
			progress["harvests"] = 3
			progress["best_quality"] = 0.82
			progress["orders_completed"] = 1
		instance.session.species_progress[species_id] = progress
	instance.session.set_seed_count(SAGE_SPECIES_ID, 0)
	var quality_species: Array[String] = []
	var order_species: Array[String] = []
	for species_id in collection_species:
		if quality_species.size() < (3 if ready else 2):
			quality_species.append(species_id)
		if order_species.size() < (2 if ready else 1):
			order_species.append(species_id)
	var first_chapter_state := {
		"seen": true,
		"claimed": true,
		"patient_return_completed": true,
		"quality_species": collection_species.slice(0, 2),
		"specific_order_completed": true,
		"specific_order_species_id": collection_species[0],
		"daily_claim_days": [1, 2],
	}
	var second_chapter_state := {
		"seen": false,
		"claimed": false,
		"quality_species": quality_species,
		"specific_order_species": order_species,
		"pack_opened": ready,
	}
	instance.session.professor_story.load_state(
		{
			PROFESSOR_STORY_CHAPTER_ID: first_chapter_state,
			PROFESSOR_STORY_CHAPTER_TWO_ID: second_chapter_state,
		},
		PROFESSOR_STORY_CHAPTER_TWO_ID,
		true,
		24,
		collection_species
	)
	instance.session._sync_professor_story_storage()
	instance._refresh_ui()
	var state: Dictionary = instance.session.get_professor_story_state()
	var expected_status := "ready" if ready else "active"
	if str(state.get("chapter_id", "")) != PROFESSOR_STORY_CHAPTER_TWO_ID \
			or str(state.get("status", "")) != expected_status \
			or (ready and not bool(state.get("can_claim", false))) \
			or (not ready and bool(state.get("can_claim", false))):
		push_error("Phase 95 professor story fixture did not resolve the requested chapter-two state.")
		return false
	if instance.professor_story_cards.size() != 5 \
			or str(instance.professor_story_scroll.get_meta("scroll_contract", "")) != "five_story_goal_cards_v1":
		push_error("Phase 95 professor story modal must retain its single five-card contract.")
		return false
	instance.professor_story_open = false
	instance.professor_story_modal.set_meta(
		"capture_state",
		"phase95_professor_silver_sage_ready_report_only_v1" if ready else "phase95_professor_silver_sage_active_report_only_v1"
	)
	instance._set_professor_story_open(true)
	instance._refresh_professor_story()
	if not instance.professor_story_modal.visible \
			or instance.professor_story_chapter_title_label.text != "ODKAZ STŘÍBRNÉ ŠALVĚJE" \
			or str(instance.professor_story_action.get("expected_chapter_id", "")) != PROFESSOR_STORY_CHAPTER_TWO_ID:
		push_error("Phase 95 professor story presenter did not bind chapter two safely.")
		return false
	if ready and ("100 mincí" not in instance.professor_story_reward_label.text \
			or "2× semínko šalvěje" not in instance.professor_story_reward_label.text):
		push_error("Phase 95 professor story ready reward copy is not domain-driven.")
		return false
	return true


func _prepare_phase78_botanical_pack_state(instance) -> void:
	instance._set_guide_modal_open(false, false)
	instance._set_settings_modal_open(false)
	instance._set_seed_selector_open(false)
	instance._set_herbarium_open(false)
	instance._set_daily_challenge_open(false)
	instance.session.pending_botanical_packs.clear()
	instance.session.next_botanical_pack_id = 1
	instance.session.botanical_pack_rng_state = GameSession.BOTANICAL_PACK_DEFAULT_RNG_STATE
	instance.session.botanical_pack_pity = 1
	instance.session._grant_botanical_pack("capture", "phase78", false)
	instance._set_botanical_pack_open(true)
	instance.botanical_pack_modal.set_meta("capture_state", "phase78_botanical_pack_diagnostic_v1")


func _prepare_locked_state(instance) -> void:
	for plant in instance.session.plants:
		plant.reset()
		plant.configure_profile(instance.profile)
	instance.session.xp = 0
	instance.last_xp_seen = 0
	instance.session.select_plant(0)
	instance.session.world_elapsed_seconds = 0.0
	for plant in instance.session.plants:
		plant.sync_environment(instance.session.world_elapsed_seconds)
	instance.room_overview.previous_unlocked_count = 1
	instance.room_overview.displayed_growth_percent = 0.0
	instance.room_overview.refresh()
	instance._refresh_ui()


func _prepare_room_state(instance) -> void:
	instance.session.selected_room_theme = "sunrise"
	for plant in instance.session.plants:
		plant.reset()
		plant.configure_profile(instance.profile)
	instance.session.xp = 300
	instance.last_xp_seen = 300
	_set_stage(instance.session.plants[0], PlantSimulation.Stage.SPROUT, 18.0, 96.0, 3.0)
	instance.session.plants[0].moisture = 31.0
	_set_stage(instance.session.plants[1], PlantSimulation.Stage.VEGETATIVE, 48.0, 82.0, 6.0)
	instance.session.plants[1].lamp_on = true
	_set_stage(instance.session.plants[2], PlantSimulation.Stage.MATURE, 73.0, 91.0, 9.0)
	_set_stage(instance.session.plants[3], PlantSimulation.Stage.MATURE, 100.0, 94.0, 12.0)
	instance.session.plants[3].moisture = 31.0
	instance.session.select_plant(2)
	# Legacy approved frames showed DEN 10 from the selected plant age, while
	# their environment was still the freshly reset day-zero state.
	instance.session.world_elapsed_seconds = 0.0
	for plant in instance.session.plants:
		plant.sync_environment(instance.session.world_elapsed_seconds)
	# Preserve the explicitly authored legacy visual fixture after the new global
	# environment sync. This is capture-only; runtime scores remain calculated.
	instance.session.plants[0].condition_score = 0.96
	instance.session.plants[1].condition_score = 0.82
	instance.session.plants[2].condition_score = 0.91
	instance.session.plants[3].condition_score = 0.94
	instance.room_overview.previous_unlocked_count = 4
	instance.room_overview.displayed_growth_percent = 73.0
	instance.room_overview.refresh()
	instance._refresh_ui()
	instance._set_day_display(10)


func _prepare_phase103_player_room_state(instance) -> void:
	instance.session.unlocked_room_themes.assign(["sunrise", "amethyst"])
	instance.session.selected_room_theme = "amethyst"
	instance._open_player_room()
	instance.player_room_view.set_cosmetic_theme("amethyst")
	instance.player_room_view.set_meta("capture_state", "phase103_player_room_amethyst_report_only_v1")


func _prepare_phase104_decorated_player_room_state(instance) -> void:
	instance.session.unlocked_room_themes.assign(["sunrise", "amethyst"])
	instance.session.selected_room_theme = "amethyst"
	instance.session.coins = 84
	instance.session.owned_room_decorations.assign([
		"mini_monstera",
		"botanical_books",
		"golden_lamp",
		"room_fern",
		"flowering_begonia",
	])
	instance.session.room_decoration_slots.assign([
		"mini_monstera",
		"botanical_books",
		"golden_lamp",
		"room_fern",
		"flowering_begonia",
	])
	instance._open_player_room()
	instance.player_room_view.set_cosmetic_theme("amethyst")
	instance.player_room_view.set_room_decorations(instance.session.get_room_decoration_slots(), GameSession.ROOM_DECORATIONS)
	instance.player_room_view.set_meta("capture_state", "phase104_player_room_decorated_report_only_v1")


func _prepare_phase104_decoration_shop_state(instance) -> void:
	_prepare_phase104_decorated_player_room_state(instance)
	instance._open_room_decoration_modal(2)
	instance.room_decoration_modal.set_meta("capture_state", "phase104_room_decoration_shop_report_only_v1")


func _prepare_phase105_greenhouse_empty_state(instance) -> void:
	instance.session.greenhouse.reset()
	_sync_capture_coin_hud(instance)
	instance._open_greenhouse()
	instance._refresh_greenhouse_view()
	instance.greenhouse_preview_view.set_meta("capture_state", "phase105_greenhouse_empty_report_only_v1")


func _prepare_phase105_greenhouse_growing_state(instance) -> void:
	instance.session.greenhouse.reset()
	instance.session.coins = maxi(instance.session.coins, 10)
	instance.session.perform_greenhouse_bed_action(0)
	instance.session.perform_greenhouse_bed_action(0)
	instance.session.greenhouse.advance(10800.0)
	_sync_capture_coin_hud(instance)
	instance._open_greenhouse()
	instance._refresh_greenhouse_view()
	instance.greenhouse_preview_view.select_bed(0)
	instance.greenhouse_preview_view.set_meta("capture_state", "phase105_greenhouse_growing_report_only_v1")


func _prepare_phase105_greenhouse_ready_state(instance) -> void:
	instance.session.greenhouse.advance(10800.0)
	_sync_capture_coin_hud(instance)
	instance._open_greenhouse()
	instance._refresh_greenhouse_view()
	instance.greenhouse_preview_view.select_bed(0)
	instance.greenhouse_preview_view.set_meta("capture_state", "phase105_greenhouse_ready_report_only_v1")


func _prepare_phase106_greenhouse_pepper_state(instance) -> void:
	instance.session.greenhouse.reset()
	instance.session.xp = maxi(instance.session.xp, 100)
	instance.session.coins = maxi(instance.session.coins, 14)
	instance.session.plant_greenhouse_crop(1, "sweet_pepper")
	instance.session.perform_greenhouse_bed_action(1)
	instance.session.greenhouse.advance(21600.0)
	_sync_capture_coin_hud(instance)
	instance._open_greenhouse()
	instance._refresh_greenhouse_view()
	instance.greenhouse_preview_view.select_bed(1)
	instance.greenhouse_preview_view.set_meta("capture_state", "phase106_greenhouse_pepper_growing_report_only_v1")


func _prepare_phase107_greenhouse_locked_state(instance) -> void:
	instance.session.greenhouse.reset()
	instance.session.xp = 0
	instance.session.coins = maxi(instance.session.coins, 18)
	_sync_capture_coin_hud(instance)
	instance._open_greenhouse()
	instance._refresh_greenhouse_view()
	instance.greenhouse_preview_view.select_bed(0)
	instance.greenhouse_preview_view.set_meta("capture_state", "phase107_greenhouse_locked_crops_report_only_v1")


func _prepare_phase107_greenhouse_cucumber_state(instance) -> void:
	instance.session.greenhouse.reset()
	instance.session.xp = 300
	instance.session.coins = maxi(instance.session.coins, 18)
	instance.session.plant_greenhouse_crop(2, "salad_cucumber")
	instance.session.perform_greenhouse_bed_action(2)
	instance.session.greenhouse.advance(27000.0)
	_sync_capture_coin_hud(instance)
	instance._open_greenhouse()
	instance._refresh_greenhouse_view()
	instance.greenhouse_preview_view.select_bed(2)
	instance.greenhouse_preview_view.set_meta("capture_state", "phase107_greenhouse_cucumber_growing_report_only_v1")


func _capture_phase109_greenhouse_level2_compact(instance) -> bool:
	var previous_content_scale_size: Vector2i = root.content_scale_size
	root.content_scale_size = Vector2i(360, 800)
	await process_frame
	await process_frame
	_prepare_phase109_greenhouse_level2_state(instance)
	await _settle(instance)
	var greenhouse = instance.greenhouse_preview_view
	var capture_valid: bool = (
		greenhouse.size == Vector2(360.0, 620.0)
		and greenhouse.get_meta("responsive_layout_component", "") == "phase109_greenhouse_compact_layout_v1"
		and greenhouse.crop_buttons.size() == 3
		and greenhouse.crop_buttons[0].visible
		and not greenhouse.crop_buttons[0].disabled
		and greenhouse.crop_buttons[1].visible
		and not greenhouse.crop_buttons[1].disabled
		and greenhouse.crop_buttons[2].visible
		and greenhouse.crop_buttons[2].disabled
		and "OD ÚR. 4" in greenhouse.crop_buttons[2].text
	)
	if not capture_valid:
		push_error("Phase 109 compact capture did not render exact 360x620 content with level-2 tomato, pepper and locked cucumber choices.")
	else:
		capture_valid = _save_full_viewport("comic-greenhouse-level2-compact.png")
	root.content_scale_size = previous_content_scale_size
	await process_frame
	await process_frame
	instance.session.greenhouse.reset()
	instance._refresh_greenhouse_view()
	instance._refresh_rack_greenhouse_attention()
	return capture_valid


func _prepare_phase109_greenhouse_level2_state(instance) -> void:
	instance.session.greenhouse.reset()
	instance.session.xp = 100
	instance.session.coins = maxi(instance.session.coins, 100)
	_sync_capture_coin_hud(instance)
	instance._open_greenhouse()
	instance._refresh_greenhouse_view()
	instance.greenhouse_preview_view.select_bed(0)
	instance.greenhouse_preview_view.set_meta("capture_state", "phase109_greenhouse_level2_compact_report_only_v1")


func _prepare_phase109_return_summary_greenhouse_state(instance) -> bool:
	instance._finish_return_summary_capture()
	instance.session.greenhouse.reset()
	instance.session.xp = 100
	instance.session.coins = maxi(instance.session.coins, 100)
	if not instance.session.plant_greenhouse_crop(2, "cherry_tomato") \
			or not instance.session.perform_greenhouse_bed_action(2):
		push_error("Phase 109 return-summary capture could not prepare a growing greenhouse crop.")
		return false
	var coins_before_maturity: int = instance.session.coins
	var xp_before_maturity: int = instance.session.xp
	if not is_equal_approx(instance.session.advance_offline(21600.0), 21600.0):
		push_error("Phase 109 return-summary capture did not apply the exact offline interval.")
		return false
	var lifecycle_events: Array[Dictionary] = instance.session.consume_offline_lifecycle_events()
	var greenhouse_events: Array[Dictionary] = []
	for lifecycle_event in lifecycle_events:
		if str(lifecycle_event.get("kind", "")) == "greenhouse_ready":
			greenhouse_events.append(lifecycle_event)
	if greenhouse_events.size() != 1 \
			or int(greenhouse_events[0].get("bed_number", -1)) != 3 \
			or instance.session.coins != coins_before_maturity \
			or instance.session.xp != xp_before_maturity:
		push_error("Phase 109 return-summary capture did not preserve the one-shot no-reward greenhouse event contract.")
		return false
	instance._change_screen(0)
	instance._open_rack_location()
	instance._refresh_rack_greenhouse_attention()
	instance.return_summary_presenter.refresh(21600.0, "Jasno", "Zkontroluj zahradu", greenhouse_events)
	instance.return_summary_open = true
	instance.return_summary_modal.visible = true
	instance.return_summary_modal.move_to_front()
	instance.return_summary_modal.set_meta("capture_state", "phase109_greenhouse_return_summary_report_only_v1")
	var cta_found := false
	for child in instance.return_summary_modal.find_children("*", "Button", true, false):
		if child.get_meta("component", "") == "phase109_return_summary_garden_cta_v1":
			cta_found = child.text == "ZKONTROLOVAT ZAHRADU" and child.size.y >= 68.0
			break
	if not cta_found \
			or "Skleník · záhon 3 · CHERRY RAJČE · PŘIPRAVENO KE SKLIZNI" not in instance.return_summary_label.text:
		push_error("Phase 109 return-summary capture is missing its greenhouse line or garden CTA.")
		return false
	return true


func _prepare_phase109_rack_attention_state(instance) -> bool:
	instance._finish_return_summary_capture()
	if not instance.session.plant_greenhouse_crop(1, "sweet_pepper"):
		push_error("Phase 109 rack-attention capture could not prepare a needs-water pepper bed.")
		return false
	instance._change_screen(0)
	instance._open_rack_location()
	instance._refresh_rack_greenhouse_attention()
	var attention: Dictionary = instance.session.get_greenhouse_attention_summary()
	if int(attention.get("needs_water", -1)) != 1 \
			or int(attention.get("ready", -1)) != 1 \
			or int(attention.get("action_count", -1)) != 2 \
			or instance.rack_greenhouse_button.size != Vector2(124.0, 64.0) \
			or instance.rack_greenhouse_button.text != "←  SKLENÍK\n2 AKCE":
		push_error("Phase 109 rack-attention capture did not render the exact derived two-action 124x64 badge.")
		return false
	instance.plants_room_panel.set_meta("capture_state", "phase109_rack_greenhouse_attention_report_only_v1")
	return true


func _finish_phase109_rack_attention_state(instance) -> void:
	instance.session.greenhouse.reset()
	instance._refresh_greenhouse_view()
	instance._refresh_rack_greenhouse_attention()
	instance.plants_room_panel.remove_meta("capture_state")


func _sync_capture_coin_hud(instance) -> void:
	instance.last_coins_seen = instance.session.coins
	instance._set_coin_count(float(instance.session.coins))
	instance.last_xp_seen = -1
	instance._refresh_xp_display()


func _prepare_hud_state(instance) -> void:
	instance._open_room()
	instance.session.xp = 209
	instance.last_xp_seen = 209
	instance.session.select_plant(2)
	instance._refresh_ui()


func _prepare_phase5_storage_state(instance) -> void:
	_prepare_room_state(instance)
	instance.customer_orders_panel.visible = false
	instance._change_screen(1)
	instance._refresh_ui()
	instance.storage_scroll.scroll_vertical = 0


func _prepare_phase10_order_state(instance) -> void:
	_prepare_room_state(instance)
	var plant = instance.session.plant
	plant.stage = PlantSimulation.Stage.PACKAGED
	plant.growth_percent = 100.0
	plant.fresh_harvest_g = 32.0
	plant.dry_harvest_g = 5.4
	plant.harvest_quality = 0.91
	instance.customer_orders_panel.visible = true
	instance._prepare_customer_orders_capture()


func _prepare_phase6_guide_state(instance, mood: int, message: String, fixed_time: float) -> void:
	instance._change_screen(0)
	instance._open_room()
	instance._prepare_guide_capture(mood, message, fixed_time)


func _prepare_phase5_shop_state(instance) -> void:
	instance.session.coins = 42
	if instance.coin_count_tween != null and instance.coin_count_tween.is_valid():
		instance.coin_count_tween.kill()
	instance.last_coins_seen = 42
	instance._set_coin_count(42.0)
	instance.session.set_seed_count("basil_genovese", 3)
	instance.session.set_seed_count("mint_peppermint", 0)
	instance.session.fertilizer_doses = 2
	instance.session.shop_stock_day = int(floor(Time.get_unix_time_from_system() / GameSession.SHOP_REAL_DAY_SECONDS))
	instance.session.shop_stock = {
		instance.session.get_shop_seed_item_id("basil_genovese"): 3,
		instance.session.get_shop_seed_item_id("mint_peppermint"): 2,
		instance.session.get_shop_seed_item_id("rosemary_officinalis"): 1,
		instance.session.get_shop_seed_item_id("oregano_vulgare"): 1,
		GameSession.SHOP_FERTILIZER_ITEM_ID: 3,
	}
	instance._set_shop_legacy_capture(true)
	instance.mint_shop_card.visible = false
	instance.rosemary_shop_card.visible = false
	instance.oregano_shop_card.visible = false
	instance._change_screen(2)
	instance._refresh_ui()


func _prepare_botanist_shop_sell_state(instance) -> void:
	instance._set_shop_legacy_capture(false)
	var plant: PlantSimulation = instance.session.plants[0]
	plant.reset()
	plant.configure_profile(instance.profile)
	plant.stage = PlantSimulation.Stage.PACKAGED
	plant.fresh_harvest_g = 32.0
	plant.dry_harvest_g = 5.4
	plant.harvest_quality = 0.84
	instance.session.select_plant(0)
	instance._change_screen(2)
	instance._set_shop_mode("sell")
	instance._refresh_ui()


func _prepare_phase40_equipment_shop_state(instance) -> void:
	instance._set_shop_legacy_capture(false)
	instance.session.coins = 86
	instance.session.xp = 350
	instance.session.equipment_levels = {
		"watering_can": 2,
		"grow_lamp": 1,
		"ventilation_fan": 1,
		"protective_spray": 1,
		"self_watering_pot": 1,
	}
	instance.session._sync_equipment_effects()
	instance.last_coins_seen = 86
	instance.last_xp_seen = 350
	instance._set_coin_count(86.0)
	instance._change_screen(2)
	instance._set_shop_category("equipment")
	instance._refresh_ui()
	instance.shop_catalog_scroll.scroll_vertical = 0


func _finish_phase40_equipment_shop_state(instance) -> void:
	# Diagnostic captures must not leak fixture state into approved Phase 7 gates.
	instance.session.coins = 42
	instance.session.xp = 300
	instance.session.equipment_levels = {
		"watering_can": 1,
		"grow_lamp": 1,
		"ventilation_fan": 1,
		"protective_spray": 1,
		"self_watering_pot": 1,
	}
	instance.session._sync_equipment_effects()
	instance.last_coins_seen = 42
	instance.last_xp_seen = 300
	instance._set_coin_count(42.0)
	instance._refresh_ui()


func _prepare_phase41_level_progression_state(instance) -> void:
	instance._set_guide_modal_open(false, false)
	instance._set_herbarium_open(false)
	instance._set_daily_challenge_open(false)
	instance._set_cosmetic_modal_open(false)
	instance._close_return_summary()
	instance.session.xp = 350
	instance.session.coins = 86
	instance.session.claimed_level_rewards.assign([1, 2])
	instance.last_xp_seen = 350
	instance.last_coins_seen = 86
	instance._set_coin_count(86.0)
	instance._set_level_progression_open(true)
	instance.level_progression_scroll.scroll_vertical = 0
	instance.level_progression_modal.set_meta("capture_state", "phase41_level_progression_candidate_v1")
	instance._refresh_ui()


func _prepare_phase42_care_center_state(instance) -> void:
	instance._set_guide_modal_open(false, false)
	instance._set_herbarium_open(false)
	instance._set_daily_challenge_open(false)
	instance._set_level_progression_open(false)
	instance._set_cosmetic_modal_open(false)
	instance._close_return_summary()
	for plant in instance.session.plants:
		plant.reset()
		plant.configure_profile(instance.profile)
	instance.session.xp = 300
	var basil: PlantSimulation = instance.session.plants[0]
	basil.stage = PlantSimulation.Stage.VEGETATIVE
	basil.growth_percent = 46.0
	basil.health = 82.0
	basil.moisture = 17.0
	var mint: PlantSimulation = instance.session.plants[1]
	mint.configure_profile(instance.plant_catalog.get("mint_peppermint", instance.profile))
	mint.stage = PlantSimulation.Stage.MATURE
	mint.growth_percent = 100.0
	mint.health = 94.0
	var rosemary: PlantSimulation = instance.session.plants[2]
	rosemary.configure_profile(instance.plant_catalog.get("rosemary_officinalis", instance.profile))
	rosemary.stage = PlantSimulation.Stage.SPROUT
	rosemary.growth_percent = 23.0
	rosemary.health = 63.0
	rosemary.disease_level = 1
	instance.session.select_plant(0)
	instance.plant_view.set_simulation(instance.session.plant)
	instance._set_care_center_open(true)
	instance.care_center_scroll.scroll_vertical = 0
	instance.care_center_modal.set_meta("capture_state", "phase43_care_plan_candidate_v1")
	instance._refresh_ui()


func _prepare_phase65_fast_time_guard_state(instance) -> void:
	_prepare_phase42_care_center_state(instance)
	instance.session.set_fast_time_guard_enabled(true)
	instance.session.speed_multiplier = 1000.0
	instance.session.paused = false
	instance.session.check_fast_time_guard_now()
	instance.care_center_scroll.scroll_vertical = 0
	instance.care_center_modal.set_meta("capture_state", "phase65_fast_time_guard_candidate_v1")


func _prepare_phase11_seed_selector_state(instance) -> void:
	for plant in instance.session.plants:
		plant.reset()
	instance.session.select_plant(0)
	instance.session.set_seed_count("basil_genovese", 3)
	instance.session.set_seed_count("mint_peppermint", 2)
	instance._change_screen(0)
	instance._open_plant_detail(0)
	instance.plant_detail_panel.modulate.a = 1.0
	instance._set_seed_selector_open(true)
	instance._refresh_ui()


func _prepare_phase11_mint_room_state(instance) -> void:
	instance._set_seed_selector_open(false)
	for plant in instance.session.plants:
		plant.reset()
	instance.session.xp = 300
	instance.last_xp_seen = 300
	var mint_profile: Dictionary = instance.plant_catalog.get("mint_peppermint", {})
	for index in range(4):
		instance.session.plants[index].configure_profile(mint_profile)
	_set_stage(instance.session.plants[0], PlantSimulation.Stage.GERMINATING, 4.0, 98.0, 2.0)
	_set_stage(instance.session.plants[1], PlantSimulation.Stage.SPROUT, 22.0, 95.0, 8.0)
	_set_stage(instance.session.plants[2], PlantSimulation.Stage.VEGETATIVE, 72.0, 90.0, 30.0)
	_set_stage(instance.session.plants[3], PlantSimulation.Stage.MATURE, 100.0, 96.0, 50.0)
	instance.session.select_plant(2)
	instance._change_screen(0)
	instance._open_room()
	instance.room_overview.previous_unlocked_count = 4
	instance.room_overview.displayed_growth_percent = 72.0
	instance.room_overview.refresh()
	instance._refresh_ui()


func _prepare_phase11_mint_detail_state(instance) -> void:
	_prepare_phase11_mint_room_state(instance)
	instance._open_plant_detail(2)
	instance.plant_detail_panel.modulate.a = 1.0
	instance.plant_view.animation_time = 0.35
	instance.plant_view.action_pulse = 0.0
	instance.plant_view.water_animation = 0.0
	instance.plant_view.sparkle_animation = 0.0
	instance.plant_view.growth_burst_animation = 0.0
	instance.plant_view.shake_animation = 0.0
	instance.plant_view.ladybug_animation = 0.0
	instance.plant_view.golden_shine_animation = 0.0
	instance.plant_view.queue_redraw()


func _prepare_phase12_herbarium_state(instance) -> void:
	_prepare_phase11_mint_detail_state(instance)
	instance.session.species_progress["basil_genovese"] = {
		"discovered": true, "harvests": 3, "best_quality": 0.74,
		"orders_completed": 1, "total_dry_g": 13.8, "claimed_tier": 2,
	}
	instance.session.species_progress["mint_peppermint"] = {
		"discovered": true, "harvests": 1, "best_quality": 0.61,
		"orders_completed": 0, "total_dry_g": 5.2, "claimed_tier": 1,
	}
	instance._set_herbarium_open(true)
	instance.herbarium_status_label.text = "Bazalka má novou hodnost k vyzvednutí. Máta roste k dalšímu cíli."


func _prepare_phase16_rosemary_detail_state(instance) -> void:
	instance._set_seed_selector_open(false)
	instance._set_herbarium_open(false)
	instance._set_daily_challenge_open(false)
	instance._set_level_progression_open(false)
	instance._set_cosmetic_modal_open(false)
	instance._close_return_summary()
	for plant in instance.session.plants:
		plant.reset()
	var rosemary_profile: Dictionary = instance.plant_catalog.get("rosemary_officinalis", {})
	instance.session.plants[0].configure_profile(rosemary_profile)
	_set_stage(instance.session.plants[0], PlantSimulation.Stage.MATURE, 100.0, 96.0, 65.0)
	instance.session.plants[0].moisture = 52.0
	instance.session.plants[0].nutrients = 52.0
	instance.session.select_plant(0)
	instance._change_screen(0)
	instance._open_plant_detail(0)
	instance.plant_detail_panel.modulate.a = 1.0
	instance.plant_view.animation_time = 0.35
	instance.plant_view.action_pulse = 0.0
	instance.plant_view.water_animation = 0.0
	instance.plant_view.sparkle_animation = 0.0
	instance.plant_view.growth_burst_animation = 0.0
	instance.plant_view.shake_animation = 0.0
	instance.plant_view.ladybug_animation = 0.0
	instance.plant_view.golden_shine_animation = 0.0
	instance._refresh_ui()
	instance.plant_view.queue_redraw()


func _prepare_phase16_rosemary_shop_state(instance) -> void:
	instance._set_seed_selector_open(false)
	instance._set_herbarium_open(false)
	instance._set_daily_challenge_open(false)
	instance._set_level_progression_open(false)
	instance._set_cosmetic_modal_open(false)
	instance._close_return_summary()
	instance.session.coins = 42
	instance.session.set_seed_count("rosemary_officinalis", 1)
	instance._set_shop_legacy_capture(false)
	instance._set_shop_mode("buy")
	instance._set_shop_category("all")
	instance.mint_shop_card.visible = true
	instance.rosemary_shop_card.visible = true
	instance.oregano_shop_card.visible = true
	instance._change_screen(2)
	instance._refresh_ui()


func _prepare_phase71_oregano_shop_state(instance) -> void:
	instance._set_seed_selector_open(false)
	instance._set_herbarium_open(false)
	instance._set_daily_challenge_open(false)
	instance._set_level_progression_open(false)
	instance._set_cosmetic_modal_open(false)
	instance._close_return_summary()
	instance.session.coins = 42
	instance.session.set_seed_count("oregano_vulgare", 1)
	instance._set_shop_legacy_capture(false)
	instance._set_shop_mode("buy")
	instance._set_shop_category("all")
	instance._change_screen(2)
	instance._refresh_ui()


func _prepare_phase71_oregano_room_state(instance) -> void:
	instance._set_seed_selector_open(false)
	instance._set_herbarium_open(false)
	instance._set_daily_challenge_open(false)
	instance._set_level_progression_open(false)
	instance._set_cosmetic_modal_open(false)
	instance._close_return_summary()
	for plant in instance.session.plants:
		plant.reset()
	instance.session.xp = 300
	instance.last_xp_seen = 300
	var oregano_profile: Dictionary = instance.plant_catalog.get("oregano_vulgare", {})
	for index in range(4):
		instance.session.plants[index].configure_profile(oregano_profile)
	_set_stage(instance.session.plants[0], PlantSimulation.Stage.GERMINATING, 4.0, 98.0, 2.0)
	_set_stage(instance.session.plants[1], PlantSimulation.Stage.SPROUT, 24.0, 95.0, 10.0)
	_set_stage(instance.session.plants[2], PlantSimulation.Stage.VEGETATIVE, 70.0, 91.0, 34.0)
	_set_stage(instance.session.plants[3], PlantSimulation.Stage.MATURE, 100.0, 96.0, 55.0)
	instance.session.select_plant(2)
	instance._change_screen(0)
	instance._open_room()
	instance.room_overview.previous_unlocked_count = 4
	instance.room_overview.displayed_growth_percent = 70.0
	instance.room_overview.refresh()
	instance._refresh_ui()


func _prepare_phase71_oregano_detail_state(instance) -> void:
	_prepare_phase71_oregano_room_state(instance)
	instance.session.select_plant(3)
	instance._open_plant_detail(3)
	instance.plant_detail_panel.modulate.a = 1.0
	instance.plant_view.animation_time = 0.35
	instance.plant_view.action_pulse = 0.0
	instance.plant_view.water_animation = 0.0
	instance.plant_view.sparkle_animation = 0.0
	instance.plant_view.growth_burst_animation = 0.0
	instance.plant_view.shake_animation = 0.0
	instance.plant_view.ladybug_animation = 0.0
	instance.plant_view.golden_shine_animation = 0.0
	instance._refresh_ui()
	instance.plant_view.queue_redraw()


func _prepare_phase5_measurement_state(instance) -> void:
	instance.session.chart_samples.clear()
	for index in range(18):
		var phase := float(index) / 17.0
		instance.session.chart_samples.append({
			"biomass": 8.0 + phase * 20.0,
			"light": 8000.0 + sin(phase * PI) * 18000.0,
			"co2": 470.0 - sin(phase * PI) * 55.0,
			"oxygen": -0.4 + sin(phase * PI) * 3.1,
		})
	instance._change_screen(3)
	instance._refresh_ui()


func _prepare_detail_state(instance) -> void:
	_prepare_room_state(instance)
	instance._change_screen(0)
	instance._open_plant_detail(2)
	# Opening detail refreshes the HUD from the global day. Restore the legacy
	# approved fixture after that refresh so feedback captures stay deterministic.
	instance._set_day_display(10)
	instance.plant_detail_panel.modulate.a = 1.0
	instance.plant_view.animation_time = 0.35
	instance.plant_view.action_pulse = 0.0
	instance.plant_view.water_animation = 0.0
	instance.plant_view.sparkle_animation = 0.0
	instance.plant_view.growth_burst_animation = 0.0
	instance.plant_view.shake_animation = 0.0
	instance.plant_view.ladybug_animation = 0.0
	instance.plant_view.golden_shine_animation = 0.0
	instance.plant_view.queue_redraw()


func _prepare_phase75_late_harvest_state(instance) -> void:
	_prepare_detail_state(instance)
	var plant: PlantSimulation = instance.session.plant
	plant.stage = PlantSimulation.Stage.MATURE
	plant.growth_percent = 100.0
	plant.health = 88.0
	plant.moisture = 61.0
	plant.nutrients = 54.0
	plant.ventilation = 72.0
	plant.disease_level = 0
	plant.disease_pressure = 0.0
	plant.mature_elapsed_seconds = plant.get_freshness_grace_seconds() + plant.get_freshness_decay_seconds() * 0.5
	plant.critical_neglect_seconds = 0.0
	plant.sync_environment(instance.session.world_elapsed_seconds)
	instance._refresh_ui()
	instance.plant_detail_panel.set_meta("capture_state", "phase75_late_harvest_diagnostic_v1")
	instance.plant_view.queue_redraw()


func _prepare_phase75_wilted_state(instance) -> void:
	_prepare_detail_state(instance)
	var plant: PlantSimulation = instance.session.plant
	plant.stage = PlantSimulation.Stage.MATURE
	plant.growth_percent = 100.0
	plant.health = 41.0
	# Keep one actionable fatal cause in the diagnostic so the mobile capture
	# proves both the blocked prune action and the required watering target.
	plant.moisture = 20.0
	plant.nutrients = 54.0
	plant.ventilation = 72.0
	plant.disease_level = 0
	plant.disease_pressure = 0.0
	plant.mature_elapsed_seconds = plant.get_freshness_grace_seconds() + 900.0
	plant.critical_neglect_seconds = plant.get_critical_wilt_seconds() + 300.0
	plant.sync_environment(instance.session.world_elapsed_seconds)
	instance._refresh_ui()
	instance.plant_detail_panel.set_meta("capture_state", "phase75_wilted_diagnostic_v1")
	instance.plant_view.queue_redraw()


func _prepare_phase75_dead_state(instance) -> void:
	_prepare_detail_state(instance)
	var plant: PlantSimulation = instance.session.plant
	plant.stage = PlantSimulation.Stage.DEAD
	plant.growth_percent = 100.0
	plant.health = 0.0
	plant.condition_score = 0.0
	plant.mature_elapsed_seconds = plant.get_freshness_grace_seconds() + 3600.0
	plant.critical_neglect_seconds = plant.get_critical_death_seconds()
	plant.lamp_on = false
	plant.current_issue = "Rostlina uhynula"
	instance._refresh_ui()
	instance.plant_detail_panel.set_meta("capture_state", "phase75_dead_diagnostic_v1")
	instance.plant_view.queue_redraw()


func _prepare_phase75_care_center_state(instance) -> void:
	_prepare_phase75_wilted_state(instance)
	instance._open_room()
	instance._set_care_center_open(true)
	instance.care_center_scroll.scroll_vertical = 0
	instance.care_center_modal.set_meta("capture_state", "phase75_wilted_care_center_diagnostic_v1")
	instance._refresh_ui()


func _prepare_phase62_treatment_state(instance) -> void:
	_prepare_detail_state(instance)
	var plant: PlantSimulation = instance.session.plant
	plant.stage = PlantSimulation.Stage.VEGETATIVE
	plant.growth_percent = 62.0
	plant.health = 66.0
	plant.moisture = 61.0
	plant.nutrients = 51.0
	plant.ventilation = 30.0
	plant.disease_pressure = 100.0
	plant.disease_level = 1
	plant.sync_environment(instance.session.world_elapsed_seconds)
	instance._refresh_ui()
	instance.plant_detail_panel.set_meta("capture_state", "phase62_disease_treatment_candidate_v1")
	instance.plant_view.animation_time = 0.35
	instance.plant_view.action_pulse = 0.0
	instance.plant_view.water_animation = 0.0
	instance.plant_view.sparkle_animation = 0.0
	instance.plant_view.growth_burst_animation = 0.0
	instance.plant_view.shake_animation = 0.0
	instance.plant_view.ladybug_animation = 0.0
	instance.plant_view.golden_shine_animation = 0.0
	instance.plant_view.queue_redraw()


func _prepare_phase63_diagnosis_state(instance) -> void:
	_prepare_phase62_treatment_state(instance)
	instance.session.paused = true
	instance.session.plant.ventilation = 100.0
	instance.session.plant.disease_pressure = 48.0
	instance._set_plant_diagnosis_open(true)
	instance.plant_diagnosis_modal.set_meta("capture_state", "phase63_plant_diagnosis_candidate_v1")
	instance.plant_diagnosis_scroll.scroll_vertical = 0
	instance._refresh_plant_diagnosis()


func _prepare_phase64_diagnosis_action_state(instance) -> void:
	_prepare_detail_state(instance)
	instance.session.paused = true
	instance.session.world_elapsed_seconds = 0.0
	var plant = instance.session.plant
	plant.disease_level = 0
	plant.disease_pressure = 0.0
	plant.moisture = 12.0
	plant.nutrients = 52.0
	plant.ventilation = 55.0
	plant.humidity_percent = 55.0
	plant.light_lux = 12000.0
	plant.temperature_c = 23.0
	plant.ph = 6.4
	plant.condition_score = 0.42
	instance._set_plant_diagnosis_open(true)
	instance.plant_diagnosis_modal.set_meta("capture_state", "phase64_plant_diagnosis_action_candidate_v1")
	instance.plant_diagnosis_scroll.scroll_vertical = 0
	instance._refresh_plant_diagnosis()


func _prepare_phase79_plant_behavior_state(instance) -> void:
	_prepare_phase16_rosemary_detail_state(instance)
	instance.session.paused = true
	instance.session.world_elapsed_seconds = 0.0
	var plant = instance.session.plant
	plant.disease_level = 0
	plant.disease_pressure = 0.0
	var ideal_moisture_min := float(plant.profile.get("ideal_moisture_min", 32.0))
	var ideal_moisture_max := float(plant.profile.get("ideal_moisture_max", 62.0))
	plant.moisture = minf(ideal_moisture_min + 4.0, ideal_moisture_max)
	plant.nutrients = (float(plant.profile.get("ideal_nutrients_min", 32.0)) + float(plant.profile.get("ideal_nutrients_max", 76.0))) * 0.5
	plant.ventilation = 68.0
	plant.humidity_percent = 54.0
	plant.light_lux = 12000.0
	plant.temperature_c = (float(plant.profile.get("ideal_temperature_min", 20.0)) + float(plant.profile.get("ideal_temperature_max", 28.0))) * 0.5
	plant.ph = (float(plant.profile.get("ideal_ph_min", 5.8)) + float(plant.profile.get("ideal_ph_max", 7.0))) * 0.5
	plant.condition_score = 0.91
	instance._set_plant_diagnosis_open(true)
	instance.plant_diagnosis_modal.set_meta("capture_state", "phase79_plant_behavior_diagnostic_v1")
	instance.plant_diagnosis_modal.set_meta("behavior_id", "water_saving_needles")
	instance.plant_diagnosis_scroll.scroll_vertical = 0
	instance._refresh_plant_diagnosis()


func _validate_phase81_lavender_contract(instance) -> bool:
	if not instance.plant_catalog.has(LAVENDER_SPECIES_ID):
		push_error("Phase 81 capture requires the Lavender profile in the dynamic manifest.")
		return false
	if LAVENDER_SPECIES_ID not in instance.session.get_available_species():
		push_error("Phase 81 Lavender is missing from get_available_species().")
		return false
	if LAVENDER_SPECIES_ID not in instance.session.get_collection_species_ids():
		push_error("Phase 81 Lavender is missing from the collection catalog.")
		return false
	if LAVENDER_SPECIES_ID not in instance.session.get_botanist_shop_species_ids():
		push_error("Phase 81 Lavender is missing from the botanist shop catalog.")
		return false
	if not instance.seed_species_buttons.has(LAVENDER_SPECIES_ID) \
			or not instance.herbarium_cards.has(LAVENDER_SPECIES_ID) \
			or not instance.shop_seed_buttons.has(LAVENDER_SPECIES_ID) \
			or not instance.shop_owned_labels.has(LAVENDER_SPECIES_ID):
		push_error("Phase 81 Lavender is missing from one or more generic UI maps.")
		return false
	var definitions: Array[Dictionary] = instance.session.get_species_behavior_definitions(LAVENDER_SPECIES_ID)
	for definition in definitions:
		if str(definition.get("id", "")) != LAVENDER_BEHAVIOR_ID:
			continue
		if str(definition.get("label", "")) != LAVENDER_BEHAVIOR_LABEL:
			push_error("Phase 81 Lavender behavior label drifted from VOŇAVÝ KVĚT.")
			return false
		var activation: Dictionary = definition.get("activation", {})
		if str(activation.get("type", "")) != "condition_score_at_least" \
				or not is_equal_approx(float(activation.get("threshold", -1.0)), LAVENDER_ACTIVE_THRESHOLD):
			push_error("Phase 81 Lavender behavior must activate at condition score 0.85.")
			return false
		return true
	push_error("Phase 81 Lavender is missing behavior fragrant_bloom.")
	return false


func _set_phase81_lavender_discovery(instance, discovered: bool) -> void:
	instance.session.set_seed_count(LAVENDER_SPECIES_ID, 0)
	var progress: Dictionary = instance.session.get_species_progress(LAVENDER_SPECIES_ID)
	progress["discovered"] = discovered
	progress["harvests"] = 2 if discovered else 0
	progress["best_quality"] = 0.91 if discovered else 0.0
	progress["orders_completed"] = 1 if discovered else 0
	progress["total_dry_g"] = 8.4 if discovered else 0.0
	progress["claimed_tier"] = 1
	instance.session.species_progress[LAVENDER_SPECIES_ID] = progress
	if discovered:
		instance.session.set_seed_count(LAVENDER_SPECIES_ID, 2)


func _prepare_phase81_lavender_seed_selector_state(instance, discovered: bool) -> bool:
	instance._set_plant_diagnosis_open(false)
	instance._set_herbarium_open(false)
	instance._set_botanical_pack_open(false)
	for plant in instance.session.plants:
		plant.reset()
	instance.session.journey_completed = true
	instance.session.harvest_count = maxi(1, instance.session.harvest_count)
	instance.session.select_plant(0)
	_set_phase81_lavender_discovery(instance, discovered)
	instance._change_screen(0)
	instance._open_plant_detail(0)
	instance.plant_detail_panel.modulate.a = 1.0
	instance._set_seed_selector_open(true)
	instance._refresh_ui()
	instance.seed_selector_modal.set_meta(
		"capture_state",
		"phase81_lavender_seed_selector_discovered_v1" if discovered else "phase81_lavender_seed_selector_locked_v1"
	)
	instance.seed_selector_modal.set_meta("species_id", LAVENDER_SPECIES_ID)
	var button := instance.seed_species_buttons.get(LAVENDER_SPECIES_ID) as Button
	if button == null or button.disabled == discovered:
		push_error("Phase 81 Lavender seed selector lock state is incorrect.")
		return false
	return true


func _prepare_phase81_lavender_herbarium_state(instance, discovered: bool) -> bool:
	instance._set_seed_selector_open(false)
	_set_phase81_lavender_discovery(instance, discovered)
	instance._set_herbarium_open(true)
	instance._refresh_ui()
	instance.herbarium_modal.set_meta(
		"capture_state",
		"phase81_lavender_herbarium_discovered_v1" if discovered else "phase81_lavender_herbarium_locked_v1"
	)
	instance.herbarium_modal.set_meta("species_id", LAVENDER_SPECIES_ID)
	var card: Dictionary = instance.herbarium_cards.get(LAVENDER_SPECIES_ID, {})
	var name_label := card.get("name") as Label
	var behavior_label := card.get("behavior") as Label
	if name_label == null or behavior_label == null:
		push_error("Phase 81 Lavender herbarium card is incomplete.")
		return false
	if discovered:
		if "LEVANDULE" not in name_label.text or not behavior_label.visible \
				or LAVENDER_BEHAVIOR_LABEL not in behavior_label.text:
			push_error("Phase 81 discovered Lavender card does not reveal its identity and trait.")
			return false
	elif name_label.text != "NEOBJEVENÁ BYLINKA" or behavior_label.visible or not behavior_label.text.is_empty():
		push_error("Phase 81 locked Lavender herbarium card leaks its trait.")
		return false
	return true


func _prepare_phase81_lavender_shop_state(instance) -> bool:
	instance._set_seed_selector_open(false)
	instance._set_herbarium_open(false)
	instance.session.xp = 400
	instance.last_xp_seen = 400
	instance.session.coins = 96
	instance.last_coins_seen = 96
	instance.session.set_seed_count(LAVENDER_SPECIES_ID, 1)
	# Keep report output independent from the real calendar while still exercising
	# the runtime stock map and every manifest-backed botanist species.
	instance.session.shop_stock_day = 2147483647
	instance.session.shop_stock.clear()
	for species_id in instance.session.get_botanist_shop_species_ids():
		instance.session.shop_stock[instance.session.get_shop_seed_item_id(species_id)] = 1
	instance.session.shop_stock[GameSession.SHOP_FERTILIZER_ITEM_ID] = 2
	instance._set_shop_legacy_capture(false)
	instance._set_shop_mode("buy")
	instance._set_shop_category("all")
	instance._change_screen(2)
	instance._refresh_ui()
	instance._set_coin_count(float(instance.session.coins))
	instance.shop_runtime_layout.set_meta("capture_state", "phase81_lavender_shop_stock_v1")
	instance.shop_runtime_layout.set_meta("species_id", LAVENDER_SPECIES_ID)
	var button := instance.shop_seed_buttons.get(LAVENDER_SPECIES_ID) as Button
	var owned := instance.shop_owned_labels.get(LAVENDER_SPECIES_ID) as Label
	if button == null or owned == null or button.disabled \
			or instance.session.get_shop_stock(instance.session.get_shop_seed_item_id(LAVENDER_SPECIES_ID)) != 1:
		push_error("Phase 81 Lavender shop tile is not unlocked and stocked.")
		return false
	return true


func _prepare_phase81_lavender_room_state(instance) -> bool:
	instance._set_seed_selector_open(false)
	instance._set_herbarium_open(false)
	instance._set_plant_diagnosis_open(false)
	for plant in instance.session.plants:
		plant.reset()
	var lavender_profile: Dictionary = instance.plant_catalog.get(LAVENDER_SPECIES_ID, {})
	if lavender_profile.is_empty():
		push_error("Phase 81 Lavender room capture has no profile.")
		return false
	instance.session.xp = 400
	instance.last_xp_seen = 400
	var lavender: PlantSimulation = instance.session.plants[0]
	lavender.configure_profile(lavender_profile)
	_set_stage(lavender, PlantSimulation.Stage.VEGETATIVE, 84.0, 92.0, 74.0)
	_configure_phase81_lavender_ideal_state(lavender)
	instance.session.select_plant(0)
	instance._change_screen(0)
	instance._open_room()
	instance.room_overview.previous_unlocked_count = 5
	instance.room_overview.displayed_growth_percent = 84.0
	instance.room_overview.set_meta("capture_state", "phase81_lavender_room_mature_v1")
	instance.room_overview.set_meta("species_id", LAVENDER_SPECIES_ID)
	instance.room_overview.refresh()
	instance._refresh_ui()
	return lavender.get_species_id() == LAVENDER_SPECIES_ID


func _prepare_phase81_lavender_detail_trait_state(instance) -> bool:
	if not _prepare_phase81_lavender_room_state(instance):
		return false
	var lavender: PlantSimulation = instance.session.plant
	lavender.stage = PlantSimulation.Stage.MATURE
	lavender.growth_percent = 100.0
	_configure_phase81_lavender_ideal_state(lavender)
	instance._open_plant_detail(0)
	instance.plant_detail_panel.modulate.a = 1.0
	instance._refresh_ui()
	var active_trait := false
	for entry in lavender.get_behavior_status_entries():
		if str(entry.get("id", "")) == LAVENDER_BEHAVIOR_ID \
				and bool(entry.get("active", false)) \
				and str(entry.get("label", "")) == LAVENDER_BEHAVIOR_LABEL:
			active_trait = true
			break
	if not active_trait:
		push_error("Phase 81 Lavender Epic trait is not active in the detail fixture.")
		return false
	instance._set_plant_diagnosis_open(true)
	instance.plant_diagnosis_modal.set_meta("capture_state", "phase81_lavender_epic_trait_active_v1")
	instance.plant_diagnosis_modal.set_meta("species_id", LAVENDER_SPECIES_ID)
	instance.plant_diagnosis_modal.set_meta("behavior_id", LAVENDER_BEHAVIOR_ID)
	instance._refresh_plant_diagnosis()
	return true


func _validate_phase83_chives_contract(instance) -> bool:
	if not instance.plant_catalog.has(CHIVES_SPECIES_ID):
		push_error("Phase 83 capture requires the Chives profile in the dynamic manifest.")
		return false
	if CHIVES_SPECIES_ID not in instance.session.get_available_species():
		push_error("Phase 83 Chives is missing from get_available_species().")
		return false
	if CHIVES_SPECIES_ID not in instance.session.get_collection_species_ids():
		push_error("Phase 83 Chives is missing from the collection catalog.")
		return false
	if CHIVES_SPECIES_ID not in instance.session.get_botanist_shop_species_ids():
		push_error("Phase 83 Chives is missing from the botanist shop catalog.")
		return false
	if not instance.seed_species_buttons.has(CHIVES_SPECIES_ID) \
			or not instance.herbarium_cards.has(CHIVES_SPECIES_ID) \
			or not instance.shop_seed_buttons.has(CHIVES_SPECIES_ID) \
			or not instance.shop_owned_labels.has(CHIVES_SPECIES_ID):
		push_error("Phase 83 Chives is missing from one or more generic UI maps.")
		return false

	var chives_profile: Dictionary = instance.plant_catalog.get(CHIVES_SPECIES_ID, {})
	if str(chives_profile.get("seed_preview_texture", "")) != str(CHIVES_STAGE_TEXTURES["sprout"]) \
			or str(chives_profile.get("herbarium_texture", "")) != str(CHIVES_STAGE_TEXTURES["mature"]):
		push_error("Phase 83 Chives preview or herbarium texture path drifted.")
		return false
	var raw_stage_textures: Variant = chives_profile.get("stage_textures", {})
	if not raw_stage_textures is Dictionary:
		push_error("Phase 83 Chives stage_textures must be a dictionary.")
		return false
	var stage_textures := raw_stage_textures as Dictionary
	for state_id in CHIVES_STAGE_TEXTURES:
		if str(stage_textures.get(state_id, "")) != str(CHIVES_STAGE_TEXTURES[state_id]):
			push_error("Phase 83 Chives texture path drifted for state %s." % state_id)
			return false
	if not is_equal_approx(float(chives_profile.get("ideal_moisture_min", -1.0)), CHIVES_MOISTURE_MIN) \
			or not is_equal_approx(float(chives_profile.get("ideal_moisture_max", -1.0)), CHIVES_MOISTURE_MAX):
		push_error("Phase 83 Chives ideal moisture band must remain 46–78.")
		return false

	var definitions: Array[Dictionary] = instance.session.get_species_behavior_definitions(CHIVES_SPECIES_ID)
	for definition in definitions:
		if str(definition.get("id", "")) != CHIVES_BEHAVIOR_ID:
			continue
		if str(definition.get("label", "")) != CHIVES_BEHAVIOR_LABEL:
			push_error("Phase 83 Chives behavior label drifted from SÍLA TRSU.")
			return false
		var activation: Dictionary = definition.get("activation", {})
		if str(activation.get("type", "")) != "growth_value_in_profile_band" \
				or str(activation.get("value", "")) != "moisture" \
				or str(activation.get("minimum_field", "")) != "ideal_moisture_min" \
				or str(activation.get("maximum_field", "")) != "ideal_moisture_max":
			push_error("Phase 83 Chives clumping_vigor activation contract drifted.")
			return false
		return true
	push_error("Phase 83 Chives is missing behavior clumping_vigor.")
	return false


func _set_phase83_chives_discovery(instance, discovered: bool) -> void:
	instance.session.set_seed_count(CHIVES_SPECIES_ID, 0)
	var progress: Dictionary = instance.session.get_species_progress(CHIVES_SPECIES_ID)
	progress["discovered"] = discovered
	progress["harvests"] = 2 if discovered else 0
	progress["best_quality"] = 0.89 if discovered else 0.0
	progress["orders_completed"] = 1 if discovered else 0
	progress["total_dry_g"] = 7.2 if discovered else 0.0
	progress["claimed_tier"] = 1
	instance.session.species_progress[CHIVES_SPECIES_ID] = progress
	if discovered:
		instance.session.set_seed_count(CHIVES_SPECIES_ID, 2)


func _prepare_phase83_chives_seed_selector_state(instance, discovered: bool) -> bool:
	instance._set_plant_diagnosis_open(false)
	instance._set_herbarium_open(false)
	instance._set_botanical_pack_open(false)
	for plant in instance.session.plants:
		plant.reset()
	instance.session.journey_completed = true
	instance.session.harvest_count = maxi(1, instance.session.harvest_count)
	instance.session.xp = 400
	instance.last_xp_seen = 400
	instance.session.select_plant(0)
	_set_phase83_chives_discovery(instance, discovered)
	instance._change_screen(0)
	instance._open_plant_detail(0)
	instance.plant_detail_panel.modulate.a = 1.0
	instance._set_seed_selector_open(true)
	instance._refresh_ui()
	instance.seed_selector_modal.set_meta(
		"capture_state",
		"phase83_chives_seed_selector_discovered_v1" if discovered else "phase83_chives_seed_selector_locked_v1"
	)
	instance.seed_selector_modal.set_meta("species_id", CHIVES_SPECIES_ID)
	var button := instance.seed_species_buttons.get(CHIVES_SPECIES_ID) as Button
	if button == null or button.disabled == discovered:
		push_error("Phase 83 Chives seed selector lock state is incorrect.")
		return false
	return true


func _prepare_phase83_chives_herbarium_state(instance, discovered: bool) -> bool:
	instance._set_seed_selector_open(false)
	_set_phase83_chives_discovery(instance, discovered)
	instance._set_herbarium_open(true)
	instance._refresh_ui()
	instance.herbarium_modal.set_meta(
		"capture_state",
		"phase83_chives_herbarium_discovered_v1" if discovered else "phase83_chives_herbarium_locked_v1"
	)
	instance.herbarium_modal.set_meta("species_id", CHIVES_SPECIES_ID)
	var card: Dictionary = instance.herbarium_cards.get(CHIVES_SPECIES_ID, {})
	var name_label := card.get("name") as Label
	var behavior_label := card.get("behavior") as Label
	if name_label == null or behavior_label == null:
		push_error("Phase 83 Chives herbarium card is incomplete.")
		return false
	if discovered:
		var profile: Dictionary = instance.plant_catalog.get(CHIVES_SPECIES_ID, {})
		var expected_name := str(profile.get("short_name", profile.get("display_name", ""))).to_upper()
		if expected_name.is_empty() or expected_name not in name_label.text \
				or not behavior_label.visible or CHIVES_BEHAVIOR_LABEL not in behavior_label.text:
			push_error("Phase 83 discovered Chives card does not reveal its identity and trait.")
			return false
	elif name_label.text != "NEOBJEVENÁ BYLINKA" or behavior_label.visible or not behavior_label.text.is_empty():
		push_error("Phase 83 locked Chives herbarium card leaks its identity or trait.")
		return false
	return true


func _prepare_phase83_chives_shop_state(instance) -> bool:
	instance._set_seed_selector_open(false)
	instance._set_herbarium_open(false)
	instance.session.xp = 400
	instance.last_xp_seen = 400
	instance.session.coins = 96
	instance.last_coins_seen = 96
	instance.session.set_seed_count(CHIVES_SPECIES_ID, 1)
	instance.session.shop_stock_day = 2147483647
	instance.session.shop_stock.clear()
	for species_id in instance.session.get_botanist_shop_species_ids():
		instance.session.shop_stock[instance.session.get_shop_seed_item_id(species_id)] = 1
	instance.session.shop_stock[GameSession.SHOP_FERTILIZER_ITEM_ID] = 2
	instance._set_shop_legacy_capture(false)
	instance._set_shop_mode("buy")
	instance._set_shop_category("all")
	instance._change_screen(2)
	instance._refresh_ui()
	instance._set_coin_count(float(instance.session.coins))
	instance.shop_runtime_layout.set_meta("capture_state", "phase83_chives_shop_stock_v1")
	instance.shop_runtime_layout.set_meta("species_id", CHIVES_SPECIES_ID)
	var button := instance.shop_seed_buttons.get(CHIVES_SPECIES_ID) as Button
	var owned := instance.shop_owned_labels.get(CHIVES_SPECIES_ID) as Label
	if button == null or owned == null or button.disabled \
			or instance.session.get_shop_stock(instance.session.get_shop_seed_item_id(CHIVES_SPECIES_ID)) != 1:
		push_error("Phase 83 Chives shop tile is not unlocked and stocked.")
		return false
	return true


func _prepare_phase83_chives_room_state(instance) -> bool:
	instance._set_seed_selector_open(false)
	instance._set_herbarium_open(false)
	instance._set_plant_diagnosis_open(false)
	for plant in instance.session.plants:
		plant.reset()
	var chives_profile: Dictionary = instance.plant_catalog.get(CHIVES_SPECIES_ID, {})
	if chives_profile.is_empty():
		push_error("Phase 83 Chives room capture has no profile.")
		return false
	instance.session.xp = 400
	instance.last_xp_seen = 400
	var chives: PlantSimulation = instance.session.plants[0]
	chives.configure_profile(chives_profile)
	var harvest_days := maxf(1.0, float(chives_profile.get("biological_days_to_harvest", 45.0)))
	_set_stage(chives, PlantSimulation.Stage.VEGETATIVE, 84.0, 92.0, harvest_days * 0.84)
	_configure_phase83_chives_ideal_state(chives)
	instance.session.select_plant(0)
	instance._change_screen(0)
	instance._open_room()
	instance.room_overview.previous_unlocked_count = 5
	instance.room_overview.displayed_growth_percent = 84.0
	instance.room_overview.set_meta("capture_state", "phase83_chives_room_mature_v1")
	instance.room_overview.set_meta("species_id", CHIVES_SPECIES_ID)
	instance.room_overview.refresh()
	instance._refresh_ui()
	return chives.get_species_id() == CHIVES_SPECIES_ID


func _prepare_phase83_chives_detail_trait_state(instance) -> bool:
	if not _prepare_phase83_chives_room_state(instance):
		return false
	var chives: PlantSimulation = instance.session.plant
	var harvest_days := maxf(1.0, float(chives.profile.get("biological_days_to_harvest", 45.0)))
	_set_stage(chives, PlantSimulation.Stage.VEGETATIVE, 58.0, 92.0, harvest_days * 0.58)
	_configure_phase83_chives_ideal_state(chives)
	instance._open_plant_detail(0)
	instance.plant_detail_panel.modulate.a = 1.0
	instance.plant_behavior_presenter.reset_observation()
	instance._refresh_ui()
	var active_trait := false
	for entry in chives.get_behavior_status_entries():
		if str(entry.get("id", "")) == CHIVES_BEHAVIOR_ID \
				and bool(entry.get("active", false)) \
				and str(entry.get("label", "")) == CHIVES_BEHAVIOR_LABEL:
			active_trait = true
			break
	if not active_trait:
		push_error("Phase 83 Chives clumping_vigor trait is not active in the detail fixture.")
		return false
	instance._set_plant_diagnosis_open(true)
	instance.plant_diagnosis_modal.set_meta("capture_state", "phase83_chives_detail_trait_active_v1")
	instance.plant_diagnosis_modal.set_meta("species_id", CHIVES_SPECIES_ID)
	instance.plant_diagnosis_modal.set_meta("behavior_id", CHIVES_BEHAVIOR_ID)
	instance._refresh_plant_diagnosis()
	return true


func _configure_phase83_chives_ideal_state(chives: PlantSimulation) -> void:
	chives.health = 92.0
	chives.moisture = 62.0
	chives.nutrients = 50.0
	chives.ventilation = 72.0
	chives.humidity_percent = 50.0
	chives.light_lux = 14000.0
	chives.temperature_c = 22.0
	chives.ph = 6.8
	chives.disease_level = 0
	chives.disease_pressure = 0.0
	chives.condition_score = 0.91


func _validate_phase84_marjoram_contract(instance) -> bool:
	if not instance.plant_catalog.has(MARJORAM_SPECIES_ID):
		push_error("Phase 84 capture requires the Marjoram profile in the dynamic manifest.")
		return false
	if MARJORAM_SPECIES_ID not in instance.session.get_available_species() \
			or MARJORAM_SPECIES_ID not in instance.session.get_collection_species_ids() \
			or MARJORAM_SPECIES_ID not in instance.session.get_botanist_shop_species_ids():
		push_error("Phase 84 Marjoram is missing from one or more runtime catalogs.")
		return false
	if not instance.seed_species_buttons.has(MARJORAM_SPECIES_ID) \
			or not instance.herbarium_cards.has(MARJORAM_SPECIES_ID) \
			or not instance.shop_seed_buttons.has(MARJORAM_SPECIES_ID) \
			or not instance.shop_owned_labels.has(MARJORAM_SPECIES_ID):
		push_error("Phase 84 Marjoram is missing from one or more generic UI maps.")
		return false
	var marjoram_profile: Dictionary = instance.plant_catalog.get(MARJORAM_SPECIES_ID, {})
	if str(marjoram_profile.get("seed_preview_texture", "")) != str(MARJORAM_STAGE_TEXTURES["sprout"]) \
			or str(marjoram_profile.get("herbarium_texture", "")) != str(MARJORAM_STAGE_TEXTURES["mature"]):
		push_error("Phase 84 Marjoram preview or herbarium texture path drifted.")
		return false
	var raw_stage_textures: Variant = marjoram_profile.get("stage_textures", {})
	if not raw_stage_textures is Dictionary:
		push_error("Phase 84 Marjoram stage_textures must be a dictionary.")
		return false
	var stage_textures := raw_stage_textures as Dictionary
	for state_id in MARJORAM_STAGE_TEXTURES:
		if str(stage_textures.get(state_id, "")) != str(MARJORAM_STAGE_TEXTURES[state_id]):
			push_error("Phase 84 Marjoram texture path drifted for state %s." % state_id)
			return false
	var definitions: Array[Dictionary] = instance.session.get_species_behavior_definitions(MARJORAM_SPECIES_ID)
	for definition in definitions:
		if str(definition.get("id", "")) != MARJORAM_BEHAVIOR_ID:
			continue
		if str(definition.get("label", "")) != MARJORAM_BEHAVIOR_LABEL:
			push_error("Phase 84 Marjoram behavior label drifted from VŮNĚ PO USUŠENÍ.")
			return false
		var activation: Dictionary = definition.get("activation", {})
		var effects: Dictionary = definition.get("effects", {})
		if str(activation.get("type", "")) != "harvest_quality_at_least" \
				or not is_equal_approx(float(activation.get("threshold", -1.0)), MARJORAM_QUALITY_THRESHOLD) \
				or not is_equal_approx(float(effects.get("drying_time_multiplier", -1.0)), MARJORAM_DRYING_MULTIPLIER):
			push_error("Phase 84 Marjoram aroma_preservation contract drifted.")
			return false
		var probe := PlantSimulation.new(marjoram_profile)
		probe.stage = PlantSimulation.Stage.HARVESTED
		probe.harvest_quality = MARJORAM_QUALITY_THRESHOLD
		if not is_equal_approx(probe.get_drying_target_seconds(), 8640.0):
			push_error("Phase 84 Marjoram active drying target must remain 8640 seconds.")
			return false
		return true
	push_error("Phase 84 Marjoram is missing behavior aroma_preservation.")
	return false


func _set_phase84_marjoram_discovery(instance, discovered: bool) -> void:
	instance.session.set_seed_count(MARJORAM_SPECIES_ID, 0)
	var progress: Dictionary = instance.session.get_species_progress(MARJORAM_SPECIES_ID)
	progress["discovered"] = discovered
	progress["harvests"] = 2 if discovered else 0
	progress["best_quality"] = 0.88 if discovered else 0.0
	progress["orders_completed"] = 1 if discovered else 0
	progress["total_dry_g"] = 9.1 if discovered else 0.0
	progress["claimed_tier"] = 1
	instance.session.species_progress[MARJORAM_SPECIES_ID] = progress
	if discovered:
		instance.session.set_seed_count(MARJORAM_SPECIES_ID, 2)


func _prepare_phase84_marjoram_seed_selector_state(instance, discovered: bool) -> bool:
	instance._set_plant_diagnosis_open(false)
	instance._set_herbarium_open(false)
	instance._set_botanical_pack_open(false)
	for plant in instance.session.plants:
		plant.reset()
	instance.session.journey_completed = true
	instance.session.harvest_count = maxi(1, instance.session.harvest_count)
	instance.session.xp = 400
	instance.last_xp_seen = 400
	instance.session.select_plant(0)
	_set_phase84_marjoram_discovery(instance, discovered)
	instance._change_screen(0)
	instance._open_plant_detail(0)
	instance.plant_detail_panel.modulate.a = 1.0
	instance._set_seed_selector_open(true)
	instance._refresh_ui()
	instance.seed_selector_modal.set_meta(
		"capture_state",
		"phase84_marjoram_seed_selector_discovered_v1" if discovered else "phase84_marjoram_seed_selector_locked_v1"
	)
	instance.seed_selector_modal.set_meta("species_id", MARJORAM_SPECIES_ID)
	var button := instance.seed_species_buttons.get(MARJORAM_SPECIES_ID) as Button
	if button == null or button.disabled == discovered:
		push_error("Phase 84 Marjoram seed selector lock state is incorrect.")
		return false
	return true


func _prepare_phase84_marjoram_herbarium_state(instance, discovered: bool) -> bool:
	instance._set_seed_selector_open(false)
	_set_phase84_marjoram_discovery(instance, discovered)
	instance._set_herbarium_open(true)
	instance._refresh_ui()
	instance.herbarium_modal.set_meta(
		"capture_state",
		"phase84_marjoram_herbarium_discovered_v1" if discovered else "phase84_marjoram_herbarium_locked_v1"
	)
	instance.herbarium_modal.set_meta("species_id", MARJORAM_SPECIES_ID)
	var card: Dictionary = instance.herbarium_cards.get(MARJORAM_SPECIES_ID, {})
	var name_label := card.get("name") as Label
	var behavior_label := card.get("behavior") as Label
	if name_label == null or behavior_label == null:
		push_error("Phase 84 Marjoram herbarium card is incomplete.")
		return false
	if discovered:
		var profile: Dictionary = instance.plant_catalog.get(MARJORAM_SPECIES_ID, {})
		var expected_name := str(profile.get("short_name", profile.get("display_name", ""))).to_upper()
		if expected_name.is_empty() or expected_name not in name_label.text \
				or not behavior_label.visible or MARJORAM_BEHAVIOR_LABEL not in behavior_label.text:
			push_error("Phase 84 discovered Marjoram card does not reveal its identity and trait.")
			return false
	elif name_label.text != "NEOBJEVENÁ BYLINKA" or behavior_label.visible or not behavior_label.text.is_empty():
		push_error("Phase 84 locked Marjoram herbarium card leaks its identity or trait.")
		return false
	return true


func _prepare_phase84_marjoram_shop_state(instance) -> bool:
	instance._set_seed_selector_open(false)
	instance._set_herbarium_open(false)
	instance.session.xp = 400
	instance.last_xp_seen = 400
	instance.session.coins = 110
	instance.last_coins_seen = 110
	instance.session.set_seed_count(MARJORAM_SPECIES_ID, 1)
	instance.session.shop_stock_day = 2147483647
	instance.session.shop_stock.clear()
	for species_id in instance.session.get_botanist_shop_species_ids():
		instance.session.shop_stock[instance.session.get_shop_seed_item_id(species_id)] = 1
	instance.session.shop_stock[GameSession.SHOP_FERTILIZER_ITEM_ID] = 2
	instance._set_shop_legacy_capture(false)
	instance._set_shop_mode("buy")
	instance._set_shop_category("all")
	instance._change_screen(2)
	instance._refresh_ui()
	instance._set_coin_count(float(instance.session.coins))
	instance.shop_runtime_layout.set_meta("capture_state", "phase84_marjoram_shop_stock_v1")
	instance.shop_runtime_layout.set_meta("species_id", MARJORAM_SPECIES_ID)
	var button := instance.shop_seed_buttons.get(MARJORAM_SPECIES_ID) as Button
	var owned := instance.shop_owned_labels.get(MARJORAM_SPECIES_ID) as Label
	if button == null or owned == null or button.disabled \
			or instance.session.get_shop_stock(instance.session.get_shop_seed_item_id(MARJORAM_SPECIES_ID)) != 1:
		push_error("Phase 84 Marjoram shop tile is not unlocked and stocked.")
		return false
	return true


func _prepare_phase84_marjoram_room_state(instance) -> bool:
	instance._set_seed_selector_open(false)
	instance._set_herbarium_open(false)
	instance._set_plant_diagnosis_open(false)
	for plant in instance.session.plants:
		plant.reset()
	var marjoram_profile: Dictionary = instance.plant_catalog.get(MARJORAM_SPECIES_ID, {})
	if marjoram_profile.is_empty():
		push_error("Phase 84 Marjoram room capture has no profile.")
		return false
	instance.session.xp = 400
	instance.last_xp_seen = 400
	var marjoram: PlantSimulation = instance.session.plants[0]
	marjoram.configure_profile(marjoram_profile)
	var harvest_days := maxf(1.0, float(marjoram_profile.get("biological_days_to_harvest", 60.0)))
	_set_stage(marjoram, PlantSimulation.Stage.VEGETATIVE, 84.0, 92.0, harvest_days * 0.84)
	_configure_phase84_marjoram_ideal_state(marjoram)
	instance.session.select_plant(0)
	instance._change_screen(0)
	instance._open_room()
	instance.room_overview.previous_unlocked_count = 5
	instance.room_overview.displayed_growth_percent = 84.0
	instance.room_overview.set_meta("capture_state", "phase84_marjoram_room_mature_v1")
	instance.room_overview.set_meta("species_id", MARJORAM_SPECIES_ID)
	instance.room_overview.refresh()
	instance._refresh_ui()
	return marjoram.get_species_id() == MARJORAM_SPECIES_ID


func _prepare_phase84_marjoram_detail_trait_state(instance) -> bool:
	if not _prepare_phase84_marjoram_room_state(instance):
		return false
	var marjoram: PlantSimulation = instance.session.plant
	var harvest_days := maxf(1.0, float(marjoram.profile.get("biological_days_to_harvest", 60.0)))
	_set_stage(marjoram, PlantSimulation.Stage.MATURE, 100.0, 92.0, harvest_days)
	_configure_phase84_marjoram_ideal_state(marjoram)
	marjoram.mature_elapsed_seconds = 0.0
	instance._open_plant_detail(0)
	instance.plant_detail_panel.modulate.a = 1.0
	instance.plant_behavior_presenter.reset_observation()
	instance._refresh_ui()
	var active_trait := false
	for entry in marjoram.get_behavior_status_entries():
		if str(entry.get("id", "")) == MARJORAM_BEHAVIOR_ID \
				and bool(entry.get("active", false)) \
				and str(entry.get("label", "")) == MARJORAM_BEHAVIOR_LABEL:
			active_trait = true
			break
	if not active_trait or marjoram.get_estimated_harvest_quality() < MARJORAM_QUALITY_THRESHOLD:
		push_error("Phase 84 Marjoram aroma_preservation trait is not active in the detail fixture.")
		return false
	instance._set_plant_diagnosis_open(true)
	instance.plant_diagnosis_modal.set_meta("capture_state", "phase84_marjoram_detail_trait_active_v1")
	instance.plant_diagnosis_modal.set_meta("species_id", MARJORAM_SPECIES_ID)
	instance.plant_diagnosis_modal.set_meta("behavior_id", MARJORAM_BEHAVIOR_ID)
	instance._refresh_plant_diagnosis()
	return true


func _configure_phase84_marjoram_ideal_state(marjoram: PlantSimulation) -> void:
	marjoram.health = 92.0
	marjoram.moisture = 49.0
	marjoram.nutrients = 42.0
	marjoram.ventilation = 72.0
	marjoram.humidity_percent = 48.0
	marjoram.light_lux = 15000.0
	marjoram.temperature_c = 23.0
	marjoram.ph = 6.8
	marjoram.disease_level = 0
	marjoram.disease_pressure = 0.0
	marjoram.condition_score = 0.91


func _validate_phase85_parsley_contract(instance) -> bool:
	if not instance.plant_catalog.has(PARSLEY_SPECIES_ID):
		push_error("Phase 85 capture requires the Parsley profile in the dynamic manifest.")
		return false
	if PARSLEY_SPECIES_ID not in instance.session.get_available_species() \
			or PARSLEY_SPECIES_ID not in instance.session.get_collection_species_ids() \
			or PARSLEY_SPECIES_ID not in instance.session.get_botanist_shop_species_ids():
		push_error("Phase 85 Parsley is missing from one or more runtime catalogs.")
		return false
	if not instance.seed_species_buttons.has(PARSLEY_SPECIES_ID) \
			or not instance.herbarium_cards.has(PARSLEY_SPECIES_ID) \
			or not instance.shop_seed_buttons.has(PARSLEY_SPECIES_ID) \
			or not instance.shop_owned_labels.has(PARSLEY_SPECIES_ID):
		push_error("Phase 85 Parsley is missing from one or more generic UI maps.")
		return false
	var parsley_profile: Dictionary = instance.plant_catalog.get(PARSLEY_SPECIES_ID, {})
	if str(parsley_profile.get("seed_preview_texture", "")) != str(PARSLEY_STAGE_TEXTURES["sprout"]) \
			or str(parsley_profile.get("herbarium_texture", "")) != str(PARSLEY_STAGE_TEXTURES["mature"]):
		push_error("Phase 85 Parsley preview or herbarium texture path drifted.")
		return false
	var raw_stage_textures: Variant = parsley_profile.get("stage_textures", {})
	if not raw_stage_textures is Dictionary:
		push_error("Phase 85 Parsley stage_textures must be a dictionary.")
		return false
	var stage_textures := raw_stage_textures as Dictionary
	for state_id in PARSLEY_STAGE_TEXTURES:
		if str(stage_textures.get(state_id, "")) != str(PARSLEY_STAGE_TEXTURES[state_id]):
			push_error("Phase 85 Parsley texture path drifted for state %s." % state_id)
			return false
	var definitions: Array[Dictionary] = instance.session.get_species_behavior_definitions(PARSLEY_SPECIES_ID)
	for definition in definitions:
		if str(definition.get("id", "")) != PARSLEY_BEHAVIOR_ID:
			continue
		if str(definition.get("label", "")) != PARSLEY_BEHAVIOR_LABEL:
			push_error("Phase 85 Parsley behavior label drifted from TOLERANCE POLOSTÍNU.")
			return false
		var activation: Dictionary = definition.get("activation", {})
		var effects: Dictionary = definition.get("effects", {})
		if str(activation.get("type", "")) != "daylight_light_below" \
				or not is_equal_approx(float(activation.get("threshold_lux", -1.0)), PARSLEY_LIGHT_THRESHOLD_LUX) \
				or not is_equal_approx(float(effects.get("daylight_light_factor_floor", -1.0)), PARSLEY_LIGHT_FACTOR_FLOOR):
			push_error("Phase 85 Parsley shade_tolerance contract drifted.")
			return false
		var probe := PlantSimulation.new(parsley_profile)
		probe.stage = PlantSimulation.Stage.MATURE
		probe.growth_percent = 100.0
		_configure_phase85_parsley_ideal_state(probe)
		probe._update_condition_score(0.0)
		if not is_equal_approx(probe.get_behavior_daylight_light_factor_floor(true, 4000.0), PARSLEY_LIGHT_FACTOR_FLOOR) \
				or not is_zero_approx(probe.get_behavior_daylight_light_factor_floor(false, 4000.0)) \
				or not is_zero_approx(probe.get_behavior_daylight_light_factor_floor(true, PARSLEY_LIGHT_THRESHOLD_LUX)) \
				or not is_equal_approx(probe.condition_score, PARSLEY_LIGHT_FACTOR_FLOOR):
			push_error("Phase 85 Parsley daylight shade floor is not exact in the capture fixture.")
			return false
		return true
	push_error("Phase 85 Parsley is missing behavior shade_tolerance.")
	return false


func _set_phase85_parsley_discovery(instance, discovered: bool) -> void:
	instance.session.set_seed_count(PARSLEY_SPECIES_ID, 0)
	var progress: Dictionary = instance.session.get_species_progress(PARSLEY_SPECIES_ID)
	progress["discovered"] = discovered
	progress["harvests"] = 2 if discovered else 0
	progress["best_quality"] = 0.86 if discovered else 0.0
	progress["orders_completed"] = 1 if discovered else 0
	progress["total_dry_g"] = 8.4 if discovered else 0.0
	progress["claimed_tier"] = 1
	instance.session.species_progress[PARSLEY_SPECIES_ID] = progress
	if discovered:
		instance.session.set_seed_count(PARSLEY_SPECIES_ID, 2)


func _prepare_phase85_parsley_seed_selector_state(instance, discovered: bool) -> bool:
	instance._set_plant_diagnosis_open(false)
	instance._set_herbarium_open(false)
	instance._set_botanical_pack_open(false)
	for plant in instance.session.plants:
		plant.reset()
	instance.session.journey_completed = true
	instance.session.harvest_count = maxi(1, instance.session.harvest_count)
	instance.session.xp = 400
	instance.last_xp_seen = 400
	instance.session.select_plant(0)
	_set_phase85_parsley_discovery(instance, discovered)
	instance._change_screen(0)
	instance._open_plant_detail(0)
	instance.plant_detail_panel.modulate.a = 1.0
	instance._set_seed_selector_open(true)
	instance._refresh_ui()
	instance.seed_selector_modal.set_meta(
		"capture_state",
		"phase85_parsley_seed_selector_discovered_v1" if discovered else "phase85_parsley_seed_selector_locked_v1"
	)
	instance.seed_selector_modal.set_meta("species_id", PARSLEY_SPECIES_ID)
	var button := instance.seed_species_buttons.get(PARSLEY_SPECIES_ID) as Button
	if button == null or button.disabled == discovered:
		push_error("Phase 85 Parsley seed selector lock state is incorrect.")
		return false
	return true


func _prepare_phase85_parsley_herbarium_state(instance, discovered: bool) -> bool:
	instance._set_seed_selector_open(false)
	_set_phase85_parsley_discovery(instance, discovered)
	instance._set_herbarium_open(true)
	instance._refresh_ui()
	instance.herbarium_modal.set_meta(
		"capture_state",
		"phase85_parsley_herbarium_discovered_v1" if discovered else "phase85_parsley_herbarium_locked_v1"
	)
	instance.herbarium_modal.set_meta("species_id", PARSLEY_SPECIES_ID)
	var card: Dictionary = instance.herbarium_cards.get(PARSLEY_SPECIES_ID, {})
	var name_label := card.get("name") as Label
	var behavior_label := card.get("behavior") as Label
	if name_label == null or behavior_label == null:
		push_error("Phase 85 Parsley herbarium card is incomplete.")
		return false
	if discovered:
		var profile: Dictionary = instance.plant_catalog.get(PARSLEY_SPECIES_ID, {})
		var expected_name := str(profile.get("short_name", profile.get("display_name", ""))).to_upper()
		if expected_name.is_empty() or expected_name not in name_label.text \
				or not behavior_label.visible or PARSLEY_BEHAVIOR_LABEL not in behavior_label.text:
			push_error("Phase 85 discovered Parsley card does not reveal its identity and trait.")
			return false
	elif name_label.text != "NEOBJEVENÁ BYLINKA" or behavior_label.visible or not behavior_label.text.is_empty():
		push_error("Phase 85 locked Parsley herbarium card leaks its identity or trait.")
		return false
	return true


func _prepare_phase85_parsley_shop_state(instance) -> bool:
	instance._set_seed_selector_open(false)
	instance._set_herbarium_open(false)
	instance.session.xp = 400
	instance.last_xp_seen = 400
	instance.session.coins = 110
	instance.last_coins_seen = 110
	instance.session.set_seed_count(PARSLEY_SPECIES_ID, 1)
	instance.session.shop_stock_day = 2147483647
	instance.session.shop_stock.clear()
	for species_id in instance.session.get_botanist_shop_species_ids():
		instance.session.shop_stock[instance.session.get_shop_seed_item_id(species_id)] = 1
	instance.session.shop_stock[GameSession.SHOP_FERTILIZER_ITEM_ID] = 2
	instance._set_shop_legacy_capture(false)
	instance._set_shop_mode("buy")
	instance._set_shop_category("all")
	instance._change_screen(2)
	instance._refresh_ui()
	instance._set_coin_count(float(instance.session.coins))
	instance.shop_runtime_layout.set_meta("capture_state", "phase85_parsley_shop_stock_v1")
	instance.shop_runtime_layout.set_meta("species_id", PARSLEY_SPECIES_ID)
	var button := instance.shop_seed_buttons.get(PARSLEY_SPECIES_ID) as Button
	var owned := instance.shop_owned_labels.get(PARSLEY_SPECIES_ID) as Label
	if button == null or owned == null or button.disabled \
			or instance.session.get_shop_stock(instance.session.get_shop_seed_item_id(PARSLEY_SPECIES_ID)) != 1:
		push_error("Phase 85 Parsley shop tile is not unlocked and stocked.")
		return false
	return true


func _prepare_phase85_parsley_room_state(instance) -> bool:
	instance._set_seed_selector_open(false)
	instance._set_herbarium_open(false)
	instance._set_plant_diagnosis_open(false)
	for plant in instance.session.plants:
		plant.reset()
	var parsley_profile: Dictionary = instance.plant_catalog.get(PARSLEY_SPECIES_ID, {})
	if parsley_profile.is_empty():
		push_error("Phase 85 Parsley room capture has no profile.")
		return false
	instance.session.xp = 400
	instance.last_xp_seen = 400
	var parsley: PlantSimulation = instance.session.plants[0]
	parsley.configure_profile(parsley_profile)
	var harvest_days := maxf(1.0, float(parsley_profile.get("biological_days_to_harvest", 70.0)))
	_set_stage(parsley, PlantSimulation.Stage.MATURE, 100.0, 92.0, harvest_days)
	_configure_phase85_parsley_ideal_state(parsley)
	parsley._update_condition_score(0.0)
	instance.session.select_plant(0)
	instance._change_screen(0)
	instance._open_room()
	instance.room_overview.previous_unlocked_count = 5
	instance.room_overview.displayed_growth_percent = 100.0
	instance.room_overview.set_meta("capture_state", "phase85_parsley_room_mature_v1")
	instance.room_overview.set_meta("species_id", PARSLEY_SPECIES_ID)
	instance.room_overview.refresh()
	instance._refresh_ui()
	return parsley.get_species_id() == PARSLEY_SPECIES_ID


func _prepare_phase85_parsley_detail_trait_state(instance) -> bool:
	if not _prepare_phase85_parsley_room_state(instance):
		return false
	var parsley: PlantSimulation = instance.session.plant
	var harvest_days := maxf(1.0, float(parsley.profile.get("biological_days_to_harvest", 70.0)))
	_set_stage(parsley, PlantSimulation.Stage.MATURE, 100.0, 92.0, harvest_days)
	_configure_phase85_parsley_ideal_state(parsley)
	parsley.mature_elapsed_seconds = 0.0
	parsley._update_condition_score(0.0)
	instance._open_plant_detail(0)
	instance.plant_detail_panel.modulate.a = 1.0
	instance.plant_behavior_presenter.reset_observation()
	instance._refresh_ui()
	var active_trait := false
	for entry in parsley.get_behavior_status_entries():
		if str(entry.get("id", "")) == PARSLEY_BEHAVIOR_ID \
				and bool(entry.get("active", false)) \
				and str(entry.get("label", "")) == PARSLEY_BEHAVIOR_LABEL:
			active_trait = true
			break
	if not active_trait \
			or not is_equal_approx(parsley.get_behavior_daylight_light_factor_floor(true, 4000.0), PARSLEY_LIGHT_FACTOR_FLOOR) \
			or not is_equal_approx(parsley.condition_score, PARSLEY_LIGHT_FACTOR_FLOOR):
		push_error("Phase 85 Parsley shade_tolerance trait is not active in the detail fixture.")
		return false
	instance._set_plant_diagnosis_open(true)
	instance.plant_diagnosis_modal.set_meta("capture_state", "phase85_parsley_detail_trait_active_v1")
	instance.plant_diagnosis_modal.set_meta("species_id", PARSLEY_SPECIES_ID)
	instance.plant_diagnosis_modal.set_meta("behavior_id", PARSLEY_BEHAVIOR_ID)
	instance._refresh_plant_diagnosis()
	return true


func _configure_phase85_parsley_ideal_state(parsley: PlantSimulation) -> void:
	parsley.health = 92.0
	parsley.moisture = 60.0
	parsley.nutrients = 52.0
	parsley.ventilation = 72.0
	parsley.humidity_percent = 54.0
	parsley.light_lux = 4000.0
	parsley.temperature_c = 21.0
	parsley.ph = 6.5
	parsley.disease_level = 0
	parsley.disease_pressure = 0.0
	parsley.condition_score = PARSLEY_LIGHT_FACTOR_FLOOR


func _validate_phase86_lemon_balm_contract(instance) -> bool:
	if not instance.plant_catalog.has(LEMON_BALM_SPECIES_ID):
		push_error("Phase 86 capture requires the Lemon Balm profile in the dynamic manifest.")
		return false
	if LEMON_BALM_SPECIES_ID not in instance.session.get_available_species() \
			or LEMON_BALM_SPECIES_ID not in instance.session.get_collection_species_ids() \
			or LEMON_BALM_SPECIES_ID not in instance.session.get_botanist_shop_species_ids():
		push_error("Phase 86 Lemon Balm is missing from one or more runtime catalogs.")
		return false
	if not instance.seed_species_buttons.has(LEMON_BALM_SPECIES_ID) \
			or not instance.herbarium_cards.has(LEMON_BALM_SPECIES_ID) \
			or not instance.shop_seed_buttons.has(LEMON_BALM_SPECIES_ID) \
			or not instance.shop_owned_labels.has(LEMON_BALM_SPECIES_ID):
		push_error("Phase 86 Lemon Balm is missing from one or more generic UI maps.")
		return false
	var lemon_balm_profile: Dictionary = instance.plant_catalog.get(LEMON_BALM_SPECIES_ID, {})
	if str(lemon_balm_profile.get("seed_preview_texture", "")) != str(LEMON_BALM_STAGE_TEXTURES["sprout"]) \
			or str(lemon_balm_profile.get("herbarium_texture", "")) != str(LEMON_BALM_STAGE_TEXTURES["mature"]):
		push_error("Phase 86 Lemon Balm preview or herbarium texture path drifted.")
		return false
	var raw_stage_textures: Variant = lemon_balm_profile.get("stage_textures", {})
	if not raw_stage_textures is Dictionary:
		push_error("Phase 86 Lemon Balm stage_textures must be a dictionary.")
		return false
	var stage_textures := raw_stage_textures as Dictionary
	for state_id in LEMON_BALM_STAGE_TEXTURES:
		if str(stage_textures.get(state_id, "")) != str(LEMON_BALM_STAGE_TEXTURES[state_id]):
			push_error("Phase 86 Lemon Balm texture path drifted for state %s." % state_id)
			return false
	var definitions: Array[Dictionary] = instance.session.get_species_behavior_definitions(LEMON_BALM_SPECIES_ID)
	for definition in definitions:
		if str(definition.get("id", "")) != LEMON_BALM_BEHAVIOR_ID:
			continue
		if str(definition.get("label", "")) != LEMON_BALM_BEHAVIOR_LABEL:
			push_error("Phase 86 Lemon Balm behavior label drifted from BOHATÝ SAMOVÝSEV.")
			return false
		var activation: Dictionary = definition.get("activation", {})
		var effects: Dictionary = definition.get("effects", {})
		if str(activation.get("type", "")) != "sale_seed_drop" \
				or not is_equal_approx(float(effects.get("seed_drop_chance_bonus", -1.0)), LEMON_BALM_SEED_DROP_BONUS) \
				or not bool(effects.get("once_per_sale", false)):
			push_error("Phase 86 Lemon Balm self_seeding contract drifted.")
			return false
		var probe := PlantSimulation.new(lemon_balm_profile)
		probe.stage = PlantSimulation.Stage.PACKAGED
		_configure_phase86_lemon_balm_ideal_state(probe)
		var active_status: Array[Dictionary] = probe.get_behavior_status_entries()
		if not is_equal_approx(probe.get_seed_drop_chance(BASE_SEED_DROP_CHANCE), LEMON_BALM_SEED_DROP_CHANCE) \
				or active_status.size() != 1 \
				or not bool(active_status[0].get("active", false)):
			push_error("Phase 86 Lemon Balm 75 percent sale seed drop is not exact in the capture fixture.")
			return false
		probe.stage = PlantSimulation.Stage.EMPTY
		if not is_equal_approx(probe.get_seed_drop_chance(BASE_SEED_DROP_CHANCE), BASE_SEED_DROP_CHANCE):
			push_error("Phase 86 Lemon Balm applies self-seeding to an empty pot.")
			return false
		return true
	push_error("Phase 86 Lemon Balm is missing behavior self_seeding.")
	return false


func _set_phase86_lemon_balm_discovery(instance, discovered: bool) -> void:
	instance.session.set_seed_count(LEMON_BALM_SPECIES_ID, 0)
	var progress: Dictionary = instance.session.get_species_progress(LEMON_BALM_SPECIES_ID)
	progress["discovered"] = discovered
	progress["harvests"] = 2 if discovered else 0
	progress["best_quality"] = 0.88 if discovered else 0.0
	progress["orders_completed"] = 1 if discovered else 0
	progress["total_dry_g"] = 9.2 if discovered else 0.0
	progress["claimed_tier"] = 1
	instance.session.species_progress[LEMON_BALM_SPECIES_ID] = progress
	if discovered:
		instance.session.set_seed_count(LEMON_BALM_SPECIES_ID, 2)


func _prepare_phase86_lemon_balm_seed_selector_state(instance, discovered: bool) -> bool:
	instance._set_plant_diagnosis_open(false)
	instance._set_herbarium_open(false)
	instance._set_botanical_pack_open(false)
	for plant in instance.session.plants:
		plant.reset()
	instance.session.journey_completed = true
	instance.session.harvest_count = maxi(1, instance.session.harvest_count)
	instance.session.xp = 400
	instance.last_xp_seen = 400
	instance.session.select_plant(0)
	_set_phase86_lemon_balm_discovery(instance, discovered)
	instance._change_screen(0)
	instance._open_plant_detail(0)
	instance.plant_detail_panel.modulate.a = 1.0
	instance._set_seed_selector_open(true)
	instance._refresh_ui()
	instance.seed_selector_modal.set_meta(
		"capture_state",
		"phase86_lemon_balm_seed_selector_discovered_v1" if discovered else "phase86_lemon_balm_seed_selector_locked_v1"
	)
	instance.seed_selector_modal.set_meta("species_id", LEMON_BALM_SPECIES_ID)
	var button := instance.seed_species_buttons.get(LEMON_BALM_SPECIES_ID) as Button
	if button == null or button.disabled == discovered:
		push_error("Phase 86 Lemon Balm seed selector lock state is incorrect.")
		return false
	return true


func _prepare_phase86_lemon_balm_herbarium_state(instance, discovered: bool) -> bool:
	instance._set_seed_selector_open(false)
	_set_phase86_lemon_balm_discovery(instance, discovered)
	instance._set_herbarium_open(true)
	instance._refresh_ui()
	instance.herbarium_modal.set_meta(
		"capture_state",
		"phase86_lemon_balm_herbarium_discovered_v1" if discovered else "phase86_lemon_balm_herbarium_locked_v1"
	)
	instance.herbarium_modal.set_meta("species_id", LEMON_BALM_SPECIES_ID)
	var card: Dictionary = instance.herbarium_cards.get(LEMON_BALM_SPECIES_ID, {})
	var name_label := card.get("name") as Label
	var behavior_label := card.get("behavior") as Label
	if name_label == null or behavior_label == null:
		push_error("Phase 86 Lemon Balm herbarium card is incomplete.")
		return false
	if discovered:
		var profile: Dictionary = instance.plant_catalog.get(LEMON_BALM_SPECIES_ID, {})
		var expected_name := str(profile.get("short_name", profile.get("display_name", ""))).to_upper()
		if expected_name.is_empty() or expected_name not in name_label.text \
				or not behavior_label.visible or LEMON_BALM_BEHAVIOR_LABEL not in behavior_label.text:
			push_error("Phase 86 discovered Lemon Balm card does not reveal its identity and trait.")
			return false
	elif name_label.text != "NEOBJEVENÁ BYLINKA" or behavior_label.visible or not behavior_label.text.is_empty():
		push_error("Phase 86 locked Lemon Balm herbarium card leaks its identity or trait.")
		return false
	return true


func _prepare_phase86_lemon_balm_shop_state(instance) -> bool:
	instance._set_seed_selector_open(false)
	instance._set_herbarium_open(false)
	instance.session.xp = 400
	instance.last_xp_seen = 400
	instance.session.coins = 110
	instance.last_coins_seen = 110
	instance.session.set_seed_count(LEMON_BALM_SPECIES_ID, 1)
	instance.session.shop_stock_day = 2147483647
	instance.session.shop_stock.clear()
	for species_id in instance.session.get_botanist_shop_species_ids():
		instance.session.shop_stock[instance.session.get_shop_seed_item_id(species_id)] = 1
	instance.session.shop_stock[GameSession.SHOP_FERTILIZER_ITEM_ID] = 2
	instance._set_shop_legacy_capture(false)
	instance._set_shop_mode("buy")
	instance._set_shop_category("all")
	instance._change_screen(2)
	instance._refresh_ui()
	instance._set_coin_count(float(instance.session.coins))
	instance.shop_runtime_layout.set_meta("capture_state", "phase86_lemon_balm_shop_stock_v1")
	instance.shop_runtime_layout.set_meta("species_id", LEMON_BALM_SPECIES_ID)
	var button := instance.shop_seed_buttons.get(LEMON_BALM_SPECIES_ID) as Button
	var owned := instance.shop_owned_labels.get(LEMON_BALM_SPECIES_ID) as Label
	if button == null or owned == null or button.disabled \
			or instance.session.get_shop_stock(instance.session.get_shop_seed_item_id(LEMON_BALM_SPECIES_ID)) != 1:
		push_error("Phase 86 Lemon Balm shop tile is not unlocked and stocked.")
		return false
	return true


func _prepare_phase86_lemon_balm_room_state(instance) -> bool:
	instance._set_seed_selector_open(false)
	instance._set_herbarium_open(false)
	instance._set_plant_diagnosis_open(false)
	for plant in instance.session.plants:
		plant.reset()
	var lemon_balm_profile: Dictionary = instance.plant_catalog.get(LEMON_BALM_SPECIES_ID, {})
	if lemon_balm_profile.is_empty():
		push_error("Phase 86 Lemon Balm room capture has no profile.")
		return false
	instance.session.xp = 400
	instance.last_xp_seen = 400
	var lemon_balm: PlantSimulation = instance.session.plants[0]
	lemon_balm.configure_profile(lemon_balm_profile)
	var harvest_days := maxf(1.0, float(lemon_balm_profile.get("biological_days_to_harvest", 70.0)))
	_set_stage(lemon_balm, PlantSimulation.Stage.MATURE, 100.0, 94.0, harvest_days)
	_configure_phase86_lemon_balm_ideal_state(lemon_balm)
	lemon_balm._update_condition_score(0.0)
	instance.session.select_plant(0)
	instance._change_screen(0)
	instance._open_room()
	instance.room_overview.previous_unlocked_count = 5
	instance.room_overview.displayed_growth_percent = 100.0
	instance.room_overview.set_meta("capture_state", "phase86_lemon_balm_room_mature_v1")
	instance.room_overview.set_meta("species_id", LEMON_BALM_SPECIES_ID)
	instance.room_overview.refresh()
	instance._refresh_ui()
	return lemon_balm.get_species_id() == LEMON_BALM_SPECIES_ID


func _prepare_phase86_lemon_balm_detail_trait_state(instance) -> bool:
	if not _prepare_phase86_lemon_balm_room_state(instance):
		return false
	var lemon_balm: PlantSimulation = instance.session.plant
	var harvest_days := maxf(1.0, float(lemon_balm.profile.get("biological_days_to_harvest", 70.0)))
	_set_stage(lemon_balm, PlantSimulation.Stage.MATURE, 100.0, 94.0, harvest_days)
	_configure_phase86_lemon_balm_ideal_state(lemon_balm)
	lemon_balm.mature_elapsed_seconds = 0.0
	lemon_balm._update_condition_score(0.0)
	instance._open_plant_detail(0)
	instance.plant_detail_panel.modulate.a = 1.0
	instance.plant_behavior_presenter.reset_observation()
	instance._refresh_ui()
	var active_trait := false
	for entry in lemon_balm.get_behavior_status_entries():
		if str(entry.get("id", "")) == LEMON_BALM_BEHAVIOR_ID \
				and bool(entry.get("active", false)) \
				and str(entry.get("label", "")) == LEMON_BALM_BEHAVIOR_LABEL:
			active_trait = true
			break
	if not active_trait \
			or not is_equal_approx(lemon_balm.get_seed_drop_chance(BASE_SEED_DROP_CHANCE), LEMON_BALM_SEED_DROP_CHANCE):
		push_error("Phase 86 Lemon Balm self_seeding trait is not active in the detail fixture.")
		return false
	instance._set_plant_diagnosis_open(true)
	instance.plant_diagnosis_modal.set_meta("capture_state", "phase86_lemon_balm_detail_trait_active_v1")
	instance.plant_diagnosis_modal.set_meta("species_id", LEMON_BALM_SPECIES_ID)
	instance.plant_diagnosis_modal.set_meta("behavior_id", LEMON_BALM_BEHAVIOR_ID)
	instance._refresh_plant_diagnosis()
	return true


func _configure_phase86_lemon_balm_ideal_state(lemon_balm: PlantSimulation) -> void:
	lemon_balm.health = 94.0
	lemon_balm.moisture = 58.0
	lemon_balm.nutrients = 50.0
	lemon_balm.ventilation = 72.0
	lemon_balm.humidity_percent = 54.0
	lemon_balm.light_lux = 12000.0
	lemon_balm.temperature_c = 22.0
	lemon_balm.ph = 6.6
	lemon_balm.disease_level = 0
	lemon_balm.disease_pressure = 0.0
	lemon_balm.condition_score = 0.94


func _validate_phase95_sage_contract(instance) -> bool:
	if not instance.plant_catalog.has(SAGE_SPECIES_ID):
		push_error("Phase 95 capture requires the Sage profile in the dynamic manifest.")
		return false
	if SAGE_SPECIES_ID not in instance.session.get_available_species() \
			or SAGE_SPECIES_ID not in instance.session.get_collection_species_ids() \
			or SAGE_SPECIES_ID not in instance.session.get_botanist_shop_species_ids():
		push_error("Phase 95 Sage is missing from one or more runtime catalogs.")
		return false
	if not instance.seed_species_buttons.has(SAGE_SPECIES_ID) \
			or not instance.herbarium_cards.has(SAGE_SPECIES_ID) \
			or not instance.shop_seed_buttons.has(SAGE_SPECIES_ID) \
			or not instance.shop_owned_labels.has(SAGE_SPECIES_ID):
		push_error("Phase 95 Sage is missing from one or more generic UI maps.")
		return false
	var sage_profile: Dictionary = instance.plant_catalog.get(SAGE_SPECIES_ID, {})
	if str(sage_profile.get("rarity", "")) != "rare":
		push_error("Phase 95 Sage must retain Rare rarity.")
		return false
	var rarity: Dictionary = instance.session.get_species_rarity_definition(SAGE_SPECIES_ID)
	if int(rarity.get("stars", 0)) != 2 or str(rarity.get("label", "")) != "VZÁCNÁ":
		push_error("Phase 95 Sage rarity presentation must be two-star VZÁCNÁ.")
		return false
	if str(sage_profile.get("seed_preview_texture", "")) != str(SAGE_STAGE_TEXTURES["sprout"]) \
			or str(sage_profile.get("herbarium_texture", "")) != str(SAGE_STAGE_TEXTURES["mature"]):
		push_error("Phase 95 Sage preview or herbarium texture path drifted.")
		return false
	var raw_stage_textures: Variant = sage_profile.get("stage_textures", {})
	if not raw_stage_textures is Dictionary:
		push_error("Phase 95 Sage stage_textures must be a dictionary.")
		return false
	var stage_textures := raw_stage_textures as Dictionary
	for state_id in SAGE_STAGE_TEXTURES:
		if str(stage_textures.get(state_id, "")) != str(SAGE_STAGE_TEXTURES[state_id]):
			push_error("Phase 95 Sage texture path drifted for state %s." % state_id)
			return false
	var definitions: Array[Dictionary] = instance.session.get_species_behavior_definitions(SAGE_SPECIES_ID)
	for definition in definitions:
		if str(definition.get("id", "")) != SAGE_BEHAVIOR_ID:
			continue
		if str(definition.get("label", "")) != SAGE_BEHAVIOR_LABEL:
			push_error("Phase 95 Sage behavior label drifted from STŘÍDMÁ VÝŽIVA.")
			return false
		var activation: Dictionary = definition.get("activation", {})
		var effects: Dictionary = definition.get("effects", {})
		if str(activation.get("type", "")) != "growth_value_in_profile_band" \
				or str(activation.get("value", "")) != "nutrients" \
				or str(activation.get("minimum_field", "")) != "ideal_nutrients_min" \
				or str(activation.get("maximum_field", "")) != "ideal_nutrients_max" \
				or not is_equal_approx(float(effects.get("nutrient_loss_multiplier", -1.0)), SAGE_NUTRIENT_LOSS_MULTIPLIER):
			push_error("Phase 95 Sage modest_feeding contract drifted.")
			return false
		var probe := PlantSimulation.new(sage_profile)
		probe.stage = PlantSimulation.Stage.MATURE
		_configure_phase95_sage_ideal_state(probe)
		var base_loss := float(sage_profile.get("nutrient_loss_per_hour", 0.0))
		if not is_equal_approx(probe.get_effective_nutrient_loss_per_hour(), base_loss * SAGE_NUTRIENT_LOSS_MULTIPLIER):
			push_error("Phase 95 Sage nutrient reduction is not exact inside the ideal band.")
			return false
		probe.nutrients = float(sage_profile.get("ideal_nutrients_max", 60.0)) + 1.0
		if not is_equal_approx(probe.get_effective_nutrient_loss_per_hour(), base_loss):
			push_error("Phase 95 Sage nutrient reduction leaks outside the ideal band.")
			return false
		return true
	push_error("Phase 95 Sage is missing behavior modest_feeding.")
	return false


func _set_phase95_sage_discovery(instance, discovered: bool) -> void:
	instance.session.set_seed_count(SAGE_SPECIES_ID, 0)
	var progress: Dictionary = instance.session.get_species_progress(SAGE_SPECIES_ID)
	progress["discovered"] = discovered
	progress["harvests"] = 3 if discovered else 0
	progress["best_quality"] = 0.93 if discovered else 0.0
	progress["orders_completed"] = 2 if discovered else 0
	progress["total_dry_g"] = 14.4 if discovered else 0.0
	progress["claimed_tier"] = 2 if discovered else 1
	instance.session.species_progress[SAGE_SPECIES_ID] = progress
	if discovered:
		instance.session.set_seed_count(SAGE_SPECIES_ID, 2)


func _prepare_phase95_sage_seed_selector_state(instance, discovered: bool) -> bool:
	instance._set_professor_story_open(false)
	instance._set_plant_diagnosis_open(false)
	instance._set_herbarium_open(false)
	instance._set_botanical_pack_open(false)
	for plant in instance.session.plants:
		plant.reset()
	instance.session.journey_completed = true
	instance.session.harvest_count = maxi(1, instance.session.harvest_count)
	instance.session.xp = 700
	instance.last_xp_seen = 700
	instance.session.select_plant(0)
	_set_phase95_sage_discovery(instance, discovered)
	instance._change_screen(0)
	instance._open_plant_detail(0)
	instance.plant_detail_panel.modulate.a = 1.0
	instance._set_seed_selector_open(true)
	instance._refresh_ui()
	instance.seed_selector_modal.set_meta(
		"capture_state",
		"phase95_sage_seed_selector_discovered_report_only_v1" if discovered else "phase95_sage_seed_selector_locked_report_only_v1"
	)
	instance.seed_selector_modal.set_meta("species_id", SAGE_SPECIES_ID)
	var button := instance.seed_species_buttons.get(SAGE_SPECIES_ID) as Button
	if button == null or button.disabled == discovered:
		push_error("Phase 95 Sage seed selector lock state is incorrect.")
		return false
	return true


func _prepare_phase95_sage_herbarium_state(instance, discovered: bool) -> bool:
	instance._set_seed_selector_open(false)
	_set_phase95_sage_discovery(instance, discovered)
	instance._set_herbarium_open(true)
	instance._refresh_ui()
	instance.herbarium_modal.set_meta(
		"capture_state",
		"phase95_sage_herbarium_discovered_report_only_v1" if discovered else "phase95_sage_herbarium_locked_report_only_v1"
	)
	instance.herbarium_modal.set_meta("species_id", SAGE_SPECIES_ID)
	var card: Dictionary = instance.herbarium_cards.get(SAGE_SPECIES_ID, {})
	var panel := card.get("panel") as Control
	var name_label := card.get("name") as Label
	var rarity_label := card.get("rarity") as Label
	var behavior_label := card.get("behavior") as Label
	if panel == null or name_label == null or rarity_label == null or behavior_label == null:
		push_error("Phase 95 Sage herbarium card is incomplete.")
		return false
	if discovered:
		var profile: Dictionary = instance.plant_catalog.get(SAGE_SPECIES_ID, {})
		var expected_name := str(profile.get("short_name", profile.get("display_name", ""))).to_upper()
		if expected_name.is_empty() or expected_name not in name_label.text \
				or rarity_label.text != "★★  ·  VZÁCNÁ" \
				or not behavior_label.visible or SAGE_BEHAVIOR_LABEL not in behavior_label.text:
			push_error("Phase 95 discovered Sage card does not reveal its Rare identity and trait.")
			return false
	elif name_label.text != "NEOBJEVENÁ BYLINKA" or behavior_label.visible or not behavior_label.text.is_empty():
		push_error("Phase 95 locked Sage herbarium card leaks its identity or trait.")
		return false
	return true


func _prepare_phase95_sage_shop_state(instance) -> bool:
	instance._set_seed_selector_open(false)
	instance._set_herbarium_open(false)
	instance.session.xp = 700
	instance.last_xp_seen = 700
	instance.session.coins = 160
	instance.last_coins_seen = 160
	instance.session.set_seed_count(SAGE_SPECIES_ID, 1)
	instance.session.shop_stock_day = 2147483647
	instance.session.shop_stock.clear()
	for species_id in instance.session.get_botanist_shop_species_ids():
		instance.session.shop_stock[instance.session.get_shop_seed_item_id(species_id)] = 1
	instance.session.shop_stock[GameSession.SHOP_FERTILIZER_ITEM_ID] = 2
	instance._set_shop_legacy_capture(false)
	instance._set_shop_mode("buy")
	instance._set_shop_category("all")
	instance._change_screen(2)
	instance._refresh_ui()
	instance._set_coin_count(float(instance.session.coins))
	instance.shop_runtime_layout.set_meta("capture_state", "phase95_sage_shop_stock_report_only_v1")
	instance.shop_runtime_layout.set_meta("species_id", SAGE_SPECIES_ID)
	var button := instance.shop_seed_buttons.get(SAGE_SPECIES_ID) as Button
	var owned := instance.shop_owned_labels.get(SAGE_SPECIES_ID) as Label
	if button == null or owned == null or button.disabled \
			or instance.session.get_shop_stock(instance.session.get_shop_seed_item_id(SAGE_SPECIES_ID)) != 1:
		push_error("Phase 95 Sage shop tile is not unlocked and stocked.")
		return false
	return true


func _prepare_phase95_sage_room_state(instance) -> bool:
	instance._set_seed_selector_open(false)
	instance._set_herbarium_open(false)
	instance._set_plant_diagnosis_open(false)
	for plant in instance.session.plants:
		plant.reset()
	var sage_profile: Dictionary = instance.plant_catalog.get(SAGE_SPECIES_ID, {})
	if sage_profile.is_empty():
		push_error("Phase 95 Sage room capture has no profile.")
		return false
	instance.session.xp = 700
	instance.last_xp_seen = 700
	var sage: PlantSimulation = instance.session.plants[0]
	sage.configure_profile(sage_profile)
	var harvest_days := maxf(1.0, float(sage_profile.get("biological_days_to_harvest", 75.0)))
	_set_stage(sage, PlantSimulation.Stage.MATURE, 100.0, 94.0, harvest_days)
	_configure_phase95_sage_ideal_state(sage)
	sage._update_condition_score(0.0)
	instance.session.select_plant(0)
	instance._change_screen(0)
	instance._open_room()
	instance.room_overview.previous_unlocked_count = 7
	instance.room_overview.displayed_growth_percent = 100.0
	instance.room_overview.set_meta("capture_state", "phase95_sage_room_mature_report_only_v1")
	instance.room_overview.set_meta("species_id", SAGE_SPECIES_ID)
	instance.room_overview.refresh()
	instance._refresh_ui()
	return sage.get_species_id() == SAGE_SPECIES_ID


func _prepare_phase95_sage_detail_trait_state(instance) -> bool:
	if not _prepare_phase95_sage_room_state(instance):
		return false
	var sage: PlantSimulation = instance.session.plant
	var harvest_days := maxf(1.0, float(sage.profile.get("biological_days_to_harvest", 75.0)))
	_set_stage(sage, PlantSimulation.Stage.MATURE, 100.0, 94.0, harvest_days)
	_configure_phase95_sage_ideal_state(sage)
	sage.mature_elapsed_seconds = 0.0
	sage._update_condition_score(0.0)
	instance._open_plant_detail(0)
	instance.plant_detail_panel.modulate.a = 1.0
	instance.plant_behavior_presenter.reset_observation()
	instance._refresh_ui()
	var active_trait := false
	for entry in sage.get_behavior_status_entries():
		if str(entry.get("id", "")) == SAGE_BEHAVIOR_ID \
				and bool(entry.get("active", false)) \
				and str(entry.get("label", "")) == SAGE_BEHAVIOR_LABEL:
			active_trait = true
			break
	var base_loss := float(sage.profile.get("nutrient_loss_per_hour", 0.0))
	if not active_trait \
			or not is_equal_approx(sage.get_effective_nutrient_loss_per_hour(), base_loss * SAGE_NUTRIENT_LOSS_MULTIPLIER):
		push_error("Phase 95 Sage modest_feeding trait is not active in the detail fixture.")
		return false
	instance._set_plant_diagnosis_open(true)
	instance.plant_diagnosis_modal.set_meta("capture_state", "phase95_sage_detail_trait_active_report_only_v1")
	instance.plant_diagnosis_modal.set_meta("species_id", SAGE_SPECIES_ID)
	instance.plant_diagnosis_modal.set_meta("behavior_id", SAGE_BEHAVIOR_ID)
	instance._refresh_plant_diagnosis()
	return _find_diagnosis_behavior_card(instance) != null


func _configure_phase95_sage_ideal_state(sage: PlantSimulation) -> void:
	sage.health = 94.0
	sage.moisture = 44.0
	sage.nutrients = 44.0
	sage.ventilation = 74.0
	sage.humidity_percent = 46.0
	sage.light_lux = 17000.0
	sage.temperature_c = 23.0
	sage.ph = 6.6
	sage.disease_level = 0
	sage.disease_pressure = 0.0
	sage.condition_score = 0.94


func _prepare_phase96_herbal_blend_order_state(instance) -> bool:
	instance._set_professor_story_open(false)
	instance._set_plant_diagnosis_open(false)
	instance._set_herbarium_open(false)
	instance._set_botanical_pack_open(false)
	instance._set_seed_selector_open(false)
	instance.session.paused = true
	instance.session.xp = 700
	instance.last_xp_seen = 700
	for slot in instance.session.plants:
		slot.reset()

	var recipe_species := [
		"mint_peppermint",
		"melissa_officinalis",
		"petroselinum_crispum",
		"origanum_majorana",
		"lavandula_angustifolia",
		"rosemary_officinalis",
	]
	for species_id in recipe_species:
		if not instance.plant_catalog.has(species_id):
			push_error("Phase 96 blend capture is missing recipe species %s." % species_id)
			return false
		instance.session._discover_species(species_id)

	# The first recipe is ready in slots 1 and 2. The selected third slot is an
	# unrelated Basil package, proving that blend readiness is resolved across
	# unlocked slots rather than interpreted from the selected plant in the UI.
	_configure_phase96_package(instance, 0, "mint_peppermint", 4.8, 0.88)
	_configure_phase96_package(instance, 1, "melissa_officinalis", 5.0, 0.86)
	_configure_phase96_package(instance, 2, "basil_genovese", 5.8, 0.91)
	# The remaining two recipes deliberately have only their second package.
	# Their first missing requirement therefore produces an exact, readable
	# Petržel/Levandule status without inventing any recipe logic in the panel.
	_configure_phase96_package(instance, 3, "origanum_majorana", 5.2, 0.88)
	_configure_phase96_package(instance, 4, "rosemary_officinalis", 5.1, 0.87)
	if not instance.session.select_plant(2):
		push_error("Phase 96 blend capture could not select the unrelated package slot.")
		return false

	# Phase 96 owns the stable sequence range 12..14. Later append-only order
	# templates must not move this report-only capture to another recipe family.
	var blend_start_sequence := GameSession.LEGACY_SINGLE_ORDER_TEMPLATE_COUNT
	instance.session.orders.clear()
	instance.session.order_rotation = blend_start_sequence
	instance.session._ensure_orders()
	var expected_blend_ids := ["evening_freshness", "soup_pair", "aromatic_sachet"]
	var expected_requirements := [
		"SMĚS · 2 BYLINY\nMÁTA · 4,0 g · kvalita 74 %\nMEDUŇKA · 4,5 g · kvalita 74 %",
		"SMĚS · 2 BYLINY\nPETRŽEL · 4,2 g · kvalita 76 %\nMAJORÁNKA · 4,8 g · kvalita 78 %",
		"SMĚS · 2 BYLINY\nLEVANDULE · 5,5 g · kvalita 82 %\nROZMARÝN · 4,8 g · kvalita 78 %",
	]
	if instance.session.orders.size() != expected_blend_ids.size():
		push_error("Phase 96 blend capture requires exactly three canonical recipes.")
		return false
	for index in range(expected_blend_ids.size()):
		if not instance.session.is_blend_order(index) \
				or str(instance.session.orders[index].get("blend_id", "")) != expected_blend_ids[index] \
				or instance.session.get_order_requirement_text(index) != expected_requirements[index]:
			push_error("Phase 96 blend capture recipe %d drifted from its canonical contract." % index)
			return false

	var ready_plan: Dictionary = instance.session.get_order_fulfillment_plan(0)
	if not bool(ready_plan.get("can_fulfill", false)) \
			or ready_plan.get("slot_indices", []) != [0, 1] \
			or instance.session.can_fulfill_order(1) \
			or instance.session.can_fulfill_order(2) \
			or instance.session.get_order_status(1) != "Chybí balíček: Petržel" \
			or instance.session.get_order_status(2) != "Chybí balíček: Levandule":
		push_error("Phase 96 blend capture did not resolve one ready and two intentional missing-package recipes.")
		return false

	instance.customer_orders_panel.visible = true
	instance._prepare_customer_orders_capture()
	var board = instance.customer_orders_panel
	if str(board.get_meta("order_contract", "")) != "multi_species_blends_v1" \
			or board.card_panels.size() != GameSession.ACTIVE_ORDER_COUNT \
			or board.action_buttons[0].text != "ODEVZDAT 2×" \
			or board.action_buttons[0].disabled \
			or board.action_buttons[1].text != "ČEKÁ" \
			or not board.action_buttons[1].disabled:
		push_error("Phase 96 blend board did not expose its ready and waiting actions safely.")
		return false
	for card in board.card_panels:
		if str(card.get_meta("order_kind", "")) != "blend":
			push_error("Phase 96 blend board card is missing order_kind=blend metadata.")
			return false
	board.set_meta("capture_state", "phase96_herbal_blend_order_report_only_v1")
	board.set_meta("ready_blend_id", expected_blend_ids[0])
	board.set_meta("missing_blend_ids", expected_blend_ids.slice(1))
	return true


func _prepare_phase97_professor_exhibition_state(instance, expected_status: String) -> bool:
	if expected_status not in ["active", "ready"]:
		push_error("Phase 97 professor exhibition capture requested an unsupported state.")
		return false
	if not _prepare_professor_story_common_state(instance):
		return false
	var collection_species: Array[String] = instance.session.get_collection_species_ids()
	# The chapter-three target is historically fixed at ten discoveries, while
	# later append-only species may also be present in the live collection.
	if collection_species.size() < 10 or SAGE_SPECIES_ID not in collection_species:
		push_error("Phase 97 exhibition capture requires at least ten discovered species including Sage.")
		return false

	# Build every prerequisite through GameSession-owned fields and load the
	# canonical three-chapter state through ProfessorStory's schema-26 boundary.
	# No capture-only state is passed directly to the presenter.
	instance.session.xp = 1000
	instance.last_xp_seen = 1000
	instance.session.harvest_count = 25
	instance.session.orders_completed = 10
	instance.session.journey_completed = true
	instance.session.journey_reward_claimed = true
	instance.session.unlocked_room_themes.clear()
	for raw_theme_id in GameSession.ROOM_THEMES.keys():
		instance.session.unlocked_room_themes.append(str(raw_theme_id))
	for equipment_id in GameSession.EQUIPMENT_ORDER:
		instance.session.equipment_levels[equipment_id] = GameSession.EQUIPMENT_MAX_LEVEL

	for slot in instance.session.plants:
		slot.reset()
	for slot_index in range(5):
		var slot: PlantSimulation = instance.session.plants[slot_index]
		slot.configure_profile(instance.plant_catalog.get(collection_species[slot_index], instance.profile))
		slot.stage = PlantSimulation.Stage.VEGETATIVE
		slot.growth_percent = 52.0 + float(slot_index) * 3.0
		slot.health = 91.0
		slot.condition_score = 0.91

	for species_index in range(collection_species.size()):
		var species_id := collection_species[species_index]
		var progress: Dictionary = instance.session.get_species_progress(species_id)
		progress["discovered"] = true
		progress["harvests"] = 3 if species_index < 3 else 1
		progress["best_quality"] = 0.92
		progress["orders_completed"] = 1 if species_index < 3 else 0
		progress["total_dry_g"] = 12.0 + float(species_index)
		progress["claimed_tier"] = 3 if species_index < 3 else 1
		instance.session.species_progress[species_id] = progress

	var non_sage_species: Array[String] = []
	for species_id in collection_species:
		if species_id != SAGE_SPECIES_ID:
			non_sage_species.append(species_id)
	var ready := expected_status == "ready"
	var first_chapter_state := {
		"seen": true,
		"claimed": true,
		"patient_return_completed": true,
		"quality_species": collection_species.slice(0, 2),
		"specific_order_completed": true,
		"specific_order_species_id": collection_species[0],
		"daily_claim_days": [1, 2],
	}
	var second_chapter_state := {
		"seen": true,
		"claimed": true,
		"quality_species": collection_species.slice(0, 3),
		"specific_order_species": collection_species.slice(0, 2),
		"pack_opened": true,
	}
	var third_chapter_state := {
		"seen": true,
		"claimed": false,
		"daily_claim_days": [101, 102, 103] if ready else [101, 102],
		"exhibition_order_species": collection_species.slice(0, 3 if ready else 2),
		"showcase_non_sage_species": non_sage_species.slice(0, 3 if ready else 2),
		"showcase_sage_completed": true,
	}
	instance.session.professor_story.load_state(
		{
			PROFESSOR_STORY_CHAPTER_ID: first_chapter_state,
			PROFESSOR_STORY_CHAPTER_TWO_ID: second_chapter_state,
			PROFESSOR_STORY_CHAPTER_THREE_ID: third_chapter_state,
		},
		PROFESSOR_STORY_CHAPTER_THREE_ID,
		true,
		GameSession.PROFESSOR_STORY_CHAPTER_THREE_SCHEMA,
		collection_species
	)
	instance.session._sync_professor_story_storage()
	instance._refresh_ui()
	instance.professor_story_open = false
	instance.professor_story_modal.set_meta(
		"capture_state",
		"phase97_professor_exhibition_ready_report_only_v1" if ready else "phase97_professor_exhibition_active_report_only_v1"
	)
	instance._set_professor_story_open(true)
	instance._refresh_professor_story()
	return _validate_phase97_professor_exhibition(instance, expected_status)


func _prepare_phase97_professor_exhibition_claimed_state(instance) -> bool:
	if not _prepare_phase97_professor_exhibition_state(instance, "ready"):
		return false
	var claim: Dictionary = instance.session.claim_professor_story_reward(PROFESSOR_STORY_CHAPTER_THREE_ID)
	if not bool(claim.get("success", false)) \
			or str(claim.get("title_id", "")) != "herbarium_master" \
			or str(claim.get("title", "")) != "MISTR HERBÁŘE" \
			or instance.session.get_professor_seal_count() != 3:
		push_error("Phase 97 exhibition capture could not claim the canonical finale reward.")
		return false
	instance._refresh_ui()
	instance.professor_story_modal.set_meta("capture_state", "phase97_professor_exhibition_claimed_report_only_v1")
	instance._refresh_professor_story()
	return _validate_phase97_professor_exhibition(instance, "claimed")


func _validate_phase97_professor_exhibition(instance, expected_status: String) -> bool:
	var state: Dictionary = instance.session.get_professor_story_state()
	var goal_ids: Array[String] = []
	var goal_targets: Array[int] = []
	var goal_currents: Array[int] = []
	for raw_goal in state.get("goals", []):
		if not raw_goal is Dictionary:
			push_error("Phase 97 exhibition capture received a non-dictionary goal.")
			return false
		var goal: Dictionary = raw_goal
		goal_ids.append(str(goal.get("id", "")))
		goal_targets.append(int(goal.get("target", -1)))
		goal_currents.append(int(goal.get("current", -1)))
	var expected_currents := [10, 3, 3, 3, 4] if expected_status in ["ready", "claimed"] else [10, 3, 2, 2, 3]
	var expected_seals := 3 if expected_status == "claimed" else 2
	if str(state.get("chapter_id", "")) != PROFESSOR_STORY_CHAPTER_THREE_ID \
			or str(state.get("status", "")) != expected_status \
			or goal_ids != PHASE97_STORY_GOAL_IDS \
			or goal_targets != PHASE97_STORY_GOAL_TARGETS \
			or goal_currents != expected_currents \
			or instance.session.get_professor_seal_count() != expected_seals:
		push_error("Phase 97 exhibition capture drifted from its canonical chapter-three goals or status.")
		return false
	if instance.professor_story_cards.size() != 5 \
			or instance.nav_buttons.size() != 4 \
			or str(instance.professor_story_scroll.get_meta("scroll_contract", "")) != "five_story_goal_cards_v1" \
			or str(instance.professor_story_modal.get_meta("chapter_contract", "")) != "three_chapter_story_v1" \
			or instance.professor_story_modal.get_meta("chapter_ids", []) != [PROFESSOR_STORY_CHAPTER_ID, PROFESSOR_STORY_CHAPTER_TWO_ID, PROFESSOR_STORY_CHAPTER_THREE_ID] \
			or instance.professor_story_modal.get_meta("responsive_test_viewports", []) != PHASE97_RESPONSIVE_TEST_VIEWPORTS:
		push_error("Phase 97 professor modal no longer exposes its generic five-card, four-tab, responsive three-chapter contract.")
		return false
	if not instance.professor_story_modal.visible \
			or instance.professor_story_chapter_title_label.text != "VELKÁ HERBÁŘOVÁ VÝSTAVA" \
			or str(instance.professor_story_action.get("expected_chapter_id", "")) != PROFESSOR_STORY_CHAPTER_THREE_ID:
		push_error("Phase 97 professor presenter did not bind the finale through the existing generic modal.")
		return false
	if expected_status == "ready" and (str(instance.professor_story_action.get("target_action", "")) != "claim_reward" \
			or instance.professor_story_action_button.disabled):
		push_error("Phase 97 ready capture did not expose the live finale claim action.")
		return false
	if expected_status == "claimed" and (instance.session.get_professor_title_id() != "herbarium_master" \
			or instance.session.get_professor_title() != "MISTR HERBÁŘE" \
			or "MISTR HERBÁŘE" not in instance.professor_story_reward_label.text \
			or "pečeť" not in instance.professor_story_status_label.text.to_lower()):
		push_error("Phase 97 claimed capture does not visibly expose the canonical title and Professor seal.")
		return false
	return true


func _prepare_phase97_herbarium_master_journal_state(instance) -> bool:
	instance._set_professor_story_open(false)
	if instance.session.get_professor_title_id() != "herbarium_master" \
			or instance.session.get_professor_seal_count() != 3:
		push_error("Phase 97 journal capture requires the claimed finale title and third seal.")
		return false
	instance._set_grower_journal_open(true)
	instance._refresh_grower_journal()
	var snapshot: Dictionary = instance.session.get_grower_journal_snapshot()
	var badges: Array = snapshot.get("badges", [])
	if badges.size() != 10 or not badges[8] is Dictionary or not badges[9] is Dictionary:
		push_error("Phase 98 journal extension must retain MISTR HERBÁŘE and append VÝZKUMNÝ PARTNER as the tenth badge.")
		return false
	var final_badge: Dictionary = badges[8]
	var final_card: Dictionary = instance.grower_journal_cards.get("herbarium_master", {})
	var research_badge: Dictionary = badges[9]
	var research_card: Dictionary = instance.grower_journal_cards.get("research_partner", {})
	if int(snapshot.get("completed_badges", 0)) != 9 \
			or int(snapshot.get("badge_total", 0)) != 10 \
			or str(final_badge.get("id", "")) != "herbarium_master" \
			or str(final_badge.get("title", "")) != "MISTR HERBÁŘE" \
			or not bool(final_badge.get("achieved", false)) \
			or str(research_badge.get("id", "")) != "research_partner" \
			or bool(research_badge.get("achieved", true)) \
			or instance.grower_journal_cards.size() != 10 \
			or instance.grower_journal_badge_count_label.text != "ODZNAKY  9 / 10" \
			or str((final_card.get("title") as Label).text) != "MISTR HERBÁŘE" \
			or not bool((final_card.get("panel") as Control).get_meta("achieved", false)) \
			or str((research_card.get("title") as Label).text) != "VÝZKUMNÝ PARTNER" \
			or instance.grower_journal_modal.get_meta("responsive_test_viewports", []) != PHASE97_RESPONSIVE_TEST_VIEWPORTS:
		push_error("Phase 98 journal did not preserve MISTR HERBÁŘE at 9/10 before the repeatable partner badge is earned.")
		return false
	instance.grower_journal_modal.set_meta("capture_state", "phase97_grower_journal_herbarium_master_report_only_v1")
	return instance.grower_journal_modal.visible


func _capture_phase97_overlay(
	instance,
	overlay: Control,
	scroll: ScrollContainer,
	focus_control: Control,
	filename: String
) -> bool:
	# Every new Phase 97 image passes through the same full-overlay path. This
	# keeps settle, responsive metadata, scroll placement and PNG persistence
	# identical instead of treating any frame as a partial check-only capture.
	await _settle(instance)
	if overlay == null or scroll == null or not overlay.visible \
			or overlay.get_meta("responsive_test_viewports", []) != PHASE97_RESPONSIVE_TEST_VIEWPORTS \
			or scroll.get_v_scroll_bar().max_value <= scroll.size.y:
		push_error("Phase 97 capture overlay is not visible, responsive or genuinely scrollable: %s" % filename)
		return false
	if focus_control != null:
		scroll.ensure_control_visible(focus_control)
	else:
		scroll.scroll_vertical = 0
	await process_frame
	await process_frame
	if focus_control != null and not scroll.get_global_rect().intersects(focus_control.get_global_rect()):
		push_error("Phase 97 capture could not scroll its requested content into view: %s" % filename)
		return false
	return _save_full_viewport(filename)


func _prepare_phase98_professor_research_state(instance, expected_status: String) -> bool:
	instance._set_grower_journal_open(false)
	instance._set_professor_story_open(false)
	var cycle_id := int(instance.session.professor_research.get_cycle_id_for_utc_day(PHASE98_RESEARCH_CAPTURE_UTC_DAY))
	var active_state := {}
	var last_claimed_cycle_id := cycle_id - 1
	var completed_count := 3
	if expected_status in ["active", "ready"]:
		var ready := expected_status == "ready"
		active_state = {
			"cycle_id": cycle_id,
			"accepted_utc_day": PHASE98_RESEARCH_CAPTURE_UTC_DAY - 1,
			"care_action_ids": ["water", "ventilate", "lamp_on"] if ready else ["water", "ventilate"],
			"quality_sample_count": 2 if ready else 1,
			"packaged_sample_count": 2 if ready else 1,
			"delivered_package_count": 2 if ready else 1,
			"observation_days": [PHASE98_RESEARCH_CAPTURE_UTC_DAY - 1, PHASE98_RESEARCH_CAPTURE_UTC_DAY] if ready else [PHASE98_RESEARCH_CAPTURE_UTC_DAY - 1],
		}
	elif expected_status == "cooldown":
		last_claimed_cycle_id = cycle_id
		completed_count = 4
	else:
		push_error("Phase 98 professor research capture requested an unsupported state: %s" % expected_status)
		return false
	instance.session.professor_research.load_state({
		"max_seen_utc_day": PHASE98_RESEARCH_CAPTURE_UTC_DAY,
		"offer_seen_cycle_id": cycle_id,
		"last_claimed_cycle_id": last_claimed_cycle_id,
		"completed_count": completed_count,
		"active": active_state,
	}, GameSession.PROFESSOR_RESEARCH_SCHEMA, true, PHASE98_RESEARCH_CAPTURE_UTC_DAY)
	instance.professor_story_modal.set_meta("capture_state", "phase98_professor_weekly_research_%s_report_only_v1" % expected_status)
	instance.professor_story_open = false
	instance._set_professor_story_open(true)
	instance._refresh_professor_story()
	return _validate_phase98_professor_research(instance, expected_status, cycle_id)


func _validate_phase98_professor_research(instance, expected_status: String, expected_cycle_id: int) -> bool:
	var state: Dictionary = instance.session.get_professor_hub_state(float(PHASE98_RESEARCH_CAPTURE_UTC_DAY) * 86400.0)
	var goal_ids: Array[String] = []
	for raw_goal in state.get("goals", []):
		if not raw_goal is Dictionary:
			push_error("Phase 98 professor research capture received a non-dictionary goal.")
			return false
		goal_ids.append(str((raw_goal as Dictionary).get("id", "")))
	var expected_action := "claim_research_reward" if expected_status == "ready" else ("none" if expected_status == "cooldown" else str((state.get("next_action", {}) as Dictionary).get("target_action", "")))
	if str(state.get("status", "")) != expected_status \
			or int(state.get("cycle_id", -1)) != expected_cycle_id \
			or goal_ids != PHASE98_RESEARCH_GOAL_IDS \
			or instance.professor_story_content_mode != "weekly_research" \
			or instance.professor_story_modal.get_meta("active_presentation_mode", "") != "weekly_research" \
			or instance.professor_story_cards.size() != 5 \
			or instance.nav_buttons.size() != 4 \
			or int(instance.professor_story_modal.get_meta("goal_card_capacity", 0)) != 5 \
			or instance.professor_story_modal.get_meta("presentation_modes", []) != ["story_chapter", "weekly_research"] \
			or str(instance.professor_story_action.get("target_action", "")) != expected_action \
			or int(instance.professor_story_action.get("expected_cycle_id", -1)) != expected_cycle_id:
		push_error("Phase 98 professor research capture drifted from its five-card weekly presentation contract.")
		return false
	if expected_status == "ready" and instance.professor_story_action_button.disabled:
		push_error("Phase 98 ready research capture did not expose its live reward claim.")
		return false
	if expected_status == "cooldown" and (not instance.professor_story_action_button.disabled \
			or instance.professor_story_action_button.text != "DALŠÍ PROTOKOL V PONDĚLÍ"):
		push_error("Phase 98 cooldown capture did not lock the protocol until Monday.")
		return false
	return true


func _prepare_phase99_professor_research_variant(instance, cycle_id: int, name_suffix: String) -> bool:
	instance._prepare_professor_research_variant_capture(cycle_id, "phase99_professor_weekly_research_%s_report_only_v1" % name_suffix)
	var expected_protocol_id := ProfessorResearch.get_protocol_id_for_cycle(cycle_id)
	if expected_protocol_id.is_empty():
		push_error("Phase 99 variant capture requested unknown protocol for cycle %d." % cycle_id)
		return false
	var state: Dictionary = instance.session.get_professor_hub_state(float(cycle_id * 7 + 3) * 86400.0)
	if str(state.get("protocol_id", "")) != expected_protocol_id:
		push_error("Phase 99 variant capture did not expose expected protocol. Expected %s, got %s." % [
			expected_protocol_id,
			str(state.get("protocol_id", "")),
		])
		return false
	instance.professor_story_modal.set_meta(
		"capture_state",
		"phase99_professor_weekly_research_%s_report_only_v1" % name_suffix
	)
	instance.professor_story_content_mode = "weekly_research"
	instance._refresh_professor_story()
	instance.professor_story_modal.set_meta("phase99_research_protocol_id", expected_protocol_id)
	instance.professor_story_modal.set_meta("phase99_research_cycle_id", cycle_id)
	return true


func _configure_phase96_package(instance, slot_index: int, species_id: String, dry_g: float, quality: float) -> void:
	var slot: PlantSimulation = instance.session.plants[slot_index]
	slot.reset()
	slot.configure_profile(instance.plant_catalog.get(species_id, instance.profile))
	slot.stage = PlantSimulation.Stage.PACKAGED
	slot.growth_percent = 100.0
	slot.fresh_harvest_g = dry_g * 6.0
	slot.dry_harvest_g = dry_g
	slot.harvest_quality = quality
	slot.health = quality * 100.0
	slot.condition_score = quality


func _find_diagnosis_behavior_card(instance) -> Control:
	for raw_card in instance.plant_diagnosis_cards:
		if not raw_card is Dictionary:
			continue
		var panel := (raw_card as Dictionary).get("panel") as Control
		if panel != null and str(panel.get_meta("diagnosis_id", "")) == "behavior":
			return panel
	return null


func _prepare_phase82_behavior_active_badge_state(instance) -> bool:
	if not instance.plant_catalog.has(MINT_SPECIES_ID):
		push_error("Phase 82 behavior badge capture requires the Mint profile.")
		return false
	_prepare_phase11_mint_detail_state(instance)
	var mint: PlantSimulation = instance.session.plant
	mint.stage = PlantSimulation.Stage.VEGETATIVE
	mint.growth_percent = 58.0
	mint.health = 72.0
	mint.moisture = 40.0
	mint.nutrients = 52.0
	mint.ventilation = 68.0
	mint.humidity_percent = 54.0
	mint.light_lux = 12000.0
	mint.temperature_c = 23.0
	mint.ph = 6.4
	mint.disease_level = 0
	mint.disease_pressure = 0.0
	mint.sync_environment(instance.session.world_elapsed_seconds)
	instance.plant_behavior_presenter.reset_observation()
	instance._refresh_ui()
	instance.plant_detail_panel.set_meta("capture_state", "phase82_behavior_active_badge_diagnostic_v1")
	instance.plant_behavior_badge.set_meta("species_id", MINT_SPECIES_ID)
	instance.plant_behavior_badge.set_meta("behavior_id", MINT_BEHAVIOR_ID)
	instance.plant_view.animation_time = 0.35
	instance.plant_view.action_pulse = 0.0
	instance.plant_view.water_animation = 0.0
	instance.plant_view.sparkle_animation = 0.0
	instance.plant_view.growth_burst_animation = 0.0
	instance.plant_view.shake_animation = 0.0
	instance.plant_view.ladybug_animation = 0.0
	instance.plant_view.golden_shine_animation = 0.0
	instance.plant_view.behavior_pulse = 0.0
	instance.plant_view.queue_redraw()
	return instance.plant_detail_panel.visible \
		and instance.plant_behavior_presenter.is_bound() \
		and instance.plant_behavior_badge.visible \
		and bool(instance.plant_behavior_badge.get_meta("behavior_active", false)) \
		and str(instance.plant_behavior_badge.get_meta("behavior_id", "")) == MINT_BEHAVIOR_ID \
		and instance.plant_behavior_badge_title.text == "VLASTNOST AKTIVNÍ" \
		and MINT_BEHAVIOR_LABEL in instance.plant_behavior_badge_value.text \
		and bool(instance.plant_view.get_meta("behavior_active", false))


func _configure_phase81_lavender_ideal_state(lavender: PlantSimulation) -> void:
	lavender.health = 92.0
	lavender.moisture = 48.0
	lavender.nutrients = 47.0
	lavender.ventilation = 76.0
	lavender.humidity_percent = 48.0
	lavender.light_lux = 18000.0
	lavender.temperature_c = 22.0
	lavender.ph = 7.1
	lavender.disease_level = 0
	lavender.disease_pressure = 0.0
	lavender.condition_score = 0.91


func _prepare_detail_water_frame(instance) -> void:
	instance.plant_view.animation_time = 0.44
	instance.plant_view.action_pulse = 0.42
	instance.plant_view.water_animation = 0.72
	instance.plant_view.sparkle_animation = 0.0
	instance.plant_view.growth_burst_animation = 0.0
	instance.plant_view.shake_animation = 0.0
	instance.plant_view.ladybug_animation = 0.0
	instance.plant_view.golden_shine_animation = 0.0
	instance.plant_view.queue_redraw()


func _prepare_detail_growth_frame(instance) -> void:
	instance.plant_view.animation_time = 0.52
	instance.plant_view.action_pulse = 0.34
	instance.plant_view.water_animation = 0.0
	instance.plant_view.sparkle_animation = 0.0
	instance.plant_view.growth_burst_animation = 0.55
	instance.plant_view.shake_animation = 0.0
	instance.plant_view.ladybug_animation = 0.0
	instance.plant_view.golden_shine_animation = 0.55
	instance.plant_view.queue_redraw()


func _prepare_detail_ladybug_frame(instance) -> void:
	instance.plant_view.animation_time = 0.61
	instance.plant_view.action_pulse = 0.0
	instance.plant_view.water_animation = 0.0
	instance.plant_view.sparkle_animation = 0.0
	instance.plant_view.growth_burst_animation = 0.0
	instance.plant_view.shake_animation = 0.62
	instance.plant_view.ladybug_animation = 0.42
	instance.plant_view.golden_shine_animation = 0.0
	instance.plant_view.queue_redraw()


func _settle(instance) -> void:
	instance.session.paused = true
	instance.plant_view.set_paused(true)
	instance.room_overview.set_paused(true)
	if instance.feedback_layer != null:
		instance.feedback_layer.finish_all()
	await process_frame
	await process_frame


func _set_stage(plant: PlantSimulation, stage: PlantSimulation.Stage, growth: float, health: float, biological_day: float) -> void:
	plant.stage = stage
	plant.growth_percent = growth
	plant.health = health
	plant.moisture = 64.0
	plant.condition_score = health / 100.0
	var target_seconds := float(plant.profile.get("growth_seconds", 172800.0))
	var harvest_days := maxf(1.0, float(plant.profile.get("biological_days_to_harvest", 45.0)))
	plant.plant_age_seconds = target_seconds * biological_day / harvest_days


func _viewport_image() -> Image:
	var image := root.get_viewport().get_texture().get_image()
	if image.get_size() != OUTPUT_SIZE:
		image.resize(OUTPUT_SIZE.x, OUTPUT_SIZE.y, Image.INTERPOLATE_LANCZOS)
	return image


func _save_full_viewport(filename: String) -> bool:
	return _save_image(_viewport_image(), filename)


func _save_top_region(image: Image, filename: String, logical_height: float) -> bool:
	var height := clampi(roundi(float(image.get_width()) * logical_height / LOGICAL_WIDTH), 1, image.get_height())
	return _save_image(image.get_region(Rect2i(0, 0, image.get_width(), height)), filename)


func _save_bottom_region(image: Image, filename: String, logical_height: float) -> bool:
	var height := clampi(roundi(float(image.get_width()) * logical_height / LOGICAL_WIDTH), 1, image.get_height())
	return _save_image(image.get_region(Rect2i(0, image.get_height() - height, image.get_width(), height)), filename)


func _save_image(image: Image, filename: String) -> bool:
	var path := output_directory.path_join(filename)
	var error := image.save_png(path)
	if error != OK:
		push_error("Could not save validation image %s: %s" % [path, error_string(error)])
		return false
	print("CAPTURED=%s" % path)
	return true


func _read_output_directory() -> String:
	var arguments := OS.get_cmdline_user_args()
	for index in range(arguments.size()):
		if arguments[index] == "--output-dir" and index + 1 < arguments.size():
			return _absolute_path(arguments[index + 1])
		if arguments[index].begins_with("--output-dir="):
			return _absolute_path(arguments[index].trim_prefix("--output-dir="))
	return ""


func _absolute_path(value: String) -> String:
	if value.is_absolute_path():
		return value.simplify_path()
	return ProjectSettings.globalize_path("res://" + value).simplify_path()
