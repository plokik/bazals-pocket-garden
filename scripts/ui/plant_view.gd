class_name PlantView
extends Control

const DetailBackground := preload("res://assets/backgrounds/comic_detail_window_v1.png")
const EmptyPotTexture := preload("res://assets/plants/comic/empty_pot_v1.png")
const PlantingHandTexture := preload("res://assets/ui/actions/planting_hand_v1.png")
const DetailLayout := preload("res://scripts/ui/plant_detail_layout.gd")
const PlanterGrounding := preload("res://scripts/ui/rack_planter_grounding.gd")
const SaucerTexture := preload("res://assets/ui/visual/phase170/rack/rack_ceramic_saucer_phase170_v1.png")
const PlantPresentationCatalogScene := preload("res://scripts/plant_presentation_catalog.gd")
const VisualDesignSystem := preload("res://scripts/ui/visual_design_system.gd")

const COMIC_INK := Color("#17212b")
const COMIC_WATER := Color("#27bde2")
const COMIC_WATER_HIGHLIGHT := Color("#c9f7ff")
const COMIC_GROWTH := Color("#91dc18")
const COMIC_GROWTH_HIGHLIGHT := Color("#e7ff73")
const COMIC_TEAL := Color("#19abc0")
const COMIC_TEAL_SHADOW := Color("#087a9c")
const COMIC_ORANGE := Color("#ff861c")
const COMIC_GOLD := Color("#ffd51e")
const COMIC_BEHAVIOR := Color("#9d5de8")
const COMIC_BEHAVIOR_HIGHLIGHT := Color("#f4dcff")
const COMIC_WILT_TINT := Color("#ff9a26")
const COMIC_DEAD_TINT := Color("#7a7286")
const WATER_SOIL_RATIO := 0.70
const IDLE_EVENT_INTERVALS := [8.5, 11.0, 9.5]

var simulation: PlantSimulation
var animation_time := 0.0
var action_pulse := 0.0
var seed_animation := 0.0
var water_animation := 0.0
var sparkle_animation := 0.0
var growth_burst_animation := 0.0
var wind_animation := 0.0
var shake_animation := 0.0
var ladybug_animation := 0.0
var golden_shine_animation := 0.0
var behavior_pulse := 0.0
var behavior_active := false
var behavior_label := ""
var idle_event_elapsed := 0.0
var idle_event_index := 0
var animations_paused := false
var reduced_motion := false
var fast_time_visuals := false
var observed_growth_percent := -1.0
var observed_stage := -1
var celebrated_stage := -1
var pending_growth_stage := -1
var was_visible := false
var plant_presentation_catalog := PlantPresentationCatalogScene.new()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	set_meta("visual_direction", "western_comic_botanical_v1")
	set_meta("mature_asset", "catalog:species_stage_texture")
	set_meta("plant_asset_family", "profile_driven_catalog_v1")
	set_meta("plant_asset_states", "seed,sprout,young,mature,sick,harvest_ready")
	set_meta("empty_asset", "comic/empty_pot_v1.png")
	set_meta("sprite_canvas", "570x640_bottom_center")
	set_meta("motion_profile", "grounded_ceramic_live_fx_v1")
	set_meta("detail_background", "comic_detail_window_v1")
	set_meta("detail_composition", "mobile_layered_window_plant_fx_v1")
	set_meta("ambient_event", "deterministic_shake_and_ladybug_v1")
	set_meta("milestone_effect", "whole_plant_golden_sweep_v1")
	set_meta("behavior_halo", "active_only_code_drawn_v1")
	set_meta("behavior_particle_budget", 0)
	set_meta("behavior_active", false)
	set_meta("behavior_id", "")
	set_meta("behavior_label", "")
	set_meta("phase151_visual_component", VisualDesignSystem.RACK_PHASE151_RUNTIME_SET_ID)
	set_meta("phase151_scene_profile", VisualDesignSystem.PLANT_DETAIL_PHASE151_SCENE_PROFILE_ID)
	set_meta("phase151_reference_asset", VisualDesignSystem.PLANT_DETAIL_PHASE151_TARGET_ASSET)
	set_meta("phase151_dynamic_policy", "eleven_species_six_states_no_baked_game_state_v1")
	set_meta("phase151_plant_grounding", "painted_saucer_contact_shadow_window_ledge_v1")
	set_meta("phase151_source_png_policy", "rgb_assets_unchanged_import_mipmaps_only_v1")
	set_meta("phase172_plant_grounding", DetailLayout.CONTRACT_ID)
	set_meta("phase172_saucer_asset", SaucerTexture.resource_path)
	visibility_changed.connect(_sync_process_state)
	_sync_process_state()


func set_simulation(value: PlantSimulation) -> void:
	simulation = value
	if simulation == null:
		observed_growth_percent = -1.0
		observed_stage = -1
		celebrated_stage = -1
	else:
		observed_growth_percent = simulation.growth_percent
		observed_stage = int(simulation.stage)
		celebrated_stage = observed_stage
	pending_growth_stage = -1
	idle_event_elapsed = 0.0
	idle_event_index = 0
	shake_animation = 0.0
	ladybug_animation = 0.0
	golden_shine_animation = 0.0
	seed_animation = 0.0
	water_animation = 0.0
	sparkle_animation = 0.0
	growth_burst_animation = 0.0
	action_pulse = 0.0
	behavior_pulse = 0.0
	behavior_active = false
	behavior_label = ""
	set_meta("behavior_active", false)
	set_meta("behavior_id", "")
	set_meta("behavior_label", "")
	queue_redraw()


func set_paused(value: bool) -> void:
	if animations_paused == value:
		return
	animations_paused = value
	_sync_process_state()
	queue_redraw()


func _sync_process_state() -> void:
	var shown := is_visible_in_tree()
	if shown and not was_visible:
		sync_growth_observation()
	was_visible = shown
	set_process(not animations_paused and shown)


func sync_growth_observation() -> void:
	if simulation == null:
		return
	observed_stage = int(simulation.stage)
	celebrated_stage = observed_stage
	observed_growth_percent = simulation.growth_percent
	pending_growth_stage = -1


func clear_action_effects() -> void:
	action_pulse = 0.0
	seed_animation = 0.0
	water_animation = 0.0
	sparkle_animation = 0.0
	growth_burst_animation = 0.0
	golden_shine_animation = 0.0
	wind_animation = 0.0
	pending_growth_stage = -1
	queue_redraw()


func set_reduced_motion(value: bool) -> void:
	reduced_motion = value
	set_meta("reduced_motion", value)
	if value:
		idle_event_elapsed = 0.0
		shake_animation = 0.0
		ladybug_animation = 0.0
		behavior_pulse = minf(behavior_pulse, 0.35)
	queue_redraw()


func set_fast_time_visuals(value: bool) -> void:
	if fast_time_visuals == value:
		return
	fast_time_visuals = value
	set_meta("fast_time_visuals_stabilized", value)
	queue_redraw()


func play_action(action: String) -> void:
	var strength := 0.35 if reduced_motion else 1.0
	action_pulse = strength
	if action == "seed":
		seed_animation = 1.0
	elif action == "water":
		water_animation = strength
	elif action == "fertilize" or action == "harvest":
		sparkle_animation = strength
		golden_shine_animation = strength
	elif action == "growth":
		if simulation != null:
			_trigger_growth_milestone(int(simulation.stage))
	elif action == "rescue":
		sparkle_animation = strength
		golden_shine_animation = strength
	elif action == "wind":
		wind_animation = strength
	queue_redraw()


func _trigger_growth_milestone(stage: int) -> void:
	if stage == celebrated_stage or stage in [PlantSimulation.Stage.EMPTY, PlantSimulation.Stage.GERMINATING, PlantSimulation.Stage.DEAD]:
		return
	celebrated_stage = stage
	if seed_animation > 0.0:
		pending_growth_stage = stage
		return
	var strength := 0.35 if reduced_motion else 1.0
	growth_burst_animation = strength
	golden_shine_animation = strength
	action_pulse = strength
	queue_redraw()


func get_feedback_anchor() -> Vector2:
	var geometry := _detail_planter_geometry()
	if geometry.is_empty():
		return Vector2(size.x * 0.5, DetailLayout.shelf_y(size) - 70.0)
	var plant_rect: Rect2 = geometry.plant_rect
	return Vector2(plant_rect.get_center().x, plant_rect.position.y + plant_rect.size.y * 0.61)


func play_ambient_event(event_name: String) -> void:
	if reduced_motion:
		return
	if event_name == "ladybug":
		shake_animation = 1.0
		ladybug_animation = 1.0
	elif event_name == "gold":
		golden_shine_animation = 1.0
	queue_redraw()


func set_behavior_state(active: bool, trigger_pulse: bool = false, label: String = "") -> void:
	behavior_active = active
	behavior_label = label.strip_edges() if active else ""
	if active and trigger_pulse:
		behavior_pulse = 0.35 if reduced_motion else 1.0
	set_meta("behavior_active", behavior_active)
	set_meta("behavior_label", behavior_label)
	if not behavior_active and behavior_pulse <= 0.0:
		set_meta("behavior_id", "")
	queue_redraw()


func play_behavior_trigger(behavior_id: String, label: String = "") -> void:
	behavior_active = true
	behavior_label = label.strip_edges()
	behavior_pulse = 0.35 if reduced_motion else 1.0
	set_meta("behavior_active", true)
	set_meta("behavior_id", behavior_id.strip_edges())
	set_meta("behavior_label", behavior_label)
	queue_redraw()


func clear_behavior_trigger() -> void:
	behavior_pulse = 0.0
	set_meta("behavior_id", "")
	if not behavior_active:
		behavior_label = ""
		set_meta("behavior_label", "")
	queue_redraw()


func _process(delta: float) -> void:
	if animations_paused:
		return
	if simulation != null:
		var current_stage := int(simulation.stage)
		if current_stage != observed_stage:
			if simulation.stage == PlantSimulation.Stage.DEAD:
				growth_burst_animation = 0.0
				golden_shine_animation = 0.0
				action_pulse = 0.0
			elif simulation.stage == PlantSimulation.Stage.GERMINATING:
				seed_animation = maxf(seed_animation, 1.0)
				growth_burst_animation = 0.0
				golden_shine_animation = 0.0
				action_pulse = 1.0
			else:
				_trigger_growth_milestone(current_stage)
			observed_growth_percent = simulation.growth_percent
			observed_stage = current_stage
		elif simulation.growth_percent != observed_growth_percent:
			observed_growth_percent = simulation.growth_percent
		if simulation.is_growing() and not simulation.is_wilted() and not reduced_motion:
			idle_event_elapsed += delta
			var interval := float(IDLE_EVENT_INTERVALS[idle_event_index % IDLE_EVENT_INTERVALS.size()])
			if idle_event_elapsed >= interval:
				idle_event_elapsed = 0.0
				idle_event_index += 1
				play_ambient_event("ladybug")
	if not reduced_motion:
		animation_time += delta
	var decay := 3.0 if reduced_motion else 1.0
	action_pulse = maxf(0.0, action_pulse - delta * 2.8 * decay)
	seed_animation = maxf(0.0, seed_animation - delta / (0.18 if reduced_motion else 1.55))
	if seed_animation <= 0.0 and pending_growth_stage >= 0:
		pending_growth_stage = -1
		var strength := 0.35 if reduced_motion else 1.0
		growth_burst_animation = strength
		golden_shine_animation = strength
		action_pulse = strength
	water_animation = maxf(0.0, water_animation - delta * 1.4 * decay)
	sparkle_animation = maxf(0.0, sparkle_animation - delta * 1.2 * decay)
	growth_burst_animation = maxf(0.0, growth_burst_animation - delta * 1.25 * decay)
	wind_animation = maxf(0.0, wind_animation - delta * 0.75 * decay)
	shake_animation = maxf(0.0, shake_animation - delta * 1.85 * decay)
	ladybug_animation = maxf(0.0, ladybug_animation - delta / 2.8 * decay)
	golden_shine_animation = maxf(0.0, golden_shine_animation - delta * 0.78 * decay)
	# Keep the local canopy pulse alive across the 0.25 s UI refresh cadence;
	# its normal-motion lifetime stays bounded and close to the shared 0.64 s cue.
	behavior_pulse = maxf(0.0, behavior_pulse - delta * 1.35 * decay)
	if behavior_pulse <= 0.0 and not behavior_active and not str(get_meta("behavior_id", "")).is_empty():
		set_meta("behavior_id", "")
		set_meta("behavior_label", "")
	queue_redraw()


func _draw() -> void:
	_draw_room(size)
	if simulation == null:
		return
	var pot_center := Vector2(size.x * 0.5, DetailLayout.shelf_y(size))
	if behavior_active or behavior_pulse > 0.0:
		_draw_behavior_halo(pot_center)
	if _is_harvest_state(simulation.stage):
		if simulation.stage != PlantSimulation.Stage.DRYING:
			_draw_contact_shadow(pot_center)
		_draw_harvest_state(pot_center)
	else:
		var geometry := _detail_planter_geometry()
		if not geometry.is_empty():
			_draw_detail_saucer(geometry.saucer_rect)
			_draw_grounded_plant(geometry)
	_draw_effects(pot_center)


func _detail_planter_geometry() -> Dictionary:
	if simulation == null or _is_harvest_state(simulation.stage):
		return {}
	var seed_is_falling := seed_animation > 0.0 and not reduced_motion and 1.0 - seed_animation < 0.74
	var texture := EmptyPotTexture if simulation.stage == PlantSimulation.Stage.EMPTY or seed_is_falling else _texture_for_simulation()
	return DetailLayout.layout(texture, size)


func _draw_behavior_halo(center: Vector2) -> void:
	# Comic plant sheets are bottom-aligned and include the pot, so the behavior
	# halo must sit around the leaf canopy rather than behind the pot body.
	var geometry := _detail_planter_geometry()
	var canopy_scale := 1.0 if geometry.is_empty() else minf(1.0, geometry.plant_rect.size.y / 310.0)
	var halo_center := center + Vector2(0.0, -196.0 * canopy_scale)
	var breathe := 1.0
	if not reduced_motion and not animations_paused:
		breathe += sin(animation_time * 2.4) * 0.035
	var halo_radius := 76.0 * breathe * canopy_scale
	if behavior_active:
		draw_circle(halo_center, halo_radius, Color(COMIC_BEHAVIOR, 0.075), true, -1.0, true)
		draw_arc(halo_center, halo_radius, PI * 0.10, PI * 0.88, 28, Color(COMIC_BEHAVIOR_HIGHLIGHT, 0.48), 3.0, true)
		draw_arc(halo_center, halo_radius + 7.0, PI * 1.08, PI * 1.83, 28, Color(COMIC_BEHAVIOR, 0.56), 3.0, true)
	if behavior_pulse <= 0.0:
		return
	var pulse_envelope := sin((1.0 - behavior_pulse) * PI)
	var pulse_radius := halo_radius + (1.0 - behavior_pulse) * 34.0
	draw_circle(halo_center, pulse_radius * 0.92, Color(COMIC_BEHAVIOR, pulse_envelope * 0.055), true, -1.0, true)
	draw_arc(halo_center, pulse_radius, -PI * 0.18, PI * 0.38, 22, Color(COMIC_BEHAVIOR_HIGHLIGHT, pulse_envelope * 0.82), 3.2, true)
	draw_arc(halo_center, pulse_radius, PI * 0.82, PI * 1.38, 22, Color(COMIC_BEHAVIOR, pulse_envelope * 0.76), 3.2, true)
	var sparkle_count := 2 if reduced_motion else 4
	for index in range(sparkle_count):
		var angle := -PI * 0.88 + float(index) * PI * 0.58
		var point := halo_center + Vector2.from_angle(angle) * (halo_radius + 12.0)
		_draw_comic_sparkle(point, 3.2 + float(index % 2), pulse_envelope * 0.90)


func _draw_contact_shadow(center: Vector2) -> void:
	var shadow_width := 45.0
	draw_set_transform(center + Vector2(0.0, -2.0), 0.0, Vector2(1.0, 0.07))
	draw_circle(Vector2.ZERO, shadow_width, Color(0.18, 0.09, 0.03, 0.30), true, -1.0, true)
	draw_circle(Vector2(0.0, -4.0), shadow_width * 0.72, Color(1.0, 0.66, 0.12, 0.13), true, -1.0, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_detail_saucer(rect: Rect2) -> void:
	# Same painted ceramic as the rack. Only the thin contact shadow is drawn;
	# no cyan fallback ellipse and no full-pot transform can detach it again.
	draw_set_transform(Vector2(rect.get_center().x, rect.end.y - rect.size.y * 0.10), 0.0, Vector2(1.0, 0.06))
	for step in range(3):
		draw_circle(Vector2.ZERO, rect.size.x * (0.52 - step * 0.045), Color("#32180b", 0.085), true, -1.0, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_texture_rect_region(SaucerTexture, rect, PlanterGrounding.saucer_source_rect())


func _draw_room(area: Vector2) -> void:
	draw_texture_rect(DetailBackground, Rect2(Vector2.ZERO, area), false)
	if simulation == null:
		return
	var weather := "Jasno" if fast_time_visuals else simulation.weather_name
	var time_of_day := fmod(8.0 + simulation.get_biological_day() * 24.0, 24.0)
	if time_of_day < 6.0 or time_of_day > 20.0:
		draw_rect(Rect2(Vector2.ZERO, area), Color("#163b64", 0.62), true)
		var moon := Vector2(area.x * 0.78, area.y * 0.17)
		draw_circle(moon, 17.0, Color("#fff2b6"), true, -1.0, true)
		draw_circle(moon + Vector2(7.0, -5.0), 16.0, Color("#35618d"), true, -1.0, true)
	elif weather == "Zataženo":
		draw_rect(Rect2(Vector2.ZERO, area), Color("#718995", 0.25), true)
	elif weather == "Déšť":
		draw_rect(Rect2(Vector2.ZERO, area), Color("#4f7180", 0.34), true)
	if weather in ["Polojasno", "Zataženo", "Déšť"]:
		var cloud_shift := fmod(animation_time * (7.0 if weather == "Déšť" else 3.0), maxf(1.0, area.x - 125.0))
		_draw_cloud(Vector2(18.0 + cloud_shift, 42.0), Color("#f5ffff", 0.9) if weather == "Polojasno" else Color("#d4dcdd", 0.93))
		_draw_cloud(Vector2(area.x - 128.0 - cloud_shift * 0.3, 76.0), Color("#e5ebea", 0.86))
	if weather == "Déšť":
		for index in range(18):
			var rain_x := 12.0 + fmod(index * 31.0 + animation_time * 82.0, area.x - 24.0)
			var rain_y := 52.0 + fmod(index * 21.0 + animation_time * 118.0, maxf(1.0, area.y - 66.0))
			draw_line(Vector2(rain_x, rain_y), Vector2(rain_x - 4.0, rain_y + 11.0), Color("#d8f3ff", 0.9), 2.0, true)
	if weather == "Větrno" or wind_animation > 0.0:
		var alpha := 0.8 if weather == "Větrno" else wind_animation
		for index in range(4):
			var wind_x := 8.0 + fmod(animation_time * 100.0 + index * 93.0, maxf(1.0, area.x - 70.0))
			var wind_y := 47.0 + index * 39.0
			draw_arc(Vector2(wind_x + 28.0, wind_y), 28.0, PI, TAU, 18, Color("#fffdf2", alpha), 3.0, true)


func _draw_outdoor_scene(window: Rect2) -> void:
	var weather := "Jasno" if fast_time_visuals or simulation == null else simulation.weather_name
	var biological_day := 0.0 if simulation == null else simulation.get_biological_day()
	var time_of_day := fmod(8.0 + biological_day * 24.0, 24.0)
	var daylight := time_of_day >= 6.0 and time_of_day <= 20.0
	var sky_color := Color("#79d3ec") if daylight else Color("#354f78")
	if weather == "Déšť":
		sky_color = Color("#7f9fac")
	elif weather == "Zataženo":
		sky_color = Color("#a2bdc3")
	draw_rect(window, sky_color, true)

	if daylight:
		var sun_progress := clampf((time_of_day - 6.0) / 14.0, 0.0, 1.0)
		_draw_sun(window.position + Vector2(30.0 + sun_progress * (window.size.x - 60.0), 32.0 - sin(sun_progress * PI) * 15.0))
	else:
		var moon_position := window.position + Vector2(window.size.x * 0.76, 27.0)
		draw_circle(moon_position, 11.0, Color("#fff2b6"), true, -1.0, true)
		draw_circle(moon_position + Vector2(5.0, -3.0), 10.0, sky_color, true, -1.0, true)
		for index in range(6):
			var star := window.position + Vector2(18.0 + index * 51.0, 17.0 + (index % 2) * 17.0)
			draw_circle(star, 1.8, Color("#fff4a8"), true, -1.0, true)

	var horizon_y := window.end.y - 34.0
	draw_colored_polygon(PackedVector2Array([Vector2(window.position.x, horizon_y), Vector2(window.position.x + window.size.x * 0.2, horizon_y - 26.0), Vector2(window.position.x + window.size.x * 0.42, horizon_y), Vector2(window.position.x + window.size.x * 0.67, horizon_y - 41.0), Vector2(window.end.x, horizon_y), window.end, Vector2(window.position.x, window.end.y)]), Color("#55ae61"))
	draw_colored_polygon(PackedVector2Array([Vector2(window.position.x, horizon_y + 8.0), Vector2(window.position.x + window.size.x * 0.34, horizon_y - 15.0), Vector2(window.position.x + window.size.x * 0.72, horizon_y + 5.0), Vector2(window.end.x, horizon_y - 18.0), window.end, Vector2(window.position.x, window.end.y)]), Color("#3e9856"))

	if weather in ["Polojasno", "Zataženo", "Déšť"]:
		var cloud_shift := fmod(animation_time * (5.0 if weather == "Déšť" else 2.5), maxf(1.0, window.size.x - 105.0))
		_draw_cloud(window.position + Vector2(20.0 + cloud_shift, 28.0), Color("#f4ffff") if weather == "Polojasno" else Color("#cbd7d9"))
		_draw_cloud(window.position + Vector2(window.size.x - 116.0 - cloud_shift * 0.35, 50.0), Color("#e1e9e8"))
	if weather == "Déšť":
		for index in range(15):
			var rain_x := window.position.x + 8.0 + fmod(index * 29.0 + animation_time * 78.0, window.size.x - 16.0)
			var rain_y := window.position.y + 42.0 + fmod(index * 19.0 + animation_time * 112.0, window.size.y - 52.0)
			draw_line(Vector2(rain_x, rain_y), Vector2(rain_x - 4.0, rain_y + 10.0), Color("#d8f3ff", 0.9), 2.0, true)
	if weather == "Větrno" or wind_animation > 0.0:
		var wind_alpha := 0.72 if weather == "Větrno" else wind_animation
		for index in range(4):
			var wind_x := window.position.x + 5.0 + fmod(animation_time * 95.0 + index * 83.0, window.size.x - 58.0)
			var wind_y := window.position.y + 24.0 + index * 21.0
			draw_arc(Vector2(wind_x + 22.0, wind_y), 24.0, PI, TAU, 18, Color("#fffaf0", wind_alpha), 2.5, true)


func _draw_sun(center: Vector2) -> void:
	for index in range(8):
		var angle := index * TAU / 8.0
		draw_line(center + Vector2.from_angle(angle) * 14.0, center + Vector2.from_angle(angle) * 20.0, Color("#f7c936"), 2.5, true)
	draw_circle(center, 12.0, Color("#f7c936"), true, -1.0, true)
	draw_circle(center + Vector2(-3.0, -4.0), 3.5, Color("#fff4aa"), true, -1.0, true)


func _draw_cloud(position: Vector2, color: Color) -> void:
	draw_circle(position + Vector2(19.0, 11.0), 12.0, color, true, -1.0, true)
	draw_circle(position + Vector2(34.0, 6.0), 16.0, color, true, -1.0, true)
	draw_circle(position + Vector2(50.0, 12.0), 11.0, color, true, -1.0, true)
	draw_rect(Rect2(position + Vector2(17.0, 10.0), Vector2(35.0, 14.0)), color, true)


func _draw_grounded_plant(geometry: Dictionary) -> void:
	var texture: Texture2D = geometry.texture
	var stress_tint := maxf(0.0, 1.0 - simulation.health / 100.0) * 0.22
	var health_tint := Color.WHITE if _uses_sick_visual() else Color.WHITE.lerp(Color("#d2b773"), stress_tint)
	health_tint = health_tint.lerp(_state_tint(), 0.62)
	var gold_strength := sin((1.0 - golden_shine_animation) * PI) if golden_shine_animation > 0.0 else 0.0
	if gold_strength > 0.0:
		health_tint = health_tint.lerp(Color("#ffe36a"), gold_strength * 0.46)
	if simulation.stage == PlantSimulation.Stage.EMPTY:
		health_tint = Color.WHITE
	draw_texture_rect(texture, geometry.plant_rect, false, health_tint)


func _uses_sick_visual() -> bool:
	return simulation != null and (simulation.stage == PlantSimulation.Stage.DEAD or _is_wilted_plant() or simulation.disease_level > 0 or simulation.health < 55.0)


func _is_wilted_plant() -> bool:
	return simulation != null and simulation.is_wilted()


func _is_dead_plant() -> bool:
	return simulation != null and simulation.stage == PlantSimulation.Stage.DEAD


func _state_tint() -> Color:
	if simulation == null:
		return Color.WHITE
	if simulation.stage == PlantSimulation.Stage.DEAD:
		return COMIC_DEAD_TINT
	if _is_wilted_plant():
		return COMIC_WILT_TINT
	return Color.WHITE


func _is_harvest_state(stage: PlantSimulation.Stage) -> bool:
	return stage in [PlantSimulation.Stage.HARVESTED, PlantSimulation.Stage.DRYING, PlantSimulation.Stage.DRY, PlantSimulation.Stage.PACKAGED]


func _texture_for_simulation() -> Texture2D:
	if simulation == null:
		return EmptyPotTexture
	var state_id := "young"
	if _uses_sick_visual():
		state_id = "sick"
	elif simulation.stage == PlantSimulation.Stage.GERMINATING:
		state_id = "seed"
	elif simulation.stage == PlantSimulation.Stage.SPROUT or simulation.growth_percent < 38.0:
		state_id = "sprout"
	elif simulation.stage == PlantSimulation.Stage.MATURE or simulation.growth_percent >= 100.0:
		state_id = "harvest_ready"
	elif simulation.growth_percent >= 67.0:
		state_id = "mature"
	var texture := plant_presentation_catalog.species_stage_texture(simulation.get_species_id(), state_id)
	return texture if texture != null else EmptyPotTexture


func _draw_harvest_state(center: Vector2) -> void:
	# Packages rest on the sill; cut herbs sit on it, drying herbs hang from
	# their own bar. These storage states never fabricate a living pot/saucer.
	var p := center + Vector2(0, -62)
	if simulation.stage == PlantSimulation.Stage.DRYING:
		draw_line(p + Vector2(-65, -38), p + Vector2(65, -38), Color("#70452e"), 4.0, true)
		for index in range(5):
			var x := -48.0 + index * 24.0
			draw_line(p + Vector2(x, -35), p + Vector2(x, 9), Color("#70452e"), 2.0, true)
			draw_circle(p + Vector2(x + 6.0, 5.0), 9.0, Color("#7fa346"), true, -1.0, true)
	elif simulation.stage in [PlantSimulation.Stage.DRY, PlantSimulation.Stage.PACKAGED]:
		_draw_rounded(Rect2(p + Vector2(-42, -20), Vector2(84, 82)), Color("#f3dfad"), Color("#70452e"), 3, 13, Color("#513421", 0.2), 4)
		draw_circle(p + Vector2(0, 22), 15.0, Color("#42b95c"), true, -1.0, true)
		draw_line(p + Vector2(0, 34), p + Vector2(0, 11), Color("#237a45"), 3.0, true)
	else:
		p = center + Vector2(0, -47)
		for index in range(9):
			var angle := index * TAU / 9.0
			draw_circle(p + Vector2.from_angle(angle) * 34.0, 13.0, Color("#42b95c"), true, -1.0, true)


func _get_water_drop_position(center: Vector2, index: int, phase: float, geometry: Dictionary = {}) -> Vector2:
	if simulation == null:
		return center
	if geometry.is_empty():
		geometry = _detail_planter_geometry()
	var soil := _water_soil_position(center, geometry)
	# Keep the small water cue beside the stem and inside the painted soil.
	# The full plant sprite includes the pot, so a canopy-length stream would
	# sit in front of the leaves and the rim rather than behind them.
	var lane := float(clampi(index, 0, 2))
	var start := soil + Vector2(49.0 + lane * 3.0, -11.0 - lane * 2.0)
	var end := soil + Vector2(43.0 + lane * 3.0, -3.0)
	var travel := clampf(phase, 0.0, 1.0)
	return start.lerp(end, travel * travel)


func _water_soil_position(center: Vector2, geometry: Dictionary) -> Vector2:
	if geometry.is_empty():
		return center + Vector2(0.0, -27.0)
	var plant_rect: Rect2 = geometry.plant_rect
	return Vector2(plant_rect.get_center().x, plant_rect.position.y + plant_rect.size.y * WATER_SOIL_RATIO)


func _draw_effects(center: Vector2) -> void:
	if simulation.stage == PlantSimulation.Stage.MATURE and not _uses_sick_visual():
		_draw_harvest_ready_effect(center)
	if seed_animation > 0.0:
		_draw_seed_planting(center)
	if water_animation > 0.0:
		var water_geometry := _detail_planter_geometry()
		var soil := _water_soil_position(center, water_geometry)
		var progress := 1.0 - water_animation
		if not reduced_motion:
			for index in range(3):
				var phase := progress * 1.55 - float(index) * 0.21
				if phase <= 0.0 or phase >= 1.0:
					continue
				var p := _get_water_drop_position(center, index, phase, water_geometry)
				var alpha := minf(1.0, minf(phase * 5.0, (1.0 - phase) * 5.0)) * 0.85
				draw_circle(p + Vector2(0.6, 1.0), 3.6, Color(COMIC_INK, alpha * 0.38), true, -1.0, true)
				draw_circle(p, 2.8, Color(COMIC_WATER, alpha), true, -1.0, true)
				draw_circle(p + Vector2(-0.8, -0.9), 0.9, Color(COMIC_WATER_HIGHLIGHT, alpha), true, -1.0, true)
		var ripple_phase := clampf((progress - 0.32) / 0.58, 0.0, 1.0)
		var ripple_alpha := sin(ripple_phase * PI) * 0.58
		if ripple_alpha > 0.0:
			draw_set_transform(soil + Vector2(45.0, -2.0), 0.0, Vector2(1.0, 0.28))
			draw_arc(Vector2.ZERO, 5.0 + ripple_phase * 8.0, 0.0, TAU, 18, Color(COMIC_WATER_HIGHLIGHT, ripple_alpha), 2.1, true)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if sparkle_animation > 0.0:
		for index in range(7):
			var angle := animation_time * 1.7 + index * TAU / 7.0
			var radius := 42.0 + sin(animation_time * 4.0 + index) * 8.0
			var p := center + Vector2(cos(angle) * radius, -90 + sin(angle) * radius)
			_draw_comic_sparkle(p, 4.0, sparkle_animation)
		draw_arc(center + Vector2(0.0, -93.0), 48.0, 0.0, TAU, 30, Color("#fff0a8", sparkle_animation * 0.55), 3.0, true)
	if growth_burst_animation > 0.0:
		var progress := 1.0 - growth_burst_animation
		var alpha := sin(progress * PI)
		var growth_geometry := _detail_planter_geometry()
		if not growth_geometry.is_empty():
			var plant_rect: Rect2 = growth_geometry.plant_rect
			var canopy_center := Vector2(plant_rect.get_center().x, plant_rect.position.y + plant_rect.size.y * 0.40)
			for index in range(8):
				var angle := -PI * 0.92 + index * TAU / 8.0
				var radius := lerpf(16.0, 64.0, progress)
				var mote := canopy_center + Vector2(cos(angle) * radius, sin(angle) * radius * 0.55)
				_draw_leaf_mote(mote, angle + PI * 0.5, 0.72 + (index % 3) * 0.12, alpha)
	if golden_shine_animation > 0.0:
		_draw_golden_sweep(center)
	if ladybug_animation > 0.0:
		_draw_ladybug_event(center)


func _draw_seed_planting(center: Vector2) -> void:
	var progress := clampf(1.0 - seed_animation, 0.0, 1.0)
	var geometry := _detail_planter_geometry()
	var soil := center + Vector2(0.0, -110.0)
	if not geometry.is_empty():
		var pot_rect: Rect2 = geometry.plant_rect
		soil = Vector2(pot_rect.get_center().x, pot_rect.position.y + pot_rect.size.y * 0.61)
	if reduced_motion:
		_draw_seed_soil_impact(soil, progress)
		return
	var hand_width := minf(size.x * 0.48, 270.0)
	var hand_size := Vector2(hand_width, hand_width * PlantingHandTexture.get_height() / PlantingHandTexture.get_width())
	var pinch_offset := hand_size * Vector2(0.18, 0.88)
	var hover_pinch := soil + Vector2(38.0, -94.0)
	var hand_shift := Vector2.ZERO
	if progress < 0.34:
		var arrival := clampf(progress / 0.34, 0.0, 1.0)
		var ease_out := 1.0 - pow(1.0 - arrival, 3.0)
		hand_shift = Vector2(minf(size.x * 0.56, 240.0), -110.0) * (1.0 - ease_out)
	elif progress > 0.56:
		var departure := clampf((progress - 0.56) / 0.34, 0.0, 1.0)
		hand_shift = Vector2(minf(size.x * 0.60, 250.0), -95.0) * (departure * departure)
	if progress < 0.91:
		var hand_alpha := clampf((0.96 - progress) / 0.12, 0.0, 1.0)
		draw_texture_rect(PlantingHandTexture, Rect2(hover_pinch + hand_shift - pinch_offset, hand_size), false, Color(1.0, 1.0, 1.0, hand_alpha))
	if progress < 0.74:
		var seed_position := hover_pinch + hand_shift
		if progress >= 0.47:
			var fall := clampf((progress - 0.47) / 0.27, 0.0, 1.0)
			seed_position = hover_pinch.lerp(soil, fall * fall) + Vector2(-sin(fall * PI) * 12.0, 0.0)
			_draw_seed_fall_trail(seed_position, fall)
		_draw_held_seed(seed_position, progress)
	else:
		_draw_seed_soil_impact(soil, (progress - 0.74) / 0.26)


func _draw_seed_fall_trail(seed_position: Vector2, fall: float) -> void:
	var alpha := sin(fall * PI) * 0.55
	if alpha <= 0.0:
		return
	for index in range(2):
		var offset := Vector2(-8.0 - index * 6.0, -13.0 - index * 12.0)
		draw_line(seed_position + offset, seed_position + offset + Vector2(3.0, 7.0), Color("#fff2b1", alpha * (1.0 - index * 0.35)), 2.0, true)


func _draw_held_seed(position: Vector2, progress: float) -> void:
	var angle := lerpf(-0.42, 0.58, clampf((progress - 0.47) / 0.27, 0.0, 1.0))
	draw_set_transform(position, angle, Vector2(1.0, 0.72))
	draw_circle(Vector2(0.0, 1.0), 9.0, COMIC_INK, true, -1.0, true)
	draw_circle(Vector2.ZERO, 7.0, Color("#9c5524"), true, -1.0, true)
	draw_circle(Vector2(-2.0, -2.0), 2.2, Color("#f4be62"), true, -1.0, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_seed_soil_impact(soil: Vector2, progress: float) -> void:
	var impact := clampf(progress, 0.0, 1.0)
	var alpha := sin(impact * PI)
	if alpha <= 0.0:
		return
	var settle := 1.0 - pow(1.0 - impact, 2.0)
	# A small indentation makes the seed feel buried instead of merely vanishing.
	draw_set_transform(soil + Vector2(0.0, 2.0), 0.0, Vector2(1.0, 0.26))
	draw_circle(Vector2.ZERO, 9.0 + settle * 9.0, Color(COMIC_INK, alpha * 0.42), true, -1.0, true)
	draw_circle(Vector2(0.0, -2.0), 7.0 + settle * 8.0, Color("#75411f", alpha * 0.72), true, -1.0, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for index in range(6):
		var direction := -1.0 if index % 2 == 0 else 1.0
		var spread := 8.0 + float(index / 2) * 9.0
		var point := soil + Vector2(direction * (spread + settle * 16.0), -sin(impact * PI) * (7.0 + float(index % 3) * 5.0))
		var radius := (2.8 + float(index % 3) * 1.1) * (1.0 - impact * 0.35)
		draw_circle(point, radius + 1.0, Color(COMIC_INK, alpha * 0.48), true, -1.0, true)
		draw_circle(point, radius, Color("#a96a35", alpha * 0.88), true, -1.0, true)
	for side in [-1.0, 1.0]:
		var dust := soil + Vector2(side * (14.0 + settle * 16.0), -7.0 - sin(impact * PI) * 11.0)
		draw_circle(dust, 7.0 + impact * 3.0, Color("#c88a4b", alpha * 0.21), true, -1.0, true)
		draw_circle(dust + Vector2(side * 5.0, -4.0), 4.0 + impact * 2.0, Color("#e7bc76", alpha * 0.24), true, -1.0, true)
	draw_arc(soil + Vector2(0.0, -4.0), 10.0 + settle * 18.0, PI * 0.10, PI * 0.90, 18, Color(COMIC_GOLD, alpha * 0.62), 2.0, true)


func _draw_golden_sweep(center: Vector2) -> void:
	var geometry := _detail_planter_geometry()
	if geometry.is_empty():
		return
	var progress := 1.0 - golden_shine_animation
	var alpha := sin(progress * PI)
	var plant_rect: Rect2 = geometry.plant_rect
	var soil := _water_soil_position(center, geometry)
	var sweep_y := lerpf(soil.y - 18.0, plant_rect.position.y + plant_rect.size.y * 0.22, progress)
	var half_width := minf(size.x * 0.32, plant_rect.size.x * 0.28)
	draw_set_transform(Vector2(center.x, sweep_y), -0.10, Vector2.ONE)
	draw_line(Vector2(-half_width, 0.0), Vector2(half_width, 0.0), Color(COMIC_INK, alpha * 0.32), 7.0, true)
	draw_line(Vector2(-half_width, -1.0), Vector2(half_width, -1.0), Color("#ffe85a", alpha * 0.70), 3.5, true)
	draw_line(Vector2(-half_width * 0.72, -2.5), Vector2(half_width * 0.28, -2.5), Color("#fffbd0", alpha * 0.84), 1.5, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for index in range(5):
		var sparkle_x := center.x - half_width + half_width * 0.5 * float(index)
		_draw_comic_sparkle(Vector2(sparkle_x, sweep_y - 12.0 - float(index % 2) * 7.0), 2.6 + float(index % 2), alpha)


func _draw_ladybug_event(center: Vector2) -> void:
	var progress := 1.0 - ladybug_animation
	var growth := clampf(simulation.growth_percent / 100.0, 0.0, 1.0)
	var perch := center + Vector2(lerpf(24.0, 58.0, growth), -lerpf(62.0, 185.0, pow(growth, 0.72)))
	var position := Vector2.ZERO
	var rotation := 0.0
	var flying := true
	if progress < 0.52:
		var t := progress / 0.52
		var start := Vector2(-28.0, center.y - 48.0)
		var control := Vector2(center.x * 0.35, perch.y - 82.0)
		position = _quadratic_bezier(start, control, perch, t)
		rotation = lerpf(-0.55, 0.18, t)
	elif progress < 0.76:
		var perch_t := (progress - 0.52) / 0.24
		position = perch + Vector2(sin(perch_t * PI * 2.0) * 1.8, -absf(sin(perch_t * PI)) * 2.5)
		rotation = 0.24 + sin(perch_t * PI * 2.0) * 0.08
		flying = false
	else:
		var t := (progress - 0.76) / 0.24
		var exit := Vector2(size.x + 28.0, center.y - 118.0)
		var control := Vector2(size.x * 0.76, perch.y - 88.0)
		position = _quadratic_bezier(perch, control, exit, t)
		rotation = lerpf(0.18, -0.38, t)

	if flying:
		for trail_index in range(3):
			var trail_offset := Vector2(-8.0 - trail_index * 6.0, 4.0 + trail_index * 1.5).rotated(rotation)
			draw_circle(position + trail_offset, 1.8 - trail_index * 0.35, Color(1.0, 0.92, 0.58, 0.48 - trail_index * 0.11), true, -1.0, true)
	_draw_ladybug(position, rotation, flying)


func _draw_ladybug(position: Vector2, rotation: float, flying: bool) -> void:
	draw_set_transform(position, rotation, Vector2.ONE)
	if flying:
		draw_colored_polygon(PackedVector2Array([Vector2(-1.0, -1.0), Vector2(-8.0, -6.0), Vector2(-10.0, 0.0), Vector2(-3.0, 3.0)]), Color("#dff7ff", 0.82))
		draw_colored_polygon(PackedVector2Array([Vector2(1.0, -1.0), Vector2(8.0, -6.0), Vector2(10.0, 0.0), Vector2(3.0, 3.0)]), Color("#dff7ff", 0.82))
	draw_set_transform(position, rotation, Vector2(1.0, 0.82))
	draw_circle(Vector2.ZERO, 8.0, COMIC_INK, true, -1.0, true)
	draw_circle(Vector2(0.0, -0.8), 6.2, Color("#f04432"), true, -1.0, true)
	draw_line(Vector2(0.0, -6.4), Vector2(0.0, 5.3), COMIC_INK, 1.4, true)
	draw_circle(Vector2(-2.8, -1.8), 1.35, COMIC_INK, true, -1.0, true)
	draw_circle(Vector2(3.0, 2.0), 1.35, COMIC_INK, true, -1.0, true)
	draw_circle(Vector2(0.0, -7.0), 2.5, COMIC_INK, true, -1.0, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _quadratic_bezier(a: Vector2, b: Vector2, c: Vector2, t: float) -> Vector2:
	var inverse := 1.0 - clampf(t, 0.0, 1.0)
	return a * inverse * inverse + b * 2.0 * inverse * t + c * t * t


func _draw_harvest_ready_effect(center: Vector2) -> void:
	var pulse := 0.62 + sin(animation_time * 3.2) * 0.28
	for index in range(5):
		var angle := -PI * 0.92 + float(index) * PI * 0.46
		var radius := 48.0 + float(index % 2) * 18.0
		var sparkle := center + Vector2(cos(angle) * radius, -104.0 + sin(angle) * radius * 0.62)
		_draw_comic_sparkle(sparkle, 3.2 + float(index % 2), pulse)
	draw_arc(center + Vector2(0.0, -96.0), 52.0, PI * 1.08, PI * 1.92, 24, Color(COMIC_GOLD, pulse * 0.24), 3.0, true)


func _draw_comic_sparkle(position: Vector2, radius: float, alpha: float) -> void:
	var points := PackedVector2Array([
		position + Vector2(0.0, -radius * 1.5),
		position + Vector2(radius * 0.7, 0.0),
		position + Vector2(0.0, radius * 1.5),
		position + Vector2(-radius * 0.7, 0.0)
	])
	draw_colored_polygon(points, Color("#ffd51e", alpha))
	draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[0]]), Color(COMIC_INK, alpha), 1.8, true)


func _draw_leaf_mote(position: Vector2, angle: float, scale_factor: float, alpha: float) -> void:
	var leaf := PackedVector2Array([
		Vector2(-7.0, 0.0), Vector2(-2.0, -5.0), Vector2(6.0, -3.0),
		Vector2(9.0, 0.0), Vector2(4.0, 5.0), Vector2(-3.0, 4.0), Vector2(-7.0, 0.0)
	])
	draw_set_transform(position, angle, Vector2.ONE * scale_factor)
	draw_colored_polygon(leaf, Color(COMIC_GROWTH, alpha))
	draw_polyline(leaf, Color(COMIC_INK, alpha), 2.2, true)
	draw_line(Vector2(-4.0, 0.0), Vector2(5.0, 0.0), Color(COMIC_GROWTH_HIGHLIGHT, alpha), 1.5, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_rounded(rect: Rect2, fill: Color, border: Color, width: int, radius: int, shadow := Color.TRANSPARENT, shadow_size := 0) -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = border
	box.set_border_width_all(width)
	box.set_corner_radius_all(radius)
	box.anti_aliasing = true
	box.shadow_color = shadow
	box.shadow_size = shadow_size
	draw_style_box(box, rect)
