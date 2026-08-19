class_name RealTimeGrowthPresenter
extends RefCounted

var title_label: Label
var value_label: Label


func bind(title: Label, value: Label) -> void:
	title_label = title
	value_label = value


func is_bound() -> bool:
	return title_label != null and value_label != null


func refresh(plant: PlantSimulation) -> void:
	if not is_bound() or plant == null:
		return
	var wilted := false
	var freshness_factor := 1.0
	var estimated_quality := 0.0
	var estimated_g := 0.0
	var seconds_until_death := 0.0
	if plant.has_method("is_wilted"):
		wilted = plant.is_wilted()
	if plant.has_method("get_harvest_freshness_factor"):
		freshness_factor = plant.get_harvest_freshness_factor()
	if plant.has_method("get_estimated_harvest_quality"):
		estimated_quality = plant.get_estimated_harvest_quality()
	if plant.has_method("get_estimated_fresh_harvest_g"):
		estimated_g = plant.get_estimated_fresh_harvest_g()
	if plant.has_method("get_seconds_until_death"):
		seconds_until_death = plant.get_seconds_until_death()
	match plant.stage:
		PlantSimulation.Stage.EMPTY:
			title_label.text = "RŮST V REÁLNÉM ČASE"
			value_label.text = "Vyber semínko a založ nový cyklus"
		PlantSimulation.Stage.DEAD:
			title_label.text = "ROSTLINA UHYNULA"
			value_label.text = "VYČISTIT KVĚTINÁČ"
		PlantSimulation.Stage.MATURE:
			if wilted:
				title_label.text = "ZVADLÁ · ZÁCHRANA %s" % GameSession.format_duration(maxf(0.0, seconds_until_death)).to_upper()
				value_label.text = "Oprav péči a odstraň poškozené listy"
			elif freshness_factor < 1.0 - 0.0001:
				title_label.text = "POZDNÍ SKLIZEŇ · ČERSTVOST %d %%" % roundi(freshness_factor * 100.0)
				value_label.text = "Odhad %.1f g · kvalita %d %%" % [estimated_g, roundi(estimated_quality * 100.0)]
			else:
				title_label.text = "PŘIPRAVENO KE SKLIZNI"
				value_label.text = "Pokračuj ve Skladu"
		PlantSimulation.Stage.HARVESTED:
			title_label.text = "ČERSTVÁ SKLIZEŇ ČEKÁ"
			value_label.text = "Zahaj sušení ve Skladu"
		PlantSimulation.Stage.DRYING:
			var drying_remaining := plant.get_drying_target_seconds() * clampf(1.0 - plant.drying_progress / 100.0, 0.0, 1.0)
			title_label.text = "SUŠENÍ BĚŽÍ V REÁLNÉM ČASE"
			value_label.text = "Hotovo přibližně za %s" % GameSession.format_duration(maxf(60.0, drying_remaining))
		PlantSimulation.Stage.DRY, PlantSimulation.Stage.PACKAGED:
			title_label.text = "SKLIZEŇ ČEKÁ VE SKLADU"
			value_label.text = "Dokonči další krok zpracování"
		_:
			var remaining := maxf(0.0, plant.get_estimated_seconds_to_mature())
			var efficiency_percent := roundi(plant.get_growth_efficiency() * 100.0)
			title_label.text = "DOZRÁNÍ · %s" % ("RYCHLÝ ZAČÁTEK" if plant.tutorial_cycle else "REÁLNÝ ČAS")
			value_label.text = "Přibližně za %s · tempo %d %%" % [GameSession.format_duration(maxf(60.0, remaining)), efficiency_percent]
