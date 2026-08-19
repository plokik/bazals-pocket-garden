class_name PlantView
extends Control

const DetailBackground := preload("res://assets/backgrounds/comic_detail_window_v1.png")
const EmptyPotTexture := preload("res://assets/plants/comic/empty_pot_v1.png")
const PlantPresentationCatalogScene := preload("res://scripts/plant_presentation_catalog.gd")

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
const IDLE_EVENT_INTERVALS := [8.5, 11.0, 9.5]

var simulation: PlantSimulation
var animation_time := 0.0
var action_pulse := 0.0
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
var plant_presentation_catalog := PlantPresentationCatalogScene.new()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	set_meta("visual_direction", "western_comic_botanical_v1")
	set_meta("mature_asset", "catalog:species_stage_texture")
	set_meta("plant_asset_family", "profile_driven_catalog_v1")
	set_meta("plant_asset_states", "seed,sprout,young,mature,sick,harvest_ready")
	set_meta("empty_asset", "comic/empty_pot_v1.png")
	set_meta("sprite_canvas", "570x640_bottom_center")
	set_meta("motion_profile", "elastic_comic_v1")
	set_meta("detail_background", "comic_detail_window_v1")
	set_meta("detail_composition", "mobile_layered_window_plant_fx_v1")
	set_meta("ambient_event", "deterministic_shake_and_ladybug_v1")
	set_meta("milestone_effect", "whole_plant_golden_sweep_v1")
	set_meta("behavior_halo", "active_only_code_drawn_v1")
	set_meta("behavior_particle_budget", 0)
	set_meta("behavior_active", false)
	set_meta("behavior_id", "")
	set_meta("behavior_label", "")
	visibility_changed.connect(_sync_process_state)
	_sync_process_state()


func set_simulation(value: PlantSimulation) -> void:
	simulation = value
	if simulation == null:
		observed_growth_percent = -1.0
		observed_stage = -1
	else:
		observed_growth_percent = simulation.growth_percent
		observed_stage = int(simulation.stage)
	idle_event_elapsed = 0.0
	idle_event_index = 0
	shake_animation = 0.0
	ladybug_animation = 0.0
	golden_shine_animation = 0.0
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
	set_process(not animations_paused and is_visible_in_tree())


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
	if action == "water":
		water_animation = strength
	elif action == "fertilize" or action == "harvest":
		sparkle_animation = strength
		golden_shine_animation = strength
	elif action == "growth":
		growth_burst_animation = strength
		golden_shine_animation = strength
	elif action == "wind":
		wind_animation = strength
	queue_redraw()


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
			else:
				growth_burst_animation = 1.0
				golden_shine_animation = 1.0
				action_pulse = 1.0
			observed_growth_percent = simulation.growth_percent
			observed_stage = current_stage
		elif observed_growth_percent >= 0.0 and simulation.growth_percent >= observed_growth_percent + 1.0:
			growth_burst_animation = 1.0
			golden_shine_animation = 1.0
			action_pulse = 1.0
			observed_growth_percent = simulation.growth_percent
		elif simulation.growth_percent < observed_growth_percent:
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
	var pot_center := Vector2(size.x * 0.5, size.y - 3.0)
	_draw_contact_shadow(pot_center)
	if behavior_active or behavior_pulse > 0.0:
		_draw_behavior_halo(pot_center)
	if simulation.stage == PlantSimulation.Stage.EMPTY:
		_draw_empty_pot(pot_center)
	elif _is_harvest_state(simulation.stage):
		_draw_harvest_state(pot_center)
	elif simulation.stage == PlantSimulation.Stage.DEAD:
		_draw_plant(pot_center)
	else:
		_draw_plant(pot_center)
	_draw_effects(pot_center)


func _draw_behavior_halo(center: Vector2) -> void:
	# Comic plant sheets are bottom-aligned and include the pot, so the behavior
	# halo must sit around the leaf canopy rather than behind the pot body.
	var halo_center := center + Vector2(0.0, -196.0)
	var breathe := 1.0
	if not reduced_motion and not animations_paused:
		breathe += sin(animation_time * 2.4) * 0.035
	var halo_radius := 76.0 * breathe
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
	var shadow_width := minf(size.x * 0.31, 120.0)
	draw_set_transform(center + Vector2(0.0, -5.0), 0.0, Vector2(1.0, 0.23))
	draw_circle(Vector2.ZERO, shadow_width, Color(0.18, 0.09, 0.03, 0.30), true, -1.0, true)
	draw_circle(Vector2(0.0, -4.0), shadow_width * 0.72, Color(1.0, 0.66, 0.12, 0.13), true, -1.0, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


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


func _draw_empty_pot(center: Vector2) -> void:
	var bounce := sin(animation_time * 9.0) * action_pulse * 3.0
	var image_size := _sprite_image_size(EmptyPotTexture)
	var idle_breathe := 1.0 + sin(animation_time * 1.8) * 0.004
	draw_set_transform(center + Vector2(0.0, bounce), 0.0, Vector2.ONE * idle_breathe)
	draw_texture_rect(EmptyPotTexture, Rect2(Vector2(-image_size.x * 0.5, -image_size.y), image_size), false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_plant(center: Vector2) -> void:
	var texture := _texture_for_simulation()
	var growth := clampf(simulation.growth_percent / 100.0, 0.0, 1.0)
	var sway := sin(animation_time * 1.65) * lerpf(0.008, 0.022, growth)
	if _is_dead_plant():
		sway = -0.035
	elif _is_wilted_plant():
		sway += 0.012
	if shake_animation > 0.0:
		var shake_progress := 1.0 - shake_animation
		sway += sin(shake_progress * PI * 8.0) * 0.045 * shake_animation
	if simulation.moisture < 22.0:
		sway += 0.028
	if _uses_sick_visual() and not _is_dead_plant():
		sway += sin(animation_time * 0.72) * 0.012
	var image_size := _sprite_image_size(texture)
	var bounce := 0.0 if _is_dead_plant() else sin(animation_time * 9.0) * action_pulse * 3.0
	var idle_breathe := 0.97 if _is_dead_plant() else 1.0 + sin(animation_time * 2.15) * 0.008
	var burst := 0.0
	if growth_burst_animation > 0.0:
		burst = sin((1.0 - growth_burst_animation) * PI)
	var comic_scale := Vector2(idle_breathe * (1.0 + burst * 0.10), idle_breathe * (1.0 - burst * 0.055))
	var stress_tint := maxf(0.0, 1.0 - simulation.health / 100.0) * 0.22
	var health_tint := Color.WHITE if _uses_sick_visual() else Color.WHITE.lerp(Color("#d2b773"), stress_tint)
	health_tint = health_tint.lerp(_state_tint(), 0.62)
	var gold_strength := sin((1.0 - golden_shine_animation) * PI) if golden_shine_animation > 0.0 else 0.0
	if gold_strength > 0.0:
		health_tint = health_tint.lerp(Color("#ffe36a"), gold_strength * 0.46)
	draw_set_transform(center + Vector2(0.0, bounce + burst * 3.0), sway, comic_scale)
	draw_texture_rect(texture, Rect2(Vector2(-image_size.x * 0.5, -image_size.y), image_size), false, health_tint)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _sprite_image_size(texture: Texture2D) -> Vector2:
	var image_height := minf(310.0, size.y * 1.02)
	var texture_size := texture.get_size()
	var aspect := texture_size.x / maxf(1.0, texture_size.y)
	var image_size := Vector2(image_height * aspect, image_height)
	var max_width := size.x * 0.78
	if image_size.x > max_width:
		image_size *= max_width / image_size.x
	return image_size


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
	var p := center + Vector2(0, -80)
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
		for index in range(9):
			var angle := index * TAU / 9.0
			draw_circle(p + Vector2.from_angle(angle) * 34.0, 13.0, Color("#42b95c"), true, -1.0, true)


func _get_water_drop_position(center: Vector2, index: int, phase: float) -> Vector2:
	if simulation == null:
		return center
	var growth := clampf(simulation.growth_percent / 100.0, 0.0, 1.0)
	var height := lerpf(6.0, 138.0, pow(growth, 0.72))
	var sway := sin(animation_time * 1.8) * (2.0 + growth * 3.0)
	if simulation.moisture < 22.0:
		sway += 4.0
	var half_width := lerpf(5.0, 22.0, growth)
	var column_ratio := float(clampi(index, 0, 5)) / 5.0
	var drop_x := center.x + sway + lerpf(-half_width, half_width, column_ratio)
	var plant_top_y := center.y - 20.0 - height
	var drop_start_y := maxf(6.0, plant_top_y - 18.0)
	var drop_end_y := center.y - 27.0
	return Vector2(drop_x, lerpf(drop_start_y, drop_end_y, clampf(phase, 0.0, 1.0)))


func _draw_effects(center: Vector2) -> void:
	if simulation.stage == PlantSimulation.Stage.MATURE and not _uses_sick_visual():
		_draw_harvest_ready_effect(center)
	if water_animation > 0.0:
		for index in range(6):
			var phase := fmod(animation_time * 2.4 + index * 0.17, 1.0)
			var p := _get_water_drop_position(center, index, phase)
			draw_circle(p + Vector2(1.0, 2.0), 5.2, Color(COMIC_INK, water_animation), true, -1.0, true)
			draw_circle(p, 3.8, Color(COMIC_WATER, water_animation), true, -1.0, true)
			draw_circle(p + Vector2(-1.2, -1.4), 1.25, Color(COMIC_WATER_HIGHLIGHT, water_animation), true, -1.0, true)
		var splash := sin((1.0 - water_animation) * PI)
		for side in [-1.0, 1.0]:
			draw_arc(center + Vector2(side * 16.0, -18.0), 12.0 + splash * 5.0, PI * 1.05, PI * 1.95, 12, Color(COMIC_INK, water_animation), 5.0, true)
			draw_arc(center + Vector2(side * 16.0, -18.0), 12.0 + splash * 5.0, PI * 1.05, PI * 1.95, 12, Color(COMIC_WATER_HIGHLIGHT, water_animation), 2.0, true)
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
		for index in range(8):
			var angle := -PI * 0.92 + index * TAU / 8.0
			var radius := lerpf(20.0, 92.0, progress)
			var mote := center + Vector2(cos(angle) * radius, -88.0 + sin(angle) * radius * 0.72)
			_draw_leaf_mote(mote, angle + PI * 0.5, 0.72 + (index % 3) * 0.12, alpha)
	if golden_shine_animation > 0.0:
		_draw_golden_sweep(center)
	if ladybug_animation > 0.0:
		_draw_ladybug_event(center)


func _draw_golden_sweep(center: Vector2) -> void:
	var progress := 1.0 - golden_shine_animation
	var alpha := sin(progress * PI)
	var growth := clampf(simulation.growth_percent / 100.0, 0.0, 1.0)
	var crown_height := lerpf(70.0, 245.0, pow(growth, 0.72))
	var sweep_y := center.y - lerpf(22.0, crown_height, progress)
	var half_width := lerpf(38.0, minf(size.x * 0.37, 150.0), growth)
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
