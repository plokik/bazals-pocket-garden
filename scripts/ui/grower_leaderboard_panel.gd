extends Control
## Presentation only. The host supplies profiles, validated rows and service state.
## No network, save access, fabricated players or progression mutations live here.

signal closed
signal refresh_requested
signal join_requested(display_name: String, portrait: int)
signal leave_requested

const Hub := preload("res://scripts/ui/teahouse_hub.gd")
const PaintedSkin := preload("res://scripts/teahouse/tea_painted_skin.gd")
const Bold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const Body := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const Portraits := [
	preload("res://assets/plants/comic/basil_mature_v1.png"),
	preload("res://assets/plants/comic/mint_mature_v1.png"),
	preload("res://assets/plants/comic/lavender_mature_v2.png"),
	preload("res://assets/ui/workshop/products/mint-lemonbalm-tea-v1.png"),
]
const INK := Color("#293f2e")
const MUTED := Color("#687554")
const OWN := Color("#e0edbb")
const STATUSES := ["join", "loading", "ready", "offline", "error", "unavailable"]

var profile: Dictionary = {}
var snapshot: Dictionary = {}
var status := "unavailable"
var page := "nearby"
var safe_insets := Vector4.ZERO
var buttons: Dictionary = {}
var scroll: ScrollContainer
var list: VBoxContainer
var name_input: LineEdit
var layout: Dictionary = {}
var view_text: Array[Dictionary] = []
var drawn_rows: Array[Dictionary] = []

var art
var ui: Control
var _locale := "cs"
var _reduced_motion := false
var _wanted_visible := false
var _scroll_positions := {"nearby": 0, "top": 0, "join": 0}
var _scroll_context := "nearby"
var _draft_name := ""
var _draft_portrait := 0
var _name_pattern := RegEx.new()
var _parent_control: Control
var _layout_queued := false
var _last_size := Vector2(-1, -1)
var _last_insets := Vector4(-1, -1, -1, -1)
var _generation := 0
var _row_height := 54.0
var _restoring_scroll := false


func _init() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 7
	z_as_relative = true
	material = CanvasItemMaterial.new()
	_name_pattern.compile("^[\\p{L}\\p{N}][\\p{L}\\p{N} ._-]{0,17}$")


func _ready() -> void:
	name = "GrowerLeaderboardPanel"
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art = Hub.new()
	# The approved frame loader is usable without starting the hub scene.
	art.load_painted_ui()
	ui = Control.new()
	ui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui.material = CanvasItemMaterial.new()
	add_child(ui)
	resized.connect(_request_layout)
	if get_parent() is Control:
		_parent_control = get_parent() as Control
		_parent_control.resized.connect(_request_layout)
	get_viewport().size_changed.connect(_request_layout)
	visible = _wanted_visible
	_layout_and_rebuild(true)


func _exit_tree() -> void:
	if is_instance_valid(_parent_control) and _parent_control.resized.is_connected(_request_layout):
		_parent_control.resized.disconnect(_request_layout)
	if is_instance_valid(art):
		art.free()
	art = null


func show_board(next_profile: Dictionary, next_snapshot: Dictionary, next_status: String, locale: String = "cs", reduced_motion: bool = false) -> void:
	var next_locale := "en" if locale.to_lower().begins_with("en") else "cs"
	var normalized_status := next_status if next_status in STATUSES else "unavailable"
	# Host refresh ticks must not replace controls underneath a held touch or drag.
	if is_node_ready() and _wanted_visible and is_visible_in_tree() and profile == next_profile and snapshot == next_snapshot and status == normalized_status and _locale == next_locale and _reduced_motion == reduced_motion:
		return
	_remember_scroll()
	var changed_profile := str(profile.get("id", "")) != str(next_profile.get("id", ""))
	profile = next_profile.duplicate(true)
	snapshot = next_snapshot.duplicate(true)
	status = normalized_status
	_locale = next_locale
	_reduced_motion = reduced_motion
	if changed_profile or _draft_name.is_empty():
		_draft_name = str(profile.get("name", "")).left(18)
		_draft_portrait = clampi(int(profile.get("portrait", 0)), 0, Portraits.size() - 1)
	_wanted_visible = true
	show()
	if is_node_ready():
		_layout_and_rebuild(true)


func hide_board() -> void:
	_remember_scroll()
	_wanted_visible = false
	if is_instance_valid(name_input):
		name_input.release_focus()
	hide()


func set_safe_insets(value: Vector4) -> void:
	safe_insets = Vector4(maxf(0, value.x), maxf(0, value.y), maxf(0, value.z), maxf(0, value.w))
	_request_layout()


func _request_layout() -> void:
	if not is_node_ready() or _layout_queued:
		return
	_layout_queued = true
	_flush_layout.call_deferred()


func _flush_layout() -> void:
	_layout_queued = false
	if is_inside_tree():
		_layout_and_rebuild(false)


func _layout_and_rebuild(force: bool) -> void:
	if not is_instance_valid(ui) or not is_instance_valid(art):
		return
	var available := _parent_control.size if is_instance_valid(_parent_control) else get_viewport().get_visible_rect().size
	if not size.is_equal_approx(available):
		size = available
	if not force and size.is_equal_approx(_last_size) and safe_insets == _last_insets:
		return
	_remember_scroll()
	_last_size = size
	_last_insets = safe_insets
	var safe := Rect2(Vector2(safe_insets.x, safe_insets.y), Vector2(maxf(1, size.x - safe_insets.x - safe_insets.z), maxf(1, size.y - safe_insets.y - safe_insets.w)))
	var width := minf(432, safe.size.x)
	var origin := safe.position + Vector2((safe.size.x - width) * 0.5, 0)
	var height := safe.size.y
	var roomy := clampf((height - 640) / 320, 0, 1)
	var margin := lerpf(10, 16, roomy)
	var inset := lerpf(12, 16, roomy)
	var left := origin.x + margin + inset
	var content_width := width - 2 * (margin + inset)
	var back_y := origin.y + height - lerpf(124, 130, roomy)
	var list_y := origin.y + lerpf(302, 402, roomy)
	var list_bottom := minf(origin.y + lerpf(504, 770, roomy), back_y - 12)
	_row_height = lerpf(48, 54, roomy)
	layout = {
		"safe": safe, "roomy": roomy,
		"frame": Rect2(origin + Vector2(margin, lerpf(10, 18, roomy)), Vector2(width - margin * 2, height - lerpf(20, 36, roomy))),
		"title": Rect2(origin.x + margin + 22, origin.y + lerpf(20, 47, roomy), width - (margin + 22) * 2, 34),
		"subtitle": Rect2(left, origin.y + lerpf(52, 86, roomy), content_width, 22),
		"own": Rect2(left, origin.y + lerpf(82, 128, roomy), content_width, lerpf(86, 116, roomy)),
		"target": Rect2(left, origin.y + lerpf(178, 256, roomy), content_width, lerpf(54, 74, roomy)),
		"tabs": Rect2(left, origin.y + lerpf(242, 344, roomy), content_width, 48),
		"list": Rect2(left, list_y, content_width, maxf(80, list_bottom - list_y)),
		"back": Rect2(left + 10, back_y, content_width - 20, lerpf(48, 54, roomy)),
		"actions": Rect2(left, origin.y + height - lerpf(66, 68, roomy), content_width, 48),
		"join": Rect2(left, origin.y + lerpf(242, 344, roomy), content_width, maxf(120, list_bottom - origin.y - lerpf(242, 344, roomy))),
	}
	_rebuild()


func _remember_scroll() -> void:
	if is_instance_valid(scroll) and not _restoring_scroll:
		_scroll_positions[_scroll_context] = scroll.scroll_vertical


func _rebuild() -> void:
	_generation += 1
	for child in ui.get_children():
		ui.remove_child(child)
		child.queue_free()
	buttons.clear()
	drawn_rows.clear()
	scroll = null
	list = null
	name_input = null
	_button("back", _tr("ZPĚT NA CESTU PĚSTITELE", "BACK TO GROWER PATH"), layout.back, _close, true)
	if status == "join" and not bool(profile.get("joined", false)):
		_build_join()
	else:
		_build_board()
	var actions: Rect2 = layout.actions
	var half := (actions.size.x - 12) * 0.5
	var refresh := _button("refresh", _tr("OBNOVIT", "REFRESH"), Rect2(actions.position, Vector2(half, 48)), _refresh, false)
	var leave := _button("leave", _tr("OPUSTIT ŽEBŘÍČEK", "LEAVE BOARD"), Rect2(actions.position + Vector2(half + 12, 0), Vector2(half, 48)), _leave, false)
	var joined_actions := bool(profile.get("joined", false)) and status not in ["join", "unavailable"]
	refresh.visible = joined_actions
	leave.visible = joined_actions
	refresh.disabled = not joined_actions or status == "loading"
	leave.disabled = not joined_actions
	queue_redraw()
	_restoring_scroll = true
	_restore_scroll.call_deferred(_generation, _scroll_context)


func _build_board() -> void:
	var tabs: Rect2 = layout.tabs
	var half := (tabs.size.x - 12) * 0.5
	var nearby := _button("nearby", _tr("KOLEM MĚ", "AROUND ME"), Rect2(tabs.position, Vector2(half, 48)), _set_page.bind("nearby"), page == "nearby")
	var top := _button("top", _tr("NEJLEPŠÍCH 100", "TOP 100"), Rect2(tabs.position + Vector2(half + 12, 0), Vector2(half, 48)), _set_page.bind("top"), page == "top")
	nearby.disabled = status in ["unavailable", "loading"]
	top.disabled = nearby.disabled
	var frame: Rect2 = layout.list
	_scroll_context = page
	_make_scroll(Rect2(frame.position + Vector2(12, 36), frame.size - Vector2(24, 46)))
	list = VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.mouse_filter = Control.MOUSE_FILTER_PASS
	list.add_theme_constant_override("separation", 6 if float(layout.roomy) < 0.5 else 8)
	scroll.add_child(list)
	var rows: Array = [] if status == "unavailable" else snapshot.get("nearby" if page == "nearby" else "top", [])
	for row: Dictionary in rows:
		var line := Control.new()
		line.custom_minimum_size = Vector2(0, _row_height)
		line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line.mouse_filter = Control.MOUSE_FILTER_PASS
		line.material = CanvasItemMaterial.new()
		line.draw.connect(_draw_row.bind(line, row.duplicate(true)))
		list.add_child(line)
		drawn_rows.append(row.duplicate(true))


func _build_join() -> void:
	_scroll_context = "join"
	var frame: Rect2 = layout.join
	_make_scroll(Rect2(frame.position + Vector2(10, 10), frame.size - Vector2(20, 20)))
	var content := Control.new()
	var width := maxf(1, frame.size.x - 34)
	content.custom_minimum_size = Vector2(width, 316)
	content.material = CanvasItemMaterial.new()
	scroll.add_child(content)
	var label := Label.new()
	label.text = _tr("TVÁ PŘEZDÍVKA", "YOUR DISPLAY NAME")
	_style_label(label)
	label.position = Vector2(4, 0)
	label.size = Vector2(width - 8, 22)
	content.add_child(label)
	name_input = LineEdit.new()
	name_input.position = Vector2(4, 28)
	name_input.size = Vector2(width - 8, 48)
	name_input.max_length = 18
	name_input.text = _draft_name
	name_input.placeholder_text = _tr("Přezdívka pro ostatní", "Name other growers see")
	name_input.material = CanvasItemMaterial.new()
	name_input.add_theme_font_override("font", Body)
	name_input.add_theme_font_size_override("font_size", 14)
	name_input.add_theme_color_override("font_color", INK)
	name_input.add_theme_stylebox_override("normal", _flat(Color("#fff8df"), 10))
	name_input.add_theme_stylebox_override("focus", _flat(Color("#eef2d9"), 10))
	name_input.text_changed.connect(_name_changed)
	name_input.text_submitted.connect(func(_value: String): _join())
	content.add_child(name_input)
	var portrait_gap := 8.0
	var portrait_width := minf(64, (width - 8 - portrait_gap * 3) / 4)
	for index in range(Portraits.size()):
		var choice := _button("portrait_%d" % index, "", Rect2(4 + index * (portrait_width + portrait_gap), 88, portrait_width, 56), _choose_portrait.bind(index), index == _draft_portrait, content)
		choice.tooltip_text = [_tr("Bazalka", "Basil"), _tr("Máta", "Mint"), _tr("Levandule", "Lavender"), _tr("Bylinkový čaj", "Herbal tea")][index]
		choice.draw.connect(_draw_portrait_choice.bind(choice, index))
	var consent := Label.new()
	_style_label(consent)
	consent.text = _tr("Zveřejní se přezdívka, portrét, XP a úroveň. Profil je vázaný na toto zařízení, ne na e-mail.", "Your display name, portrait, XP and level will be public. This profile is tied to this device, not to an email address.")
	consent.position = Vector2(4, 156)
	consent.size = Vector2(width - 8, 88)
	consent.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(consent)
	var join := _button("join", _tr("ZAPOJIT SE", "JOIN LEADERBOARD"), Rect2(4, 256, width - 8, 48), _join, true, content)
	join.disabled = not _valid_name(_draft_name)


func _make_scroll(rect: Rect2) -> void:
	scroll = ScrollContainer.new()
	scroll.position = rect.position
	scroll.size = Vector2(maxf(1, rect.size.x), maxf(1, rect.size.y))
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.scroll_deadzone = 6
	scroll.follow_focus = false
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	scroll.add_theme_constant_override("scrollbar_h_separation", 8)
	scroll.material = CanvasItemMaterial.new()
	ui.add_child(scroll)
	var bar := scroll.get_v_scroll_bar()
	bar.material = CanvasItemMaterial.new()
	bar.custom_minimum_size.x = 6
	bar.add_theme_stylebox_override("scroll", _flat(Color("#dedfc4"), 4))
	for state in ["grabber", "grabber_highlight", "grabber_pressed"]:
		bar.add_theme_stylebox_override(state, _flat(Color("#92a474"), 4))


func _restore_scroll(generation: int, context: String) -> void:
	if not is_inside_tree():
		return
	await get_tree().process_frame
	if generation != _generation or context != _scroll_context or not is_instance_valid(scroll):
		return
	var bar := scroll.get_v_scroll_bar()
	scroll.scroll_vertical = clampi(int(_scroll_positions.get(context, 0)), 0, maxi(0, int(bar.max_value - bar.page)))
	_restoring_scroll = false


func _set_page(next: String) -> void:
	if next == page or status in ["unavailable", "loading"]:
		return
	_remember_scroll()
	page = next
	_rebuild()


func _close() -> void:
	hide_board()
	closed.emit()


func _refresh() -> void:
	if bool(profile.get("joined", false)) and status not in ["unavailable", "join", "loading"]:
		_remember_scroll()
		refresh_requested.emit()


func _leave() -> void:
	if bool(profile.get("joined", false)) and status not in ["unavailable", "join"]:
		leave_requested.emit()


func _valid_name(value: String) -> bool:
	var clean := value.strip_edges()
	return clean.length() >= 1 and clean.length() <= 18 and _name_pattern.search(clean) != null


func _name_changed(value: String) -> void:
	_draft_name = value
	if buttons.has("join"):
		buttons.join.disabled = not _valid_name(value)


func _choose_portrait(index: int) -> void:
	_draft_portrait = index
	_remember_scroll()
	_rebuild()


func _join() -> void:
	if status == "join" and not bool(profile.get("joined", false)) and _valid_name(_draft_name):
		join_requested.emit(_draft_name.strip_edges(), _draft_portrait)


func _unhandled_key_input(event: InputEvent) -> void:
	# Main owns Android system navigation. Keep the desktop Escape shortcut
	# separate so this child cannot compete with its host's close path.
	if OS.has_feature("android"):
		return
	if is_visible_in_tree() and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		_close()


func _button(key: String, caption: String, rect: Rect2, action: Callable, selected: bool, parent: Control = null) -> Button:
	var button := Button.new()
	button.position = rect.position
	button.size = rect.size
	button.text = caption
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.material = CanvasItemMaterial.new()
	button.add_theme_font_override("font", Bold)
	button.add_theme_font_size_override("font_size", 12)
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(state, art.painted_box("sage" if selected else "banner", OWN if state == "pressed" else Color.WHITE))
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		button.add_theme_color_override(state, INK)
	button.add_theme_color_override("font_disabled_color", MUTED)
	button.pressed.connect(action)
	(ui if parent == null else parent).add_child(button)
	buttons[key] = button
	return button


func _style_label(label: Label) -> void:
	label.material = CanvasItemMaterial.new()
	label.add_theme_font_override("font", Body)
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", INK)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _flat(color: Color, radius: int) -> StyleBoxFlat:
	var result := StyleBoxFlat.new()
	result.bg_color = color
	result.set_corner_radius_all(radius)
	return result


func _own_rank() -> int:
	if status == "unavailable":
		return 0
	var me: Dictionary = snapshot.get("me", {})
	if not str(profile.get("id", "")).is_empty() and str(me.get("id", "")) == str(profile.get("id", "")):
		return maxi(0, int(me.get("rank", 0)))
	return maxi(0, int(profile.get("rank", 0)))


func _draw() -> void:
	view_text.clear()
	if not is_instance_valid(art) or layout.is_empty():
		return
	draw_texture_rect(PaintedSkin.Background, Rect2(Vector2.ZERO, size), false)
	draw_rect(Rect2(Vector2.ZERO, size), Color(.12, .20, .10, .23))
	draw_style_box(art.painted_box("cream"), layout.frame)
	_text(self, _tr("ŽEBŘÍČEK PĚSTITELŮ", "GROWER LEADERBOARD"), layout.title, 21, INK)
	_text(self, _tr("Každá zahrada roste svým tempem.", "Every garden grows at its own pace."), layout.subtitle, 12, MUTED)
	_draw_own_card()
	_draw_target()
	if status == "join" and not bool(profile.get("joined", false)):
		draw_style_box(art.painted_box("cream"), layout.join)
	else:
		var frame: Rect2 = layout.list
		draw_style_box(art.painted_box("cream"), frame)
		_text(self, _tr("POŘADÍ", "RANK"), Rect2(frame.position + Vector2(12, 10), Vector2(60, 20)), 12, MUTED, HORIZONTAL_ALIGNMENT_LEFT)
		_text(self, _tr("PĚSTITEL", "GROWER"), Rect2(frame.position + Vector2(106, 10), Vector2(frame.size.x - 188, 20)), 12, MUTED, HORIZONTAL_ALIGNMENT_LEFT)
		_text(self, _tr("ÚROVEŇ", "LEVEL"), Rect2(frame.end.x - 72, frame.position.y + 10, 60, 20), 12, MUTED)
		if drawn_rows.is_empty():
			var message := _tr("Zatím tu není žádný přehled.", "There is no board to show yet.")
			if status == "unavailable":
				message = _tr("Po připojení uvidíš i ostatní pěstitele.", "Once connected, you will see other growers too.")
			elif status == "loading":
				message = _tr("Načítám přehled…", "Loading the board…")
			_block(message, Rect2(frame.position + Vector2(24, 70), frame.size - Vector2(48, 90)), 12, MUTED)
		var note_y := frame.end.y + 10
		if status != "unavailable" and float((layout.back as Rect2).position.y) - note_y >= 23:
			_text(self, _tr("Shodné XP znamenají společné pořadí.", "Equal XP share the same rank."), Rect2(frame.position.x, note_y, frame.size.x, 22), 12, MUTED)
	if status == "unavailable":
		_text(self, _tr("TVŮJ POSTUP ZŮSTÁVÁ V ZAŘÍZENÍ", "YOUR PROGRESS STAYS ON THIS DEVICE"), layout.actions, 12, MUTED)


func _draw_own_card() -> void:
	var rect: Rect2 = layout.own
	var roomy := float(layout.roomy)
	draw_style_box(art.painted_box("cream", Color("#e6edcf")), rect)
	var portrait_width := lerpf(52, 70, roomy)
	_fit(self, Portraits[clampi(int(profile.get("portrait", 0)), 0, 3)], Rect2(rect.position + Vector2(lerpf(12, 15, roomy), lerpf(8, 13, roomy)), Vector2(portrait_width, lerpf(70, 87, roomy))))
	var text_x := rect.position.x + lerpf(12, 15, roomy) + portrait_width + 11
	var rank_rect := Rect2(rect.end.x - 86, rect.position.y + lerpf(22, 27, roomy), 66, 38)
	var text_width := maxf(1, rank_rect.position.x - text_x - 10)
	_text(self, _tr("TVOJE ZAHRADA", "YOUR GARDEN"), Rect2(text_x, rect.position.y + lerpf(9, 16, roomy), text_width, 20), 12, MUTED, HORIZONTAL_ALIGNMENT_LEFT)
	_text(self, str(profile.get("name", _tr("Pěstitel", "Grower"))), Rect2(text_x, rect.position.y + lerpf(29, 38, roomy), text_width, 28), 18, INK, HORIZONTAL_ALIGNMENT_LEFT)
	var level := maxi(1, int(profile.get("level", 1)))
	var xp := maxi(0, int(profile.get("xp", 0)))
	var summary := _tr("Úroveň %s · %s XP", "Level %s · %s XP") % [_number(level), _number(xp)]
	if Body.get_string_size(summary, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x > text_width:
		summary = _tr("Úr. %s · %s XP", "Lv %s · %s XP") % [_compact(level), _compact(xp)]
	_text(self, summary, Rect2(text_x, rect.position.y + lerpf(57, 71, roomy), text_width, 22), 12, INK, HORIZONTAL_ALIGNMENT_LEFT)
	var rank := _own_rank()
	_text(self, (_number(rank) + ".") if rank > 0 else "—", rank_rect, 28, INK)
	_text(self, _tr("MÍSTO", "RANK"), Rect2(rank_rect.position.x, rect.position.y + lerpf(57, 70, roomy), rank_rect.size.x, 20), 12, MUTED)


func _draw_target() -> void:
	var rect: Rect2 = layout.target
	draw_style_box(art.painted_box("banner"), rect)
	var title := _tr("Další příčka je blízko", "The next place is close")
	var detail := ""
	match status:
		"unavailable":
			title = _tr("Online žebříček se připravuje", "The online leaderboard is being prepared")
			detail = _tr("Tvoje úroveň zůstává uložená.", "Your level stays saved.")
		"loading":
			title = _tr("Načítám žebříček", "Loading the leaderboard")
			detail = _tr("Tvoje úroveň zůstává uložená.", "Your level stays saved.")
		"offline":
			title = _tr("Jsi bez připojení", "You are offline")
			detail = _tr("Zobrazený přehled může být starší.", "The displayed board may be older.")
		"error":
			title = _tr("Přehled se nepodařilo načíst", "The board could not be loaded")
			detail = _tr("Zkus ho za chvíli obnovit.", "Try refreshing it in a moment.")
		"join":
			title = _tr("Přidej svou zahradu", "Add your garden")
			detail = _tr("Zvol si přezdívku a portrét.", "Choose your display name and portrait.")
		_:
			var target: Dictionary = snapshot.get("target", {})
			if target.is_empty():
				title = _tr("Patří ti první místo", "Your garden is in first place") if _own_rank() == 1 else _tr("Každá zahrada má svůj příběh", "Every garden has its own story")
				detail = _tr("Tvoje zahrada roste dál.", "Your garden keeps growing.")
			else:
				detail = _tr("%s XP k předstižení: %s", "%s XP to pass: %s") % [_compact(maxi(0, int(target.get("gap_to_overtake", 0)))), str(target.get("name", ""))]
	if status == "unavailable":
		var title_height := Bold.get_height(14)
		var detail_height := Body.get_height(12)
		var gap := 2.0
		var top := rect.position.y + (rect.size.y - title_height - gap - detail_height) * 0.5
		_text(self, title, Rect2(rect.position.x + 15, top, rect.size.x - 30, title_height), 14, INK)
		_block(detail, Rect2(rect.position.x + 18, top + title_height + gap, rect.size.x - 36, detail_height), 12, MUTED)
	else:
		_text(self, title, Rect2(rect.position + Vector2(15, 5), Vector2(rect.size.x - 30, 24)), 14, INK)
		_block(detail, Rect2(rect.position + Vector2(18, 28), Vector2(rect.size.x - 36, rect.size.y - 30)), 12, MUTED)


func _draw_row(node: Control, row: Dictionary) -> void:
	var width := node.size.x
	var mine := not str(profile.get("id", "")).is_empty() and str(row.get("id", "")) == str(profile.get("id", ""))
	if mine:
		node.draw_style_box(_flat(OWN, 12), Rect2(0, 0, width, _row_height))
		node.draw_line(Vector2(3, 11), Vector2(3, _row_height - 11), Color("#7b9051"), 3, true)
	else:
		node.draw_line(Vector2(8, _row_height - 1), Vector2(width - 8, _row_height - 1), Color(.36, .40, .25, .15), 1, true)
	var rank := maxi(0, int(row.get("rank", 0)))
	if rank >= 1 and rank <= 3:
		var tint: Color = [Color.WHITE, Color("#d0dac7"), Color("#d9ad78")][rank - 1]
		node.draw_texture_rect_region(art.icon_art, Rect2(4, (_row_height - 34) * .5, 34, 34), art.icon_regions[3], tint)
		_text(node, str(rank), Rect2(7, (_row_height - 22) * .5, 28, 22), 12, INK)
	else:
		_text(node, (_number(rank) + ".") if rank > 0 else "—", Rect2(3, (_row_height - 24) * .5, 40, 24), 12, INK)
	_fit(node, Portraits[clampi(int(row.get("portrait", 0)), 0, 3)], Rect2(46, 3, 39, _row_height - 6))
	var row_name := (_tr("Ty · ", "You · ") if mine else "") + str(row.get("name", ""))
	_text(node, row_name, Rect2(94, 3, maxf(1, width - 148), 23), 12, INK, HORIZONTAL_ALIGNMENT_LEFT)
	var xp := maxi(0, int(row.get("xp", 0)))
	var xp_text := _number(xp) + " XP"
	if Body.get_string_size(xp_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x > width - 148:
		xp_text = _compact(xp) + " XP"
	_text(node, xp_text, Rect2(94, 26, maxf(1, width - 148), 20), 12, MUTED, HORIZONTAL_ALIGNMENT_LEFT)
	_text(node, _compact(maxi(1, int(row.get("level", 1)))), Rect2(width - 46, (_row_height - 28) * .5, 40, 28), 18, INK)


func _draw_portrait_choice(button: Button, index: int) -> void:
	_fit(button, Portraits[index], Rect2(Vector2(8, 5), button.size - Vector2(16, 10)))


func _text(node: CanvasItem, value: String, rect: Rect2, font_size: int, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER) -> void:
	var font: Font = Bold
	var fitted_size := maxi(12, font_size)
	while fitted_size > 12 and font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, fitted_size).x > rect.size.x:
		fitted_size -= 1
	var shown := _ellipsis(value, font, fitted_size, rect.size.x)
	var baseline := rect.position.y + (rect.size.y - font.get_height(fitted_size)) * .5 + font.get_ascent(fitted_size)
	node.draw_string(font, Vector2(rect.position.x, baseline), shown, align, maxf(1, rect.size.x), fitted_size, color)
	if node == self:
		view_text.append({"text": value, "shown": shown, "font_size": fitted_size, "font": "bold", "rect": rect})


func _block(value: String, rect: Rect2, font_size: int, color: Color) -> void:
	var words := value.split(" ", false)
	var lines: Array[String] = []
	var current := ""
	for word: String in words:
		var candidate := word if current.is_empty() else current + " " + word
		if not current.is_empty() and Body.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > rect.size.x:
			lines.append(current)
			current = word
		else:
			current = candidate
	if not current.is_empty():
		lines.append(current)
	var line_height := Body.get_height(font_size)
	var max_lines := maxi(1, floori(rect.size.y / line_height))
	for index in range(mini(max_lines, lines.size())):
		var line := lines[index]
		if index == max_lines - 1 and lines.size() > max_lines:
			line += "…"
		line = _ellipsis(line, Body, font_size, rect.size.x)
		var at := Vector2(rect.position.x, rect.position.y + index * line_height + Body.get_ascent(font_size))
		draw_string(Body, at, line, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, font_size, color)
		view_text.append({"text": lines[index], "shown": line, "font_size": font_size, "font": "body", "rect": Rect2(rect.position + Vector2(0, index * line_height), Vector2(rect.size.x, line_height))})


func _ellipsis(value: String, font: Font, font_size: int, width: float) -> String:
	if font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= width:
		return value
	var shortened := value
	while not shortened.is_empty() and font.get_string_size(shortened + "…", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > width:
		shortened = shortened.left(shortened.length() - 1)
	return shortened + "…"


func _fit(node: CanvasItem, texture: Texture2D, rect: Rect2) -> void:
	var ratio := minf(rect.size.x / texture.get_width(), rect.size.y / texture.get_height())
	var dimensions := Vector2(texture.get_size()) * ratio
	node.draw_texture_rect(texture, Rect2(rect.get_center() - dimensions * .5, dimensions), false)


func _number(value: int) -> String:
	var result := str(maxi(0, value))
	var at := result.length() - 3
	while at > 0:
		result = result.insert(at, " ")
		at -= 3
	return result


func _compact(value: int) -> String:
	if value < 100000:
		return _number(value)
	var units := ["", "k", "M", "G", "T", "P", "E"]
	var amount := float(value)
	var unit := 0
	while amount >= 1000 and unit < units.size() - 1:
		amount /= 1000.0
		unit += 1
	var shown := ("%.1f" % amount).trim_suffix(".0")
	if _locale == "cs":
		shown = shown.replace(".", ",")
	return shown + str(units[unit])


func _tr(cs: String, en: String) -> String:
	return en if _locale == "en" else cs


func get_debug_snapshot() -> Dictionary:
	var controls := {}
	for key: String in buttons:
		var button: Button = buttons[key]
		controls[key] = {"rect": button.get_global_rect(), "visible": button.is_visible_in_tree(), "disabled": button.disabled, "font_size": button.get_theme_font_size("font_size")}
	return {"status": status, "profile": profile.duplicate(true), "page": page, "visible": is_visible_in_tree(), "rank": _own_rank(), "rank_text": (_number(_own_rank()) + ".") if _own_rank() > 0 else "—", "layout": layout.duplicate(true), "buttons": controls, "rows": drawn_rows.duplicate(true), "text": view_text.duplicate(true), "scroll_vertical": scroll.scroll_vertical if is_instance_valid(scroll) else 0, "minimum_font_size": 12, "minimum_target_size": 48, "safe_insets": safe_insets, "reduced_motion": _reduced_motion}
