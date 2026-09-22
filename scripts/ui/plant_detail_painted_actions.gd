extends "res://scripts/ui/plant_action_presenter.gd"
## Typography only; the original presenter still owns every care state.

const Art := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const EMPTY_HINT := "Vyber semínko a založ nový cyklus"


func refresh(plant: PlantSimulation, fertilizer_doses: int, water_amount_ml := 120.0, treatment_relief := 52.0) -> void:
	super.refresh(plant, fertilizer_doses, water_amount_ml, treatment_relief)
	if plant != null:
		_refresh_empty_cycle_card(plant.stage == PlantSimulation.Stage.EMPTY)


func _set_text(button: Button, text_value: String, tooltip := "") -> void:
	var display := text_value
	if button == water_button:
		display = text_value.replace("Zalít ", "Zalít\n")
	elif button == lamp_button:
		display = text_value.replace(": ", "\n")
	elif button == fertilizer_button:
		display = text_value.replace(" · ", "\n")
	elif button == vent_button:
		display = text_value.replace("Proudění\n", "Proudění ")
	super._set_text(button, display, text_value if tooltip.is_empty() else tooltip)


func _set_visual(button: Button, disabled: bool, icon_active := true) -> void:
	super._set_visual(button, disabled, icon_active)
	# The VYP label carries the off state; retain the approved golden sun.
	if not icon_active:
		var glyph := button.get_meta("action_icon", null) as TextureRect
		if glyph != null:
			glyph.modulate = Color(0.88, 0.88, 0.88)


func _refresh_empty_cycle_card(empty: bool) -> void:
	var hint := seed_button.get_meta("empty_cycle_hint", null) as Label
	var time_panel := seed_button.get_meta("empty_cycle_time_panel", null) as PanelContainer
	if hint == null or time_panel == null:
		return
	var icon := seed_button.get_meta("action_icon", null) as TextureRect
	var label := seed_button.get_meta("action_label", null) as Label
	var action_row := seed_button.get_parent() as HBoxContainer
	hint.visible = empty
	time_panel.visible = not empty
	seed_button.custom_minimum_size.y = 144.0 if empty else 100.0
	if action_row != null:
		action_row.custom_minimum_size.y = seed_button.custom_minimum_size.y
	if icon != null:
		icon.custom_minimum_size = Vector2(56, 52) if empty else Vector2(42, 42)
	if label != null:
		label.add_theme_font_size_override("font_size", 13 if empty else 10)
		label.size_flags_vertical = Control.SIZE_SHRINK_CENTER if empty else Control.SIZE_EXPAND_FILL
	if empty:
		TooltipPolicy.apply(seed_button, EMPTY_HINT)
		_apply_empty_button_style("sage")
	else:
		_apply_empty_button_style("cream")


func _apply_empty_button_style(kind: String) -> void:
	seed_button.add_theme_stylebox_override("normal", Art.box(kind, 8))
	seed_button.add_theme_stylebox_override("hover", Art.box(kind, 8, Color(1.04, 1.04, 1.0)))
	seed_button.add_theme_stylebox_override("pressed", Art.box(kind, 8, Color(0.85, 0.91, 0.85)))
