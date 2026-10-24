extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("_run")
func _check(condition: bool, caption: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(caption)
func _run() -> void:
	preload("res://tests/teahouse_progress_test.gd").run(self)
	var hub_script = load("res://scripts/ui/teahouse_hub.gd")
	_check(hub_script != null, "Hub parses")
	await preload("res://tests/teahouse_campaign_test.gd").run(self)
	print("TEAHOUSE_LEVEL_CHECKS=%d FAILURES=%d" % [checks, failures])
	quit(0 if failures == 0 else 1)

func _load_plant_catalog() -> Dictionary:
	return preload("res://scripts/plant_catalog_repository.gd").new().load_catalog()



func _finish_phase92_startup_for_test(instance) -> void:
	instance.is_garden_handover_active = false
	instance.return_to_herbarium_after_handover = false
	instance.garden_handover_presenter.reset()
	instance.session.intro_completed = true
	instance._apply_normal_guide_mode()
	instance._set_guide_modal_open(false, false)
