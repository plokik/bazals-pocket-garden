extends RefCounted

const Rack := preload("res://scripts/ui/room_overview.gd")
const Catalog := preload("res://scripts/plant_catalog_repository.gd")

const VIEWPORTS := [Vector2(432.0, 960.0), Vector2(360.0, 800.0)]
const PHASE163_MANIFEST_PATH := "res://assets/ui/visual/phase163/rack/phase163_rack_manifest.json"
const PHASE163_MANIFEST_SHA256 := "cb8f14b41e5008c8e7294f9a6090329d41a6b6c7b518b89565f657bd45b3d0f9"
const LOCKED_PATH := "res://assets/ui/visual/phase163/rack/rack_locked_planter_phase163_v1.png"
const LOCKED_SHA256 := "9c362af2fdbf6c32d818ca174692db60d2b806d579ec3ed80578b99addc43706"
const LIGHT_PATH := "res://assets/ui/visual/phase163/rack/rack_grow_light_phase163_v1.png"
const LIGHT_SHA256 := "fda5b231de47ab419f67843dacc2b2a985a866456b4f2c90e50788d470810764"
const EPSILON := 0.002


static func run(suite: SceneTree) -> void:
	_test_public_contract(suite)
	_test_phase163_fixture_integrity(suite)
	_test_touch_geometry_and_priority(suite)
	_test_independent_session_toggle_and_save(suite)
	_test_concurrent_animation(suite)
	_test_off_animation_anchor(suite)


static func _test_public_contract(suite: SceneTree) -> void:
	var rack := Rack.new()
	rack.size = VIEWPORTS[0]
	rack._ready()
	var source := FileAccess.get_file_as_string("res://scripts/ui/room_overview.gd")
	var draw_source := _source_function(source, "func _draw_light_segment_states()")
	var transition_source := _source_function(source, "func _draw_rack_light_transition(")
	var input_source := _source_function(source, "func _gui_input(event: InputEvent)")
	var light_hit_position := input_source.find("_light_index_at_position(position)")
	var slot_hit_position := input_source.find("slot_rects[index].has_point(position)")
	suite._check(
		rack.has_meta("phase179_independent_rack_lights")
		and not str(rack.get_meta("phase179_independent_rack_lights", "")).is_empty()
		and source.contains("signal light_toggle_requested(index: int)")
		and source.contains("func play_light_toggle(index: int, enabled: bool)")
		and source.contains("func play_light_denied(index: int)")
		and source.contains("func cancel_pointer_interactions()")
		and source.contains("func _light_transition_strength(index: int, active: bool)")
		and draw_source.contains("_light_transition_strength(")
		and draw_source.contains("_draw_rack_light_lens(") and draw_source.contains("_draw_rack_light_transition(")
		and transition_source.contains("_light_transition_pulse(index)")
		and transition_source.contains("_light_effect_center(index)")
		and light_hit_position >= 0 and slot_hit_position > light_hit_position,
		"Phase181 zachová přímý signál a samostatný animační stav každé lampy; zhasínací efekt má vlastní indexovaný střed a hit lampy se vyhodnotí před slotem"
	)
	rack.free()


static func _test_phase163_fixture_integrity(suite: SceneTree) -> void:
	var manifest = JSON.parse_string(FileAccess.get_file_as_string(PHASE163_MANIFEST_PATH))
	var locked_image := Image.load_from_file(LOCKED_PATH)
	var light_image := Image.load_from_file(LIGHT_PATH)
	var manifest_valid := manifest is Dictionary
	if manifest_valid:
		var manifest_data := manifest as Dictionary
		var locked := manifest_data.get("locked_planter", {}) as Dictionary
		var light := manifest_data.get("grow_light", {}) as Dictionary
		manifest_valid = str(manifest_data.get("schema", "")) == "phase163_approved_rack_overlay_assets_v1" \
			and str(locked.get("path", "")) == LOCKED_PATH and str(locked.get("sha256", "")).to_lower() == LOCKED_SHA256 \
			and str(light.get("path", "")) == LIGHT_PATH and str(light.get("sha256", "")).to_lower() == LIGHT_SHA256
	suite._check(
		manifest_valid and FileAccess.get_sha256(PHASE163_MANIFEST_PATH) == PHASE163_MANIFEST_SHA256
		and FileAccess.get_sha256(LOCKED_PATH) == LOCKED_SHA256 and locked_image != null and locked_image.get_size() == Vector2i(137, 166)
		and FileAccess.get_sha256(LIGHT_PATH) == LIGHT_SHA256 and light_image != null and light_image.get_size() == Vector2i(108, 49)
		and Rack.Phase163LockedPlanterTexture.resource_path == LOCKED_PATH
		and Rack.Phase163GrowLightTexture.resource_path == LIGHT_PATH,
		"Phase179 nemění jediný pixel ani manifest schváleného Phase163 květináče a mosazného svítidla"
	)

	var geometry_valid := Rack.LIGHT_SOURCE_X == 123.0 and Rack.LIGHT_SOURCE_STEP_X == 140.0 \
		and Rack.LIGHT_SOURCE_FIRST_Y == 494.0 and Rack.LIGHT_SOURCE_SECOND_Y == 831.0
	var rack := Rack.new()
	for viewport: Vector2 in VIEWPORTS:
		rack.size = viewport
		var future_height := clampf(viewport.x * Rack.FUTURE_CONTENT_SOURCE_HEIGHT / Rack.SOURCE_WIDTH, 90.0, 93.0)
		var scale_factor := Vector2(viewport.x / Rack.GRID_SOURCE_WIDTH, (viewport.y - future_height) / Rack.GRID_SOURCE_HEIGHT)
		for index in range(GameSession.MAX_PLANT_SLOTS):
			var row := int(index / 5)
			var source_y := 480.0 if row == 0 else 817.0
			var expected := Rect2(Vector2(111.0 + float(index % 5) * 140.0, source_y) * scale_factor, Vector2(108.0, 49.0) * scale_factor)
			geometry_valid = geometry_valid and _rect_near(rack._light_fixture_rect(row, index % 5), expected)
	suite._check(geometry_valid, "Phase179 zachová přesnou Phase163 geometrii 2×5 svítidel na obou podporovaných mobilních rozměrech")
	rack.free()


static func _test_touch_geometry_and_priority(suite: SceneTree) -> void:
	var catalog := Catalog.new().load_catalog()
	var session := GameSession.new(catalog)
	session.xp = 999999
	var rack := Rack.new()
	suite.root.add_child(rack)
	rack.set_session(session)
	var light_signals: Array[int] = []
	var slot_signals: Array[int] = []
	rack.light_toggle_requested.connect(func(index: int) -> void: light_signals.append(index))
	rack.slot_selected.connect(func(index: int) -> void: slot_signals.append(index))
	for viewport: Vector2 in VIEWPORTS:
		rack.size = viewport
		rack._layout_slots()
		var targets: Array[Rect2] = []
		var geometry_valid := rack.slot_rects.size() == GameSession.MAX_PLANT_SLOTS
		var priority_valid := true
		var screen_rect := Rect2(Vector2.ZERO, viewport)
		for index in range(GameSession.MAX_PLANT_SLOTS):
			var target := rack._light_touch_rect(index)
			var fixture := rack._light_fixture_rect(int(index / 5), index % 5)
			var slot_overlap := target.intersection(rack.slot_rects[index])
			geometry_valid = geometry_valid and target.size.x >= 48.0 and target.size.y >= 48.0 \
				and target.encloses(fixture) and slot_overlap.size.y <= 8.0 and screen_rect.encloses(target)
			for previous: Rect2 in targets:
				geometry_valid = geometry_valid and not target.intersects(previous)
			targets.append(target)

			light_signals.clear()
			slot_signals.clear()
			rack.selection_pending = false
			rack.selection_slot_index = -1
			rack._gui_input(_mouse_press(target.get_center()))
			priority_valid = priority_valid and light_signals.is_empty() and slot_signals.is_empty() and not rack.selection_pending
			rack._gui_input(_mouse_release(target.get_center()))
			priority_valid = priority_valid and light_signals == [index] and slot_signals.is_empty() and not rack.selection_pending

		light_signals.clear()
		rack._gui_input(_mouse_press(targets[0].get_center()))
		rack._gui_input(_mouse_drag(targets[0].get_center() + Vector2(Rack.LIGHT_TAP_DRAG_LIMIT + 3.0, 0.0)))
		rack._gui_input(_mouse_release(targets[0].get_center()))
		priority_valid = priority_valid and light_signals.is_empty() and rack.light_touch_tracking_index < 0
		rack.selection_pending = true
		rack.selection_slot_index = 2
		rack.selection_elapsed = 0.1
		rack.cancel_pointer_interactions()
		priority_valid = priority_valid and not rack.selection_pending and rack.selection_slot_index < 0 and is_zero_approx(rack.selection_elapsed)
		suite._check(
			geometry_valid and targets.size() == GameSession.MAX_PLANT_SLOTS,
			"Phase179 má deset disjunktních dotykových cílů nejméně 48×48 px, z nichž každý obsahuje celé svítidlo stojanu %dx%d" % [viewport.x, viewport.y]
		)
		suite._check(
			priority_valid,
			"Phase179 každé světlo %dx%d přepne až po puštění na stejné lampě a tažení akci zruší bez otevření rostliny" % [viewport.x, viewport.y]
		)
	rack.free()


static func _test_independent_session_toggle_and_save(suite: SceneTree) -> void:
	var catalog := Catalog.new().load_catalog()
	var session := GameSession.new(catalog)
	# Úroveň 3 zpřístupní sloty 0..2. Slot 2 zůstane prázdný a slot 3 je
	# úmyslně osazen přímo v modelu, ale nadále uzamčený pro veřejnou akci.
	session.xp = 200
	session.plants[0].plant_seed(120.0, false)
	session.plants[1].plant_seed(120.0, false)
	session.plants[3].plant_seed(120.0, false)
	var selected_ok := session.select_plant(2)
	var selected_before := session.selected_plant_index
	var selected_plant_before := session.plant
	var feedback: Array[Dictionary] = []
	session.feedback_requested.connect(func(kind: String, slot_index: int, payload: Dictionary) -> void:
		if kind == "light":
			feedback.append({"slot": slot_index, "enabled": bool(payload.get("enabled", false))})
	)

	var first_on := session.toggle_lamp_for_slot(0)
	var only_first_changed := session.plants[0].lamp_on and not session.plants[1].lamp_on and not session.plants[2].lamp_on and not session.plants[3].lamp_on
	var second_on := session.toggle_lamp_for_slot(1)
	var both_on := session.plants[0].lamp_on and session.plants[1].lamp_on and not session.plants[2].lamp_on and not session.plants[3].lamp_on
	var empty_rejected := not session.toggle_lamp_for_slot(2)
	var locked_rejected := not session.toggle_lamp_for_slot(3)
	var invalid_rejected := not session.toggle_lamp_for_slot(-1) and not session.toggle_lamp_for_slot(GameSession.MAX_PLANT_SLOTS)
	var first_off := session.toggle_lamp_for_slot(0)
	var first_back_on := session.toggle_lamp_for_slot(0)
	suite._check(
		selected_ok and first_on and only_first_changed and second_on and both_on
		and empty_rejected and locked_rejected and invalid_rejected and first_off and first_back_on
		and session.selected_plant_index == selected_before and session.plant == selected_plant_before
		and session.plants[0].lamp_on and session.plants[1].lamp_on and not session.plants[2].lamp_on and not session.plants[3].lamp_on,
		"Phase179 toggluje pouze platný odemčený neprázdný slot, nevybírá jej a odmítá EMPTY, locked i neplatné indexy bez vedlejší změny"
	)
	suite._check(
		feedback == [
			{"slot": 0, "enabled": true},
			{"slot": 1, "enabled": true},
			{"slot": 0, "enabled": false},
			{"slot": 0, "enabled": true},
		],
		"Phase179 hlásí světelnou odezvu s indexem skutečně změněného květináče a při odmítnutí nevydá falešný úspěch"
	)

	var saved := session.to_dict()
	var restored := GameSession.new(catalog)
	restored.from_dict(saved)
	var saved_plants = saved.get("plants", [])
	suite._check(
		GameSession.SAVE_SCHEMA == 42 and int(saved.get("schema", -1)) == 42
		and saved_plants is Array and saved_plants.size() == GameSession.MAX_PLANT_SLOTS
		and bool((saved_plants[0] as Dictionary).get("lamp_on", false)) and bool((saved_plants[1] as Dictionary).get("lamp_on", false))
		and restored.plants[0].lamp_on and restored.plants[1].lamp_on
		and not restored.plants[2].lamp_on and not restored.plants[3].lamp_on
		and restored.selected_plant_index == selected_before,
		"Phase179 uloží a obnoví dva nezávisle rozsvícené sloty i přes schema 42 s oddělenou sušárnou"
	)


static func _test_concurrent_animation(suite: SceneTree) -> void:
	var rack := Rack.new()
	rack.size = VIEWPORTS[0]
	rack._ready()
	rack.set_reduced_motion(false)
	rack.play_light_toggle(0, true)
	rack.play_light_toggle(6, true)
	var starts_dark := is_zero_approx(rack._light_transition_strength(0, true)) and is_zero_approx(rack._light_transition_strength(6, true))
	rack._process(Rack.LIGHT_TOGGLE_DURATION * 0.35)
	var first_mid := rack._light_transition_strength(0, true)
	var second_mid := rack._light_transition_strength(6, true)
	var concurrent := first_mid > 0.0 and first_mid < 1.0 and second_mid > 0.0 and second_mid < 1.0 \
		and is_equal_approx(first_mid, second_mid) and rack._light_transition_pulse(0) > 0.0 and rack._light_transition_pulse(6) > 0.0
	var untouched := rack.light_transition_elapsed[1] < 0.0 and rack.light_transition_elapsed[5] < 0.0
	rack._process(Rack.LIGHT_TOGGLE_DURATION)
	var settled_on := is_equal_approx(rack._light_transition_strength(0, true), 1.0) and is_equal_approx(rack._light_transition_strength(6, true), 1.0)
	rack.play_light_toggle(0, false)
	var starts_bright := is_equal_approx(rack._light_transition_strength(0, false), 1.0)
	rack._process(Rack.LIGHT_TOGGLE_DURATION * 0.35)
	var off_mid := rack._light_transition_strength(0, false)
	rack._process(Rack.LIGHT_TOGGLE_DURATION)
	var settled_off := is_zero_approx(rack._light_transition_strength(0, false))
	rack.play_light_toggle(2, true)
	rack._process(Rack.LIGHT_TOGGLE_DURATION * 0.32)
	var before_reverse := rack._light_transition_strength(2, true)
	rack.play_light_toggle(2, false)
	var after_reverse := rack._light_transition_strength(2, false)
	rack._process(Rack.LIGHT_TOGGLE_OFF_DURATION * 0.25)
	var reverse_mid := rack._light_transition_strength(2, false)
	var reversal_is_continuous := before_reverse > 0.0 and is_equal_approx(before_reverse, after_reverse) \
		and reverse_mid > 0.0 and reverse_mid < after_reverse
	suite._check(
		starts_dark and concurrent and untouched and settled_on and starts_bright and off_mid > 0.0 and off_mid < 1.0 and settled_off and reversal_is_continuous,
		"Phase179 plynule rozsvítí i zhasne samostatné světlo, naváže při rychlém obrácení a současně animuje více indexů bez přepsání souseda"
	)

	rack.play_light_denied(3)
	var denied_isolated := is_zero_approx(rack._light_denied_progress(3)) and rack._light_denied_progress(2) < 0.0 and rack._light_denied_progress(4) < 0.0
	rack._process(Rack.LIGHT_DENIED_DURATION * 0.5)
	var denied_mid := rack._light_denied_progress(3)
	rack._process(Rack.LIGHT_DENIED_DURATION)
	var denied_done := rack._light_denied_progress(3) < 0.0
	suite._check(denied_isolated and denied_mid > 0.0 and denied_mid < 1.0 and denied_done, "Phase179 odmítnuté světlo dostane krátkou izolovanou odezvu bez bliknutí jiného slotu")

	rack.set_reduced_motion(true)
	var ambient_before := rack.animation_time
	rack.play_light_toggle(4, true)
	rack._process(0.05)
	var reduced_has_no_pulse := is_zero_approx(rack._light_transition_pulse(4)) and is_equal_approx(rack.animation_time, ambient_before)
	rack._process(Rack.LIGHT_TOGGLE_DURATION)
	suite._check(
		reduced_has_no_pulse and is_equal_approx(rack._light_transition_strength(4, true), 1.0),
		"Phase179 v reduced-motion režimu ukončí změnu bez průběžného pulzu a nerozběhne ambientní animaci"
	)
	rack.free()


static func _test_off_animation_anchor(suite: SceneTree) -> void:
	var rack := Rack.new()
	rack._ready()
	rack.set_reduced_motion(false)
	var probe_indices := [0, 2, 4, 5, 7, 9]
	for viewport: Vector2 in VIEWPORTS:
		rack.size = viewport
		rack._layout_slots()
		rack._ensure_light_animation_state()
		var centers: Dictionary = {}
		var geometry_valid := true
		for index: int in probe_indices:
			var expected := rack._active_light_lens_rect(rack._light_fixture_rect(int(index / 5), index % 5)).get_center()
			var actual := rack._light_effect_center(index)
			centers[index] = actual
			geometry_valid = geometry_valid and actual.distance_to(expected) <= EPSILON
			rack.light_transition_elapsed[index] = -1.0
			rack.light_transition_targets[index] = true
			rack.light_transition_from_strength[index] = 1.0
			rack.play_light_toggle(index, false)
		rack._process(Rack.LIGHT_TOGGLE_OFF_DURATION * 0.5)
		var animation_valid := true
		for index: int in probe_indices:
			var strength := rack._light_transition_strength(index, false)
			animation_valid = animation_valid and not rack.light_transition_targets[index] \
				and strength > 0.0 and strength < 1.0 and rack._light_transition_pulse(index) > 0.0 \
				and (centers[index] as Vector2).distance_to(rack._light_effect_center(index)) <= EPSILON
		var horizontal_order_valid := (centers[0] as Vector2).x < (centers[2] as Vector2).x \
			and (centers[2] as Vector2).x < (centers[4] as Vector2).x \
			and (centers[5] as Vector2).x < (centers[7] as Vector2).x \
			and (centers[7] as Vector2).x < (centers[9] as Vector2).x
		var row_order_valid := (centers[0] as Vector2).y < (centers[5] as Vector2).y \
			and is_equal_approx((centers[0] as Vector2).y, (centers[2] as Vector2).y) \
			and is_equal_approx((centers[5] as Vector2).y, (centers[7] as Vector2).y)
		suite._check(
			geometry_valid and horizontal_order_valid and row_order_valid,
			"Phase181 ukotví levou, prostřední a pravou zhasínací animaci do šesti různých čoček obou řad stojanu %dx%d" % [viewport.x, viewport.y]
		)
		suite._check(
			animation_valid,
			"Phase181 při zhasnutí šesti testovaných lamp zachová jejich vlastní indexovaný střed po celý přechod %dx%d" % [viewport.x, viewport.y]
		)
	rack.free()


static func _mouse_press(position: Vector2) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.position = position
	event.global_position = position
	event.button_index = MOUSE_BUTTON_LEFT
	event.button_mask = MOUSE_BUTTON_MASK_LEFT
	event.pressed = true
	return event


static func _mouse_release(position: Vector2) -> InputEventMouseButton:
	var event := InputEventMouseButton.new()
	event.position = position
	event.global_position = position
	event.button_index = MOUSE_BUTTON_LEFT
	event.button_mask = 0
	event.pressed = false
	return event


static func _mouse_drag(position: Vector2) -> InputEventMouseMotion:
	var event := InputEventMouseMotion.new()
	event.position = position
	event.global_position = position
	event.button_mask = MOUSE_BUTTON_MASK_LEFT
	return event


static func _source_function(source: String, signature: String) -> String:
	var start := source.find(signature)
	if start < 0:
		return ""
	var next := source.find("\nfunc ", start + signature.length())
	return source.substr(start) if next < 0 else source.substr(start, next - start)


static func _rect_near(left: Rect2, right: Rect2) -> bool:
	return left.position.distance_to(right.position) <= EPSILON and left.size.distance_to(right.size) <= EPSILON
