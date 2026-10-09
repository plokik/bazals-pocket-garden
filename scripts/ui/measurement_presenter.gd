class_name MeasurementPresenter
extends RefCounted

var metric_labels: Dictionary = {}
var metric_graph: MetricGraph
var knowledge_label: RichTextLabel
var presentation_catalog: PlantPresentationCatalog
var screen_presentation: RefCounted


func bind(labels: Dictionary, graph: MetricGraph, knowledge: RichTextLabel = null, catalog: PlantPresentationCatalog = null) -> void:
	metric_labels = labels
	metric_graph = graph
	knowledge_label = knowledge
	presentation_catalog = catalog


func is_bound() -> bool:
	return metric_labels.size() == 10 and metric_graph != null


func refresh(plant: PlantSimulation, chart_samples: Array[Dictionary]) -> void:
	if not is_bound() or plant == null:
		return
	(metric_labels.temperature as Label).text = "%.1f °C" % plant.temperature_c
	(metric_labels.humidity as Label).text = "%.0f%%" % plant.humidity_percent
	(metric_labels.ph as Label).text = "%.2f" % plant.ph
	(metric_labels.ec as Label).text = "%.2f mS/cm" % plant.ec_ms_cm
	(metric_labels.light as Label).text = "%d lux" % roundi(plant.light_lux)
	(metric_labels.co2 as Label).text = "%d ppm" % roundi(plant.co2_ppm)
	(metric_labels.oxygen as Label).text = "%.3f%%" % plant.oxygen_percent
	(metric_labels.oxygen_balance as Label).text = "%+.2f mg/h" % plant.oxygen_balance_mg_h
	(metric_labels.biomass as Label).text = "%.1f g" % plant.get_biomass_g()
	(metric_labels.weather as Label).text = plant.weather_name
	metric_graph.set_samples(chart_samples)
	if knowledge_label != null and presentation_catalog != null:
		knowledge_label.text = presentation_catalog.knowledge_text(plant.get_species_id())
	if screen_presentation != null:
		screen_presentation.refresh(plant)
