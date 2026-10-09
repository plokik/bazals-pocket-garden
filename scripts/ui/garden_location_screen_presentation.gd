extends RefCounted
## Approved room/greenhouse presentation. Reads existing controls and state only.
## Painting, collection geometry, navigation signals and simulation stay owned by
## the original views. Historical captures opt out before entering the tree.

const Art := preload("res://scripts/ui/plant_detail_painted_assets.gd")
const Buttons := preload("res://scripts/ui/care_center_skin.gd")
const Comic := preload("res://scripts/ui/comic_ui.gd")
const FontBold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")
const FontBody := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const INK := Color("#173d30")
const SAGE := Color("#e7eec7")
const MUTED := Color("#637351")


func apply(game: Control) -> void:
	if game.player_room_view.screen_presentation != null:
		return
	var room: PlayerRoomCollectionView = game.player_room_view
	var greenhouse: GreenhousePreviewView = game.greenhouse_preview_view
	room.screen_presentation = self
	greenhouse.screen_presentation = self
	room.back_button.text = "← STOJAN"
	room.theme_button.text = "VZHLED"
	for button: Button in [room.back_button, room.theme_button, greenhouse.back_button]:
		button.add_theme_font_override("font", FontBold)
		button.add_theme_font_size_override("font_size", 11)
		quiet_button(button)
	room._layout_navigation()
	greenhouse._layout_controls()
	greenhouse._refresh_controls()
	room.queue_redraw()
	greenhouse.queue_redraw()


func header_rect(view: Control) -> Rect2:
	# Enclose the room's baked chrome, including its original painted shadow.
	# The book/jar shelf to the right remains fully visible; no new art is needed.
	var width := minf(234.0, view.size.x * 0.55)
	if view.size.x > 432:
		width = 234.0 * view.size.x / 432.0
	return Rect2(0, 0, width, maxf(146, 146.0 * view.size.y / 795.0))


func layout_room(view: PlayerRoomCollectionView) -> void:
	var panel := header_rect(view)
	var button_width := (panel.size.x - 26.0) * 0.5
	view.back_button.position = Vector2(9, 74)
	view.back_button.size = Vector2(button_width, 64)
	view.theme_button.position = Vector2(17 + button_width, 74)
	view.theme_button.size = Vector2(button_width, 64)


func layout_greenhouse(view: GreenhousePreviewView) -> void:
	var panel := header_rect(view)
	var button_width := (panel.size.x - 26.0) * 0.5
	view.back_button.custom_minimum_size = Vector2(64, 64)
	view.back_button.position = Vector2(9, 74)
	view.back_button.size = Vector2(button_width, 64)
	var rep := reputation_rect(view)
	view.wallet_label.position = rep.position + Vector2(30, 5)
	view.wallet_label.size = rep.size - Vector2(35, 10)
	view.wallet_label.add_theme_font_size_override("font_size", 9)
	view.wallet_label.add_theme_color_override("font_color", INK)
	var status := view._status_rect()
	view.selected_title_label.position = status.position + Vector2(13, 10)
	view.selected_title_label.size = Vector2(status.size.x - 26, 24)
	view.selected_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	view.selected_title_label.add_theme_font_size_override("font_size", 12)
	view.selected_title_label.add_theme_color_override("font_color", INK)
	view.selected_detail_label.position = status.position + Vector2(13, 37)
	view.selected_detail_label.size = Vector2(status.size.x - 26, 36)
	view.selected_detail_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	view.selected_detail_label.add_theme_color_override("font_color", INK)


func refresh_greenhouse(view: GreenhousePreviewView) -> void:
	Buttons.button(view.action_button, "teal")
	view.action_button.add_theme_stylebox_override("disabled", soft_box(SAGE, 10))
	view.action_button.add_theme_font_size_override("font_size", 12)
	for button: Button in view.crop_buttons:
		Buttons.button(button, "sage")
		button.add_theme_stylebox_override("disabled", soft_box(Color("#e4e8d4"), 5))


func draw_header(view: Control, is_room: bool) -> void:
	var panel := header_rect(view)
	# The painted texture supplies its own opaque face and alpha-shaped corners.
	# A flat underlay would protrude as a cream crescent outside that contour.
	var frame := Art.box("cream", 9)
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		frame.set_texture_margin(side, 12)
	view.draw_style_box(frame, panel)
	var title := "MŮJ POKOJ" if is_room else "SKLENÍK"
	var subtitle := "DEKORACE · ÚSPĚCHY · MAZLÍČEK" if is_room else "4 ZÁHONY · 5 PLODIN"
	var title_line := Rect2(panel.position + Vector2(10, 16), Vector2(panel.size.x - 20, 24))
	var subtitle_line := Rect2(panel.position + Vector2(10, 44), Vector2(panel.size.x - 20, 16))
	view.draw_string(FontBold, Art.centered_text_baseline(FontBold, 17, title_line), title, HORIZONTAL_ALIGNMENT_CENTER, title_line.size.x, 17, INK)
	view.draw_string(FontBody, Art.centered_text_baseline(FontBody, 8, subtitle_line), subtitle, HORIZONTAL_ALIGNMENT_CENTER, subtitle_line.size.x, 8, MUTED)
	if not is_room:
		var rep := reputation_rect(view)
		view.draw_style_box(soft_box(SAGE, 0), rep)
		var leaf := Art.texture("leaf")
		view.draw_texture_rect(leaf, Rect2(rep.position + Vector2(8, 21), Vector2(20, 22)), false)


func reputation_rect(view: Control) -> Rect2:
	var panel := header_rect(view)
	var width := (panel.size.x - 26) * 0.5
	return Rect2(Vector2(17 + width, 74), Vector2(width, 64))


func draw_status(view: GreenhousePreviewView) -> void:
	var rect := view._status_rect()
	var style := Art.box("cream", 10)
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		style.set_texture_margin(side, 12)
	view.draw_style_box(style, rect)
	var state := view.bed_states[view.selected_bed_index]
	if str(state.get("stage", "")) == "growing":
		draw_progress(view, Rect2(rect.position + Vector2(13, 79), Vector2(rect.size.x - 26, 7)), float(state.get("progress", 0)))


func draw_progress(view: Control, rect: Rect2, progress: float) -> void:
	view.draw_style_box(Comic.style_box(Color("#e0e7cd"), Color("#81906a"), 1, 4, Color.TRANSPARENT, 0, 0), rect)
	var value := clampf(progress, 0, 1)
	if value <= 0:
		return
	var fill := Rect2(rect.position + Vector2.ONE, Vector2((rect.size.x - 2) * value, rect.size.y - 2))
	view.draw_style_box(Comic.style_box(Color("#6cac60"), Color.TRANSPARENT, 0, 3, Color.TRANSPARENT, 0, 0), fill)


func quiet_button(button: Button) -> void:
	for state in ["normal", "hover", "pressed", "disabled"]:
		var fill := Color("#edf0d8") if state == "normal" else Color("#dce8c9")
		button.add_theme_stylebox_override(state, Comic.style_box(fill, Color("#9aa883"), 1, 10, Color.TRANSPARENT, 0, 8))
		button.add_theme_color_override("font_color" if state == "normal" else "font_%s_color" % state, INK)
	button.add_theme_stylebox_override("focus", Comic.transparent_border(Color("#39785a"), 2, 10))
	button.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
	button.add_theme_constant_override("shadow_offset_y", 0)


func soft_box(fill: Color, padding: float) -> StyleBoxFlat:
	return Comic.style_box(fill, Color.TRANSPARENT, 0, 10, Color.TRANSPARENT, 0, padding)
