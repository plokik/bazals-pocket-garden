class_name TooltipPolicy
extends RefCounted


static func apply(control: Control, text_value: String, mobile_override: Variant = null) -> void:
	if control == null:
		return
	var mobile := OS.has_feature("mobile") if mobile_override == null else bool(mobile_override)
	control.set_meta("tooltip_policy", "mobile_suppressed_desktop_comic_v1")
	control.set_meta("desktop_tooltip_text", text_value)
	control.tooltip_text = "" if mobile else text_value
