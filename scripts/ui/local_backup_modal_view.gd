class_name LocalBackupModalView
extends Control
## Builds only the existing backup dialog. Game/save operations belong to Main.
## The supplied button factory retains Main's swipe guard for every action.

const ComicUITheme := preload("res://scripts/ui/comic_ui.gd")
const FontSemiBold := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const FontExtraBold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")

signal export_requested
signal import_requested
signal import_confirmation_requested
signal previous_restore_requested
signal new_game_requested
signal close_requested

var info_label: Label
var status_label: Label
var confirm_button: Button
var restore_previous_button: Button
var new_game_button: Button
var _card: PanelContainer
var _column: VBoxContainer
var _close_button: Button
var _compact_column: VBoxContainer
var _content_scroll: ScrollContainer
var _compact_layout := false
var _layout_queued := false


func _init(action_button_factory: Callable) -> void:
	var overlay: Control = self
	overlay.name = "LocalBackupModal"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = 260
	overlay.visible = false
	overlay.set_meta("component", "phase47_portable_local_backup_v1")
	overlay.set_meta("blocks_game_input", true)
	var scrim := ColorRect.new()
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = Color("#071823", 0.96)
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_child(scrim)
	var card := PanelContainer.new()
	card.set_anchor(SIDE_LEFT, 0.055)
	card.set_anchor(SIDE_TOP, 0.075)
	card.set_anchor(SIDE_RIGHT, 0.945)
	card.set_anchor(SIDE_BOTTOM, 0.925)
	card.add_theme_stylebox_override("panel", ComicUITheme.style_box(Color("#fff8df"), ComicUITheme.BLUE, 5, 22, Color("#000713", 0.68), 10, 15.0))
	overlay.add_child(card)
	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_theme_constant_override("separation", 12)
	card.add_child(column)
	_card = card
	_column = column
	var title := Label.new()
	title.text = "ZÁLOHA A POSTUP"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 23)
	title.add_theme_color_override("font_color", ComicUITheme.PURPLE)
	column.add_child(title)
	var intro := Label.new()
	intro.text = "Ulož si přenositelnou zálohu do telefonu nebo cloudu. Obnova vždy nejdřív ukáže náhled a nikdy nepřepíše postup bez potvrzení."
	intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.add_theme_font_override("font", FontSemiBold)
	intro.add_theme_font_size_override("font_size", 13)
	intro.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(intro)
	info_label = Label.new()
	info_label.custom_minimum_size.y = 46
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_label.add_theme_font_override("font", FontExtraBold)
	info_label.add_theme_font_size_override("font_size", 12)
	info_label.add_theme_color_override("font_color", ComicUITheme.PURPLE)
	info_label.set_meta("component", "phase56_version_save_status_v1")
	column.add_child(info_label)
	status_label = Label.new()
	status_label.text = "Připraveno k vytvoření nebo obnovení zálohy."
	status_label.custom_minimum_size.y = 82
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_override("font", FontExtraBold)
	status_label.add_theme_font_size_override("font_size", 13)
	status_label.add_theme_color_override("font_color", ComicUITheme.INK)
	column.add_child(status_label)
	var export_button: Button = action_button_factory.call("VYTVOŘIT ZÁLOHU", export_requested.emit)
	export_button.set_meta("component", "sage_backup_export_action_v1")
	export_button.custom_minimum_size.y = 64
	export_button.set_meta("touch_target_min_height", 64)
	ComicUITheme.apply_button(export_button, ComicUITheme.GREEN, ComicUITheme.CREAM, 14)
	column.add_child(export_button)
	var import_button: Button = action_button_factory.call("VYBRAT ZÁLOHU K OBNOVĚ", import_requested.emit)
	import_button.custom_minimum_size.y = 64
	import_button.set_meta("touch_target_min_height", 64)
	ComicUITheme.apply_button(import_button, ComicUITheme.CYAN, ComicUITheme.INK, 13)
	column.add_child(import_button)
	confirm_button = action_button_factory.call("POTVRDIT OBNOVU", import_confirmation_requested.emit)
	confirm_button.custom_minimum_size.y = 64
	confirm_button.set_meta("touch_target_min_height", 64)
	confirm_button.visible = false
	ComicUITheme.apply_button(confirm_button, ComicUITheme.ORANGE, ComicUITheme.CREAM, 13)
	column.add_child(confirm_button)
	restore_previous_button = action_button_factory.call("OBNOVIT PŘEDCHOZÍ HRU", previous_restore_requested.emit)
	restore_previous_button.custom_minimum_size.y = 64
	restore_previous_button.set_meta("touch_target_min_height", 64)
	restore_previous_button.set_meta("component", "phase58_restore_previous_game_v1")
	restore_previous_button.visible = false
	ComicUITheme.apply_button(restore_previous_button, ComicUITheme.BLUE, ComicUITheme.CREAM, 13)
	column.add_child(restore_previous_button)
	new_game_button = action_button_factory.call("ZAČÍT NOVOU HRU", new_game_requested.emit)
	new_game_button.custom_minimum_size.y = 64
	new_game_button.set_meta("touch_target_min_height", 64)
	new_game_button.set_meta("component", "phase56_safe_new_game_v1")
	ComicUITheme.apply_button(new_game_button, ComicUITheme.ORANGE, ComicUITheme.CREAM, 13)
	column.add_child(new_game_button)
	var close_button: Button = action_button_factory.call("ZPĚT", close_requested.emit)
	close_button.custom_minimum_size.y = 64
	close_button.set_meta("touch_target_min_height", 64)
	ComicUITheme.apply_button(close_button, ComicUITheme.PURPLE, ComicUITheme.CREAM, 14)
	column.add_child(close_button)
	_close_button = close_button
	_compact_column = VBoxContainer.new()
	_compact_column.add_theme_constant_override("separation", 12)
	_compact_column.visible = false
	card.add_child(_compact_column)
	_content_scroll = ScrollContainer.new()
	_content_scroll.name = "BackupContentScroll"
	_content_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_content_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_scroll.follow_focus = true
	_content_scroll.scroll_deadzone = 12
	_compact_column.add_child(_content_scroll)
	resized.connect(_queue_compact_layout)
	visibility_changed.connect(_queue_compact_layout)
	column.minimum_size_changed.connect(_queue_compact_layout)
	_queue_compact_layout()


func _queue_compact_layout() -> void:
	if _layout_queued:
		return
	_layout_queued = true
	_update_compact_layout.call_deferred()


func _update_compact_layout() -> void:
	_layout_queued = false
	if not is_inside_tree() or size.y <= 0.0:
		return
	var natural_height := _column.get_combined_minimum_size().y
	if _compact_layout:
		natural_height += 12.0 + _close_button.get_combined_minimum_size().y
	var legacy_bottom := maxf(size.y * 0.925, size.y * 0.075 + natural_height + 30.0)
	var needs_scroll := legacy_bottom > size.y - 16.0
	if needs_scroll != _compact_layout:
		_compact_layout = needs_scroll
		if needs_scroll:
			_column.reparent(_content_scroll, false)
			_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			_close_button.reparent(_compact_column, false)
			_compact_column.visible = true
		else:
			_close_button.reparent(_column, false)
			_column.reparent(_card, false)
			_compact_column.visible = false
			_content_scroll.scroll_vertical = 0
	_card.set_anchor(SIDE_TOP, 0.04 if needs_scroll else 0.075)
	_card.set_anchor(SIDE_BOTTOM, 0.96 if needs_scroll else 0.925)
	_card.offset_top = 0.0
	_card.offset_bottom = 0.0
	set_meta("compact_scroll_layout", needs_scroll)
