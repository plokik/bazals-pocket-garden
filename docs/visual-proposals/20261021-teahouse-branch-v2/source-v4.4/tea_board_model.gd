extends RefCounted
## Review-only minigame state. It has no GameSession, inventory or save access.

const COLS := 6
const ROWS := 6
const HERB_COUNT := 4
const STARTING_MOVES := 18
const POUR_TARGET := 0.72
const SHUFFLE_ATTEMPTS := 24
const RECIPES := [
	{"id": "fresh_morning", "name": "Svěží ráno", "description": "Máta a meduňka", "goals": {0: 8, 1: 6}},
	{"id": "quiet_evening", "name": "Klidný večer", "description": "Heřmánek a levandule", "goals": {3: 8, 2: 6}},
	{"id": "garden_visit", "name": "Zahradní posezení", "description": "Máta, meduňka a heřmánek", "goals": {0: 6, 1: 6, 3: 6}},
]

var board: Array[int] = []
var goals: Dictionary = {}
var collected: Dictionary = {}
var moves_left := STARTING_MOVES
var score := 0
var longest_chain := 0
var phase := "matching"
var recipe_index := 0
var round_seed := 0
var _rng := RandomNumberGenerator.new()


func reset(next_recipe_index: int, next_seed: int) -> void:
	recipe_index = clampi(next_recipe_index, 0, RECIPES.size() - 1)
	round_seed = next_seed
	_rng.seed = next_seed
	goals = RECIPES[recipe_index]["goals"].duplicate()
	collected = {0: 0, 1: 0, 2: 0, 3: 0}
	moves_left = STARTING_MOVES
	score = 0
	longest_chain = 0
	phase = "matching"
	board.clear()
	for _index in range(COLS * ROWS):
		board.append(_rng.randi_range(0, HERB_COUNT - 1))
	shuffle_if_stuck()


func can_extend(chain: Array[int], index: int) -> bool:
	if phase != "matching" or not _valid_board() or not _valid_path(chain, 0):
		return false
	if index < 0 or index >= board.size() or chain.has(index):
		return false
	if chain.is_empty():
		return true
	return board[index] == board[chain[0]] and _adjacent(chain[-1], index)


func submit_chain(chain: Array[int]) -> Dictionary:
	if phase != "matching":
		return _rejected("phase")
	if not _valid_board() or not _valid_path(chain, 3):
		return _rejected("chain")
	# Validate the entire gesture before touching counters, cells or RNG state.
	var herb := board[chain[0]]
	var count := chain.size()
	var bonus := maxi(0, count - 3) * 5
	var score_gain := count * 10 + bonus
	collected[herb] = int(collected.get(herb, 0)) + count
	score += score_gain
	longest_chain = maxi(longest_chain, count)
	moves_left -= 1
	_collapse_and_refill(chain)
	var reshuffled := shuffle_if_stuck()
	var complete := _goals_complete()
	if complete:
		phase = "pouring"
	elif moves_left == 0:
		phase = "retry"
	return {
		"accepted": true, "herb": herb, "count": count, "bonus": bonus,
		"score_gain": score_gain, "complete": complete, "removed": chain.duplicate(),
		"reshuffled": reshuffled,
	}


func has_legal_chain() -> bool:
	if not _valid_board():
		return false
	# Any connected group of three contains a cell with two same-herb neighbors.
	for index in range(board.size()):
		var same_neighbors := 0
		for other in _neighbors(index):
			if board[other] == board[index]:
				same_neighbors += 1
				if same_neighbors >= 2:
					return true
	return false


func shuffle_if_stuck() -> bool:
	if not _valid_board() or has_legal_chain():
		return false
	for _attempt in range(SHUFFLE_ATTEMPTS):
		for index in range(board.size() - 1, 0, -1):
			var other := _rng.randi_range(0, index)
			var held := board[index]
			board[index] = board[other]
			board[other] = held
		if has_legal_chain():
			return true
	_construct_legal_chain()
	return true


func finish_pour(fill: float) -> Dictionary:
	if phase != "pouring" or not _goals_complete():
		return _rejected("phase")
	if not is_finite(fill):
		return _rejected("fill")
	var normalized := clampf(fill, 0.0, 1.0)
	var distance := absf(normalized - POUR_TARGET)
	var quality := "light"
	var caption := "Jemný čaj na klidnou chvilku."
	var bonus := 0
	if distance <= 0.08:
		quality = "perfect"
		caption = "Právě tak! Čaj se krásně povedl."
		bonus = 100
	elif distance <= 0.18:
		quality = "good"
		caption = "Voňavý šálek. Děkuji!"
		bonus = 50
	elif normalized > POUR_TARGET:
		quality = "overflow"
		caption = "Trochu vody navíc. Příště to vyjde."
	else:
		bonus = int(normalized / POUR_TARGET * 20.0)
		if normalized == 0.0:
			quality = "empty"
			caption = "Příště nezapomeň přilít vodu."
	score += bonus
	phase = "result"
	return {
		"accepted": true, "complete": true, "fill": normalized,
		"quality": quality, "caption": caption, "bonus": bonus, "score": score,
	}


func _valid_board() -> bool:
	if board.size() != COLS * ROWS:
		return false
	for herb in board:
		if herb < 0 or herb >= HERB_COUNT:
			return false
	return true


func _valid_path(chain: Array[int], minimum_length: int) -> bool:
	if chain.size() < minimum_length:
		return false
	var seen: Dictionary = {}
	var previous := -1
	var herb := -1
	for index in chain:
		if index < 0 or index >= board.size() or seen.has(index):
			return false
		if previous >= 0 and (board[index] != herb or not _adjacent(previous, index)):
			return false
		seen[index] = true
		herb = board[index]
		previous = index
	return true


func _adjacent(first: int, second: int) -> bool:
	var delta_x := absi(first % COLS - second % COLS)
	var delta_y := absi(first / COLS - second / COLS)
	return maxi(delta_x, delta_y) == 1


func _neighbors(index: int) -> Array[int]:
	var result: Array[int] = []
	var column := index % COLS
	var row := index / COLS
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var x := column + dx
			var y := row + dy
			if (dx != 0 or dy != 0) and x >= 0 and x < COLS and y >= 0 and y < ROWS:
				result.append(y * COLS + x)
	return result


func _collapse_and_refill(chain: Array[int]) -> void:
	var removed: Dictionary = {}
	for index in chain:
		removed[index] = true
	for column in range(COLS):
		var write_row := ROWS - 1
		for read_row in range(ROWS - 1, -1, -1):
			var read_index := read_row * COLS + column
			if not removed.has(read_index):
				board[write_row * COLS + column] = board[read_index]
				write_row -= 1
		for row in range(write_row, -1, -1):
			board[row * COLS + column] = _rng.randi_range(0, HERB_COUNT - 1)


func _construct_legal_chain() -> void:
	# 36 cells and four herbs guarantee at least three of one herb. Move them
	# together using swaps, preserving the shuffled board's ingredient counts.
	var herb := 0
	for candidate in range(HERB_COUNT):
		if board.count(candidate) >= 3:
			herb = candidate
			break
	for target in range(3):
		if board[target] == herb:
			continue
		for source in range(target + 1, board.size()):
			if board[source] == herb:
				board[source] = board[target]
				board[target] = herb
				break


func _goals_complete() -> bool:
	if goals.is_empty():
		return false
	for herb in goals:
		if int(collected.get(herb, 0)) < int(goals[herb]):
			return false
	return true


func _rejected(reason: String) -> Dictionary:
	return {"accepted": false, "herb": -1, "count": 0, "bonus": 0, "score_gain": 0, "complete": false, "reason": reason}
