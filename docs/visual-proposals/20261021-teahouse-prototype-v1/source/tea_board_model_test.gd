extends SceneTree

const Model := preload("res://prototypes/teahouse/tea_board_model.gd")
var _checks := 0
var _failures: Array[String] = []


func _initialize() -> void:
	_test_deterministic_resets()
	_test_gestures_and_atomic_rejection()
	_test_gravity_and_scoring()
	_test_dead_board_recovery()
	_test_real_rounds()
	_test_retry_and_pouring()
	if _failures.is_empty():
		print("TEA_BOARD_TESTS_PASSED=%d" % _checks)
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		print("TEA_BOARD_TESTS_FAILED=%d/%d" % [_failures.size(), _checks])
		quit(1)


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)


func _snapshot(model: RefCounted) -> Dictionary:
	return {
		"board": model.board.duplicate(), "goals": model.goals.duplicate(),
		"collected": model.collected.duplicate(), "moves": model.moves_left,
		"score": model.score, "longest": model.longest_chain, "phase": model.phase,
		"rng": model._rng.state,
	}


func _test_deterministic_resets() -> void:
	var first := Model.new()
	var second := Model.new()
	for recipe in range(Model.RECIPES.size()):
		for seed_value in range(-8, 248):
			first.reset(recipe, seed_value)
			second.reset(recipe, seed_value)
			_check(_snapshot(first) == _snapshot(second), "Reset is deterministic: %d/%d" % [recipe, seed_value])
			_check(first.board.size() == 36 and first.board.all(func(herb: int) -> bool: return herb >= 0 and herb < 4), "Reset creates exactly 36 valid herbs")
			_check(first.has_legal_chain(), "Every initial board permits a three-herb chain")
			_check(first.phase == "matching" and first.moves_left == 18 and first.score == 0 and first.longest_chain == 0, "Reset starts a fresh round")
	first.reset(0, 10)
	first.goals[0] = 999
	first.collected[0] = 999
	first.reset(-10, 10)
	_check(first.recipe_index == 0 and first.goals == {0: 8, 1: 6} and first.collected[0] == 0, "Reset clamps recipe index and isolates mutable recipe data")
	first.reset(999, 10)
	_check(first.recipe_index == 2 and first.goals == {0: 6, 1: 6, 3: 6}, "High recipe index clamps to last recipe")


func _test_gestures_and_atomic_rejection() -> void:
	var model := Model.new()
	model.reset(0, 1)
	model.board.fill(0)
	var empty: Array[int] = []
	_check(model.can_extend(empty, 0) and not model.can_extend(empty, -1) and not model.can_extend(empty, 36), "Gesture starts only on a board cell")
	for first in range(36):
		for second in range(36):
			var path: Array[int] = [first]
			var expected: bool = first != second and absi(first % 6 - second % 6) <= 1 and absi(first / 6 - second / 6) <= 1
			_check(model.can_extend(path, second) == expected, "All 1296 neighbor pairs obey eight-direction adjacency")
	var diagonal: Array[int] = [0, 7, 14]
	_check(model.can_extend(diagonal, 21) and not model.can_extend(diagonal, 7), "Diagonal chains extend without reusing a cell")
	var invalid_prefix: Array[int] = [0, 2]
	_check(not model.can_extend(invalid_prefix, 3), "An invalid prefix cannot be extended")
	var invalid_chains: Array = [[], [0], [0, 1], [-1, 0, 1], [0, 1, 36], [0, 1, 0], [0, 1, 3], [4, 5, 6]]
	for raw in invalid_chains:
		var path: Array[int] = []
		path.assign(raw)
		var before := _snapshot(model)
		_check(not model.submit_chain(path).accepted and _snapshot(model) == before, "Invalid gesture is atomic: %s" % str(raw))
	model.board[1] = 2
	var mixed: Array[int] = [0, 1, 2]
	var before := _snapshot(model)
	_check(not model.submit_chain(mixed).accepted and _snapshot(model) == before, "Mixed herbs neither consume a move nor alter RNG state")
	model.board.resize(35)
	before = _snapshot(model)
	_check(not model.submit_chain(diagonal).accepted and not model.has_legal_chain() and _snapshot(model) == before, "Incomplete boards fail safely")


func _test_gravity_and_scoring() -> void:
	var model := Model.new()
	model.reset(0, 14)
	model.goals = {0: 999}
	for index in range(36):
		model.board[index] = (index / 6 + index % 6) % 4
	for index in [6, 12, 18]:
		model.board[index] = 1
	# An unaffected legal chain prevents a reshuffle from obscuring gravity.
	for index in [33, 34, 35]:
		model.board[index] = 3
	var original := model.board.duplicate()
	var vertical: Array[int] = [6, 12, 18]
	var result := model.submit_chain(vertical)
	_check(result.accepted and result.herb == 1 and result.count == 3 and result.bonus == 0 and result.score_gain == 30, "A three-chain scores once and identifies its ingredient")
	_check(model.board[18] == original[0] and model.board[24] == original[24] and model.board[30] == original[30], "Gravity keeps surviving column order")
	var unchanged_columns := true
	for index in range(36):
		if index % 6 != 0 and model.board[index] != original[index]:
			unchanged_columns = false
	_check(unchanged_columns and model.board.size() == 36 and model.has_legal_chain(), "Only affected columns refill and the board remains playable")
	_check(model.moves_left == 17 and model.collected[1] == 3 and model.score == 30 and model.longest_chain == 3, "Extra ingredients collect normally without a penalty")
	for index in range(30, 36):
		model.board[index] = 0
	var long_path: Array[int] = [30, 31, 32, 33, 34, 35]
	result = model.submit_chain(long_path)
	_check(result.accepted and result.bonus == 15 and result.score_gain == 75 and model.score == 105 and model.longest_chain == 6, "Longer chains gain a clear combo bonus")
	_check(model.collected[0] == 6 and model.moves_left == 16 and model.phase == "matching", "A gesture consumes exactly one move")
	result.removed.clear()
	_check(long_path.size() == 6, "Animation event cells are a copy, not the caller's gesture")


func _dead_board() -> Array[int]:
	var result: Array[int] = []
	for index in range(36):
		result.append((index % 6) % 2 + 2 * ((index / 6) % 2))
	return result


func _test_dead_board_recovery() -> void:
	var model := Model.new()
	var other := Model.new()
	for seed_value in range(80):
		model.reset(0, seed_value)
		other.reset(0, seed_value)
		model.board = _dead_board()
		other.board = _dead_board()
		_check(not model.has_legal_chain(), "The isolated four-color fixture has no valid triple")
		var before := _snapshot(model)
		var old_sorted := model.board.duplicate()
		old_sorted.sort()
		_check(model.shuffle_if_stuck() and model.has_legal_chain(), "A stuck board is recovered without a player move")
		other.shuffle_if_stuck()
		var new_sorted := model.board.duplicate()
		new_sorted.sort()
		_check(old_sorted == new_sorted and model.moves_left == before.moves and model.score == before.score and model.collected == before.collected and model.phase == before.phase, "Recovery preserves ingredient counts and progress")
		_check(_snapshot(model) == _snapshot(other), "Recovery is deterministic for a given RNG state")
		before = _snapshot(model)
		_check(not model.shuffle_if_stuck() and before == _snapshot(model), "Playable boards do not reshuffle or consume RNG")
	model.board = _dead_board()
	var before_sorted := model.board.duplicate()
	before_sorted.sort()
	model._construct_legal_chain()
	var after_sorted := model.board.duplicate()
	after_sorted.sort()
	_check(model.has_legal_chain() and before_sorted == after_sorted, "Constructive bounded-recovery fallback preserves every ingredient")


func _find_path(model: RefCounted, path: Array[int], limit: int) -> Array[int]:
	var best := path.duplicate()
	if path.size() >= limit:
		return best
	for next in model._neighbors(path[-1]):
		if model.board[next] != model.board[path[0]] or path.has(next):
			continue
		var longer := path.duplicate()
		longer.append(next)
		var candidate := _find_path(model, longer, limit)
		if candidate.size() > best.size():
			best = candidate
		if best.size() >= limit:
			return best
	return best


func _choose_gesture(model: RefCounted) -> Array[int]:
	var best: Array[int] = []
	var best_value := -1
	for index in range(36):
		var start: Array[int] = [index]
		var candidate := _find_path(model, start, 8)
		if candidate.size() < 3:
			continue
		var herb: int = model.board[index]
		var need := maxi(0, int(model.goals.get(herb, 0)) - int(model.collected[herb]))
		var value := mini(need, candidate.size()) * 100 + candidate.size()
		if value > best_value:
			best = candidate
			best_value = value
	return best


func _test_real_rounds() -> void:
	for recipe in range(3):
		for seed_value in [20261021, 42, 180, 19, 80, 1234, 67890, -5]:
			var model := Model.new()
			var repeated := Model.new()
			model.reset(recipe, seed_value)
			repeated.reset(recipe, seed_value)
			var gesture_count := 0
			while model.phase == "matching" and gesture_count < 18:
				var path := _choose_gesture(model)
				var event := model.submit_chain(path)
				var repeated_event := repeated.submit_chain(path)
				_check(event.accepted and event == repeated_event and _snapshot(model) == _snapshot(repeated), "Actual legal gameplay, score and refill reproduce deterministically")
				_check(model.board.size() == 36 and model.has_legal_chain() and model.moves_left == 17 - gesture_count, "Every accepted refill remains playable and consumes one move")
				gesture_count += 1
				if not event.accepted:
					break
			_check(model.phase == "pouring", "Recipe %d with seed %d completes through actual matching within 18 moves" % [recipe, seed_value])
			var result := model.finish_pour(Model.POUR_TARGET)
			_check(result.accepted and result.complete and result.quality == "perfect" and model.phase == "result", "Actual completed recipes reach a single pour and served result")


func _ready_to_pour() -> RefCounted:
	var model := Model.new()
	model.reset(0, 3)
	model.goals = {0: 3}
	model.board.fill(0)
	var path: Array[int] = [0, 1, 2]
	model.submit_chain(path)
	return model


func _test_retry_and_pouring() -> void:
	var model := Model.new()
	model.reset(0, 10)
	var original_board := model.board.duplicate()
	var before := _snapshot(model)
	_check(not model.finish_pour(0.72).accepted and before == _snapshot(model), "Pouring cannot bypass an unfinished recipe")
	model.board.fill(0)
	model.goals = {0: 1000}
	model.moves_left = 1
	var path: Array[int] = [0, 1, 2]
	_check(model.submit_chain(path).accepted and model.phase == "retry" and model.moves_left == 0, "Exhausting moves produces an explicit retry without imaginary completion")
	before = _snapshot(model)
	_check(not model.submit_chain(path).accepted and not model.finish_pour(0.72).accepted and before == _snapshot(model), "Retry state cannot spend moves or award a pour bonus")
	model.reset(0, 10)
	_check(model.board == original_board and model.moves_left == 18 and model.score == 0, "Retrying the same seed restores the same fair round")
	model = _ready_to_pour()
	_check(model.phase == "pouring" and model.moves_left == 17, "Completion wins before the move budget is exhausted")
	before = _snapshot(model)
	_check(not model.submit_chain(path).accepted and before == _snapshot(model), "A completed board cannot add matching score during pouring")
	for invalid in [NAN, INF, -INF]:
		before = _snapshot(model)
		_check(not model.finish_pour(invalid).accepted and before == _snapshot(model), "Nonfinite fills cannot finish or reward the round")
	for fill in [-10.0, 0.0, 0.3, 0.60, 0.72, 0.84, 1.0, 12.0]:
		model = _ready_to_pour()
		var score_before: int = model.score
		var outcome := model.finish_pour(fill)
		_check(outcome.accepted and outcome.complete and outcome.fill >= 0.0 and outcome.fill <= 1.0 and model.phase == "result", "Finite pour fill clamps into the physical cup")
		_check(model.score == score_before + int(outcome.bonus) and outcome.bonus >= 0 and is_finite(float(model.score)), "Serving gives one finite nonnegative bonus")
		if fill <= 0.0:
			_check(outcome.bonus == 0 and outcome.fill == 0.0 and outcome.quality == "empty", "Negative or empty fills award no pour bonus")
		if fill == 0.72:
			_check(outcome.bonus == 100 and outcome.quality == "perfect", "The target level provides the best result")
		before = _snapshot(model)
		_check(not model.finish_pour(fill).accepted and not model.submit_chain(path).accepted and before == _snapshot(model), "Double serving and late gestures are harmless")
	model = _ready_to_pour()
	model.moves_left = 1
	model.phase = "matching"
	model.collected[0] = 0
	model.board.fill(0)
	_check(model.submit_chain(path).complete and model.phase == "pouring" and model.moves_left == 0, "Finishing on the final move succeeds instead of forcing retry")
