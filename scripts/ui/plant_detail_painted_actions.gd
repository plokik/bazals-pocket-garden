extends "res://scripts/ui/plant_action_presenter.gd"
## Typography only; the original presenter still owns every care state.

const Art := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const EMPTY_HINT := "Vyber semínko a založ nový cyklus"
var _vent_caption := ""


func bind(seed: Button, water: Button, lamp: Button, fertilizer: Button, vent: Button) -> void:
	super.bind(seed, water, lamp, fertilizer, vent)
	var label := vent.get_meta("action_label", null) as Label
	if label != null:
		label.set_meta("painted_caption_font_size", label.get_theme_font_size("font_size"))
		label.set_meta("painted_caption_h_flags", label.size_flags_horizontal)
		label.set_meta("painted_caption_min_width", label.custom_minimum_size.x)
		vent.set_meta("painted_caption_base_height",vent.custom_minimum_size.y)
		var content := vent.get_meta("action_content") as Control if vent.has_meta("action_content") else null
		if content != null: content.set_meta("painted_caption_bottom",content.offset_bottom)
		label.resized.connect(_fit_vent_caption.call_deferred)
		vent.resized.connect(_fit_vent_caption.call_deferred)


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
	if button == vent_button:
		_vent_caption = display
		_fit_vent_caption()


func _fit_vent_caption() -> void:
	if vent_button == null: return
	var label := vent_button.get_meta("action_label", null) as Label
	if label == null or label.size.x <= 0 or _vent_caption.is_empty(): return
	var font := label.get_theme_font("font")
	var original := int(label.get_meta("painted_caption_font_size",10))
	var content := vent_button.get_meta("action_content") as Control if vent_button.has_meta("action_content") else null
	var width := minf(content.size.x,vent_button.size.x-20.0) if content != null else label.size.x
	var widest := 0.0
	for line in _vent_caption.split("\n"):
		widest = maxf(widest,font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,original).x)
	var caption := _vent_caption
	if widest > width:
		caption = caption.replace("Proudění ","Proudění\n").replace("LÉČBA PŮSOBÍ","LÉČBA\nPŮSOBÍ")
	var three_lines := caption.count("\n") >= 2
	var desired := maxi(original,10) if three_lines else original
	var available_height := label.size.y
	var base_height := float(vent_button.get_meta("painted_caption_base_height",vent_button.custom_minimum_size.y))
	vent_button.custom_minimum_size.y = base_height + (12.0 if three_lines else 0.0)
	if content != null:
		# Grow the shared HBox row once, rather than pushing small text through
		# the painted rim. Restoring the authored values preserves wide layouts.
		content.offset_bottom = -12.0 if three_lines else float(content.get_meta("painted_caption_bottom",-6.0))
		label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER if three_lines else int(label.get_meta("painted_caption_h_flags",Control.SIZE_EXPAND_FILL))
		label.custom_minimum_size.x = maxf(0,vent_button.size.x-20.0) if three_lines else float(label.get_meta("painted_caption_min_width",0.0))
		width = vent_button.size.x-20.0 if three_lines else content.size.x
		available_height = maxf(vent_button.size.y,vent_button.custom_minimum_size.y)-content.position.y-label.position.y-(-content.offset_bottom)
	var chosen := desired
	var lines := caption.split("\n")
	for font_size in range(desired,7,-1):
		chosen = font_size
		widest = 0.0
		for line in lines: widest = maxf(widest,font.get_string_size(line,HORIZONTAL_ALIGNMENT_LEFT,-1,font_size).x)
		if widest <= width+.5 and lines.size()*font.get_height(font_size) <= available_height+.5: break
	label.text = caption
	label.add_theme_font_size_override("font_size",chosen)


func _get_icon_color(active: bool) -> Color:
	# The VYP label carries the off state; retain the approved golden sun.
	return Color.WHITE if active else Color(0.88, 0.88, 0.88)


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
