extends RefCounted

const SWIPE_MIN_DISTANCE := 90.0
const SWIPE_HORIZONTAL_BIAS := 1.3
const DRAG_AXIS_LOCK_DISTANCE := 18.0
const DRAG_AXIS_LOCK_BIAS := 1.15
const DRAG_AXIS_UNDECIDED := 0
const DRAG_AXIS_HORIZONTAL := 1
const DRAG_AXIS_VERTICAL := 2


func resolve_drag_axis(delta: Vector2) -> int:
	var horizontal_distance := absf(delta.x)
	var vertical_distance := absf(delta.y)
	if maxf(horizontal_distance, vertical_distance) < DRAG_AXIS_LOCK_DISTANCE:
		return DRAG_AXIS_UNDECIDED
	if horizontal_distance >= vertical_distance * DRAG_AXIS_LOCK_BIAS:
		return DRAG_AXIS_HORIZONTAL
	if vertical_distance >= horizontal_distance * DRAG_AXIS_LOCK_BIAS:
		return DRAG_AXIS_VERTICAL
	return DRAG_AXIS_UNDECIDED


func is_swipe_delta(delta: Vector2) -> bool:
	return absf(delta.x) >= SWIPE_MIN_DISTANCE and absf(delta.x) >= absf(delta.y) * SWIPE_HORIZONTAL_BIAS


func physical_swipe_direction(delta: Vector2) -> int:
	if not is_swipe_delta(delta):
		return 0
	return 1 if delta.x > 0.0 else -1


func resolve_swipe_target(delta: Vector2, current_screen: int, screen_count: int) -> int:
	if screen_count <= 0:
		return -1
	if not is_swipe_delta(delta):
		return -1
	return clampi(current_screen + (-1 if delta.x > 0.0 else 1), 0, screen_count - 1)


func apply_screen(
	index: int,
	current_screen: int,
	screen_nodes: Array,
	navigation_buttons: Array,
	game_session,
	feedback,
	transition_direction_override := 0
) -> int:
	if screen_nodes.is_empty():
		return current_screen
	var next_screen := clampi(index, 0, screen_nodes.size() - 1)
	for screen_index in range(screen_nodes.size()):
		(screen_nodes[screen_index] as Control).visible = screen_index == next_screen
	for navigation_button in navigation_buttons:
		(navigation_button as Button).disabled = false
	if game_session != null:
		game_session.visit_screen(next_screen)
	if feedback != null and current_screen != next_screen:
		var transition_direction := transition_direction_override
		if transition_direction == 0:
			transition_direction = 1 if next_screen > current_screen else -1
		feedback.play_screen_transition(transition_direction)
	return next_screen
