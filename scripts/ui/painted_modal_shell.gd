extends RefCounted

## Shared non-visual construction layer for blocking painted modals.
## Callers keep ownership of their exact colors, geometry and content so moving
## an existing modal onto this shell does not silently change approved pixels.

const CONTRACT_ID := "painted_modal_shell_v1"


static func create_overlay(
	component: String,
	z_layer: int,
	scrim_color: Color,
	node_name := "",
	metadata: Dictionary = {}
) -> Dictionary:
	var overlay := Control.new()
	if not node_name.is_empty():
		overlay.name = node_name
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.z_index = z_layer
	overlay.visible = false
	overlay.set_meta("component", component)
	overlay.set_meta("blocks_game_input", true)
	overlay.set_meta("shared_modal_shell", CONTRACT_ID)
	for key in metadata:
		overlay.set_meta(str(key), metadata[key])

	var scrim := ColorRect.new()
	scrim.name = "PaintedScrim"
	scrim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scrim.color = scrim_color
	scrim.mouse_filter = Control.MOUSE_FILTER_STOP
	scrim.set_meta("shared_modal_shell", CONTRACT_ID)
	overlay.add_child(scrim)
	return {"overlay": overlay, "scrim": scrim}


static func create_anchored_card(
	overlay: Control,
	anchors: Rect2,
	style: StyleBox,
	component := ""
) -> PanelContainer:
	var card := PanelContainer.new()
	card.set_anchor(SIDE_LEFT, anchors.position.x)
	card.set_anchor(SIDE_TOP, anchors.position.y)
	card.set_anchor(SIDE_RIGHT, anchors.end.x)
	card.set_anchor(SIDE_BOTTOM, anchors.end.y)
	card.add_theme_stylebox_override("panel", style)
	card.set_meta("shared_modal_shell", CONTRACT_ID)
	if not component.is_empty():
		card.set_meta("component", component)
	overlay.add_child(card)
	return card


static func create_margin_shell(
	overlay: Control,
	margins: Vector4,
	style: StyleBox,
	component := ""
) -> PanelContainer:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", int(margins.x))
	margin.add_theme_constant_override("margin_top", int(margins.y))
	margin.add_theme_constant_override("margin_right", int(margins.z))
	margin.add_theme_constant_override("margin_bottom", int(margins.w))
	margin.set_meta("shared_modal_shell", CONTRACT_ID)
	overlay.add_child(margin)

	var shell := PanelContainer.new()
	shell.add_theme_stylebox_override("panel", style)
	shell.set_meta("shared_modal_shell", CONTRACT_ID)
	if not component.is_empty():
		shell.set_meta("component", component)
	margin.add_child(shell)
	return shell


static func create_column(
	parent: Control,
	separation: int,
	alignment := BoxContainer.ALIGNMENT_BEGIN
) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.alignment = alignment
	column.add_theme_constant_override("separation", separation)
	column.set_meta("shared_modal_shell", CONTRACT_ID)
	parent.add_child(column)
	return column
