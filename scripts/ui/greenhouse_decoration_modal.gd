extends Control
## One permanent garden decoration. The model owns the atomic purchase;
## this component owns presentation and input only while the exterior is open.

const Decoration := preload("res://scripts/greenhouse_decorations.gd")
const Art := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const FontBold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const FontBody := preload("res://assets/fonts/Poppins-SemiBold.ttf")
var game: Control
var shell: PanelContainer
var preview: TextureRect
var inventory: Label
var status_label: Label
var purchase_button: Button
var close_button: Button
var notice := ""
var busy := false
var persist_override: Callable


func bind(owner_control: Control) -> void:
	game = owner_control


func _ready() -> void:
	name = "GreenhouseDecorations"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 180
	hide()
	set_meta("component", "greenhouse_tea_tree_shop_v1")
	var shade := ColorRect.new()
	shade.color = Color(0.06, 0.12, 0.06, 0.78)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var margins := MarginContainer.new()
	margins.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margins.add_theme_constant_override("margin_" + side, 16)
	add_child(margins)
	var center := CenterContainer.new()
	margins.add_child(center)
	shell = PanelContainer.new()
	shell.add_theme_stylebox_override("panel", Art.box("wood", 24))
	center.add_child(shell)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	shell.add_child(column)
	var heading := PanelContainer.new()
	heading.add_theme_stylebox_override("panel", Art.box("sage", 12))
	column.add_child(heading)
	heading.add_child(_label("ČAJOVNÍK", 20, true))
	var picture_frame := PanelContainer.new()
	picture_frame.add_theme_stylebox_override("panel", Art.box("cream", 10))
	column.add_child(picture_frame)
	preview = TextureRect.new()
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	picture_frame.add_child(preview)
	column.add_child(_label("Rozkvetlý stromek ve zdobeném květináči.\nTrvalá ozdoba před tvým skleníkem.", 11))
	inventory = _label("", 12, true)
	column.add_child(inventory)
	status_label = _label("Jednorázový nákup · bez povinné péče", 11)
	status_label.custom_minimum_size.y = 34
	column.add_child(status_label)
	purchase_button = _button("KOUPIT ZA %d MINCÍ" % Decoration.PRICE)
	purchase_button.pressed.connect(purchase)
	column.add_child(purchase_button)
	close_button = _button("ZPĚT DO ZAHRADY")
	close_button.pressed.connect(close)
	column.add_child(close_button)
	resized.connect(_layout)
	_layout()


func _label(caption: String, font_size: int, strong := false) -> Label:
	var label := Label.new()
	label.text = caption
	label.add_theme_font_override("font", FontBold if strong else FontBody)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("#243b2b"))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _button(caption: String) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size.y = 52
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_override("font", FontBold)
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_color", Color("#243b2b"))
	button.add_theme_color_override("font_disabled_color", Color("#64745a"))
	for state in ["normal", "hover", "pressed", "disabled"]:
		button.add_theme_stylebox_override(state, Art.box("cream" if state in ["hover", "disabled"] else "sage", 9))
	return button


func _layout() -> void:
	if shell == null:
		return
	shell.custom_minimum_size.x = minf(400.0, maxf(264.0, size.x - 32.0))
	preview.custom_minimum_size.y = clampf(size.y * 0.25, 150.0, 240.0)


func open() -> void:
	if not is_instance_valid(game) or game.session == null or visible or game._is_blocking_modal_open():
		return
	if game.active_screen != 0 or game.garden_location_id != game.GARDEN_LOCATION_GREENHOUSE_EXTERIOR or game.greenhouse_entrance_view.opening:
		return
	if preview.texture == null:
		var detail := AtlasTexture.new()
		detail.atlas = load(game.greenhouse_entrance_view.TEA_EXTERIOR_PATH) as Texture2D
		detail.region = Rect2(6, 734, 343, 607)
		detail.filter_clip = true
		preview.texture = detail
	notice = ""
	game.greenhouse_decoration_open = true
	show()
	move_to_front()
	refresh()
	game._sync_background_animation_state()
	game.audio_haptics.play_ui("tap")


func close() -> void:
	if not visible or busy:
		return
	hide()
	game.greenhouse_decoration_open = false
	notice = ""
	game._sync_background_animation_state()
	game.audio_haptics.play_ui("tap")


func refresh() -> void:
	if not is_instance_valid(game) or game.session == null:
		return
	var owned := Decoration.is_owned(game.session)
	inventory.text = "TRVALE ZAKOUPENO" if owned else "Cena %d mincí · Máš %d" % [Decoration.PRICE, game.session.coins]
	purchase_button.visible = not owned
	purchase_button.disabled = busy or owned or game.session.coins < Decoration.PRICE or SaveManager.writes_blocked
	if not notice.is_empty():
		status_label.text = notice
	elif owned:
		status_label.text = "Čajovník už zdobí tvou zahradu."
	elif SaveManager.writes_blocked:
		status_label.text = "Nejdřív obnov ukládání hry. Mince zůstávají u tebe."
	elif game.session.coins < Decoration.PRICE:
		var missing: int = Decoration.PRICE - game.session.coins
		var unit := "minci" if missing == 1 else ("mince" if missing in [2, 3, 4] else "mincí")
		status_label.text = "Ještě potřebuješ %d %s." % [missing, unit]
	else:
		status_label.text = "Jednorázový nákup · bez povinné péče"


func purchase() -> void:
	if busy or not visible or game.seed_selector_open or game._is_blocking_modal_open_except_seed_selector(true):
		return
	if game.active_screen != 0 or game.garden_location_id != game.GARDEN_LOCATION_GREENHOUSE_EXTERIOR:
		return
	busy = true
	var result := Decoration.purchase(game.session, Decoration.DECORATION_ID, _persist)
	busy = false
	if bool(result.get("ok", false)):
		notice = "Čajovník už zdobí tvou zahradu."
		game.audio_haptics.play_ui("confirm")
	else:
		notice = str(result.get("message", "Nákup se nepodařilo uložit. Mince zůstaly u tebe."))
		game.audio_haptics.play_ui("error")
	game._refresh_coin_display()
	game._refresh_greenhouse_view()
	refresh()


func _persist() -> bool:
	return bool(persist_override.call()) if persist_override.is_valid() else game._save_current_session(false)
