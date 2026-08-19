extends RefCounted

const SWIPE_MIN_DISTANCE := 90.0
const SWIPE_HORIZONTAL_BIAS := 1.3


func resolve_swipe_target(delta: Vector2, current_screen: int, screen_count: int) -> int:
	if screen_count <= 0:
		return -1
	if absf(delta.x) < SWIPE_MIN_DISTANCE or absf(delta.x) < absf(delta.y) * SWIPE_HORIZONTAL_BIAS:
		return -1
	return clampi(current_screen + (-1 if delta.x > 0.0 else 1), 0, screen_count - 1)


func apply_screen(
	index: int,
	current_screen: int,
	screen_nodes: Array,
	navigation_buttons: Array,
	game_session,
	feedback
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
		feedback.play_screen_transition(1 if next_screen > current_screen else -1)
	return next_screen
