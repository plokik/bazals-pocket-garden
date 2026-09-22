extends "res://tools/capture_phase172_detail.gd"
## Real Main scene and real CareCenterPresenter in an isolated generated garden.

var checks := 0
var failed := false


func _capture() -> void:
	if not OS.get_environment("APPDATA").replace("\\", "/").contains("care-center-painted-appdata"):
		push_error("Preview requires isolated care-center-painted-appdata")
		quit(2)
		return
	var instance = load("res://main.tscn").instantiate()
	root.add_child(instance)
	await process_frame
	await process_frame
	_prepare_common_state(instance)
	_prepare_care_state(instance)
	instance._refresh_ui()
	instance._open_care_center()
	await _settle(instance)
	_check(instance.care_center_open and instance.care_center_cards.size() == 10, "ten_live_cards")
	_check(instance.care_center_scroll.get_meta("mobile_scroll_contract", "") == "mobile_vertical_scroll_v1", "mobile_scroll_contract")
	_check(instance.care_center_reminder_button.custom_minimum_size.y >= 56.0, "reminder_touch_target")
	for dimensions in [Vector2i(432, 960), Vector2i(360, 800)]:
		root.content_scale_size = dimensions
		await process_frame
		instance._apply_safe_area_rect(Rect2(Vector2.ZERO, dimensions), dimensions, dimensions)
		await _settle(instance)
		var first_card: Dictionary = instance.care_center_cards.get(2, {})
		var action := first_card.get("action") as Button
		var status_icon := first_card.get("status_icon") as TextureRect
		_check(action != null and action.custom_minimum_size.y >= 56.0, "card_touch_target_%d" % dimensions.x)
		_check(status_icon != null and status_icon.texture != null, "painted_status_icon_%d" % dimensions.x)
		_check(action != null and action.icon != null, "painted_action_icon_%d" % dimensions.x)
		for control: Control in [instance.care_center_modal.get_child(0), first_card.get("panel") as Control, action, instance.care_center_reminder_button]:
			var rect := control.get_global_rect()
			_check(rect.position.x >= -0.1 and rect.end.x <= dimensions.x + 0.1, "horizontal_bounds_%s_%d" % [control.name, dimensions.x])
		_check(_save_full_viewport("care-center-painted-%d.png" % dimensions.x), "capture_%d" % dimensions.x)
	var scroll_before: int = instance.care_center_scroll.scroll_vertical
	instance.care_center_scroll.scroll_vertical = 620
	await process_frame
	_check(instance.care_center_scroll.scroll_vertical > scroll_before, "scroll_reaches_later_cards")
	var reminders_before: bool = instance.session.care_reminders_enabled
	instance.care_center_reminder_button.pressed.emit()
	_check(instance.session.care_reminders_enabled != reminders_before, "reminder_toggle_live")
	instance.care_center_reminder_button.pressed.emit()
	var selected_before: int = instance.session.selected_plant_index
	var first_action := (instance.care_center_cards.get(2, {}) as Dictionary).get("action") as Button
	first_action.pressed.emit()
	await process_frame
	_check(not instance.care_center_open and instance.session.selected_plant_index != selected_before, "detail_navigation_live")
	instance.queue_free()
	await process_frame
	print("CARE_CENTER_PAINTED_CHECKS=%d" % checks)
	if failed:
		quit(2)
	else:
		print("CARE_CENTER_PAINTED_INTEGRATION=PASSED")
		quit(0)


func _prepare_care_state(instance) -> void:
	instance.session.xp = 300
	for plant in instance.session.plants:
		(plant as PlantSimulation).reset()
	var catalog: Dictionary = load("res://scripts/plant_catalog_repository.gd").new().load_catalog()
	var rosemary: PlantSimulation = instance.session.plants[2]
	rosemary.configure_profile(catalog["rosemary_officinalis"])
	rosemary.stage = PlantSimulation.Stage.VEGETATIVE
	rosemary.growth_percent = 48.0
	rosemary.disease_level = 1
	rosemary.disease_pressure = 42.0
	var basil: PlantSimulation = instance.session.plants[0]
	basil.configure_profile(catalog["basil_genovese"])
	basil.stage = PlantSimulation.Stage.VEGETATIVE
	basil.growth_percent = 73.0
	basil.moisture = 15.0
	var mint: PlantSimulation = instance.session.plants[1]
	mint.configure_profile(catalog["mint_peppermint"])
	mint.stage = PlantSimulation.Stage.MATURE
	mint.growth_percent = 100.0
	mint.health = 91.0
	instance.session.select_plant(0)


func _check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failed = true
		push_error("CARE_CENTER_PAINTED_FAILED=" + description)
