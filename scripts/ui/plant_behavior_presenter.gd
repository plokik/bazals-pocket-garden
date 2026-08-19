class_name PlantBehaviorPresenter
extends RefCounted

## Presents the profile-driven plant behavior without leaking it into the
## diagnosis problem count. A trigger is emitted only when an already observed
## plant changes from an inactive behavior to an active one.

const ACTIVE_TITLE := "VLASTNOST AKTIVNÍ"
const COMPONENT_ID := "plant_behavior_active_badge_v1"

var panel: Control
var title_label: Label
var value_label: Label

var observed_plant_instance_id := 0
var observation_initialized := false
var previous_active_ids: Array[String] = []


func bind(new_panel: Control, new_title_label: Label, new_value_label: Label) -> void:
	panel = new_panel
	title_label = new_title_label
	value_label = new_value_label
	if not is_bound():
		return
	panel.set_meta("component", COMPONENT_ID)
	panel.set_meta("active_only", true)
	panel.set_meta("behavior_active", false)
	panel.set_meta("behavior_id", "")
	title_label.text = ACTIVE_TITLE
	value_label.text = ""
	panel.visible = false


func is_bound() -> bool:
	return is_instance_valid(panel) and is_instance_valid(title_label) and is_instance_valid(value_label)


func reset_observation() -> void:
	observed_plant_instance_id = 0
	observation_initialized = false
	previous_active_ids.clear()
	_apply_inactive_state()


func refresh(plant: PlantSimulation) -> Dictionary:
	var state := {
		"active": false,
		"just_activated": false,
		"behavior_id": "",
		"label": "",
		"status_text": "",
		"active_count": 0,
	}
	if plant == null:
		reset_observation()
		return state

	var active_ids: Array[String] = []
	var active_entries: Dictionary = {}
	for raw_entry in plant.get_behavior_status_entries():
		if not raw_entry is Dictionary:
			continue
		var entry: Dictionary = raw_entry
		if not bool(entry.get("active", false)):
			continue
		var behavior_id := str(entry.get("id", "")).strip_edges()
		if behavior_id.is_empty():
			continue
		active_ids.append(behavior_id)
		active_entries[behavior_id] = entry
		if not bool(state["active"]):
			state["active"] = true
			state["behavior_id"] = behavior_id
			state["label"] = str(entry.get("label", "")).strip_edges()
			state["status_text"] = str(entry.get("status_text", "")).strip_edges()
	state["active_count"] = active_ids.size()

	var instance_id := int(plant.get_instance_id())
	var same_observation := observation_initialized and observed_plant_instance_id == instance_id
	if same_observation:
		for behavior_id in active_ids:
			if not previous_active_ids.has(behavior_id):
				var activated_entry: Dictionary = active_entries.get(behavior_id, {})
				state["just_activated"] = true
				state["behavior_id"] = behavior_id
				state["label"] = str(activated_entry.get("label", "")).strip_edges()
				state["status_text"] = str(activated_entry.get("status_text", "")).strip_edges()
				break
	else:
		observed_plant_instance_id = instance_id
		observation_initialized = true

	previous_active_ids.clear()
	previous_active_ids.append_array(active_ids)
	_apply_state(state)
	return state


func _apply_state(state: Dictionary) -> void:
	if not is_bound():
		return
	var active := bool(state.get("active", false))
	panel.visible = active
	panel.set_meta("behavior_active", active)
	panel.set_meta("behavior_id", str(state.get("behavior_id", "")) if active else "")
	title_label.text = ACTIVE_TITLE
	if not active:
		value_label.text = ""
		return
	var label := str(state.get("label", "")).strip_edges()
	var status_text := str(state.get("status_text", "")).strip_edges()
	value_label.text = "%s · %s" % [label, status_text] if not status_text.is_empty() else label


func _apply_inactive_state() -> void:
	if not is_bound():
		return
	panel.visible = false
	panel.set_meta("behavior_active", false)
	panel.set_meta("behavior_id", "")
	title_label.text = ACTIVE_TITLE
	value_label.text = ""
