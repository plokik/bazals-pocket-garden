extends Control

const PlantViewScene := preload("res://scripts/ui/plant_view.gd")
const RoomOverviewScene := preload("res://scripts/ui/room_overview.gd")
const PlayerRoomViewScene := preload("res://scripts/ui/player_room_collection_view.gd")
const GreenhousePreviewViewScene := preload("res://scripts/ui/greenhouse_preview_view.gd")
const RoomDecorationModalScene := preload("res://scripts/ui/room_decoration_modal.gd")
const MetricGraphScene := preload("res://scripts/ui/metric_graph.gd")
const ComicUITheme := preload("res://scripts/ui/comic_ui.gd")
const TooltipPolicy := preload("res://scripts/ui/tooltip_policy.gd")
const VisualDesignSystem := preload("res://scripts/ui/visual_design_system.gd")
const ComicHudScene := preload("res://scripts/ui/comic_hud.gd")
const GuideCharacterScene := preload("res://scripts/ui/guide_character.gd")
const GameFeedbackLayerScene := preload("res://scripts/ui/game_feedback_layer.gd")
const GameAudioHapticsScene := preload("res://scripts/audio_haptics.gd")
const PlantCatalogRepositoryScene := preload("res://scripts/plant_catalog_repository.gd")
const PlantPresentationCatalogScene := preload("res://scripts/plant_presentation_catalog.gd")
const ScreenNavigationControllerScene := preload("res://scripts/ui/screen_navigation_controller.gd")
const CustomerOrdersPanelScene := preload("res://scripts/ui/customer_orders_panel.gd")
const StoragePipelinePresenterScene := preload("res://scripts/ui/storage_pipeline_presenter.gd")
const BotanistShopPresenterScene := preload("res://scripts/ui/botanist_shop_presenter.gd")
const DailyChallengePresenterScene := preload("res://scripts/ui/daily_challenge_presenter.gd")
const DailyChallengeVisualScene := preload("res://scripts/ui/daily_challenge_visual.gd")
const BotanicalPackPresenterScene := preload("res://scripts/ui/botanical_pack_presenter.gd")
const CosmeticShowroomPresenterScene := preload("res://scripts/ui/cosmetic_showroom_presenter.gd")
const CosmeticShowroomVisualLayout := preload("res://scripts/ui/cosmetic_showroom_visual.gd")
const SeedSelectorPresenterScene := preload("res://scripts/ui/seed_selector_presenter.gd")
const HerbariumPresenterScene := preload("res://scripts/ui/herbarium_presenter.gd")
const MeasurementPresenterScene := preload("res://scripts/ui/measurement_presenter.gd")
const StorageInventoryPresenterScene := preload("res://scripts/ui/storage_inventory_presenter.gd")
const PlantVitalsPresenterScene := preload("res://scripts/ui/plant_vitals_presenter.gd")
const ReturnSummaryPresenterScene := preload("res://scripts/ui/return_summary_presenter.gd")
const SaveRecoveryPresenterScene := preload("res://scripts/ui/save_recovery_presenter.gd")
const PlantActionPresenterScene := preload("res://scripts/ui/plant_action_presenter.gd")
const RealTimeGrowthPresenterScene := preload("res://scripts/ui/real_time_growth_presenter.gd")
const GardenSelectionPresenterScene := preload("res://scripts/ui/garden_selection_presenter.gd")
const DayHudPresenterScene := preload("res://scripts/ui/day_hud_presenter.gd")
const XpHudPresenterScene := preload("res://scripts/ui/xp_hud_presenter.gd")
const CoinHudPresenterScene := preload("res://scripts/ui/coin_hud_presenter.gd")
const AudioSettingsPresenterScene := preload("res://scripts/ui/audio_settings_presenter.gd")
const GardenHandoverPresenterScene := preload("res://scripts/ui/garden_handover_presenter.gd")
const ProfessorStoryPresenterScene := preload("res://scripts/ui/professor_story_presenter.gd")
const GuideDialogPresenterScene := preload("res://scripts/ui/guide_dialog_presenter.gd")
const LevelProgressionPresenterScene := preload("res://scripts/ui/level_progression_presenter.gd")
const GrowerJournalPresenterScene := preload("res://scripts/ui/grower_journal_presenter.gd")
const CareCenterPresenterScene := preload("res://scripts/ui/care_center_presenter.gd")
const CareNotificationServiceScene := preload("res://scripts/services/care_notification_service.gd")
const PlantDiagnosisServiceScene := preload("res://scripts/services/plant_diagnosis_service.gd")
const PlantDiagnosisPresenterScene := preload("res://scripts/ui/plant_diagnosis_presenter.gd")
const PlantBehaviorPresenterScene := preload("res://scripts/ui/plant_behavior_presenter.gd")
const CoinTexture := preload("res://assets/ui/target_b_exact/hud_coin_clean_v2.png")
const BotanistShopSceneTexture := preload("res://assets/ui/merchant/botanist_shop_counter_v2.png")
const Phase128StorageBackdrop := preload("res://assets/ui/visual/phase128/storage_workshop_backdrop_v2.png")
const Phase128MeasurementBackdrop := preload("res://assets/ui/visual/phase128/measurement_corner_backdrop_v1.png")
const MeasurementMetricIconScene := preload("res://scripts/ui/measurement_metric_icon.gd")
const NavTouchShineShader := preload("res://assets/shaders/nav_touch_shine.gdshader")
const InfoQuestionTexture := preload("res://assets/ui/rack/rack_help_badge_v1.png")
const SettingsGearTexture := preload("res://assets/ui/icons/settings_gear_phase125.png")
const RackDockPetTexture := preload("res://assets/ui/visual/phase183/rack_dock/pet_paw_phase183_v1.png")
const RackDockProfessorTexture := preload("res://assets/ui/visual/phase183/rack_dock/professor_bazal_phase183_v1.png")
const RackDockCareTexture := preload("res://assets/ui/visual/phase183/rack_dock/care_leaf_phase183_v1.png")
const Phase161DailyChallengeBackdrop := preload("res://assets/ui/visual/phase161/daily_challenge/daily_challenge_clean_backdrop_v3.png")
const Phase162CosmeticShowroomBackdrop := preload("res://assets/ui/visual/phase162/cosmetic_showroom/cosmetic_showroom_clean_backdrop_v1.png")
const GUIDE_MODAL_DURATION := 0.34
const GUIDE_PANEL_HEIGHT := 80.0
const GUIDE_INFO_ICON_SIZE := Vector2(44.0, 44.0)
const GUIDE_INFO_ICON_POSITION := Vector2(18.0, 12.0)
const GUIDE_INFO_HIT_SIZE := Vector2(64.0, 64.0)
const GUIDE_INFO_HIT_POSITION := Vector2(8.0, 2.0)
const RACK_DOCK_BUTTON_SIZE := 68.0
const RACK_DOCK_ICON_SIZE := 48.0
const RACK_DOCK_BUTTON_COUNT := 4
const RACK_DOCK_BOTTOM_INSET := 8.0
const GUIDE_MODAL_DIM := Color("#071823", 0.84)
const GUIDE_MODAL_CHARACTER_OFFSET := Vector2(-54.0, 92.0)
const GUIDE_MODAL_CARD_OFFSET := Vector2(72.0, 0.0)
const GUIDE_MODAL_CARD_BOTTOM := 0.315
const GARDEN_HANDOVER_CARD_BOTTOM := 0.36
const GUIDE_APPROVAL_CAPTURE_CHARACTER_OFFSET := Vector2(-7.2, 12.0)
const GUIDE_APPROVAL_CAPTURE_CARD_OFFSET := Vector2(36.0, 0.0)
const SIMULATION_TICK_SECONDS := 0.1
const HUD_HEIGHT := 74.0
const GARDEN_LOCATION_RACK := "rack"
const GARDEN_LOCATION_PLAYER_ROOM := "player_room"
const GARDEN_LOCATION_GREENHOUSE := "greenhouse"
const HUD_CARD_RECTS := [
	Rect2(0.005, 0.02, 0.324, 0.96),
	Rect2(0.335, 0.02, 0.319, 0.96),
	Rect2(0.659, 0.02, 0.336, 0.96),
]
const HUD_DAY_ICON_RECT := Rect2(0.068, 0.22, 0.110, 0.57)
const HUD_DAY_TEXT_RECT := Rect2(0.165, 0.24, 0.148, 0.52)
const HUD_COIN_ICON_RECT := Rect2(0.396, 0.165, 0.114, 0.68)
const HUD_COIN_TEXT_RECT := Rect2(0.495, 0.24, 0.148, 0.52)
const HUD_LEVEL_TEXT_RECT := Rect2(0.70, 0.20, 0.22, 0.28)
const HUD_XP_GAIN_RECT := Rect2(0.79, 0.04, 0.17, 0.40)
const HUD_XP_BAR_RECT := Rect2(0.695, 0.54, 0.267, 0.28)
const HUD_XP_VALUE_RECT := Rect2(0.82, 0.54, 0.135, 0.28)
const FontRegular := preload("res://assets/fonts/Poppins-Regular.ttf")
const FontSemiBold := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const FontExtraBold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const ButtonGreenTexture := preload("res://assets/ui/v3/button_green.png")
const ButtonBlueTexture := preload("res://assets/ui/v3/button_blue.png")
const ButtonYellowTexture := preload("res://assets/ui/v3/button_yellow.png")
const ButtonPurpleTexture := preload("res://assets/ui/v3/button_purple.png")
const ButtonTealTexture := preload("res://assets/ui/v3/button_teal.png")
const WaterIcon := preload("res://assets/ui/icons/water.png")
const SunIcon := preload("res://assets/ui/icons/sun.png")
const FertilizerIcon := preload("res://assets/ui/icons/fertilizer.png")
const WindIcon := preload("res://assets/ui/icons/wind.png")
const NavPlantIcon := preload("res://assets/ui/icons/nav_plants.png")
const NavStorageIcon := preload("res://assets/ui/icons/nav_storage.png")
const NavShopIcon := preload("res://assets/ui/icons/nav_shop.png")
const NavMeasureIcon := preload("res://assets/ui/icons/nav_measure.png")

const NAV_ICONS: Array[Texture2D] = [
	NavPlantIcon,
	NavStorageIcon,
	NavShopIcon,
	NavMeasureIcon,
]

const NAV_BUTTON_BOUNDS: Array[Vector2] = [
	Vector2(0.009, 0.248),
	Vector2(0.256, 0.493),
	Vector2(0.504, 0.741),
	Vector2(0.749, 0.991),
]

const GROWER_JOURNAL_BADGE_IDS := [
	"first_cycle",
	"species_collection",
	"busy_rack",
	"trusted_supplier",
	"seasoned_grower",
	"quality_trio",
	"workshop_master",
	"room_collector",
	"herbarium_master",
	"research_partner",
]

const COLORS := {
	"green": Color("#42b95c"),
	"light_green": Color("#a9e66b"),
	"blue": Color("#59cbe8"),
	"soil": Color("#70452e"),
	"terracotta": Color("#e87838"),
	"cream": Color("#fff8df"),
	"yellow": Color("#f7c936"),
	"ink": Color("#244638"),
	"white": Color("#fffdf4"),
}

const DETAIL_INK := ComicUITheme.INK
const DETAIL_CREAM := ComicUITheme.CREAM
const DETAIL_BLUE := ComicUITheme.BLUE
const DETAIL_CYAN := ComicUITheme.CYAN
const DETAIL_GREEN := ComicUITheme.GREEN
const DETAIL_PURPLE := ComicUITheme.PURPLE
const DETAIL_GOLD := ComicUITheme.GOLD
const DETAIL_ORANGE := ComicUITheme.ORANGE

var profile: Dictionary
var plant_catalog: Dictionary = {}
var session: GameSession
var screens: Array[Control] = []
var nav_buttons: Array[Button] = []
var nav_shine_overlays: Array[ColorRect] = []
var nav_icon_nodes: Array[TextureRect] = []
var navigation_separator: Control
var edge_background: ColorRect
var safe_area_container: MarginContainer
var safe_area_surface: ColorRect
var safe_area_insets := Vector4.ZERO
var active_screen := 0
var plant_catalog_repository := PlantCatalogRepositoryScene.new()
var plant_presentation_catalog := PlantPresentationCatalogScene.new()
var screen_navigation_controller := ScreenNavigationControllerScene.new()
var storage_pipeline_presenter := StoragePipelinePresenterScene.new()
var botanist_shop_presenter := BotanistShopPresenterScene.new()
var daily_challenge_presenter := DailyChallengePresenterScene.new()
var botanical_pack_presenter := BotanicalPackPresenterScene.new()
var cosmetic_showroom_presenter := CosmeticShowroomPresenterScene.new()
var seed_selector_presenter := SeedSelectorPresenterScene.new()
var herbarium_presenter := HerbariumPresenterScene.new()
var measurement_presenter := MeasurementPresenterScene.new()
var storage_inventory_presenter := StorageInventoryPresenterScene.new()
var plant_vitals_presenter := PlantVitalsPresenterScene.new()
var return_summary_presenter := ReturnSummaryPresenterScene.new()
var save_recovery_presenter := SaveRecoveryPresenterScene.new()
var plant_action_presenter := PlantActionPresenterScene.new()
var real_time_growth_presenter := RealTimeGrowthPresenterScene.new()
var garden_selection_presenter := GardenSelectionPresenterScene.new()
var day_hud_presenter := DayHudPresenterScene.new()
var xp_hud_presenter := XpHudPresenterScene.new()
var coin_hud_presenter := CoinHudPresenterScene.new()
var audio_settings_presenter := AudioSettingsPresenterScene.new()
var guide_dialog_presenter := GuideDialogPresenterScene.new()
var level_progression_presenter := LevelProgressionPresenterScene.new()
var grower_journal_presenter := GrowerJournalPresenterScene.new()
var care_center_presenter := CareCenterPresenterScene.new()
var care_notification_service := CareNotificationServiceScene.new()
var plant_diagnosis_service := PlantDiagnosisServiceScene.new()
var plant_diagnosis_presenter := PlantDiagnosisPresenterScene.new()
var plant_behavior_presenter := PlantBehaviorPresenterScene.new()

var coins_label: Label
var coin_icon: Control
var coin_count_tween: Tween
var day_label: Label
var day_icon: TextureRect
var daily_challenge_launcher: Button
var daily_challenge_modal: Control
var daily_challenge_open := false
var daily_challenge_title_label: Label
var daily_challenge_body_label: Label
var daily_challenge_status_label: Label
var daily_challenge_weather_label: Label
var daily_challenge_action_button: Button
var daily_challenge_claim_button: Button
var botanical_pack_launcher_button: Button
var daily_challenge_backdrop: TextureRect
var daily_challenge_context_visual: DailyChallengeVisual
var daily_challenge_action_state_overlay: PanelContainer
var daily_challenge_claim_state_overlay: PanelContainer
var daily_challenge_warning_label: Label
var daily_challenge_close_button: Button
var botanical_pack_modal: Control
var botanical_pack_open := false
var botanical_pack_count_label: Label
var botanical_pack_odds_label: Label
var botanical_pack_pity_label: Label
var botanical_pack_status_label: Label
var botanical_pack_reward_name_label: Label
var botanical_pack_reward_rarity_label: Label
var botanical_pack_reward_icon: TextureRect
var botanical_pack_open_button: Button
var botanical_pack_last_reward: Dictionary = {}
var botanical_pack_opening := false
var level_progression_launcher: Button
var level_progression_modal: Control
var level_progression_open := false
var level_progression_summary_label: Label
var level_progression_status_label: Label
var level_progression_cards: Dictionary = {}
var level_progression_scroll: ScrollContainer
var herbarium_scroll: ScrollContainer
var herbarium_backdrop: TextureRect
var herbarium_collection_summary_label: Label
var herbarium_mastery_summary_label: Label
var grower_journal_launcher: Button
var grower_journal_modal: Control
var grower_journal_open := false
var grower_journal_summary_label: Label
var grower_journal_next_goal_label: Label
var grower_journal_badge_count_label: Label
var grower_journal_cards: Dictionary = {}
var grower_journal_scroll: ScrollContainer
var care_center_modal: Control
var care_center_open := false
var care_center_summary_label: Label
var care_center_status_label: Label
var care_center_reminder_button: Button
var care_center_notification_test_button: Button
var care_center_cards: Dictionary = {}
var care_center_scroll: ScrollContainer
var fast_time_guard_pending: Dictionary = {}
var care_notification_test_pending := false
var plant_diagnosis_modal: Control
var plant_diagnosis_open := false
var plant_diagnosis_launcher: Button
var plant_diagnosis_summary_label: Label
var plant_diagnosis_status_label: Label
var plant_diagnosis_recommendation_label: Label
var plant_diagnosis_cards: Array[Dictionary] = []
var plant_diagnosis_scroll: ScrollContainer
var plant_diagnosis_close_button: Button
var plant_diagnosis_action_button: Button
var cosmetic_modal: Control
var cosmetic_modal_open := false
var cosmetic_status_label: Label
var cosmetic_theme_cards: Dictionary = {}
var cosmetic_showroom_scroll: ScrollContainer
var room_decoration_modal: RoomDecorationModal
var room_decoration_open := false
var return_summary_modal: Control
var return_summary_open := false
var return_summary_label: Label
var save_recovery_modal: Control
var save_recovery_open := false
var save_recovery_label: Label
var save_recovery_confirm_button: Button
var save_recovery_confirm_armed := false
var save_failure_modal: Control
var save_failure_open := false
var save_failure_pending := false
var save_failure_silenced := false
var save_failure_label: Label
var save_failure_retry_button: Button
var save_failure_continue_button: Button
var local_backup_modal: Control
var local_backup_open := false
var local_backup_info_label: Label
var local_backup_status_label: Label
var local_backup_confirm_button: Button
var local_backup_restore_previous_button: Button
var local_backup_new_game_button: Button
var local_backup_import_armed := false
var local_backup_restore_previous_armed := false
var local_backup_new_game_armed := false
var pending_local_backup_data: Dictionary = {}
var external_file_picker_open := false
var suspended_at_unix := 0.0
var hud_background: Control
var xp_label: Label
var xp_value_label: Label
var xp_gain_label: Label
var xp_bar: ProgressBar
var xp_tween: Tween
var dialog_panel: PanelContainer
var dialog_label: Label
var dialog_reveal: Control
var dialog_toggle_button: Button
var dialog_info_icon: TextureRect
var dialog_open := false
var dialog_tween: Tween
var detail_dialog_panel: PanelContainer
var detail_dialog_label: Label
var detail_dialog_reveal: Control
var detail_dialog_toggle_button: Button
var detail_dialog_info_icon: TextureRect
var detail_dialog_open := false
var detail_dialog_tween: Tween
var professor_research_launcher_button: Button
var professor_research_launcher_icon: TextureRect
var professor_research_lock_badge: PanelContainer
var guide_portrait: GuideCharacter
var guide_modal: Control
var guide_modal_dimmer: ColorRect
var guide_modal_card: PanelContainer
var guide_modal_name_badge: PanelContainer
var guide_modal_name_label: Label
var guide_modal_label: Label
var guide_modal_character: GuideCharacter
var guide_modal_close_button: Button
var guide_modal_confirm_button: Button
var garden_handover_presenter := GardenHandoverPresenterScene.new()
var is_garden_handover_active := false
var return_to_herbarium_after_handover := false
var herbarium_replay_from_garden_handover_button: Button
var professor_story_presenter := ProfessorStoryPresenterScene.new()
var professor_story_modal: Control
var professor_story_open := false
var professor_story_chapter_title_label: Label
var professor_story_body_label: Label
var professor_story_summary_label: Label
var professor_story_status_label: Label
var professor_story_reward_title_label: Label
var professor_story_reward_label: Label
var professor_story_action_button: Button
var professor_story_scroll: ScrollContainer
var professor_story_cards: Dictionary = {}
var professor_story_action: Dictionary = {}
var professor_story_badges: Array[PanelContainer] = []
var professor_story_content_mode := "story_chapter"
var reduce_motion_button: Button
var feedback_layer: GameFeedbackLayer
var audio_haptics: GameAudioHaptics
var settings_launcher_button: Button
var settings_launcher_icon: TextureRect
var rack_pet_launcher_button: Button
var rack_pet_launcher_icon: TextureRect
var care_center_launcher_button: Button
var care_center_launcher_icon: TextureRect
var care_center_attention_badge: PanelContainer
var care_center_attention_label: Label
var settings_modal: Control
var settings_modal_open := false
var seed_selector_modal: Control
var seed_selector_open := false
var seed_selector_basil_button: Button
var seed_selector_mint_button: Button
var seed_selector_rosemary_button: Button
var seed_selector_oregano_button: Button
var seed_species_buttons: Dictionary = {}
var seed_selector_status_label: Label
var seed_selector_scroll: ScrollContainer
var herbarium_launcher_button: Button
var plant_detail_selector: HBoxContainer
var herbarium_modal: Control
var herbarium_open := false
var herbarium_summary_label: Label
var herbarium_status_label: Label
var herbarium_cards: Dictionary = {}
var settings_music_button: Button
var settings_sfx_button: Button
var settings_haptics_button: Button
var settings_motion_button: Button
var settings_music_slider: HSlider
var settings_sfx_slider: HSlider
var settings_status_label: Label
var plants_room_panel: Control
var player_room_panel: Control
var greenhouse_panel: Control
var plant_detail_panel: Control
var room_overview: PlantRoomOverview
var player_room_view: PlayerRoomCollectionView
var greenhouse_preview_view: GreenhousePreviewView
var rack_greenhouse_button: Button
var rack_player_room_button: Button
var garden_location_id := GARDEN_LOCATION_RACK
var plant_count_label: Label
var plant_position_label: Label
var plant_view: PlantView
var plant_behavior_badge: PanelContainer
var plant_behavior_badge_title: Label
var plant_behavior_badge_value: Label
var stage_label: Label
var growth_label: Label
var growth_bar: ProgressBar
var moisture_card: Label
var health_card: Label
var condition_card: Label
var seed_button: Button
var water_button: Button
var lamp_button: Button
var fertilizer_button: Button
var vent_button: Button
var growth_time_panel: PanelContainer
var growth_time_title_label: Label
var growth_time_value_label: Label

var metric_labels: Dictionary = {}
var metric_graph: MetricGraph
var measurement_metric_grid: GridContainer
var measurement_hero_panel: Control
var phase154_measurement_modern_contents: Array[Control] = []
var phase154_measurement_legacy_contents: Array[Control] = []
var phase154_measurement_legacy_value_labels: Dictionary = {}
var inventory_label: Label
var inventory_value_labels: Dictionary = {}
var harvest_label: Label
var storage_action_button: Button
var storage_progress_bar: ProgressBar
var storage_step_labels: Array[Label] = []
var storage_scroll: ScrollContainer
var measurement_scroll: ScrollContainer
var phase128_scene_heroes: Array[Control] = []
var phase128_scene_backdrops: Array[CanvasItem] = []
var phase128_legacy_headers: Array[Control] = []
var phase128_surface_styles: Array[Dictionary] = []
var phase128_label_styles: Array[Dictionary] = []
var phase128_plants_style_enabled := true
var customer_orders_panel: CustomerOrdersPanel
var order_card_panels: Array[PanelContainer] = []
var order_customer_labels: Array[Label] = []
var order_requirement_labels: Array[Label] = []
var order_reward_labels: Array[Label] = []
var order_buttons: Array[Button] = []
var order_decline_buttons: Array[Button] = []
var buy_seed_button: Button
var buy_mint_seed_button: Button
var buy_rosemary_seed_button: Button
var buy_oregano_seed_button: Button
var shop_seed_buttons: Dictionary = {}
var mint_shop_card: Control
var rosemary_shop_card: Control
var oregano_shop_card: Control
var buy_fertilizer_button: Button
var shop_balance_label: Label
var shop_feedback_label: Label
var shop_owned_labels: Dictionary = {}
var shop_equipment_buttons: Dictionary = {}
var shop_equipment_level_labels: Dictionary = {}
var shop_equipment_effect_labels: Dictionary = {}
var shop_scroll: ScrollContainer
var shop_column: VBoxContainer
var shop_runtime_layout: VBoxContainer
var shop_catalog_scroll: ScrollContainer
var shop_catalog_grid: GridContainer
var shop_legacy_header: Control
var shop_legacy_balance_label: Label
var shop_legacy_owned_labels: Dictionary = {}
var shop_hero_panel: Control
var shop_merchant_scene: TextureRect
var shop_merchant_dialog_label: Label
var shop_mode_tabs: Control
var shop_buy_tab_button: Button
var shop_sell_tab_button: Button
var shop_category_buttons: Dictionary = {}
var shop_buy_cards: Array[Control] = []
var shop_sell_panel: PanelContainer
var shop_sell_icon: TextureRect
var shop_sell_title_label: Label
var shop_sell_details_label: Label
var shop_sell_offer_label: Label
var shop_sell_button: Button
var shop_mode := "buy"
var shop_category := "all"
var shop_legacy_capture := false
var source_label: RichTextLabel

var refresh_accumulator := 0.0
var simulation_accumulator := 0.0
var last_coins_seen := -1
var last_xp_seen := -1
var autosave_accumulator := 0.0
var notification_destination_poll_accumulator := 0.0
var touch_start := Vector2.ZERO
var touch_tracking := false
var touch_axis_lock := ScreenNavigationControllerScene.DRAG_AXIS_UNDECIDED
var swipe_action_suppressed := false
var swipe_action_suppression_generation := 0


func _ready() -> void:
	get_tree().quit_on_go_back = false
	set_meta("global_swipe_navigation_component", "phase119_axis_locked_top_level_v1")
	set_meta("global_swipe_navigation_screens", 4)
	set_meta("swipe_action_guard_component", "phase122_drag_action_guard_v2")
	set_meta("swipe_action_guard_predecessor", "phase121_swipe_action_guard_v1")
	plant_catalog = _load_plant_catalog()
	profile = plant_catalog.get("basil_genovese", {})
	session = SaveManager.load_session(plant_catalog)
	var cold_start_offline_seconds := SaveManager.consume_last_load_offline_seconds()
	var returning_player := session.intro_completed
	care_notification_service.enter_foreground()
	_build_theme()
	_build_ui()
	_apply_display_safe_area()
	_apply_audio_settings()
	session.event_created.connect(_show_dialog)
	session.feedback_requested.connect(_on_session_feedback)
	session.journey_changed.connect(_on_journey_changed)
	session.slot_unlocked.connect(_on_slot_unlocked)
	session.fast_time_guard_triggered.connect(_on_fast_time_guard_triggered)
	session.story_progressed.connect(_on_professor_story_progressed)
	session.story_chapter_changed.connect(_on_professor_story_chapter_changed)
	plant_view.set_simulation(session.plant)
	room_overview.set_session(session)
	_apply_motion_preference()
	_refresh_ui()
	var needs_save_recovery := SaveManager.last_load_status in [SaveManager.STATUS_CORRUPT, SaveManager.STATUS_UNSUPPORTED, SaveManager.STATUS_BACKUP_READ_ONLY]
	if needs_save_recovery:
		call_deferred("_open_save_recovery")
	elif not session.intro_completed:
		call_deferred("_start_garden_handover", false)
	else:
		_show_dialog(session.get_journey_dialog_text() if not session.journey_completed else "Vítej zpět. Podívej se na hodnoty a rozhodni, co rostlina právě potřebuje.")
	if cold_start_offline_seconds > 0.0 and not needs_save_recovery:
		var cold_start_saved := _save_current_session()
		if cold_start_saved and returning_player:
			call_deferred("_present_return_summary", cold_start_offline_seconds)
	call_deferred("_consume_care_notification_destination")
	call_deferred("_check_fast_time_guard_after_load")


func _process(delta: float) -> void:
	if session.paused:
		simulation_accumulator = 0.0
	else:
		simulation_accumulator += delta
		if simulation_accumulator >= SIMULATION_TICK_SECONDS:
			var simulation_step := simulation_accumulator
			simulation_accumulator = 0.0
			session.advance(simulation_step)
	_sync_background_animation_state()
	if not fast_time_guard_pending.is_empty() and not _is_blocking_modal_open():
		_present_fast_time_guard()
	refresh_accumulator += delta
	autosave_accumulator += delta
	if care_notification_service.is_system_available():
		notification_destination_poll_accumulator += delta
		if notification_destination_poll_accumulator >= 1.0:
			notification_destination_poll_accumulator = 0.0
			_consume_care_notification_destination()
	if not session.paused and refresh_accumulator >= _get_active_ui_refresh_interval():
		refresh_accumulator = 0.0
		_refresh_active_ui()
	if autosave_accumulator >= 15.0 and not is_garden_handover_active:
		autosave_accumulator = 0.0
		_save_current_session()


func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT]:
		if player_room_view != null:
			player_room_view.cancel_plant_drag(true)
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		call_deferred("_apply_display_safe_area")
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		if not _consume_mobile_back_navigation():
			_request_safe_exit()
		return
	# Android overlays can briefly remove window focus without actually putting
	# the game in the background. Only a real pause/resume owns offline time and
	# the system reminder lifecycle; otherwise the 20-second test is cancelled,
	# rewritten and the game visibly flashes behind the transient system UI.
	if what == NOTIFICATION_APPLICATION_PAUSED:
		if session != null:
			if not external_file_picker_open:
				suspended_at_unix = Time.get_unix_time_from_system()
				if not care_notification_test_pending:
					care_notification_service.prepare_background_reminder(session, suspended_at_unix)
			_save_current_session(false)
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_request_safe_exit()
	if what == NOTIFICATION_APPLICATION_RESUMED:
		care_notification_service.enter_foreground()
		care_notification_test_pending = false
		if external_file_picker_open:
			suspended_at_unix = 0.0
		else:
			_resume_from_background()
		_present_pending_save_failure()
		call_deferred("_consume_care_notification_destination")


func _consume_mobile_back_navigation() -> bool:
	_reset_swipe_tracking()
	if player_room_view != null and player_room_view.plant_drag.is_tracking():
		player_room_view.cancel_plant_drag()
		return true
	if external_file_picker_open:
		return true
	if local_backup_open:
		_close_local_backup()
		return true
	# Tyto dva stavy chrání postup hráče a vyžadují výslovné rozhodnutí tlačítkem.
	if save_failure_open or save_recovery_open:
		return true
	if is_garden_handover_active:
		return true
	if professor_story_open:
		_close_professor_story()
		return true
	if grower_journal_open:
		_close_grower_journal()
		return true
	if plant_diagnosis_open:
		_close_plant_diagnosis()
		return true
	if dialog_open:
		_close_guide_modal()
		return true
	if settings_modal_open:
		_close_settings_modal()
		return true
	if seed_selector_open:
		_close_seed_selector()
		return true
	if herbarium_open:
		_close_herbarium()
		return true
	if botanical_pack_open:
		_close_botanical_pack_to_daily()
		return true
	if daily_challenge_open:
		_close_daily_challenge()
		return true
	if level_progression_open:
		_close_level_progression()
		return true
	if care_center_open:
		_close_care_center()
		return true
	if room_decoration_open:
		_close_room_decoration_modal()
		return true
	if cosmetic_modal_open:
		_close_cosmetic_modal()
		return true
	if return_summary_open:
		_close_return_summary()
		return true
	if active_screen == 0 and plant_detail_panel != null and plant_detail_panel.visible:
		_open_room()
		return true
	if active_screen == 0 and garden_location_id != GARDEN_LOCATION_RACK:
		_open_rack_location()
		return true
	if active_screen != 0:
		_change_screen(0)
		return true
	return false


func _request_safe_exit() -> bool:
	var saved_before_exit := true
	if session != null:
		if not external_file_picker_open:
			suspended_at_unix = Time.get_unix_time_from_system()
			if not care_notification_test_pending:
				care_notification_service.prepare_background_reminder(session, suspended_at_unix)
		saved_before_exit = _save_current_session(false)
	if saved_before_exit:
		get_tree().quit()
	else:
		_present_pending_save_failure()
	return saved_before_exit


func _input(event: InputEvent) -> void:
	# Phase166 owns the full plant gesture before GUI buttons or tab navigation.
	if player_room_view != null:
		player_room_view.set_plant_drag_enabled(_room_plant_drag_available())
		if event.is_action_pressed("ui_cancel") and player_room_view.plant_drag.is_tracking():
			player_room_view.cancel_plant_drag()
			get_viewport().set_input_as_handled()
			return
		if player_room_view.handle_plant_drag_input(event):
			_reset_swipe_tracking()
			get_viewport().set_input_as_handled()
			return
	if not _top_level_swipe_navigation_available():
		_reset_swipe_tracking()
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			_begin_swipe_tracking(event.position)
		elif touch_tracking:
			if _finish_swipe_tracking(event.position):
				get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and touch_tracking:
		if _update_swipe_axis(event.position) == ScreenNavigationControllerScene.DRAG_AXIS_HORIZONTAL:
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_begin_swipe_tracking(event.position)
		elif touch_tracking:
			if _finish_swipe_tracking(event.position):
				get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and touch_tracking and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
		if _update_swipe_axis(event.position) == ScreenNavigationControllerScene.DRAG_AXIS_HORIZONTAL:
			get_viewport().set_input_as_handled()


func _begin_swipe_tracking(position: Vector2) -> void:
	swipe_action_suppression_generation += 1
	swipe_action_suppressed = false
	touch_start = position
	touch_tracking = true
	touch_axis_lock = ScreenNavigationControllerScene.DRAG_AXIS_UNDECIDED


func _update_swipe_axis(position: Vector2) -> int:
	if not touch_tracking or touch_axis_lock != ScreenNavigationControllerScene.DRAG_AXIS_UNDECIDED:
		return touch_axis_lock
	touch_axis_lock = screen_navigation_controller.resolve_drag_axis(position - touch_start)
	if touch_axis_lock != ScreenNavigationControllerScene.DRAG_AXIS_UNDECIDED:
		swipe_action_suppressed = true
		if room_overview != null:
			room_overview.cancel_pointer_interactions()
	return touch_axis_lock


func _finish_swipe_tracking(position: Vector2) -> bool:
	if not touch_tracking:
		return false
	var delta := position - touch_start
	_update_swipe_axis(position)
	var horizontal_gesture := touch_axis_lock == ScreenNavigationControllerScene.DRAG_AXIS_HORIZONTAL
	var drag_action_suppressed := touch_axis_lock in [
		ScreenNavigationControllerScene.DRAG_AXIS_HORIZONTAL,
		ScreenNavigationControllerScene.DRAG_AXIS_VERTICAL,
	]
	if horizontal_gesture:
		_handle_swipe(delta)
	var suppression_generation := swipe_action_suppression_generation
	_reset_swipe_tracking(not drag_action_suppressed)
	if drag_action_suppressed:
		call_deferred("_clear_swipe_action_suppression", suppression_generation)
	return horizontal_gesture


func _reset_swipe_tracking(clear_action_suppression := true) -> void:
	touch_start = Vector2.ZERO
	touch_tracking = false
	touch_axis_lock = ScreenNavigationControllerScene.DRAG_AXIS_UNDECIDED
	if clear_action_suppression:
		swipe_action_suppression_generation += 1
		swipe_action_suppressed = false


func _clear_swipe_action_suppression(generation: int) -> void:
	if generation != swipe_action_suppression_generation or touch_tracking:
		return
	swipe_action_suppressed = false


func _handle_swipe(delta: Vector2) -> bool:
	var target_screen: int = screen_navigation_controller.resolve_swipe_target(delta, active_screen, screens.size())
	if target_screen < 0:
		return false
	if target_screen == active_screen:
		return true
	if target_screen == 0:
		_open_rack_location()
	_play_navigation_shine(target_screen)
	_change_screen(target_screen, true, screen_navigation_controller.physical_swipe_direction(delta))
	return true


func _top_level_swipe_navigation_available() -> bool:
	if screens.is_empty() or active_screen < 0 or active_screen >= screens.size():
		return false
	if _is_blocking_modal_open() or is_garden_handover_active or external_file_picker_open:
		return false
	if active_screen != 0:
		return true
	return garden_location_id == GARDEN_LOCATION_RACK and plants_room_panel != null and plants_room_panel.visible and plant_detail_panel != null and not plant_detail_panel.visible


func _room_plant_drag_available() -> bool:
	return session != null and active_screen == 0 and garden_location_id == GARDEN_LOCATION_PLAYER_ROOM and player_room_view != null and player_room_view.is_visible_in_tree() and not _is_blocking_modal_open() and not is_garden_handover_active and not external_file_picker_open


func _active_content_scroll() -> ScrollContainer:
	match active_screen:
		1:
			return storage_scroll
		2:
			if shop_catalog_scroll != null and shop_catalog_scroll.is_visible_in_tree():
				return shop_catalog_scroll
			return shop_scroll
		3:
			return measurement_scroll
	return null


func _point_is_inside_active_scroll(position: Vector2) -> bool:
	var scroll := _active_content_scroll()
	return scroll != null and scroll.is_visible_in_tree() and scroll.get_global_rect().has_point(position)


func _load_plant_catalog() -> Dictionary:
	return plant_catalog_repository.load_catalog()


func _build_theme() -> void:
	var app_theme := Theme.new()
	app_theme.default_font = FontRegular
	app_theme.default_font_size = 14
	app_theme.set_font("font", "Button", FontSemiBold)
	app_theme.set_font("font", "ProgressBar", FontSemiBold)
	app_theme.set_color("font_color", "Label", ComicUITheme.INK)
	app_theme.set_color("font_color", "Button", ComicUITheme.INK)
	app_theme.set_color("font_hover_color", "Button", ComicUITheme.INK)
	app_theme.set_color("font_pressed_color", "Button", ComicUITheme.INK)
	app_theme.set_color("font_disabled_color", "Button", Color(ComicUITheme.INK, 0.45))
	app_theme.set_stylebox("normal", "Button", ComicUITheme.style_box(ComicUITheme.CREAM, ComicUITheme.INK, 3, 11))
	app_theme.set_stylebox("hover", "Button", ComicUITheme.style_box(ComicUITheme.PAPER, ComicUITheme.CYAN, 3, 11, ComicUITheme.SHADOW, 4))
	app_theme.set_stylebox("pressed", "Button", ComicUITheme.style_box(Color("#e5c96f"), ComicUITheme.INK, 4, 11, Color("#0c1720", 0.18), 1))
	app_theme.set_stylebox("disabled", "Button", ComicUITheme.style_box(Color("#c8c6aa"), Color("#59616a"), 3, 11, Color.TRANSPARENT, 0))
	app_theme.set_stylebox("panel", "PanelContainer", ComicUITheme.style_box(ComicUITheme.PAPER, ComicUITheme.INK, 3, 14))
	app_theme.set_stylebox("panel", "Panel", ComicUITheme.style_box(ComicUITheme.PAPER, ComicUITheme.INK, 3, 14))
	app_theme.set_stylebox("panel", "TooltipPanel", ComicUITheme.style_box(ComicUITheme.CREAM, ComicUITheme.INK, 3, 9, ComicUITheme.SHADOW, 3, 7.0))
	app_theme.set_font("font", "TooltipLabel", FontSemiBold)
	app_theme.set_font_size("font_size", "TooltipLabel", 13)
	app_theme.set_color("font_color", "TooltipLabel", ComicUITheme.INK)
	app_theme.set_stylebox("background", "ProgressBar", ComicUITheme.style_box(Color("#174f56"), ComicUITheme.INK, 2, 8, Color.TRANSPARENT, 0, 0.0))
	app_theme.set_stylebox("fill", "ProgressBar", ComicUITheme.style_box(ComicUITheme.GREEN, Color("#2d8f30"), 2, 8, Color.TRANSPARENT, 0, 0.0))
	app_theme.set_color("font_color", "ProgressBar", Color.WHITE)
	app_theme.set_meta("visual_system", "comic_ui_v1")
	theme = app_theme


func _comic_style_box(fill: Color, border := DETAIL_INK, border_width := 3, radius := 12, shadow_color := Color("#0c1720", 0.30), shadow_size := 3, content_margin := 7.0) -> StyleBoxFlat:
	return ComicUITheme.style_box(fill, border, border_width, radius, shadow_color, shadow_size, content_margin)


func _apply_comic_button_style(button: Button, fill: Color, font_color := Color.WHITE, radius := 11) -> void:
	ComicUITheme.apply_button(button, fill, font_color, radius)


func _build_ui() -> void:
	edge_background = ColorRect.new()
	edge_background.color = ComicUITheme.NAVY
	edge_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	edge_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	edge_background.set_meta("component", "mobile_edge_to_edge_chrome_v1")
	edge_background.set_meta("covers_full_viewport", true)
	add_child(edge_background)

	safe_area_container = MarginContainer.new()
	safe_area_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe_area_container.set_meta("component", "dynamic_mobile_safe_area_v1")
	safe_area_container.set_meta("logical_canvas", "432x960")
	add_child(safe_area_container)
	safe_area_surface = ColorRect.new()
	safe_area_surface.color = ComicUITheme.PAPER
	safe_area_surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe_area_surface.mouse_filter = Control.MOUSE_FILTER_IGNORE
	safe_area_surface.set_meta("component", "safe_area_paper_surface_v1")
	safe_area_container.add_child(safe_area_surface)

	var root_layout := VBoxContainer.new()
	root_layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_layout.add_theme_constant_override("separation", 0)
	safe_area_container.add_child(root_layout)
	root_layout.add_child(_build_header())

	var content := Control.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_layout.add_child(content)

	screens = [
		_build_garden_screen(),
		_build_storage_screen(),
		_build_shop_screen(),
		_build_measurement_screen(),
	]
	for screen in screens:
		content.add_child(screen)
		screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	navigation_separator = PanelContainer.new()
	navigation_separator.custom_minimum_size.y = 9
	navigation_separator.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	navigation_separator.mouse_filter = Control.MOUSE_FILTER_IGNORE
	navigation_separator.add_theme_stylebox_override("panel", ComicUITheme.style_box(ComicUITheme.GOLD, ComicUITheme.INK, 2, 0, Color("#0c1720", 0.26), 2, 0.0))
	navigation_separator.set_meta("presentation", "comic_gold_transition")
	navigation_separator.set_meta("ui_kit", "comic_ui_v1")
	root_layout.add_child(navigation_separator)

	var navigation_dock := PanelContainer.new()
	navigation_dock.custom_minimum_size.y = 97
	navigation_dock.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	navigation_dock.set_meta("edge_presentation", "integrated_full_bleed")
	navigation_dock.set_meta("color_family", "comic_navy_cyan_gold")
	navigation_dock.set_meta("ui_kit", "comic_ui_v1")
	navigation_dock.add_theme_stylebox_override("panel", ComicUITheme.style_box(ComicUITheme.NAVY, ComicUITheme.INK, 0, 0, Color.TRANSPARENT, 0, 0.0))
	var navigation_safe_area := MarginContainer.new()
	navigation_safe_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	navigation_safe_area.add_theme_constant_override("margin_left", 0)
	navigation_safe_area.add_theme_constant_override("margin_right", 0)
	navigation_safe_area.add_theme_constant_override("margin_bottom", 0)
	navigation_safe_area.set_meta("safe_bottom_inset", 0)
	navigation_safe_area.set_meta("safe_area_fill", "inside_navigation_frame")
	navigation_safe_area.add_child(_build_navigation())
	navigation_dock.add_child(navigation_safe_area)
	root_layout.add_child(navigation_dock)
	feedback_layer = GameFeedbackLayerScene.new() as GameFeedbackLayer
	feedback_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	feedback_layer.z_index = 120
	add_child(feedback_layer)
	audio_haptics = GameAudioHapticsScene.new() as GameAudioHaptics
	audio_haptics.name = "AudioHaptics"
	add_child(audio_haptics)
	guide_modal = _build_guide_modal()
	add_child(guide_modal)
	guide_dialog_presenter.bind(dialog_label, detail_dialog_label)
	professor_story_modal = _build_professor_story_modal()
	add_child(professor_story_modal)
	settings_modal = _build_settings_modal()
	add_child(settings_modal)
	seed_selector_modal = _build_seed_selector_modal()
	add_child(seed_selector_modal)
	herbarium_modal = _build_herbarium_modal()
	add_child(herbarium_modal)
	cosmetic_modal = _build_cosmetic_modal()
	add_child(cosmetic_modal)
	room_decoration_modal = RoomDecorationModalScene.new()
	room_decoration_modal.close_requested.connect(_close_room_decoration_modal)
	room_decoration_modal.decoration_requested.connect(_on_room_decoration_requested)
	room_decoration_modal.clear_requested.connect(_on_room_decoration_clear_requested)
	add_child(room_decoration_modal)
	_configure_mobile_scroll(room_decoration_modal.scroll, room_decoration_modal.list_root, "room_decorations")
	daily_challenge_modal = _build_daily_challenge_modal()
	add_child(daily_challenge_modal)
	botanical_pack_modal = _build_botanical_pack_modal()
	add_child(botanical_pack_modal)
	level_progression_modal = _build_level_progression_modal()
	add_child(level_progression_modal)
	grower_journal_modal = _build_grower_journal_modal()
	add_child(grower_journal_modal)
	care_center_modal = _build_care_center_modal()
	add_child(care_center_modal)
	plant_diagnosis_modal = _build_plant_diagnosis_modal()
	add_child(plant_diagnosis_modal)
	return_summary_modal = _build_return_summary_modal()
	add_child(return_summary_modal)
	save_recovery_modal = _build_save_recovery_modal()
	add_child(save_recovery_modal)
	save_failure_modal = _build_save_failure_modal()
	add_child(save_failure_modal)
	local_backup_modal = _build_local_backup_modal()
	add_child(local_backup_modal)
	_change_screen(0)


func _logical_safe_margins(safe_rect: Rect2, window_size: Vector2, logical_size: Vector2) -> Vector4:
	if window_size.x <= 0.0 or window_size.y <= 0.0 or safe_rect.size.x <= 0.0 or safe_rect.size.y <= 0.0:
		return Vector4.ZERO
	var bounded_safe_rect := safe_rect.intersection(Rect2(Vector2.ZERO, window_size))
	if bounded_safe_rect.size.x <= 0.0 or bounded_safe_rect.size.y <= 0.0:
		return Vector4.ZERO
	var scale := logical_size / window_size
	var left := maxf(0.0, bounded_safe_rect.position.x * scale.x)
	var top := maxf(0.0, bounded_safe_rect.position.y * scale.y)
	var right := maxf(0.0, (window_size.x - bounded_safe_rect.end.x) * scale.x)
	var bottom := maxf(0.0, (window_size.y - bounded_safe_rect.end.y) * scale.y)
	return Vector4(left, top, right, bottom)


func _apply_display_safe_area() -> void:
	if safe_area_container == null or not is_inside_tree():
		return
	var window_size := Vector2(DisplayServer.window_get_size())
	var safe_rect := Rect2(DisplayServer.get_display_safe_area())
	_apply_safe_area_rect(safe_rect, window_size, get_viewport_rect().size)


func _apply_safe_area_rect(safe_rect: Rect2, window_size: Vector2, logical_size: Vector2) -> void:
	if safe_area_container == null:
		return
	safe_area_insets = _logical_safe_margins(safe_rect, window_size, logical_size)
	safe_area_container.add_theme_constant_override("margin_left", roundi(safe_area_insets.x))
	safe_area_container.add_theme_constant_override("margin_top", roundi(safe_area_insets.y))
	safe_area_container.add_theme_constant_override("margin_right", roundi(safe_area_insets.z))
	safe_area_container.add_theme_constant_override("margin_bottom", roundi(safe_area_insets.w))
	safe_area_container.set_meta("insets", safe_area_insets)


func _apply_hud_rect(control: Control, rect: Rect2) -> void:
	control.set_anchor(SIDE_LEFT, rect.position.x)
	control.set_anchor(SIDE_TOP, rect.position.y)
	control.set_anchor(SIDE_RIGHT, rect.end.x)
	control.set_anchor(SIDE_BOTTOM, rect.end.y)


func _build_header() -> Control:
	var panel := Control.new()
	panel.custom_minimum_size.y = HUD_HEIGHT
	panel.clip_contents = false
	panel.set_meta("color_family", "comic_cyan_blue_purple_gold")
	panel.set_meta("asset_set", "code_native_comic_ui_v1")
	panel.set_meta("visual_integration", "comic_full_width_three_card_bar")
	panel.set_meta("layout_set", "comic_hud_grid_v1")
	panel.set_meta("ui_kit", "comic_ui_v1")
	panel.set_meta("card_rects", HUD_CARD_RECTS)

	hud_background = ComicHudScene.new()
	hud_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(hud_background)

	# The emblem is code-drawn by ComicHud. This invisible marker exposes its
	# exact responsive anchor for deterministic tests and dynamic label layout.
	day_icon = TextureRect.new()
	_apply_hud_rect(day_icon, HUD_DAY_ICON_RECT)
	day_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	day_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	day_icon.modulate.a = 0.0
	day_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(day_icon)

	day_label = Label.new()
	_apply_hud_rect(day_label, HUD_DAY_TEXT_RECT)
	day_label.clip_text = true
	day_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	day_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	day_label.add_theme_font_override("font", FontExtraBold)
	day_label.add_theme_font_size_override("font_size", 13)
	day_label.add_theme_color_override("font_color", ComicUITheme.CREAM)
	day_label.add_theme_color_override("font_shadow_color", Color("#07131c"))
	day_label.add_theme_color_override("font_outline_color", ComicUITheme.INK)
	day_label.add_theme_constant_override("outline_size", 1)
	day_label.add_theme_constant_override("shadow_offset_x", 1)
	day_label.add_theme_constant_override("shadow_offset_y", 2)
	day_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(day_label)
	day_hud_presenter.bind(day_label)

	var coin_texture := TextureRect.new()
	coin_texture.texture = CoinTexture
	coin_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	coin_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	coin_texture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	coin_icon = coin_texture
	_apply_hud_rect(coin_icon, HUD_COIN_ICON_RECT)
	coin_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(coin_icon)

	coins_label = Label.new()
	_apply_hud_rect(coins_label, HUD_COIN_TEXT_RECT)
	coins_label.clip_text = true
	coins_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coins_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	coins_label.add_theme_font_override("font", FontExtraBold)
	coins_label.add_theme_font_size_override("font_size", 19)
	coins_label.add_theme_color_override("font_color", ComicUITheme.CREAM)
	coins_label.add_theme_color_override("font_shadow_color", Color("#07131c"))
	coins_label.add_theme_color_override("font_outline_color", ComicUITheme.INK)
	coins_label.add_theme_constant_override("outline_size", 1)
	coins_label.add_theme_constant_override("shadow_offset_x", 1)
	coins_label.add_theme_constant_override("shadow_offset_y", 2)
	coins_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(coins_label)
	coin_hud_presenter.bind(coins_label)

	xp_label = Label.new()
	_apply_hud_rect(xp_label, HUD_LEVEL_TEXT_RECT)
	xp_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	xp_label.add_theme_font_override("font", FontExtraBold)
	xp_label.add_theme_font_size_override("font_size", 13)
	xp_label.add_theme_color_override("font_color", ComicUITheme.CREAM)
	xp_label.add_theme_color_override("font_shadow_color", Color("#07131c"))
	xp_label.add_theme_color_override("font_outline_color", ComicUITheme.INK)
	xp_label.add_theme_constant_override("outline_size", 1)
	xp_label.add_theme_constant_override("shadow_offset_y", 2)
	xp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(xp_label)

	xp_gain_label = Label.new()
	_apply_hud_rect(xp_gain_label, HUD_XP_GAIN_RECT)
	xp_gain_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	xp_gain_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	xp_gain_label.add_theme_font_size_override("font_size", 11)
	xp_gain_label.add_theme_color_override("font_color", ComicUITheme.GOLD)
	xp_gain_label.add_theme_color_override("font_outline_color", ComicUITheme.INK)
	xp_gain_label.add_theme_constant_override("outline_size", 2)
	xp_gain_label.modulate.a = 0.0
	xp_gain_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(xp_gain_label)

	xp_bar = ProgressBar.new()
	_apply_hud_rect(xp_bar, HUD_XP_BAR_RECT)
	xp_bar.max_value = 100.0
	xp_bar.show_percentage = false
	xp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ComicUITheme.apply_progress(xp_bar, ComicUITheme.GOLD, Color("#2e2763"), ComicUITheme.INK, 6)
	panel.add_child(xp_bar)

	xp_value_label = Label.new()
	_apply_hud_rect(xp_value_label, HUD_XP_VALUE_RECT)
	xp_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	xp_value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	xp_value_label.add_theme_font_override("font", FontSemiBold)
	xp_value_label.add_theme_font_size_override("font_size", 8)
	xp_value_label.add_theme_color_override("font_color", ComicUITheme.INK)
	xp_value_label.add_theme_color_override("font_shadow_color", ComicUITheme.CREAM)
	xp_value_label.add_theme_constant_override("shadow_offset_y", 1)
	xp_value_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(xp_value_label)
	xp_hud_presenter.bind(xp_label, xp_value_label)
	daily_challenge_launcher = Button.new()
	daily_challenge_launcher.flat = true
	daily_challenge_launcher.focus_mode = Control.FOCUS_NONE
	TooltipPolicy.apply(daily_challenge_launcher, "Otevřít dnešní výzvu a předpověď")
	daily_challenge_launcher.set_anchor(SIDE_LEFT, HUD_CARD_RECTS[0].position.x)
	daily_challenge_launcher.set_anchor(SIDE_TOP, HUD_CARD_RECTS[0].position.y)
	daily_challenge_launcher.set_anchor(SIDE_RIGHT, HUD_CARD_RECTS[0].end.x)
	daily_challenge_launcher.set_anchor(SIDE_BOTTOM, HUD_CARD_RECTS[0].end.y)
	daily_challenge_launcher.set_meta("component", "transparent_daily_challenge_launcher_v1")
	daily_challenge_launcher.set_meta("touch_target_min_height", 64)
	var transparent := StyleBoxEmpty.new()
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		daily_challenge_launcher.add_theme_stylebox_override(state, transparent)
	daily_challenge_launcher.pressed.connect(_open_daily_challenge)
	panel.add_child(daily_challenge_launcher)
	level_progression_launcher = Button.new()
	level_progression_launcher.flat = true
	level_progression_launcher.focus_mode = Control.FOCUS_NONE
	TooltipPolicy.apply(level_progression_launcher, "Otevřít cestu pěstitele a odměny za úrovně")
	level_progression_launcher.set_anchor(SIDE_LEFT, HUD_CARD_RECTS[2].position.x)
	level_progression_launcher.set_anchor(SIDE_TOP, HUD_CARD_RECTS[2].position.y)
	level_progression_launcher.set_anchor(SIDE_RIGHT, HUD_CARD_RECTS[2].end.x)
	level_progression_launcher.set_anchor(SIDE_BOTTOM, HUD_CARD_RECTS[2].end.y)
	level_progression_launcher.set_meta("component", "transparent_level_progression_launcher_v1")
	level_progression_launcher.set_meta("touch_target_min_height", 64)
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		level_progression_launcher.add_theme_stylebox_override(state, transparent)
	level_progression_launcher.pressed.connect(_open_level_progression)
	panel.add_child(level_progression_launcher)
	return panel


func _build_garden_screen() -> Control:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 0)
	margin.add_theme_constant_override("margin_right", 0)
	margin.add_theme_constant_override("margin_top", 0)
	margin.add_theme_constant_override("margin_bottom", 0)
	var view_stack := Control.new()
	margin.add_child(view_stack)

	plants_room_panel = Control.new()
	plants_room_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	view_stack.add_child(plants_room_panel)
	plant_count_label = Label.new()
	plant_count_label.visible = false
	plants_room_panel.add_child(plant_count_label)
	room_overview = RoomOverviewScene.new()
	room_overview.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	room_overview.custom_minimum_size.y = 470
	room_overview.slot_selected.connect(_open_plant_detail)
	room_overview.light_toggle_requested.connect(_on_rack_light_toggle_requested)
	plants_room_panel.add_child(room_overview)
	var room_guide := _build_guide_panel(true)
	room_guide.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	room_guide.offset_bottom = GUIDE_PANEL_HEIGHT
	room_guide.set_meta("presentation", "overlay")
	plants_room_panel.add_child(room_guide)
	rack_greenhouse_button = _build_rack_location_button("←  SKLENÍK", ComicUITheme.TEAL)
	rack_greenhouse_button.position = Vector2(10.0, 96.0)
	rack_greenhouse_button.size = Vector2(124.0, 64.0)
	rack_greenhouse_button.set_meta("component", "phase103_rack_greenhouse_arrow_v1")
	rack_greenhouse_button.set_meta("attention_component", "phase109_greenhouse_attention_v1")
	rack_greenhouse_button.set_meta("touch_target_min", Vector2(124, 64))
	rack_greenhouse_button.set_meta("location_target", GARDEN_LOCATION_GREENHOUSE)
	rack_greenhouse_button.pressed.connect(_open_greenhouse)
	plants_room_panel.add_child(rack_greenhouse_button)
	_refresh_rack_greenhouse_attention()
	rack_player_room_button = _build_rack_location_button("POKOJ  →", ComicUITheme.PURPLE)
	rack_player_room_button.set_anchor(SIDE_LEFT, 1.0)
	rack_player_room_button.set_anchor(SIDE_RIGHT, 1.0)
	rack_player_room_button.offset_left = -122.0
	rack_player_room_button.offset_right = -10.0
	rack_player_room_button.offset_top = 96.0
	rack_player_room_button.offset_bottom = 160.0
	rack_player_room_button.set_meta("component", "phase103_rack_player_room_arrow_v1")
	rack_player_room_button.set_meta("location_target", GARDEN_LOCATION_PLAYER_ROOM)
	rack_player_room_button.pressed.connect(_open_player_room)
	plants_room_panel.add_child(rack_player_room_button)
	rack_pet_launcher_button = _build_rack_dock_launcher(
		plants_room_panel,
		0,
		RackDockPetTexture,
		ComicUITheme.CYAN,
		"phase183_rack_pet_launcher_v1",
		"pet_paw_phase183_v1.png",
		"Doplňky, mazlíček a vzhled pokoje",
		_open_cosmetic_modal
	)
	rack_pet_launcher_icon = rack_pet_launcher_button.get_node("Icon") as TextureRect
	professor_research_launcher_button = _build_rack_dock_launcher(
		plants_room_panel,
		1,
		RackDockProfessorTexture,
		ComicUITheme.ORANGE,
		"phase183_professor_research_launcher_v1",
		"professor_bazal_phase183_v1.png",
		"Otevřít Profesorův výzkum",
		_on_professor_research_launcher_pressed
	)
	professor_research_launcher_icon = professor_research_launcher_button.get_node("Icon") as TextureRect
	var story_badge := _build_rack_dock_badge(
		professor_research_launcher_button,
		"!",
		ComicUITheme.ORANGE,
		"professor_story_attention_badge_v2",
		Vector2(26.0, 26.0),
		15
	)
	story_badge.set_meta("state", "new_or_claimable")
	story_badge.set_meta("launcher", "phase183_rack_dock_professor")
	professor_story_badges.append(story_badge)
	professor_research_lock_badge = _build_rack_dock_badge(
		professor_research_launcher_button,
		"ZÁM",
		ComicUITheme.GOLD,
		"phase183_professor_lock_badge_v1",
		Vector2(32.0, 22.0),
		7
	)
	care_center_launcher_button = _build_rack_dock_launcher(
		plants_room_panel,
		2,
		RackDockCareTexture,
		ComicUITheme.GREEN,
		"phase183_rack_care_launcher_v1",
		"care_leaf_phase183_v1.png",
		"Otevřít přehled péče o rostliny",
		_open_care_center
	)
	care_center_launcher_icon = care_center_launcher_button.get_node("Icon") as TextureRect
	care_center_attention_badge = _build_rack_dock_badge(
		care_center_launcher_button,
		"0",
		ComicUITheme.ORANGE,
		"phase183_care_attention_badge_v1",
		Vector2(26.0, 26.0),
		12
	)
	care_center_attention_label = care_center_attention_badge.get_node("Label") as Label
	settings_launcher_button = _build_rack_dock_launcher(
		plants_room_panel,
		3,
		SettingsGearTexture,
		ComicUITheme.PURPLE,
		"phase183_player_settings_launcher_v1",
		"settings_gear_phase125.png",
		"Otevřít hráčské nastavení",
		_open_settings_modal
	)
	settings_launcher_icon = settings_launcher_button.get_node("Icon") as TextureRect

	player_room_panel = Control.new()
	player_room_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	player_room_panel.visible = false
	player_room_panel.set_meta("location_id", GARDEN_LOCATION_PLAYER_ROOM)
	view_stack.add_child(player_room_panel)
	player_room_view = PlayerRoomViewScene.new()
	player_room_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	player_room_view.rack_requested.connect(_open_rack_location)
	player_room_view.theme_requested.connect(_open_cosmetic_modal)
	player_room_view.decoration_slot_requested.connect(_open_room_decoration_modal)
	player_room_view.plant_move_requested.connect(_on_room_plant_move_requested)
	player_room_view.plant_drag_started.connect(_on_room_plant_drag_started)
	player_room_view.set_room_decorations(session.get_room_decoration_slots(), GameSession.ROOM_DECORATIONS)
	player_room_panel.add_child(player_room_view)

	greenhouse_panel = Control.new()
	greenhouse_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	greenhouse_panel.visible = false
	greenhouse_panel.set_meta("location_id", GARDEN_LOCATION_GREENHOUSE)
	view_stack.add_child(greenhouse_panel)
	greenhouse_preview_view = GreenhousePreviewViewScene.new()
	greenhouse_preview_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	greenhouse_preview_view.rack_requested.connect(_open_rack_location)
	greenhouse_preview_view.bed_action_requested.connect(_on_greenhouse_bed_action_requested)
	greenhouse_preview_view.crop_plant_requested.connect(_on_greenhouse_crop_plant_requested)
	greenhouse_panel.add_child(greenhouse_preview_view)
	greenhouse_preview_view.set_greenhouse_state(session.get_greenhouse_bed_states(), session.get_greenhouse_crop_catalog(), session.coins, session.xp, session.get_greenhouse_order_state())

	plant_detail_panel = VBoxContainer.new()
	plant_detail_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	plant_detail_panel.add_theme_constant_override("separation", 5)
	plant_detail_panel.set_meta("phase3_visual_system", "mobile_comic_detail_v1")
	plant_detail_panel.set_meta("touch_target_policy", "primary_actions_64px_min")
	plant_detail_panel.set_meta("effect_language", "water_wind_ladybug_gold_v1")
	plant_detail_panel.visible = false
	view_stack.add_child(plant_detail_panel)

	plant_detail_selector = preload("res://scripts/ui/plant_detail_header.gd").new()
	plant_detail_selector.name = "PlantDetailHeader"
	plant_detail_selector.custom_minimum_size.y = 50
	plant_detail_selector.add_theme_constant_override("separation", 5)
	plant_detail_selector.set_meta("component", "phase157_responsive_detail_header_v1")
	plant_detail_selector.set_meta("fits_parent_width", true)
	plant_detail_panel.add_child(plant_detail_selector)
	var room_button := _action_button("←  STOJAN", _open_room)
	room_button.custom_minimum_size = Vector2(108, 50)
	room_button.add_theme_font_override("font", FontExtraBold)
	room_button.add_theme_font_size_override("font_size", 13)
	_apply_comic_button_style(room_button, DETAIL_BLUE)
	plant_detail_selector.add_child(room_button)
	var previous_button := _action_button("‹", _select_adjacent_plant.bind(-1))
	previous_button.custom_minimum_size = Vector2(48, 50)
	previous_button.add_theme_font_override("font", FontExtraBold)
	previous_button.add_theme_font_size_override("font_size", 24)
	_apply_comic_button_style(previous_button, DETAIL_CYAN, DETAIL_INK)
	plant_detail_selector.add_child(previous_button)
	var plant_selector_panel := PanelContainer.new()
	plant_selector_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	plant_selector_panel.add_theme_stylebox_override("panel", _comic_style_box(DETAIL_CREAM, DETAIL_BLUE, 3, 12, Color("#0c1720", 0.28), 3, 5.0))
	plant_position_label = Label.new()
	plant_position_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	plant_position_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	plant_position_label.clip_text = true
	plant_position_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	plant_position_label.add_theme_font_override("font", FontExtraBold)
	plant_position_label.add_theme_font_size_override("font_size", 12)
	plant_position_label.add_theme_color_override("font_color", DETAIL_INK)
	plant_selector_panel.add_child(plant_position_label)
	garden_selection_presenter.bind(plant_count_label, plant_position_label)
	plant_detail_selector.add_child(plant_selector_panel)
	var next_button := _action_button("›", _select_adjacent_plant.bind(1))
	next_button.custom_minimum_size = Vector2(48, 50)
	next_button.add_theme_font_override("font", FontExtraBold)
	next_button.add_theme_font_size_override("font_size", 24)
	_apply_comic_button_style(next_button, DETAIL_CYAN, DETAIL_INK)
	plant_detail_selector.add_child(next_button)
	herbarium_launcher_button = _action_button("HERBÁŘ", _open_herbarium)
	herbarium_launcher_button.custom_minimum_size = Vector2(68, 50)
	herbarium_launcher_button.add_theme_font_override("font", FontExtraBold)
	herbarium_launcher_button.add_theme_font_size_override("font_size", 10)
	herbarium_launcher_button.set_meta("component", "herbarium_detail_launcher_v1")
	herbarium_launcher_button.set_meta("touch_target", Vector2(68, 50))
	_apply_comic_button_style(herbarium_launcher_button, DETAIL_PURPLE, Color.WHITE)
	plant_detail_selector.add_child(herbarium_launcher_button)

	var detail_view_stack := Control.new()
	detail_view_stack.custom_minimum_size = Vector2(0, 300)
	detail_view_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	plant_detail_panel.add_child(detail_view_stack)
	plant_view = PlantViewScene.new()
	plant_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	detail_view_stack.add_child(plant_view)
	plant_behavior_badge = PanelContainer.new()
	plant_behavior_badge.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	plant_behavior_badge.offset_left = -250.0
	plant_behavior_badge.offset_top = 10.0
	plant_behavior_badge.offset_right = -10.0
	plant_behavior_badge.offset_bottom = 82.0
	plant_behavior_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plant_behavior_badge.z_index = 3
	plant_behavior_badge.visible = false
	plant_behavior_badge.set_meta("component", "plant_behavior_active_badge_v1")
	plant_behavior_badge.set_meta("active_only", true)
	plant_behavior_badge.add_theme_stylebox_override("panel", _comic_style_box(Color("#effff2", 0.97), DETAIL_GREEN, 3, 11, Color("#0c1720", 0.30), 3, 6.0))
	var behavior_badge_column := VBoxContainer.new()
	behavior_badge_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	behavior_badge_column.custom_minimum_size.y = 56.0
	behavior_badge_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	behavior_badge_column.add_theme_constant_override("separation", 0)
	plant_behavior_badge.add_child(behavior_badge_column)
	plant_behavior_badge_title = Label.new()
	plant_behavior_badge_title.text = "VLASTNOST AKTIVNÍ"
	plant_behavior_badge_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plant_behavior_badge_title.add_theme_font_override("font", FontExtraBold)
	plant_behavior_badge_title.add_theme_font_size_override("font_size", 8)
	plant_behavior_badge_title.add_theme_color_override("font_color", Color("#16865a"))
	behavior_badge_column.add_child(plant_behavior_badge_title)
	plant_behavior_badge_value = Label.new()
	plant_behavior_badge_value.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plant_behavior_badge_value.custom_minimum_size.y = 36.0
	plant_behavior_badge_value.size_flags_vertical = Control.SIZE_EXPAND_FILL
	plant_behavior_badge_value.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	plant_behavior_badge_value.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	plant_behavior_badge_value.max_lines_visible = 2
	plant_behavior_badge_value.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	plant_behavior_badge_value.add_theme_font_override("font", FontSemiBold)
	plant_behavior_badge_value.add_theme_font_size_override("font_size", 9)
	plant_behavior_badge_value.add_theme_color_override("font_color", DETAIL_INK)
	behavior_badge_column.add_child(plant_behavior_badge_value)
	detail_view_stack.add_child(plant_behavior_badge)
	plant_behavior_presenter.bind(plant_behavior_badge, plant_behavior_badge_title, plant_behavior_badge_value)
	var detail_guide := _build_guide_panel(false)
	detail_guide.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	detail_guide.offset_bottom = GUIDE_PANEL_HEIGHT
	detail_guide.set_meta("presentation", "overlay")
	detail_view_stack.add_child(detail_guide)

	var growth_panel := PanelContainer.new()
	growth_panel.custom_minimum_size.y = 64
	growth_panel.add_theme_stylebox_override("panel", _comic_style_box(DETAIL_CREAM, DETAIL_ORANGE, 3, 12, Color("#0c1720", 0.30), 3, 7.0))
	growth_panel.set_meta("component", "comic_growth_card_v1")
	var growth_column := VBoxContainer.new()
	growth_column.alignment = BoxContainer.ALIGNMENT_CENTER
	growth_column.add_theme_constant_override("separation", 2)
	growth_panel.add_child(growth_column)
	var progress_row := HBoxContainer.new()
	stage_label = Label.new()
	stage_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stage_label.add_theme_font_override("font", FontExtraBold)
	stage_label.add_theme_font_size_override("font_size", 14)
	stage_label.add_theme_color_override("font_color", DETAIL_INK)
	progress_row.add_child(stage_label)
	growth_label = Label.new()
	growth_label.add_theme_font_override("font", FontExtraBold)
	growth_label.add_theme_font_size_override("font_size", 15)
	growth_label.add_theme_color_override("font_color", DETAIL_INK)
	progress_row.add_child(growth_label)
	growth_column.add_child(progress_row)
	growth_bar = ProgressBar.new()
	growth_bar.max_value = 100
	growth_bar.show_percentage = false
	growth_bar.custom_minimum_size.y = 18
	growth_bar.add_theme_stylebox_override("background", _comic_style_box(Color("#174f56"), DETAIL_INK, 2, 8, Color.TRANSPARENT, 0, 0.0))
	growth_bar.add_theme_stylebox_override("fill", _comic_style_box(DETAIL_GREEN, Color("#2d8f30"), 2, 8, Color.TRANSPARENT, 0, 0.0))
	growth_column.add_child(growth_bar)
	plant_detail_panel.add_child(growth_panel)

	var cards := HBoxContainer.new()
	cards.custom_minimum_size.y = 70
	cards.add_theme_constant_override("separation", 5)
	moisture_card = _add_stat_card(cards, "VLHKOST", WaterIcon)
	health_card = _add_stat_card(cards, "ZDRAVÍ", NavPlantIcon)
	condition_card = _add_stat_card(cards, "PODMÍNKY", SunIcon)
	var condition_panel := condition_card.get_parent().get_parent().get_parent() as PanelContainer
	plant_diagnosis_launcher = Button.new()
	plant_diagnosis_launcher.name = "PlantDiagnosisLauncher"
	plant_diagnosis_launcher.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	plant_diagnosis_launcher.flat = true
	plant_diagnosis_launcher.focus_mode = Control.FOCUS_NONE
	plant_diagnosis_launcher.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	TooltipPolicy.apply(plant_diagnosis_launcher, "Otevřít diagnostiku rostliny")
	plant_diagnosis_launcher.set_meta("component", "plant_diagnosis_launcher_v1")
	plant_diagnosis_launcher.set_meta("touch_target_min_height", 70)
	plant_diagnosis_launcher.set_meta("transparent_overlay", true)
	var empty_style := StyleBoxEmpty.new()
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		plant_diagnosis_launcher.add_theme_stylebox_override(state, empty_style)
	plant_diagnosis_launcher.pressed.connect(_open_plant_diagnosis)
	condition_panel.add_child(plant_diagnosis_launcher)
	plant_vitals_presenter.bind(stage_label, growth_label, growth_bar, moisture_card, health_card, condition_card)
	plant_detail_panel.add_child(cards)

	var action_row := HBoxContainer.new()
	action_row.custom_minimum_size.y = 68
	action_row.add_theme_constant_override("separation", 4)
	seed_button = _icon_action_button("ZASADIT", _on_seed_pressed, NavPlantIcon, ButtonGreenTexture)
	water_button = _icon_action_button("Zalít 120 ml", _on_water_pressed, WaterIcon, ButtonBlueTexture)
	lamp_button = _icon_action_button("Světlo", _on_lamp_pressed, SunIcon, ButtonYellowTexture, COLORS.ink)
	fertilizer_button = _icon_action_button("Hnojit · 1×", _on_fertilize_pressed, FertilizerIcon, ButtonPurpleTexture)
	vent_button = _icon_action_button("Vyvětrat", _on_ventilate_pressed, WindIcon, ButtonTealTexture)
	for button in [seed_button, water_button, lamp_button, fertilizer_button, vent_button]:
		action_row.add_child(button)
	plant_action_presenter.bind(seed_button, water_button, lamp_button, fertilizer_button, vent_button)
	plant_detail_panel.add_child(action_row)

	growth_time_panel = PanelContainer.new()
	growth_time_panel.custom_minimum_size.y = 52
	growth_time_panel.add_theme_stylebox_override("panel", _comic_style_box(Color("#dff8f5"), DETAIL_CYAN, 3, 11, Color("#0c1720", 0.28), 3, 5.0))
	growth_time_panel.set_meta("component", "comic_real_time_growth_v1")
	var growth_time_column := VBoxContainer.new()
	growth_time_column.alignment = BoxContainer.ALIGNMENT_CENTER
	growth_time_column.add_theme_constant_override("separation", 0)
	growth_time_panel.add_child(growth_time_column)
	growth_time_title_label = Label.new()
	growth_time_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	growth_time_title_label.add_theme_font_override("font", FontExtraBold)
	growth_time_title_label.add_theme_font_size_override("font_size", 11)
	growth_time_title_label.add_theme_color_override("font_color", DETAIL_INK)
	growth_time_column.add_child(growth_time_title_label)
	growth_time_value_label = Label.new()
	growth_time_value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	growth_time_value_label.add_theme_font_override("font", FontSemiBold)
	growth_time_value_label.add_theme_font_size_override("font_size", 12)
	growth_time_value_label.add_theme_color_override("font_color", Color("#176b70"))
	growth_time_column.add_child(growth_time_value_label)
	real_time_growth_presenter.bind(growth_time_title_label, growth_time_value_label)
	plant_detail_panel.add_child(growth_time_panel)
	return margin


func _build_guide_panel(primary: bool) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size.y = GUIDE_PANEL_HEIGHT
	panel.clip_contents = false
	panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	var canvas := Control.new()
	canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	canvas.clip_contents = false
	canvas.mouse_filter = Control.MOUSE_FILTER_PASS
	panel.add_child(canvas)
	var info_icon := TextureRect.new()
	info_icon.texture = InfoQuestionTexture
	info_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	info_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	info_icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	info_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(info_icon)
	var portrait_button := Button.new()
	portrait_button.flat = true
	portrait_button.focus_mode = Control.FOCUS_NONE
	portrait_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	TooltipPolicy.apply(portrait_button, "Zobrazit nápovědu")
	for state in ["normal", "hover", "pressed", "focus", "disabled", "hover_pressed"]:
		portrait_button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	portrait_button.pressed.connect(_toggle_guide_dialog.bind(primary))
	canvas.add_child(portrait_button)
	if primary:
		dialog_panel = panel
		dialog_toggle_button = portrait_button
		dialog_info_icon = info_icon
	else:
		detail_dialog_panel = panel
		detail_dialog_toggle_button = portrait_button
		detail_dialog_info_icon = info_icon
	panel.set_meta("interaction", "open_fullscreen_guide_modal")
	panel.set_meta("professor_research_launcher", "moved_to_compact_rack_dock_phase183_v1" if primary else "not_present_in_detail")
	panel.set_meta("background_mode", "launcher_only")
	panel.set_meta("closed_visual", "question_only")
	panel.set_meta("touch_target_min", 64)
	panel.set_meta("ui_kit", "comic_ui_v1")
	canvas.resized.connect(_sync_guide_launcher.bind(canvas, portrait_button, info_icon))
	_sync_guide_launcher(canvas, portrait_button, info_icon)
	return panel


func _sync_guide_launcher(_canvas: Control, portrait_button: Button, info_icon: TextureRect) -> void:
	portrait_button.position = GUIDE_INFO_HIT_POSITION
	portrait_button.size = GUIDE_INFO_HIT_SIZE
	info_icon.size = GUIDE_INFO_ICON_SIZE
	info_icon.position = GUIDE_INFO_ICON_POSITION
	info_icon.modulate.a = 1.0


func _build_guide_modal() -> Control:
	var overlay := Control.new()
	overlay.name = "GuideModal"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.clip_contents = true
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.z_index = 180
	overlay.visible = false
	overlay.set_meta("component", "fullscreen_guide_modal_v1")
	overlay.set_meta("presentation", "dimmed_blocking_full_body")
	overlay.set_meta("covers_full_viewport", true)
	overlay.set_meta("blocks_game_input", true)
	guide_modal_dimmer = ColorRect.new()
	guide_modal_dimmer.name = "Dimmer"
	guide_modal_dimmer.color = GUIDE_MODAL_DIM
	guide_modal_dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	guide_modal_dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	guide_modal_dimmer.gui_input.connect(_on_guide_modal_dimmer_input)
	overlay.add_child(guide_modal_dimmer)
	guide_modal_character = GuideCharacterScene.new() as GuideCharacter
	guide_modal_character.name = "ProfessorBazalFullBody"
	guide_modal_character.set_anchor(SIDE_LEFT, 0.0)
	guide_modal_character.set_anchor(SIDE_TOP, 0.25)
	guide_modal_character.set_anchor(SIDE_RIGHT, 1.0)
	guide_modal_character.set_anchor(SIDE_BOTTOM, 0.99)
	guide_modal_character.z_index = 4
	guide_modal_character.set_full_body(true)
	overlay.add_child(guide_modal_character)
	guide_modal_card = PanelContainer.new()
	guide_modal_card.name = "DialogCard"
	guide_modal_card.set_anchor(SIDE_LEFT, 0.035)
	guide_modal_card.set_anchor(SIDE_TOP, 0.075)
	guide_modal_card.set_anchor(SIDE_RIGHT, 0.965)
	guide_modal_card.set_anchor(SIDE_BOTTOM, GUIDE_MODAL_CARD_BOTTOM)
	guide_modal_card.z_index = 6
	guide_modal_card.mouse_filter = Control.MOUSE_FILTER_STOP
	guide_modal_card.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff5ce", 0.995), ComicUITheme.CYAN, 4, 18, Color("#071823", 0.52), 8, 0.0))
	guide_modal_card.set_meta("component", "separate_guide_dialog_card_v1")
	var card_canvas := Control.new()
	card_canvas.mouse_filter = Control.MOUSE_FILTER_PASS
	guide_modal_card.add_child(card_canvas)
	guide_modal_label = Label.new()
	guide_modal_label.set_anchor(SIDE_LEFT, 0.065)
	guide_modal_label.set_anchor(SIDE_TOP, 0.27)
	guide_modal_label.set_anchor(SIDE_RIGHT, 0.935)
	guide_modal_label.set_anchor(SIDE_BOTTOM, 0.66)
	guide_modal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	guide_modal_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	guide_modal_label.add_theme_font_override("font", FontSemiBold)
	guide_modal_label.add_theme_font_size_override("font_size", 14)
	guide_modal_label.add_theme_color_override("font_color", ComicUITheme.INK)
	guide_modal_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_canvas.add_child(guide_modal_label)
	guide_modal_confirm_button = Button.new()
	guide_modal_confirm_button.text = "ROZUMÍM"
	guide_modal_confirm_button.set_anchor(SIDE_LEFT, 0.52)
	guide_modal_confirm_button.set_anchor(SIDE_TOP, 0.70)
	guide_modal_confirm_button.set_anchor(SIDE_RIGHT, 0.94)
	guide_modal_confirm_button.set_anchor(SIDE_BOTTOM, 0.94)
	guide_modal_confirm_button.focus_mode = Control.FOCUS_NONE
	guide_modal_confirm_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	_apply_comic_button_style(guide_modal_confirm_button, ComicUITheme.GREEN, Color.WHITE, 12)
	guide_modal_confirm_button.pressed.connect(_on_guide_modal_confirm_pressed)
	card_canvas.add_child(guide_modal_confirm_button)
	reduce_motion_button = Button.new()
	reduce_motion_button.toggle_mode = true
	reduce_motion_button.button_pressed = session.reduced_motion
	reduce_motion_button.text = "MÉNĚ POHYBU"
	reduce_motion_button.set_anchor(SIDE_LEFT, 0.06)
	reduce_motion_button.set_anchor(SIDE_TOP, 0.70)
	reduce_motion_button.set_anchor(SIDE_RIGHT, 0.49)
	reduce_motion_button.set_anchor(SIDE_BOTTOM, 0.94)
	reduce_motion_button.focus_mode = Control.FOCUS_NONE
	reduce_motion_button.add_theme_font_override("font", FontExtraBold)
	reduce_motion_button.add_theme_font_size_override("font_size", 11)
	_apply_comic_button_style(reduce_motion_button, ComicUITheme.CYAN, ComicUITheme.INK, 12)
	reduce_motion_button.toggled.connect(_on_reduce_motion_toggled)
	reduce_motion_button.set_meta("component", "reduced_motion_toggle_v1")
	reduce_motion_button.set_meta("touch_target_min_height", 48)
	card_canvas.add_child(reduce_motion_button)
	overlay.add_child(guide_modal_card)
	guide_modal_name_badge = PanelContainer.new()
	guide_modal_name_badge.name = "ProfessorNameBadge"
	guide_modal_name_badge.set_anchor(SIDE_LEFT, 0.085)
	guide_modal_name_badge.set_anchor(SIDE_TOP, 0.048)
	guide_modal_name_badge.set_anchor(SIDE_RIGHT, 0.62)
	guide_modal_name_badge.set_anchor(SIDE_BOTTOM, 0.125)
	guide_modal_name_badge.z_index = 7
	guide_modal_name_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	guide_modal_name_badge.add_theme_stylebox_override("panel", ComicUITheme.style_box(ComicUITheme.GREEN, ComicUITheme.GOLD, 4, 14, Color("#071823", 0.44), 5, 5.0))
	guide_modal_name_badge.set_meta("component", "guide_name_badge_v1")
	guide_modal_name_label = Label.new()
	guide_modal_name_label.text = "PROFESOR BAZAL"
	guide_modal_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	guide_modal_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	guide_modal_name_label.add_theme_font_override("font", FontExtraBold)
	guide_modal_name_label.add_theme_font_size_override("font_size", 14)
	guide_modal_name_label.add_theme_color_override("font_color", Color.WHITE)
	guide_modal_name_label.add_theme_color_override("font_shadow_color", Color("#15384a", 0.9))
	guide_modal_name_label.add_theme_constant_override("shadow_offset_x", 1)
	guide_modal_name_label.add_theme_constant_override("shadow_offset_y", 2)
	guide_modal_name_badge.add_child(guide_modal_name_label)
	overlay.add_child(guide_modal_name_badge)
	guide_modal_close_button = Button.new()
	guide_modal_close_button.text = "×"
	guide_modal_close_button.set_anchor(SIDE_LEFT, 0.84)
	guide_modal_close_button.set_anchor(SIDE_TOP, 0.025)
	guide_modal_close_button.set_anchor(SIDE_RIGHT, 0.97)
	guide_modal_close_button.set_anchor(SIDE_BOTTOM, 0.092)
	guide_modal_close_button.z_index = 8
	guide_modal_close_button.focus_mode = Control.FOCUS_NONE
	guide_modal_close_button.add_theme_font_override("font", FontExtraBold)
	guide_modal_close_button.add_theme_font_size_override("font_size", 28)
	_apply_comic_button_style(guide_modal_close_button, ComicUITheme.ORANGE, Color.WHITE, 14)
	TooltipPolicy.apply(guide_modal_close_button, "Zavřít")
	guide_modal_close_button.pressed.connect(_on_guide_modal_close_pressed)
	overlay.add_child(guide_modal_close_button)
	dialog_label = guide_modal_label
	detail_dialog_label = guide_modal_label
	dialog_reveal = guide_modal_character
	detail_dialog_reveal = guide_modal_character
	guide_portrait = guide_modal_character
	return overlay


func _build_professor_story_modal() -> Control:
	var overlay := Control.new()
	overlay.name = "ProfessorStoryModal"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	overlay.z_index = 232
	overlay.visible = false
	overlay.set_meta("component", "fullscreen_professor_story_modal_v1")
	overlay.set_meta("chapter_contract", "three_chapter_story_v1")
	overlay.set_meta("chapter_ids", ["lost_herbarium_pages", "silver_sage_legacy", "grand_herbarium_exhibition"])
	overlay.set_meta("presentation_modes", ["story_chapter", "weekly_research"])
	overlay.set_meta("weekly_research_contract", "schema27_repeatable_weekly_v1")
	overlay.set_meta("goal_card_capacity", 5)
	overlay.set_meta("responsive_test_viewports", [Vector2i(432, 960), Vector2i(360, 800)])
	overlay.set_meta("presentation", "blocking_fullscreen_scroll")
	overlay.set_meta("blocks_game_input", true)
	overlay.set_meta("covers_full_viewport", true)
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color("#061522", 0.965)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(scrim)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 13)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 13)
	margin.add_theme_constant_override("margin_bottom", 16)
	overlay.add_child(margin)
	var shell := PanelContainer.new()
	shell.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff8dc"), ComicUITheme.GOLD, 5, 22, Color("#000713", 0.66), 10, 12.0))
	shell.set_meta("component", "comic_professor_story_shell_v1")
	margin.add_child(shell)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 7)
	shell.add_child(column)
	var banner := PanelContainer.new()
	banner.custom_minimum_size.y = 72
	banner.add_theme_stylebox_override("panel", ComicUITheme.style_box(ComicUITheme.PURPLE.darkened(0.16), ComicUITheme.GOLD, 4, 17, Color("#07131c", 0.38), 4, 8.0))
	column.add_child(banner)
	var banner_row := HBoxContainer.new()
	banner_row.add_theme_constant_override("separation", 7)
	banner.add_child(banner_row)
	var heading := VBoxContainer.new()
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.alignment = BoxContainer.ALIGNMENT_CENTER
	heading.add_theme_constant_override("separation", -2)
	banner_row.add_child(heading)
	var title := Label.new()
	title.text = "PROFESORŮV VÝZKUM"
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 19)
	title.add_theme_color_override("font_color", ComicUITheme.CREAM)
	title.add_theme_color_override("font_outline_color", ComicUITheme.INK)
	title.add_theme_constant_override("outline_size", 3)
	heading.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Dlouhodobé stopy napříč zahradou"
	subtitle.add_theme_font_override("font", FontSemiBold)
	subtitle.add_theme_font_size_override("font_size", 9)
	subtitle.add_theme_color_override("font_color", Color("#fff0b2"))
	heading.add_child(subtitle)
	var top_close := _action_button("×", _close_professor_story)
	top_close.custom_minimum_size = Vector2(56, 56)
	top_close.size_flags_horizontal = Control.SIZE_SHRINK_END
	top_close.set_meta("touch_target_min_height", 56)
	top_close.add_theme_font_override("font", FontExtraBold)
	top_close.add_theme_font_size_override("font_size", 25)
	ComicUITheme.apply_button(top_close, ComicUITheme.ORANGE, ComicUITheme.CREAM, 13)
	banner_row.add_child(top_close)
	var chapter_panel := PanelContainer.new()
	chapter_panel.custom_minimum_size.y = 120
	chapter_panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff1b8"), ComicUITheme.PURPLE, 3, 14, Color("#07131c", 0.20), 3, 7.0))
	chapter_panel.set_meta("component", "professor_story_chapter_header_v1")
	column.add_child(chapter_panel)
	var chapter_column := VBoxContainer.new()
	chapter_column.alignment = BoxContainer.ALIGNMENT_CENTER
	chapter_column.add_theme_constant_override("separation", 1)
	chapter_panel.add_child(chapter_column)
	professor_story_chapter_title_label = Label.new()
	professor_story_chapter_title_label.text = "ZTRACENÉ STRÁNKY HERBÁŘE"
	professor_story_chapter_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	professor_story_chapter_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	professor_story_chapter_title_label.max_lines_visible = 2
	professor_story_chapter_title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	professor_story_chapter_title_label.add_theme_font_override("font", FontExtraBold)
	professor_story_chapter_title_label.add_theme_font_size_override("font_size", 15)
	professor_story_chapter_title_label.add_theme_color_override("font_color", ComicUITheme.PURPLE.darkened(0.24))
	chapter_column.add_child(professor_story_chapter_title_label)
	professor_story_body_label = Label.new()
	professor_story_body_label.custom_minimum_size.y = 50
	professor_story_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	professor_story_body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	professor_story_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	professor_story_body_label.max_lines_visible = 3
	professor_story_body_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	professor_story_body_label.add_theme_font_override("font", FontSemiBold)
	professor_story_body_label.add_theme_font_size_override("font_size", 9)
	professor_story_body_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	chapter_column.add_child(professor_story_body_label)
	professor_story_summary_label = Label.new()
	professor_story_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	professor_story_summary_label.add_theme_font_override("font", FontExtraBold)
	professor_story_summary_label.add_theme_font_size_override("font_size", 10)
	professor_story_summary_label.add_theme_color_override("font_color", ComicUITheme.GREEN.darkened(0.28))
	chapter_column.add_child(professor_story_summary_label)
	professor_story_scroll = ScrollContainer.new()
	professor_story_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	professor_story_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	professor_story_scroll.set_meta("mobile_scroll", true)
	professor_story_scroll.set_meta("scroll_contract", "five_story_goal_cards_v1")
	column.add_child(professor_story_scroll)
	var goal_list := VBoxContainer.new()
	goal_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	goal_list.add_theme_constant_override("separation", 8)
	professor_story_scroll.add_child(goal_list)
	for goal_index in range(5):
		goal_list.add_child(_build_professor_story_goal_card(goal_index))
	_configure_mobile_scroll(professor_story_scroll, goal_list, "professor_story")
	var reward_panel := PanelContainer.new()
	reward_panel.custom_minimum_size.y = 68
	reward_panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#dcf8d1"), ComicUITheme.GREEN, 3, 13, Color("#07131c", 0.20), 3, 6.0))
	reward_panel.set_meta("component", "professor_story_reward_v1")
	column.add_child(reward_panel)
	var reward_column := VBoxContainer.new()
	reward_column.alignment = BoxContainer.ALIGNMENT_CENTER
	reward_column.add_theme_constant_override("separation", 0)
	reward_panel.add_child(reward_column)
	professor_story_reward_title_label = Label.new()
	professor_story_reward_title_label.text = "ODMĚNA ZA KAPITOLU"
	professor_story_reward_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	professor_story_reward_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	professor_story_reward_title_label.max_lines_visible = 2
	professor_story_reward_title_label.add_theme_font_override("font", FontExtraBold)
	professor_story_reward_title_label.add_theme_font_size_override("font_size", 10)
	professor_story_reward_title_label.add_theme_color_override("font_color", ComicUITheme.GREEN.darkened(0.30))
	reward_column.add_child(professor_story_reward_title_label)
	professor_story_reward_label = Label.new()
	professor_story_reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	professor_story_reward_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	professor_story_reward_label.max_lines_visible = 2
	professor_story_reward_label.add_theme_font_override("font", FontSemiBold)
	professor_story_reward_label.add_theme_font_size_override("font_size", 9)
	professor_story_reward_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	reward_column.add_child(professor_story_reward_label)
	professor_story_status_label = Label.new()
	professor_story_status_label.custom_minimum_size.y = 38
	professor_story_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	professor_story_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	professor_story_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	professor_story_status_label.max_lines_visible = 2
	professor_story_status_label.add_theme_font_override("font", FontSemiBold)
	professor_story_status_label.add_theme_font_size_override("font_size", 10)
	professor_story_status_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(professor_story_status_label)
	professor_story_action_button = _action_button("POKRAČOVAT", _on_professor_story_action_pressed)
	professor_story_action_button.custom_minimum_size.y = 60
	professor_story_action_button.set_meta("component", "professor_story_context_action_v1")
	professor_story_action_button.set_meta("touch_target_min_height", 60)
	professor_story_action_button.add_theme_font_override("font", FontExtraBold)
	professor_story_action_button.add_theme_font_size_override("font_size", 13)
	ComicUITheme.apply_button(professor_story_action_button, ComicUITheme.GREEN, ComicUITheme.CREAM, 14)
	column.add_child(professor_story_action_button)
	professor_story_presenter.bind(professor_story_chapter_title_label, professor_story_body_label, professor_story_summary_label, professor_story_status_label, professor_story_reward_label, professor_story_action_button, professor_story_cards, professor_story_reward_title_label)
	return overlay


func _build_professor_story_goal_card(goal_index: int) -> Control:
	var accents := [ComicUITheme.CYAN, ComicUITheme.ORANGE, ComicUITheme.PURPLE, ComicUITheme.GREEN, ComicUITheme.GOLD]
	var accent: Color = accents[goal_index % accents.size()]
	var panel := PanelContainer.new()
	panel.custom_minimum_size.y = 140
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff2bd"), accent, 3, 14, Color("#07131c", 0.24), 4, 7.0))
	panel.set_meta("component", "professor_story_goal_card_v1")
	panel.set_meta("goal_index", goal_index)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 3)
	panel.add_child(column)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	column.add_child(row)
	var title := Label.new()
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.max_lines_visible = 2
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 13)
	title.add_theme_color_override("font_color", accent.darkened(0.34))
	row.add_child(title)
	var value := Label.new()
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value.add_theme_font_override("font", FontExtraBold)
	value.add_theme_font_size_override("font_size", 10)
	value.add_theme_color_override("font_color", ComicUITheme.PURPLE)
	row.add_child(value)
	var body := Label.new()
	body.custom_minimum_size.y = 48
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.max_lines_visible = 3
	body.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	body.add_theme_font_override("font", FontSemiBold)
	body.add_theme_font_size_override("font_size", 9)
	body.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(body)
	var progress := ProgressBar.new()
	progress.custom_minimum_size.y = 17
	progress.min_value = 0.0
	progress.max_value = 100.0
	progress.show_percentage = false
	progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress.add_theme_stylebox_override("background", ComicUITheme.style_box(Color("#d5c897"), Color("#8b784c"), 1, 6, Color.TRANSPARENT, 0, 0.0))
	progress.add_theme_stylebox_override("fill", ComicUITheme.style_box(accent, accent.lightened(0.25), 1, 6, Color.TRANSPARENT, 0, 0.0))
	column.add_child(progress)
	professor_story_cards[goal_index] = {"panel": panel, "title": title, "body": body, "value": value, "progress": progress, "accent": accent}
	return panel


func _build_settings_modal() -> Control:
	var overlay := Control.new()
	overlay.name = "PlayerSettingsModal"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 190
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.visible = false
	overlay.set_meta("component", "fullscreen_player_settings_v1")
	overlay.set_meta("blocks_game_input", true)

	var dimmer := ColorRect.new()
	dimmer.color = Color("#071823", 0.88)
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(dimmer)

	var card := PanelContainer.new()
	card.set_anchor(SIDE_LEFT, 0.055)
	card.set_anchor(SIDE_TOP, 0.145)
	card.set_anchor(SIDE_RIGHT, 0.945)
	card.set_anchor(SIDE_BOTTOM, 0.835)
	card.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff8df"), ComicUITheme.PURPLE, 5, 23, Color("#050d16", 0.58), 9, 16.0))
	card.set_meta("component", "comic_audio_settings_card_v1")
	overlay.add_child(card)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	card.add_child(column)
	var banner := PanelContainer.new()
	banner.custom_minimum_size.y = 78
	banner.add_theme_stylebox_override("panel", ComicUITheme.style_box(ComicUITheme.PURPLE, ComicUITheme.GOLD, 4, 17, Color("#08131e", 0.35), 4, 8.0))
	var title := Label.new()
	title.text = "NASTAVENÍ HRÁČE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 25)
	title.add_theme_color_override("font_color", ComicUITheme.CREAM)
	title.add_theme_color_override("font_outline_color", ComicUITheme.INK)
	title.add_theme_constant_override("outline_size", 2)
	banner.add_child(title)
	column.add_child(banner)

	var intro := Label.new()
	intro.text = "Nastav atmosféru zahrady, herní efekty a jemnou mobilní odezvu. Vše se ukládá automaticky."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro.add_theme_font_override("font", FontSemiBold)
	intro.add_theme_font_size_override("font_size", 13)
	intro.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(intro)

	settings_music_button = _settings_toggle_button("HUDBA", _on_music_toggled)
	settings_sfx_button = _settings_toggle_button("HERNÍ ZVUKY", _on_sfx_toggled)
	settings_haptics_button = _settings_toggle_button("VIBRACE", _on_haptics_toggled)
	settings_motion_button = _settings_toggle_button("ANIMACE", _on_settings_motion_toggled)
	var toggle_grid := GridContainer.new()
	toggle_grid.columns = 2
	toggle_grid.add_theme_constant_override("h_separation", 8)
	toggle_grid.add_theme_constant_override("v_separation", 8)
	for button in [settings_music_button, settings_sfx_button, settings_haptics_button, settings_motion_button]:
		toggle_grid.add_child(button)
	column.add_child(toggle_grid)

	column.add_child(_settings_slider_title("HLASITOST HUDBY"))
	settings_music_slider = _settings_slider(_on_music_volume_changed)
	column.add_child(settings_music_slider)
	column.add_child(_settings_slider_title("HLASITOST EFEKTŮ"))
	settings_sfx_slider = _settings_slider(_on_sfx_volume_changed)
	column.add_child(settings_sfx_slider)

	settings_status_label = Label.new()
	settings_status_label.text = "Teplá zahradní hudba · čitelné akční zvuky · jemné vibrace"
	settings_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	settings_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_status_label.add_theme_font_override("font", FontSemiBold)
	settings_status_label.add_theme_font_size_override("font_size", 12)
	settings_status_label.add_theme_color_override("font_color", ComicUITheme.INK)
	column.add_child(settings_status_label)
	audio_settings_presenter.bind(
		settings_music_button,
		settings_sfx_button,
		settings_haptics_button,
		settings_motion_button,
		settings_music_slider,
		settings_sfx_slider,
		settings_status_label
	)
	var cosmetic_button := _action_button("VZHLED POKOJE", _open_cosmetic_modal)
	cosmetic_button.custom_minimum_size.y = 60
	cosmetic_button.add_theme_font_override("font", FontExtraBold)
	cosmetic_button.add_theme_font_size_override("font_size", 16)
	ComicUITheme.apply_button(cosmetic_button, ComicUITheme.CYAN, ComicUITheme.INK, 14)
	cosmetic_button.set_meta("touch_target_min_height", 60)
	cosmetic_button.set_meta("component", "phase14_cosmetic_showroom_launcher_v1")
	column.add_child(cosmetic_button)
	var backup_button := _action_button("ZÁLOHA POSTUPU", _open_local_backup)
	backup_button.custom_minimum_size.y = 60
	backup_button.add_theme_font_override("font", FontExtraBold)
	backup_button.add_theme_font_size_override("font_size", 16)
	ComicUITheme.apply_button(backup_button, ComicUITheme.BLUE, ComicUITheme.CREAM, 14)
	backup_button.set_meta("touch_target_min_height", 60)
	backup_button.set_meta("component", "phase47_local_backup_launcher_v1")
	column.add_child(backup_button)

	var close_button := Button.new()
	close_button.text = "HOTOVO"
	close_button.custom_minimum_size.y = 68
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.add_theme_font_override("font", FontExtraBold)
	close_button.add_theme_font_size_override("font_size", 18)
	ComicUITheme.apply_button(close_button, ComicUITheme.GREEN, ComicUITheme.CREAM, 15)
	close_button.set_meta("touch_target_min_height", 68)
	close_button.pressed.connect(_close_settings_modal)
	column.add_child(close_button)
	return overlay


func _build_local_backup_modal() -> Control:
	var overlay := Control.new()
	overlay.name = "LocalBackupModal"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 260
	overlay.visible = false
	overlay.set_meta("component", "phase47_portable_local_backup_v1")
	overlay.set_meta("blocks_game_input", true)
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color("#071823", 0.96)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(scrim)
	var card := PanelContainer.new()
	card.set_anchor(SIDE_LEFT, 0.055)
	card.set_anchor(SIDE_TOP, 0.075)
	card.set_anchor(SIDE_RIGHT, 0.945)
	card.set_anchor(SIDE_BOTTOM, 0.925)
	card.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff8df"), ComicUITheme.BLUE, 5, 22, Color("#000713", 0.68), 10, 15.0))
	overlay.add_child(card)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 12)
	card.add_child(column)
	var title := Label.new()
	title.text = "ZÁLOHA A POSTUP"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 23)
	title.add_theme_color_override("font_color", ComicUITheme.PURPLE)
	column.add_child(title)
	var intro := Label.new()
	intro.text = "Ulož si přenositelnou zálohu do telefonu nebo cloudu. Obnova vždy nejdřív ukáže náhled a nikdy nepřepíše postup bez potvrzení."
	intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.add_theme_font_override("font", FontSemiBold)
	intro.add_theme_font_size_override("font_size", 13)
	intro.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(intro)
	local_backup_info_label = Label.new()
	local_backup_info_label.custom_minimum_size.y = 46
	local_backup_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	local_backup_info_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	local_backup_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	local_backup_info_label.add_theme_font_override("font", FontExtraBold)
	local_backup_info_label.add_theme_font_size_override("font_size", 12)
	local_backup_info_label.add_theme_color_override("font_color", ComicUITheme.PURPLE)
	local_backup_info_label.set_meta("component", "phase56_version_save_status_v1")
	column.add_child(local_backup_info_label)
	local_backup_status_label = Label.new()
	local_backup_status_label.text = "Připraveno k vytvoření nebo obnovení zálohy."
	local_backup_status_label.custom_minimum_size.y = 82
	local_backup_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	local_backup_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	local_backup_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	local_backup_status_label.add_theme_font_override("font", FontExtraBold)
	local_backup_status_label.add_theme_font_size_override("font_size", 13)
	local_backup_status_label.add_theme_color_override("font_color", ComicUITheme.INK)
	column.add_child(local_backup_status_label)
	var export_button := _action_button("VYTVOŘIT ZÁLOHU", _choose_local_backup_export)
	export_button.custom_minimum_size.y = 64
	export_button.set_meta("touch_target_min_height", 64)
	ComicUITheme.apply_button(export_button, ComicUITheme.GREEN, ComicUITheme.CREAM, 14)
	column.add_child(export_button)
	var import_button := _action_button("VYBRAT ZÁLOHU K OBNOVĚ", _choose_local_backup_import)
	import_button.custom_minimum_size.y = 64
	import_button.set_meta("touch_target_min_height", 64)
	ComicUITheme.apply_button(import_button, ComicUITheme.CYAN, ComicUITheme.INK, 13)
	column.add_child(import_button)
	local_backup_confirm_button = _action_button("POTVRDIT OBNOVU", _confirm_local_backup_import)
	local_backup_confirm_button.custom_minimum_size.y = 64
	local_backup_confirm_button.set_meta("touch_target_min_height", 64)
	local_backup_confirm_button.visible = false
	ComicUITheme.apply_button(local_backup_confirm_button, ComicUITheme.ORANGE, ComicUITheme.CREAM, 13)
	column.add_child(local_backup_confirm_button)
	local_backup_restore_previous_button = _action_button("OBNOVIT PŘEDCHOZÍ HRU", _confirm_restore_previous_game)
	local_backup_restore_previous_button.custom_minimum_size.y = 64
	local_backup_restore_previous_button.set_meta("touch_target_min_height", 64)
	local_backup_restore_previous_button.set_meta("component", "phase58_restore_previous_game_v1")
	local_backup_restore_previous_button.visible = false
	ComicUITheme.apply_button(local_backup_restore_previous_button, ComicUITheme.BLUE, ComicUITheme.CREAM, 13)
	column.add_child(local_backup_restore_previous_button)
	local_backup_new_game_button = _action_button("ZAČÍT NOVOU HRU", _confirm_local_new_game)
	local_backup_new_game_button.custom_minimum_size.y = 64
	local_backup_new_game_button.set_meta("touch_target_min_height", 64)
	local_backup_new_game_button.set_meta("component", "phase56_safe_new_game_v1")
	ComicUITheme.apply_button(local_backup_new_game_button, ComicUITheme.ORANGE, ComicUITheme.CREAM, 13)
	column.add_child(local_backup_new_game_button)
	var close_button := _action_button("ZPĚT", _close_local_backup)
	close_button.custom_minimum_size.y = 64
	close_button.set_meta("touch_target_min_height", 64)
	ComicUITheme.apply_button(close_button, ComicUITheme.PURPLE, ComicUITheme.CREAM, 14)
	column.add_child(close_button)
	return overlay


func _build_seed_selector_modal() -> Control:
	var overlay := Control.new()
	overlay.name = "SeedSelectorModal"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 195
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.visible = false
	overlay.set_meta("component", "comic_mobile_seed_selector_v1")
	overlay.set_meta("blocks_game_input", true)

	var dimmer := ColorRect.new()
	dimmer.color = Color("#071823", 0.90)
	dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dimmer.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(dimmer)

	var card := PanelContainer.new()
	card.set_anchor(SIDE_LEFT, 0.045)
	card.set_anchor(SIDE_TOP, 0.07)
	card.set_anchor(SIDE_RIGHT, 0.955)
	card.set_anchor(SIDE_BOTTOM, 0.91)
	card.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff8df"), ComicUITheme.CYAN, 5, 23, Color("#050d16", 0.60), 10, 15.0))
	card.set_meta("component", "comic_seed_selector_card_v1")
	overlay.add_child(card)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 9)
	card.add_child(column)
	var banner := PanelContainer.new()
	banner.custom_minimum_size.y = 74
	banner.add_theme_stylebox_override("panel", ComicUITheme.style_box(ComicUITheme.BLUE, ComicUITheme.GOLD, 4, 16, Color("#08131e", 0.35), 4, 8.0))
	var title := Label.new()
	title.text = "CO BUDE RŮST?"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", ComicUITheme.CREAM)
	title.add_theme_color_override("font_outline_color", ComicUITheme.INK)
	title.add_theme_constant_override("outline_size", 2)
	banner.add_child(title)
	column.add_child(banner)

	var intro := Label.new()
	intro.text = "Vyber semínko pro tento květináč. Každá bylinka má vlastní tempo, péči i cenu sklizně."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro.add_theme_font_override("font", FontSemiBold)
	intro.add_theme_font_size_override("font_size", 12)
	intro.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(intro)

	seed_selector_scroll = ScrollContainer.new()
	seed_selector_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	seed_selector_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	seed_selector_scroll.set_meta("component", "comic_seed_species_scroll_v1")
	seed_selector_scroll.set_meta("mobile_scroll", true)
	column.add_child(seed_selector_scroll)
	var species_list := VBoxContainer.new()
	species_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	species_list.add_theme_constant_override("separation", 9)
	seed_selector_scroll.add_child(species_list)
	for species_id in session.get_available_species():
		var species_profile := session.get_plant_profile(species_id)
		var species_button := _seed_species_button(
			str(species_profile.get("ui_name", "Bylinka")).to_upper(),
			_seed_species_description(species_id),
			_species_preview_texture(species_id),
			_species_accent(species_id),
			species_id
		)
		species_list.add_child(species_button)
		seed_species_buttons[species_id] = species_button
	_configure_mobile_scroll(seed_selector_scroll, species_list, "seed_selector")
	seed_selector_basil_button = seed_species_buttons.get("basil_genovese") as Button
	seed_selector_mint_button = seed_species_buttons.get("mint_peppermint") as Button
	seed_selector_rosemary_button = seed_species_buttons.get("rosemary_officinalis") as Button
	seed_selector_oregano_button = seed_species_buttons.get("oregano_vulgare") as Button

	seed_selector_status_label = Label.new()
	seed_selector_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	seed_selector_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	seed_selector_status_label.add_theme_font_override("font", FontSemiBold)
	seed_selector_status_label.add_theme_font_size_override("font_size", 12)
	seed_selector_status_label.add_theme_color_override("font_color", ComicUITheme.INK)
	column.add_child(seed_selector_status_label)

	var close_button := Button.new()
	close_button.text = "ZPĚT KE KVĚTINÁČI"
	close_button.custom_minimum_size.y = 68
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.add_theme_font_override("font", FontExtraBold)
	ComicUITheme.apply_button(close_button, ComicUITheme.ORANGE, ComicUITheme.CREAM, 13)
	close_button.set_meta("touch_target_min_height", 68)
	close_button.pressed.connect(_close_seed_selector)
	column.add_child(close_button)
	seed_selector_presenter.bind(seed_species_buttons, seed_selector_status_label)
	return overlay


func _build_herbarium_modal() -> Control:
	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 210
	overlay.visible = false
	overlay.set_meta("component", "fullscreen_herbarium_modal_v1")
	overlay.set_meta("presentation", "blocking_fullscreen_overlay")
	overlay.set_meta("preserves_primary_navigation", true)
	overlay.set_meta("phase155_runtime_set", VisualDesignSystem.HERBARIUM_PHASE155_RUNTIME_SET_ID)
	overlay.set_meta("phase155_scene_profile", VisualDesignSystem.HERBARIUM_PHASE155_SCENE_PROFILE_ID)
	overlay.set_meta("phase155_dynamic_policy", "eleven_species_mastery_rewards_descriptions_progress_scroll_and_handover_preserved_v1")
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color("#130a04")
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(scrim)
	var backdrop_profile := VisualDesignSystem.asset_profile("herbarium_phase155_background")
	herbarium_backdrop = TextureRect.new()
	herbarium_backdrop.texture = load(str(backdrop_profile.get("texture", VisualDesignSystem.HERBARIUM_PHASE155_BACKDROP_ASSET))) as Texture2D
	herbarium_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	herbarium_backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	herbarium_backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	herbarium_backdrop.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	herbarium_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	herbarium_backdrop.set_meta("component", "painted_herbarium_clean_backdrop_phase155_v1")
	herbarium_backdrop.set_meta("phase155_runtime_set", VisualDesignSystem.HERBARIUM_PHASE155_RUNTIME_SET_ID)
	overlay.add_child(herbarium_backdrop)
	var title := Label.new()
	title.text = "BYLINKOVÝ\nHERBÁŘ"
	_apply_hud_rect(title, Rect2(0.18, 0.035, 0.62, 0.105))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 25)
	title.add_theme_color_override("font_color", Color("#482514"))
	title.add_theme_color_override("font_outline_color", Color("#fff0bd", 0.72))
	title.add_theme_constant_override("outline_size", 2)
	title.set_meta("component", "painted_herbarium_dynamic_title_phase155_v1")
	overlay.add_child(title)
	var top_close := _action_button("", _close_herbarium)
	_apply_hud_rect(top_close, Rect2(0.82, 0.022, 0.145, 0.075))
	top_close.custom_minimum_size = Vector2(58, 58)
	top_close.set_meta("touch_target_min_height", 58)
	top_close.set_meta("component", "painted_herbarium_close_hitbox_phase155_v1")
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		top_close.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	overlay.add_child(top_close)
	herbarium_summary_label = Label.new()
	_apply_hud_rect(herbarium_summary_label, Rect2(0.13, 0.145, 0.74, 0.076))
	herbarium_summary_label.custom_minimum_size.y = 52
	herbarium_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	herbarium_summary_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	herbarium_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	herbarium_summary_label.max_lines_visible = 2
	herbarium_summary_label.add_theme_font_override("font", FontExtraBold)
	herbarium_summary_label.add_theme_font_size_override("font_size", 1)
	herbarium_summary_label.add_theme_color_override("font_color", Color.TRANSPARENT)
	herbarium_summary_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	herbarium_summary_label.set_meta("component", "herbarium_summary_compatibility_data_v1")
	overlay.add_child(herbarium_summary_label)
	herbarium_collection_summary_label = _phase155_herbarium_summary_label()
	_apply_hud_rect(herbarium_collection_summary_label, Rect2(0.155, 0.146, 0.31, 0.075))
	herbarium_collection_summary_label.set_meta("component", "painted_herbarium_collection_summary_phase155_v1")
	overlay.add_child(herbarium_collection_summary_label)
	herbarium_mastery_summary_label = _phase155_herbarium_summary_label()
	_apply_hud_rect(herbarium_mastery_summary_label, Rect2(0.535, 0.146, 0.31, 0.075))
	herbarium_mastery_summary_label.set_meta("component", "painted_herbarium_mastery_summary_phase155_v1")
	overlay.add_child(herbarium_mastery_summary_label)
	var replay_handover_button := _action_button("PŘEHRÁT PŘEDÁNÍ ZAHRADY", _open_garden_handover_replay)
	_apply_hud_rect(replay_handover_button, Rect2(0.16, 0.208, 0.68, 0.075))
	replay_handover_button.custom_minimum_size.y = 60
	replay_handover_button.set_meta("component", "herbarium_handover_replay_v1")
	replay_handover_button.set_meta("phase155_component", "painted_handover_recess_action_v1")
	replay_handover_button.set_meta("touch_target_min_height", 60)
	replay_handover_button.add_theme_font_override("font", FontExtraBold)
	replay_handover_button.add_theme_font_size_override("font_size", 11)
	replay_handover_button.add_theme_color_override("font_color", Color("#fff2c4"))
	replay_handover_button.add_theme_color_override("font_outline_color", Color("#321508"))
	replay_handover_button.add_theme_constant_override("outline_size", 3)
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		replay_handover_button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	herbarium_replay_from_garden_handover_button = replay_handover_button
	overlay.add_child(replay_handover_button)
	herbarium_scroll = ScrollContainer.new()
	_apply_hud_rect(herbarium_scroll, Rect2(0.115, 0.285, 0.785, 0.545))
	herbarium_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	herbarium_scroll.set_meta("mobile_scroll", true)
	herbarium_scroll.set_meta("component", "painted_herbarium_species_scroll_phase155_v1")
	herbarium_scroll.set_meta("phase155_runtime_set", VisualDesignSystem.HERBARIUM_PHASE155_RUNTIME_SET_ID)
	herbarium_scroll.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	herbarium_scroll.add_theme_stylebox_override("scroll", ComicUITheme.style_box(Color("#6f431e", 0.48), Color("#3a1d0b", 0.72), 1, 6))
	herbarium_scroll.add_theme_stylebox_override("grabber", ComicUITheme.style_box(Color("#5d8b2f"), Color("#2f4d19"), 1, 6))
	overlay.add_child(herbarium_scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 12)
	herbarium_scroll.add_child(list)
	for species_id in session.get_collection_species_ids():
		list.add_child(_build_herbarium_card(species_id))
	_configure_mobile_scroll(herbarium_scroll, list, "herbarium")
	herbarium_status_label = Label.new()
	_apply_hud_rect(herbarium_status_label, Rect2(0.13, 0.835, 0.74, 0.052))
	herbarium_status_label.custom_minimum_size.y = 40
	herbarium_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	herbarium_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	herbarium_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	herbarium_status_label.add_theme_font_override("font", FontSemiBold)
	herbarium_status_label.add_theme_font_size_override("font_size", 10)
	herbarium_status_label.add_theme_color_override("font_color", Color("#4a2916"))
	herbarium_status_label.add_theme_color_override("font_outline_color", Color("#fff0bd", 0.62))
	herbarium_status_label.add_theme_constant_override("outline_size", 2)
	herbarium_status_label.set_meta("component", "painted_herbarium_dynamic_status_phase155_v1")
	overlay.add_child(herbarium_status_label)
	var close_button := _action_button("ZAVŘÍT HERBÁŘ", _close_herbarium)
	_apply_hud_rect(close_button, Rect2(0.175, 0.892, 0.65, 0.085))
	close_button.custom_minimum_size.y = 68
	close_button.set_meta("touch_target_min_height", 68)
	close_button.set_meta("component", "painted_herbarium_bottom_close_phase155_v1")
	close_button.add_theme_font_override("font", FontExtraBold)
	close_button.add_theme_font_size_override("font_size", 16)
	close_button.add_theme_color_override("font_color", Color("#fff2c4"))
	close_button.add_theme_color_override("font_outline_color", Color("#20330f"))
	close_button.add_theme_constant_override("outline_size", 3)
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		close_button.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	overlay.add_child(close_button)
	herbarium_presenter.bind(herbarium_summary_label, herbarium_status_label, herbarium_cards, herbarium_collection_summary_label, herbarium_mastery_summary_label)
	return overlay


func _phase155_herbarium_summary_label() -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.max_lines_visible = 2
	label.add_theme_font_override("font", FontExtraBold)
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color("#4a2916"))
	label.add_theme_color_override("font_outline_color", Color("#fff4c8", 0.76))
	label.add_theme_constant_override("outline_size", 2)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _build_daily_challenge_modal() -> Control:
	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 220
	overlay.visible = false
	overlay.set_meta("component", "fullscreen_daily_challenge_modal_v1")
	overlay.set_meta("blocks_game_input", true)
	overlay.set_meta("covers_full_viewport", true)
	overlay.set_meta("phase161_runtime_set", VisualDesignSystem.DAILY_CHALLENGE_PHASE161_RUNTIME_SET_ID)
	overlay.set_meta("phase161_scene_profile", VisualDesignSystem.DAILY_CHALLENGE_PHASE161_SCENE_PROFILE_ID)
	overlay.set_meta("phase161_layer_policy", "clean_painted_plate_dynamic_text_buttons_and_context_effects_v1")
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color("#061923", 0.88)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	scrim.set_meta("component", "phase161_live_game_scrim_v1")
	overlay.add_child(scrim)
	daily_challenge_backdrop = TextureRect.new()
	_apply_hud_rect(daily_challenge_backdrop, Rect2(0.0, 0.035, 1.0, 0.895))
	daily_challenge_backdrop.texture = Phase161DailyChallengeBackdrop
	daily_challenge_backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	daily_challenge_backdrop.stretch_mode = TextureRect.STRETCH_SCALE
	daily_challenge_backdrop.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	daily_challenge_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	daily_challenge_backdrop.set_meta("component", "painted_daily_challenge_clean_backdrop_phase161_v1")
	daily_challenge_backdrop.set_meta("source_pixel_policy", "neutral_clean_plate_no_baked_text_values_or_hud_v1")
	overlay.add_child(daily_challenge_backdrop)

	var banner_title := Label.new()
	banner_title.text = "DENNÍ VÝZVA"
	_apply_hud_rect(banner_title, Rect2(0.105, 0.091, 0.79, 0.068))
	banner_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner_title.add_theme_font_override("font", FontExtraBold)
	banner_title.add_theme_font_size_override("font_size", 23)
	banner_title.add_theme_color_override("font_color", ComicUITheme.CREAM)
	banner_title.add_theme_color_override("font_outline_color", ComicUITheme.INK)
	banner_title.add_theme_constant_override("outline_size", 3)
	banner_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	banner_title.set_meta("component", "painted_daily_challenge_dynamic_header_phase161_v1")
	overlay.add_child(banner_title)

	daily_challenge_weather_label = Label.new()
	_apply_hud_rect(daily_challenge_weather_label, Rect2(0.105, 0.166, 0.79, 0.043))
	daily_challenge_weather_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	daily_challenge_weather_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	daily_challenge_weather_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	daily_challenge_weather_label.max_lines_visible = 2
	daily_challenge_weather_label.add_theme_font_override("font", FontExtraBold)
	daily_challenge_weather_label.add_theme_font_size_override("font_size", 12)
	daily_challenge_weather_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	daily_challenge_weather_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	daily_challenge_weather_label.set_meta("component", "painted_daily_challenge_dynamic_weather_phase161_v1")
	overlay.add_child(daily_challenge_weather_label)

	daily_challenge_title_label = Label.new()
	_apply_hud_rect(daily_challenge_title_label, Rect2(0.11, 0.218, 0.78, 0.041))
	daily_challenge_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	daily_challenge_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	daily_challenge_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	daily_challenge_title_label.max_lines_visible = 2
	daily_challenge_title_label.add_theme_font_override("font", FontExtraBold)
	daily_challenge_title_label.add_theme_font_size_override("font_size", 18)
	daily_challenge_title_label.add_theme_color_override("font_color", ComicUITheme.PURPLE)
	daily_challenge_title_label.add_theme_color_override("font_outline_color", Color("#fff4c8", 0.76))
	daily_challenge_title_label.add_theme_constant_override("outline_size", 2)
	daily_challenge_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(daily_challenge_title_label)

	daily_challenge_body_label = Label.new()
	_apply_hud_rect(daily_challenge_body_label, Rect2(0.105, 0.258, 0.79, 0.058))
	daily_challenge_body_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	daily_challenge_body_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	daily_challenge_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	daily_challenge_body_label.max_lines_visible = 4
	daily_challenge_body_label.add_theme_font_override("font", FontSemiBold)
	daily_challenge_body_label.add_theme_font_size_override("font_size", 10)
	daily_challenge_body_label.add_theme_color_override("font_color", ComicUITheme.INK)
	daily_challenge_body_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(daily_challenge_body_label)

	daily_challenge_status_label = Label.new()
	_apply_hud_rect(daily_challenge_status_label, Rect2(0.14, 0.300, 0.72, 0.035))
	daily_challenge_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	daily_challenge_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	daily_challenge_status_label.add_theme_font_override("font", FontExtraBold)
	daily_challenge_status_label.add_theme_font_size_override("font_size", 12)
	daily_challenge_status_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	daily_challenge_status_label.add_theme_color_override("font_outline_color", Color("#fff4c8", 0.94))
	daily_challenge_status_label.add_theme_constant_override("outline_size", 3)
	daily_challenge_status_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(daily_challenge_status_label)

	daily_challenge_context_visual = DailyChallengeVisualScene.new()
	_apply_hud_rect(daily_challenge_context_visual, Rect2(0.105, 0.345, 0.79, 0.225))
	daily_challenge_context_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	daily_challenge_context_visual.set_meta("phase161_layer_role", "dynamic_challenge_and_weather_context_only_v1")
	overlay.add_child(daily_challenge_context_visual)

	daily_challenge_action_state_overlay = _phase161_daily_state_overlay(Rect2(0.097, 0.579, 0.806, 0.066), Color("#667176", 0.54), "action_disabled")
	overlay.add_child(daily_challenge_action_state_overlay)
	daily_challenge_action_button = _action_button("OTEVŘÍT ÚKOL", _on_daily_challenge_action_requested)
	_apply_hud_rect(daily_challenge_action_button, Rect2(0.075, 0.575, 0.85, 0.073))
	daily_challenge_action_button.custom_minimum_size.y = 64
	daily_challenge_action_button.set_meta("touch_target_min_height", 64)
	_phase161_prepare_painted_button(daily_challenge_action_button, 13, ComicUITheme.CREAM, "action")
	overlay.add_child(daily_challenge_action_button)

	daily_challenge_claim_state_overlay = _phase161_daily_state_overlay(Rect2(0.097, 0.648, 0.806, 0.067), Color("#63c73f", 0.48), "claim_ready")
	overlay.add_child(daily_challenge_claim_state_overlay)
	daily_challenge_claim_button = _action_button("VYZVEDNOUT ODMĚNU\n12 MINCÍ · 10 XP · 1 BALÍČEK", _on_daily_reward_claimed)
	_apply_hud_rect(daily_challenge_claim_button, Rect2(0.075, 0.642, 0.85, 0.079))
	daily_challenge_claim_button.custom_minimum_size.y = 68
	daily_challenge_claim_button.set_meta("touch_target_min_height", 68)
	_phase161_prepare_painted_button(daily_challenge_claim_button, 10, ComicUITheme.CREAM, "claim")
	overlay.add_child(daily_challenge_claim_button)

	botanical_pack_launcher_button = _action_button("BOTANICKÉ BALÍČKY", _open_botanical_pack)
	_apply_hud_rect(botanical_pack_launcher_button, Rect2(0.075, 0.711, 0.85, 0.074))
	botanical_pack_launcher_button.custom_minimum_size.y = 64
	botanical_pack_launcher_button.set_meta("component", "botanical_pack_daily_launcher_v1")
	botanical_pack_launcher_button.set_meta("touch_target_min_height", 64)
	_phase161_prepare_painted_button(botanical_pack_launcher_button, 12, ComicUITheme.CREAM, "botanical_packs")
	overlay.add_child(botanical_pack_launcher_button)

	daily_challenge_warning_label = Label.new()
	_apply_hud_rect(daily_challenge_warning_label, Rect2(0.105, 0.786, 0.79, 0.054))
	daily_challenge_warning_label.text = "Denní úkol se mění jednou za skutečný den.\nHotovou odměnu proto vyzvedni včas."
	daily_challenge_warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	daily_challenge_warning_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	daily_challenge_warning_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	daily_challenge_warning_label.max_lines_visible = 2
	daily_challenge_warning_label.add_theme_font_override("font", FontSemiBold)
	daily_challenge_warning_label.add_theme_font_size_override("font_size", 9)
	daily_challenge_warning_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	daily_challenge_warning_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	daily_challenge_warning_label.set_meta("component", "painted_daily_challenge_warning_phase161_v1")
	overlay.add_child(daily_challenge_warning_label)

	daily_challenge_close_button = _action_button("ZPĚT DO ZAHRADY", _close_daily_challenge)
	_apply_hud_rect(daily_challenge_close_button, Rect2(0.075, 0.842, 0.85, 0.077))
	daily_challenge_close_button.custom_minimum_size.y = 64
	daily_challenge_close_button.set_meta("touch_target_min_height", 64)
	_phase161_prepare_painted_button(daily_challenge_close_button, 13, ComicUITheme.CREAM, "close")
	overlay.add_child(daily_challenge_close_button)
	daily_challenge_presenter.bind(daily_challenge_weather_label, daily_challenge_title_label, daily_challenge_body_label, daily_challenge_status_label, daily_challenge_action_button, daily_challenge_claim_button)
	return overlay


func _phase161_daily_state_overlay(rect: Rect2, color: Color, role: String) -> PanelContainer:
	var panel := PanelContainer.new()
	_apply_hud_rect(panel, rect)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.visible = false
	panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(color, Color(color, 0.0), 0, 12, Color.TRANSPARENT, 0, 0.0))
	panel.set_meta("component", "painted_daily_challenge_state_tint_phase161_v1")
	panel.set_meta("state_role", role)
	return panel


func _phase161_prepare_painted_button(button: Button, font_size: int, font_color: Color, role: String) -> void:
	button.add_theme_font_override("font", FontExtraBold)
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", font_color)
	button.add_theme_color_override("font_hover_color", font_color)
	button.add_theme_color_override("font_pressed_color", font_color)
	button.add_theme_color_override("font_focus_color", font_color)
	button.add_theme_color_override("font_disabled_color", Color("#fff2c4", 0.88))
	button.add_theme_color_override("font_outline_color", ComicUITheme.INK)
	button.add_theme_constant_override("outline_size", 2)
	button.set_meta("phase161_uses_baked_painted_surface", true)
	button.set_meta("phase161_button_role", role)
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		button.add_theme_stylebox_override(state, StyleBoxEmpty.new())


func _build_botanical_pack_modal() -> Control:
	var overlay := Control.new()
	overlay.name = "BotanicalPackModal"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 230
	overlay.visible = false
	overlay.set_meta("component", "fullscreen_botanical_pack_modal_v1")
	overlay.set_meta("blocks_game_input", true)
	overlay.set_meta("covers_full_viewport", true)
	overlay.set_meta("no_real_money_purchase", true)
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color("#071423", 0.95)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(scrim)
	var card := PanelContainer.new()
	card.set_anchor(SIDE_LEFT, 0.045)
	card.set_anchor(SIDE_TOP, 0.07)
	card.set_anchor(SIDE_RIGHT, 0.955)
	card.set_anchor(SIDE_BOTTOM, 0.91)
	card.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff6d7"), ComicUITheme.PURPLE, 5, 22, Color("#000713", 0.66), 10, 15.0))
	overlay.add_child(card)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 9)
	card.add_child(column)
	var banner := PanelContainer.new()
	banner.custom_minimum_size.y = 76
	banner.add_theme_stylebox_override("panel", ComicUITheme.style_box(ComicUITheme.PURPLE, ComicUITheme.GOLD, 4, 17, Color("#07131c", 0.34), 4, 8.0))
	column.add_child(banner)
	var title := Label.new()
	title.text = "BOTANICKÁ ZÁSILKA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 23)
	title.add_theme_color_override("font_color", ComicUITheme.CREAM)
	title.add_theme_color_override("font_outline_color", ComicUITheme.INK)
	title.add_theme_constant_override("outline_size", 3)
	banner.add_child(title)
	botanical_pack_count_label = Label.new()
	botanical_pack_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	botanical_pack_count_label.add_theme_font_override("font", FontExtraBold)
	botanical_pack_count_label.add_theme_font_size_override("font_size", 15)
	botanical_pack_count_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(botanical_pack_count_label)
	var reward_panel := PanelContainer.new()
	reward_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	reward_panel.custom_minimum_size.y = 238
	reward_panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff0b5"), ComicUITheme.GOLD, 4, 18, Color("#07131c", 0.22), 4, 10.0))
	reward_panel.set_meta("component", "sealed_botanical_pack_reward_v1")
	column.add_child(reward_panel)
	var reward_column := VBoxContainer.new()
	reward_column.alignment = BoxContainer.ALIGNMENT_CENTER
	reward_column.add_theme_constant_override("separation", 5)
	reward_panel.add_child(reward_column)
	botanical_pack_reward_icon = TextureRect.new()
	botanical_pack_reward_icon.texture = NavPlantIcon
	botanical_pack_reward_icon.custom_minimum_size = Vector2(0, 136)
	botanical_pack_reward_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	botanical_pack_reward_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	botanical_pack_reward_icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	botanical_pack_reward_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	reward_column.add_child(botanical_pack_reward_icon)
	botanical_pack_reward_name_label = Label.new()
	botanical_pack_reward_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	botanical_pack_reward_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	botanical_pack_reward_name_label.add_theme_font_override("font", FontExtraBold)
	botanical_pack_reward_name_label.add_theme_font_size_override("font_size", 18)
	botanical_pack_reward_name_label.add_theme_color_override("font_color", ComicUITheme.INK)
	reward_column.add_child(botanical_pack_reward_name_label)
	botanical_pack_reward_rarity_label = Label.new()
	botanical_pack_reward_rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	botanical_pack_reward_rarity_label.add_theme_font_override("font", FontExtraBold)
	botanical_pack_reward_rarity_label.add_theme_font_size_override("font_size", 12)
	botanical_pack_reward_rarity_label.add_theme_color_override("font_color", ComicUITheme.PURPLE)
	reward_column.add_child(botanical_pack_reward_rarity_label)
	botanical_pack_odds_label = Label.new()
	botanical_pack_odds_label.custom_minimum_size.y = 50
	botanical_pack_odds_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	botanical_pack_odds_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	botanical_pack_odds_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	botanical_pack_odds_label.add_theme_font_override("font", FontSemiBold)
	botanical_pack_odds_label.add_theme_font_size_override("font_size", 11)
	botanical_pack_odds_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(botanical_pack_odds_label)
	botanical_pack_pity_label = Label.new()
	botanical_pack_pity_label.custom_minimum_size.y = 36
	botanical_pack_pity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	botanical_pack_pity_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	botanical_pack_pity_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	botanical_pack_pity_label.add_theme_font_override("font", FontExtraBold)
	botanical_pack_pity_label.add_theme_font_size_override("font_size", 11)
	botanical_pack_pity_label.add_theme_color_override("font_color", ComicUITheme.ORANGE)
	column.add_child(botanical_pack_pity_label)
	botanical_pack_status_label = Label.new()
	botanical_pack_status_label.custom_minimum_size.y = 48
	botanical_pack_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	botanical_pack_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	botanical_pack_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	botanical_pack_status_label.add_theme_font_override("font", FontSemiBold)
	botanical_pack_status_label.add_theme_font_size_override("font_size", 11)
	botanical_pack_status_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(botanical_pack_status_label)
	botanical_pack_open_button = _action_button("OTEVŘÍT BALÍČEK", _on_botanical_pack_opened)
	botanical_pack_open_button.custom_minimum_size.y = 72
	botanical_pack_open_button.add_theme_font_override("font", FontExtraBold)
	botanical_pack_open_button.add_theme_font_size_override("font_size", 15)
	botanical_pack_open_button.set_meta("component", "botanical_pack_open_button_v1")
	botanical_pack_open_button.set_meta("touch_target_min_height", 72)
	column.add_child(botanical_pack_open_button)
	var close_button := _action_button("ZPĚT K DENNÍ VÝZVĚ", _close_botanical_pack_to_daily)
	close_button.custom_minimum_size.y = 64
	close_button.add_theme_font_override("font", FontExtraBold)
	close_button.add_theme_font_size_override("font_size", 13)
	close_button.set_meta("touch_target_min_height", 64)
	ComicUITheme.apply_button(close_button, ComicUITheme.BLUE, ComicUITheme.CREAM, 13)
	column.add_child(close_button)
	botanical_pack_presenter.bind(botanical_pack_count_label, botanical_pack_odds_label, botanical_pack_pity_label, botanical_pack_status_label, botanical_pack_reward_name_label, botanical_pack_reward_rarity_label, botanical_pack_open_button)
	return overlay


func _build_level_progression_modal() -> Control:
	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 225
	overlay.visible = false
	overlay.set_meta("component", "fullscreen_level_progression_modal_v1")
	overlay.set_meta("blocks_game_input", true)
	overlay.set_meta("covers_full_viewport", true)
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color("#071423", 0.95)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(scrim)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 13)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 13)
	margin.add_theme_constant_override("margin_bottom", 16)
	overlay.add_child(margin)
	var shell := PanelContainer.new()
	shell.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff8dc"), ComicUITheme.GOLD, 5, 22, Color("#000713", 0.66), 10, 12.0))
	shell.set_meta("component", "comic_level_progression_shell_v1")
	margin.add_child(shell)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	shell.add_child(column)
	var banner := PanelContainer.new()
	banner.custom_minimum_size.y = 70
	banner.add_theme_stylebox_override("panel", ComicUITheme.style_box(ComicUITheme.PURPLE, ComicUITheme.GOLD, 4, 17, Color("#07131c", 0.36), 4, 8.0))
	column.add_child(banner)
	var banner_row := HBoxContainer.new()
	banner_row.add_theme_constant_override("separation", 7)
	banner.add_child(banner_row)
	var heading := VBoxContainer.new()
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_theme_constant_override("separation", -2)
	banner_row.add_child(heading)
	var title := Label.new()
	title.text = "CESTA PĚSTITELE"
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 21)
	title.add_theme_color_override("font_color", ComicUITheme.CREAM)
	title.add_theme_color_override("font_outline_color", ComicUITheme.INK)
	title.add_theme_constant_override("outline_size", 3)
	heading.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Úrovně propojují stojan, vybavení a zásoby."
	subtitle.add_theme_font_override("font", FontSemiBold)
	subtitle.add_theme_font_size_override("font_size", 10)
	subtitle.add_theme_color_override("font_color", Color("#fff2b5"))
	heading.add_child(subtitle)
	var top_close := _action_button("×", _close_level_progression)
	top_close.custom_minimum_size = Vector2(56, 52)
	top_close.size_flags_horizontal = Control.SIZE_SHRINK_END
	top_close.set_meta("touch_target_min_height", 52)
	top_close.add_theme_font_override("font", FontExtraBold)
	top_close.add_theme_font_size_override("font_size", 25)
	ComicUITheme.apply_button(top_close, ComicUITheme.ORANGE, ComicUITheme.CREAM, 13)
	banner_row.add_child(top_close)
	level_progression_summary_label = Label.new()
	level_progression_summary_label.custom_minimum_size.y = 30
	level_progression_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_progression_summary_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	level_progression_summary_label.add_theme_font_override("font", FontExtraBold)
	level_progression_summary_label.add_theme_font_size_override("font_size", 12)
	level_progression_summary_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(level_progression_summary_label)
	level_progression_scroll = ScrollContainer.new()
	level_progression_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	level_progression_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	level_progression_scroll.set_meta("mobile_scroll", true)
	column.add_child(level_progression_scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 9)
	level_progression_scroll.add_child(list)
	for reward_level in range(1, GameSession.LEVEL_REWARDS.size() + 1):
		list.add_child(_build_level_progression_card(reward_level))
	_configure_mobile_scroll(level_progression_scroll, list, "level_progression")
	level_progression_status_label = Label.new()
	level_progression_status_label.custom_minimum_size.y = 38
	level_progression_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_progression_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	level_progression_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	level_progression_status_label.add_theme_font_override("font", FontSemiBold)
	level_progression_status_label.add_theme_font_size_override("font_size", 10)
	level_progression_status_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(level_progression_status_label)
	var bottom_actions := HBoxContainer.new()
	bottom_actions.add_theme_constant_override("separation", 8)
	column.add_child(bottom_actions)
	grower_journal_launcher = _action_button("PĚSTITELSKÝ\nDENÍK", _open_grower_journal)
	grower_journal_launcher.custom_minimum_size.y = 64
	grower_journal_launcher.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grower_journal_launcher.set_meta("touch_target_min_height", 64)
	grower_journal_launcher.set_meta("component", "phase49_grower_journal_launcher_v1")
	grower_journal_launcher.add_theme_font_override("font", FontExtraBold)
	grower_journal_launcher.add_theme_font_size_override("font_size", 12)
	ComicUITheme.apply_button(grower_journal_launcher, ComicUITheme.PURPLE, ComicUITheme.CREAM, 13)
	bottom_actions.add_child(grower_journal_launcher)
	var close_button := _action_button("ZPĚT DO\nZAHRADY", _close_level_progression)
	close_button.custom_minimum_size.y = 64
	close_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	close_button.set_meta("touch_target_min_height", 64)
	close_button.add_theme_font_override("font", FontExtraBold)
	close_button.add_theme_font_size_override("font_size", 12)
	ComicUITheme.apply_button(close_button, ComicUITheme.GREEN, ComicUITheme.CREAM, 13)
	bottom_actions.add_child(close_button)
	level_progression_presenter.bind(level_progression_summary_label, level_progression_status_label, level_progression_cards)
	return overlay


func _build_level_progression_card(reward_level: int) -> Control:
	var accents := [ComicUITheme.GREEN, ComicUITheme.CYAN, ComicUITheme.ORANGE, ComicUITheme.PURPLE, ComicUITheme.GOLD]
	var accent: Color = accents[(reward_level - 1) % accents.size()]
	var panel := PanelContainer.new()
	panel.custom_minimum_size.y = 146
	panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff2bd"), accent, 4, 15, Color("#07131c", 0.30), 5, 9.0))
	panel.set_meta("component", "level_progression_reward_card_v1")
	panel.set_meta("reward_level", reward_level)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	panel.add_child(column)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	column.add_child(top)
	var title := Label.new()
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 17)
	title.add_theme_color_override("font_color", accent.darkened(0.30))
	top.add_child(title)
	var reward_label := Label.new()
	reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	reward_label.add_theme_font_override("font", FontExtraBold)
	reward_label.add_theme_font_size_override("font_size", 11)
	reward_label.add_theme_color_override("font_color", ComicUITheme.PURPLE)
	top.add_child(reward_label)
	var unlock_label := Label.new()
	unlock_label.custom_minimum_size.y = 30
	unlock_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	unlock_label.add_theme_font_override("font", FontSemiBold)
	unlock_label.add_theme_font_size_override("font_size", 10)
	unlock_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(unlock_label)
	var claim := _action_button("VYZVEDNOUT", _on_level_reward_claimed.bind(reward_level))
	claim.custom_minimum_size.y = 54
	claim.set_meta("touch_target_min_height", 54)
	claim.add_theme_font_override("font", FontExtraBold)
	claim.add_theme_font_size_override("font_size", 13)
	ComicUITheme.apply_button(claim, ComicUITheme.GREEN, ComicUITheme.INK, 11)
	column.add_child(claim)
	level_progression_cards[reward_level] = {"panel": panel, "title": title, "reward": reward_label, "unlock": unlock_label, "claim": claim, "accent": accent}
	return panel


func _build_grower_journal_modal() -> Control:
	var overlay := Control.new()
	overlay.name = "GrowerJournalModal"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 227
	overlay.visible = false
	overlay.set_meta("component", "fullscreen_grower_journal_modal_v1")
	overlay.set_meta("blocks_game_input", true)
	overlay.set_meta("covers_full_viewport", true)
	overlay.set_meta("responsive_test_viewports", [Vector2i(432, 960), Vector2i(360, 800)])
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color("#061826", 0.96)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(scrim)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 13)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 13)
	margin.add_theme_constant_override("margin_bottom", 16)
	overlay.add_child(margin)
	var shell := PanelContainer.new()
	shell.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff8dc"), ComicUITheme.GREEN, 5, 22, Color("#000713", 0.66), 10, 12.0))
	shell.set_meta("component", "comic_grower_journal_shell_v1")
	margin.add_child(shell)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	shell.add_child(column)
	var banner := PanelContainer.new()
	banner.custom_minimum_size.y = 70
	banner.add_theme_stylebox_override("panel", ComicUITheme.style_box(ComicUITheme.GREEN.darkened(0.18), ComicUITheme.GOLD, 4, 17, Color("#07131c", 0.36), 4, 8.0))
	column.add_child(banner)
	var banner_row := HBoxContainer.new()
	banner_row.add_theme_constant_override("separation", 7)
	banner.add_child(banner_row)
	var heading := VBoxContainer.new()
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_theme_constant_override("separation", -2)
	banner_row.add_child(heading)
	var title := Label.new()
	title.text = "PĚSTITELSKÝ DENÍK"
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", ComicUITheme.CREAM)
	title.add_theme_color_override("font_outline_color", ComicUITheme.INK)
	title.add_theme_constant_override("outline_size", 3)
	heading.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Skutečný postup napříč celou zahradou."
	subtitle.add_theme_font_override("font", FontSemiBold)
	subtitle.add_theme_font_size_override("font_size", 9)
	subtitle.add_theme_color_override("font_color", Color("#fff2b5"))
	heading.add_child(subtitle)
	var top_close := _action_button("×", _close_grower_journal)
	top_close.custom_minimum_size = Vector2(56, 52)
	top_close.size_flags_horizontal = Control.SIZE_SHRINK_END
	top_close.set_meta("touch_target_min_height", 52)
	top_close.add_theme_font_override("font", FontExtraBold)
	top_close.add_theme_font_size_override("font_size", 25)
	ComicUITheme.apply_button(top_close, ComicUITheme.ORANGE, ComicUITheme.CREAM, 13)
	banner_row.add_child(top_close)
	var summary_panel := PanelContainer.new()
	summary_panel.custom_minimum_size.y = 82
	summary_panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff1b8"), ComicUITheme.GOLD, 3, 14, Color("#07131c", 0.20), 3, 7.0))
	column.add_child(summary_panel)
	grower_journal_summary_label = Label.new()
	grower_journal_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	grower_journal_summary_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	grower_journal_summary_label.add_theme_font_override("font", FontExtraBold)
	grower_journal_summary_label.add_theme_font_size_override("font_size", 11)
	grower_journal_summary_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	summary_panel.add_child(grower_journal_summary_label)
	var goal_panel := PanelContainer.new()
	goal_panel.custom_minimum_size.y = 88
	goal_panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#dff8d1"), ComicUITheme.CYAN, 3, 14, Color("#07131c", 0.18), 3, 7.0))
	column.add_child(goal_panel)
	grower_journal_next_goal_label = Label.new()
	grower_journal_next_goal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	grower_journal_next_goal_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	grower_journal_next_goal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	grower_journal_next_goal_label.add_theme_font_override("font", FontSemiBold)
	grower_journal_next_goal_label.add_theme_font_size_override("font_size", 10)
	grower_journal_next_goal_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	goal_panel.add_child(grower_journal_next_goal_label)
	grower_journal_badge_count_label = Label.new()
	grower_journal_badge_count_label.custom_minimum_size.y = 24
	grower_journal_badge_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	grower_journal_badge_count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	grower_journal_badge_count_label.add_theme_font_override("font", FontExtraBold)
	grower_journal_badge_count_label.add_theme_font_size_override("font_size", 12)
	grower_journal_badge_count_label.add_theme_color_override("font_color", ComicUITheme.PURPLE)
	column.add_child(grower_journal_badge_count_label)
	grower_journal_scroll = ScrollContainer.new()
	grower_journal_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grower_journal_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	grower_journal_scroll.set_meta("mobile_scroll", true)
	column.add_child(grower_journal_scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 8)
	grower_journal_scroll.add_child(list)
	for badge_index in range(GROWER_JOURNAL_BADGE_IDS.size()):
		list.add_child(_build_grower_journal_card(str(GROWER_JOURNAL_BADGE_IDS[badge_index]), badge_index))
	_configure_mobile_scroll(grower_journal_scroll, list, "grower_journal")
	var close_button := _action_button("ZPĚT NA CESTU PĚSTITELE", _close_grower_journal)
	close_button.custom_minimum_size.y = 64
	close_button.set_meta("touch_target_min_height", 64)
	close_button.add_theme_font_override("font", FontExtraBold)
	close_button.add_theme_font_size_override("font_size", 14)
	ComicUITheme.apply_button(close_button, ComicUITheme.PURPLE, ComicUITheme.CREAM, 14)
	column.add_child(close_button)
	grower_journal_presenter.bind(grower_journal_summary_label, grower_journal_next_goal_label, grower_journal_badge_count_label, grower_journal_cards)
	return overlay


func _build_grower_journal_card(badge_id: String, badge_index: int) -> Control:
	var accents := [ComicUITheme.GREEN, ComicUITheme.CYAN, ComicUITheme.ORANGE, ComicUITheme.PURPLE]
	var accent: Color = accents[badge_index % accents.size()]
	var panel := PanelContainer.new()
	panel.custom_minimum_size.y = 112
	panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff2bd"), accent, 3, 14, Color("#07131c", 0.24), 4, 7.0))
	panel.set_meta("component", "grower_journal_badge_card_v1")
	panel.set_meta("badge_id", badge_id)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 3)
	panel.add_child(column)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	column.add_child(row)
	var title := Label.new()
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 13)
	title.add_theme_color_override("font_color", accent.darkened(0.34))
	row.add_child(title)
	var value := Label.new()
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value.add_theme_font_override("font", FontExtraBold)
	value.add_theme_font_size_override("font_size", 10)
	row.add_child(value)
	var description := Label.new()
	description.custom_minimum_size.y = 32
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_font_override("font", FontSemiBold)
	description.add_theme_font_size_override("font_size", 9)
	description.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(description)
	var progress := ProgressBar.new()
	progress.custom_minimum_size.y = 16
	progress.min_value = 0.0
	progress.max_value = 100.0
	progress.show_percentage = false
	progress.add_theme_stylebox_override("background", ComicUITheme.style_box(Color("#d5c897"), Color("#8b784c"), 1, 6, Color.TRANSPARENT, 0, 0.0))
	progress.add_theme_stylebox_override("fill", ComicUITheme.style_box(accent, accent.lightened(0.25), 1, 6, Color.TRANSPARENT, 0, 0.0))
	column.add_child(progress)
	grower_journal_cards[badge_id] = {"panel": panel, "title": title, "description": description, "value": value, "progress": progress, "accent": accent}
	return panel


func _build_care_center_modal() -> Control:
	var overlay := Control.new()
	overlay.name = "CareCenterModal"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 228
	overlay.visible = false
	overlay.set_meta("component", "fullscreen_care_center_modal_v1")
	overlay.set_meta("blocks_game_input", true)
	overlay.set_meta("covers_full_viewport", true)
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color("#061826", 0.96)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(scrim)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 13)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 13)
	margin.add_theme_constant_override("margin_bottom", 16)
	overlay.add_child(margin)
	var shell := PanelContainer.new()
	shell.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff8dc"), ComicUITheme.CYAN, 5, 22, Color("#000713", 0.66), 10, 12.0))
	shell.set_meta("component", "comic_care_center_shell_v1")
	margin.add_child(shell)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	shell.add_child(column)
	var banner := PanelContainer.new()
	banner.custom_minimum_size.y = 70
	banner.add_theme_stylebox_override("panel", ComicUITheme.style_box(ComicUITheme.TEAL, ComicUITheme.GOLD, 4, 17, Color("#07131c", 0.36), 4, 8.0))
	column.add_child(banner)
	var banner_row := HBoxContainer.new()
	banner_row.add_theme_constant_override("separation", 7)
	banner.add_child(banner_row)
	var heading := VBoxContainer.new()
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_theme_constant_override("separation", -2)
	banner_row.add_child(heading)
	var title := Label.new()
	title.text = "CENTRUM PÉČE"
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 21)
	title.add_theme_color_override("font_color", ComicUITheme.CREAM)
	title.add_theme_color_override("font_outline_color", ComicUITheme.INK)
	title.add_theme_constant_override("outline_size", 3)
	heading.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Všech 10 květináčů v pořadí naléhavosti."
	subtitle.add_theme_font_override("font", FontSemiBold)
	subtitle.add_theme_font_size_override("font_size", 10)
	subtitle.add_theme_color_override("font_color", Color("#ddfff3"))
	heading.add_child(subtitle)
	var top_close := _action_button("×", _close_care_center)
	top_close.custom_minimum_size = Vector2(56, 52)
	top_close.size_flags_horizontal = Control.SIZE_SHRINK_END
	top_close.set_meta("touch_target_min_height", 52)
	top_close.add_theme_font_override("font", FontExtraBold)
	top_close.add_theme_font_size_override("font_size", 25)
	ComicUITheme.apply_button(top_close, ComicUITheme.ORANGE, ComicUITheme.CREAM, 13)
	banner_row.add_child(top_close)
	care_center_summary_label = Label.new()
	care_center_summary_label.custom_minimum_size.y = 30
	care_center_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	care_center_summary_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	care_center_summary_label.add_theme_font_override("font", FontExtraBold)
	care_center_summary_label.add_theme_font_size_override("font_size", 12)
	care_center_summary_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(care_center_summary_label)
	care_center_scroll = ScrollContainer.new()
	care_center_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	care_center_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	care_center_scroll.set_meta("mobile_scroll", true)
	column.add_child(care_center_scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 9)
	care_center_scroll.add_child(list)
	for slot_index in range(GameSession.MAX_PLANT_SLOTS):
		list.add_child(_build_care_center_card(slot_index))
	_configure_mobile_scroll(care_center_scroll, list, "care_center")
	care_center_status_label = Label.new()
	care_center_status_label.custom_minimum_size.y = 42
	care_center_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	care_center_status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	care_center_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	care_center_status_label.add_theme_font_override("font", FontSemiBold)
	care_center_status_label.add_theme_font_size_override("font_size", 10)
	care_center_status_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(care_center_status_label)
	care_center_reminder_button = _action_button("PŘIPOMÍNKY V APLIKACI · ZAPNUTÉ", _on_care_reminders_toggled)
	care_center_reminder_button.custom_minimum_size.y = 56
	care_center_reminder_button.toggle_mode = true
	care_center_reminder_button.set_meta("touch_target_min_height", 56)
	care_center_reminder_button.set_meta("reminder_scope", "in_app_only_v1")
	care_center_reminder_button.add_theme_font_override("font", FontExtraBold)
	care_center_reminder_button.add_theme_font_size_override("font_size", 11)
	column.add_child(care_center_reminder_button)
	care_center_notification_test_button = _action_button("OVĚŘIT UPOZORNĚNÍ ZA 20 S", _on_care_notification_test_pressed)
	care_center_notification_test_button.custom_minimum_size.y = 56
	care_center_notification_test_button.visible = care_notification_service.is_system_available()
	care_center_notification_test_button.set_meta("component", "android_notification_self_test_v1")
	care_center_notification_test_button.set_meta("touch_target_min_height", 56)
	care_center_notification_test_button.add_theme_font_override("font", FontExtraBold)
	care_center_notification_test_button.add_theme_font_size_override("font_size", 11)
	ComicUITheme.apply_button(care_center_notification_test_button, ComicUITheme.ORANGE, ComicUITheme.CREAM, 11)
	column.add_child(care_center_notification_test_button)
	var close_button := _action_button("ZPĚT DO ZAHRADY", _close_care_center)
	close_button.custom_minimum_size.y = 64
	close_button.set_meta("touch_target_min_height", 64)
	close_button.add_theme_font_override("font", FontExtraBold)
	close_button.add_theme_font_size_override("font_size", 15)
	ComicUITheme.apply_button(close_button, ComicUITheme.GREEN, ComicUITheme.CREAM, 15)
	column.add_child(close_button)
	care_center_presenter.bind(care_center_summary_label, care_center_status_label, care_center_reminder_button, care_center_cards)
	return overlay


func _build_care_center_card(slot_index: int) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size.y = 148
	panel.set_meta("component", "care_center_slot_card_v1")
	panel.set_meta("slot_index", slot_index)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	panel.add_child(column)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 8)
	column.add_child(top)
	var slot_label := Label.new()
	slot_label.custom_minimum_size.x = 88
	slot_label.add_theme_font_override("font", FontExtraBold)
	slot_label.add_theme_font_size_override("font_size", 10)
	slot_label.add_theme_color_override("font_color", ComicUITheme.PURPLE)
	top.add_child(slot_label)
	var title := Label.new()
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 15)
	title.add_theme_color_override("font_color", ComicUITheme.INK)
	top.add_child(title)
	var state := Label.new()
	state.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	state.add_theme_font_override("font", FontExtraBold)
	state.add_theme_font_size_override("font_size", 10)
	top.add_child(state)
	var detail := Label.new()
	detail.custom_minimum_size.y = 30
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail.add_theme_font_override("font", FontSemiBold)
	detail.add_theme_font_size_override("font_size", 10)
	detail.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(detail)
	var check := Label.new()
	check.custom_minimum_size.y = 18
	check.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	check.add_theme_font_override("font", FontExtraBold)
	check.add_theme_font_size_override("font_size", 9)
	column.add_child(check)
	var action := _action_button("OTEVŘÍT DETAIL", _on_care_destination_pressed.bind(slot_index))
	action.custom_minimum_size.y = 56
	action.set_meta("touch_target_min_height", 56)
	action.add_theme_font_override("font", FontExtraBold)
	action.add_theme_font_size_override("font_size", 11)
	column.add_child(action)
	care_center_cards[slot_index] = {"panel": panel, "slot": slot_label, "title": title, "state": state, "detail": detail, "check": check, "action": action}
	return panel


func _build_plant_diagnosis_modal() -> Control:
	var overlay := Control.new()
	overlay.name = "PlantDiagnosisModal"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 229
	overlay.visible = false
	overlay.set_meta("component", "fullscreen_plant_diagnosis_modal_v1")
	overlay.set_meta("blocks_game_input", true)
	overlay.set_meta("covers_full_viewport", true)
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color("#061826", 0.96)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(scrim)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 13)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 13)
	margin.add_theme_constant_override("margin_bottom", 16)
	overlay.add_child(margin)
	var shell := PanelContainer.new()
	shell.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff8dc"), ComicUITheme.PURPLE, 5, 22, Color("#000713", 0.66), 10, 12.0))
	shell.set_meta("component", "comic_plant_diagnosis_shell_v1")
	margin.add_child(shell)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	shell.add_child(column)
	var banner := PanelContainer.new()
	banner.custom_minimum_size.y = 70
	banner.add_theme_stylebox_override("panel", ComicUITheme.style_box(ComicUITheme.PURPLE, ComicUITheme.GOLD, 4, 17, Color("#07131c", 0.36), 4, 8.0))
	column.add_child(banner)
	var banner_row := HBoxContainer.new()
	banner_row.add_theme_constant_override("separation", 7)
	banner.add_child(banner_row)
	var heading := VBoxContainer.new()
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_theme_constant_override("separation", -2)
	banner_row.add_child(heading)
	var title := Label.new()
	title.text = "DIAGNOSTIKA ROSTLINY"
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 19)
	title.add_theme_color_override("font_color", ComicUITheme.CREAM)
	title.add_theme_color_override("font_outline_color", ComicUITheme.INK)
	title.add_theme_constant_override("outline_size", 3)
	heading.add_child(title)
	var subtitle := Label.new()
	subtitle.text = "Přesný rozbor podmínek a doporučený další krok."
	subtitle.add_theme_font_override("font", FontSemiBold)
	subtitle.add_theme_font_size_override("font_size", 9)
	subtitle.add_theme_color_override("font_color", Color("#f4e9ff"))
	heading.add_child(subtitle)
	plant_diagnosis_close_button = _action_button("×", _close_plant_diagnosis)
	plant_diagnosis_close_button.custom_minimum_size = Vector2(64, 64)
	plant_diagnosis_close_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	plant_diagnosis_close_button.set_meta("touch_target_min_height", 64)
	plant_diagnosis_close_button.add_theme_font_override("font", FontExtraBold)
	plant_diagnosis_close_button.add_theme_font_size_override("font_size", 25)
	ComicUITheme.apply_button(plant_diagnosis_close_button, ComicUITheme.ORANGE, ComicUITheme.CREAM, 13)
	banner_row.add_child(plant_diagnosis_close_button)
	var summary_panel := PanelContainer.new()
	summary_panel.custom_minimum_size.y = 76
	summary_panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#e6fbff"), ComicUITheme.CYAN, 3, 14, Color("#07131c", 0.22), 3, 5.0))
	column.add_child(summary_panel)
	var summary_column := VBoxContainer.new()
	summary_column.alignment = BoxContainer.ALIGNMENT_CENTER
	summary_column.add_theme_constant_override("separation", 2)
	summary_panel.add_child(summary_column)
	plant_diagnosis_summary_label = Label.new()
	plant_diagnosis_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	plant_diagnosis_summary_label.add_theme_font_override("font", FontExtraBold)
	plant_diagnosis_summary_label.add_theme_font_size_override("font_size", 12)
	plant_diagnosis_summary_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	summary_column.add_child(plant_diagnosis_summary_label)
	plant_diagnosis_status_label = Label.new()
	plant_diagnosis_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	plant_diagnosis_status_label.add_theme_font_override("font", FontExtraBold)
	plant_diagnosis_status_label.add_theme_font_size_override("font_size", 15)
	summary_column.add_child(plant_diagnosis_status_label)
	var recommendation_panel := PanelContainer.new()
	recommendation_panel.custom_minimum_size.y = 72
	recommendation_panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff1b8"), ComicUITheme.GOLD, 3, 14, Color("#07131c", 0.20), 3, 5.0))
	column.add_child(recommendation_panel)
	plant_diagnosis_recommendation_label = Label.new()
	plant_diagnosis_recommendation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	plant_diagnosis_recommendation_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	plant_diagnosis_recommendation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	plant_diagnosis_recommendation_label.add_theme_font_override("font", FontExtraBold)
	plant_diagnosis_recommendation_label.add_theme_font_size_override("font_size", 10)
	plant_diagnosis_recommendation_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	recommendation_panel.add_child(plant_diagnosis_recommendation_label)
	plant_diagnosis_scroll = ScrollContainer.new()
	plant_diagnosis_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	plant_diagnosis_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	plant_diagnosis_scroll.set_meta("mobile_scroll", true)
	column.add_child(plant_diagnosis_scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 8)
	plant_diagnosis_scroll.add_child(list)
	for index in range(8):
		list.add_child(_build_plant_diagnosis_card(index))
	_configure_mobile_scroll(plant_diagnosis_scroll, list, "plant_diagnosis")
	plant_diagnosis_action_button = _action_button("ZPĚT K ROSTLINĚ", _on_plant_diagnosis_action_pressed)
	plant_diagnosis_action_button.custom_minimum_size.y = 64
	plant_diagnosis_action_button.set_meta("touch_target_min_height", 64)
	plant_diagnosis_action_button.set_meta("component", "plant_diagnosis_primary_action_v1")
	plant_diagnosis_action_button.set_meta("navigation_only", true)
	plant_diagnosis_action_button.add_theme_font_override("font", FontExtraBold)
	plant_diagnosis_action_button.add_theme_font_size_override("font_size", 15)
	ComicUITheme.apply_button(plant_diagnosis_action_button, ComicUITheme.GREEN, ComicUITheme.CREAM, 15)
	column.add_child(plant_diagnosis_action_button)
	plant_diagnosis_presenter.bind(plant_diagnosis_summary_label, plant_diagnosis_status_label, plant_diagnosis_recommendation_label, plant_diagnosis_action_button, plant_diagnosis_cards)
	return overlay


func _build_plant_diagnosis_card(index: int) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size.y = 116
	panel.set_meta("component", "plant_diagnosis_check_card_v1")
	panel.set_meta("card_index", index)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 3)
	panel.add_child(column)
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", 6)
	column.add_child(top)
	var title := Label.new()
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 13)
	title.add_theme_color_override("font_color", ComicUITheme.INK)
	top.add_child(title)
	var state := Label.new()
	state.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	state.add_theme_font_override("font", FontExtraBold)
	state.add_theme_font_size_override("font_size", 9)
	top.add_child(state)
	var value := Label.new()
	value.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	value.add_theme_font_override("font", FontSemiBold)
	value.add_theme_font_size_override("font_size", 10)
	value.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(value)
	var ideal := Label.new()
	ideal.add_theme_font_override("font", FontSemiBold)
	ideal.add_theme_font_size_override("font_size", 9)
	ideal.add_theme_color_override("font_color", Color("#477079"))
	column.add_child(ideal)
	var action := Label.new()
	action.custom_minimum_size.y = 32
	action.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	action.add_theme_font_override("font", FontExtraBold)
	action.add_theme_font_size_override("font_size", 9)
	action.add_theme_color_override("font_color", ComicUITheme.INK)
	column.add_child(action)
	plant_diagnosis_cards.append({"panel": panel, "title": title, "state": state, "value": value, "ideal": ideal, "action": action})
	return panel


func _build_cosmetic_modal() -> Control:
	var overlay := Control.new()
	overlay.name = "CosmeticShowroomModal"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 205
	overlay.visible = false
	overlay.set_meta("component", "fullscreen_cosmetic_showroom_v1")
	overlay.set_meta("blocks_game_input", true)
	overlay.set_meta("gameplay_bonuses", false)
	overlay.set_meta("covers_full_viewport", true)
	overlay.set_meta("phase162_runtime_set", VisualDesignSystem.COSMETIC_SHOWROOM_PHASE162_RUNTIME_SET_ID)
	overlay.set_meta("phase162_scene_profile", VisualDesignSystem.COSMETIC_SHOWROOM_PHASE162_SCENE_PROFILE_ID)
	overlay.set_meta("phase162_layer_policy", "clean_painted_plate_dynamic_copy_wallet_states_and_buttons_v1")
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color("#061923", 0.88)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	scrim.set_meta("component", "phase162_live_room_scrim_v1")
	overlay.add_child(scrim)

	cosmetic_showroom_scroll = ScrollContainer.new()
	cosmetic_showroom_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	cosmetic_showroom_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cosmetic_showroom_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cosmetic_showroom_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	cosmetic_showroom_scroll.set_meta("mobile_scroll", true)
	overlay.add_child(cosmetic_showroom_scroll)

	var canvas := Control.new()
	canvas.name = "PaintedShowroomCanvas"
	canvas.custom_minimum_size = Vector2.ONE
	canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	canvas.mouse_filter = Control.MOUSE_FILTER_PASS
	canvas.set_meta("component", "phase162_painted_showroom_canvas_v1")
	cosmetic_showroom_scroll.add_child(canvas)

	var painted_backdrop := TextureRect.new()
	_apply_hud_rect(painted_backdrop, CosmeticShowroomVisualLayout.PLATE_VIEWPORT_RECT)
	painted_backdrop.texture = CosmeticShowroomVisualLayout.create_plate_texture(Phase162CosmeticShowroomBackdrop)
	painted_backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	painted_backdrop.stretch_mode = TextureRect.STRETCH_SCALE
	painted_backdrop.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	painted_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	painted_backdrop.set_meta("component", "painted_cosmetic_showroom_clean_backdrop_phase162_v1")
	painted_backdrop.set_meta("source_pixel_policy", "generated_clean_plate_no_baked_copy_values_or_states_v1")
	canvas.add_child(painted_backdrop)

	var header_badge := _phase162_showroom_label("VZHLED POKOJE", CosmeticShowroomVisualLayout.HEADER_BADGE_RECT, FontExtraBold, 12, Color("#3d2a17"), 1)
	header_badge.add_theme_color_override("font_outline_color", Color("#f2b35d", 0.66))
	header_badge.add_theme_constant_override("outline_size", 1)
	header_badge.set_meta("component", "painted_cosmetic_showroom_dynamic_badge_phase162_v1")
	canvas.add_child(header_badge)

	var title := _phase162_showroom_label("KOUZELNÝ SHOWROOM", CosmeticShowroomVisualLayout.HEADER_TITLE_RECT, FontExtraBold, 23, ComicUITheme.CREAM, 2)
	title.add_theme_color_override("font_outline_color", ComicUITheme.INK)
	title.add_theme_constant_override("outline_size", 3)
	title.set_meta("component", "painted_cosmetic_showroom_dynamic_header_phase162_v1")
	canvas.add_child(title)

	var intro := _phase162_showroom_label(
		"Vzhled mění jen atmosféru pokoje. Růst, počasí i odměny zůstávají stejné.",
		CosmeticShowroomVisualLayout.INTRO_RECT,
		FontSemiBold,
		12,
		ComicUITheme.NAVY,
		3
	)
	intro.set_meta("component", "painted_cosmetic_showroom_dynamic_intro_phase162_v1")
	canvas.add_child(intro)

	cosmetic_theme_cards.clear()
	for theme_id in CosmeticShowroomVisualLayout.THEME_ORDER:
		canvas.add_child(_build_cosmetic_theme_card(theme_id))

	cosmetic_status_label = _phase162_showroom_label("", CosmeticShowroomVisualLayout.STATUS_RECT, FontExtraBold, 11, ComicUITheme.NAVY, 2)
	cosmetic_status_label.set_meta("component", "painted_cosmetic_showroom_dynamic_wallet_phase162_v1")
	canvas.add_child(cosmetic_status_label)

	var close_button := _action_button("HOTOVO", _close_cosmetic_modal)
	_apply_hud_rect(close_button, CosmeticShowroomVisualLayout.viewport_rect(CosmeticShowroomVisualLayout.CLOSE_RECT))
	close_button.custom_minimum_size.y = 58
	close_button.set_meta("touch_target_min_height", 64)
	_phase162_prepare_painted_showroom_button(close_button, 17, "close")
	canvas.add_child(close_button)

	_configure_mobile_scroll(cosmetic_showroom_scroll, canvas, "cosmetic_showroom")
	cosmetic_showroom_presenter.bind(cosmetic_status_label, cosmetic_theme_cards)
	return overlay


func _build_cosmetic_theme_card(theme_id: String) -> Control:
	var theme_data := _get_cosmetic_theme_data(theme_id)
	var accent := Color(str(theme_data.get("accent", "#74848b")))
	var layout := CosmeticShowroomVisualLayout.theme_layout(theme_id)
	var panel := Control.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.set_meta("component", "phase162_painted_cosmetic_theme_card_v1")
	panel.set_meta("theme_id", theme_id)

	var name_font_size := 10 if theme_id == "research_study" else 15
	var name_label := _phase162_showroom_label(str(theme_data.name).to_upper(), layout.name as Rect2, FontExtraBold, name_font_size, ComicUITheme.NAVY, 1)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	name_label.add_theme_color_override("font_outline_color", Color("#fff2c5", 0.82))
	name_label.add_theme_constant_override("outline_size", 2)
	panel.add_child(name_label)

	var description_font_size := 8 if theme_id == "research_study" else 11
	var description_max_lines := 3 if theme_id == "research_study" else 5
	var description := _phase162_showroom_label(str(theme_data.description), layout.description as Rect2, FontSemiBold, description_font_size, ComicUITheme.NAVY, description_max_lines)
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	panel.add_child(description)

	var action_state := PanelContainer.new()
	_apply_hud_rect(action_state, CosmeticShowroomVisualLayout.viewport_rect(layout.button as Rect2))
	action_state.mouse_filter = Control.MOUSE_FILTER_IGNORE
	action_state.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	action_state.set_meta("component", "phase162_cosmetic_theme_state_overlay_v1")
	action_state.set_meta("theme_id", theme_id)
	panel.add_child(action_state)

	var action := Button.new()
	_apply_hud_rect(action, CosmeticShowroomVisualLayout.viewport_rect(layout.button_hit as Rect2))
	action.focus_mode = Control.FOCUS_NONE
	action.set_meta("touch_target_min_height", 52)
	action.set_meta("component", "phase162_painted_cosmetic_theme_action_v1")
	action.set_meta("theme_id", theme_id)
	action.pressed.connect(_on_room_theme_pressed.bind(theme_id))
	_phase162_prepare_painted_showroom_button(action, 12 if theme_id != "research_study" else 10, "theme_%s" % theme_id)
	for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_disabled_color", "font_outline_color"]:
		action.add_theme_color_override(color_name, Color.TRANSPARENT)
	action.add_theme_constant_override("outline_size", 0)
	panel.add_child(action)

	var action_label := _phase162_showroom_label("", layout.button as Rect2, FontExtraBold, 12 if theme_id != "research_study" else 9, ComicUITheme.CREAM, 2)
	action_label.add_theme_color_override("font_outline_color", ComicUITheme.INK)
	action_label.add_theme_constant_override("outline_size", 2)
	action_label.set_meta("component", "phase162_cosmetic_theme_dynamic_action_label_v1")
	action_label.set_meta("theme_id", theme_id)
	panel.add_child(action_label)

	cosmetic_theme_cards[theme_id] = {
		"panel": panel,
		"button": action,
		"accent": accent,
		"name": name_label,
		"description": description,
		"action_label": action_label,
		"state_overlay": action_state,
		"painted_surface": true,
	}
	return panel


func _phase162_showroom_label(text: String, source_rect: Rect2, font: Font, font_size: int, color: Color, max_lines: int) -> Label:
	var label := Label.new()
	label.text = text
	_apply_hud_rect(label, CosmeticShowroomVisualLayout.viewport_rect(source_rect))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.max_lines_visible = max_lines
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _phase162_prepare_painted_showroom_button(button: Button, font_size: int, role: String) -> void:
	button.add_theme_font_override("font", FontExtraBold)
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", ComicUITheme.CREAM)
	button.add_theme_color_override("font_hover_color", ComicUITheme.CREAM)
	button.add_theme_color_override("font_pressed_color", ComicUITheme.CREAM)
	button.add_theme_color_override("font_focus_color", ComicUITheme.CREAM)
	button.add_theme_color_override("font_disabled_color", Color("#fff2c4", 0.90))
	button.add_theme_color_override("font_outline_color", ComicUITheme.INK)
	button.add_theme_constant_override("outline_size", 2)
	button.set_meta("phase162_uses_baked_painted_surface", true)
	button.set_meta("phase162_button_role", role)
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		button.add_theme_stylebox_override(state, StyleBoxEmpty.new())


func _get_cosmetic_theme_data(theme_id: String) -> Dictionary:
	if GameSession.ROOM_THEMES.has(theme_id):
		var base_theme: Variant = GameSession.ROOM_THEMES.get(theme_id, {})
		if base_theme is Dictionary:
			return base_theme.duplicate(true)
	return {
		"name": "Neznámé nastavení vzhledu",
		"price": 0,
		"accent": "#6e7480",
		"description": "Tento vzhled je pro tuto verzi pokoje zatím nedostupný.",
	}


func _build_return_summary_modal() -> Control:
	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 230
	overlay.visible = false
	overlay.set_meta("component", "phase15_mobile_return_summary_v1")
	overlay.set_meta("extension_component", "phase109_greenhouse_return_summary_v1")
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color("#06131f", 0.92)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(scrim)
	var card := PanelContainer.new()
	card.set_anchor(SIDE_LEFT, 0.06)
	card.set_anchor(SIDE_TOP, 0.25)
	card.set_anchor(SIDE_RIGHT, 0.94)
	card.set_anchor(SIDE_BOTTOM, 0.70)
	card.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff7d8"), ComicUITheme.CYAN, 5, 22, Color("#000713", 0.64), 10, 15.0))
	overlay.add_child(card)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 16)
	card.add_child(column)
	var title := Label.new()
	title.text = "NÁVRAT DO ZAHRADY"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 23)
	title.add_theme_color_override("font_color", ComicUITheme.PURPLE)
	column.add_child(title)
	return_summary_label = Label.new()
	return_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return_summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return_summary_label.add_theme_font_override("font", FontSemiBold)
	return_summary_label.add_theme_font_size_override("font_size", 15)
	return_summary_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(return_summary_label)
	return_summary_presenter.bind(return_summary_label)
	var close_button := _action_button("ZKONTROLOVAT ZAHRADU", _close_return_summary)
	close_button.custom_minimum_size.y = 68
	close_button.add_theme_font_override("font", FontExtraBold)
	close_button.add_theme_font_size_override("font_size", 15)
	ComicUITheme.apply_button(close_button, ComicUITheme.GREEN, ComicUITheme.CREAM, 14)
	close_button.set_meta("touch_target_min_height", 68)
	close_button.set_meta("component", "phase109_return_summary_garden_cta_v1")
	column.add_child(close_button)
	return overlay


func _build_save_recovery_modal() -> Control:
	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 240
	overlay.visible = false
	overlay.set_meta("component", "phase15_safe_save_recovery_v1")
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color("#120b1d", 0.96)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(scrim)
	var card := PanelContainer.new()
	card.set_anchor(SIDE_LEFT, 0.055)
	card.set_anchor(SIDE_TOP, 0.18)
	card.set_anchor(SIDE_RIGHT, 0.945)
	card.set_anchor(SIDE_BOTTOM, 0.77)
	card.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff6dc"), ComicUITheme.ORANGE, 5, 22, Color("#000713", 0.68), 10, 15.0))
	overlay.add_child(card)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 14)
	card.add_child(column)
	var title := Label.new()
	title.text = "OCHRANA ULOŽENÉ HRY"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", ComicUITheme.PURPLE)
	column.add_child(title)
	save_recovery_label = Label.new()
	save_recovery_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	save_recovery_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_recovery_label.add_theme_font_override("font", FontSemiBold)
	save_recovery_label.add_theme_font_size_override("font_size", 14)
	save_recovery_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(save_recovery_label)
	var keep_button := _action_button("POKRAČOVAT BEZ UKLÁDÁNÍ", _continue_after_save_recovery)
	keep_button.custom_minimum_size.y = 64
	ComicUITheme.apply_button(keep_button, ComicUITheme.CYAN, ComicUITheme.INK, 14)
	keep_button.set_meta("touch_target_min_height", 64)
	column.add_child(keep_button)
	save_recovery_confirm_button = _action_button("ZAČÍT NOVOU HRU", _confirm_new_game_after_recovery)
	save_recovery_confirm_button.custom_minimum_size.y = 64
	ComicUITheme.apply_button(save_recovery_confirm_button, ComicUITheme.ORANGE, ComicUITheme.CREAM, 14)
	save_recovery_confirm_button.set_meta("touch_target_min_height", 64)
	column.add_child(save_recovery_confirm_button)
	save_recovery_presenter.bind(save_recovery_label, save_recovery_confirm_button)
	return overlay


func _build_save_failure_modal() -> Control:
	var overlay := Control.new()
	overlay.name = "SaveFailureModal"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 250
	overlay.visible = false
	overlay.set_meta("component", "phase46_save_failure_modal_v1")
	overlay.set_meta("blocks_game_input", true)
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color("#120b1d", 0.96)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(scrim)
	var card := PanelContainer.new()
	card.set_anchor(SIDE_LEFT, 0.055)
	card.set_anchor(SIDE_TOP, 0.21)
	card.set_anchor(SIDE_RIGHT, 0.945)
	card.set_anchor(SIDE_BOTTOM, 0.75)
	card.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff6dc"), ComicUITheme.ORANGE, 5, 22, Color("#000713", 0.68), 10, 15.0))
	overlay.add_child(card)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 14)
	card.add_child(column)
	var title := Label.new()
	title.text = "UKLÁDÁNÍ SE NEZDAŘILO"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 21)
	title.add_theme_color_override("font_color", ComicUITheme.PURPLE)
	column.add_child(title)
	save_failure_label = Label.new()
	save_failure_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	save_failure_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_failure_label.add_theme_font_override("font", FontSemiBold)
	save_failure_label.add_theme_font_size_override("font_size", 14)
	save_failure_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(save_failure_label)
	save_failure_retry_button = _action_button("ZKUSIT ULOŽIT ZNOVU", _retry_failed_save)
	save_failure_retry_button.custom_minimum_size.y = 64
	save_failure_retry_button.set_meta("touch_target_min_height", 64)
	ComicUITheme.apply_button(save_failure_retry_button, ComicUITheme.GREEN, ComicUITheme.CREAM, 14)
	column.add_child(save_failure_retry_button)
	save_failure_continue_button = _action_button("POKRAČOVAT BEZ ULOŽENÍ", _continue_without_saving)
	save_failure_continue_button.custom_minimum_size.y = 64
	save_failure_continue_button.set_meta("touch_target_min_height", 64)
	ComicUITheme.apply_button(save_failure_continue_button, ComicUITheme.CYAN, ComicUITheme.INK, 14)
	column.add_child(save_failure_continue_button)
	return overlay


func _build_herbarium_card(species_id: String) -> Control:
	var plant_profile := session.get_plant_profile(species_id)
	var accent := _species_accent(species_id)
	var card := PanelContainer.new()
	card.custom_minimum_size.y = 382
	card.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff0c0", 0.965), Color("#754719"), 3, 14, Color("#2b1408", 0.42), 5, 7.0))
	card.set_meta("species_id", species_id)
	card.set_meta("component", "herbarium_species_mastery_card_v1")
	card.set_meta("phase155_component", "painted_dynamic_species_page_v1")
	card.set_meta("phase155_runtime_set", VisualDesignSystem.HERBARIUM_PHASE155_RUNTIME_SET_ID)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 7)
	card.add_child(column)
	var hero := HBoxContainer.new()
	hero.add_theme_constant_override("separation", 9)
	column.add_child(hero)
	var icon_frame := PanelContainer.new()
	icon_frame.custom_minimum_size = Vector2(118, 150)
	icon_frame.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#f5d98f", 0.88), Color("#9a6828"), 3, 13, Color("#321708", 0.30), 3, 5.0))
	icon_frame.set_meta("component", "painted_herbarium_plant_portrait_frame_phase155_v1")
	hero.add_child(icon_frame)
	var icon := TextureRect.new()
	icon.texture = _species_herbarium_texture(species_id)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	icon.set_meta("component", "painted_herbarium_dynamic_plant_portrait_phase155_v1")
	icon_frame.add_child(icon)
	var identity := VBoxContainer.new()
	identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	identity.add_theme_constant_override("separation", 2)
	hero.add_child(identity)
	var name_label := Label.new()
	name_label.text = str(plant_profile.get("display_name", "Bylinka")).to_upper()
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_font_override("font", FontExtraBold)
	name_label.add_theme_font_size_override("font_size", 17)
	name_label.add_theme_color_override("font_color", Color("#24451d"))
	identity.add_child(name_label)
	var rarity_definition := session.get_species_rarity_definition(species_id)
	var rarity_label := Label.new()
	rarity_label.text = "%s  ·  %s" % ["★".repeat(maxi(1, int(rarity_definition.get("stars", 1)))), str(rarity_definition.get("label", "BĚŽNÁ"))]
	rarity_label.add_theme_font_override("font", FontExtraBold)
	rarity_label.add_theme_font_size_override("font_size", 11)
	rarity_label.add_theme_color_override("font_color", Color(str(rarity_definition.get("color_hex", "#76D91D"))).darkened(0.28))
	identity.add_child(rarity_label)
	var rank_label := Label.new()
	rank_label.add_theme_font_override("font", FontExtraBold)
	rank_label.add_theme_font_size_override("font_size", 13)
	rank_label.add_theme_color_override("font_color", ComicUITheme.PURPLE)
	identity.add_child(rank_label)
	var progress_bar := ProgressBar.new()
	progress_bar.custom_minimum_size.y = 26
	progress_bar.max_value = 100.0
	progress_bar.show_percentage = false
	ComicUITheme.apply_progress(progress_bar, accent, Color("#174f56"), ComicUITheme.INK, 8)
	identity.add_child(progress_bar)
	var overview := Label.new()
	overview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overview.add_theme_font_override("font", FontSemiBold)
	overview.add_theme_font_size_override("font_size", 10)
	overview.add_theme_color_override("font_color", Color("#4b2c17"))
	identity.add_child(overview)
	var behavior := Label.new()
	behavior.custom_minimum_size.y = 44
	behavior.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	behavior.add_theme_font_override("font", FontExtraBold)
	behavior.add_theme_font_size_override("font_size", 9)
	behavior.add_theme_color_override("font_color", accent.darkened(0.30))
	behavior.set_meta("component", "herbarium_species_behavior_v1")
	column.add_child(behavior)
	var stats_label := Label.new()
	stats_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stats_label.add_theme_font_override("font", FontExtraBold)
	stats_label.add_theme_font_size_override("font_size", 10)
	stats_label.add_theme_color_override("font_color", Color("#4b2c17"))
	column.add_child(stats_label)
	var goal_label := Label.new()
	goal_label.custom_minimum_size.y = 40
	goal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	goal_label.add_theme_font_override("font", FontSemiBold)
	goal_label.add_theme_font_size_override("font_size", 10)
	goal_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(goal_label)
	var claim_button := _action_button("ODMĚNA", _on_mastery_reward_claimed.bind(species_id))
	claim_button.custom_minimum_size.y = 58
	claim_button.set_meta("touch_target_min_height", 58)
	claim_button.set_meta("phase155_component", "painted_species_reward_action_v1")
	claim_button.add_theme_font_override("font", FontExtraBold)
	claim_button.add_theme_font_size_override("font_size", 12)
	ComicUITheme.apply_button(claim_button, accent, ComicUITheme.CREAM, 13)
	column.add_child(claim_button)
	herbarium_cards[species_id] = {"panel": card, "icon": icon, "name": name_label, "rarity": rarity_label, "rank": rank_label, "progress": progress_bar, "overview": overview, "behavior": behavior, "stats": stats_label, "goal": goal_label, "claim": claim_button, "accent": accent}
	return card


func _species_accent(species_id: String) -> Color:
	return plant_presentation_catalog.species_accent(species_id)


func _species_preview_texture(species_id: String) -> Texture2D:
	return plant_presentation_catalog.species_preview_texture(species_id)


func _species_herbarium_texture(species_id: String) -> Texture2D:
	return plant_presentation_catalog.species_herbarium_texture(species_id)


func _seed_species_description(species_id: String) -> String:
	return plant_presentation_catalog.seed_species_description(species_id, session.get_species_behavior_definitions(species_id))


func _seed_species_button(title: String, body: String, texture: Texture2D, accent: Color, species_id: String) -> Button:
	var button := Button.new()
	button.custom_minimum_size.y = 142
	button.focus_mode = Control.FOCUS_NONE
	button.set_meta("species_id", species_id)
	button.set_meta("component", "comic_seed_species_card_v1")
	button.set_meta("touch_target_min_height", 142)
	ComicUITheme.apply_button(button, Color("#fff3c4"), accent, 14, ComicUITheme.INK, 4)
	button.pressed.connect(_on_seed_species_selected.bind(species_id))
	var row := HBoxContainer.new()
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 9
	row.offset_top = 7
	row.offset_right = -9
	row.offset_bottom = -7
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 8)
	button.add_child(row)
	var preview := TextureRect.new()
	preview.texture = texture
	preview.custom_minimum_size = Vector2(100, 124)
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview.set_meta("species_preview", species_id)
	row.add_child(preview)
	var texts := VBoxContainer.new()
	texts.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	texts.alignment = BoxContainer.ALIGNMENT_CENTER
	texts.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(texts)
	var heading := Label.new()
	heading.text = title
	heading.add_theme_font_override("font", FontExtraBold)
	heading.add_theme_font_size_override("font_size", 16)
	heading.add_theme_color_override("font_color", ComicUITheme.INK)
	heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texts.add_child(heading)
	var description := Label.new()
	description.text = body
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_font_override("font", FontSemiBold)
	description.add_theme_font_size_override("font_size", 11)
	description.add_theme_color_override("font_color", ComicUITheme.NAVY)
	description.mouse_filter = Control.MOUSE_FILTER_IGNORE
	description.set_meta("seed_description", true)
	texts.add_child(description)
	var owned := Label.new()
	owned.name = "OwnedLabel"
	owned.add_theme_font_override("font", FontExtraBold)
	owned.add_theme_font_size_override("font_size", 13)
	owned.add_theme_color_override("font_color", accent)
	owned.mouse_filter = Control.MOUSE_FILTER_IGNORE
	texts.add_child(owned)
	button.set_meta("owned_label", owned)
	button.set_meta("description_label", description)
	button.resized.connect(_sync_seed_species_button_height.bind(button, preview, texts, description))
	description.resized.connect(_sync_seed_species_button_height.bind(button, preview, texts, description))
	texts.minimum_size_changed.connect(_sync_seed_species_button_height.bind(button, preview, texts, description))
	call_deferred("_sync_seed_species_button_height", button, preview, texts, description)
	return button


func _sync_seed_species_button_height(button: Button, preview: TextureRect, texts: VBoxContainer, description: Label) -> void:
	if not is_instance_valid(button) or not is_instance_valid(preview) or not is_instance_valid(texts) or not is_instance_valid(description):
		return
	var description_line_count := maxi(1, description.get_line_count())
	var description_content_height := ceilf(float(description_line_count * description.get_line_height()))
	if not is_equal_approx(description.custom_minimum_size.y, description_content_height):
		description.custom_minimum_size.y = description_content_height
	var content_height := maxf(preview.get_combined_minimum_size().y, texts.get_combined_minimum_size().y)
	var required_height := ceilf(maxf(142.0, content_height + 14.0))
	if not is_equal_approx(button.custom_minimum_size.y, required_height):
		button.custom_minimum_size.y = required_height
	button.set_meta("touch_target_min_height", ceili(required_height))
	button.set_meta("content_minimum_height", content_height)
	button.set_meta("description_line_count", description_line_count)
	button.set_meta("description_content_height", description_content_height)


func _settings_toggle_button(title: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = title
	button.toggle_mode = true
	button.custom_minimum_size = Vector2(0, 64)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_override("font", FontExtraBold)
	button.add_theme_font_size_override("font_size", 13)
	button.toggled.connect(callback)
	button.set_meta("touch_target_min_height", 64)
	return button


func _settings_slider_title(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", FontExtraBold)
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	return label


func _settings_slider(callback: Callable) -> HSlider:
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 5.0
	slider.custom_minimum_size.y = 46
	slider.focus_mode = Control.FOCUS_NONE
	slider.value_changed.connect(callback)
	slider.set_meta("touch_target_min_height", 46)
	return slider


func _open_settings_modal() -> void:
	_set_settings_modal_open(true)


func _close_settings_modal() -> void:
	if audio_haptics != null:
		audio_haptics.play_ui("confirm")
	_set_settings_modal_open(false)


func _set_settings_modal_open(opening: bool) -> void:
	if settings_modal == null:
		return
	if opening and care_center_open:
		_set_care_center_open(false)
	if opening and level_progression_open:
		_set_level_progression_open(false)
	if opening and herbarium_open:
		_set_herbarium_open(false)
	if opening and daily_challenge_open:
		_set_daily_challenge_open(false)
	if opening and cosmetic_modal_open:
		_set_cosmetic_modal_open(false)
	if opening and dialog_open:
		_set_guide_modal_open(false, false)
	settings_modal_open = opening
	settings_modal.visible = opening
	if opening:
		settings_modal.move_to_front()
		_refresh_audio_settings()
		if audio_haptics != null:
			audio_haptics.play_ui("tap")


func _open_seed_selector() -> void:
	_set_seed_selector_open(true)


func _close_seed_selector() -> void:
	_set_seed_selector_open(false)


func _set_seed_selector_open(opening: bool) -> void:
	if seed_selector_modal == null:
		return
	if opening and care_center_open:
		_set_care_center_open(false)
	if opening and level_progression_open:
		_set_level_progression_open(false)
	if opening and herbarium_open:
		_set_herbarium_open(false)
	if opening and daily_challenge_open:
		_set_daily_challenge_open(false)
	if opening and cosmetic_modal_open:
		_set_cosmetic_modal_open(false)
	if opening and dialog_open:
		_set_guide_modal_open(false, false)
	if opening and settings_modal_open:
		_set_settings_modal_open(false)
	seed_selector_open = opening
	seed_selector_modal.visible = opening
	if opening:
		seed_selector_modal.move_to_front()
		_refresh_seed_selector()
		if audio_haptics != null:
			audio_haptics.play_ui("tap")


func _open_herbarium() -> void:
	_set_herbarium_open(true)


func _close_herbarium() -> void:
	_set_herbarium_open(false)


func _set_herbarium_open(opening: bool) -> void:
	if herbarium_modal == null:
		return
	if opening and care_center_open:
		_set_care_center_open(false)
	if opening and level_progression_open:
		_set_level_progression_open(false)
	if opening and dialog_open:
		_set_guide_modal_open(false, false)
	if opening and settings_modal_open:
		_set_settings_modal_open(false)
	if opening and seed_selector_open:
		_set_seed_selector_open(false)
	if opening and daily_challenge_open:
		_set_daily_challenge_open(false)
	if opening and cosmetic_modal_open:
		_set_cosmetic_modal_open(false)
	herbarium_open = opening
	herbarium_modal.visible = opening
	if opening:
		herbarium_modal.move_to_front()
		herbarium_presenter.show_intro()
		_refresh_herbarium()
		if audio_haptics != null:
			audio_haptics.play_ui("tap")
	elif audio_haptics != null:
		audio_haptics.play_ui("tap")


func _open_daily_challenge() -> void:
	if session != null:
		session.refresh_daily_challenge_context()
	_set_daily_challenge_open(true)


func _close_daily_challenge() -> void:
	_set_daily_challenge_open(false)


func _open_botanical_pack() -> void:
	_set_botanical_pack_open(true)


func _close_botanical_pack_to_daily() -> void:
	_set_botanical_pack_open(false)
	_set_daily_challenge_open(true)


func _open_cosmetic_modal() -> void:
	_set_cosmetic_modal_open(true)


func _close_cosmetic_modal() -> void:
	_set_cosmetic_modal_open(false)


func _set_cosmetic_modal_open(opening: bool) -> void:
	if cosmetic_modal == null:
		return
	if opening and care_center_open:
		_set_care_center_open(false)
	if opening and level_progression_open:
		_set_level_progression_open(false)
	if opening and dialog_open:
		_set_guide_modal_open(false, false)
	if opening and settings_modal_open:
		_set_settings_modal_open(false)
	if opening and seed_selector_open:
		_set_seed_selector_open(false)
	if opening and herbarium_open:
		_set_herbarium_open(false)
	if opening and daily_challenge_open:
		_set_daily_challenge_open(false)
	cosmetic_modal_open = opening
	cosmetic_modal.visible = opening
	if opening:
		cosmetic_modal.move_to_front()
		_refresh_cosmetic_showroom()
	if audio_haptics != null:
		audio_haptics.play_ui("tap")


func _refresh_cosmetic_showroom() -> void:
	if session == null or cosmetic_status_label == null:
		return
	cosmetic_showroom_presenter.refresh(session)


func _on_room_theme_pressed(theme_id: String) -> void:
	if session == null:
		return
	var state := session.get_room_theme_unlock_state(theme_id)
	var reason := str(state.get("reason", "unknown"))
	if reason == "unknown" or reason == "insufficient_coins" or reason == "research_required":
		cosmetic_showroom_presenter.show_room_theme_unlock_state(state)
		return
	if not session.unlock_or_select_room_theme(theme_id):
		state = session.get_room_theme_unlock_state(theme_id)
		var failure_reason := str(state.get("reason", ""))
		if failure_reason == "insufficient_coins" or failure_reason == "research_required" or failure_reason == "unknown":
			cosmetic_showroom_presenter.show_room_theme_unlock_state(state)
		return
	cosmetic_showroom_presenter.restore_status_color()
	room_overview.set_cosmetic_theme(session.selected_room_theme)
	player_room_view.set_cosmetic_theme(session.selected_room_theme)
	_save_current_session()
	_refresh_ui()
	_refresh_cosmetic_showroom()


func _open_room_decoration_modal(slot_index: int) -> void:
	if session == null or room_decoration_modal == null:
		return
	if active_screen != 0 or garden_location_id != GARDEN_LOCATION_PLAYER_ROOM:
		return
	if cosmetic_modal_open:
		_close_cosmetic_modal()
	room_decoration_open = true
	room_decoration_modal.open_for_slot(session, slot_index)
	if audio_haptics != null:
		audio_haptics.play_ui("tap")


func _close_room_decoration_modal() -> void:
	if room_decoration_modal == null:
		return
	room_decoration_open = false
	room_decoration_modal.close_modal()
	if audio_haptics != null:
		audio_haptics.play_ui("tap")


func _on_room_decoration_requested(decoration_id: String, slot_index: int) -> void:
	if session == null or room_decoration_modal == null or not room_decoration_open:
		return
	var changed := session.purchase_or_place_room_decoration(decoration_id, slot_index)
	if changed:
		player_room_view.set_room_decorations(session.get_room_decoration_slots(), GameSession.ROOM_DECORATIONS)
		_save_current_session()
		_refresh_coin_display()
	room_decoration_modal.refresh(session)
	if audio_haptics != null:
		audio_haptics.play_ui("confirm" if changed else "error")


func _on_room_plant_drag_started() -> void:
	if audio_haptics != null:
		audio_haptics.play_ui("tap")


func _on_room_plant_move_requested(source_slot: int, target_slot: int, decoration_id: String) -> void:
	if not _room_plant_drag_available():
		return
	var swapped := target_slot >= 0 and target_slot < GameSession.ROOM_PLANT_SLOT_COUNT and not session.room_decoration_slots[target_slot].is_empty()
	var moved := session.move_room_plant(source_slot, target_slot, decoration_id)
	player_room_view.set_room_decorations(session.get_room_decoration_slots(), GameSession.ROOM_DECORATIONS)
	if moved and not _save_current_session():
		# The existing blocking save-failure dialog owns retry/recovery. Never
		# claim persistence while the filesystem rejected the write.
		return
	player_room_view.show_plant_move_result(moved, swapped)
	if audio_haptics != null:
		audio_haptics.play_ui("confirm" if moved else "error")


func _on_room_decoration_clear_requested(slot_index: int) -> void:
	if session == null or room_decoration_modal == null or not room_decoration_open:
		return
	var changed := session.clear_room_decoration_slot(slot_index)
	if changed:
		player_room_view.set_room_decorations(session.get_room_decoration_slots(), GameSession.ROOM_DECORATIONS)
		_save_current_session()
	room_decoration_modal.refresh(session)
	if audio_haptics != null:
		audio_haptics.play_ui("confirm" if changed else "error")


func _on_greenhouse_bed_action_requested(bed_index: int) -> void:
	if session == null or greenhouse_preview_view == null:
		return
	if active_screen != 0 or garden_location_id != GARDEN_LOCATION_GREENHOUSE:
		return
	var changed := session.perform_greenhouse_bed_action(bed_index)
	if changed:
		_save_current_session()
		_refresh_coin_display()
		_refresh_xp_display()
	_refresh_greenhouse_view()
	_refresh_rack_greenhouse_attention()
	if audio_haptics != null:
		audio_haptics.play_ui("confirm" if changed else "error")


func _on_greenhouse_crop_plant_requested(bed_index: int, crop_id: String) -> void:
	if session == null or greenhouse_preview_view == null:
		return
	if active_screen != 0 or garden_location_id != GARDEN_LOCATION_GREENHOUSE:
		return
	var changed := session.plant_greenhouse_crop(bed_index, crop_id)
	if changed:
		_save_current_session()
		_refresh_coin_display()
	_refresh_greenhouse_view()
	_refresh_rack_greenhouse_attention()
	if audio_haptics != null:
		audio_haptics.play_ui("confirm" if changed else "error")


func _resume_from_background() -> void:
	if suspended_at_unix <= 0.0 or session == null:
		return
	var elapsed := maxf(0.0, Time.get_unix_time_from_system() - suspended_at_unix)
	suspended_at_unix = 0.0
	_apply_resume_elapsed(elapsed)


func _apply_resume_elapsed(elapsed: float) -> float:
	if session == null or elapsed <= 1.0:
		return 0.0
	var applied := session.advance_offline(elapsed)
	_refresh_rack_greenhouse_attention()
	_save_current_session()
	_present_return_summary(applied)
	return applied


func _present_return_summary(applied: float) -> void:
	if session == null or return_summary_modal == null:
		return
	var lifecycle_events := session.consume_offline_lifecycle_events()
	var story_summary_text := session.consume_story_return_summary_text()
	if applied < 60.0 and lifecycle_events.is_empty() and story_summary_text.is_empty():
		return
	_refresh_ui()
	_set_care_center_open(false)
	if professor_story_open:
		_set_professor_story_open(false)
	return_summary_presenter.refresh(applied, session.get_world_weather(), session.get_daily_challenge_title(), lifecycle_events)
	if not story_summary_text.is_empty() and return_summary_label != null:
		return_summary_label.text += "\n\nVÝZKUM PROFESORA · %s" % story_summary_text
	_set_level_progression_open(false)
	return_summary_open = true
	return_summary_modal.visible = true
	return_summary_modal.move_to_front()


func _close_return_summary() -> void:
	return_summary_open = false
	return_summary_modal.visible = false


func _open_save_recovery() -> void:
	_set_level_progression_open(false)
	_set_care_center_open(false)
	save_recovery_confirm_armed = false
	save_recovery_presenter.show_initial(SaveManager.last_load_message)
	save_recovery_open = true
	save_recovery_modal.visible = true
	save_recovery_modal.move_to_front()


func _close_save_recovery() -> void:
	save_recovery_open = false
	save_recovery_modal.visible = false


func _continue_after_save_recovery() -> void:
	_close_save_recovery()
	if session == null:
		return
	if not session.intro_completed:
		call_deferred("_start_garden_handover", false)
	else:
		_show_dialog(session.get_journey_dialog_text() if not session.journey_completed else "Vítej zpět. Podívej se na hodnoty a rozhodni, co rostlina právě potřebuje.")


func _save_current_session(show_failure := true) -> bool:
	if session == null:
		return false
	var saved := SaveManager.save_session(session)
	_apply_save_result(saved, show_failure)
	return saved


func _apply_save_result(saved: bool, show_failure := true) -> void:
	if saved:
		save_failure_pending = false
		save_failure_silenced = false
		_close_save_failure()
		return
	save_failure_pending = true
	if SaveManager.writes_blocked:
		if show_failure and save_recovery_modal != null:
			_open_save_recovery()
		return
	if show_failure and not save_failure_silenced:
		_open_save_failure()


func _present_pending_save_failure() -> void:
	if save_failure_pending and not save_failure_silenced and not SaveManager.writes_blocked:
		_open_save_failure()


func _open_save_failure() -> void:
	if save_failure_modal == null:
		return
	if return_summary_open:
		_close_return_summary()
	if save_recovery_open:
		_close_save_recovery()
	save_failure_label.text = SaveManager.last_save_error_message if not SaveManager.last_save_error_message.is_empty() else "Telefon teď nedokázal zapsat uloženou hru. Poslední změny jsou zatím jen v paměti aplikace."
	save_failure_open = true
	save_failure_modal.visible = true
	save_failure_modal.move_to_front()


func _close_save_failure() -> void:
	save_failure_open = false
	if save_failure_modal != null:
		save_failure_modal.visible = false


func _open_local_backup() -> void:
	if local_backup_modal == null or SaveManager.writes_blocked:
		audio_settings_presenter.show_status("Zálohu nelze otevřít, dokud je chráněný poškozený nebo novější save.")
		return
	_set_settings_modal_open(false)
	pending_local_backup_data.clear()
	local_backup_import_armed = false
	_disarm_local_previous_game_restore()
	_disarm_local_new_game()
	local_backup_confirm_button.visible = false
	local_backup_status_label.text = "Připraveno k vytvoření nebo obnovení zálohy."
	_refresh_local_backup_info()
	_refresh_previous_game_restore_state()
	local_backup_open = true
	local_backup_modal.visible = true
	local_backup_modal.move_to_front()


func _close_local_backup() -> void:
	if external_file_picker_open:
		return
	local_backup_open = false
	local_backup_import_armed = false
	_disarm_local_previous_game_restore()
	_disarm_local_new_game()
	pending_local_backup_data.clear()
	if local_backup_modal != null:
		local_backup_modal.visible = false


func _refresh_local_backup_info() -> void:
	if local_backup_info_label == null:
		return
	var version := str(ProjectSettings.get_setting("application/config/version", "vývojová"))
	var save_text := "zatím bez potvrzeného zápisu"
	if SaveManager.last_successful_save_unix > 0.0:
		var age_seconds := maxf(0.0, Time.get_unix_time_from_system() - SaveManager.last_successful_save_unix)
		save_text = "právě teď" if age_seconds < 60.0 else "před %s" % GameSession.format_duration(age_seconds)
	local_backup_info_label.text = "VERZE %s  ·  LOKÁLNÍ HRA\nPOSLEDNÍ ULOŽENÍ · %s" % [version, save_text]


func _disarm_local_new_game() -> void:
	local_backup_new_game_armed = false
	if local_backup_new_game_button != null:
		local_backup_new_game_button.text = "ZAČÍT NOVOU HRU"


func _disarm_local_previous_game_restore() -> void:
	local_backup_restore_previous_armed = false
	if local_backup_restore_previous_button != null:
		local_backup_restore_previous_button.text = "OBNOVIT PŘEDCHOZÍ HRU"


func _refresh_previous_game_restore_state() -> void:
	if local_backup_restore_previous_button == null:
		return
	_disarm_local_previous_game_restore()
	var available := SaveManager.read_before_new_game_backup()
	local_backup_restore_previous_button.visible = bool(available.get("ok", false))
	if local_backup_restore_previous_button.visible:
		local_backup_status_label.text = "Předchozí hra je bezpečně uložená a můžeš ji obnovit."


func _confirm_restore_previous_game() -> void:
	if not local_backup_restore_previous_armed:
		var available := SaveManager.read_before_new_game_backup()
		if not bool(available.get("ok", false)):
			local_backup_restore_previous_button.visible = false
			local_backup_status_label.text = str(available.get("message", "Předchozí hra už není dostupná."))
			return
		_disarm_local_new_game()
		local_backup_import_armed = false
		pending_local_backup_data.clear()
		local_backup_confirm_button.visible = false
		var preview := GameSession.new(plant_catalog)
		preview.from_dict(available.get("data", {}) as Dictionary)
		local_backup_restore_previous_armed = true
		local_backup_restore_previous_button.text = "POTVRDIT NÁVRAT"
		local_backup_status_label.text = "PŘEDCHOZÍ HRA\nÚroveň %d · %d mincí · %d/10 rostlin\nPotvrzením nahradíš současný postup." % [preview.get_level(), preview.coins, preview.get_occupied_count()]
		return
	var result := SaveManager.restore_before_new_game_session(plant_catalog)
	if not bool(result.get("ok", false)):
		local_backup_status_label.text = str(result.get("message", "Předchozí hru se nepodařilo obnovit."))
		return
	var restored := result.get("session") as GameSession
	if restored == null:
		local_backup_status_label.text = "Předchozí hra byla uložena, ale nelze ji teď aktivovat. Po restartu se načte automaticky."
		return
	_activate_session(restored)
	_apply_save_result(true, false)
	_disarm_local_previous_game_restore()
	local_backup_restore_previous_button.visible = false
	local_backup_status_label.text = str(result.get("message", "Předchozí hra byla obnovena."))
	_refresh_local_backup_info()
	_refresh_ui()
	if audio_haptics != null:
		audio_haptics.play_ui("confirm")


func _confirm_local_new_game() -> void:
	if not local_backup_new_game_armed:
		_disarm_local_previous_game_restore()
		local_backup_import_armed = false
		pending_local_backup_data.clear()
		local_backup_confirm_button.visible = false
		local_backup_new_game_armed = true
		local_backup_new_game_button.text = "OPRAVDU ZAČÍT ZNOVU"
		local_backup_status_label.text = "TÍMTO ZAČNEŠ OD ZAČÁTKU\nPředchozí postup nejdřív uchováme v interní bezpečnostní kopii."
		return
	var fresh_session := GameSession.new(plant_catalog)
	var result := SaveManager.install_new_game_session(fresh_session)
	if not bool(result.get("ok", false)):
		local_backup_status_label.text = str(result.get("message", "Novou hru se nepodařilo připravit."))
		return
	_activate_session(fresh_session)
	_apply_save_result(true, false)
	local_backup_new_game_armed = false
	_close_local_backup()
	_change_screen(0)
	_open_room()
	_refresh_ui()
	_show_dialog("Vítej v nové zahradě.\n\n%s" % session.get_journey_dialog_text())
	call_deferred("_start_garden_handover", false)


func _choose_local_backup_export() -> void:
	_disarm_local_previous_game_restore()
	_disarm_local_new_game()
	if not DisplayServer.has_feature(DisplayServer.FEATURE_NATIVE_DIALOG_FILE):
		local_backup_status_label.text = "Toto zařízení nenabízí bezpečný systémový výběr souboru."
		return
	external_file_picker_open = true
	var filename := "bazals-pocket-garden-%s.%s" % [Time.get_date_string_from_system(), SaveManager.PORTABLE_BACKUP_EXTENSION]
	var error := DisplayServer.file_dialog_show("Uložit zálohu Bazal’s Pocket Garden", "", filename, false, DisplayServer.FILE_DIALOG_MODE_SAVE_FILE, PackedStringArray(["*.htgbackup;Bazal’s Pocket Garden backup;application/octet-stream"]), _on_local_backup_export_selected)
	if error != OK:
		external_file_picker_open = false
		local_backup_status_label.text = "Systémový výběr souboru se nepodařilo otevřít."


func _on_local_backup_export_selected(status: bool, selected_paths: PackedStringArray, _filter_index: int) -> void:
	external_file_picker_open = false
	if not status or selected_paths.is_empty():
		local_backup_status_label.text = "Vytvoření zálohy bylo zrušeno."
		return
	var result := SaveManager.export_portable_backup_to_path(session, selected_paths[0])
	local_backup_status_label.text = str(result.get("message", "Zálohu se nepodařilo vytvořit."))
	if bool(result.get("ok", false)) and audio_haptics != null:
		audio_haptics.play_ui("confirm")


func _choose_local_backup_import() -> void:
	_disarm_local_previous_game_restore()
	_disarm_local_new_game()
	if not DisplayServer.has_feature(DisplayServer.FEATURE_NATIVE_DIALOG_FILE):
		local_backup_status_label.text = "Toto zařízení nenabízí bezpečný systémový výběr souboru."
		return
	external_file_picker_open = true
	var error := DisplayServer.file_dialog_show("Vybrat zálohu Bazal’s Pocket Garden", "", "", false, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, PackedStringArray(["*.htgbackup,*.htgbackup.json;Bazal’s Pocket Garden backup;application/octet-stream,application/json"]), _on_local_backup_import_selected)
	if error != OK:
		external_file_picker_open = false
		local_backup_status_label.text = "Systémový výběr souboru se nepodařilo otevřít."


func _on_local_backup_import_selected(status: bool, selected_paths: PackedStringArray, _filter_index: int) -> void:
	external_file_picker_open = false
	_disarm_local_previous_game_restore()
	_disarm_local_new_game()
	local_backup_import_armed = false
	pending_local_backup_data.clear()
	local_backup_confirm_button.visible = false
	if not status or selected_paths.is_empty():
		local_backup_status_label.text = "Obnovení zálohy bylo zrušeno."
		return
	var result := SaveManager.read_portable_backup_from_path(selected_paths[0])
	if not bool(result.get("ok", false)):
		local_backup_status_label.text = str(result.get("message", "Záloha není platná."))
		return
	pending_local_backup_data = (result.get("data", {}) as Dictionary).duplicate(true)
	var preview_session := GameSession.new(plant_catalog)
	preview_session.from_dict(pending_local_backup_data)
	local_backup_status_label.text = "NALEZENA ZÁLOHA\nÚroveň %d · %d mincí · %d/10 rostlin\nPotvrzením nahradíš aktuální postup." % [preview_session.get_level(), preview_session.coins, preview_session.get_occupied_count()]
	local_backup_import_armed = true
	local_backup_confirm_button.visible = true


func _confirm_local_backup_import() -> void:
	if not local_backup_import_armed or pending_local_backup_data.is_empty():
		return
	_disarm_local_previous_game_restore()
	_disarm_local_new_game()
	var restored := GameSession.new(plant_catalog)
	restored.from_dict(pending_local_backup_data)
	var install_result := SaveManager.install_portable_session(restored)
	if not bool(install_result.get("ok", false)):
		local_backup_status_label.text = str(install_result.get("message", "Zálohu se nepodařilo obnovit."))
		return
	_activate_session(restored)
	_apply_save_result(true, false)
	local_backup_import_armed = false
	pending_local_backup_data.clear()
	local_backup_confirm_button.visible = false
	local_backup_status_label.text = str(install_result.get("message", "Záloha byla obnovena a bezpečně uložena."))
	_refresh_ui()
	if audio_haptics != null:
		audio_haptics.play_ui("confirm")


func _retry_failed_save() -> void:
	save_failure_silenced = false
	if _save_current_session(true):
		_close_save_failure()
	else:
		save_failure_label.text = SaveManager.last_save_error_message


func _continue_without_saving() -> void:
	save_failure_silenced = true
	_close_save_failure()


func _confirm_new_game_after_recovery() -> void:
	if not save_recovery_confirm_armed:
		save_recovery_confirm_armed = true
		save_recovery_presenter.show_confirmation()
		return
	if not SaveManager.discard_unreadable_save_for_new_game():
		save_recovery_presenter.show_delete_failure()
		return
	var fresh_session := GameSession.new(plant_catalog)
	_activate_session(fresh_session)
	_save_current_session()
	call_deferred("_start_garden_handover", false)
	_close_save_recovery()
	_refresh_ui()


func _activate_session(next_session: GameSession) -> void:
	session = next_session
	session.event_created.connect(_show_dialog)
	session.feedback_requested.connect(_on_session_feedback)
	session.journey_changed.connect(_on_journey_changed)
	session.slot_unlocked.connect(_on_slot_unlocked)
	session.fast_time_guard_triggered.connect(_on_fast_time_guard_triggered)
	session.story_progressed.connect(_on_professor_story_progressed)
	session.story_chapter_changed.connect(_on_professor_story_chapter_changed)
	plant_view.set_simulation(session.plant)
	room_overview.set_session(session)
	_apply_audio_settings()
	_apply_motion_preference()


func _set_daily_challenge_open(opening: bool) -> void:
	if daily_challenge_modal == null:
		return
	if opening and botanical_pack_open:
		_set_botanical_pack_open(false)
	if opening and care_center_open:
		_set_care_center_open(false)
	if opening and level_progression_open:
		_set_level_progression_open(false)
	if opening and dialog_open:
		_set_guide_modal_open(false, false)
	if opening and settings_modal_open:
		_set_settings_modal_open(false)
	if opening and seed_selector_open:
		_set_seed_selector_open(false)
	if opening and herbarium_open:
		_set_herbarium_open(false)
	if opening and cosmetic_modal_open:
		_set_cosmetic_modal_open(false)
	daily_challenge_open = opening
	daily_challenge_modal.visible = opening
	if opening:
		daily_challenge_modal.move_to_front()
		_refresh_daily_challenge()
	if audio_haptics != null:
		audio_haptics.play_ui("tap")


func _set_botanical_pack_open(opening: bool) -> void:
	if botanical_pack_modal == null:
		return
	if opening and care_center_open:
		_set_care_center_open(false)
	if opening and level_progression_open:
		_set_level_progression_open(false)
	if opening and dialog_open:
		_set_guide_modal_open(false, false)
	if opening and settings_modal_open:
		_set_settings_modal_open(false)
	if opening and seed_selector_open:
		_set_seed_selector_open(false)
	if opening and herbarium_open:
		_set_herbarium_open(false)
	if opening and daily_challenge_open:
		_set_daily_challenge_open(false)
	if opening and cosmetic_modal_open:
		_set_cosmetic_modal_open(false)
	botanical_pack_open = opening
	botanical_pack_modal.visible = opening
	if opening:
		botanical_pack_last_reward.clear()
		botanical_pack_reward_icon.texture = NavPlantIcon
		botanical_pack_reward_icon.modulate = Color.WHITE
		botanical_pack_modal.move_to_front()
		_refresh_botanical_pack()
	if audio_haptics != null:
		audio_haptics.play_ui("tap")


func _refresh_daily_challenge() -> void:
	if session == null or daily_challenge_title_label == null:
		return
	session.refresh_daily_challenge_context()
	daily_challenge_presenter.refresh(session)
	if botanical_pack_launcher_button != null:
		var pack_count := session.get_botanical_pack_count() if session.has_method("get_botanical_pack_count") else 0
		botanical_pack_launcher_button.text = "BOTANICKÉ BALÍČKY · %d" % pack_count
	_refresh_phase161_daily_challenge_visual()


func _refresh_phase161_daily_challenge_visual() -> void:
	if session == null:
		return
	if daily_challenge_context_visual != null:
		daily_challenge_context_visual.configure(
			session.daily_challenge_id,
			session.daily_challenge_weather,
			session.daily_challenge_forecast_weather
		)
	var target_available := session.get_daily_challenge_target_slot() >= 0
	var state := "active"
	if session.daily_challenge_claimed:
		state = "claimed"
	elif session.daily_challenge_completed:
		state = "ready"
	elif not target_available:
		state = "no_target"
	if daily_challenge_modal != null:
		daily_challenge_modal.set_meta("phase161_presented_state", state)
		daily_challenge_modal.set_meta("phase161_challenge_id", session.daily_challenge_id)
	if daily_challenge_action_state_overlay != null and daily_challenge_action_button != null:
		daily_challenge_action_state_overlay.visible = daily_challenge_action_button.disabled
	if daily_challenge_claim_state_overlay != null and daily_challenge_claim_button != null:
		daily_challenge_claim_state_overlay.visible = not daily_challenge_claim_button.disabled
		var claim_color := ComicUITheme.CREAM if not daily_challenge_claim_button.disabled else Color("#fff2c4", 0.88)
		for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
			daily_challenge_claim_button.add_theme_color_override(color_name, claim_color)


func _get_botanical_pack_odds_text() -> String:
	if session == null or not session.has_method("get_botanical_pack_odds"):
		return "SKUTEČNÉ ŠANCE NEJSOU DOSTUPNÉ"
	var odds: Dictionary = session.get_botanical_pack_odds()
	var parts: Array[String] = []
	for rarity_id in session.plant_rarity_catalog.get_order():
		var chance := float(odds.get(rarity_id, 0.0))
		if chance <= 0.0:
			continue
		parts.append("%s %.1f %%" % [session.plant_rarity_catalog.get_label(rarity_id), chance])
	if parts.is_empty():
		return "ŽÁDNÝ DRUH NENÍ V BALÍČKU DOSTUPNÝ"
	return "SKUTEČNÉ ŠANCE · %s\nSPECIÁLNÍ · POUZE PŘÍBĚH A UDÁLOSTI" % " · ".join(parts)


func _get_botanical_pack_pity_text(state: Dictionary) -> String:
	if int(state.get("eligible_species_count", 0)) <= 0:
		return "V BĚŽNÉM BALÍČKU TEĎ NENÍ DOSTUPNÝ ŽÁDNÝ DRUH"
	if int(state.get("ungranted_new_species_count", 0)) <= 0:
		return "VŠECHNY NOVÉ DRUHY JSOU OBJEVENÉ NEBO ČEKAJÍ V BALÍČKU"
	if bool(state.get("next_grant_guaranteed_new", false)):
		return "DALŠÍ BALÍČEK ZARUČENĚ OBSAHUJE NOVÝ DRUH"
	var duplicates_left := maxi(1, int(state.get("duplicates_until_guaranteed_new", 4)))
	return "OCHRANA OBJEVU · JEŠTĚ NEJVÝŠ %d DUPLIKÁTY, POTOM NOVÝ DRUH" % duplicates_left


func _refresh_botanical_pack() -> void:
	if session == null or botanical_pack_count_label == null:
		return
	var state: Dictionary = session.get_botanical_pack_state() if session.has_method("get_botanical_pack_state") else {}
	var pack_count := int(state.get("count", session.get_botanical_pack_count() if session.has_method("get_botanical_pack_count") else 0))
	var can_open := bool(state.get("can_open", pack_count > 0)) and not botanical_pack_opening
	botanical_pack_presenter.refresh(pack_count, _get_botanical_pack_odds_text(), _get_botanical_pack_pity_text(state), can_open, str(state.get("blocked_reason", "")), botanical_pack_last_reward)
	if botanical_pack_launcher_button != null:
		botanical_pack_launcher_button.text = "BOTANICKÉ BALÍČKY · %d" % pack_count


func _on_botanical_pack_opened() -> void:
	if session == null or botanical_pack_opening:
		return
	var state: Dictionary = session.get_botanical_pack_state()
	var pack_id := int(state.get("next_openable_pack_id", -1))
	if pack_id < 0:
		_refresh_botanical_pack()
		return
	botanical_pack_opening = true
	botanical_pack_open_button.disabled = true
	var reward: Dictionary = session.open_botanical_pack(pack_id)
	if reward.is_empty():
		botanical_pack_opening = false
		_refresh_botanical_pack()
		return
	var species_id := str(reward.get("species_id", ""))
	var reward_profile := session.get_plant_profile(species_id)
	var rarity := session.get_species_rarity_definition(species_id)
	botanical_pack_last_reward = reward.duplicate(true)
	botanical_pack_last_reward["display_name"] = str(reward_profile.get("ui_name", reward_profile.get("display_name", "Neznámá bylina")))
	botanical_pack_last_reward["rarity_label"] = str(rarity.get("label", "BĚŽNÁ"))
	botanical_pack_last_reward["rarity_stars"] = int(rarity.get("stars", 1))
	botanical_pack_last_reward["new_discovery"] = bool(reward.get("newly_discovered", false))
	botanical_pack_reward_icon.texture = _species_preview_texture(species_id)
	botanical_pack_reward_icon.modulate = Color.WHITE
	botanical_pack_reward_rarity_label.add_theme_color_override("font_color", Color(str(rarity.get("color_hex", "#76D91D"))).darkened(0.22))
	_save_current_session()
	_refresh_ui()
	_refresh_botanical_pack()
	if audio_haptics != null:
		audio_haptics.play_feedback("journey_complete")
	if session.reduced_motion:
		_finish_botanical_pack_reveal()
		return
	botanical_pack_reward_icon.scale = Vector2(0.78, 0.78)
	botanical_pack_reward_icon.pivot_offset = botanical_pack_reward_icon.size * 0.5
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(botanical_pack_reward_icon, "scale", Vector2.ONE, 0.34)
	tween.tween_callback(_finish_botanical_pack_reveal)


func _finish_botanical_pack_reveal() -> void:
	botanical_pack_opening = false
	if botanical_pack_reward_icon != null:
		botanical_pack_reward_icon.scale = Vector2.ONE
	_refresh_botanical_pack()


func _on_daily_challenge_action_requested() -> void:
	if session == null:
		return
	session.refresh_daily_challenge_context()
	var target_slot := session.get_daily_challenge_target_slot()
	if target_slot < 0 or not session.select_plant(target_slot):
		_refresh_daily_challenge()
		return
	var challenge_id := session.daily_challenge_id
	var target_screen := session.get_daily_challenge_target_screen()
	_set_daily_challenge_open(false)
	_change_screen(target_screen)
	if target_screen == 0:
		_open_plant_detail(target_slot)
		if challenge_id == "plant" and session.plant.stage == PlantSimulation.Stage.EMPTY:
			_set_seed_selector_open(true)


func _on_daily_reward_claimed() -> void:
	if not session.claim_daily_challenge_reward():
		return
	_save_current_session()
	_refresh_ui()
	_refresh_daily_challenge()
	if audio_haptics != null:
		audio_haptics.play_feedback("journey_complete")


func _open_level_progression() -> void:
	_set_level_progression_open(true)


func _close_level_progression() -> void:
	_set_level_progression_open(false)


func _set_level_progression_open(opening: bool) -> void:
	if level_progression_modal == null:
		return
	if opening and grower_journal_open:
		_set_grower_journal_open(false)
	if opening and care_center_open:
		_set_care_center_open(false)
	if opening and save_recovery_open:
		return
	if opening and dialog_open:
		_set_guide_modal_open(false, false)
	if opening and settings_modal_open:
		_set_settings_modal_open(false)
	if opening and seed_selector_open:
		_set_seed_selector_open(false)
	if opening and herbarium_open:
		_set_herbarium_open(false)
	if opening and daily_challenge_open:
		_set_daily_challenge_open(false)
	if opening and cosmetic_modal_open:
		_set_cosmetic_modal_open(false)
	if opening and return_summary_open:
		_close_return_summary()
	level_progression_open = opening
	level_progression_modal.visible = opening
	if opening:
		level_progression_modal.move_to_front()
		_refresh_level_progression()
	if audio_haptics != null:
		audio_haptics.play_ui("tap")


func _refresh_level_progression() -> void:
	if session == null or level_progression_summary_label == null:
		return
	level_progression_presenter.refresh(session)


func _on_level_reward_claimed(reward_level: int) -> void:
	if not session.claim_level_reward(reward_level):
		_refresh_level_progression()
		return
	_save_current_session()
	_refresh_ui()
	level_progression_presenter.show_claimed(reward_level)


func _open_grower_journal() -> void:
	_set_grower_journal_open(true)


func _close_grower_journal() -> void:
	_set_grower_journal_open(false)
	_set_level_progression_open(true)


func _set_grower_journal_open(opening: bool) -> void:
	if grower_journal_modal == null:
		return
	if opening and save_recovery_open:
		return
	if opening and dialog_open:
		_set_guide_modal_open(false, false)
	if opening and settings_modal_open:
		_set_settings_modal_open(false)
	if opening and seed_selector_open:
		_set_seed_selector_open(false)
	if opening and herbarium_open:
		_set_herbarium_open(false)
	if opening and daily_challenge_open:
		_set_daily_challenge_open(false)
	if opening and level_progression_open:
		_set_level_progression_open(false)
	if opening and care_center_open:
		_set_care_center_open(false)
	if opening and cosmetic_modal_open:
		_set_cosmetic_modal_open(false)
	if opening and return_summary_open:
		_close_return_summary()
	grower_journal_open = opening
	grower_journal_modal.visible = opening
	if opening:
		grower_journal_scroll.scroll_vertical = 0
		grower_journal_modal.move_to_front()
		_refresh_grower_journal()
	if audio_haptics != null:
		audio_haptics.play_ui("tap")


func _refresh_grower_journal() -> void:
	if session == null or grower_journal_summary_label == null:
		return
	grower_journal_presenter.refresh(session.get_grower_journal_snapshot())


func _open_care_center() -> void:
	_set_care_center_open(true)


func _close_care_center() -> void:
	_set_care_center_open(false)


func _set_care_center_open(opening: bool) -> void:
	if care_center_modal == null:
		return
	if opening and save_recovery_open:
		return
	if opening and dialog_open:
		_set_guide_modal_open(false, false)
	if opening and settings_modal_open:
		_set_settings_modal_open(false)
	if opening and seed_selector_open:
		_set_seed_selector_open(false)
	if opening and herbarium_open:
		_set_herbarium_open(false)
	if opening and daily_challenge_open:
		_set_daily_challenge_open(false)
	if opening and level_progression_open:
		_set_level_progression_open(false)
	if opening and cosmetic_modal_open:
		_set_cosmetic_modal_open(false)
	if opening and return_summary_open:
		_close_return_summary()
	care_center_open = opening
	care_center_modal.visible = opening
	if opening:
		care_center_scroll.scroll_vertical = 0
		care_center_modal.move_to_front()
		_refresh_care_center()
	if audio_haptics != null:
		audio_haptics.play_ui("tap")


func _refresh_care_center() -> void:
	if session == null or care_center_summary_label == null:
		return
	care_center_presenter.refresh(session, care_notification_service.get_ui_state(session))
	_refresh_care_notification_test()
	if not fast_time_guard_pending.is_empty():
		_show_fast_time_guard_status(fast_time_guard_pending)


func _open_plant_diagnosis() -> void:
	_set_plant_diagnosis_open(true)


func _close_plant_diagnosis() -> void:
	_set_plant_diagnosis_open(false)


func _set_plant_diagnosis_open(opening: bool) -> void:
	if plant_diagnosis_modal == null:
		return
	if opening and (save_recovery_open or save_failure_open or local_backup_open):
		return
	if opening and dialog_open:
		_set_guide_modal_open(false, false)
	if opening and settings_modal_open:
		_set_settings_modal_open(false)
	if opening and seed_selector_open:
		_set_seed_selector_open(false)
	if opening and herbarium_open:
		_set_herbarium_open(false)
	if opening and daily_challenge_open:
		_set_daily_challenge_open(false)
	if opening and level_progression_open:
		_set_level_progression_open(false)
	if opening and grower_journal_open:
		_set_grower_journal_open(false)
	if opening and care_center_open:
		_set_care_center_open(false)
	if opening and cosmetic_modal_open:
		_set_cosmetic_modal_open(false)
	if opening and return_summary_open:
		_close_return_summary()
	plant_diagnosis_open = opening
	plant_diagnosis_modal.visible = opening
	if opening:
		plant_diagnosis_scroll.scroll_vertical = 0
		plant_diagnosis_modal.move_to_front()
		_refresh_plant_diagnosis()
	if audio_haptics != null:
		audio_haptics.play_ui("tap")


func _refresh_plant_diagnosis() -> void:
	if session == null or plant_diagnosis_summary_label == null:
		return
	plant_diagnosis_presenter.refresh(plant_diagnosis_service.build_snapshot(session.plant, session.world_elapsed_seconds))


func _on_plant_diagnosis_action_pressed() -> void:
	if session == null or plant_diagnosis_action_button == null:
		return
	var action_id := str(plant_diagnosis_action_button.get_meta("diagnosis_action_id", "return"))
	_set_plant_diagnosis_open(false)
	match action_id:
		"prune", "clear":
			_navigate_to_diagnosis_detail_target(seed_button)
		"seed":
			if _has_any_seed_available():
				_open_seed_selector()
			else:
				_navigate_to_diagnosis_shop_target("supplies", buy_seed_button)
		"storage":
			_change_screen(1)
		"measurement":
			_change_screen(3)
		"fertilize":
			if session.fertilizer_doses > 0:
				_navigate_to_diagnosis_detail_target(fertilizer_button)
			else:
				_navigate_to_diagnosis_shop_target("supplies", buy_fertilizer_button)
		"treat":
			if session.get_equipment_level("protective_spray") > 0:
				_navigate_to_diagnosis_detail_target(vent_button)
			else:
				_navigate_to_diagnosis_shop_target("equipment", shop_equipment_buttons.get("protective_spray") as Control)
		"water":
			_navigate_to_diagnosis_detail_target(water_button)
		"lamp":
			_navigate_to_diagnosis_detail_target(lamp_button)
		"ventilate":
			_navigate_to_diagnosis_detail_target(vent_button)
		_:
			pass


func _has_any_seed_available() -> bool:
	if session == null:
		return false
	for species_id in session.plant_profiles.keys():
		if session.get_seed_count(str(species_id)) > 0:
			return true
	return false


func _navigate_to_diagnosis_detail_target(target: Control) -> void:
	_change_screen(0)
	_open_plant_detail(session.selected_plant_index)
	if target != null:
		call_deferred("_play_success_pulse", target)


func _navigate_to_diagnosis_shop_target(category: String, target: Control) -> void:
	_set_shop_category(category)
	_change_screen(2)
	if target != null:
		call_deferred("_play_success_pulse", target)


func _refresh_care_notification_test() -> void:
	if care_center_notification_test_button == null:
		return
	var available := care_notification_service.is_system_available()
	care_center_notification_test_button.visible = available
	if not available:
		return
	if care_notification_test_pending and care_notification_service.get_scheduled_at_millis() <= 0:
		care_notification_test_pending = false
	var permitted := care_notification_service.has_permission()
	care_center_notification_test_button.disabled = not permitted or care_notification_test_pending
	care_center_notification_test_button.text = "TEST NAPLÁNOVÁN · PŘEJDI NA PLOCHU" if care_notification_test_pending else ("OVĚŘIT UPOZORNĚNÍ ZA 20 S" if permitted else "NEJPRVE POVOL UPOZORNĚNÍ")
	if care_notification_test_pending:
		care_center_status_label.text = "Teď přejdi na plochu telefonu. Testovací upozornění dorazí přibližně za 20 sekund."


func _on_care_notification_test_pressed() -> void:
	if session == null or care_notification_test_pending:
		return
	if care_notification_service.should_request_permission(session):
		care_notification_service.request_permission()
		care_center_status_label.text = "Povol oznámení v Androidu a potom test spusť znovu."
		_refresh_care_notification_test()
		return
	var result: Dictionary = care_notification_service.schedule_test_reminder()
	care_notification_test_pending = bool(result.get("scheduled", false))
	if not care_notification_test_pending:
		care_center_status_label.text = "Test se nepodařilo naplánovat. Zkontroluj systémové povolení oznámení."
	_refresh_care_notification_test()
	if audio_haptics != null:
		audio_haptics.play_ui("confirm" if care_notification_test_pending else "error")


func _consume_care_notification_destination() -> bool:
	if session == null or save_recovery_open or save_failure_open or local_backup_open or plant_diagnosis_open:
		return false
	var slot_index := care_notification_service.consume_opened_slot_index()
	if slot_index < 0 or slot_index >= session.plants.size():
		return false
	_on_care_destination_pressed(slot_index)
	return true


func _on_care_reminders_toggled() -> void:
	if session == null:
		return
	if care_notification_service.should_request_permission(session):
		care_notification_service.request_permission()
	else:
		session.set_care_reminders_enabled(not session.care_reminders_enabled)
		if not session.care_reminders_enabled:
			care_notification_service.cancel_system_reminder()
	_save_current_session()
	_refresh_care_center()
	if audio_haptics != null:
		audio_haptics.play_ui("confirm")


func _on_fast_time_guard_triggered(slot_index: int, reason: String, target: String) -> void:
	fast_time_guard_pending = {
		"slot_index": slot_index,
		"reason": reason,
		"target": target,
	}
	_refresh_ui()
	if care_center_open:
		if slot_index >= 0 and slot_index < session.plants.size():
			session.select_plant(slot_index)
		_show_fast_time_guard_status(fast_time_guard_pending)
		fast_time_guard_pending.clear()


func _check_fast_time_guard_after_load() -> void:
	if session != null:
		session.check_fast_time_guard_now()


func _present_fast_time_guard() -> void:
	if session == null or fast_time_guard_pending.is_empty():
		return
	var pending := fast_time_guard_pending.duplicate(true)
	var slot_index := int(pending.get("slot_index", -1))
	if slot_index >= 0 and slot_index < session.plants.size():
		session.select_plant(slot_index)
	_set_care_center_open(true)
	_show_fast_time_guard_status(pending)
	fast_time_guard_pending.clear()
	_save_current_session(false)


func _show_fast_time_guard_status(pending: Dictionary) -> void:
	if care_center_status_label == null:
		return
	var slot_index := int(pending.get("slot_index", 0))
	var reason := str(pending.get("reason", "Rostlina potřebuje kontrolu"))
	care_center_status_label.text = "RYCHLÁ SIMULACE POZASTAVENA · KVĚTINÁČ %d · %s." % [slot_index + 1, reason]
	care_center_status_label.add_theme_color_override("font_color", ComicUITheme.ORANGE)


func _on_care_destination_pressed(slot_index: int) -> void:
	if session == null or not session.select_plant(slot_index):
		care_center_presenter.show_navigation_error("Tento květináč zatím není odemčený.")
		return
	var target := "detail"
	for entry in session.get_care_center_entries():
		if int(entry.get("slot_index", -1)) == slot_index:
			target = str(entry.get("target", "detail"))
			break
	_set_care_center_open(false)
	if target == "storage":
		_change_screen(1)
		_refresh_ui()
	else:
		_change_screen(0)
		_open_plant_detail(slot_index)
	if audio_haptics != null:
		audio_haptics.play_ui("confirm")


func _refresh_herbarium() -> void:
	if session == null or herbarium_summary_label == null:
		return
	herbarium_presenter.refresh(session)


func _on_mastery_reward_claimed(species_id: String) -> void:
	if not session.claim_mastery_reward(species_id):
		herbarium_presenter.show_reward_locked()
		return
	_save_current_session()
	_refresh_ui()
	var tier := int(session.get_species_progress(species_id).get("claimed_tier", 1))
	herbarium_presenter.show_reward_claimed(str(session.get_plant_profile(species_id).get("short_name", "Bylinka")), str(session.get_mastery_tier_data(tier).get("title", "")))
	if audio_haptics != null:
		audio_haptics.play_feedback("journey_complete")


func _refresh_seed_selector() -> void:
	if session == null or seed_species_buttons.is_empty():
		return
	seed_selector_presenter.refresh(session)


func _on_seed_species_selected(species_id: String) -> void:
	if session.plant_seed(species_id):
		_set_seed_selector_open(false)
		_save_and_refresh()
		if audio_haptics != null:
			audio_haptics.play_ui("confirm")
	else:
		_refresh_seed_selector()


func _on_music_toggled(enabled: bool) -> void:
	if session == null:
		return
	session.music_enabled = enabled
	_commit_audio_settings("Hudba %s." % ("hraje" if enabled else "je vypnutá"))


func _on_sfx_toggled(enabled: bool) -> void:
	if session == null:
		return
	session.sfx_enabled = enabled
	_commit_audio_settings("Herní zvuky %s." % ("jsou zapnuté" if enabled else "jsou vypnuté"))


func _on_haptics_toggled(enabled: bool) -> void:
	if session == null:
		return
	session.haptics_enabled = enabled
	_commit_audio_settings("Jemná vibrace %s." % ("je zapnutá" if enabled else "je vypnutá"))


func _on_settings_motion_toggled(full_motion: bool) -> void:
	if session == null:
		return
	session.reduced_motion = not full_motion
	_apply_motion_preference()
	_commit_audio_settings("Animace %s." % ("běží naplno" if full_motion else "jsou omezené"))


func _on_music_volume_changed(value: float) -> void:
	if session == null:
		return
	session.music_volume = value / 100.0
	_commit_audio_settings("Hlasitost hudby: %d %%" % roundi(value), false)


func _on_sfx_volume_changed(value: float) -> void:
	if session == null:
		return
	session.sfx_volume = value / 100.0
	_commit_audio_settings("Hlasitost efektů: %d %%" % roundi(value), false)


func _commit_audio_settings(message: String, play_confirmation := true) -> void:
	_apply_audio_settings()
	_save_current_session()
	audio_settings_presenter.show_status(message)
	if play_confirmation and audio_haptics != null:
		audio_haptics.play_ui("confirm")


func _apply_audio_settings() -> void:
	if audio_haptics == null or session == null:
		return
	audio_haptics.apply_settings(session.music_enabled, session.sfx_enabled, session.haptics_enabled, session.music_volume, session.sfx_volume)
	_refresh_audio_settings()


func _refresh_audio_settings() -> void:
	if session == null:
		return
	audio_settings_presenter.refresh(
		session.music_enabled,
		session.sfx_enabled,
		session.haptics_enabled,
		session.reduced_motion,
		session.music_volume,
		session.sfx_volume
	)


func _open_professor_story() -> void:
	_set_professor_story_open(true)


func _close_professor_story() -> void:
	_set_professor_story_open(false)


func _set_professor_story_open(opening: bool) -> void:
	if professor_story_modal == null or session == null:
		return
	if opening and (save_recovery_open or save_failure_open or is_garden_handover_active):
		return
	if opening and not session.is_professor_story_unlocked():
		return
	if opening and dialog_open:
		_set_guide_modal_open(false, false)
	if opening and settings_modal_open:
		_set_settings_modal_open(false)
	if opening and seed_selector_open:
		_set_seed_selector_open(false)
	if opening and herbarium_open:
		_set_herbarium_open(false)
	if opening and botanical_pack_open:
		_set_botanical_pack_open(false)
	if opening and daily_challenge_open:
		_set_daily_challenge_open(false)
	if opening and level_progression_open:
		_set_level_progression_open(false)
	if opening and grower_journal_open:
		grower_journal_open = false
		grower_journal_modal.visible = false
	if opening and care_center_open:
		_set_care_center_open(false)
	if opening and plant_diagnosis_open:
		_set_plant_diagnosis_open(false)
	if opening and cosmetic_modal_open:
		_set_cosmetic_modal_open(false)
	if opening and return_summary_open:
		_close_return_summary()
	professor_story_open = opening
	professor_story_modal.visible = opening
	if opening:
		var hub_state: Dictionary = session.get_professor_hub_state()
		professor_story_content_mode = "weekly_research" if _is_professor_research_state(hub_state) else "story_chapter"
		var content_state := _get_professor_story_content_state()
		var marked_seen := false
		if professor_story_content_mode == "weekly_research":
			marked_seen = session.mark_professor_hub_seen(int(content_state.get("cycle_id", -1)))
		else:
			var expected_chapter_id := str(content_state.get("chapter_id", "")).strip_edges()
			marked_seen = session.mark_professor_story_seen(expected_chapter_id)
		if marked_seen:
			_save_current_session()
		professor_story_scroll.scroll_vertical = 0
		professor_story_modal.move_to_front()
		_refresh_professor_story()
	_refresh_professor_story_badges()
	if audio_haptics != null:
		audio_haptics.play_ui("tap")


func _refresh_professor_story() -> void:
	if session == null or professor_story_modal == null or not professor_story_presenter.is_bound():
		return
	var view_state: Dictionary = professor_story_presenter.refresh(_get_professor_story_content_state())
	professor_story_action = view_state.get("action", {}) as Dictionary
	professor_story_modal.set_meta("active_presentation_mode", professor_story_content_mode)


func _get_professor_story_content_state() -> Dictionary:
	if session == null:
		return {}
	if professor_story_content_mode == "weekly_research":
		var hub_state: Dictionary = session.get_professor_hub_state()
		if _is_professor_research_state(hub_state):
			return hub_state
	return session.get_professor_story_state()


func _is_professor_research_state(state: Dictionary) -> bool:
	return str(state.get("content_kind", "")).strip_edges().to_lower() == "weekly_research" \
		or str(state.get("mode", "")).strip_edges().to_lower() == "research"


func _refresh_professor_story_badges() -> void:
	if session == null:
		return
	# Keep the claimed finale visually complete for the remainder of the open
	# story presentation. Closing the modal immediately falls back to hub
	# attention and reveals the unread weekly offer on both Professor launchers.
	var story_unlocked := session.is_professor_story_unlocked()
	var badge_visible := story_unlocked and session.has_professor_hub_attention()
	if professor_story_open and professor_story_content_mode == "story_chapter":
		badge_visible = session.has_professor_story_attention()
	for badge in professor_story_badges:
		if badge != null:
			badge.visible = badge_visible
	if dialog_toggle_button != null:
		TooltipPolicy.apply(dialog_toggle_button, "Zobrazit nápovědu")
	if detail_dialog_toggle_button != null:
		TooltipPolicy.apply(detail_dialog_toggle_button, "Zobrazit nápovědu")
	if professor_research_launcher_button != null:
		professor_research_launcher_button.visible = true
		professor_research_launcher_button.disabled = false
		professor_research_launcher_button.modulate = Color.WHITE
		professor_research_launcher_button.set_meta("research_locked", not story_unlocked)
		TooltipPolicy.apply(
			professor_research_launcher_button,
			"Otevřít Profesorův výzkum" if story_unlocked else "Profesorův výzkum se odemkne po předání zahrady"
		)
	if professor_research_launcher_icon != null:
		professor_research_launcher_icon.visible = true
		professor_research_launcher_icon.modulate = Color.WHITE if story_unlocked else Color(0.80, 0.80, 0.80, 0.96)
	if professor_research_lock_badge != null:
		professor_research_lock_badge.visible = not story_unlocked


func _on_professor_story_action_pressed() -> void:
	if session == null or not professor_story_open:
		return
	var target_action := str(professor_story_action.get("target_action", "")).strip_edges()
	if bool(professor_story_action.get("disabled", false)) or target_action in ["", "none", "pack_unavailable"]:
		_refresh_professor_story()
		return
	var expected_chapter_id := str(professor_story_action.get("expected_chapter_id", "")).strip_edges()
	if target_action == "claim_reward":
		_claim_professor_story_reward(expected_chapter_id)
		return
	var expected_cycle_id := int(professor_story_action.get("expected_cycle_id", professor_story_action.get("cycle_id", -1)))
	if target_action in ["start_research", "accept_professor_research"]:
		_start_professor_research(expected_cycle_id)
		return
	if target_action in ["claim_research_reward", "claim_professor_research_reward"]:
		_claim_professor_research_reward(expected_cycle_id)
		return
	var target_screen := int(professor_story_action.get("target_screen", -1))
	_close_professor_story()
	match target_action:
		"room":
			_change_screen(0)
			_open_room()
		"storage":
			_change_screen(1)
			if storage_scroll != null:
				storage_scroll.scroll_vertical = 0
		"orders":
			_change_screen(1)
			call_deferred("_scroll_professor_story_destination_to_orders")
		"herbarium":
			_set_herbarium_open(true)
		"daily":
			_set_daily_challenge_open(true)
		"botanical_packs":
			_set_botanical_pack_open(true)
		"seed_capacity":
			_open_professor_story_seed_capacity_destination()
		_:
			if target_screen >= 0 and target_screen < screens.size():
				_change_screen(target_screen)


func _scroll_professor_story_destination_to_orders() -> void:
	if storage_scroll == null:
		return
	storage_scroll.scroll_vertical = roundi(minf(620.0, maxf(0.0, storage_scroll.get_v_scroll_bar().max_value - storage_scroll.size.y)))


func _open_professor_story_seed_capacity_destination() -> void:
	_change_screen(0)
	_open_room()
	for slot_index in range(session.plants.size()):
		if session.plants[slot_index].stage != PlantSimulation.Stage.EMPTY:
			continue
		if not session.select_plant(slot_index):
			continue
		_open_plant_detail(slot_index)
		_set_seed_selector_open(true)
		return


func _claim_professor_story_reward(expected_chapter_id: String) -> void:
	if session == null:
		return
	var result := session.claim_professor_story_reward(expected_chapter_id)
	if not bool(result.get("success", false)):
		var reason := str(result.get("reason", "unknown")).strip_edges().to_lower()
		if reason in ["already_claimed", "chapter_changed", "stale_chapter"]:
			_refresh_ui()
			_refresh_professor_story()
			_refresh_professor_story_badges()
			return
		professor_story_presenter.show_claim_failure(reason)
		_refresh_professor_story_badges()
		return
	_save_current_session()
	_refresh_ui()
	professor_story_scroll.scroll_vertical = 0
	_refresh_professor_story()
	_refresh_professor_story_badges()
	if feedback_layer != null:
		feedback_layer.play_feedback("journey_complete", Vector2(0.50, 0.48), 1.10)
	if audio_haptics != null:
		audio_haptics.play_feedback("journey_complete", result)


func _start_professor_research(expected_cycle_id: int) -> void:
	if session == null:
		return
	var result := session.start_professor_research(expected_cycle_id)
	if not bool(result.get("success", false)):
		var reason := str(result.get("reason", "unknown")).strip_edges().to_lower()
		if reason in ["already_active", "already_claimed", "stale_cycle"]:
			professor_story_content_mode = "weekly_research"
			_refresh_professor_story()
			_refresh_professor_story_badges()
			return
		professor_story_presenter.show_claim_failure(reason)
		return
	_save_current_session()
	professor_story_scroll.scroll_vertical = 0
	_refresh_ui()
	_refresh_professor_story()
	_refresh_professor_story_badges()


func _claim_professor_research_reward(expected_cycle_id: int) -> void:
	if session == null:
		return
	var result := session.claim_professor_research_reward(expected_cycle_id)
	if not bool(result.get("success", false)):
		var reason := str(result.get("reason", "unknown")).strip_edges().to_lower()
		if reason in ["already_claimed", "stale_cycle", "incomplete"]:
			_refresh_ui()
			_refresh_professor_story()
			_refresh_professor_story_badges()
			return
		professor_story_presenter.show_claim_failure(reason)
		_refresh_professor_story_badges()
		return
	_save_current_session()
	_refresh_ui()
	professor_story_scroll.scroll_vertical = 0
	_refresh_professor_story()
	_refresh_professor_story_badges()


func _on_professor_story_progressed(_event: Dictionary) -> void:
	_refresh_professor_story_badges()
	if professor_story_open:
		_refresh_professor_story()


func _on_professor_story_chapter_changed(_chapter_id: String, _state: Dictionary) -> void:
	_refresh_professor_story_badges()
	if professor_story_open:
		_refresh_professor_story()


func _toggle_guide_dialog(primary: bool) -> void:
	if is_garden_handover_active:
		return
	if not dialog_open and session != null:
		_show_dialog(session.get_journey_dialog_text())
	_set_guide_modal_open(not dialog_open, not session.reduced_motion)


func _toggle_professor_research() -> void:
	if is_garden_handover_active or session == null or not session.is_professor_story_unlocked():
		return
	_set_professor_story_open(not professor_story_open)


func _on_professor_research_launcher_pressed() -> void:
	if session == null or is_garden_handover_active:
		return
	if not session.is_professor_story_unlocked():
		_show_dialog("Profesorův výzkum se odemkne po dokončení předání zahrady.")
		_set_guide_modal_open(true, not session.reduced_motion)
		return
	_toggle_professor_research()


func _set_guide_modal_open(opening: bool, animate: bool) -> void:
	if guide_modal == null or guide_modal_character == null or guide_modal_card == null:
		return
	if opening and care_center_open:
		_set_care_center_open(false)
	if opening and level_progression_open:
		_set_level_progression_open(false)
	if opening and herbarium_open:
		_set_herbarium_open(false)
	if opening and daily_challenge_open:
		_set_daily_challenge_open(false)
	if opening and professor_story_open:
		_set_professor_story_open(false)
	animate = animate and (session == null or not session.reduced_motion)
	if dialog_tween != null and dialog_tween.is_valid():
		dialog_tween.kill()
	_reset_guide_modal_layout()
	dialog_open = opening
	detail_dialog_open = opening
	if opening:
		if settings_modal_open:
			_set_settings_modal_open(false)
		guide_modal.visible = true
		guide_modal.modulate.a = 1.0
		guide_modal.move_to_front()
		var character_final := guide_modal_character.position
		var card_final := guide_modal_card.position
		guide_modal_character.pivot_offset = guide_modal_character.size * Vector2(0.5, 0.82)
		guide_modal_card.pivot_offset = guide_modal_card.size * Vector2(0.5, 0.5)
		if not animate:
			_set_guide_modal_visual_state(true)
			return
		guide_modal_character.position = character_final + GUIDE_MODAL_CHARACTER_OFFSET
		guide_modal_character.scale = Vector2(0.92, 0.92)
		guide_modal_character.modulate.a = 0.0
		guide_modal_card.position = card_final + GUIDE_MODAL_CARD_OFFSET
		guide_modal_card.modulate.a = 0.0
		guide_modal_name_badge.modulate.a = 0.0
		guide_modal_close_button.modulate.a = 0.0
		guide_modal_dimmer.modulate.a = 0.0
		guide_modal_character.play_entry()
		dialog_tween = create_tween().set_parallel(true)
		dialog_tween.tween_property(guide_modal_dimmer, "modulate:a", 1.0, 0.22)
		dialog_tween.tween_property(guide_modal_character, "position", character_final, GUIDE_MODAL_DURATION).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		dialog_tween.tween_property(guide_modal_character, "scale", Vector2.ONE, GUIDE_MODAL_DURATION).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		dialog_tween.tween_property(guide_modal_character, "modulate:a", 1.0, 0.20)
		var card_move := dialog_tween.tween_property(guide_modal_card, "position", card_final, 0.28).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		card_move.set_delay(0.06)
		dialog_tween.tween_property(guide_modal_card, "modulate:a", 1.0, 0.18).set_delay(0.06)
		dialog_tween.tween_property(guide_modal_name_badge, "modulate:a", 1.0, 0.16).set_delay(0.11)
		dialog_tween.tween_property(guide_modal_close_button, "modulate:a", 1.0, 0.16).set_delay(0.11)
		dialog_tween.finished.connect(_reset_guide_modal_layout)
	else:
		if not animate:
			_set_guide_modal_visual_state(false)
			return
		dialog_tween = create_tween().set_parallel(true)
		dialog_tween.tween_property(guide_modal, "modulate:a", 0.0, 0.20)
		dialog_tween.tween_property(guide_modal_character, "scale", Vector2(0.96, 0.96), 0.20)
		dialog_tween.finished.connect(_set_guide_modal_visual_state.bind(false))


func _set_guide_modal_visual_state(opened: bool) -> void:
	_reset_guide_modal_layout()
	guide_modal.visible = opened
	guide_modal.modulate.a = 1.0
	guide_modal_dimmer.modulate.a = 1.0
	guide_modal_card.modulate.a = 1.0
	guide_modal_name_badge.modulate.a = 1.0
	guide_modal_close_button.modulate.a = 1.0
	guide_modal_character.modulate.a = 1.0
	guide_modal_character.scale = Vector2.ONE
	if not opened:
		guide_modal_character.resume_live_animation()


func _reset_guide_modal_layout() -> void:
	# Position tweens change Control offsets. Always restore the anchor-derived
	# rest layout so deferred intro animation timing cannot affect captures or
	# a later modal opening on slower mobile devices.
	for control in [guide_modal_character, guide_modal_card]:
		if control == null:
			continue
		control.offset_left = 0.0
		control.offset_top = 0.0
		control.offset_right = 0.0
		control.offset_bottom = 0.0


func _close_guide_modal() -> void:
	_set_guide_modal_open(false, true)


func _on_guide_modal_dimmer_input(event: InputEvent) -> void:
	if is_garden_handover_active:
		return
	if event is InputEventScreenTouch and event.pressed:
		_close_guide_modal()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_close_guide_modal()


func _icon_action_button(text_value: String, callback: Callable, icon_texture: Texture2D, background_texture: Texture2D, text_color := Color("#fffdf4")) -> Button:
	var button := _action_button("", callback)
	TooltipPolicy.apply(button, text_value)
	button.custom_minimum_size.y = 68
	var fill := DETAIL_BLUE
	if background_texture == ButtonGreenTexture:
		fill = DETAIL_GREEN
	elif background_texture == ButtonYellowTexture:
		fill = DETAIL_GOLD
	elif background_texture == ButtonPurpleTexture:
		fill = DETAIL_PURPLE
	elif background_texture == ButtonTealTexture:
		fill = Color("#1abdc5")
	_apply_comic_button_style(button, fill, text_color, 12)
	button.set_meta("component", "comic_mobile_action_v1")
	button.set_meta("touch_target_min_height", 68)

	var content := HBoxContainer.new()
	content.name = "ActionContent"
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.offset_left = 6.0
	content.offset_top = 5.0
	content.offset_right = -6.0
	content.offset_bottom = -5.0
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 1)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(content)

	var icon := TextureRect.new()
	icon.texture = icon_texture
	icon.custom_minimum_size = Vector2(29, 29)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.set_meta("presentation", "high_readability_action_icon")
	content.add_child(icon)

	var label := Label.new()
	label.text = text_value
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.clip_text = true
	label.add_theme_font_override("font", FontSemiBold)
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", text_color)
	label.add_theme_color_override("font_shadow_color", Color("#0b1520", 0.45))
	label.add_theme_constant_override("shadow_offset_y", 1)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(label)

	button.set_meta("action_label", label)
	button.set_meta("action_icon", icon)
	button.set_meta("action_content", content)
	return button


func _build_measurement_screen() -> Control:
	var margin := _screen_margin()
	margin.set_meta("phase5_screen", "measurement_v1")
	margin.set_meta("ui_kit", "comic_ui_v1")
	margin.set_meta("phase128_style_parity", VisualDesignSystem.PLANTS_STYLE_PARITY_ID)
	margin.set_meta("phase128_style_reference", VisualDesignSystem.PLANTS_STYLE_REFERENCE_ID)
	margin.set_meta("phase128_style_refinement", VisualDesignSystem.PLANTS_STYLE_REFINEMENT_ID)
	margin.set_meta("phase154_runtime_set", VisualDesignSystem.MEASUREMENT_PHASE154_RUNTIME_SET_ID)
	margin.set_meta("phase154_scene_profile", VisualDesignSystem.MEASUREMENT_PHASE154_SCENE_PROFILE_ID)
	margin.set_meta("phase154_dynamic_policy", "live_sensor_values_graph_knowledge_and_scroll_preserved_v1")
	_add_phase128_screen_backdrop(margin, Phase128MeasurementBackdrop, "measurement")
	measurement_scroll = ScrollContainer.new()
	measurement_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	measurement_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	measurement_scroll.set_meta("component", "painted_measurement_scroll_phase154_v1")
	measurement_scroll.set_meta("phase154_runtime_set", VisualDesignSystem.MEASUREMENT_PHASE154_RUNTIME_SET_ID)
	margin.add_child(measurement_scroll)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 10)
	measurement_scroll.add_child(column)
	measurement_hero_panel = _build_phase128_screen_hero(Phase128MeasurementBackdrop, "MĚŘENÍ PROSTŘEDÍ", "Živé senzory vybrané rostliny", ComicUITheme.PURPLE, "measurement")
	measurement_hero_panel.set_meta("phase154_component", "painted_botanical_lab_hero_v1")
	measurement_hero_panel.set_meta("phase154_source_asset", "measurement_corner_background")
	column.add_child(measurement_hero_panel)
	var legacy_header := _screen_header("MĚŘENÍ PROSTŘEDÍ", "Živé senzory vybrané rostliny a posledních 72 záznamů.", ComicUITheme.PURPLE)
	legacy_header.visible = false
	legacy_header.set_meta("phase128_legacy_fallback", true)
	phase128_legacy_headers.append(legacy_header)
	column.add_child(legacy_header)
	var sensor_banner := Label.new()
	sensor_banner.text = "●  SENZORY ONLINE   ·   hodnoty se aktualizují každých 0,25 s"
	sensor_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sensor_banner.add_theme_font_override("font", FontSemiBold)
	sensor_banner.add_theme_font_size_override("font_size", 11)
	sensor_banner.add_theme_color_override("font_color", ComicUITheme.NAVY)
	_register_phase128_label_surface(sensor_banner, "status_ribbon", ComicUITheme.CYAN)
	sensor_banner.set_meta("phase154_component", "painted_sensor_status_ribbon_v1")
	column.add_child(sensor_banner)
	measurement_metric_grid = GridContainer.new()
	measurement_metric_grid.columns = 2
	measurement_metric_grid.add_theme_constant_override("h_separation", 7)
	measurement_metric_grid.add_theme_constant_override("v_separation", 7)
	measurement_metric_grid.set_meta("component", "painted_measurement_metric_grid_phase154_v1")
	for card_data in [
		["temperature", "TEPLOTA", ComicUITheme.ORANGE], ["humidity", "VLHKOST VZDUCHU", ComicUITheme.CYAN],
		["ph", "PH SUBSTRÁTU", ComicUITheme.PURPLE], ["ec", "VODIVOST EC", ComicUITheme.GOLD],
		["light", "OSVĚTLENÍ", ComicUITheme.GOLD], ["co2", "CO₂ U LISTU", ComicUITheme.BLUE],
		["oxygen", "O₂ V PROSTŘEDÍ", ComicUITheme.CYAN], ["oxygen_balance", "BILANCE O₂", ComicUITheme.GREEN],
		["biomass", "BIOMASA", ComicUITheme.GREEN], ["weather", "POČASÍ", ComicUITheme.ORANGE],
	]:
		metric_labels[card_data[0]] = _add_measurement_card(measurement_metric_grid, card_data[0], card_data[1], card_data[2])
	column.add_child(measurement_metric_grid)
	var graph_panel := PanelContainer.new()
	graph_panel.custom_minimum_size.y = 272
	var graph_legacy_style := ComicUITheme.style_box(Color("#e8fbfa"), ComicUITheme.CYAN, 3, 14, ComicUITheme.SHADOW, 3, 6.0)
	_register_phase128_surface(graph_panel, graph_legacy_style, "information_card", ComicUITheme.CYAN)
	graph_panel.set_meta("component", "comic_sensor_graph_card_v1")
	graph_panel.set_meta("phase154_component", "painted_72h_sensor_graph_card_v1")
	graph_panel.set_meta("phase154_runtime_set", VisualDesignSystem.MEASUREMENT_PHASE154_RUNTIME_SET_ID)
	metric_graph = MetricGraphScene.new()
	metric_graph.custom_minimum_size = Vector2(0, 255)
	graph_panel.add_child(metric_graph)
	column.add_child(graph_panel)
	var note := Label.new()
	note.text = "Graf ukazuje, jak světlo mění fotosyntézu, spotřebu CO₂, bilanci O₂ a tvorbu biomasy. Hodnoty výměny plynů jsou modelový odhad, ne měření celého pokoje."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override("font_size", 12)
	note.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(note)
	column.add_child(_screen_header("PĚSTITELSKÁ NÁPOVĚDA", "Krátké vysvětlení hodnot a ověřené zdroje.", ComicUITheme.GREEN))
	var knowledge_panel := PanelContainer.new()
	var knowledge_legacy_style := ComicUITheme.style_box(ComicUITheme.PAPER, ComicUITheme.GREEN, 3, 14, ComicUITheme.SHADOW, 3, 10.0)
	_register_phase128_surface(knowledge_panel, knowledge_legacy_style, "information_card", ComicUITheme.GREEN)
	knowledge_panel.set_meta("component", "comic_knowledge_card_v1")
	source_label = RichTextLabel.new()
	source_label.bbcode_enabled = true
	source_label.fit_content = true
	source_label.scroll_active = false
	source_label.custom_minimum_size.y = 670
	source_label.add_theme_font_size_override("normal_font_size", 14)
	source_label.add_theme_font_size_override("bold_font_size", 16)
	source_label.add_theme_color_override("default_color", ComicUITheme.INK)
	source_label.meta_clicked.connect(_on_link_clicked)
	source_label.text = _knowledge_text()
	knowledge_panel.add_child(source_label)
	column.add_child(knowledge_panel)
	measurement_presenter.bind(metric_labels, metric_graph, source_label, plant_presentation_catalog)
	_configure_mobile_scroll(measurement_scroll, column, "measurement")
	return margin


func _build_storage_screen() -> Control:
	var margin := _screen_margin()
	margin.set_meta("phase5_screen", "storage_v1")
	margin.set_meta("ui_kit", "comic_ui_v1")
	margin.set_meta("phase128_style_parity", VisualDesignSystem.PLANTS_STYLE_PARITY_ID)
	margin.set_meta("phase128_style_reference", VisualDesignSystem.PLANTS_STYLE_REFERENCE_ID)
	margin.set_meta("phase128_style_refinement", VisualDesignSystem.PLANTS_STYLE_REFINEMENT_ID)
	margin.set_meta("phase152_runtime_set", VisualDesignSystem.STORAGE_PHASE152_RUNTIME_SET_ID)
	margin.set_meta("phase152_scene_profile", VisualDesignSystem.STORAGE_PHASE152_SCENE_PROFILE_ID)
	margin.set_meta("phase152_reference_asset", VisualDesignSystem.STORAGE_PHASE152_TARGET_ASSET)
	_add_phase128_screen_backdrop(margin, Phase128StorageBackdrop, "storage")
	storage_scroll = ScrollContainer.new()
	storage_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	storage_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	storage_scroll.set_meta("component", "mobile_storage_scroll_v1")
	margin.add_child(storage_scroll)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 10)
	storage_scroll.add_child(column)
	var scene_hero := _build_phase128_screen_hero(Phase128StorageBackdrop, "SKLAD A ZPRACOVÁNÍ", "Od sklizně přes sušení až k prodeji", ComicUITheme.ORANGE, "storage")
	scene_hero.custom_minimum_size.y = 280
	scene_hero.set_meta("phase152_workshop_hero", true)
	column.add_child(scene_hero)
	var legacy_header := _screen_header("SKLAD A ZPRACOVÁNÍ", "Zásoby a cesta bazalky od sklizně až k prodeji.", ComicUITheme.BLUE)
	legacy_header.visible = false
	legacy_header.set_meta("phase128_legacy_fallback", true)
	phase128_legacy_headers.append(legacy_header)
	column.add_child(legacy_header)
	inventory_label = Label.new()
	inventory_label.text = "AKTUÁLNÍ ZÁSOBY"
	inventory_label.add_theme_font_override("font", FontExtraBold)
	inventory_label.add_theme_font_size_override("font_size", 13)
	inventory_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	inventory_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_register_phase128_label_surface(inventory_label, "status_ribbon", ComicUITheme.ORANGE)
	column.add_child(inventory_label)
	var inventory_grid := GridContainer.new()
	inventory_grid.columns = 3
	inventory_grid.add_theme_constant_override("h_separation", 6)
	inventory_value_labels.seeds = _build_inventory_card(inventory_grid, "SEMÍNKA", NavPlantIcon, ComicUITheme.GREEN)
	inventory_value_labels.fertilizer = _build_inventory_card(inventory_grid, "HNOJIVO", FertilizerIcon, ComicUITheme.PURPLE)
	inventory_value_labels.harvests = _build_inventory_card(inventory_grid, "SKLIZNĚ", NavStorageIcon, ComicUITheme.GOLD)
	column.add_child(inventory_grid)
	storage_inventory_presenter.bind(inventory_label, inventory_value_labels)

	var harvest_panel := PanelContainer.new()
	harvest_panel.custom_minimum_size.y = 330
	var harvest_legacy_style := ComicUITheme.style_box(Color("#fff5ce"), ComicUITheme.ORANGE, 3, 15, ComicUITheme.SHADOW, 4, 10.0)
	_register_phase128_surface(harvest_panel, harvest_legacy_style, "primary_work_surface", ComicUITheme.ORANGE)
	harvest_panel.set_meta("component", "comic_harvest_pipeline_v1")
	var harvest_column := VBoxContainer.new()
	harvest_column.alignment = BoxContainer.ALIGNMENT_CENTER
	harvest_column.add_theme_constant_override("separation", 10)
	harvest_panel.add_child(harvest_column)
	var process_title := Label.new()
	process_title.text = "CESTA ÚRODY"
	process_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	process_title.add_theme_font_override("font", FontExtraBold)
	process_title.add_theme_font_size_override("font_size", 20)
	process_title.add_theme_color_override("font_color", ComicUITheme.INK)
	harvest_column.add_child(process_title)
	var steps := GridContainer.new()
	steps.columns = 4
	steps.add_theme_constant_override("h_separation", 4)
	for step_text in ["1  SKLIDIT", "2  SUŠIT", "3  ZABALIT", "4  PRODAT"]:
		var step_panel := PanelContainer.new()
		step_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		step_panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#dbe7e8"), ComicUITheme.INK, 2, 9, Color.TRANSPARENT, 0, 3.0))
		var step_label := Label.new()
		step_label.text = step_text
		step_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		step_label.add_theme_font_override("font", FontExtraBold)
		step_label.add_theme_font_size_override("font_size", 8)
		step_label.add_theme_color_override("font_color", Color("#65717a"))
		step_panel.add_child(step_label)
		steps.add_child(step_panel)
		storage_step_labels.append(step_label)
	harvest_column.add_child(steps)
	storage_progress_bar = ProgressBar.new()
	storage_progress_bar.max_value = 100.0
	storage_progress_bar.show_percentage = false
	storage_progress_bar.custom_minimum_size.y = 22
	ComicUITheme.apply_progress(storage_progress_bar, ComicUITheme.GREEN, Color("#174f56"), ComicUITheme.INK, 9)
	harvest_column.add_child(storage_progress_bar)
	harvest_label = Label.new()
	harvest_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	harvest_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	harvest_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	harvest_label.custom_minimum_size.y = 82
	harvest_label.add_theme_font_override("font", FontSemiBold)
	harvest_label.add_theme_font_size_override("font_size", 14)
	harvest_label.add_theme_color_override("font_color", ComicUITheme.INK)
	harvest_column.add_child(harvest_label)
	storage_action_button = _action_button("Čekám na sklizeň", _on_storage_action)
	storage_action_button.custom_minimum_size.y = 68
	storage_action_button.add_theme_font_override("font", FontExtraBold)
	storage_action_button.add_theme_font_size_override("font_size", 15)
	ComicUITheme.apply_button(storage_action_button, ComicUITheme.GREEN, ComicUITheme.INK, 13)
	storage_action_button.set_meta("component", "comic_primary_pipeline_action_v1")
	storage_action_button.set_meta("touch_target_min_height", 68)
	harvest_column.add_child(storage_action_button)
	storage_pipeline_presenter.bind(harvest_label, storage_action_button, storage_progress_bar, storage_step_labels)
	column.add_child(harvest_panel)
	customer_orders_panel = _build_customer_orders_panel()
	column.add_child(customer_orders_panel)
	_configure_mobile_scroll(storage_scroll, column, "storage")
	return margin


func _build_customer_orders_panel() -> CustomerOrdersPanel:
	var board := CustomerOrdersPanelScene.new() as CustomerOrdersPanel
	board.order_pressed.connect(_on_order_pressed)
	board.order_decline_pressed.connect(_on_order_decline_pressed)
	order_card_panels = board.card_panels
	order_customer_labels = board.customer_labels
	order_requirement_labels = board.requirement_labels
	order_reward_labels = board.reward_labels
	order_buttons = board.action_buttons
	order_decline_buttons = board.decline_buttons
	return board


func _build_shop_screen() -> Control:
	var margin := _screen_margin()
	margin.set_meta("phase5_screen", "shop_v1")
	margin.set_meta("ui_kit", "comic_ui_v1")
	margin.set_meta("component", "botanist_shop_mobile_v1")
	margin.set_meta("phase128_style_parity", VisualDesignSystem.PLANTS_STYLE_PARITY_ID)
	shop_scroll = ScrollContainer.new()
	shop_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	shop_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shop_scroll.set_meta("component", "botanist_shop_scroll_v1")
	shop_scroll.visible = false
	margin.add_child(shop_scroll)
	shop_column = VBoxContainer.new()
	shop_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shop_column.add_theme_constant_override("separation", 10)
	shop_scroll.add_child(shop_column)
	shop_legacy_header = _screen_header("PĚSTITELSKÝ OBCHOD", "Doplň zásoby za herní mince. Žádné nákupy za skutečné peníze.", ComicUITheme.ORANGE)
	shop_column.add_child(shop_legacy_header)
	var balance_panel := PanelContainer.new()
	balance_panel.custom_minimum_size.y = 62
	balance_panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff3b5"), ComicUITheme.GOLD, 3, 13, ComicUITheme.SHADOW, 3, 7.0))
	var balance_row := HBoxContainer.new()
	balance_row.alignment = BoxContainer.ALIGNMENT_CENTER
	balance_row.add_theme_constant_override("separation", 9)
	balance_panel.add_child(balance_row)
	var balance_icon := TextureRect.new()
	balance_icon.texture = CoinTexture
	balance_icon.custom_minimum_size = Vector2(42, 42)
	balance_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	balance_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	balance_row.add_child(balance_icon)
	shop_legacy_balance_label = Label.new()
	shop_legacy_balance_label.add_theme_font_override("font", FontExtraBold)
	shop_legacy_balance_label.add_theme_font_size_override("font_size", 18)
	shop_legacy_balance_label.add_theme_color_override("font_color", ComicUITheme.INK)
	balance_row.add_child(shop_legacy_balance_label)
	shop_column.add_child(balance_panel)

	var seed_card := _build_shop_item_card("SEMÍNKO BAZALKY", "Nový pěstitelský cyklus", "BĚŽNÉ", int(profile.get("seed_price", 12)), NavPlantIcon, ComicUITheme.GREEN, _on_buy_seed)
	shop_legacy_owned_labels.seeds = seed_card.owned
	shop_column.add_child(seed_card.root)
	var fertilizer_card := _build_shop_item_card("DÁVKA HNOJIVA", "Doplní živiny, zvyšuje EC", "PĚSTITELSKÁ POMŮCKA", 8, FertilizerIcon, ComicUITheme.PURPLE, _on_buy_fertilizer)
	shop_legacy_owned_labels.fertilizer = fertilizer_card.owned
	shop_column.add_child(fertilizer_card.root)
	var mint_profile: Dictionary = plant_catalog.get("mint_peppermint", {})
	var mint_card := _build_shop_item_card("SEMÍNKO MÁTY", "Svěží druh s vyšší cenou sklizně", "NOVÝ DRUH", int(mint_profile.get("seed_price", 15)), preload("res://assets/plants/comic/mint_sprout_v1.png"), ComicUITheme.CYAN, _on_buy_mint_seed)
	mint_shop_card = mint_card.root
	shop_column.add_child(mint_shop_card)
	var rosemary_profile: Dictionary = plant_catalog.get("rosemary_officinalis", {})
	var rosemary_card := _build_shop_item_card("SEMÍNKO ROZMARÝNU", "Odolná voňavá bylina pro střídmější zálivku", "VZÁCNÝ DRUH", int(rosemary_profile.get("seed_price", 18)), _species_preview_texture("rosemary_officinalis"), ComicUITheme.PURPLE, _on_buy_species_seed.bind("rosemary_officinalis"))
	rosemary_shop_card = rosemary_card.root
	shop_column.add_child(rosemary_shop_card)
	var oregano_profile: Dictionary = plant_catalog.get("oregano_vulgare", {})
	var oregano_card := _build_shop_item_card("SEMÍNKO OREGANA", "Slunná aromatická bylina s drobnými lístky", "STŘEDOMOŘSKÝ DRUH", int(oregano_profile.get("seed_price", 20)), _species_preview_texture("oregano_vulgare"), ComicUITheme.ORANGE, _on_buy_species_seed.bind("oregano_vulgare"))
	oregano_shop_card = oregano_card.root
	shop_column.add_child(oregano_shop_card)
	_build_botanist_runtime_shop(margin)
	_configure_mobile_scroll(shop_scroll, shop_column, "shop_legacy")
	_configure_mobile_scroll(shop_catalog_scroll, shop_catalog_grid, "shop_catalog")
	_set_shop_mode("buy")
	return margin


func _configure_mobile_scroll(scroll: ScrollContainer, content_root: Control, scroll_id: String) -> void:
	if scroll == null or content_root == null:
		return
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.scroll_deadzone = 6
	scroll.follow_focus = false
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	if not scroll.has_meta("component"):
		scroll.set_meta("component", "mobile_vertical_scroll_v1")
	scroll.set_meta("mobile_scroll_contract", "mobile_vertical_scroll_v1")
	scroll.set_meta("scroll_id", scroll_id)
	scroll.set_meta("touch_drag_enabled", true)
	_set_scroll_descendant_passthrough(content_root)


func _set_scroll_descendant_passthrough(node: Node) -> void:
	for child in node.get_children():
		if child is Control:
			var control := child as Control
			if control.mouse_filter == Control.MOUSE_FILTER_STOP:
				control.mouse_filter = Control.MOUSE_FILTER_PASS
		_set_scroll_descendant_passthrough(child)


func _build_botanist_runtime_shop(parent: Control) -> void:
	shop_runtime_layout = VBoxContainer.new()
	shop_runtime_layout.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shop_runtime_layout.add_theme_constant_override("separation", 5)
	shop_runtime_layout.set_meta("component", "botanist_shop_counter_catalog_phase153_v1")
	shop_runtime_layout.set_meta("phase128_style_parity", VisualDesignSystem.PLANTS_STYLE_PARITY_ID)
	shop_runtime_layout.set_meta("phase153_runtime_set", VisualDesignSystem.SHOP_PHASE153_RUNTIME_SET_ID)
	shop_runtime_layout.set_meta("phase153_scene_profile", VisualDesignSystem.SHOP_PHASE153_SCENE_PROFILE_ID)
	shop_runtime_layout.set_meta("phase153_dynamic_policy", "wallet_stock_catalog_categories_buy_sell_equipment_scroll_v1")
	parent.add_child(shop_runtime_layout)
	shop_hero_panel = _build_botanist_shop_hero()
	shop_runtime_layout.add_child(shop_hero_panel)
	var wallet := PanelContainer.new()
	wallet.custom_minimum_size.y = 46
	wallet.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff1bd"), Color("#c77922"), 3, 10, ComicUITheme.SHADOW, 3, 4.0))
	wallet.set_meta("phase153_component", "painted_wallet_ribbon_v1")
	var wallet_row := HBoxContainer.new()
	wallet_row.alignment = BoxContainer.ALIGNMENT_CENTER
	wallet_row.add_theme_constant_override("separation", 7)
	wallet.add_child(wallet_row)
	var wallet_icon := TextureRect.new()
	wallet_icon.texture = CoinTexture
	wallet_icon.custom_minimum_size = Vector2(34, 34)
	wallet_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	wallet_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	wallet_row.add_child(wallet_icon)
	shop_balance_label = Label.new()
	shop_balance_label.add_theme_font_override("font", FontExtraBold)
	shop_balance_label.add_theme_font_size_override("font_size", 16)
	shop_balance_label.add_theme_color_override("font_color", ComicUITheme.INK)
	wallet_row.add_child(shop_balance_label)
	shop_runtime_layout.add_child(wallet)
	shop_catalog_scroll = ScrollContainer.new()
	shop_catalog_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	shop_catalog_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	shop_catalog_scroll.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#713b1d"), Color("#3b2415"), 2, 8, Color("#1b0d06", 0.48), 2, 3.0))
	shop_catalog_scroll.set_meta("component", "botanist_catalog_scroll_phase153_v1")
	shop_catalog_scroll.set_meta("phase153_background", "warm_wood_catalog_ground_v1")
	shop_runtime_layout.add_child(shop_catalog_scroll)
	shop_catalog_grid = GridContainer.new()
	shop_catalog_grid.columns = 3
	shop_catalog_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shop_catalog_grid.add_theme_constant_override("h_separation", 6)
	shop_catalog_grid.add_theme_constant_override("v_separation", 6)
	shop_catalog_grid.set_meta("component", "botanist_catalog_grid_3x_phase153_v1")
	shop_catalog_scroll.add_child(shop_catalog_grid)
	shop_seed_buttons.clear()
	shop_owned_labels.clear()
	for species_id in session.get_botanist_shop_species_ids():
		var species_profile: Dictionary = plant_catalog.get(species_id, {})
		if species_profile.is_empty():
			continue
		var seed_price := int(species_profile.get("seed_price", 0))
		var species_tile := _build_shop_catalog_tile(
			str(species_profile.get("short_name", species_profile.get("ui_name", species_id))).to_upper(),
			seed_price,
			_species_preview_texture(species_id),
			_species_accent(species_id),
			_botanist_seed_buy_callback(species_id),
			session.get_species_rarity_definition(species_id)
		)
		species_tile.root.set_meta("shop_category", "seeds")
		species_tile.root.set_meta("species_id", species_id)
		species_tile.root.set_meta("shop_description", plant_presentation_catalog.shop_description(species_id))
		species_tile.root.set_meta("shop_badge", plant_presentation_catalog.shop_badge(species_id))
		var species_button := species_tile.button as Button
		species_button.set_meta("shop_item_id", session.get_shop_seed_item_id(species_id))
		shop_seed_buttons[species_id] = species_button
		shop_owned_labels[species_id] = species_tile.owned
		shop_buy_cards.append(species_tile.root)
		shop_catalog_grid.add_child(species_tile.root)
	buy_seed_button = shop_seed_buttons.get("basil_genovese") as Button
	buy_mint_seed_button = shop_seed_buttons.get("mint_peppermint") as Button
	buy_rosemary_seed_button = shop_seed_buttons.get("rosemary_officinalis") as Button
	buy_oregano_seed_button = shop_seed_buttons.get("oregano_vulgare") as Button
	var fertilizer_tile := _build_shop_catalog_tile("HNOJIVO", 8, FertilizerIcon, ComicUITheme.PURPLE, _on_buy_fertilizer)
	fertilizer_tile.root.set_meta("shop_category", "supplies")
	buy_fertilizer_button = fertilizer_tile.button
	buy_fertilizer_button.set_meta("shop_item_id", GameSession.SHOP_FERTILIZER_ITEM_ID)
	shop_owned_labels.fertilizer = fertilizer_tile.owned
	shop_buy_cards.append(fertilizer_tile.root)
	shop_catalog_grid.add_child(fertilizer_tile.root)
	_add_equipment_shop_tile("watering_can", WaterIcon, ComicUITheme.BLUE)
	_add_equipment_shop_tile("grow_lamp", SunIcon, ComicUITheme.GOLD)
	_add_equipment_shop_tile("ventilation_fan", WindIcon, ComicUITheme.CYAN)
	_add_equipment_shop_tile("protective_spray", FertilizerIcon, ComicUITheme.PURPLE)
	_add_equipment_shop_tile("self_watering_pot", NavPlantIcon, ComicUITheme.ORANGE)
	shop_sell_panel = _build_botanist_sell_panel()
	shop_sell_panel.visible = false
	shop_runtime_layout.add_child(shop_sell_panel)
	shop_feedback_label = Label.new()
	shop_feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	shop_feedback_label.custom_minimum_size.y = 24
	shop_feedback_label.add_theme_font_size_override("font_size", 9)
	shop_feedback_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	shop_runtime_layout.add_child(shop_feedback_label)
	var categories := HBoxContainer.new()
	shop_mode_tabs = categories
	categories.custom_minimum_size.y = 58
	categories.add_theme_constant_override("separation", 4)
	categories.set_meta("component", "botanist_shop_category_tabs_phase153_v1")
	categories.set_meta("phase153_touch_tabs", true)
	shop_runtime_layout.add_child(categories)
	shop_buy_tab_button = _build_shop_category_button("NABÍDKA", "all")
	categories.add_child(shop_buy_tab_button)
	var supplies_button := _build_shop_category_button("POMŮCKY", "supplies")
	shop_category_buttons["supplies"] = supplies_button
	categories.add_child(supplies_button)
	var equipment_button := _build_shop_category_button("VYBAVENÍ", "equipment")
	shop_category_buttons["equipment"] = equipment_button
	categories.add_child(equipment_button)
	shop_sell_tab_button = _build_shop_category_button("VÝKUP", "sell")
	categories.add_child(shop_sell_tab_button)
	var runtime_buy_buttons := shop_seed_buttons.duplicate()
	runtime_buy_buttons["fertilizer"] = buy_fertilizer_button
	botanist_shop_presenter.bind_buy_view(
		shop_balance_label,
		shop_legacy_balance_label,
		shop_owned_labels,
		shop_legacy_owned_labels,
		runtime_buy_buttons
	)
	botanist_shop_presenter.bind_mode_view(shop_buy_cards, shop_catalog_scroll, shop_sell_panel, shop_buy_tab_button, shop_sell_tab_button, shop_category_buttons, shop_feedback_label)
	botanist_shop_presenter.bind_sell_view(shop_sell_icon, shop_sell_title_label, shop_sell_details_label, shop_sell_offer_label, shop_sell_button)
	botanist_shop_presenter.bind_message_view(shop_merchant_dialog_label)


func _botanist_seed_buy_callback(species_id: String) -> Callable:
	match species_id:
		"basil_genovese":
			return _on_buy_seed
		"mint_peppermint":
			return _on_buy_mint_seed
		_:
			return _on_buy_species_seed.bind(species_id)


func _build_shop_category_button(label_text: String, mode: String) -> Button:
	var button := Button.new()
	button.text = label_text
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size.y = 58
	button.set_meta("touch_target_min_height", 58)
	button.set_meta("shop_mode", "sell" if mode == "sell" else "buy")
	button.set_meta("shop_category", mode)
	if mode == "sell":
		button.pressed.connect(_set_shop_mode.bind("sell"))
	else:
		button.pressed.connect(_set_shop_category.bind(mode))
	ComicUITheme.apply_button(button, Color("#fff3c4"), ComicUITheme.INK, 10, ComicUITheme.INK, 3)
	return button


func _set_shop_category(category: String) -> void:
	shop_category = category if category in ["all", "supplies", "equipment"] else "all"
	if shop_catalog_grid != null:
		shop_catalog_grid.columns = 2 if shop_category == "equipment" else 3
	_set_shop_mode("buy")


func _build_botanist_shop_hero() -> Control:
	var hero := Control.new()
	hero.custom_minimum_size.y = 245
	hero.clip_contents = true
	hero.set_meta("component", "botanist_shopkeeper_counter_phase153_v1")
	hero.set_meta("phase128_style_parity", VisualDesignSystem.PLANTS_STYLE_PARITY_ID)
	hero.set_meta("phase153_runtime_set", VisualDesignSystem.SHOP_PHASE153_RUNTIME_SET_ID)
	hero.set_meta("phase153_composition", "integrated_sign_merchant_counter_and_dialog_v1")
	var frame := PanelContainer.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#74401f"), Color("#302016"), 4, 14, ComicUITheme.SHADOW, 4, 8.0))
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero.add_child(frame)
	shop_merchant_scene = TextureRect.new()
	shop_merchant_scene.texture = BotanistShopSceneTexture
	shop_merchant_scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shop_merchant_scene.offset_left = 4
	shop_merchant_scene.offset_top = 4
	shop_merchant_scene.offset_right = -4
	shop_merchant_scene.offset_bottom = -4
	shop_merchant_scene.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shop_merchant_scene.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	shop_merchant_scene.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	shop_merchant_scene.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shop_merchant_scene.set_meta("phase153_asset_profile", "shop_merchant_background")
	hero.add_child(shop_merchant_scene)
	var name_badge := PanelContainer.new()
	name_badge.set_anchor(SIDE_LEFT, 0.025)
	name_badge.set_anchor(SIDE_TOP, 0.045)
	name_badge.set_anchor(SIDE_RIGHT, 0.46)
	name_badge.set_anchor(SIDE_BOTTOM, 0.34)
	name_badge.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#0f6064"), Color("#d59a31"), 4, 12, Color("#1a0d07", 0.52), 3, 5.0))
	name_badge.set_meta("phase153_component", "integrated_painted_shop_sign_v1")
	var name_label := Label.new()
	name_label.text = "OBCHOD\nU PANA KOŘÍNKA"
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.add_theme_font_override("font", FontExtraBold)
	name_label.add_theme_font_size_override("font_size", 13)
	name_label.add_theme_color_override("font_color", Color("#fff0bd"))
	name_badge.add_child(name_label)
	hero.add_child(name_badge)
	var dialog_badge := PanelContainer.new()
	dialog_badge.set_anchor(SIDE_LEFT, 0.12)
	dialog_badge.set_anchor(SIDE_TOP, 0.79)
	dialog_badge.set_anchor(SIDE_RIGHT, 0.88)
	dialog_badge.set_anchor(SIDE_BOTTOM, 0.965)
	dialog_badge.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#123b3d", 0.88), Color("#d59a31", 0.90), 2, 9, Color("#160b05", 0.40), 2, 3.0))
	dialog_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog_badge.set_meta("phase153_component", "dynamic_merchant_dialog_plaque_v1")
	hero.add_child(dialog_badge)
	shop_merchant_dialog_label = Label.new()
	shop_merchant_dialog_label.text = "Vítej! Něco zasadíme, nebo proměníme úrodu v mince?"
	shop_merchant_dialog_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	shop_merchant_dialog_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_merchant_dialog_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	shop_merchant_dialog_label.add_theme_font_override("font", FontSemiBold)
	shop_merchant_dialog_label.add_theme_font_size_override("font_size", 8)
	shop_merchant_dialog_label.add_theme_color_override("font_color", ComicUITheme.CREAM)
	shop_merchant_dialog_label.add_theme_color_override("font_shadow_color", Color("#071823"))
	shop_merchant_dialog_label.add_theme_constant_override("shadow_offset_x", 2)
	shop_merchant_dialog_label.add_theme_constant_override("shadow_offset_y", 2)
	shop_merchant_dialog_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dialog_badge.add_child(shop_merchant_dialog_label)
	return hero


func _build_shop_catalog_tile(title_text: String, price: int, icon_texture: Texture2D, accent: Color, callback: Callable, rarity: Dictionary = {}) -> Dictionary:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 180 if not rarity.is_empty() else 166)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff0c1", 0.98), accent.darkened(0.08), 3, 12, Color("#1a0c06", 0.48), 4, 5.0))
	panel.set_meta("component", "botanist_catalog_tile_phase153_v1")
	panel.set_meta("phase128_style_parity", VisualDesignSystem.PLANTS_STYLE_PARITY_ID)
	panel.set_meta("phase153_grounding", "painted_display_plaque_contact_shadow_v1")
	if not rarity.is_empty():
		panel.set_meta("rarity", str(rarity.get("id", "common")))
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 2)
	panel.add_child(column)
	var owned := Label.new()
	owned.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	owned.add_theme_font_override("font", FontExtraBold)
	owned.add_theme_font_size_override("font_size", 9)
	owned.add_theme_color_override("font_color", accent.darkened(0.35))
	column.add_child(owned)
	var icon_frame := PanelContainer.new()
	icon_frame.custom_minimum_size = Vector2(0, 82)
	icon_frame.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff7db", 0.72), accent.darkened(0.22), 1, 8, Color.TRANSPARENT, 0, 0.0))
	var icon := TextureRect.new()
	icon.texture = icon_texture
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_frame.add_child(icon)
	column.add_child(icon_frame)
	if not rarity.is_empty():
		var rarity_label := Label.new()
		rarity_label.text = "%s  %s" % ["★".repeat(maxi(1, int(rarity.get("stars", 1)))), str(rarity.get("label", "BĚŽNÁ"))]
		rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rarity_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		rarity_label.add_theme_font_override("font", FontExtraBold)
		rarity_label.add_theme_font_size_override("font_size", 8)
		rarity_label.add_theme_color_override("font_color", Color(str(rarity.get("color_hex", "#76D91D"))).darkened(0.32))
		column.add_child(rarity_label)
	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 10)
	title.add_theme_color_override("font_color", ComicUITheme.INK)
	column.add_child(title)
	var button := _action_button("%d  MINCÍ" % price, callback)
	button.custom_minimum_size.y = 48
	button.focus_mode = Control.FOCUS_NONE
	button.set_meta("component", "comic_shop_buy_button_v1")
	button.set_meta("touch_target_min_height", 48)
	button.set_meta("price", price)
	ComicUITheme.apply_button(button, accent, ComicUITheme.INK if accent != ComicUITheme.PURPLE else Color.WHITE, 9, ComicUITheme.INK, 2)
	column.add_child(button)
	return {"root": panel, "button": button, "owned": owned}


func _add_equipment_shop_tile(equipment_id: String, icon_texture: Texture2D, accent: Color) -> void:
	var state := session.get_equipment_upgrade_state(equipment_id)
	var tile := _build_equipment_upgrade_tile(equipment_id, str(state.get("name", equipment_id)), icon_texture, accent)
	var root := tile.root as Control
	root.set_meta("shop_category", "equipment")
	shop_equipment_buttons[equipment_id] = tile.button
	shop_equipment_level_labels[equipment_id] = tile.level
	shop_equipment_effect_labels[equipment_id] = tile.effect
	shop_buy_cards.append(root)
	shop_catalog_grid.add_child(root)


func _build_equipment_upgrade_tile(equipment_id: String, title_text: String, icon_texture: Texture2D, accent: Color) -> Dictionary:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 190)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff0c1", 0.98), accent.darkened(0.08), 3, 12, Color("#1a0c06", 0.48), 4, 5.0))
	panel.set_meta("component", "botanist_equipment_upgrade_tile_phase153_v1")
	panel.set_meta("phase128_style_parity", VisualDesignSystem.PLANTS_STYLE_PARITY_ID)
	panel.set_meta("phase153_grounding", "painted_display_plaque_contact_shadow_v1")
	panel.set_meta("equipment_id", equipment_id)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 2)
	panel.add_child(column)
	var level_label := Label.new()
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	level_label.add_theme_font_override("font", FontExtraBold)
	level_label.add_theme_font_size_override("font_size", 9)
	level_label.add_theme_color_override("font_color", accent.darkened(0.35))
	column.add_child(level_label)
	var icon_frame := PanelContainer.new()
	icon_frame.custom_minimum_size = Vector2(0, 58)
	icon_frame.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff7db", 0.72), accent.darkened(0.22), 1, 8, Color.TRANSPARENT, 0, 0.0))
	var icon := TextureRect.new()
	icon.texture = icon_texture
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_frame.add_child(icon)
	column.add_child(icon_frame)
	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 10)
	title.add_theme_color_override("font_color", ComicUITheme.INK)
	column.add_child(title)
	var effect_label := Label.new()
	effect_label.custom_minimum_size.y = 31
	effect_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	effect_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	effect_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	effect_label.add_theme_font_override("font", FontSemiBold)
	effect_label.add_theme_font_size_override("font_size", 8)
	effect_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(effect_label)
	var button := _action_button("VYLEPŠIT", _on_buy_equipment_upgrade.bind(equipment_id))
	button.custom_minimum_size.y = 58
	button.focus_mode = Control.FOCUS_NONE
	button.set_meta("component", "comic_equipment_upgrade_button_v1")
	button.set_meta("touch_target_min_height", 58)
	button.set_meta("equipment_id", equipment_id)
	ComicUITheme.apply_button(button, accent, ComicUITheme.INK if accent != ComicUITheme.PURPLE else Color.WHITE, 9, ComicUITheme.INK, 2)
	column.add_child(button)
	return {"root": panel, "button": button, "level": level_label, "effect": effect_label}


func _build_botanist_sell_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size.y = 258
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#e9fff2"), ComicUITheme.GREEN, 4, 16, ComicUITheme.SHADOW, 4, 9.0))
	panel.set_meta("component", "botanist_instant_sell_card_v1")
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	panel.add_child(column)
	var header := Label.new()
	header.text = "RYCHLÝ VÝKUP U PANA KOŘÍNKA"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_override("font", FontExtraBold)
	header.add_theme_font_size_override("font_size", 16)
	header.add_theme_color_override("font_color", ComicUITheme.INK)
	column.add_child(header)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	column.add_child(row)
	var icon_frame := PanelContainer.new()
	icon_frame.custom_minimum_size = Vector2(92, 100)
	icon_frame.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff2a8"), ComicUITheme.GOLD, 3, 12, Color.TRANSPARENT, 0, 0.0))
	shop_sell_icon = TextureRect.new()
	shop_sell_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	shop_sell_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	shop_sell_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_frame.add_child(shop_sell_icon)
	row.add_child(icon_frame)
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.alignment = BoxContainer.ALIGNMENT_CENTER
	details.add_theme_constant_override("separation", 3)
	row.add_child(details)
	shop_sell_title_label = Label.new()
	shop_sell_title_label.add_theme_font_override("font", FontExtraBold)
	shop_sell_title_label.add_theme_font_size_override("font_size", 16)
	shop_sell_title_label.add_theme_color_override("font_color", ComicUITheme.INK)
	details.add_child(shop_sell_title_label)
	shop_sell_details_label = Label.new()
	shop_sell_details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	shop_sell_details_label.add_theme_font_size_override("font_size", 11)
	shop_sell_details_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	details.add_child(shop_sell_details_label)
	shop_sell_offer_label = Label.new()
	shop_sell_offer_label.add_theme_font_override("font", FontExtraBold)
	shop_sell_offer_label.add_theme_font_size_override("font_size", 19)
	shop_sell_offer_label.add_theme_color_override("font_color", Color("#a15b0b"))
	details.add_child(shop_sell_offer_label)
	shop_sell_button = _action_button("PRODAT HNED", _on_botanist_sell)
	shop_sell_button.custom_minimum_size.y = 68
	ComicUITheme.apply_button(shop_sell_button, ComicUITheme.GREEN, ComicUITheme.INK, 13)
	shop_sell_button.set_meta("component", "botanist_instant_sell_button_v1")
	shop_sell_button.set_meta("touch_target_min_height", 68)
	column.add_child(shop_sell_button)
	var hint := Label.new()
	hint.text = "Zakázky ve SKLADU platí více, ale mají požadavky na váhu a kvalitu. Tady prodáš hotový balíček okamžitě."
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 10)
	hint.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(hint)
	return panel


func _set_shop_mode(mode: String) -> void:
	shop_mode = "sell" if mode == "sell" else "buy"
	if shop_legacy_capture:
		shop_mode = "buy"
	botanist_shop_presenter.apply_mode(shop_mode, shop_category)
	if shop_mode == "buy":
		if shop_category == "equipment":
			_set_botanist_dialog("Dobré vybavení šetří čas i rostliny. Ukážu ti přesně, co další úroveň zlepší.")
		else:
			_set_botanist_dialog("Vyber semínko nebo pomůcku. Na všechno dohlédnu osobně.")
	else:
		_select_first_packaged_plant()
		_set_botanist_dialog("Ukaž balíček. Nabídku řeknu rovnou a bez čekání.")
	_refresh_botanist_sell_panel()
	if shop_catalog_scroll != null:
		shop_catalog_scroll.scroll_vertical = 0


func _set_shop_legacy_capture(enabled: bool) -> void:
	shop_legacy_capture = enabled
	if shop_legacy_header != null:
		shop_legacy_header.visible = enabled
	if shop_scroll != null:
		shop_scroll.visible = enabled
	if shop_runtime_layout != null:
		shop_runtime_layout.visible = not enabled
	if shop_hero_panel != null:
		shop_hero_panel.visible = not enabled
	if shop_mode_tabs != null:
		shop_mode_tabs.visible = not enabled
	if enabled:
		mint_shop_card.visible = false
		rosemary_shop_card.visible = false
	else:
		_set_shop_mode(shop_mode)
	if shop_scroll != null:
		shop_scroll.scroll_vertical = 0


func _select_first_packaged_plant() -> void:
	if session == null or session.plant.stage == PlantSimulation.Stage.PACKAGED:
		return
	for index in range(session.plants.size()):
		if session.plants[index].stage == PlantSimulation.Stage.PACKAGED:
			session.select_plant(index)
			plant_view.set_simulation(session.plant)
			return


func _refresh_botanist_sell_panel() -> void:
	if shop_sell_panel == null or session == null:
		return
	botanist_shop_presenter.refresh_sell_view(
		session,
		_species_herbarium_texture(session.plant.get_species_id()),
		NavStorageIcon
	)


func _set_botanist_dialog(message: String, success := false) -> void:
	if shop_merchant_dialog_label == null:
		return
	botanist_shop_presenter.show_merchant_message(message, success)
	if shop_merchant_scene == null or not is_inside_tree():
		return
	var previous_tween: Tween
	if shop_merchant_scene.has_meta("reaction_tween"):
		previous_tween = shop_merchant_scene.get_meta("reaction_tween") as Tween
	if previous_tween != null and previous_tween.is_valid():
		previous_tween.kill()
	shop_merchant_scene.pivot_offset = shop_merchant_scene.size * Vector2(0.68, 0.55)
	shop_merchant_scene.scale = Vector2.ONE
	var tween := create_tween()
	shop_merchant_scene.set_meta("reaction_tween", tween)
	tween.tween_property(shop_merchant_scene, "scale", Vector2(1.025, 1.025), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(shop_merchant_scene, "scale", Vector2.ONE, 0.20).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _on_botanist_sell() -> void:
	if session.plant.stage != PlantSimulation.Stage.PACKAGED:
		_set_botanist_dialog("Ještě ne. Nejdřív úrodu usuš a zabal ve skladu.")
		_refresh_botanist_sell_panel()
		return
	var species_name := session.plant.get_short_name()
	var offer := session.get_botanist_sale_value()
	if session.sell_harvest_to_botanist():
		botanist_shop_presenter.show_feedback("✓ %s prodána za %d mincí." % [species_name, offer], true)
		_set_botanist_dialog("Poctivá práce! %d mincí je tvých." % offer, true)
		_play_success_pulse(shop_sell_button)
		_save_and_refresh()
	else:
		_set_botanist_dialog("Tenhle balíček zatím nemohu vykoupit.")


func _build_navigation() -> Control:
	var panel := Control.new()
	panel.custom_minimum_size.y = 97
	panel.set_meta("visual_source", "comic_ui_code_native")
	panel.set_meta("navigation_asset", "comic_mobile_tabs_v1")
	panel.set_meta("visual_integration", "comic_full_width_four_tab_bar")
	panel.set_meta("selection_feedback", "shine_only")
	panel.set_meta("ui_kit", "comic_ui_v1")
	var background := PanelContainer.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.add_theme_stylebox_override("panel", ComicUITheme.style_box(ComicUITheme.NAVY, ComicUITheme.INK, 3, 0, Color("#07131c", 0.44), 3, 0.0))
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(background)
	var top_glow := ColorRect.new()
	top_glow.color = ComicUITheme.CYAN
	top_glow.set_anchor(SIDE_LEFT, 0.015)
	top_glow.set_anchor(SIDE_TOP, 0.035)
	top_glow.set_anchor(SIDE_RIGHT, 0.985)
	top_glow.set_anchor(SIDE_BOTTOM, 0.065)
	top_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(top_glow)
	var tab_accents := [ComicUITheme.GREEN, ComicUITheme.BLUE, ComicUITheme.ORANGE, ComicUITheme.PURPLE]
	for index in range(4):
		var button := Button.new()
		button.text = ["ROSTLINY", "SKLAD", "OBCHOD", "MĚŘENÍ"][index]
		button.set_anchor(SIDE_LEFT, NAV_BUTTON_BOUNDS[index].x)
		button.set_anchor(SIDE_TOP, 0.08)
		button.set_anchor(SIDE_RIGHT, NAV_BUTTON_BOUNDS[index].y)
		button.set_anchor(SIDE_BOTTOM, 0.96)
		button.offset_left = 2.0
		button.offset_right = -2.0
		button.focus_mode = Control.FOCUS_NONE
		button.clip_contents = true
		TooltipPolicy.apply(button, button.text)
		ComicUITheme.apply_button(button, Color("#fff3c4"), ComicUITheme.INK, 12, ComicUITheme.INK, 3)
		button.add_theme_color_override("font_color", Color.TRANSPARENT)
		button.add_theme_color_override("font_hover_color", Color.TRANSPARENT)
		button.add_theme_color_override("font_pressed_color", Color.TRANSPARENT)
		button.add_theme_color_override("font_disabled_color", Color.TRANSPARENT)
		button.set_meta("component", "comic_nav_tab_v1")
		button.set_meta("touch_target_min_height", 80)
		var accent := ColorRect.new()
		accent.color = tab_accents[index]
		accent.set_anchor(SIDE_LEFT, 0.10)
		accent.set_anchor(SIDE_TOP, 0.04)
		accent.set_anchor(SIDE_RIGHT, 0.90)
		accent.set_anchor(SIDE_BOTTOM, 0.095)
		accent.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(accent)
		var icon := TextureRect.new()
		icon.texture = NAV_ICONS[index]
		icon.set_anchor(SIDE_LEFT, 0.20)
		icon.set_anchor(SIDE_TOP, 0.10)
		icon.set_anchor(SIDE_RIGHT, 0.80)
		icon.set_anchor(SIDE_BOTTOM, 0.64)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.visible = true
		button.add_child(icon)
		var label := Label.new()
		label.text = button.text
		label.set_anchor(SIDE_LEFT, 0.04)
		label.set_anchor(SIDE_TOP, 0.63)
		label.set_anchor(SIDE_RIGHT, 0.96)
		label.set_anchor(SIDE_BOTTOM, 0.96)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_override("font", FontExtraBold)
		label.add_theme_font_size_override("font_size", 10)
		label.add_theme_color_override("font_color", ComicUITheme.INK)
		label.add_theme_color_override("font_shadow_color", ComicUITheme.CREAM)
		label.add_theme_constant_override("shadow_offset_y", 1)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.visible = true
		button.add_child(label)
		var shine := ColorRect.new()
		shine.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		shine.mouse_filter = Control.MOUSE_FILTER_IGNORE
		shine.visible = false
		var shine_material := ShaderMaterial.new()
		shine_material.shader = NavTouchShineShader
		shine_material.set_shader_parameter("progress", 1.0)
		shine_material.set_shader_parameter("strength", 0.72)
		shine.material = shine_material
		button.add_child(shine)
		button.pressed.connect(_on_navigation_pressed.bind(index))
		panel.add_child(button)
		nav_buttons.append(button)
		nav_shine_overlays.append(shine)
		nav_icon_nodes.append(icon)
	return panel


func _on_navigation_pressed(index: int) -> void:
	_play_navigation_shine(index)
	# ROSTLINY is the canonical entrance to the rack. Garden sublocations stay
	# remembered only while the player deliberately remains inside that screen.
	if index == 0:
		_open_rack_location()
	_change_screen(index)


func _play_navigation_shine(index: int) -> void:
	if index < 0 or index >= nav_shine_overlays.size():
		return
	var shine := nav_shine_overlays[index]
	var button := nav_buttons[index]
	var icon := nav_icon_nodes[index]
	var old_press_tween: Tween
	if button.has_meta("press_tween"):
		old_press_tween = button.get_meta("press_tween") as Tween
	if old_press_tween != null and old_press_tween.is_valid():
		old_press_tween.kill()
	button.pivot_offset = button.size * 0.5
	icon.pivot_offset = icon.size * 0.5
	button.scale = Vector2.ONE
	icon.rotation = 0.0
	var press_tween := create_tween()
	button.set_meta("press_tween", press_tween)
	press_tween.tween_property(button, "scale", Vector2(0.955, 0.955), 0.09).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	press_tween.parallel().tween_property(icon, "rotation", -0.055, 0.09)
	press_tween.tween_property(button, "scale", Vector2.ONE, 0.17).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	press_tween.parallel().tween_property(icon, "rotation", 0.0, 0.17)
	var old_tween: Tween
	if shine.has_meta("shine_tween"):
		old_tween = shine.get_meta("shine_tween") as Tween
	if old_tween != null and old_tween.is_valid():
		old_tween.kill()
	var shine_material := shine.material as ShaderMaterial
	shine_material.set_shader_parameter("progress", 0.0)
	shine.visible = true
	var tween := create_tween()
	shine.set_meta("shine_tween", tween)
	tween.tween_method(_set_navigation_shine_progress.bind(shine_material), 0.0, 1.0, 0.34).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(shine.hide)


func _set_navigation_shine_progress(value: float, material: ShaderMaterial) -> void:
	material.set_shader_parameter("progress", value)


func _add_phase128_screen_backdrop(parent: Control, texture: Texture2D, screen_id: String) -> void:
	var backdrop := TextureRect.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.texture = texture
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	backdrop.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.modulate = Color(1.0, 1.0, 1.0, 0.72 if screen_id == "measurement" else 0.56)
	backdrop.set_meta("component", "phase128_illustrated_screen_backdrop_v1")
	backdrop.set_meta("screen_id", screen_id)
	backdrop.set_meta("style_parity", VisualDesignSystem.PLANTS_STYLE_PARITY_ID)
	parent.add_child(backdrop)
	phase128_scene_backdrops.append(backdrop)

	var wash := ColorRect.new()
	wash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	wash.color = Color("#fff5d8", 0.12 if screen_id == "measurement" else 0.25)
	wash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wash.set_meta("component", "phase128_readability_wash_v1")
	wash.set_meta("screen_id", screen_id)
	parent.add_child(wash)
	phase128_scene_backdrops.append(wash)


func _build_phase128_screen_hero(texture: Texture2D, title_text: String, subtitle_text: String, accent: Color, screen_id: String) -> Control:
	var hero := Control.new()
	hero.custom_minimum_size.y = 248 if screen_id == "measurement" else 188
	hero.clip_contents = true
	hero.set_meta("component", "phase128_plants_style_scene_hero_v1")
	hero.set_meta("screen_id", screen_id)
	hero.set_meta("style_parity", VisualDesignSystem.PLANTS_STYLE_PARITY_ID)
	hero.set_meta("style_reference", VisualDesignSystem.PLANTS_STYLE_REFERENCE_ID)
	hero.set_meta("style_refinement", VisualDesignSystem.PLANTS_STYLE_REFINEMENT_ID)
	phase128_scene_heroes.append(hero)

	var frame := PanelContainer.new()
	frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	frame.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff0bd"), accent, 4, 17, Color("#07131c", 0.48), 6, 5.0))
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero.add_child(frame)

	var scene := TextureRect.new()
	if screen_id == "storage":
		var workshop_crop := AtlasTexture.new()
		workshop_crop.atlas = texture
		workshop_crop.region = Rect2(0.0, 0.0, texture.get_width(), minf(texture.get_height(), 900.0))
		scene.texture = workshop_crop
	elif screen_id == "measurement":
		var laboratory_crop := AtlasTexture.new()
		laboratory_crop.atlas = texture
		var crop_height := minf(texture.get_height(), 520.0)
		var crop_top := clampf(500.0, 0.0, maxf(0.0, texture.get_height() - crop_height))
		laboratory_crop.region = Rect2(0.0, crop_top, texture.get_width(), crop_height)
		scene.texture = laboratory_crop
		scene.set_meta("phase154_crop", "integrated_window_sensor_plant_meter_and_lab_tools_v1")
	else:
		scene.texture = texture
	scene.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene.offset_left = 5.0
	scene.offset_top = 5.0
	scene.offset_right = -5.0
	scene.offset_bottom = -5.0
	scene.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	scene.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	scene.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	scene.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero.add_child(scene)

	var title_panel := PanelContainer.new()
	title_panel.set_anchor(SIDE_LEFT, 0.055)
	title_panel.set_anchor(SIDE_TOP, 0.055)
	title_panel.set_anchor(SIDE_RIGHT, 0.945)
	var title_bottom := 0.35 if screen_id == "storage" else 0.43
	if screen_id == "measurement":
		title_bottom = 0.34
	title_panel.set_anchor(SIDE_BOTTOM, title_bottom)
	title_panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff5d8", 0.96), accent, 3, 14, Color("#07131c", 0.42), 4, 7.0))
	title_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hero.add_child(title_panel)

	var text_column := VBoxContainer.new()
	text_column.alignment = BoxContainer.ALIGNMENT_CENTER
	text_column.add_theme_constant_override("separation", 0)
	title_panel.add_child(text_column)
	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", ComicUITheme.INK)
	text_column.add_child(title)
	var subtitle := Label.new()
	subtitle.text = subtitle_text
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	subtitle.add_theme_font_override("font", FontSemiBold)
	subtitle.add_theme_font_size_override("font_size", 9)
	subtitle.add_theme_color_override("font_color", ComicUITheme.NAVY)
	text_column.add_child(subtitle)
	return hero


func _phase128_surface_style(token_id: String, accent: Color) -> StyleBoxFlat:
	var token: Dictionary = VisualDesignSystem.PLANTS_SURFACE_TOKENS.get(token_id, {})
	var fill: Color = token.get("fill", Color("#fff4c8", 0.90))
	var border_width := int(token.get("border_width", 4))
	var radius := int(token.get("radius", 14))
	var shadow_size := int(token.get("shadow_size", 4))
	var content_margin := float(token.get("content_margin", 6.0))
	return ComicUITheme.style_box(fill, accent, border_width, radius, Color("#07131c", 0.40), shadow_size, content_margin)


func _register_phase128_surface(panel: PanelContainer, legacy_style: StyleBox, token_id: String, accent: Color) -> void:
	var modern_style := _phase128_surface_style(token_id, accent)
	phase128_surface_styles.append({
		"panel": panel,
		"legacy_style": legacy_style,
		"modern_style": modern_style,
	})
	panel.set_meta("phase128_surface_token", token_id)
	panel.set_meta("phase128_style_reference", VisualDesignSystem.PLANTS_STYLE_REFERENCE_ID)
	panel.add_theme_stylebox_override("panel", modern_style if phase128_plants_style_enabled else legacy_style)


func _register_phase128_label_surface(label: Label, token_id: String, accent: Color) -> void:
	var modern_style := _phase128_surface_style(token_id, accent)
	phase128_label_styles.append({
		"label": label,
		"modern_style": modern_style,
	})
	label.set_meta("phase128_surface_token", token_id)
	label.set_meta("phase128_style_reference", VisualDesignSystem.PLANTS_STYLE_REFERENCE_ID)
	if phase128_plants_style_enabled:
		label.add_theme_stylebox_override("normal", modern_style)


func _set_phase128_plants_style_enabled(enabled: bool) -> void:
	phase128_plants_style_enabled = enabled
	if not enabled:
		for metric_id in phase154_measurement_legacy_value_labels:
			var modern_value := metric_labels.get(metric_id) as Label
			var legacy_value := phase154_measurement_legacy_value_labels.get(metric_id) as Label
			if is_instance_valid(modern_value) and is_instance_valid(legacy_value):
				legacy_value.text = modern_value.text
	for modern_content in phase154_measurement_modern_contents:
		if is_instance_valid(modern_content):
			modern_content.visible = enabled
	for legacy_content in phase154_measurement_legacy_contents:
		if is_instance_valid(legacy_content):
			legacy_content.visible = not enabled
	for hero in phase128_scene_heroes:
		if is_instance_valid(hero):
			hero.visible = enabled
	for backdrop in phase128_scene_backdrops:
		if is_instance_valid(backdrop):
			backdrop.visible = enabled
	for header in phase128_legacy_headers:
		if is_instance_valid(header):
			header.visible = not enabled
	for entry in phase128_surface_styles:
		var panel: PanelContainer = entry.get("panel")
		if not is_instance_valid(panel):
			continue
		var style: StyleBox = entry.get("modern_style") if enabled else entry.get("legacy_style")
		panel.add_theme_stylebox_override("panel", style)
	for entry in phase128_label_styles:
		var label: Label = entry.get("label")
		if not is_instance_valid(label):
			continue
		if enabled:
			label.add_theme_stylebox_override("normal", entry.get("modern_style"))
		else:
			label.remove_theme_stylebox_override("normal")
	set_meta("phase128_plants_style_enabled", enabled)


func _screen_margin() -> MarginContainer:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	return margin


func _section_title(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 22)
	return label


func _screen_header(title_text: String, subtitle_text: String, accent: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size.y = 92
	panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(ComicUITheme.PAPER, accent, 3, 15, ComicUITheme.SHADOW, 4, 10.0))
	panel.set_meta("component", "comic_screen_header_v1")
	panel.set_meta("ui_kit", "comic_ui_v1")
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	panel.add_child(row)
	var accent_bar := ColorRect.new()
	accent_bar.color = accent
	accent_bar.custom_minimum_size.x = 8
	accent_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(accent_bar)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 2)
	row.add_child(column)
	var title := Label.new()
	title.text = title_text
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", ComicUITheme.INK)
	column.add_child(title)
	var subtitle := Label.new()
	subtitle.text = subtitle_text
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.add_theme_font_size_override("font_size", 11)
	subtitle.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(subtitle)
	return panel


func _build_inventory_card(parent: Container, title_text: String, icon_texture: Texture2D, accent: Color) -> Label:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 110)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var legacy_style := ComicUITheme.style_box(Color("#fff4c8"), accent, 3, 12, ComicUITheme.SHADOW, 3, 5.0)
	_register_phase128_surface(panel, legacy_style, "information_card", accent)
	panel.set_meta("component", "comic_inventory_card_v1")
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 0)
	panel.add_child(column)
	var icon := TextureRect.new()
	icon.texture = icon_texture
	icon.custom_minimum_size = Vector2(45, 45)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(icon)
	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FontSemiBold)
	title.add_theme_font_size_override("font_size", 9)
	title.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(title)
	var value := Label.new()
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value.add_theme_font_override("font", FontExtraBold)
	value.add_theme_font_size_override("font_size", 20)
	value.add_theme_color_override("font_color", ComicUITheme.INK)
	column.add_child(value)
	parent.add_child(panel)
	return value


func _build_shop_item_card(title_text: String, description: String, rarity: String, price: int, icon_texture: Texture2D, accent: Color, callback: Callable) -> Dictionary:
	var panel := PanelContainer.new()
	panel.custom_minimum_size.y = 180
	panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff4c8"), accent, 3, 15, ComicUITheme.SHADOW, 4, 9.0))
	panel.set_meta("component", "comic_shop_item_card_v1")
	panel.set_meta("rarity", rarity.to_lower())
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 9)
	panel.add_child(row)
	var icon_panel := PanelContainer.new()
	icon_panel.custom_minimum_size = Vector2(92, 0)
	icon_panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color(accent, 0.22), ComicUITheme.INK, 2, 12, Color.TRANSPARENT, 0, 4.0))
	var icon := TextureRect.new()
	icon.texture = icon_texture
	icon.custom_minimum_size = Vector2(76, 76)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.set_meta("shop_item_icon", title_text)
	icon_panel.add_child(icon)
	row.add_child(icon_panel)
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.alignment = BoxContainer.ALIGNMENT_CENTER
	details.add_theme_constant_override("separation", 2)
	row.add_child(details)
	var rarity_label := Label.new()
	rarity_label.text = rarity
	rarity_label.add_theme_font_override("font", FontExtraBold)
	rarity_label.add_theme_font_size_override("font_size", 9)
	rarity_label.add_theme_color_override("font_color", accent.darkened(0.28))
	details.add_child(rarity_label)
	var title := Label.new()
	title.text = title_text
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", ComicUITheme.INK)
	details.add_child(title)
	var description_label := Label.new()
	description_label.text = description
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.add_theme_font_size_override("font_size", 11)
	description_label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	details.add_child(description_label)
	var owned := Label.new()
	owned.add_theme_font_override("font", FontSemiBold)
	owned.add_theme_font_size_override("font_size", 11)
	owned.add_theme_color_override("font_color", accent.darkened(0.34))
	details.add_child(owned)
	var button := _action_button("KOUPIT  ·  %d" % price, callback)
	button.custom_minimum_size.y = 64
	button.add_theme_font_override("font", FontExtraBold)
	button.add_theme_font_size_override("font_size", 14)
	ComicUITheme.apply_button(button, accent, ComicUITheme.INK if accent != ComicUITheme.PURPLE else Color.WHITE, 12)
	button.set_meta("component", "comic_shop_buy_button_v1")
	button.set_meta("touch_target_min_height", 64)
	button.set_meta("price", price)
	details.add_child(button)
	return {"root": panel, "button": button, "owned": owned}


func _add_stat_card(parent: Container, title_text: String, icon_texture: Texture2D) -> Label:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size.y = 70
	var accent := DETAIL_GREEN
	if title_text == "VLHKOST":
		accent = DETAIL_CYAN
	elif title_text == "PODMÍNKY":
		accent = DETAIL_GOLD
	panel.add_theme_stylebox_override("panel", _comic_style_box(DETAIL_CREAM, accent, 3, 12, Color("#0c1720", 0.27), 3, 6.0))
	panel.set_meta("component", "comic_stat_card_v1")
	panel.set_meta("accent", title_text.to_lower())
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 2)
	panel.add_child(row)
	var icon := TextureRect.new()
	icon.texture = icon_texture
	icon.custom_minimum_size = Vector2(34, 34)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(icon)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 0)
	row.add_child(column)
	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FontSemiBold)
	title.add_theme_font_size_override("font_size", 10)
	title.add_theme_color_override("font_color", DETAIL_INK)
	column.add_child(title)
	var value := Label.new()
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value.add_theme_font_override("font", FontExtraBold)
	value.add_theme_font_size_override("font_size", 16)
	value.add_theme_color_override("font_color", DETAIL_INK)
	column.add_child(value)
	parent.add_child(panel)
	return value


func _add_measurement_card(parent: Container, metric_id: String, title_text: String, accent: Color) -> Label:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size.y = 82
	var legacy_style := ComicUITheme.style_box(Color("#fff4c8"), accent, 3, 12, ComicUITheme.SHADOW, 3, 6.0)
	_register_phase128_surface(panel, legacy_style, "information_card", accent)
	panel.set_meta("component", "comic_measurement_card_v1")
	panel.set_meta("phase154_component", "painted_dynamic_metric_card_v1")
	panel.set_meta("metric_id", metric_id)

	var legacy_column := VBoxContainer.new()
	legacy_column.alignment = BoxContainer.ALIGNMENT_CENTER
	legacy_column.add_theme_constant_override("separation", 1)
	legacy_column.visible = not phase128_plants_style_enabled
	panel.add_child(legacy_column)
	phase154_measurement_legacy_contents.append(legacy_column)
	var legacy_title := Label.new()
	legacy_title.text = title_text
	legacy_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	legacy_title.add_theme_font_override("font", FontSemiBold)
	legacy_title.add_theme_font_size_override("font_size", 9)
	legacy_title.add_theme_color_override("font_color", ComicUITheme.NAVY)
	legacy_column.add_child(legacy_title)
	var legacy_value := Label.new()
	legacy_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	legacy_value.clip_text = true
	legacy_value.add_theme_font_override("font", FontExtraBold)
	legacy_value.add_theme_font_size_override("font_size", 16)
	legacy_value.add_theme_color_override("font_color", ComicUITheme.INK)
	legacy_column.add_child(legacy_value)
	phase154_measurement_legacy_value_labels[metric_id] = legacy_value

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 5)
	row.visible = phase128_plants_style_enabled
	row.set_meta("component", "comic_measurement_card_v1")
	row.set_meta("phase154_component", "painted_metric_icon_value_row_v1")
	panel.add_child(row)
	phase154_measurement_modern_contents.append(row)
	var icon := MeasurementMetricIconScene.new()
	icon.custom_minimum_size = Vector2(43.0, 43.0)
	icon.configure(metric_id, accent)
	row.add_child(icon)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 0)
	row.add_child(column)
	var title := Label.new()
	title.text = title_text
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title.add_theme_font_override("font", FontSemiBold)
	title.add_theme_font_size_override("font_size", 8)
	title.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(title)
	var value := Label.new()
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value.clip_text = true
	value.add_theme_font_override("font", FontExtraBold)
	value.add_theme_font_size_override("font_size", 16)
	value.add_theme_color_override("font_color", ComicUITheme.INK)
	column.add_child(value)
	parent.add_child(panel)
	return value


func _action_button(text_value: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text_value
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size.y = 38
	button.set_meta("swipe_action_guard", "phase122_deferred_drag_release_v2")
	button.set_meta("swipe_action_guard_predecessor", "phase121_deferred_release_v1")
	button.pressed.connect(_on_guarded_action_pressed.bind(callback))
	return button


func _on_guarded_action_pressed(callback: Callable) -> void:
	if swipe_action_suppressed:
		return
	callback.call()


func _build_rack_location_button(text_value: String, fill: Color) -> Button:
	var button := Button.new()
	button.text = text_value
	button.focus_mode = Control.FOCUS_NONE
	button.z_index = 9
	button.add_theme_font_override("font", FontExtraBold)
	button.add_theme_font_size_override("font_size", 12)
	ComicUITheme.apply_button(button, fill, Color.WHITE, 18)
	button.set_meta("touch_target_min", Vector2(112, 64))
	button.set_meta("navigation_scope", "garden_sublocation")
	return button


func _build_rack_dock_launcher(
	parent: Control,
	index: int,
	icon_texture: Texture2D,
	fill: Color,
	component: String,
	asset_name: String,
	tooltip_text: String,
	callback: Callable
) -> Button:
	var button := Button.new()
	button.name = "RackDockLauncher%d" % index
	button.text = ""
	button.clip_contents = false
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.set_anchor(SIDE_LEFT, 0.5)
	button.set_anchor(SIDE_TOP, 1.0)
	button.set_anchor(SIDE_RIGHT, 0.5)
	button.set_anchor(SIDE_BOTTOM, 1.0)
	var group_width := RACK_DOCK_BUTTON_SIZE * float(RACK_DOCK_BUTTON_COUNT)
	var left := -group_width * 0.5 + float(index) * RACK_DOCK_BUTTON_SIZE
	button.offset_left = left
	button.offset_top = -RACK_DOCK_BOTTOM_INSET - RACK_DOCK_BUTTON_SIZE
	button.offset_right = left + RACK_DOCK_BUTTON_SIZE
	button.offset_bottom = -RACK_DOCK_BOTTOM_INSET
	button.custom_minimum_size = Vector2(RACK_DOCK_BUTTON_SIZE, RACK_DOCK_BUTTON_SIZE)
	button.z_index = 10
	ComicUITheme.apply_button(button, fill, ComicUITheme.CREAM, 16)
	TooltipPolicy.apply(button, tooltip_text)
	button.set_meta("component", component)
	button.set_meta("asset", asset_name)
	button.set_meta("dock_index", index)
	button.set_meta("dock_group", "compact_four_icon_phase183_v1")
	button.set_meta("touch_target_min", Vector2(RACK_DOCK_BUTTON_SIZE, RACK_DOCK_BUTTON_SIZE))
	button.set_meta("icon_policy", "transparent_cropped_png_48_v1")
	if callback.is_valid():
		button.pressed.connect(callback)
	parent.add_child(button)

	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.texture = icon_texture
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.set_anchors_preset(Control.PRESET_CENTER)
	icon.offset_left = -RACK_DOCK_ICON_SIZE * 0.5
	icon.offset_top = -RACK_DOCK_ICON_SIZE * 0.5
	icon.offset_right = RACK_DOCK_ICON_SIZE * 0.5
	icon.offset_bottom = RACK_DOCK_ICON_SIZE * 0.5
	icon.set_meta("component", "%s_icon_png" % component)
	icon.set_meta("alpha_policy", "clean_transparent_edge_v1")
	button.add_child(icon)
	return button


func _build_rack_dock_badge(
	parent: Button,
	text_value: String,
	fill: Color,
	component: String,
	badge_size: Vector2,
	font_size: int
) -> PanelContainer:
	var badge := PanelContainer.new()
	badge.name = "Badge"
	badge.set_anchor(SIDE_LEFT, 1.0)
	badge.set_anchor(SIDE_RIGHT, 1.0)
	badge.offset_left = -badge_size.x
	badge.offset_top = 0.0
	badge.offset_right = 0.0
	badge.offset_bottom = badge_size.y
	badge.custom_minimum_size = badge_size
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.z_index = 4
	badge.visible = false
	badge.add_theme_stylebox_override("panel", ComicUITheme.style_box(fill, ComicUITheme.CREAM, 2, 11, Color("#07131c", 0.42), 2, 2.0))
	badge.set_meta("component", component)
	var label := Label.new()
	label.name = "Label"
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_override("font", FontExtraBold)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", ComicUITheme.INK if fill == ComicUITheme.GOLD else ComicUITheme.CREAM)
	badge.add_child(label)
	parent.add_child(badge)
	return badge


func _change_screen(index: int, refresh_active := true, transition_direction_override := 0) -> void:
	if index != active_screen and player_room_view != null:
		player_room_view.cancel_plant_drag()
	var previous_screen := active_screen
	active_screen = screen_navigation_controller.apply_screen(index, active_screen, screens, nav_buttons, session, feedback_layer, transition_direction_override)
	if active_screen != 0 and plant_view != null:
		plant_view.clear_behavior_trigger()
	if refresh_active and active_screen != previous_screen:
		_refresh_active_ui()


func _open_plant_detail(index: int) -> void:
	if not session.select_plant(index):
		return
	plant_behavior_presenter.reset_observation()
	plant_view.set_simulation(session.plant)
	garden_location_id = GARDEN_LOCATION_RACK
	plants_room_panel.visible = false
	player_room_panel.visible = false
	greenhouse_panel.visible = false
	plant_detail_panel.visible = true
	plant_detail_panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(plant_detail_panel, "modulate:a", 1.0, 0.18)
	_refresh_ui()


func _on_rack_light_toggle_requested(index: int) -> void:
	if session == null or room_overview == null:
		return
	if swipe_action_suppressed:
		room_overview.play_light_denied(index)
		return
	if session.toggle_lamp_for_slot(index):
		_save_and_refresh()
	else:
		room_overview.play_light_denied(index)


func _open_room() -> void:
	_show_garden_location(GARDEN_LOCATION_RACK)
	plant_view.clear_behavior_trigger()
	room_overview.refresh()
	room_overview.set_cosmetic_theme(session.selected_room_theme)
	_show_dialog("Vyber rostlinu, o kterou se chceš postarat, nebo přidej novou do prázdného květináče.")


func _open_rack_location() -> void:
	_show_garden_location(GARDEN_LOCATION_RACK)


func _open_player_room() -> void:
	_show_garden_location(GARDEN_LOCATION_PLAYER_ROOM)


func _open_greenhouse() -> void:
	_show_garden_location(GARDEN_LOCATION_GREENHOUSE)


func _show_garden_location(location_id: String) -> void:
	if player_room_view != null:
		player_room_view.cancel_plant_drag()
	var normalized_id := location_id
	if normalized_id not in [GARDEN_LOCATION_RACK, GARDEN_LOCATION_PLAYER_ROOM, GARDEN_LOCATION_GREENHOUSE]:
		normalized_id = GARDEN_LOCATION_RACK
	garden_location_id = normalized_id
	set_meta("garden_location_id", garden_location_id)
	plant_detail_panel.visible = false
	plants_room_panel.visible = normalized_id == GARDEN_LOCATION_RACK
	player_room_panel.visible = normalized_id == GARDEN_LOCATION_PLAYER_ROOM
	greenhouse_panel.visible = normalized_id == GARDEN_LOCATION_GREENHOUSE
	if plant_view != null:
		plant_view.clear_behavior_trigger()
	if normalized_id == GARDEN_LOCATION_RACK and room_overview != null:
		room_overview.refresh()
		if session != null:
			room_overview.set_cosmetic_theme(session.selected_room_theme)
	if normalized_id == GARDEN_LOCATION_PLAYER_ROOM and player_room_view != null and session != null:
		player_room_view.set_cosmetic_theme(session.selected_room_theme)
		player_room_view.set_room_decorations(session.get_room_decoration_slots(), GameSession.ROOM_DECORATIONS)
	if normalized_id == GARDEN_LOCATION_GREENHOUSE:
		_refresh_greenhouse_view()


func _refresh_greenhouse_view() -> void:
	if greenhouse_preview_view == null or session == null:
		return
	greenhouse_preview_view.set_greenhouse_state(
		session.get_greenhouse_bed_states(),
		session.get_greenhouse_crop_catalog(),
		session.coins,
		session.xp,
		session.get_greenhouse_order_state()
	)


func _refresh_rack_greenhouse_attention() -> void:
	if rack_greenhouse_button == null or session == null:
		return
	var summary := session.get_greenhouse_attention_summary()
	var action_count := maxi(0, int(summary.get("action_count", 0)))
	rack_greenhouse_button.text = "←  SKLENÍK\n%d AKCE" % action_count if action_count > 0 else "←  SKLENÍK"
	rack_greenhouse_button.set_meta("greenhouse_action_count", action_count)


func _refresh_rack_controls() -> void:
	if care_center_launcher_button == null or session == null:
		return
	var attention_count := maxi(0, session.get_care_attention_count())
	care_center_launcher_button.text = ""
	care_center_launcher_button.set_meta("care_attention_count", attention_count)
	if care_center_attention_badge != null:
		care_center_attention_badge.visible = attention_count > 0
	if care_center_attention_label != null:
		care_center_attention_label.text = "99+" if attention_count > 99 else str(attention_count)


func _select_adjacent_plant(offset: int) -> void:
	_open_plant_detail(session.get_adjacent_unlocked_slot_index(offset))


func _refresh_ui() -> void:
	var plant := session.plant
	_refresh_coin_display()
	_refresh_xp_display()
	_set_day_display(_get_display_day())
	_refresh_professor_story_badges()
	var selected_plant_name := str(plant.profile.get("ui_name", plant.get_display_name()))
	garden_selection_presenter.refresh(session.get_occupied_count(), GameSession.MAX_PLANT_SLOTS, session.selected_plant_index, plant.stage == PlantSimulation.Stage.EMPTY, selected_plant_name)
	room_overview.refresh()
	room_overview.set_paused(session.paused)
	room_overview.set_cosmetic_theme(session.selected_room_theme)
	player_room_view.set_cosmetic_theme(session.selected_room_theme)
	player_room_view.set_room_decorations(session.get_room_decoration_slots(), GameSession.ROOM_DECORATIONS)
	player_room_view.set_paused(session.paused)
	_refresh_greenhouse_view()
	_refresh_rack_greenhouse_attention()
	_refresh_rack_controls()
	greenhouse_preview_view.set_paused(session.paused)
	plant_view.set_paused(session.paused)
	plant_vitals_presenter.refresh(plant)
	plant_action_presenter.refresh(plant, session.fertilizer_doses, float(session.get_equipment_level_data("watering_can").get("water_ml", 120.0)), float(session.get_equipment_level_data("protective_spray").get("disease_treatment_relief", 52.0)))
	real_time_growth_presenter.refresh(plant)
	_refresh_plant_behavior(true)
	measurement_presenter.refresh(plant, session.chart_samples)
	storage_inventory_presenter.refresh(session)
	_update_storage_panel()
	_update_customer_orders()
	session.refresh_shop_stock_for_unix()
	botanist_shop_presenter.refresh_buy_view(session, plant_catalog)
	_refresh_equipment_shop()
	_refresh_botanist_sell_panel()
	if seed_selector_open:
		_refresh_seed_selector()
	if herbarium_open:
		_refresh_herbarium()
	if daily_challenge_open:
		_refresh_daily_challenge()
	if botanical_pack_open:
		_refresh_botanical_pack()
	if level_progression_open:
		_refresh_level_progression()
	if grower_journal_open:
		_refresh_grower_journal()
	if care_center_open:
		_refresh_care_center()
	if plant_diagnosis_open:
		_refresh_plant_diagnosis()
	if room_decoration_open and room_decoration_modal != null:
		room_decoration_modal.refresh(session)
	if professor_story_open:
		_refresh_professor_story()


func _refresh_active_ui() -> void:
	var plant := session.plant
	_refresh_coin_display()
	_refresh_xp_display()
	_set_day_display(_get_display_day())
	_refresh_professor_story_badges()
	var selected_plant_name := str(plant.profile.get("ui_name", plant.get_display_name()))
	garden_selection_presenter.refresh(session.get_occupied_count(), GameSession.MAX_PLANT_SLOTS, session.selected_plant_index, plant.stage == PlantSimulation.Stage.EMPTY, selected_plant_name)
	_refresh_rack_greenhouse_attention()
	_refresh_rack_controls()
	if professor_story_open:
		_refresh_professor_story()
		return
	if seed_selector_open:
		_refresh_seed_selector()
		return
	if herbarium_open:
		_refresh_herbarium()
		return
	if daily_challenge_open:
		_refresh_daily_challenge()
		return
	if botanical_pack_open:
		_refresh_botanical_pack()
		return
	if level_progression_open:
		_refresh_level_progression()
		return
	if grower_journal_open:
		_refresh_grower_journal()
		return
	if care_center_open:
		_refresh_care_center()
		return
	if plant_diagnosis_open:
		_refresh_plant_diagnosis()
		return
	if room_decoration_open and room_decoration_modal != null:
		room_decoration_modal.refresh(session)
		return
	if dialog_open or settings_modal_open or botanical_pack_open or cosmetic_modal_open or return_summary_open or save_recovery_open or save_failure_open or local_backup_open:
		return
	match active_screen:
		0:
			if plants_room_panel.visible:
				room_overview.refresh()
				room_overview.set_paused(session.paused)
			if player_room_panel.visible:
				player_room_view.set_cosmetic_theme(session.selected_room_theme)
				player_room_view.set_room_decorations(session.get_room_decoration_slots(), GameSession.ROOM_DECORATIONS)
				player_room_view.set_paused(session.paused)
			if greenhouse_panel.visible:
				_refresh_greenhouse_view()
				greenhouse_preview_view.set_paused(session.paused)
			if plant_detail_panel.visible:
				plant_view.set_paused(session.paused)
				plant_vitals_presenter.refresh(plant)
				plant_action_presenter.refresh(plant, session.fertilizer_doses, float(session.get_equipment_level_data("watering_can").get("water_ml", 120.0)), float(session.get_equipment_level_data("protective_spray").get("disease_treatment_relief", 52.0)))
				real_time_growth_presenter.refresh(plant)
				_refresh_plant_behavior(true)
		1:
			storage_inventory_presenter.refresh(session)
			_update_storage_panel()
			_update_customer_orders()
		2:
			session.refresh_shop_stock_for_unix()
			botanist_shop_presenter.refresh_buy_view(session, plant_catalog)
			_refresh_equipment_shop()
			_refresh_botanist_sell_panel()
		3:
			measurement_presenter.refresh(plant, session.chart_samples)


func _get_active_ui_refresh_interval() -> float:
	return 0.25 if active_screen == 0 and not _is_blocking_modal_open() else 1.0


func _refresh_plant_behavior(allow_transition_feedback: bool) -> void:
	if plant_behavior_presenter == null or plant_view == null or session == null:
		return
	var state: Dictionary = plant_behavior_presenter.refresh(session.plant)
	var active := bool(state.get("active", false))
	var label := str(state.get("label", ""))
	plant_view.set_behavior_state(active, false, label)
	if not allow_transition_feedback or not bool(state.get("just_activated", false)):
		return
	if active_screen != 0 or plant_detail_panel == null or not plant_detail_panel.visible or _is_blocking_modal_open():
		return
	var behavior_id := str(state.get("behavior_id", ""))
	plant_view.play_behavior_trigger(behavior_id, label)
	if feedback_layer != null:
		feedback_layer.play_feedback("plant_behavior", Vector2(0.50, 0.36), 1.0)
	if audio_haptics != null:
		audio_haptics.play_feedback("plant_behavior", state)


func _is_blocking_modal_open() -> bool:
	return dialog_open or professor_story_open or settings_modal_open or seed_selector_open or herbarium_open or daily_challenge_open or botanical_pack_open or level_progression_open or grower_journal_open or care_center_open or plant_diagnosis_open or cosmetic_modal_open or room_decoration_open or return_summary_open or save_recovery_open or save_failure_open or local_backup_open


func _sync_background_animation_state() -> void:
	var should_pause := session.paused or _is_blocking_modal_open()
	var stabilize_fast_time_visuals := session.speed_multiplier >= 100.0
	room_overview.set_paused(should_pause)
	room_overview.set_fast_time_visuals(stabilize_fast_time_visuals)
	player_room_view.set_paused(should_pause)
	player_room_view.set_plant_drag_enabled(_room_plant_drag_available())
	player_room_view.set_fast_time_visuals(stabilize_fast_time_visuals)
	greenhouse_preview_view.set_paused(should_pause)
	greenhouse_preview_view.set_fast_time_visuals(stabilize_fast_time_visuals)
	plant_view.set_paused(should_pause)
	plant_view.set_fast_time_visuals(stabilize_fast_time_visuals)


func _refresh_shop_buy_button(button: Button, item_id: String, price: int) -> void:
	botanist_shop_presenter.refresh_buy_button(button, session, item_id, price)


func _refresh_equipment_shop() -> void:
	for equipment_id in GameSession.EQUIPMENT_ORDER:
		var state := session.get_equipment_upgrade_state(equipment_id)
		var level_label := shop_equipment_level_labels.get(equipment_id) as Label
		var effect_label := shop_equipment_effect_labels.get(equipment_id) as Label
		var button := shop_equipment_buttons.get(equipment_id) as Button
		if level_label == null or effect_label == null or button == null or state.is_empty():
			continue
		level_label.text = "ÚROVEŇ %d / %d" % [int(state.get("level", 1)), int(state.get("max_level", GameSession.EQUIPMENT_MAX_LEVEL))]
		var current_effect := str(state.get("current_effect", ""))
		if bool(state.get("is_max", false)):
			effect_label.text = "%s\nMAXIMUM" % current_effect
			button.text = "MAXIMUM"
			TooltipPolicy.apply(button, "Tato pomůcka je plně vylepšená.")
			button.disabled = true
		elif not bool(state.get("unlocked", false)):
			effect_label.text = "%s\n→ %s" % [current_effect, str(state.get("next_effect", ""))]
			button.text = "OD ÚR. %d" % int(state.get("unlock_level", 1))
			TooltipPolicy.apply(button, "Odemkne se na úrovni hráče %d." % int(state.get("unlock_level", 1)))
			button.disabled = true
		else:
			effect_label.text = "%s\n→ %s" % [current_effect, str(state.get("next_effect", ""))]
			button.text = "VYLEPŠIT · %d" % int(state.get("price", 0))
			TooltipPolicy.apply(button, "Vylepšit za %d mincí." % int(state.get("price", 0)))
			button.disabled = not bool(state.get("affordable", false))


func _get_display_day() -> int:
	return session.get_world_day()


func _set_day_display(display_day: int) -> void:
	day_hud_presenter.refresh(display_day)


func _refresh_coin_display() -> void:
	var current_coins := session.coins
	if last_coins_seen < 0:
		last_coins_seen = current_coins
		_set_coin_count(float(current_coins))
		return
	if current_coins == last_coins_seen:
		return
	var previous_coins := last_coins_seen
	last_coins_seen = current_coins
	if coin_count_tween != null and coin_count_tween.is_valid():
		coin_count_tween.kill()
	if current_coins > previous_coins:
		coin_count_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		coin_count_tween.tween_method(_set_coin_count, float(previous_coins), float(current_coins), 0.58)
		_animate_coin_gain(current_coins - previous_coins)
	else:
		_set_coin_count(float(current_coins))


func _set_coin_count(value: float) -> void:
	coin_hud_presenter.refresh(value)


func _animate_coin_gain(gained_coins: int) -> void:
	coin_icon.pivot_offset = coin_icon.size * 0.5
	coin_icon.scale = Vector2(0.88, 0.88)
	coin_icon.rotation = -0.08
	var coin_icon_tween := create_tween().set_parallel(true)
	coin_icon_tween.tween_property(coin_icon, "scale", Vector2.ONE, 0.34).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	coin_icon_tween.tween_property(coin_icon, "rotation", 0.0, 0.34).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	coins_label.pivot_offset = coins_label.size * 0.5
	coins_label.scale = Vector2(0.76, 0.76)
	var icon_tween := create_tween()
	icon_tween.tween_property(coins_label, "scale", Vector2(1.18, 1.18), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	icon_tween.tween_property(coins_label, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	var root_origin := get_global_rect().position
	var icon_origin := coin_icon.get_global_rect().position - root_origin
	var gain_label := Label.new()
	gain_label.text = "+%d" % gained_coins
	gain_label.position = icon_origin + Vector2(25.0, -2.0)
	gain_label.size = Vector2(72.0, 26.0)
	gain_label.z_index = 121
	gain_label.add_theme_font_size_override("font_size", 17)
	gain_label.add_theme_color_override("font_color", Color("#fff4a8"))
	gain_label.add_theme_color_override("font_shadow_color", COLORS.soil)
	gain_label.add_theme_constant_override("shadow_offset_x", 2)
	gain_label.add_theme_constant_override("shadow_offset_y", 2)
	add_child(gain_label)
	var label_tween := create_tween().set_parallel(true)
	label_tween.tween_property(gain_label, "position:y", gain_label.position.y - 34.0, 0.72).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	label_tween.tween_property(gain_label, "modulate:a", 0.0, 0.24).set_delay(0.52)
	label_tween.tween_callback(gain_label.queue_free).set_delay(0.78)

	for index in range(3):
		var flying_coin := TextureRect.new()
		flying_coin.texture = CoinTexture
		flying_coin.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		flying_coin.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		flying_coin.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		flying_coin.size = Vector2(25, 25)
		flying_coin.position = icon_origin + Vector2(7.0, 7.0)
		flying_coin.pivot_offset = flying_coin.size * 0.5
		flying_coin.z_index = 120
		flying_coin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(flying_coin)
		var offset_x := float(index - 1) * 17.0
		var coin_tween := create_tween().set_parallel(true)
		coin_tween.tween_property(flying_coin, "position", flying_coin.position + Vector2(offset_x, -43.0 - index * 7.0), 0.62).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		coin_tween.tween_property(flying_coin, "rotation", (-0.5 + index * 0.5), 0.62)
		coin_tween.tween_property(flying_coin, "modulate:a", 0.0, 0.22).set_delay(0.43)
		coin_tween.tween_callback(flying_coin.queue_free).set_delay(0.68)


func _refresh_xp_display() -> void:
	var current_xp := session.xp
	xp_hud_presenter.refresh(session.get_level(), current_xp % 100)
	if last_xp_seen < 0:
		last_xp_seen = current_xp
		xp_bar.value = session.get_level_progress()
		return
	if current_xp == last_xp_seen:
		return
	var previous_xp := last_xp_seen
	last_xp_seen = current_xp
	if current_xp > previous_xp:
		_animate_xp_gain(previous_xp, current_xp)
	else:
		if xp_tween != null and xp_tween.is_valid():
			xp_tween.kill()
		xp_bar.value = session.get_level_progress()


func _animate_xp_gain(previous_xp: int, current_xp: int) -> void:
	if xp_tween != null and xp_tween.is_valid():
		xp_tween.kill()
	xp_gain_label.text = "+%d XP" % (current_xp - previous_xp)
	xp_gain_label.modulate = Color(1.0, 1.0, 1.0, 0.0)
	xp_gain_label.scale = Vector2(0.72, 0.72)
	xp_gain_label.pivot_offset = xp_gain_label.size * 0.5
	var feedback_tween := create_tween().set_parallel(true)
	feedback_tween.tween_property(xp_gain_label, "modulate:a", 1.0, 0.16)
	feedback_tween.tween_property(xp_gain_label, "scale", Vector2.ONE, 0.24).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	feedback_tween.tween_property(xp_gain_label, "modulate:a", 0.0, 0.28).set_delay(0.72)
	feedback_tween.tween_callback(_clear_xp_gain).set_delay(1.02)

	xp_bar.value = float(previous_xp % 100)
	xp_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var previous_level := int(previous_xp / 100)
	var current_level := int(current_xp / 100)
	if previous_level == current_level:
		xp_tween.tween_property(xp_bar, "value", float(current_xp % 100), 0.48)
		return
	xp_tween.tween_property(xp_bar, "value", 100.0, 0.38)
	for _completed_level in range(previous_level + 1, current_level):
		xp_tween.tween_callback(_set_xp_bar_value.bind(0.0))
		xp_tween.tween_property(xp_bar, "value", 100.0, 0.32)
	xp_tween.tween_callback(_set_xp_bar_value.bind(0.0))
	xp_tween.tween_property(xp_bar, "value", float(current_xp % 100), 0.38)


func _set_xp_bar_value(value: float) -> void:
	xp_bar.value = value


func _clear_xp_gain() -> void:
	xp_gain_label.text = ""


func _update_storage_panel() -> void:
	storage_pipeline_presenter.refresh(session)


func _update_storage_steps(active_step: int) -> void:
	storage_pipeline_presenter.update_steps(active_step)


func _update_customer_orders() -> void:
	if customer_orders_panel == null:
		return
	customer_orders_panel.refresh(session)


func _order_accent(accent_id: String) -> Color:
	return customer_orders_panel.get_order_accent(accent_id) if customer_orders_panel != null else ComicUITheme.GREEN


func _show_dialog(message: String) -> void:
	if is_garden_handover_active or professor_story_open:
		return
	if not guide_dialog_presenter.is_bound():
		return
	var mood := guide_dialog_presenter.refresh(message)
	var character := guide_modal_character
	if character != null:
		character.set_mood(mood)
		character.play_talk()


func _open_intro_guide() -> void:
	if not is_inside_tree() or session == null:
		return
	_start_garden_handover(false)


func _start_garden_handover(replay: bool) -> void:
	if session == null or guide_modal == null:
		return
	return_to_herbarium_after_handover = replay
	is_garden_handover_active = true
	var state := garden_handover_presenter.begin(replay)
	_apply_garden_handover_mode()
	_render_garden_handover_state(state)
	_set_guide_modal_open(true, not session.reduced_motion)


func _apply_garden_handover_mode() -> void:
	if guide_modal_card != null:
		guide_modal_card.set_anchor(SIDE_BOTTOM, GARDEN_HANDOVER_CARD_BOTTOM)
	if guide_modal_confirm_button != null:
		guide_modal_confirm_button.text = "DALŠÍ"
	if guide_modal_close_button != null:
		guide_modal_close_button.text = "×"
		TooltipPolicy.apply(guide_modal_close_button, "PŘESKOČIT PŘEDÁNÍ")
	if guide_modal_name_label != null:
		guide_modal_name_label.text = "PROFESOR BAZAL"


func _apply_normal_guide_mode() -> void:
	if guide_modal_card != null:
		guide_modal_card.set_anchor(SIDE_BOTTOM, GUIDE_MODAL_CARD_BOTTOM)
	if guide_modal_confirm_button != null:
		guide_modal_confirm_button.text = "ROZUMÍM"
	if guide_modal_close_button != null:
		TooltipPolicy.apply(guide_modal_close_button, "Zavřít")
	if guide_modal_name_label != null:
		guide_modal_name_label.text = "PROFESOR BAZAL"


func _garden_handover_title(state: Dictionary) -> String:
	var title := str(state.get("title", "")).strip_edges()
	var page_number := int(state.get("page_number", 0))
	var page_count := int(state.get("page_count", 0))
	if title != "" and page_number > 0 and page_count > 0:
		return "%s · %d/%d" % [title, page_number, page_count]
	if page_number > 0 and page_count > 0:
		return "%d/%d" % [page_number, page_count]
	return title


func _garden_handover_body(state: Dictionary) -> String:
	return str(state.get("body", ""))


func _garden_handover_confirm_label(state: Dictionary) -> String:
	return str(state.get("confirm_label", "DALŠÍ")).strip_edges()


func _garden_handover_is_finished(state: Dictionary) -> bool:
	return bool(state.get("finished", false))


func _garden_handover_mood(state: Dictionary) -> int:
	return int(state.get("mood", 0))


func _render_garden_handover_state(state: Dictionary) -> void:
	var title := _garden_handover_title(state)
	var body := _garden_handover_body(state)
	var message_parts := PackedStringArray()
	if title != "":
		message_parts.append(title)
		message_parts.append("")
	if body != "":
		message_parts.append(body)
	var content := "\n".join(message_parts)
	if guide_modal_label != null:
		guide_modal_label.text = content
	var confirm_label := _garden_handover_confirm_label(state)
	if guide_modal_confirm_button != null:
		guide_modal_confirm_button.text = confirm_label
	if guide_modal_character != null:
		guide_modal_character.set_mood(_garden_handover_mood(state))
		if not _garden_handover_is_finished(state):
			guide_modal_character.play_talk()


func _progress_garden_handover() -> void:
	var state := garden_handover_presenter.advance()
	_render_garden_handover_state(state)
	if _garden_handover_is_finished(state):
		_apply_garden_handover_finalize(state)


func _apply_garden_handover_finalize(_state: Dictionary) -> void:
	var open_herbarium_again := return_to_herbarium_after_handover
	return_to_herbarium_after_handover = false
	is_garden_handover_active = false
	_set_guide_modal_open(false, false)
	_apply_normal_guide_mode()
	if not open_herbarium_again:
		if not session.intro_completed:
			session.intro_completed = true
			autosave_accumulator = 0.0
			_save_current_session()
		_show_dialog(session.get_journey_dialog_text())
	else:
		_set_herbarium_open(true)
	garden_handover_presenter.reset()


func _skip_garden_handover() -> void:
	if not is_garden_handover_active:
		return
	var state := garden_handover_presenter.skip()
	_apply_garden_handover_finalize(state)


func _open_garden_handover_replay() -> void:
	call_deferred("_start_garden_handover", true)


func _on_guide_modal_confirm_pressed() -> void:
	if is_garden_handover_active:
		_progress_garden_handover()
	else:
		_close_guide_modal()


func _on_guide_modal_close_pressed() -> void:
	if is_garden_handover_active:
		_skip_garden_handover()
	else:
		_close_guide_modal()


func _on_journey_changed(_step: int, _previous_step: int) -> void:
	_show_dialog(session.get_journey_dialog_text())
	if feedback_layer != null:
		feedback_layer.play_feedback("objective", Vector2(0.50, 0.46), 0.85)


func _on_slot_unlocked(slot_index: int, _level: int) -> void:
	if room_overview != null:
		room_overview.trigger_unlock_pulse(slot_index)
	if feedback_layer != null:
		feedback_layer.play_feedback("unlock", Vector2(0.50, 0.48), 1.0)
	if _level > 1 and not save_recovery_open:
		call_deferred("_open_level_progression")


func _on_session_feedback(kind: String, slot_index: int, payload: Dictionary) -> void:
	# Automatické změny životního cyklu nejsou přímá odezva na dotyk. Přes
	# celoplošný modal nebo jinou záložku by rušily scroll a vypadaly jako bliknutí;
	# stav přesto zůstane vidět v Centru péče a v návratovém souhrnu.
	if kind in ["care_reminder", "plant_wilted", "plant_dead"] and (active_screen != 0 or _is_blocking_modal_open()):
		return
	if kind == "plant_behavior" and (active_screen != 0 or plant_detail_panel == null or not plant_detail_panel.visible or _is_blocking_modal_open()):
		return
	if kind == "light" and room_overview != null:
		room_overview.play_light_toggle(slot_index, bool(payload.get("enabled", false)))
	if audio_haptics != null:
		var audio_kind := kind
		if kind in ["plant_wilted", "plant_dead"]:
			audio_kind = "care"
		elif kind in ["care_reminder", "plant_cleared"]:
			audio_kind = "objective"
		elif kind == "plant_rescued":
			audio_kind = "growth"
		audio_haptics.play_feedback(audio_kind, payload)
	if plant_view != null and slot_index == session.selected_plant_index:
		match kind:
			"water": plant_view.play_action("water")
			"fertilize", "seed": plant_view.play_action("fertilize")
			"light": plant_view.play_action("light")
			"wind", "treatment": plant_view.play_action("wind")
			"growth": plant_view.play_action("growth")
			"harvest": plant_view.play_action("harvest")
			"plant_rescued": plant_view.play_action("growth")
			"plant_behavior":
				var behavior_id := str(payload.get("behavior_id", ""))
				var behavior_label := str(payload.get("label", ""))
				plant_view.play_behavior_trigger(behavior_id, behavior_label)
	if feedback_layer == null:
		return
	match kind:
		"water": feedback_layer.play_feedback("water", Vector2(0.50, 0.50), 0.65)
		"fertilize": feedback_layer.play_feedback("fertilize", Vector2(0.50, 0.51), 0.70)
		"treatment": feedback_layer.play_feedback("fertilize", Vector2(0.50, 0.49), 0.82)
		"growth": feedback_layer.play_feedback("growth", Vector2(0.50, 0.48), 1.0)
		"harvest": feedback_layer.play_feedback("harvest", Vector2(0.50, 0.49), 1.0)
		"sale": feedback_layer.play_feedback("coins", Vector2(0.55, 0.64), 1.0)
		"order_complete": feedback_layer.play_feedback("journey_complete", Vector2(0.52, 0.50), 1.10)
		"mastery_reward": feedback_layer.play_feedback("journey_complete", Vector2(0.52, 0.50), 1.10)
		"daily_complete": feedback_layer.play_feedback("objective", Vector2(0.50, 0.46), 0.95)
		"daily_reward": feedback_layer.play_feedback("journey_complete", Vector2(0.52, 0.50), 1.10)
		"level_reward": feedback_layer.play_feedback("journey_complete", Vector2(0.52, 0.50), 1.10)
		"unlock": feedback_layer.play_feedback("unlock", Vector2(0.50, 0.48), 1.0)
		"journey_complete": feedback_layer.play_feedback("journey_complete", Vector2(0.50, 0.46), 1.15)
		"objective": feedback_layer.play_feedback("objective", Vector2(0.50, 0.46), 0.85)
		"care_reminder": feedback_layer.play_feedback("warning", Vector2(0.50, 0.44), 0.72)
		"plant_wilted": feedback_layer.play_feedback("warning", Vector2(0.50, 0.48), 0.95)
		"plant_dead": feedback_layer.play_feedback("warning", Vector2(0.50, 0.48), 1.05)
		"plant_rescued": feedback_layer.play_feedback("growth", Vector2(0.50, 0.48), 0.82)
		"plant_cleared": feedback_layer.play_feedback("objective", Vector2(0.50, 0.50), 0.58)
		"plant_behavior": feedback_layer.play_feedback("plant_behavior", Vector2(0.50, 0.36), 1.0)
		_:
			pass
	if kind == "journey_complete":
		_show_dialog("První cyklus je hotový! Získal jsi %d mincí a %d XP. Další meta: odemykej stojan a pěstuj více bazalek najednou." % [int(payload.get("coins", 25)), int(payload.get("xp", 40))])
		if not is_garden_handover_active and not professor_story_open:
			_set_guide_modal_open(true, not session.reduced_motion)
	elif kind == "order_complete":
		if str(payload.get("order_kind", "single")) == "greenhouse":
			_show_dialog("Skleníková zakázka pro %s je splněná! Bonus za %s: %d mincí a %d XP." % [str(payload.get("customer", "odběratele")), str(payload.get("crop_name", "sklizeň")).to_lower(), int(payload.get("coins", 0)), int(payload.get("xp", 0))])
		elif str(payload.get("order_kind", "single")) == "blend":
			_show_dialog("Zakázka pro %s je splněná! Směs ze dvou balíčků vynesla %d mincí a %d XP." % [str(payload.get("customer", "odběratele")), int(payload.get("coins", 0)), int(payload.get("xp", 0))])
		else:
			_show_dialog("Zakázka pro %s je splněná! Kvalita %d %% vynesla %d mincí a %d XP." % [str(payload.get("customer", "odběratele")), roundi(float(payload.get("quality", 0.0)) * 100.0), int(payload.get("coins", 0)), int(payload.get("xp", 0))])
		if not is_garden_handover_active and not professor_story_open:
			_set_guide_modal_open(true, not session.reduced_motion)


func _on_reduce_motion_toggled(enabled: bool) -> void:
	if session == null:
		return
	session.reduced_motion = enabled
	_apply_motion_preference()
	_refresh_audio_settings()
	_save_current_session()
	_show_dialog("Omezený pohyb je zapnutý. Efekty zůstanou čitelné, ale budou kratší a bez průběžného houpání." if enabled else "Plné animace jsou znovu zapnuté.")


func _apply_motion_preference() -> void:
	if feedback_layer != null:
		feedback_layer.set_reduced_motion(session.reduced_motion)
	if plant_view != null:
		plant_view.set_reduced_motion(session.reduced_motion)
	if room_overview != null:
		room_overview.set_reduced_motion(session.reduced_motion)
	if player_room_view != null:
		player_room_view.set_reduced_motion(session.reduced_motion)
	if greenhouse_preview_view != null:
		greenhouse_preview_view.set_reduced_motion(session.reduced_motion)
	if guide_modal_character != null:
		guide_modal_character.set_reduced_motion(session.reduced_motion)
	if reduce_motion_button != null:
		reduce_motion_button.set_pressed_no_signal(session.reduced_motion)
	if settings_motion_button != null:
		settings_motion_button.set_pressed_no_signal(not session.reduced_motion)


func _prepare_guide_capture(mood: int, message: String, fixed_time: float) -> void:
	_show_dialog(message)
	var character := guide_modal_character
	if character == null:
		return
	character.set_capture_state(mood, fixed_time)
	_set_guide_modal_open(true, false)
	# Preserve the exact user-approved Phase 6 pose without depending on how
	# many frames of the live entrance tween happened before the screenshot.
	guide_modal_character.position += GUIDE_APPROVAL_CAPTURE_CHARACTER_OFFSET
	guide_modal_card.position += GUIDE_APPROVAL_CAPTURE_CARD_OFFSET
	guide_modal.set_meta("capture_mood", character.get_mood_name())
	guide_modal.set_meta("capture_pose", "phase6_approved_v1")


func _finish_guide_capture() -> void:
	var character := guide_modal_character
	if character == null:
		return
	_set_guide_modal_open(false, false)
	character.resume_live_animation()


func _prepare_audio_settings_capture() -> void:
	_set_guide_modal_open(false, false)
	_change_screen(0)
	_open_room()
	if audio_haptics != null:
		audio_haptics.set_capture_mode(true)
	_set_settings_modal_open(true)
	if audio_haptics != null:
		audio_haptics.set_capture_mode(true)
	audio_settings_presenter.show_status("Hudba 55 % · efekty 80 % · mobilní odezva zapnutá")
	settings_modal.set_meta("capture_state", "phase9_audio_settings_candidate_v1")


func _finish_audio_settings_capture() -> void:
	_set_settings_modal_open(false)
	if audio_haptics != null:
		audio_haptics.set_capture_mode(false)
	_apply_audio_settings()


func _prepare_daily_challenge_capture() -> void:
	_set_guide_modal_open(false, false)
	_set_settings_modal_open(false)
	_set_seed_selector_open(false)
	_set_herbarium_open(false)
	_change_screen(0)
	_open_room()
	session.world_elapsed_seconds = PlantSimulation.ENVIRONMENT_DAY_SECONDS
	session.plant.stage = PlantSimulation.Stage.VEGETATIVE
	session.plant.growth_percent = 68.0
	session.plant.moisture = 74.0
	session.plant.disease_level = 0
	session.daily_challenge_issued_day = session.get_world_day_index()
	session.daily_challenge_weather = session.get_world_weather()
	session.daily_challenge_forecast_weather = session.get_world_weather_for_day_offset(1)
	session.daily_challenge_id = "prepare_rain"
	session.daily_challenge_completed = false
	session.daily_challenge_claimed = false
	for plant in session.plants:
		plant.sync_environment(session.world_elapsed_seconds)
	_set_daily_challenge_open(true)
	daily_challenge_modal.set_meta("capture_state", "phase72_forecast_daily_challenge_candidate_v1")


func _finish_daily_challenge_capture() -> void:
	_set_daily_challenge_open(false)


func _prepare_cosmetic_showroom_capture() -> void:
	_set_daily_challenge_open(false)
	_set_guide_modal_open(false, false)
	session.unlocked_room_themes = ["sunrise", "lagoon", "amethyst"]
	session.coins = 120
	session.unlock_or_select_room_theme("lagoon")
	session.unlock_or_select_room_theme("amethyst")
	room_overview.set_cosmetic_theme("amethyst")
	_set_cosmetic_modal_open(true)
	cosmetic_modal.set_meta("capture_state", "phase14_cosmetic_showroom_candidate_v1")


func _finish_cosmetic_showroom_capture() -> void:
	_set_cosmetic_modal_open(false)
	session.unlock_or_select_room_theme("sunrise")
	room_overview.set_cosmetic_theme("sunrise")


func _prepare_phase162_cosmetic_showroom_selected_capture() -> void:
	_finish_professor_research_capture()
	_set_daily_challenge_open(false)
	_set_guide_modal_open(false, false)
	session.professor_research.load_state({
		"completed_count": 3,
	}, GameSession.PROFESSOR_RESEARCH_VARIANT_SCHEMA, true, 0)
	session.unlocked_room_themes = ["sunrise", "lagoon", "amethyst"]
	session.coins = 120
	session.unlock_or_select_room_theme("sunrise")
	room_overview.set_cosmetic_theme("sunrise")
	player_room_view.set_cosmetic_theme("sunrise")
	_set_cosmetic_modal_open(true)
	cosmetic_showroom_scroll.scroll_vertical = 0
	cosmetic_modal.set_meta("capture_state", "phase162_cosmetic_showroom_selected_v1")


func _prepare_phase162_cosmetic_showroom_insufficient_capture() -> void:
	_finish_professor_research_capture()
	_set_daily_challenge_open(false)
	_set_guide_modal_open(false, false)
	session.professor_research.load_state({}, GameSession.PROFESSOR_RESEARCH_VARIANT_SCHEMA, true, 0)
	session.unlocked_room_themes = ["sunrise"]
	session.coins = 0
	session.unlock_or_select_room_theme("sunrise")
	room_overview.set_cosmetic_theme("sunrise")
	player_room_view.set_cosmetic_theme("sunrise")
	_set_cosmetic_modal_open(true)
	cosmetic_showroom_scroll.scroll_vertical = 0
	cosmetic_modal.set_meta("capture_state", "phase162_cosmetic_showroom_insufficient_v1")


func _finish_phase162_cosmetic_showroom_capture() -> void:
	cosmetic_showroom_scroll.scroll_vertical = 0
	session.unlock_or_select_room_theme("sunrise")
	room_overview.set_cosmetic_theme("sunrise")
	player_room_view.set_cosmetic_theme("sunrise")
	_set_cosmetic_modal_open(false)


func _prepare_professor_research_variant_capture(cycle_id: int, capture_state: String) -> void:
	if session == null or professor_story_modal == null:
		return
	var safe_cycle: int = maxi(0, cycle_id)
	var safe_day: int = safe_cycle * 7
	session.professor_research.load_state({}, GameSession.PROFESSOR_RESEARCH_VARIANT_SCHEMA, true, safe_day)
	session.professor_research.start(safe_cycle, safe_day)
	professor_story_content_mode = "weekly_research"
	professor_story_modal.visible = true
	professor_story_modal.move_to_front()
	professor_story_scroll.scroll_vertical = 0
	if professor_story_modal != null:
		professor_story_modal.set_meta("capture_state", capture_state)
		_refresh_professor_story()


func _finish_professor_research_capture() -> void:
	_set_professor_story_open(false)


func _prepare_research_study_showroom_locked_capture() -> void:
	_finish_professor_research_capture()
	_set_daily_challenge_open(false)
	_set_guide_modal_open(false, false)
	session.unlocked_room_themes = ["sunrise", "lagoon", "amethyst"]
	session.unlock_or_select_room_theme("amethyst")
	room_overview.set_cosmetic_theme("amethyst")
	_set_cosmetic_modal_open(true)
	cosmetic_showroom_scroll.scroll_vertical = 4096
	cosmetic_modal.set_meta("capture_state", "phase99_cosmetic_showroom_research_study_locked_v1")


func _prepare_research_study_showroom_selected_capture() -> bool:
	_finish_professor_research_capture()
	_set_daily_challenge_open(false)
	_set_guide_modal_open(false, false)
	session.coins = 360
	session.professor_research.load_state({
		"completed_count": GameSession.RESEARCH_STUDY_COMPLETED_REQUIRED,
	}, GameSession.PROFESSOR_RESEARCH_VARIANT_SCHEMA, true, 0)
	if session.professor_story != null and session.professor_story.has_method("load_state"):
		session.professor_story.load_state({
			"lost_herbarium_pages": {"seen": true, "claimed": true},
			"silver_sage_legacy": {"seen": true, "claimed": true},
			"grand_herbarium_exhibition": {"seen": true, "claimed": true},
		}, "grand_herbarium_exhibition", true, GameSession.PROFESSOR_STORY_CHAPTER_THREE_SCHEMA, session.get_available_species())
		session._sync_professor_story_storage()
	else:
		push_error("Phase 99 research-study capture requires direct chapter claim API for the finale.")
		return false
	if not session.unlock_or_select_room_theme("research_study"):
		push_error("Phase 99 research-study capture could not unlock selected room theme after completed_count seed.")
		return false
	room_overview.set_cosmetic_theme("research_study")
	_set_cosmetic_modal_open(true)
	cosmetic_showroom_scroll.scroll_vertical = 4096
	cosmetic_modal.set_meta("capture_state", "phase99_cosmetic_showroom_research_study_selected_v1")
	return true


func _finish_research_study_showroom_capture() -> void:
	cosmetic_showroom_scroll.scroll_vertical = 0
	session.unlock_or_select_room_theme("sunrise")
	room_overview.set_cosmetic_theme("sunrise")
	_set_cosmetic_modal_open(false)


func _prepare_return_summary_capture() -> void:
	_set_cosmetic_modal_open(false)
	_change_screen(0)
	_open_room()
	return_summary_presenter.refresh(8280.0, "Polojasno", "Správná zálivka")
	return_summary_open = true
	return_summary_modal.visible = true
	return_summary_modal.move_to_front()
	return_summary_modal.set_meta("capture_state", "phase15_return_summary_candidate_v1")


func _finish_return_summary_capture() -> void:
	_close_return_summary()


func _prepare_save_failure_capture() -> void:
	SaveManager.last_save_error_message = "Telefon teď nedokázal zapsat uloženou hru. Poslední změny jsou zatím jen v paměti aplikace."
	save_failure_pending = true
	save_failure_silenced = false
	_open_save_failure()
	save_failure_modal.set_meta("capture_state", "phase46_save_failure_candidate_v1")


func _finish_save_failure_capture() -> void:
	_close_save_failure()
	save_failure_pending = false
	save_failure_silenced = false
	session.unlock_or_select_room_theme("sunrise")
	room_overview.set_cosmetic_theme("sunrise")


func _prepare_local_backup_capture() -> void:
	_set_guide_modal_open(false, false)
	_set_settings_modal_open(false)
	_open_local_backup()
	local_backup_status_label.text = "NALEZENA ZÁLOHA\nÚroveň 4 · 186 mincí · 4/10 rostlin\nPotvrzením nahradíš aktuální postup."
	local_backup_import_armed = true
	local_backup_confirm_button.visible = true
	local_backup_restore_previous_button.visible = true
	local_backup_modal.set_meta("capture_state", "phase47_local_backup_candidate_v1")


func _finish_local_backup_capture() -> void:
	external_file_picker_open = false
	_close_local_backup()


func _prepare_grower_journal_capture() -> void:
	_set_guide_modal_open(false, false)
	_set_settings_modal_open(false)
	_set_level_progression_open(false)
	session.xp = 540
	session.harvest_count = 12
	session.orders_completed = 7
	session.journey_completed = true
	session.species_progress["basil_genovese"] = {"discovered": true, "harvests": 7, "best_quality": 0.94, "orders_completed": 4, "total_dry_g": 31.8, "claimed_tier": 3}
	session.species_progress["mint_peppermint"] = {"discovered": true, "harvests": 4, "best_quality": 0.88, "orders_completed": 2, "total_dry_g": 20.1, "claimed_tier": 2}
	session.species_progress["rosemary_officinalis"] = {"discovered": true, "harvests": 1, "best_quality": 0.79, "orders_completed": 1, "total_dry_g": 6.4, "claimed_tier": 1}
	for slot_index in range(5):
		session.plants[slot_index].stage = PlantSimulation.Stage.VEGETATIVE
		session.plants[slot_index].growth_percent = 42.0 + float(slot_index)
	_set_grower_journal_open(true)
	grower_journal_modal.set_meta("capture_state", "phase49_grower_journal_candidate_v1")


func _finish_grower_journal_capture() -> void:
	_set_grower_journal_open(false)


func _prepare_customer_orders_capture() -> void:
	_set_settings_modal_open(false)
	_set_seed_selector_open(false)
	_set_guide_modal_open(false, false)
	if customer_orders_panel != null:
		customer_orders_panel.visible = true
	_change_screen(1)
	_refresh_ui()
	_scroll_orders_into_view()


func _scroll_orders_into_view() -> void:
	if storage_scroll != null:
		storage_scroll.scroll_vertical = roundi(minf(620.0, maxf(0.0, storage_scroll.get_v_scroll_bar().max_value - storage_scroll.size.y)))


func _on_seed_pressed() -> void:
	match str(seed_button.get_meta("action_mode", "seed")):
		"prune":
			if session.prune_damaged_leaves():
				_save_and_refresh()
			else:
				_refresh_ui()
		"clear":
			if session.clear_dead_plant():
				_save_and_refresh()
		"seed":
			_open_seed_selector()


func _on_water_pressed() -> void:
	if session.water():
		_save_and_refresh()


func _on_lamp_pressed() -> void:
	if session.toggle_lamp():
		_save_and_refresh()


func _on_fertilize_pressed() -> void:
	if session.fertilize():
		_save_and_refresh()


func _on_ventilate_pressed() -> void:
	var treatment_mode := session.plant.disease_level > 0
	var succeeded := session.treat_disease() if treatment_mode else session.ventilate()
	if succeeded:
		_save_and_refresh()


func _on_storage_action() -> void:
	var succeeded := false
	var previous_stage := session.plant.stage
	match previous_stage:
		PlantSimulation.Stage.MATURE:
			succeeded = session.harvest()
		PlantSimulation.Stage.HARVESTED:
			succeeded = session.start_drying()
		PlantSimulation.Stage.DRY:
			succeeded = session.package_harvest()
		PlantSimulation.Stage.PACKAGED:
			succeeded = session.sell_harvest()
		PlantSimulation.Stage.DEAD:
			succeeded = session.clear_dead_plant()
	if succeeded:
		_play_success_pulse(storage_action_button)
		match previous_stage:
			PlantSimulation.Stage.MATURE:
				_show_dialog("Sklizeno! Čerstvá bylinka %s je ve skladu a čeká na sušení." % session.plant.get_short_name())
			PlantSimulation.Stage.HARVESTED:
				_show_dialog("Sušení začalo. Proudění vzduchu teď pomalu odvádí vodu z listů.")
			PlantSimulation.Stage.DRY:
				_show_dialog("%s je zabalená a připravená k prodeji." % session.plant.get_short_name())
			PlantSimulation.Stage.PACKAGED:
				_show_dialog("Prodáno! Mince i úspěšná sklizeň byly připsány.")
		_save_and_refresh()


func _on_order_pressed(index: int) -> void:
	if index < 0 or index >= order_buttons.size():
		return
	if session.fulfill_order(index):
		_play_success_pulse(order_buttons[index])
		_save_and_refresh()
	else:
		_refresh_ui()


func _on_order_decline_pressed(index: int) -> void:
	if index < 0 or index >= order_decline_buttons.size():
		return
	if session.decline_order(index):
		_play_success_pulse(order_decline_buttons[index])
		_save_and_refresh()
	else:
		_refresh_ui()


func _on_buy_seed() -> void:
	var item_id := session.get_shop_seed_item_id("basil_genovese")
	if session.get_shop_stock(item_id) <= 0:
		_show_shop_sold_out("Bazalka je pro dnešek vyprodaná.")
		return
	if session.buy_seed("basil_genovese"):
		botanist_shop_presenter.show_feedback("✓ Semínko bazalky přidáno do skladu.", true)
		_set_botanist_dialog("Bazalka je skvělý začátek. Ať se jí daří!", true)
		_play_success_pulse(buy_seed_button)
		_save_and_refresh()
	else:
		botanist_shop_presenter.show_feedback("Na semínko teď nemáš dost mincí.", false)
		_set_botanist_dialog("Mincí je zatím málo. Vypěstuj a prodej další balíček.")


func _on_buy_mint_seed() -> void:
	var item_id := session.get_shop_seed_item_id("mint_peppermint")
	if session.get_shop_stock(item_id) <= 0:
		_show_shop_sold_out("Máta je pro dnešek vyprodaná.")
		return
	if session.buy_seed("mint_peppermint"):
		botanist_shop_presenter.show_feedback("✓ Semínko máty přidáno do skladu.", true)
		_set_botanist_dialog("Máta provoní celý pokoj. Dobrá volba!", true)
		_play_success_pulse(buy_mint_seed_button)
		_save_and_refresh()
	else:
		botanist_shop_presenter.show_feedback("Na semínko máty teď nemáš dost mincí.", false)
		_set_botanist_dialog("Na mátu si ještě vydělej jedním pěkným balíčkem.")


func _on_buy_species_seed(species_id: String) -> void:
	var species_name := str(session.get_plant_profile(species_id).get("short_name", "Bylinka"))
	var item_id := session.get_shop_seed_item_id(species_id)
	if session.get_shop_stock(item_id) <= 0:
		_show_shop_sold_out("%s je pro dnešek vyprodaný." % species_name)
		return
	if session.buy_seed(species_id):
		botanist_shop_presenter.show_feedback("✓ Semínko %s přidáno do skladu." % species_name.to_lower(), true)
		_set_botanist_dialog("%s potřebuje trpělivost, ale odmění tě vůní." % species_name, true)
		_play_success_pulse(shop_seed_buttons.get(species_id) as Control)
	else:
		botanist_shop_presenter.show_feedback("Na semínko %s teď nemáš dost mincí." % species_name.to_lower(), false)
		_set_botanist_dialog("Na %s zatím chybí pár mincí." % species_name.to_lower())
	_save_and_refresh()


func _on_buy_fertilizer() -> void:
	if session.get_shop_stock(GameSession.SHOP_FERTILIZER_ITEM_ID) <= 0:
		_show_shop_sold_out("Hnojivo je pro dnešek vyprodané.")
		return
	if session.buy_fertilizer():
		botanist_shop_presenter.show_feedback("✓ Dávka hnojiva přidána do skladu.", true)
		_set_botanist_dialog("S hnojivem opatrně. Malá dávka udělá velkou službu!", true)
		_play_success_pulse(buy_fertilizer_button)
		_save_and_refresh()
	else:
		botanist_shop_presenter.show_feedback("Na hnojivo teď nemáš dost mincí.", false)
		_set_botanist_dialog("Hnojivo počká. Nejdřív doplň pokladničku.")


func _on_buy_equipment_upgrade(equipment_id: String) -> void:
	var state := session.get_equipment_upgrade_state(equipment_id)
	if state.is_empty():
		return
	var display_name := str(state.get("name", "POMŮCKA"))
	if session.buy_equipment_upgrade(equipment_id):
		var new_state := session.get_equipment_upgrade_state(equipment_id)
		botanist_shop_presenter.show_feedback("✓ %s vylepšeno na úroveň %d." % [display_name.capitalize(), int(new_state.get("level", 1))], true)
		_set_botanist_dialog("Teď je to pořádné nářadí! Změnu poznáš přímo při péči o rostliny.", true)
		_play_success_pulse(shop_equipment_buttons.get(equipment_id) as Control)
		_save_and_refresh()
	elif bool(state.get("is_max", false)):
		botanist_shop_presenter.show_feedback("%s už má nejvyšší úroveň." % display_name.capitalize(), false)
		_set_botanist_dialog("Lepší už ji neudělám. Tohle vybavení ti vydrží celou sezónu!")
	elif not bool(state.get("unlocked", false)):
		botanist_shop_presenter.show_feedback("Další úroveň se odemkne na úrovni hráče %d." % int(state.get("unlock_level", 1)), false)
		_set_botanist_dialog("Ještě trochu zkušeností. Pak ti ukážu pokročilejší úpravu.")
	else:
		botanist_shop_presenter.show_feedback("Na vylepšení chybí mince.", false)
		_set_botanist_dialog("Kvalitní práce něco stojí. Přines mi další pěknou sklizeň.")


func _show_shop_sold_out(message: String) -> void:
	botanist_shop_presenter.show_feedback("%s Nové zásoby budou zítra." % message, false)
	_set_botanist_dialog("Dnes už není skladem. Zastav se zítra, přivezu čerstvé zásoby.")
	_refresh_ui()


func _play_success_pulse(control: Control) -> void:
	if control == null:
		return
	var previous_tween: Tween
	if control.has_meta("success_tween"):
		previous_tween = control.get_meta("success_tween") as Tween
	if previous_tween != null and previous_tween.is_valid():
		previous_tween.kill()
	control.pivot_offset = control.size * 0.5
	control.scale = Vector2.ONE
	var tween := create_tween()
	control.set_meta("success_tween", tween)
	tween.tween_property(control, "scale", Vector2(1.045, 1.045), 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(control, "scale", Vector2.ONE, 0.20).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _save_and_refresh() -> void:
	_save_current_session()
	_refresh_ui()


func _on_link_clicked(meta: Variant) -> void:
	var url := str(meta)
	if url.begins_with("https://"):
		OS.shell_open(url)


func _knowledge_text() -> String:
	var species_id := session.plant.get_species_id() if session != null else "basil_genovese"
	return plant_presentation_catalog.knowledge_text(species_id)


func _mint_knowledge_text() -> String:
	return plant_presentation_catalog.mint_knowledge_text()


func _rosemary_knowledge_text() -> String:
	return plant_presentation_catalog.rosemary_knowledge_text()

