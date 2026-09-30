class_name PlayerSettingsModalView
extends RefCounted
## Constructs the existing settings UI without owning preferences or save state.
## Main supplies the actions, including its guarded cosmetic/backup button factory.

const ComicUITheme := preload("res://scripts/ui/comic_ui.gd")
const PaintedModalShell := preload("res://scripts/ui/painted_modal_shell.gd")
const FontSemiBold := preload("res://assets/fonts/Poppins-SemiBold.ttf")
const FontExtraBold := preload("res://assets/fonts/Poppins-ExtraBold.ttf")

var root: Control
var settings_music_button: Button
var settings_sfx_button: Button
var settings_haptics_button: Button
var settings_motion_button: Button
var settings_music_slider: HSlider
var settings_sfx_slider: HSlider
var settings_status_label: Label


func _init(
	action_button_factory: Callable,
	music_toggled: Callable,
	sfx_toggled: Callable,
	haptics_toggled: Callable,
	motion_toggled: Callable,
	music_volume_changed: Callable,
	sfx_volume_changed: Callable,
	show_cosmetics: Callable,
	show_backup: Callable,
	close_settings: Callable
) -> void:
	var modal := PaintedModalShell.create_overlay("fullscreen_player_settings_v1", 190, Color("#071823", 0.88), "PlayerSettingsModal")
	var overlay: Control = modal.overlay
	root = overlay
	var card := PaintedModalShell.create_anchored_card(
		overlay,
		Rect2(0.055, 0.145, 0.89, 0.69),
		ComicUITheme.style_box(Color("#fff8df"), ComicUITheme.PURPLE, 5, 23, Color("#050d16", 0.58), 9, 16.0),
		"comic_audio_settings_card_v1"
	)
	var column := PaintedModalShell.create_column(card, 10)
	var banner := PanelContainer.new()
	banner.custom_minimum_size.y = 78
	banner.add_theme_stylebox_override("panel", ComicUITheme.style_box(ComicUITheme.PURPLE, ComicUITheme.GOLD, 4, 17, Color("#08131e", 0.35), 4, 8.0))
	var title := Label.new()
	title.text = "NASTAVENÍ HRÁČE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", FontExtraBold)
	title.add_theme_font_size_override("font_size", 25)
	title.add_theme_color_override("font_color", ComicUITheme.CREAM)
	title.add_theme_color_override("font_outline_color", ComicUITheme.INK)
	title.add_theme_constant_override("outline_size", 2)
	banner.add_child(title)
	column.add_child(banner)

	var intro := Label.new()
	intro.text = "Nastav atmosféru zahrady, herní efekty a jemnou mobilní odezvu. Vše se ukládá automaticky."
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	intro.add_theme_font_override("font", FontSemiBold)
	intro.add_theme_font_size_override("font_size", 13)
	intro.add_theme_color_override("font_color", ComicUITheme.NAVY)
	column.add_child(intro)

	settings_music_button = _settings_toggle_button("HUDBA", music_toggled)
	settings_sfx_button = _settings_toggle_button("HERNÍ ZVUKY", sfx_toggled)
	settings_haptics_button = _settings_toggle_button("VIBRACE", haptics_toggled)
	settings_motion_button = _settings_toggle_button("ANIMACE", motion_toggled)
	var toggle_grid := GridContainer.new()
	toggle_grid.columns = 2
	toggle_grid.add_theme_constant_override("h_separation", 8)
	toggle_grid.add_theme_constant_override("v_separation", 8)
	for button in [settings_music_button, settings_sfx_button, settings_haptics_button, settings_motion_button]:
		toggle_grid.add_child(button)
	column.add_child(toggle_grid)

	column.add_child(_settings_slider_title("HLASITOST HUDBY"))
	settings_music_slider = _settings_slider(music_volume_changed)
	column.add_child(settings_music_slider)
	column.add_child(_settings_slider_title("HLASITOST EFEKTŮ"))
	settings_sfx_slider = _settings_slider(sfx_volume_changed)
	column.add_child(settings_sfx_slider)

	settings_status_label = Label.new()
	settings_status_label.text = "Teplá zahradní hudba · čitelné akční zvuky · jemné vibrace"
	settings_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	settings_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_status_label.add_theme_font_override("font", FontSemiBold)
	settings_status_label.add_theme_font_size_override("font_size", 12)
	settings_status_label.add_theme_color_override("font_color", ComicUITheme.INK)
	column.add_child(settings_status_label)
	var cosmetic_button: Button = action_button_factory.call("VZHLED POKOJE", show_cosmetics)
	cosmetic_button.custom_minimum_size.y = 60
	cosmetic_button.add_theme_font_override("font", FontExtraBold)
	cosmetic_button.add_theme_font_size_override("font_size", 16)
	ComicUITheme.apply_button(cosmetic_button, ComicUITheme.CYAN, ComicUITheme.INK, 14)
	cosmetic_button.set_meta("touch_target_min_height", 60)
	cosmetic_button.set_meta("component", "phase14_cosmetic_showroom_launcher_v1")
	column.add_child(cosmetic_button)
	var backup_button: Button = action_button_factory.call("ZÁLOHA POSTUPU", show_backup)
	backup_button.custom_minimum_size.y = 60
	backup_button.add_theme_font_override("font", FontExtraBold)
	backup_button.add_theme_font_size_override("font_size", 16)
	ComicUITheme.apply_button(backup_button, ComicUITheme.BLUE, ComicUITheme.CREAM, 14)
	backup_button.set_meta("touch_target_min_height", 60)
	backup_button.set_meta("component", "phase47_local_backup_launcher_v1")
	column.add_child(backup_button)

	var close_button := Button.new()
	close_button.text = "HOTOVO"
	close_button.custom_minimum_size.y = 68
	close_button.focus_mode = Control.FOCUS_NONE
	close_button.add_theme_font_override("font", FontExtraBold)
	close_button.add_theme_font_size_override("font_size", 18)
	ComicUITheme.apply_button(close_button, ComicUITheme.GREEN, ComicUITheme.CREAM, 15)
	close_button.set_meta("touch_target_min_height", 68)
	close_button.pressed.connect(close_settings)
	column.add_child(close_button)


func _settings_toggle_button(title: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = title
	button.toggle_mode = true
	button.custom_minimum_size = Vector2(0, 64)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_override("font", FontExtraBold)
	button.add_theme_font_size_override("font_size", 13)
	button.toggled.connect(callback)
	button.set_meta("touch_target_min_height", 64)
	return button


func _settings_slider_title(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", FontExtraBold)
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", ComicUITheme.NAVY)
	return label


func _settings_slider(callback: Callable) -> HSlider:
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 5.0
	slider.custom_minimum_size.y = 46
	slider.focus_mode = Control.FOCUS_NONE
	slider.value_changed.connect(callback)
	slider.set_meta("touch_target_min_height", 46)
	return slider


