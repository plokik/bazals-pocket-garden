class_name PlantVitalsPresenter
extends RefCounted

const HEALTHY_COLOR := Color("#42b95c")
const STRESSED_COLOR := Color("#e87838")
const NORMAL_STAGE_COLOR := Color("#17212b")
const WILTED_STAGE_COLOR := Color("#b84b13")
const DEAD_STAGE_COLOR := Color("#554d74")
const HEALTHY_CONDITION_THRESHOLD := 0.72

var stage_label: Label
var growth_label: Label
var growth_bar: ProgressBar
var moisture_label: Label
var health_label: Label
var condition_label: Label


func bind(stage: Label, growth: Label, progress: ProgressBar, moisture: Label, health: Label, condition: Label) -> void:
	stage_label = stage
	growth_label = growth
	growth_bar = progress
	moisture_label = moisture
	health_label = health
	condition_label = condition


func is_bound() -> bool:
	return stage_label != null and growth_label != null and growth_bar != null and moisture_label != null and health_label != null and condition_label != null


func refresh(plant: PlantSimulation) -> void:
	if not is_bound() or plant == null:
		return
	var growth_value := plant.growth_percent
	if plant.stage == PlantSimulation.Stage.DEAD:
		stage_label.text = "UHYNULÁ · VYČISTIT KVĚTINÁČ"
		stage_label.add_theme_color_override("font_color", DEAD_STAGE_COLOR)
		growth_value = 0.0
	elif plant.is_wilted():
		stage_label.text = "ZVADLÁ · ZACHRÁNIT"
		stage_label.add_theme_color_override("font_color", WILTED_STAGE_COLOR)
	else:
		stage_label.text = plant.get_stage_name()
		stage_label.add_theme_color_override("font_color", NORMAL_STAGE_COLOR)
	growth_label.text = "%.1f%%" % growth_value
	growth_bar.value = growth_value
	moisture_label.text = "%d%%" % roundi(plant.moisture)
	health_label.text = "%d%%" % roundi(plant.health)
	condition_label.text = "%d%%" % roundi(plant.condition_score * 100.0)
	condition_label.add_theme_color_override("font_color", HEALTHY_COLOR if plant.condition_score >= HEALTHY_CONDITION_THRESHOLD else STRESSED_COLOR)
