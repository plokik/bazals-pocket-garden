class_name AudioSettingsPresenter
extends RefCounted

const ComicUITheme := preload("res://scripts/ui/comic_ui.gd")
const DISABLED_COLOR := Color("#73838c")

var music_button: Button
var sfx_button: Button
var haptics_button: Button
var motion_button: Button
var music_slider: HSlider
var sfx_slider: HSlider
var status_label: Label


func bind(
	target_music_button: Button,
	target_sfx_button: Button,
	target_haptics_button: Button,
	target_motion_button: Button,
	target_music_slider: HSlider,
	target_sfx_slider: HSlider,
	target_status_label: Label
) -> void:
	music_button = target_music_button
	sfx_button = target_sfx_button
	haptics_button = target_haptics_button
	motion_button = target_motion_button
	music_slider = target_music_slider
	sfx_slider = target_sfx_slider
	status_label = target_status_label


func is_bound() -> bool:
	return music_button != null and sfx_button != null and haptics_button != null and motion_button != null and music_slider != null and sfx_slider != null and status_label != null


func refresh(music_enabled: bool, sfx_enabled: bool, haptics_enabled: bool, reduced_motion: bool, music_volume: float, sfx_volume: float) -> void:
	if not is_bound():
		return
	music_button.set_pressed_no_signal(music_enabled)
	sfx_button.set_pressed_no_signal(sfx_enabled)
	haptics_button.set_pressed_no_signal(haptics_enabled)
	motion_button.set_pressed_no_signal(not reduced_motion)
	music_button.text = "HUDBA · %s" % ("ZAP" if music_enabled else "VYP")
	sfx_button.text = "ZVUKY · %s" % ("ZAP" if sfx_enabled else "VYP")
	haptics_button.text = "VIBRACE · %s" % ("ZAP" if haptics_enabled else "VYP")
	motion_button.text = "ANIMACE · %s" % ("PLNÉ" if not reduced_motion else "MÉNĚ")
	for button in [music_button, sfx_button, haptics_button, motion_button]:
		ComicUITheme.apply_button(button, ComicUITheme.GREEN if button.button_pressed else DISABLED_COLOR, ComicUITheme.CREAM, 13)
	music_slider.set_value_no_signal(music_volume * 100.0)
	sfx_slider.set_value_no_signal(sfx_volume * 100.0)


func show_status(message: String) -> void:
	if status_label != null:
		status_label.text = message
