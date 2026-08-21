class_name GreenhousePreviewView
extends Control

signal rack_requested
signal bed_action_requested(bed_index: int)
signal crop_plant_requested(bed_index: int, crop_id: String)

const ComicUITheme := preload("res://scripts/ui/comic_ui.gd")
const FontSemiBold := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const FontExtraBold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")

const BED_COUNT := 4
const CROP_IDS: Array[String] = ["cherry_tomato", "sweet_pepper", "salad_cucumber"]
const TOUCH_TARGET_MIN := 64.0

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
var wallet_coins := 0
var player_level := 1


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_meta("component", "phase105_greenhouse_v1")
	set_meta("location_id", "greenhouse")
	set_meta("functional_beds", BED_COUNT)
	set_meta("future_bed_count", BED_COUNT)
	set_meta("preview_only", false)
	set_meta("crop_count", 3)
	set_meta("extension_component", "phase107_greenhouse_progression_v1")
	set_meta("attention_component", "phase109_greenhouse_attention_v1")
	set_meta("responsive_layout_component", "phase109_greenhouse_compact_layout_v1")
	set_meta("compact_content_size", Vector2i(360, 620))
	set_meta("responsive_test_viewports", [Vector2i(432, 960), Vector2i(360, 800)])
	resized.connect(_layout_controls)
	_build_controls()
	_ensure_placeholder_states()
	_layout_controls()
	_refresh_controls()


func set_greenhouse_state(states: Array[Dictionary], crops: Dictionary, coins: int, xp: int) -> void:
	bed_states.clear()
	for index in range(BED_COUNT):
		if index < states.size() and states[index] is Dictionary:
			bed_states.append(states[index].duplicate(true))
		else:
			bed_states.append({})
	crop_catalog = crops.duplicate(true)
	wallet_coins = maxi(0, coins)
	player_level = maxi(1, 1 + int(maxi(0, xp) / 100))
	selected_bed_index = clampi(selected_bed_index, 0, BED_COUNT - 1)
	if wallet_label == null or action_button == null:
		return
	wallet_label.text = "%d MINCÍ\nÚR. %d" % [wallet_coins, player_level]
	_refresh_controls()
	queue_redraw()


func set_paused(paused: bool) -> void:
	animations_paused = paused
	set_meta("animations_paused", paused)
	queue_redraw()


func set_fast_time_visuals(_enabled: bool) -> void:
	pass


func set_reduced_motion(enabled: bool) -> void:
	set_meta("reduced_motion", enabled)


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
	back_button.position = Vector2(10.0, 10.0)
	back_button.size = Vector2(124.0, TOUCH_TARGET_MIN)
	wallet_label.position = Vector2(size.x - 122.0, 14.0)
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
	var crop_width := (size.x - 32.0 - float(crop_count - 1) * crop_gap) / float(crop_count)
	for crop_index in range(crop_buttons.size()):
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
	match stage:
		"empty":
			selected_detail_label.text = "Vyber osivo · paprika od úr. 2 · okurka od úr. 4."
		"needs_water":
			selected_detail_label.text = "Osivo je zasazené. Jedna zálivka spustí růst na %s." % _format_duration(float(crop.get("growth_seconds", 0.0)))
		"growing":
			selected_detail_label.text = "Roste · %d %% · zbývá %s" % [roundi(float(state.get("progress", 0.0)) * 100.0), _format_duration(float(state.get("remaining_seconds", 0.0)))]
		"ready":
			selected_detail_label.text = "Sklizeň přidá %d mincí a %d XP." % [int(crop.get("reward_coins", 0)), int(crop.get("reward_xp", 0))]
		_:
			selected_detail_label.text = "Stav záhonu není dostupný."
	var choosing_crop := stage == "empty"
	action_button.visible = not choosing_crop
	action_button.text = str(state.get("action_label", "NELZE POUŽÍT"))
	action_button.disabled = choosing_crop or not bool(state.get("can_action", false))
	var action := str(state.get("action", "none"))
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


func _crop_button_fill(crop_id: String) -> Color:
	match crop_id:
		"cherry_tomato": return ComicUITheme.GREEN
		"sweet_pepper": return ComicUITheme.ORANGE
		"salad_cucumber": return Color("#35b874")
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
	draw_rect(Rect2(Vector2.ZERO, size), Color("#9ee3ed"))
	_draw_sky()
	_draw_title()
	_draw_wallet_panel()
	var house_rect := _house_rect()
	_draw_greenhouse(house_rect)
	for bed_index in range(BED_COUNT):
		_draw_bed(bed_index, _bed_rect(bed_index), bed_states[bed_index])
	_draw_status_panel()


func _draw_sky() -> void:
	draw_circle(Vector2(size.x - 58.0, 73.0), 28.0, Color("#ffe764"))
	for cloud_center in [Vector2(82, 116), Vector2(size.x - 84, 126)]:
		for cloud_offset in [Vector2(-22, 4), Vector2(0, -5), Vector2(24, 5)]:
			draw_circle(cloud_center + cloud_offset, 17.0, Color("#fffdf4", 0.91))


func _draw_title() -> void:
	draw_string(FontExtraBold, Vector2(0.0, 104.0), "SKLENÍK", HORIZONTAL_ALIGNMENT_CENTER, size.x, 25, ComicUITheme.INK)
	draw_string(FontExtraBold, Vector2(0.0, 132.0), "4 ZÁHONY · 3 PLODINY", HORIZONTAL_ALIGNMENT_CENTER, size.x, 12, ComicUITheme.NAVY)


func _draw_wallet_panel() -> void:
	_draw_panel(Rect2(size.x - 122.0, 14.0, 112.0, 48.0), ComicUITheme.PURPLE, ComicUITheme.GOLD, 13)


func _house_rect() -> Rect2:
	if _uses_compact_layout():
		return Rect2(18.0, 174.0, size.x - 36.0, 240.0)
	var status_top := _status_rect().position.y
	return Rect2(18.0, 174.0, size.x - 36.0, maxf(300.0, status_top - 192.0))


func _status_rect() -> Rect2:
	return Rect2(16.0, size.y - 190.0, size.x - 32.0, 96.0)


func _bed_rect(index: int) -> Rect2:
	var house_rect := _house_rect()
	if _uses_compact_layout():
		var compact_gap := 8.0
		var compact_margin := 12.0
		var compact_bed_width := (house_rect.size.x - compact_margin * 2.0 - compact_gap) * 0.5
		var compact_column := index % 2
		var compact_row := int(index / 2)
		return Rect2(
			house_rect.position.x + compact_margin + compact_column * (compact_bed_width + compact_gap),
			house_rect.position.y + 72.0 + compact_row * 82.0,
			compact_bed_width,
			74.0
		)
	var gap := 12.0
	var margin := 16.0
	var bed_width := (house_rect.size.x - margin * 2.0 - gap) * 0.5
	var bed_area_top := house_rect.position.y + maxf(118.0, house_rect.size.y * 0.34)
	var available_height := maxf(150.0, house_rect.end.y - bed_area_top - 18.0)
	var bed_height := minf(108.0, (available_height - gap) * 0.5)
	var column := index % 2
	var row := int(index / 2)
	return Rect2(
		house_rect.position.x + margin + column * (bed_width + gap),
		bed_area_top + row * (bed_height + gap),
		bed_width,
		bed_height
	)


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
	var border := ComicUITheme.GOLD if selected else ComicUITheme.INK
	_draw_panel(rect, Color("#9a5c36"), border, 12)
	var soil_rect := Rect2(rect.position + Vector2(7.0, 8.0), rect.size - Vector2(14.0, 31.0))
	draw_rect(soil_rect, Color("#563823"))
	var stage := str(state.get("stage", "invalid"))
	var progress := clampf(float(state.get("progress", 0.0)), 0.0, 1.0)
	if stage != "empty" and stage != "invalid":
		_draw_crop(str(state.get("crop_id", "")), soil_rect, stage, progress)
	else:
		for mark_index in range(4):
			var mark_x := lerpf(soil_rect.position.x + 14.0, soil_rect.end.x - 14.0, float(mark_index) / 3.0)
			draw_circle(Vector2(mark_x, soil_rect.get_center().y), 3.0, Color("#d99a5c", 0.70))
	var state_name := str(state.get("stage_name", "NENAČTENO"))
	draw_string(FontExtraBold, Vector2(rect.position.x, rect.end.y - 7.0), state_name, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, 8, ComicUITheme.CREAM)
	draw_string(FontExtraBold, rect.position + Vector2(8.0, 17.0), "%d" % (index + 1), HORIZONTAL_ALIGNMENT_LEFT, 24.0, 11, ComicUITheme.CREAM)


func _draw_crop(crop_id: String, soil_rect: Rect2, stage: String, progress: float) -> void:
	match crop_id:
		"sweet_pepper": _draw_pepper_crop(soil_rect, stage, progress)
		"salad_cucumber": _draw_cucumber_crop(soil_rect, stage, progress)
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
