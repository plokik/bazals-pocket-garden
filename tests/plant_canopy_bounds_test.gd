extends RefCounted

const Study := preload("res://scripts/ui/plant_view_study.gd")
const Samples := preload("res://tests/rack_planter_grounding_test.gd")
const DetailCases := preload("res://tests/plant_detail_grounding_test.gd")
const Catalog := preload("res://scripts/plant_catalog_repository.gd")
const FRAMES := [
	{"growth": 0.0, "water": 0.0},
	{"growth": 1.0, "water": 0.0},
	{"growth": 0.9, "water": 0.0},
	{"growth": 0.7114, "water": 0.0},
	{"growth": 0.4, "water": 0.0},
	{"growth": 0.15, "water": 0.0},
	{"growth": 0.0, "water": 0.85},
	{"growth": 0.0, "water": 0.5},
	{"growth": 0.0, "water": 0.2},
	{"growth": 0.7114, "water": 0.5},
]


static func run(suite: SceneTree) -> void:
	var view := Study.new()
	view._ready()
	var samples := Samples._build_samples(Catalog.new().load_catalog())
	var bounds_valid := true
	var contact_stable := true
	var state_unchanged := true
	var count := 0
	var errors: Array[String] = []
	for area: Vector2 in DetailCases.AREAS:
		view.size = area
		for sample: Dictionary in samples:
			if sample.state in ["empty", "sick"]:
				continue
			view.set_simulation(sample.simulation)
			var before: Dictionary = sample.simulation.to_dict().duplicate(true)
			var geometry: Dictionary = view._detail_planter_geometry()
			var target: Rect2 = geometry.plant_rect
			var texture: Texture2D = geometry.texture
			var height := texture.get_height()
			for frame: Dictionary in FRAMES:
				view.growth_burst_animation = frame.growth
				view.water_animation = frame.water
				var motion_scale := view.canopy_vertical_motion_scale(target, height)
				var minimum := INF
				for row in range(0, height, 8):
					var top := target.position.y + row * target.size.y / height \
						+ view.canopy_vertical_offset(row, height, target.size.y) * motion_scale
					minimum = minf(minimum, top)
				count += 1
				if minimum < 1.0 - 0.001 or motion_scale < 0.0 or motion_scale > 1.0:
					bounds_valid = false
					Samples._append_error(errors, "%s %s top=%.3f" % [sample.path, area, minimum])
				contact_stable = contact_stable and Samples._same_layout(geometry, view._detail_planter_geometry()) \
					and is_zero_approx(view.canopy_vertical_offset(height * 0.8, height, target.size.y) * motion_scale)
			state_unchanged = state_unchanged and sample.simulation.to_dict() == before
	suite._check(count == 3850 and bounds_valid, "Animace listů: 55 stavů × 7 velikostí × 10 fází udrží celý pohyblivý vršek alespoň 1 px uvnitř detailu: %s" % "; ".join(errors))
	suite._check(contact_stable and state_unchanged, "Animace listů: omezení výšky nehýbe keramikou, podmiskou ani uložitelným stavem rostliny")
	var parsley := Samples._simulation_for(Catalog.new().load_catalog()["petroselinum_crispum"], "harvest_ready")
	view.set_simulation(parsley)
	view.size = Vector2(410, 363)
	view.growth_burst_animation = 0.7114
	view.water_animation = 0.0
	var compact: Rect2 = view._detail_planter_geometry().plant_rect
	var compact_scale := view.canopy_vertical_motion_scale(compact, 640)
	view.size = Vector2(432, 451)
	var roomy: Rect2 = view._detail_planter_geometry().plant_rect
	suite._check(compact_scale > 0.0 and compact_scale < 1.0 and view.canopy_vertical_motion_scale(roomy, 640) == 1.0, "Petržel: potvrzený kompaktní přesah tlumí pouze potřebnou část pohybu, prostorný detail zachovává plnou animaci")
	view.set_reduced_motion(true)
	suite._check(view.canopy_vertical_motion_scale(compact, 640) == 1.0 and view.canopy_vertical_offset(0, 640, compact.size.y) == 0.0, "Animace listů: omezený pohyb zůstává statický bez dodatečného posunu")
	view.free()
