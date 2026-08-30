class_name RoomPlantDragController
extends RefCounted

## Owns one gesture from press to release. No session mutation or wall clock.
const HOLD_SECONDS := 0.45
const HOLD_SLOP := 12.0
const NO_POINTER := -2
const MOUSE_POINTER := -1

var pointer_id := NO_POINTER
var source_slot := -1
var decoration_id := ""
var start_position := Vector2.ZERO
var pointer_position := Vector2.ZERO
var hold_elapsed := 0.0
var dragging := false
var cancelled := false
var touch_ids: Array[int] = []
var claimed_touch_ids: Array[int] = []
var mouse_press_claimed := false
var emulated_mouse_claimed := false
var emulated_touch_claimed := false


func is_tracking() -> bool:
	return pointer_id != NO_POINTER


func cancel(reset_contacts := false) -> void:
	pointer_id = NO_POINTER
	source_slot = -1
	decoration_id = ""
	hold_elapsed = 0.0
	dragging = false
	cancelled = false
	# Back/Escape/modal cancellation does not mean the held fingers lifted.
	# Focus loss is different: the OS may never deliver the remaining releases.
	if reset_contacts:
		touch_ids.clear()
		claimed_touch_ids.clear()
		mouse_press_claimed = false
		emulated_mouse_claimed = false
		emulated_touch_claimed = false


func advance_hold(delta: float) -> bool:
	if not is_tracking() or cancelled or dragging:
		return false
	hold_elapsed = minf(HOLD_SECONDS, hold_elapsed + maxf(0.0, delta))
	if hold_elapsed < HOLD_SECONDS:
		return false
	dragging = true
	return true


func handle_event(event: InputEvent, slot_index := -1, item_id := "", allow_start := true) -> Dictionary:
	var pointer_event := event is InputEventMouseButton or event is InputEventMouseMotion or event is InputEventScreenTouch or event is InputEventScreenDrag
	if not pointer_event:
		return {"handled": false}
	if event.device == InputEvent.DEVICE_ID_EMULATION:
		return _handle_emulated_event(event, allow_start and slot_index >= 0 and not item_id.is_empty())
	if event is InputEventScreenTouch:
		if event.pressed and not event.canceled:
			if event.index not in touch_ids:
				touch_ids.append(event.index)
			if is_tracking() or not claimed_touch_ids.is_empty() or mouse_press_claimed:
				if event.index not in claimed_touch_ids:
					claimed_touch_ids.append(event.index)
				cancelled = true
				dragging = false
				return {"handled": true}
			if allow_start and touch_ids.size() == 1 and slot_index >= 0 and not item_id.is_empty():
				claimed_touch_ids.append(event.index)
				return _begin(event.index, event.position, slot_index, item_id)
			return {"handled": false}
		var was_claimed: bool = event.index in claimed_touch_ids
		touch_ids.erase(event.index)
		claimed_touch_ids.erase(event.index)
		if event.index == pointer_id:
			cancelled = cancelled or event.canceled or not touch_ids.is_empty()
			return _finish(event.position)
		if was_claimed and is_tracking():
			cancelled = true
			dragging = false
		return {"handled": was_claimed}
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return {"handled": is_tracking()}
		if event.pressed:
			if is_tracking() or not claimed_touch_ids.is_empty() or mouse_press_claimed:
				mouse_press_claimed = true
				cancelled = true
				dragging = false
				return {"handled": true}
			if allow_start and touch_ids.is_empty() and slot_index >= 0 and not item_id.is_empty():
				mouse_press_claimed = true
				return _begin(MOUSE_POINTER, event.position, slot_index, item_id)
			return {"handled": false}
		if mouse_press_claimed:
			mouse_press_claimed = false
			if pointer_id == MOUSE_POINTER:
				cancelled = cancelled or event.is_canceled()
				return _finish(event.position)
			return {"handled": true}
		return {"handled": is_tracking()}
	if event is InputEventScreenDrag:
		if is_tracking():
			if event.index == pointer_id:
				_update_position(event.position)
			else:
				cancelled = true
				dragging = false
			return {"handled": true}
		return {"handled": event.index in claimed_touch_ids}
	if event is InputEventMouseMotion and is_tracking():
		if pointer_id == MOUSE_POINTER:
			if (event.button_mask & MOUSE_BUTTON_MASK_LEFT) == 0:
				cancel()
				mouse_press_claimed = false
				emulated_touch_claimed = false
			else:
				_update_position(event.position)
		return {"handled": true}
	return {"handled": false}


func _handle_emulated_event(event: InputEvent, can_start: bool) -> Dictionary:
	# Godot dispatches emulated events BEFORE their native source. Decide at
	# the emulated PRESS and keep the pair together, including cancellation.
	var claim_press := is_tracking() or mouse_press_claimed or not claimed_touch_ids.is_empty() or (can_start and touch_ids.is_empty())
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emulated_mouse_claimed = claim_press
			return {"handled": emulated_mouse_claimed}
		var handled := emulated_mouse_claimed
		emulated_mouse_claimed = false
		return {"handled": handled}
	if event is InputEventScreenTouch:
		if event.pressed and not event.canceled:
			emulated_touch_claimed = claim_press
			return {"handled": emulated_touch_claimed}
		var handled := emulated_touch_claimed
		emulated_touch_claimed = false
		return {"handled": handled}
	if event is InputEventMouseMotion:
		return {"handled": emulated_mouse_claimed}
	if event is InputEventScreenDrag:
		return {"handled": emulated_touch_claimed}
	return {"handled": false}


func _begin(id: int, position: Vector2, slot_index: int, item_id: String) -> Dictionary:
	pointer_id = id
	source_slot = slot_index
	decoration_id = item_id
	start_position = position
	pointer_position = position
	hold_elapsed = 0.0
	dragging = false
	cancelled = false
	return {"handled": true}


func _update_position(position: Vector2) -> void:
	pointer_position = position
	if not dragging and start_position.distance_to(position) > HOLD_SLOP:
		cancelled = true


func _finish(position: Vector2) -> Dictionary:
	_update_position(position)
	var result := {
		"handled": true,
		"kind": "cancel" if cancelled else ("drop" if dragging else "tap"),
		"source_slot": source_slot,
		"decoration_id": decoration_id,
		"position": pointer_position,
	}
	cancel()
	return result
