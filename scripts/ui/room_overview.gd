class_name PlantRoomOverview
extends Control

signal slot_selected(index: int)
signal care_center_requested

const RoomTexture := preload("res://assets/backgrounds/comic_room_rack_v1.png")
const EmptyPotTexture := preload("res://assets/plants/comic/empty_pot_v1.png")
const PlantPresentationCatalogScene := preload("res://scripts/plant_presentation_catalog.gd")
const FontSemiBold := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const FontExtraBold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")

const INK := Color("#163a21")
const CREAM := Color("#fff4cf")
const GREEN := Color("#67d51e")
const DEEP_GREEN := Color("#17621f")
const GOLD := Color("#f4c533")
const TERRACOTTA := Color("#e87838")
const COMIC_INK := Color("#17212b")
const LOCK_PURPLE := Color("#8544c7")
const LOCK_PURPLE_LIGHT := Color("#b975ed")
const LOCK_GOLD := Color("#ffd51e")
const LOCK_GOLD_SHADOW := Color("#d88b08")
const COMIC_BLUE := Color("#138fc7")
const COMIC_CYAN := Color("#39d8ee")
const COMIC_CREAM := Color("#fff0bd")
const COMIC_GREEN := Color("#76d91d")
const COMIC_GREEN_DARK := Color("#258f38")
const COMIC_ORANGE := Color("#ff8c22")
const COMIC_WILT_BADGE := Color("#ffad47")
const COMIC_WILT_BADGE_DARK := Color("#a44e0f")
const COMIC_DEAD_BADGE := Color("#6b6f99")
const COMIC_DEAD_BADGE_DARK := Color("#20243a")
const COMIC_DEAD_BADGE_SHADOW := Color("#111426")
const SOURCE_WIDTH := 941.0
const GRID_SOURCE_WIDTH := 887.0
const GRID_SOURCE_HEIGHT := 1420.0
const SUMMARY_HEIGHT := 180.0
const SUMMARY_SOURCE_SIZE := Vector2(941.0, 180.0)
const SUMMARY_PROGRESS_TRACK := Rect2(191.0, 84.0, 398.0, 34.0)
const SUMMARY_PROGRESS_INNER := Rect2(199.0, 91.0, 382.0, 22.0)
const SLOT_SELECTION_DURATION := 0.34
const LOCK_FEEDBACK_DURATION := 0.34
const SLOT_UNLOCK_DURATION := 0.72
const AMBIENT_REDRAW_INTERVAL := 1.0 / 20.0
const ROUNDED_STYLE_CACHE_LIMIT := 96
const SLOT_SOURCE_X := 100.0
const SLOT_SOURCE_STEP_X := 140.0
const SLOT_SOURCE_WIDTH := 130.0
const SLOT_SOURCE_FIRST_Y := 500.0
const SLOT_SOURCE_SECOND_Y := 820.0
const SLOT_SOURCE_FIRST_HEIGHT := 305.0
const SLOT_SOURCE_SECOND_HEIGHT := 305.0
const SLOT_SOURCE_FIRST_BASELINE_Y := 720.0
const SLOT_SOURCE_SECOND_BASELINE_Y := 1018.0
const SLOT_LABEL_ASPECT := 86.0 / 28.0
const STATUS_BADGE_RADIUS := 12.5
const STATUS_BADGE_SHADOW_OFFSET := Vector2(1.0, 2.0)
const STATUS_BADGE_RIGHT_INSET := 15.0
const STATUS_BADGE_TOP_LIFT := 16.0
const TITLE_SOURCE_RECT := Rect2(184.0, 24.0, 548.0, 92.0)
const COUNT_SOURCE_RECT := Rect2(749.0, 27.0, 108.0, 86.0)
const LIGHT_SOURCE_WIDTH := 84.0
const LIGHT_SOURCE_X := 123.0
const LIGHT_SOURCE_STEP_X := SLOT_SOURCE_STEP_X
const LIGHT_SOURCE_HEIGHT := 20.0
const LIGHT_SOURCE_FIRST_Y := 482.0
const LIGHT_SOURCE_SECOND_Y := 840.0

var session: GameSession
var slot_rects: Array[Rect2] = []
var slot_layout_size := Vector2(-1.0, -1.0)
var detail_rect := Rect2()
var care_button_rect := Rect2()
var animation_time := 0.0
var ambient_redraw_accumulator := 0.0
var animations_paused := false
var reduced_motion := false
var fast_time_visuals := false
var rounded_style_cache: Dictionary = {}
var cosmetic_theme := "sunrise"
var selection_slot_index := -1
var selection_elapsed := 0.0
var selection_pending := false
var lock_feedback_slot_index := -1
var lock_feedback_elapsed := 0.0
var unlock_slot_index := -1
var unlock_elapsed := 0.0
var previous_unlocked_count := -1
var displayed_unlocked_count := 0
var displayed_growth_percent := 0.0
var target_growth_percent := 0.0
var growth_display_initialized := false
var displayed_occupied_count := 0
var displayed_care_attention_count := 0
var plant_presentation_catalog := PlantPresentationCatalogScene.new()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	set_meta("visual_source", "comic_room_phase_2_dynamic")
	set_meta("summary_asset", "comic_code_drawn_v1")
	set_meta("edge_background", "full_width_frame_no_filler")
	set_meta("growth_animation", "left_to_right_tween")
	set_meta("slot_label_source", "comic_code_drawn_v1")
	set_meta("grid_source", "comic_rack_fixed_grid_2x5_v1")
	set_meta("locked_slot_asset", "comic_code_drawn_v1")
	set_meta("room_asset", "comic_room_rack_v1")
	set_meta("header_asset", "comic_code_drawn_v1")
	set_meta("lighting", "optional_two_rows_five_weather_ready")
	set_meta("geometry_set", "comic_room_887x1420_v1")
	set_meta("light_geometry", "background_socket_aligned_segments")
	set_meta("summary_progress_style", "comic_live_percent_v1")
	set_meta("care_center_launcher", "selected_summary_button_v1")
	set_meta("summary_icon_source", "profile_driven_catalog_v1")
	set_meta("ambient_motion", "window_dust_and_weather_tint_v1")
	set_meta("lamp_policy", "manual_supplemental_light_day_night_cloud")
	set_meta("comic_vertical_slice", "profile_driven_catalog_v1")
	set_meta("comic_mature_asset", "catalog:species_stage_texture")
	set_meta("comic_plant_family", "profile_driven_catalog_v1")
	set_meta("comic_plant_states", "seed,sprout,young,mature,sick,harvest_ready,empty")
	set_meta("sprite_canvas", "570x640_bottom_center")
	set_process(true)


func set_session(value: GameSession) -> void:
	session = value
	if session != null:
		target_growth_percent = session.plant.growth_percent
		displayed_growth_percent = target_growth_percent
		growth_display_initialized = true
		previous_unlocked_count = session.get_unlocked_slot_count()
		displayed_unlocked_count = previous_unlocked_count
		displayed_occupied_count = session.get_occupied_count()
		displayed_care_attention_count = session.get_care_attention_count()
	queue_redraw()


func refresh() -> void:
	if session != null:
		target_growth_percent = clampf(session.plant.growth_percent, 0.0, 100.0)
		if not growth_display_initialized or target_growth_percent < displayed_growth_percent:
			displayed_growth_percent = target_growth_percent
			growth_display_initialized = true
		var unlocked_count := session.get_unlocked_slot_count()
		if previous_unlocked_count >= 0 and unlocked_count > previous_unlocked_count:
			unlock_slot_index = unlocked_count - 1
			unlock_elapsed = 0.0
		previous_unlocked_count = unlocked_count
		displayed_unlocked_count = unlocked_count
		displayed_occupied_count = session.get_occupied_count()
		displayed_care_attention_count = session.get_care_attention_count()
	queue_redraw()


func set_paused(value: bool) -> void:
	if animations_paused == value:
		return
	animations_paused = value
	ambient_redraw_accumulator = 0.0
	# Klikaci odezva UI zustava aktivni i pri pozastavene simulaci.
	set_process(true)
	queue_redraw()


func set_reduced_motion(value: bool) -> void:
	reduced_motion = value
	set_meta("reduced_motion", value)
	if value:
		displayed_growth_percent = target_growth_percent
	queue_redraw()


func set_fast_time_visuals(value: bool) -> void:
	if fast_time_visuals == value:
		return
	fast_time_visuals = value
	set_meta("fast_time_visuals_stabilized", value)
	queue_redraw()


func set_cosmetic_theme(theme_id: String) -> void:
	var normalized := theme_id if GameSession.ROOM_THEMES.has(theme_id) else "sunrise"
	if cosmetic_theme == normalized:
		return
	cosmetic_theme = normalized
	set_meta("cosmetic_theme", cosmetic_theme)
	queue_redraw()


func trigger_unlock_pulse(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= GameSession.MAX_PLANT_SLOTS:
		return
	unlock_slot_index = slot_index
	unlock_elapsed = 0.0
	queue_redraw()


func _process(delta: float) -> void:
	var redraw_needed := false
	if not animations_paused and not reduced_motion:
		animation_time += delta
		ambient_redraw_accumulator += delta
		if ambient_redraw_accumulator >= AMBIENT_REDRAW_INTERVAL:
			ambient_redraw_accumulator = fmod(ambient_redraw_accumulator, AMBIENT_REDRAW_INTERVAL)
			redraw_needed = true
		if not is_equal_approx(displayed_growth_percent, target_growth_percent):
			var distance := absf(target_growth_percent - displayed_growth_percent)
			var speed := maxf(5.0, distance / 0.42)
			displayed_growth_percent = move_toward(displayed_growth_percent, target_growth_percent, speed * delta)
	var ui_delta := delta * (3.0 if reduced_motion else 1.0)
	if selection_pending:
		selection_elapsed += ui_delta
		redraw_needed = true
		if selection_elapsed >= SLOT_SELECTION_DURATION:
			var completed_index := selection_slot_index
			selection_pending = false
			selection_slot_index = -1
			selection_elapsed = 0.0
			slot_selected.emit(completed_index)
	if lock_feedback_slot_index >= 0:
		lock_feedback_elapsed += ui_delta
		redraw_needed = true
		if lock_feedback_elapsed >= LOCK_FEEDBACK_DURATION:
			lock_feedback_slot_index = -1
			lock_feedback_elapsed = 0.0
	if unlock_slot_index >= 0:
		unlock_elapsed += ui_delta
		redraw_needed = true
		if unlock_elapsed >= SLOT_UNLOCK_DURATION:
			unlock_slot_index = -1
			unlock_elapsed = 0.0
	if redraw_needed:
		queue_redraw()


func _gui_input(event: InputEvent) -> void:
	var pressed := false
	var position := Vector2.ZERO
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		pressed = true
		position = event.position
	elif event is InputEventScreenTouch and event.pressed:
		pressed = true
		position = event.position
	if not pressed:
		return
	for index in range(slot_rects.size()):
		if slot_rects[index].has_point(position):
			start_slot_selection(index)
			accept_event()
			return
	if session != null and care_button_rect.has_point(position):
		care_center_requested.emit()
		accept_event()
		return
	if session != null and detail_rect.has_point(position):
		slot_selected.emit(session.selected_plant_index)
		accept_event()


func start_slot_selection(index: int) -> void:
	if index < 0 or index >= slot_rects.size():
		return
	if session == null or not session.is_plant_slot_unlocked(index):
		lock_feedback_slot_index = index
		lock_feedback_elapsed = 0.0
		selection_pending = false
		selection_slot_index = -1
		queue_redraw()
		return
	selection_slot_index = index
	selection_elapsed = 0.0
	selection_pending = true
	queue_redraw()


func _draw() -> void:
	var summary_height := _summary_height()
	var room_rect := Rect2(0.0, 0.0, size.x, maxf(1.0, size.y - summary_height))
	draw_texture_rect(RoomTexture, room_rect, false)
	_draw_room_atmosphere(room_rect)
	_draw_cosmetic_atmosphere(room_rect)
	_layout_slots()
	_draw_light_segment_states()
	_draw_title()
	if session != null:
		for index in range(mini(slot_rects.size(), session.plants.size())):
			if index < displayed_unlocked_count:
				_draw_slot(index, slot_rects[index], session.plants[index])
			else:
				_draw_locked_slot(index, slot_rects[index])
	if selection_pending:
		_draw_slot_selection_animation()
	if unlock_slot_index >= 0:
		_draw_slot_unlock_animation()
	if session != null:
		_draw_selected_summary()


func _draw_cosmetic_atmosphere(room_rect: Rect2) -> void:
	if cosmetic_theme == "sunrise":
		return
	if cosmetic_theme == "research_study":
		_draw_research_study_atmosphere(room_rect)
		return
	var accent := Color("#19cbd1") if cosmetic_theme == "lagoon" else Color("#a85bea")
	draw_rect(room_rect, Color(accent, 0.075), true)
	var top_y := room_rect.position.y + room_rect.size.y * 0.055
	for index in range(9):
		var ratio := float(index) / 8.0
		var center := Vector2(lerpf(room_rect.position.x + room_rect.size.x * 0.08, room_rect.end.x - room_rect.size.x * 0.08, ratio), top_y + sin(ratio * PI) * room_rect.size.y * 0.035)
		draw_line(center - Vector2(room_rect.size.x * 0.055, 9.0), center, Color("#352345", 0.62), 2.0, true)
		draw_circle(center, 5.6, Color("#173144", 0.72), true, -1.0, true)
		draw_circle(center - Vector2(0.0, 1.0), 3.7, accent.lightened(0.28), true, -1.0, true)
	for index in range(6):
		var sparkle := room_rect.position + Vector2(room_rect.size.x * (0.12 + float(index) * 0.145), room_rect.size.y * (0.18 + float(index % 3) * 0.12))
		draw_circle(sparkle, 2.2 + float(index % 2), Color(accent.lightened(0.35), 0.62), true, -1.0, true)


func _draw_research_study_atmosphere(room_rect: Rect2) -> void:
	draw_rect(room_rect, Color(DEEP_GREEN, 0.08), true)
	draw_rect(room_rect, Color(GOLD, 0.03), false, 2.0, true)
	var wave_count := 14
	var wave_height := room_rect.size.y * 0.06
	for index in range(wave_count):
		var ratio := float(index) / float(max(1, wave_count - 1))
		var y := room_rect.position.y + room_rect.size.y * (0.28 + ratio * 0.45)
		var wave_width := room_rect.size.x * 0.86
		var x := room_rect.position.x + room_rect.size.x * (0.07 + ratio * 0.07)
		var wave_rect := Rect2(
			Vector2(x, y + sin((animation_time * 1.1) + ratio * PI * 3.0) * wave_height * 0.28),
			Vector2(wave_width, 3.5)
		)
		var alpha: float = 0.14 + (1.0 - abs(ratio - 0.5) * 1.3) * 0.08
		draw_rect(wave_rect, Color(GOLD.lightened(0.10), alpha), true)
	for row in range(9):
		var x := room_rect.position.x + room_rect.size.x * (0.1 + fmod(float(row) * 0.117 + animation_time * 0.07, 0.75))
		var y := room_rect.position.y + room_rect.size.y * (0.18 + float(row % 3) * 0.14 + (sin((animation_time + float(row) * 0.35) * 2.2) * 0.01))
		draw_circle(Vector2(x, y), 2.5 + float(row % 2) * 0.9, Color(GOLD.lightened(0.06), 0.35), true, -1.0, true)
		draw_circle(Vector2(x, y + 12.0), 1.5 + float((row + 2) % 2) * 0.7, Color(DEEP_GREEN.lightened(0.34), 0.32), true, -1.0, true)


func _summary_height() -> float:
	# Preserve the native 941 × 180 ratio instead of flattening the card.
	return clampf(size.x * SUMMARY_HEIGHT / SOURCE_WIDTH, 90.0, 93.0)


func _title_height() -> float:
	return _source_rect_to_room(TITLE_SOURCE_RECT).size.y


func _grid_height() -> float:
	return maxf(1.0, size.y - _summary_height())


func _layout_slots() -> void:
	if slot_rects.size() == GameSession.MAX_PLANT_SLOTS and slot_layout_size.is_equal_approx(size):
		return
	slot_layout_size = size
	slot_rects.clear()
	var summary_y := size.y - _summary_height()
	for index in range(GameSession.MAX_PLANT_SLOTS):
		var column := index % 5
		var row := int(index / 5)
		var source_y := SLOT_SOURCE_FIRST_Y if row == 0 else SLOT_SOURCE_SECOND_Y
		var source_height := SLOT_SOURCE_FIRST_HEIGHT if row == 0 else SLOT_SOURCE_SECOND_HEIGHT
		var source_x := SLOT_SOURCE_X + column * SLOT_SOURCE_STEP_X
		slot_rects.append(_source_rect_to_room(Rect2(source_x, source_y, SLOT_SOURCE_WIDTH, source_height)))
	detail_rect = Rect2(0.0, summary_y, size.x, _summary_height())


func _draw_slot_selection_animation() -> void:
	if selection_slot_index < 0 or selection_slot_index >= slot_rects.size():
		return
	var progress := clampf(selection_elapsed / SLOT_SELECTION_DURATION, 0.0, 1.0)
	var settle := 1.0 - pow(1.0 - minf(progress * 2.8, 1.0), 3.0)
	var pulse := sin(progress * PI)
	var source_scale := size.x / GRID_SOURCE_WIDTH
	var target_rect := slot_rects[selection_slot_index]
	var animated_scale := lerpf(1.035, 1.0, settle) + pulse * 0.003
	var animated_size := target_rect.size * animated_scale
	var animated_rect := Rect2(target_rect.get_center() - animated_size * 0.5, animated_size)
	var alpha := clampf(progress * 5.5, 0.0, 1.0)

	var outer := StyleBoxFlat.new()
	outer.bg_color = Color.TRANSPARENT
	outer.border_color = Color(0.08, 0.36, 0.04, (0.84 + pulse * 0.12) * alpha)
	outer.set_border_width_all(maxi(2, roundi(2.4 * source_scale)))
	outer.set_corner_radius_all(maxi(8, roundi(8.0 * source_scale)))
	outer.anti_aliasing = true
	outer.shadow_color = Color(0.29, 0.93, 0.04, (0.28 + pulse * 0.18) * alpha)
	outer.shadow_size = maxi(2, roundi((2.0 + pulse * 1.7) * source_scale))
	draw_style_box(outer, animated_rect)

	var frame := StyleBoxFlat.new()
	frame.bg_color = Color(0.92, 1.0, 0.75, (0.12 + pulse * 0.04) * alpha)
	frame.border_color = Color(0.38, 0.91, 0.06, alpha)
	frame.set_border_width_all(maxi(2, roundi(2.0 * source_scale)))
	frame.set_corner_radius_all(maxi(7, roundi(7.0 * source_scale)))
	frame.anti_aliasing = true
	draw_style_box(frame, animated_rect)

	var highlight := StyleBoxFlat.new()
	highlight.bg_color = Color.TRANSPARENT
	highlight.border_color = Color(0.81, 1.0, 0.31, (0.60 + pulse * 0.32) * alpha)
	highlight.set_border_width_all(maxi(1, roundi(0.8 * source_scale)))
	highlight.set_corner_radius_all(maxi(6, roundi(6.0 * source_scale)))
	highlight.anti_aliasing = true
	draw_style_box(highlight, animated_rect.grow(-2.2 * source_scale))


func _draw_slot_unlock_animation() -> void:
	if unlock_slot_index < 0 or unlock_slot_index >= slot_rects.size():
		return
	var progress := clampf(unlock_elapsed / SLOT_UNLOCK_DURATION, 0.0, 1.0)
	var pulse := sin(progress * PI)
	var rect := slot_rects[unlock_slot_index]
	var center := rect.get_center()
	var radius := lerpf(rect.size.x * 0.15, rect.size.x * 0.62, progress)
	draw_circle(center, radius, Color(1.0, 0.82, 0.16, pulse * 0.22), true, -1.0, true)
	for index in range(8):
		var angle := TAU * float(index) / 8.0 + progress * 0.55
		var distance := rect.size.x * (0.22 + progress * 0.36)
		var sparkle := center + Vector2(cos(angle), sin(angle)) * distance
		draw_circle(sparkle, maxf(1.4, rect.size.x * 0.035 * pulse), Color("#fff08a", pulse), true, -1.0, true)


func _draw_room_atmosphere(room_rect: Rect2) -> void:
	if fast_time_visuals or session == null or session.plant == null:
		return
	var weather := session.plant.weather_name
	var time_of_day := fmod(8.0 + session.plant.get_biological_day() * 24.0, 24.0)
	var is_night := time_of_day < 6.0 or time_of_day > 20.0
	if is_night:
		draw_rect(room_rect, Color(0.07, 0.16, 0.38, 0.24), true)
	elif weather == "Déšť":
		draw_rect(room_rect, Color(0.20, 0.38, 0.50, 0.15), true)
	elif weather == "Zataženo":
		draw_rect(room_rect, Color(0.31, 0.48, 0.56, 0.10), true)

	# Deterministic dust motes keep the sunny window alive without competing
	# with the plants. Rain and night intentionally suppress them.
	if is_night or weather == "Déšť":
		return
	var window_rect := _source_rect_to_room(Rect2(112.0, 0.0, 656.0, 445.0))
	var drift := fmod(animation_time * 5.0, maxf(1.0, window_rect.size.y))
	for index in range(7):
		var x_ratio := fmod(0.13 + float(index) * 0.173, 0.88)
		var base_y := fmod(float(index * 67) + drift, window_rect.size.y)
		var mote := window_rect.position + Vector2(window_rect.size.x * x_ratio, window_rect.size.y - base_y)
		var alpha := 0.20 + 0.09 * sin(animation_time * 1.2 + float(index))
		draw_circle(mote, 1.0 + float(index % 3) * 0.45, Color(1.0, 0.92, 0.50, alpha), true, -1.0, true)


func _low_ambient_factor() -> float:
	if fast_time_visuals or session == null or session.plant == null:
		return 0.0
	var time_of_day := fmod(8.0 + session.plant.get_biological_day() * 24.0, 24.0)
	if time_of_day < 6.0 or time_of_day > 20.0:
		return 1.0
	if session.plant.weather_name == "Déšť":
		return 0.72
	if session.plant.weather_name == "Zataženo":
		return 0.50
	return 0.0


func _draw_light_segment_states() -> void:
	if session == null:
		return
	var low_ambient := _low_ambient_factor()
	for row in range(2):
		for column in range(5):
			var index := row * 5 + column
			var segment := _light_segment_rect(row, column)
			var active := index < displayed_unlocked_count and session.plants[index].stage != PlantSimulation.Stage.EMPTY and session.plants[index].lamp_on
			if not active:
				# The background already contains an unobtrusive dark fixture.
				continue
			var glow_alpha := 0.22 + low_ambient * 0.20
			draw_circle(segment.get_center() + Vector2(0.0, segment.size.y * 1.7), segment.size.x * 0.63, Color(1.0, 0.75, 0.18, glow_alpha * 0.25), true, -1.0, true)
			_draw_rounded(segment.grow(1.2), Color("#ffe98b"), Color("#8f5516"), 1, 5, Color(1.0, 0.67, 0.08, glow_alpha), 4)
			draw_line(segment.position + Vector2(5.0, segment.size.y * 0.40), Vector2(segment.end.x - 5.0, segment.position.y + segment.size.y * 0.40), Color("#fffdf1"), 1.5, true)


func _light_segment_rect(row: int, column: int) -> Rect2:
	var source_y := LIGHT_SOURCE_FIRST_Y if row == 0 else LIGHT_SOURCE_SECOND_Y
	return _source_rect_to_room(Rect2(
		LIGHT_SOURCE_X + column * LIGHT_SOURCE_STEP_X,
		source_y,
		LIGHT_SOURCE_WIDTH,
		LIGHT_SOURCE_HEIGHT
	))


func _draw_title() -> void:
	var title_rect := _source_rect_to_room(TITLE_SOURCE_RECT)
	var count_rect := _source_rect_to_room(COUNT_SOURCE_RECT)
	var scale_factor := size.x / GRID_SOURCE_WIDTH
	_draw_rounded(Rect2(title_rect.position + Vector2(0.0, 4.0 * scale_factor), title_rect.size), Color("#133449", 0.48), Color.TRANSPARENT, 0, maxi(8, roundi(14.0 * scale_factor)))
	_draw_rounded(title_rect, COMIC_BLUE, COMIC_INK, maxi(2, roundi(4.0 * scale_factor)), maxi(8, roundi(14.0 * scale_factor)))
	var title_inner := title_rect.grow(-maxf(4.0, 8.0 * scale_factor))
	_draw_rounded(title_inner, COMIC_CREAM, Color("#f29c1f"), maxi(1, roundi(3.0 * scale_factor)), maxi(6, roundi(10.0 * scale_factor)))
	draw_line(title_inner.position + Vector2(title_inner.size.x * 0.08, title_inner.size.y * 0.22), title_inner.position + Vector2(title_inner.size.x * 0.92, title_inner.size.y * 0.22), Color(1.0, 1.0, 1.0, 0.65), maxf(1.0, 2.0 * scale_factor), true)
	_draw_rounded(Rect2(count_rect.position + Vector2(0.0, 4.0 * scale_factor), count_rect.size), Color("#133449", 0.48), Color.TRANSPARENT, 0, maxi(8, roundi(15.0 * scale_factor)))
	_draw_rounded(count_rect, COMIC_CYAN, COMIC_INK, maxi(2, roundi(4.0 * scale_factor)), maxi(8, roundi(15.0 * scale_factor)))
	_draw_rounded(count_rect.grow(-maxf(3.0, 7.0 * scale_factor)), COMIC_CREAM, COMIC_ORANGE, maxi(1, roundi(3.0 * scale_factor)), maxi(6, roundi(10.0 * scale_factor)))
	var title_font_size := maxi(14, roundi(title_rect.size.y * 0.39))
	draw_string(FontExtraBold, title_rect.position + Vector2(0.0, title_rect.size.y * 0.68), "MOJE ROSTLINY", HORIZONTAL_ALIGNMENT_CENTER, title_rect.size.x, title_font_size, COMIC_INK)
	if session == null:
		return
	var font_size := maxi(12, roundi(count_rect.size.y * 0.36))
	draw_string(FontExtraBold, count_rect.position + Vector2(0.0, count_rect.size.y * 0.68), "%d/10" % displayed_occupied_count, HORIZONTAL_ALIGNMENT_CENTER, count_rect.size.x, font_size, COMIC_INK)


func _draw_slot(index: int, rect: Rect2, slot: PlantSimulation) -> void:
	var selected := index == session.selected_plant_index
	var plaque := _slot_label_rect(rect)
	# Every generated sprite shares a bottom-center pivot. The explicit shelf
	# baseline keeps all growth states planted instead of vertically centered.
	var baseline_y := _slot_plant_baseline(index)
	var plant_area := Rect2(rect.position + Vector2(2.0, -6.0), Vector2(rect.size.x - 4.0, baseline_y - rect.position.y + 6.0))
	var texture := EmptyPotTexture if slot.stage == PlantSimulation.Stage.EMPTY else _texture_for(slot)
	var plant_rect := _fit_texture_bottom_rect(texture, plant_area)
	var idle_strength := 0.0 if _is_dead(slot) else (0.38 if slot.stage == PlantSimulation.Stage.EMPTY else (1.6 if selected else 0.65))
	plant_rect.position.y += sin(animation_time * 2.0 + index * 0.7) * idle_strength
	var idle_scale := 0.97 if _is_dead(slot) else 1.0 + sin(animation_time * 2.15 + index * 0.4) * (0.006 if selected else 0.003)
	var idle_rotation := 0.0 if slot.stage == PlantSimulation.Stage.EMPTY else sin(animation_time * 1.65 + index * 0.2) * (0.012 if selected else 0.005)
	if _is_dead(slot):
		idle_rotation = -0.035
	elif _is_wilted(slot):
		idle_rotation += sin(animation_time * 0.72 + index) * 0.008
	elif _uses_sick_visual_extended(slot):
		idle_rotation += sin(animation_time * 0.72 + index) * 0.008
	var stress_tint := maxf(0.0, 1.0 - slot.health / 100.0) * 0.20
	var health_tint := Color.WHITE if _uses_sick_visual_extended(slot) else Color.WHITE.lerp(Color("#d6bd75"), stress_tint)
	health_tint = health_tint.lerp(_slot_state_tint(slot), 0.58)
	var center := plant_rect.get_center()
	draw_set_transform(center, idle_rotation, Vector2.ONE * idle_scale)
	draw_texture_rect(texture, Rect2(-plant_rect.size * 0.5, plant_rect.size), false, health_tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if slot.stage == PlantSimulation.Stage.MATURE and not _uses_sick_visual_extended(slot):
		_draw_slot_harvest_ready(plant_rect, index)

	_draw_comic_slot_label(plaque, slot)
	_draw_status_badge(_status_badge_center(plaque), slot)


func _draw_locked_slot(index: int, rect: Rect2) -> void:
	var visual_rect := _locked_texture_rect(rect)
	var pulse := 0.0
	if index == lock_feedback_slot_index:
		var progress := clampf(lock_feedback_elapsed / LOCK_FEEDBACK_DURATION, 0.0, 1.0)
		pulse = sin(progress * PI)
		var shake := sin(progress * PI * 6.0) * (2.2 * (1.0 - progress))
		visual_rect.position.x += shake
		var scale_up := 1.0 + pulse * 0.018
		var scaled_size := visual_rect.size * scale_up
		visual_rect = Rect2(visual_rect.get_center() - scaled_size * 0.5, scaled_size)
	var required_level := session.get_slot_unlock_level(index)
	_draw_comic_locked_slot(visual_rect, required_level, pulse)


func _draw_comic_locked_slot(visual_rect: Rect2, required_level: int, pulse: float) -> void:
	var unit := visual_rect.size.x / 100.0
	if pulse > 0.0:
		_draw_rounded(visual_rect.grow(unit * (1.0 + pulse)), Color.TRANSPARENT, Color(LOCK_GOLD, 0.70 + pulse * 0.30), maxi(2, roundi(unit * 2.0)), maxi(8, roundi(unit * 8.0)), Color(LOCK_GOLD, pulse * 0.30), maxi(2, roundi(unit * 3.0)))

	var pot_body := Rect2(visual_rect.position + Vector2(visual_rect.size.x * 0.18, visual_rect.size.y * 0.61), Vector2(visual_rect.size.x * 0.64, visual_rect.size.y * 0.22))
	_draw_rounded(pot_body, TERRACOTTA, COMIC_INK, maxi(2, roundi(unit * 3.0)), maxi(5, roundi(unit * 6.0)))
	var pot_rim := Rect2(pot_body.position + Vector2(-visual_rect.size.x * 0.05, -visual_rect.size.y * 0.035), Vector2(pot_body.size.x + visual_rect.size.x * 0.10, visual_rect.size.y * 0.075))
	_draw_rounded(pot_rim, Color("#ff9a32"), COMIC_INK, maxi(2, roundi(unit * 3.0)), maxi(5, roundi(unit * 5.0)))

	var cover := Rect2(visual_rect.position + Vector2(visual_rect.size.x * 0.10, visual_rect.size.y * 0.14), Vector2(visual_rect.size.x * 0.80, visual_rect.size.y * 0.55))
	_draw_rounded(cover, LOCK_PURPLE, COMIC_INK, maxi(2, roundi(unit * 3.2)), maxi(10, roundi(unit * 11.0)), Color("#2c1640", 0.30), maxi(2, roundi(unit * 3.0)))
	draw_line(cover.position + Vector2(cover.size.x * 0.20, cover.size.y * 0.14), cover.position + Vector2(cover.size.x * 0.13, cover.size.y * 0.72), LOCK_PURPLE_LIGHT, maxf(1.5, unit * 3.0), true)
	for scallop_index in range(4):
		var scallop_center := Vector2(cover.position.x + cover.size.x * (0.17 + scallop_index * 0.22), cover.end.y - unit * 1.0)
		draw_circle(scallop_center, unit * 9.0, COMIC_INK, true, -1.0, true)
		draw_circle(scallop_center + Vector2(0.0, -unit * 1.2), unit * 6.2, LOCK_PURPLE, true, -1.0, true)

	var lock_center := cover.get_center() + Vector2(0.0, cover.size.y * 0.10)
	var shackle_radius := cover.size.x * 0.16
	draw_arc(lock_center + Vector2(0.0, -cover.size.y * 0.12), shackle_radius, PI, TAU, 24, COMIC_INK, maxf(5.0, unit * 9.0), true)
	draw_arc(lock_center + Vector2(0.0, -cover.size.y * 0.12), shackle_radius, PI, TAU, 24, Color("#fff0a5"), maxf(2.0, unit * 4.5), true)
	var lock_body := Rect2(lock_center - Vector2(cover.size.x * 0.22, cover.size.y * 0.11), Vector2(cover.size.x * 0.44, cover.size.y * 0.27))
	_draw_rounded(lock_body, LOCK_GOLD, COMIC_INK, maxi(2, roundi(unit * 3.0)), maxi(5, roundi(unit * 6.0)), Color("#3b2305", 0.24), maxi(1, roundi(unit * 2.0)))
	draw_line(lock_body.position + Vector2(lock_body.size.x * 0.16, lock_body.size.y * 0.23), lock_body.position + Vector2(lock_body.size.x * 0.78, lock_body.size.y * 0.16), Color("#fff19b"), maxf(1.2, unit * 2.2), true)
	var keyhole := lock_body.get_center() + Vector2(0.0, unit * 1.5)
	draw_circle(keyhole, unit * 3.7, COMIC_INK, true, -1.0, true)
	draw_line(keyhole, keyhole + Vector2(0.0, unit * 7.0), COMIC_INK, maxf(2.0, unit * 4.5), true)

	var plaque := Rect2(visual_rect.position + Vector2(visual_rect.size.x * 0.05, visual_rect.size.y * 0.85), Vector2(visual_rect.size.x * 0.90, visual_rect.size.y * 0.12))
	_draw_rounded(plaque, CREAM, COMIC_INK, maxi(2, roundi(unit * 2.4)), maxi(4, roundi(unit * 5.0)))
	var text := "ÚROVEŇ %d" % required_level
	var font_size := maxi(8, roundi(plaque.size.y * (0.46 if required_level >= 10 else 0.52)))
	var baseline := plaque.position.y + plaque.size.y * 0.70
	draw_string(FontExtraBold, Vector2(plaque.position.x, baseline), text, HORIZONTAL_ALIGNMENT_CENTER, plaque.size.x, font_size, COMIC_INK)


func _slot_label_rect(rect: Rect2) -> Rect2:
	var plaque_height := rect.size.x / SLOT_LABEL_ASPECT
	return Rect2(rect.position.x, rect.end.y - plaque_height, rect.size.x, plaque_height)


func _status_badge_center(plaque: Rect2) -> Vector2:
	return plaque.position + Vector2(plaque.size.x - STATUS_BADGE_RIGHT_INSET, -STATUS_BADGE_TOP_LIFT)


func _status_badge_visual_rect(plaque: Rect2) -> Rect2:
	var center := _status_badge_center(plaque)
	var body_rect := Rect2(center - Vector2.ONE * STATUS_BADGE_RADIUS, Vector2.ONE * STATUS_BADGE_RADIUS * 2.0)
	var shadow_radius := STATUS_BADGE_RADIUS + 1.0
	var shadow_center := center + STATUS_BADGE_SHADOW_OFFSET
	var shadow_rect := Rect2(shadow_center - Vector2.ONE * shadow_radius, Vector2.ONE * shadow_radius * 2.0)
	var crisis_center := center + Vector2(0.0, 1.0)
	var crisis_rect := Rect2(crisis_center - Vector2.ONE * shadow_radius, Vector2.ONE * shadow_radius * 2.0)
	return body_rect.merge(shadow_rect).merge(crisis_rect)


func _slot_plant_baseline(index: int) -> float:
	var source_y := SLOT_SOURCE_FIRST_BASELINE_Y if index < 5 else SLOT_SOURCE_SECOND_BASELINE_Y
	return _source_rect_to_room(Rect2(0.0, source_y, 1.0, 1.0)).position.y


func _draw_comic_slot_label(rect: Rect2, slot: PlantSimulation) -> void:
	var is_empty := slot.stage == PlantSimulation.Stage.EMPTY
	var shadow := Rect2(rect.position + Vector2(0.0, maxf(1.0, rect.size.y * 0.09)), rect.size)
	_draw_rounded(shadow, Color("#17212b", 0.48), Color.TRANSPARENT, 0, maxi(4, roundi(rect.size.y * 0.22)))
	var fill := COMIC_CYAN if is_empty else COMIC_BLUE
	_draw_rounded(rect, fill, COMIC_INK, maxi(2, roundi(rect.size.y * 0.08)), maxi(4, roundi(rect.size.y * 0.22)))
	var inner := rect.grow(-maxf(2.0, rect.size.y * 0.12))
	_draw_rounded(inner, COMIC_CREAM, Color("#ffae24"), maxi(1, roundi(rect.size.y * 0.05)), maxi(3, roundi(rect.size.y * 0.16)))
	var font_size := maxi(8, roundi(rect.size.y * 0.42))
	var text := "PŘIDAT" if is_empty else slot.get_short_name().to_upper()
	draw_string(FontExtraBold, rect.position + Vector2(0.0, rect.size.y * 0.68), text, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, font_size, COMIC_INK)


func _locked_texture_rect(rect: Rect2) -> Rect2:
	var locked_size := Vector2(rect.size.x * 0.88, rect.size.y * 0.92)
	var baseline := rect.position.y + rect.size.y * (220.0 / 305.0)
	return Rect2(Vector2(rect.get_center().x - locked_size.x * 0.5, baseline - locked_size.y * 0.83), locked_size)


func _source_rect_to_room(source_rect: Rect2) -> Rect2:
	var room_size := Vector2(size.x, maxf(1.0, size.y - _summary_height()))
	var scale_factor := room_size / Vector2(GRID_SOURCE_WIDTH, GRID_SOURCE_HEIGHT)
	return Rect2(source_rect.position * scale_factor, source_rect.size * scale_factor)


func _draw_status_badge(center: Vector2, slot: PlantSimulation) -> void:
	var radius := STATUS_BADGE_RADIUS
	draw_circle(center + STATUS_BADGE_SHADOW_OFFSET, radius + 1.0, Color("#17212b", 0.34), true, -1.0, true)
	draw_circle(center, radius, COMIC_CYAN, true, -1.0, true)
	draw_arc(center, radius, 0.0, TAU, 32, COMIC_INK, 2.2, true)
	draw_circle(center, radius - 3.0, COMIC_CREAM, true, -1.0, true)
	if _is_dead(slot):
		draw_circle(center + Vector2(0.0, 1.0), radius + 1.0, COMIC_DEAD_BADGE_SHADOW, true, -1.0, true)
		draw_circle(center, radius, COMIC_DEAD_BADGE, true, -1.0, true)
		draw_circle(center, radius - 3.0, COMIC_DEAD_BADGE_DARK, true, -1.0, true)
		draw_line(center + Vector2(-4.0, -4.0), center + Vector2(4.0, 4.0), COMIC_CREAM, 1.7, true)
		draw_line(center + Vector2(4.0, -4.0), center + Vector2(-4.0, 4.0), COMIC_CREAM, 1.7, true)
		return
	if _is_wilted(slot):
		draw_circle(center + Vector2(0.0, 1.0), radius + 1.0, Color("#3f2100", 0.35), true, -1.0, true)
		draw_circle(center, radius, COMIC_WILT_BADGE, true, -1.0, true)
		draw_circle(center, radius - 3.0, COMIC_WILT_BADGE_DARK, true, -1.0, true)
		draw_line(center + Vector2(-2.0, -3.2), center + Vector2(-2.0, 3.2), COMIC_CREAM, 1.6, true)
		draw_line(center + Vector2(-1.0, 1.2), center + Vector2(2.4, 1.2), COMIC_CREAM, 1.6, true)
		return
	if slot.stage == PlantSimulation.Stage.EMPTY:
		draw_circle(center, 8.3, COMIC_GREEN, true, -1.0, true)
		draw_string(FontExtraBold, center + Vector2(-9.0, 6.0), "+", HORIZONTAL_ALIGNMENT_CENTER, 18.0, 17, COMIC_INK)
		return
	if slot.moisture < 38.0:
		var drop := PackedVector2Array([
			center + Vector2(0.0, -8.0),
			center + Vector2(6.0, 1.0),
			center + Vector2(4.0, 6.0),
			center + Vector2(0.0, 8.0),
			center + Vector2(-5.0, 5.0),
			center + Vector2(-6.0, 1.0),
		])
		draw_colored_polygon(drop, Color("#27bdf1"))
		var drop_outline := PackedVector2Array([drop[0], drop[1], drop[2], drop[3], drop[4], drop[5], drop[0]])
		draw_polyline(drop_outline, COMIC_INK, 1.7, true)
		draw_circle(center + Vector2(-1.8, 2.0), 1.5, Color(1.0, 1.0, 1.0, 0.82), true, -1.0, true)
		return
	if slot.lamp_on:
		for ray_index in range(8):
			var angle := TAU * float(ray_index) / 8.0
			draw_line(center + Vector2(cos(angle), sin(angle)) * 5.8, center + Vector2(cos(angle), sin(angle)) * 8.2, COMIC_INK, 1.4, true)
		draw_circle(center, 5.3, COMIC_INK, true, -1.0, true)
		draw_circle(center, 3.7, LOCK_GOLD, true, -1.0, true)
		return
	draw_circle(center, 8.3, COMIC_GREEN, true, -1.0, true)
	var left_leaf := PackedVector2Array([center + Vector2(-1, 3), center + Vector2(-8, -4), center + Vector2(-2, -8), center + Vector2(2, 0)])
	var right_leaf := PackedVector2Array([center + Vector2(1, 3), center + Vector2(8, -4), center + Vector2(2, -8), center + Vector2(-2, 0)])
	draw_colored_polygon(left_leaf, Color("#efff79"))
	draw_colored_polygon(right_leaf, Color("#efff79"))
	draw_polyline(PackedVector2Array([left_leaf[0], left_leaf[1], left_leaf[2], left_leaf[3]]), COMIC_INK, 1.1, true)
	draw_polyline(PackedVector2Array([right_leaf[0], right_leaf[1], right_leaf[2], right_leaf[3]]), COMIC_INK, 1.1, true)


func _draw_selected_summary() -> void:
	draw_rect(detail_rect, COMIC_INK)
	var outer := detail_rect.grow(-3.0)
	_draw_rounded(outer, COMIC_BLUE, COMIC_INK, 3, 13, Color("#0b1520", 0.34), 3)
	var inner := outer.grow(-5.0)
	_draw_rounded(inner, COMIC_CREAM, Color("#ff9f1f"), 2, 9)
	var plant := session.plant
	var icon_panel := Rect2(detail_rect.position + Vector2(10.0, 10.0), Vector2(70.0, detail_rect.size.y - 20.0))
	_draw_rounded(icon_panel, COMIC_CYAN, COMIC_INK, 2, 10)
	var icon_area := icon_panel.grow(-5.0)
	var icon_texture: Texture2D = EmptyPotTexture
	if plant.stage != PlantSimulation.Stage.EMPTY:
		icon_texture = _texture_for(plant)
	draw_texture_rect(icon_texture, _fit_texture_rect(icon_texture, icon_area), false)
	var title := _selected_summary_title(plant)
	draw_string(FontExtraBold, detail_rect.position + Vector2(89.0, 34.0), title, HORIZONTAL_ALIGNMENT_LEFT, detail_rect.size.x - 238.0, 13, COMIC_INK)
	if plant.stage != PlantSimulation.Stage.EMPTY:
		var track := _summary_progress_track_rect()
		_draw_rounded(track, Color("#ffd77e"), COMIC_INK, 2, 7)
		var progress_inner := _summary_progress_inner_rect()
		_draw_rounded(progress_inner, Color("#174f56"), COMIC_INK, 1, 5)
		var fill := _summary_progress_fill_rect(displayed_growth_percent)
		if fill.size.x > 0.0:
			_draw_rounded(fill, COMIC_GREEN, COMIC_GREEN_DARK, 1, 5)
		if fill.size.x >= 42.0:
			var percent_text := "%d%%" % roundi(displayed_growth_percent)
			var percent_font_size := maxi(10, roundi(progress_inner.size.y * 0.69))
			var percent_width := minf(52.0, fill.size.x - 4.0)
			var percent_x := fill.end.x - percent_width - 3.0
			draw_string(FontExtraBold, Vector2(percent_x, progress_inner.position.y + progress_inner.size.y * 0.78), percent_text, HORIZONTAL_ALIGNMENT_CENTER, percent_width, percent_font_size, Color.WHITE)

	# Preserve the approved green summary surface. The separate sound button owns
	# its right half; the visible left half is now a dedicated 64+ px care target.
	var button_rect := Rect2(detail_rect.end.x - 142.0, detail_rect.position.y + 14.0, 130.0, detail_rect.size.y - 28.0)
	care_button_rect = Rect2(button_rect.position + Vector2(0.0, -2.0), Vector2(button_rect.size.x, button_rect.size.y + 4.0))
	_draw_rounded(Rect2(button_rect.position + Vector2(0.0, 3.0), button_rect.size), Color("#17212b", 0.42), Color.TRANSPARENT, 0, 9)
	_draw_rounded(button_rect, COMIC_GREEN, COMIC_INK, 3, 9)
	var button_inner := button_rect.grow(-5.0)
	_draw_rounded(button_inner, Color("#35b967"), Color("#b8f34b"), 2, 6)
	var care_text := "PÉČE" if displayed_care_attention_count <= 0 else "PÉČE %d" % displayed_care_attention_count
	draw_string(FontExtraBold, button_rect.position + Vector2(0.0, button_rect.size.y * 0.63), care_text, HORIZONTAL_ALIGNMENT_CENTER, 66.0, 11, Color.WHITE)


func _selected_summary_title(plant: PlantSimulation) -> String:
	if plant.stage == PlantSimulation.Stage.EMPTY:
		return "Volný květináč"
	return "%s · růst %d %%" % [plant.get_short_name(), roundi(plant.growth_percent)]


func _summary_progress_track_rect() -> Rect2:
	var source_scale := detail_rect.size / SUMMARY_SOURCE_SIZE
	return Rect2(
		detail_rect.position + SUMMARY_PROGRESS_TRACK.position * source_scale,
		SUMMARY_PROGRESS_TRACK.size * source_scale
	)


func _summary_progress_fill_rect(growth_percent: float) -> Rect2:
	var fill := _summary_progress_inner_rect()
	fill.size.x *= clampf(growth_percent / 100.0, 0.0, 1.0)
	return fill


func _summary_progress_inner_rect() -> Rect2:
	var source_scale := detail_rect.size / SUMMARY_SOURCE_SIZE
	return Rect2(
		detail_rect.position + SUMMARY_PROGRESS_INNER.position * source_scale,
		SUMMARY_PROGRESS_INNER.size * source_scale
	)


func _fit_texture_rect(texture: Texture2D, area: Rect2) -> Rect2:
	var texture_size := texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return area
	var scale_factor := minf(area.size.x / texture_size.x, area.size.y / texture_size.y)
	var fitted_size := texture_size * scale_factor
	return Rect2(area.position + (area.size - fitted_size) * 0.5, fitted_size)


func _fit_texture_bottom_rect(texture: Texture2D, area: Rect2) -> Rect2:
	var texture_size := texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return area
	var scale_factor := minf(area.size.x / texture_size.x, area.size.y / texture_size.y)
	var fitted_size := texture_size * scale_factor
	return Rect2(Vector2(area.get_center().x - fitted_size.x * 0.5, area.end.y - fitted_size.y), fitted_size)


func _texture_for(slot: PlantSimulation) -> Texture2D:
	var state_id := "young"
	if _uses_sick_visual_extended(slot):
		state_id = "sick"
	elif slot.stage == PlantSimulation.Stage.GERMINATING:
		state_id = "seed"
	elif slot.stage == PlantSimulation.Stage.SPROUT or slot.growth_percent < 38.0:
		state_id = "sprout"
	elif slot.stage == PlantSimulation.Stage.MATURE or slot.growth_percent >= 100.0:
		state_id = "harvest_ready"
	elif slot.growth_percent >= 67.0:
		state_id = "mature"
	var texture := plant_presentation_catalog.species_stage_texture(slot.get_species_id(), state_id)
	return texture if texture != null else EmptyPotTexture


func _uses_sick_visual(slot: PlantSimulation) -> bool:
	return slot.disease_level > 0 or slot.health < 55.0



func _uses_sick_visual_extended(slot: PlantSimulation) -> bool:
	return _is_dead(slot) or _is_wilted(slot) or _uses_sick_visual(slot)


func _is_wilted(slot: PlantSimulation) -> bool:
	return slot.is_wilted()


func _is_dead(slot: PlantSimulation) -> bool:
	return slot.stage == PlantSimulation.Stage.DEAD


func _slot_state_tint(slot: PlantSimulation) -> Color:
	if _is_dead(slot):
		return COMIC_DEAD_BADGE
	if _is_wilted(slot):
		return COMIC_WILT_BADGE
	return Color.WHITE


func _draw_slot_harvest_ready(plant_rect: Rect2, index: int) -> void:
	var pulse := 0.58 + sin(animation_time * 3.2 + index * 0.5) * 0.30
	for sparkle_index in range(3):
		var x_ratio := 0.22 + sparkle_index * 0.28
		var y_offset := 0.12 + float(sparkle_index % 2) * 0.18
		_draw_slot_sparkle(plant_rect.position + Vector2(plant_rect.size.x * x_ratio, plant_rect.size.y * y_offset), maxf(1.6, plant_rect.size.x * 0.025), pulse)


func _draw_slot_sparkle(position: Vector2, radius: float, alpha: float) -> void:
	var points := PackedVector2Array([
		position + Vector2(0.0, -radius * 1.5),
		position + Vector2(radius * 0.7, 0.0),
		position + Vector2(0.0, radius * 1.5),
		position + Vector2(-radius * 0.7, 0.0),
		position + Vector2(0.0, -radius * 1.5),
	])
	draw_colored_polygon(PackedVector2Array([points[0], points[1], points[2], points[3]]), Color(LOCK_GOLD, alpha))
	draw_polyline(points, Color(COMIC_INK, alpha), maxf(1.0, radius * 0.42), true)


func _draw_rounded(rect: Rect2, fill: Color, border: Color, width: int, radius: int, shadow := Color.TRANSPARENT, shadow_size := 0) -> void:
	draw_style_box(_get_rounded_style_box(fill, border, width, radius, shadow, shadow_size), rect)


func _get_rounded_style_box(fill: Color, border: Color, width: int, radius: int, shadow := Color.TRANSPARENT, shadow_size := 0) -> StyleBoxFlat:
	# A Vector4i keeps the exact 32-bit colors and packed integer geometry while
	# avoiding several temporary strings for every rounded shape on every draw.
	var geometry_key := (width & 0xff) | ((radius & 0xfff) << 8) | ((shadow_size & 0xfff) << 20)
	var cache_key := Vector4i(fill.to_rgba32(), border.to_rgba32(), shadow.to_rgba32(), geometry_key)
	if rounded_style_cache.has(cache_key):
		return rounded_style_cache[cache_key] as StyleBoxFlat
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(width)
	box.set_corner_radius_all(radius)
	box.anti_aliasing = true
	box.shadow_color = shadow
	box.shadow_size = shadow_size
	if rounded_style_cache.size() < ROUNDED_STYLE_CACHE_LIMIT:
		rounded_style_cache[cache_key] = box
	return box


