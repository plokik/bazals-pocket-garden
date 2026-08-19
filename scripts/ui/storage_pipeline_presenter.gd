class_name StoragePipelinePresenter
extends RefCounted

const ComicUITheme := preload("res://scripts/ui/comic_ui.gd")

var harvest_label: Label
var action_button: Button
var progress_bar: ProgressBar
var step_labels: Array[Label] = []


func bind(label: Label, button: Button, progress: ProgressBar, steps: Array[Label]) -> void:
	harvest_label = label
	action_button = button
	progress_bar = progress
	step_labels = steps


func is_bound() -> bool:
	return harvest_label != null and action_button != null and progress_bar != null


func refresh(game_session: GameSession) -> void:
	if not is_bound():
		return
	var plant: PlantSimulation = game_session.plant
	var active_step := -1
	var progress := 0.0
	var is_wilted := plant.has_method("is_wilted") and plant.is_wilted()
	var estimated_g := float(plant.profile.get("base_fresh_yield_g", 32.0))
	var estimated_quality := 0.0
	var freshness_factor := 1.0
	var seconds_until_death := 0.0
	if plant.has_method("get_estimated_fresh_harvest_g"):
		estimated_g = plant.get_estimated_fresh_harvest_g()
	if plant.has_method("get_estimated_harvest_quality"):
		estimated_quality = plant.get_estimated_harvest_quality()
	if plant.has_method("get_harvest_freshness_factor"):
		freshness_factor = plant.get_harvest_freshness_factor()
	if plant.has_method("get_seconds_until_death"):
		seconds_until_death = plant.get_seconds_until_death()
	match plant.stage:
		PlantSimulation.Stage.MATURE:
			active_step = 0
			progress = 8.0
			if is_wilted and seconds_until_death > 0.0:
				harvest_label.text = "Odhad pozdní sklizně: %.1f g\nKvalita %d %% · čerstvost %d %%\nDo úhynu %s" % [estimated_g, roundi(estimated_quality * 100.0), roundi(freshness_factor * 100.0), GameSession.format_duration(maxf(0.0, seconds_until_death))]
			elif freshness_factor < 0.999:
				harvest_label.text = "Odhad pozdní sklizně: %.1f g\nKvalita %d %% · čerstvost %d %%" % [estimated_g, roundi(estimated_quality * 100.0), roundi(freshness_factor * 100.0)]
			else:
				# Preserve the approved healthy-storage card; lifecycle detail appears only
				# after freshness loss or when the plant needs rescue.
				harvest_label.text = "Odhad čerstvé sklizně: %.1f g\nZdraví určí výslednou kvalitu a cenu." % estimated_g
			action_button.text = "Sklidit: %s" % plant.get_short_name()
			action_button.disabled = false
		PlantSimulation.Stage.DEAD:
			active_step = -1
			progress = 0.0
			harvest_label.text = "Rostlina uhynula. Sklizeň není možná.\nVyčisti květináč a vrať se po výsadbě."
			action_button.text = "VYČISTIT KVĚTINÁČ"
			action_button.disabled = false
		PlantSimulation.Stage.HARVESTED:
			active_step = 1
			progress = 31.0
			harvest_label.text = "Čerstvá bylinka %s: %.1f g\nPřed prodejem ji usuš." % [plant.get_short_name(), plant.fresh_harvest_g]
			action_button.text = "Zahájit sušení"
			action_button.disabled = false
		PlantSimulation.Stage.DRYING:
			active_step = 1
			progress = 31.0 + clampf(plant.drying_progress, 0.0, 100.0) * 0.34
			var drying_remaining := plant.get_drying_target_seconds() * clampf(1.0 - plant.drying_progress / 100.0, 0.0, 1.0)
			harvest_label.text = "Sušení: %.1f %% · zbývá asi %s\nProudění vzduchu odvádí vlhkost z listů." % [plant.drying_progress, GameSession.format_duration(maxf(60.0, drying_remaining))]
			action_button.text = "Sušení probíhá"
			action_button.disabled = true
		PlantSimulation.Stage.DRY:
			active_step = 2
			progress = 70.0
			harvest_label.text = "Suchá bylinka %s: %.1f g\nZabal ji, aby byla připravená pro odběratele." % [plant.get_short_name(), plant.dry_harvest_g]
			action_button.text = "Zabalit do sáčku"
			action_button.disabled = false
		PlantSimulation.Stage.PACKAGED:
			active_step = 3
			progress = 90.0
			harvest_label.text = "Balíček: %.1f g\nDnešní výkupní cena: %d mincí" % [plant.dry_harvest_g, game_session.get_sale_value()]
			action_button.text = "Prodat velkoobchodu"
			action_button.disabled = false
		_:
			var remaining := plant.get_estimated_seconds_to_mature()
			var eta := GameSession.format_duration(maxf(60.0, remaining)) if remaining >= 0.0 else "—"
			harvest_label.text = "Zatím není co zpracovat.\nDo sklizně zbývá přibližně %s v reálném čase." % eta
			action_button.text = "Čekám na sklizeň"
			action_button.disabled = true
	progress_bar.value = progress
	update_steps(active_step)


func update_steps(active_step: int) -> void:
	for index in range(step_labels.size()):
		var label := step_labels[index]
		var panel := label.get_parent() as PanelContainer
		var state := "upcoming"
		var fill := Color("#dbe7e8")
		var border := Color("#65717a")
		var font_color := Color("#65717a")
		if active_step >= 0 and index < active_step:
			state = "complete"
			fill = Color("#d9f4a9")
			border = ComicUITheme.GREEN
			font_color = ComicUITheme.INK
		elif index == active_step:
			state = "active"
			fill = Color("#fff0a6")
			border = ComicUITheme.ORANGE
			font_color = ComicUITheme.INK
		label.add_theme_color_override("font_color", font_color)
		if panel != null and panel.get_meta("step_state", "") != state:
			panel.set_meta("step_state", state)
			panel.add_theme_stylebox_override("panel", ComicUITheme.style_box(fill, border, 2, 9, Color.TRANSPARENT, 0, 3.0))
