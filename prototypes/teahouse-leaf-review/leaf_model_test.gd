extends RefCounted

const BaseBoard := preload("res://scripts/teahouse/tea_board_model.gd")
const LeafBoard := preload("res://prototypes/teahouse-leaf-review/golden_leaf_board.gd")


static func _grid() -> Array[int]:
	var result: Array[int] = []
	for row in range(6):
		for column in range(6):
			result.append(row % 4)
	return result


static func _prepared(model: RefCounted, seed_value := 321) -> void:
	model.reset(0, seed_value)
	model.board.assign(_grid())
	model.goals = {0: 99, 1: 99, 2: 99, 3: 99}


static func _state(model: RefCounted, with_leaf := false) -> Dictionary:
	var state := {"board": model.board.duplicate(), "goals": model.goals.duplicate(true), "collected": model.collected.duplicate(true), "moves_left": model.moves_left, "score": model.score, "longest_chain": model.longest_chain, "phase": model.phase, "recipe_index": model.recipe_index, "round_seed": model.round_seed, "rng_state": model._rng.state, "rng_seed": model._rng.seed}
	if with_leaf:
		state["leaf_charges"] = model.leaf_charges
	return state


static func _path(model: RefCounted, chain: Array[int], length: int) -> Array[int]:
	if chain.size() == length:
		return chain
	for index in range(36):
		if model.can_extend(chain, index):
			var next: Array[int] = chain.duplicate()
			next.append(index)
			var found := _path(model, next, length)
			if not found.is_empty():
				return found
	return []


static func _find(model: RefCounted, length: int) -> Array[int]:
	for index in range(36):
		var start: Array[int] = [index]
		var found := _path(model, start, length)
		if not found.is_empty():
			return found
	return []


static func _check_submit_pair(check: Callable, base: RefCounted, leaf: RefCounted, chain: Array[int], expected_earned: bool, caption: String) -> void:
	var expected: Dictionary = base.submit_chain(chain)
	var actual: Dictionary = leaf.submit_chain(chain)
	check.call(actual.has("leaf_earned") and actual.leaf_earned == expected_earned, caption + ": získání lístku je přesné")
	actual.erase("leaf_earned")
	check.call(actual == expected and _state(base) == _state(leaf), caption + ": původní score/cíle/tahy/deska/RNG i response zůstaly identické")


static func run(check: Callable) -> void:
	var base := BaseBoard.new()
	var leaf := LeafBoard.new()
	check.call(leaf.leaf_charges == 0, "Lístek: nový model má nula nábojů")
	_prepared(base)
	_prepared(leaf)
	var five: Array[int] = [0, 1, 2, 3, 4]
	var six: Array[int] = [0, 1, 2, 3, 4, 5]
	_check_submit_pair(check, base, leaf, five, false, "Lístek: řetězec5")
	check.call(leaf.leaf_charges == 0 and leaf.score == 60 and leaf.moves_left == 17, "Lístek: pět bylin nevydá lístek a zachová původní60bodů")
	_prepared(base)
	_prepared(leaf)
	_check_submit_pair(check, base, leaf, six, true, "Lístek: řetězec6")
	check.call(leaf.leaf_charges == 1 and leaf.score == 75 and leaf.moves_left == 17, "Lístek: šest bylin vydá právě jeden náboj bez změny původního75bodového skóre")
	_prepared(base)
	_prepared(leaf)
	base.board[11] = 0
	leaf.board[11] = 0
	var seven: Array[int] = [0, 1, 2, 3, 4, 5, 11]
	_check_submit_pair(check, base, leaf, seven, true, "Lístek: řetězec7")
	check.call(leaf.leaf_charges == 1 and leaf.score == 90, "Lístek: delší než šest také vydá právě jeden náboj a zachová původní90bodové skóre")
	base.board.assign(_grid())
	leaf.board.assign(_grid())
	_check_submit_pair(check, base, leaf, six, false, "Lístek: druhý řetězec6 při plné kapacitě")
	check.call(leaf.leaf_charges == 1, "Lístek: kapacita se nezvýší nad1")
	for invalid: Variant in [null, true, false, -1, 4, 0.0, 1.0, 1.5, NAN, INF, "0", {}, []]:
		var before := _state(leaf, true)
		var rejected: Dictionary = leaf.use_leaf(invalid)
		check.call(not rejected.accepted and not rejected.leaf_used and _state(leaf, true) == before, "Lístek: neplatná bylina nezmění žádný stav: " + str(invalid))
	var before := _state(leaf, true)
	var used: Dictionary = leaf.use_leaf(1)
	check.call(used.accepted and used.leaf_used and used.herb == 1 and used.count == 3 and used.score_gain == 30 and not used.complete and leaf.leaf_charges == 0, "Lístek: správná bylina přidá3,30bodů a spotřebuje jeden náboj")
	var expected := before.duplicate(true)
	expected.collected[1] = int(expected.collected[1]) + 3
	expected.score += 30
	expected.leaf_charges = 0
	check.call(_state(leaf, true) == expected, "Lístek: použití nezmění desku, RNG, tahy, longest chain ani jiné počty")
	base.collected[1] = int(base.collected[1]) + 3
	base.score += 30
	var next_chain := _find(base, 3)
	_check_submit_pair(check, base, leaf, next_chain, false, "Lístek: další tah po použití")
	base.board.assign(_grid())
	leaf.board.assign(_grid())
	_check_submit_pair(check, base, leaf, six, true, "Lístek: nový náboj po spotřebování")
	check.call(leaf.leaf_charges == 1, "Lístek: po použití lze získat další, stále nejvýše1")
	for raw_path: Array in [[], [0], [0, 1], [0, 0, 1], [-1, 0, 1], [0, 1, 35]]:
		var invalid_path: Array[int] = []
		invalid_path.assign(raw_path)
		before = _state(leaf, true)
		var rejected: Dictionary = leaf.submit_chain(invalid_path)
		check.call(not rejected.accepted and not rejected.leaf_earned and _state(leaf, true) == before, "Lístek: neplatný řetězec náboj ani hru nezmění")

	# A finished recipe and a last exhausted move do not earn an unusable bonus.
	_prepared(base)
	_prepared(leaf)
	base.goals = {0: 6}
	leaf.goals = {0: 6}
	_check_submit_pair(check, base, leaf, six, false, "Lístek: dokončovací řetězec6")
	check.call(leaf.phase == "pouring" and leaf.leaf_charges == 0, "Lístek: finální řetězec neudělí náboj do nalévání")
	_prepared(base)
	_prepared(leaf)
	base.moves_left = 1
	leaf.moves_left = 1
	_check_submit_pair(check, base, leaf, six, false, "Lístek: poslední neúspěšný tah6")
	check.call(leaf.phase == "retry" and leaf.leaf_charges == 0, "Lístek: vyčerpané tahy nevydají nepoužitelný náboj")

	for current_phase: String in ["retry", "pouring", "result", "other"]:
		_prepared(leaf)
		leaf.leaf_charges = 1
		leaf.phase = current_phase
		before = _state(leaf, true)
		check.call(not leaf.use_leaf(0).accepted and _state(leaf, true) == before, "Lístek: fáze%s odmítne použití bez mutace" % current_phase)
		var rejected: Dictionary = leaf.submit_chain(six)
		check.call(not rejected.accepted and not rejected.leaf_earned and _state(leaf, true) == before, "Lístek: fáze%s neudělí další náboj" % current_phase)
	_prepared(leaf)
	before = _state(leaf, true)
	check.call(not leaf.use_leaf(0).accepted and _state(leaf, true) == before, "Lístek: bez náboje nelze použít ani platnou bylinu")
	leaf.leaf_charges = 1
	leaf.goals = {0: 6}
	leaf.collected[0] = 6
	for herb in [0, 1]:
		before = _state(leaf, true)
		check.call(not leaf.use_leaf(herb).accepted and _state(leaf, true) == before, "Lístek: splněná či nezadaná bylina náboj nespotřebuje")
	leaf.collected[0] = 9
	before = _state(leaf, true)
	check.call(not leaf.use_leaf(0).accepted and _state(leaf, true) == before, "Lístek: překročený cíl náboj také nespotřebuje")
	for remaining in [1, 2, 3, 8]:
		_prepared(leaf)
		leaf.leaf_charges = 1
		leaf.goals = {0: 4 + remaining, 1: 99}
		leaf.collected[0] = 4
		leaf.score = 20
		before = _state(leaf, true)
		used = leaf.use_leaf(0)
		var count := mini(3, remaining)
		expected = before.duplicate(true)
		expected.collected[0] = 4 + count
		expected.score = 20 + count * 10
		expected.leaf_charges = 0
		check.call(used.accepted and used.count == count and used.score_gain == count * 10 and not used.complete and _state(leaf, true) == expected, "Lístek: zbývajících%d bylin dostane přesněmin(3,zbývá) bez jiné změny" % remaining)

	_prepared(leaf)
	leaf.leaf_charges = 1
	leaf.goals = {0: 3}
	leaf.collected[0] = 2
	leaf.moves_left = 1
	before = _state(leaf, true)
	used = leaf.use_leaf(0)
	check.call(used.accepted and used.count == 1 and used.complete and leaf.phase == "pouring" and leaf.leaf_charges == 0 and leaf.moves_left == 1 and leaf.board == before.board and leaf._rng.state == before.rng_state and leaf.score == 10, "Lístek: poslední chybějící bylina otevře nalévání bez odebrání posledního tahu nebo pohybu desky")
	check.call(leaf.finish_pour(0.72).accepted and leaf.phase == "result", "Lístek: takto dokončený recept se dá normálně nalít")
	before = _state(leaf, true)
	check.call(not leaf.use_leaf(0).accepted and _state(leaf, true) == before, "Lístek: výsledek nelze odměnit opakovaným použitím")

	leaf.leaf_charges = 1
	leaf.reset(1, 672)
	base.reset(1, 672)
	check.call(leaf.leaf_charges == 0 and _state(leaf) == _state(base), "Lístek: restart vynuluje náboj a zachová původní reset včetně RNG")
	leaf.leaf_charges = 1
	var definition := {"recipe_index": 2, "seed": 991, "goals": {0: 9, 1: 9}, "moves": 7}
	leaf.reset_level(definition)
	base.reset_level(definition)
	check.call(leaf.leaf_charges == 0 and _state(leaf) == _state(base) and leaf.moves_left == 7 and leaf.goals == definition.goals, "Lístek: reset levelu vynuluje náboj a nepřepíše vlastní cíle/tahy")

	# Genuine random boards exercise refill/reshuffle parity beyond the fixture.
	for seed_value in range(24):
		base.reset(seed_value % 3, 20261024 + seed_value)
		leaf.reset(seed_value % 3, 20261024 + seed_value)
		base.goals = {0: 999, 1: 999, 2: 999, 3: 999}
		leaf.goals = base.goals.duplicate()
		for turn in range(8):
			var chain := _find(base, 6)
			if chain.is_empty():
				chain = _find(base, 3)
			var earns: bool = chain.size() >= 6 and leaf.leaf_charges == 0
			check.call(not chain.is_empty(), "Lístek: skutečná náhodná deska má hratelný řetězec")
			_check_submit_pair(check, base, leaf, chain, earns, "Lístek: náhodná deska%d tah%d" % [seed_value, turn])
