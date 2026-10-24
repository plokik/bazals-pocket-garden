extends RefCounted
## Review-only fixture ranking. No profile, persistence, rewards, or network.

const MAX_XP := 1_000_000_000
const MAX_PORTRAIT := 31
const MAX_NAME_LENGTH := 18
const MAX_ID_LENGTH := 64

var _entries: Array[Dictionary] = []
var _positions: Dictionary = {}
var entries: Array[Dictionary]:
	get: return _copy_rows(_entries)


func load_entries(raw: Array) -> bool:
	# Validate the whole batch before replacing the last usable fixture.
	var normalized: Array[Dictionary] = []
	var seen: Dictionary = {}
	var valid_id := RegEx.create_from_string("\\A[A-Za-z0-9_-]+\\z")
	var unsafe_name := RegEx.create_from_string("[^\\p{L}\\p{M}\\p{N} '\u2019-]")
	var name_content := RegEx.create_from_string("[\\p{L}\\p{N}]")
	var spaces := RegEx.create_from_string(" +")
	for row in raw:
		if not row is Dictionary: return false
		if typeof(row.get("id")) != TYPE_STRING or typeof(row.get("name")) != TYPE_STRING: return false
		if typeof(row.get("xp")) != TYPE_INT or typeof(row.get("portrait")) != TYPE_INT: return false
		var id: String = row.id
		var xp: int = row.xp
		var portrait: int = row.portrait
		if id.is_empty() or id.length() > MAX_ID_LENGTH or valid_id.search(id) == null or seen.has(id): return false
		if xp < 0 or xp > MAX_XP or portrait < 0 or portrait > MAX_PORTRAIT: return false
		var display_name := spaces.sub(unsafe_name.sub(row.name," ",true)," ",true).strip_edges()
		display_name = display_name.substr(0,MAX_NAME_LENGTH).strip_edges()
		if display_name.is_empty() or name_content.search(display_name) == null: return false
		seen[id] = true
		normalized.append({"id":id,"name":display_name,"xp":xp,"portrait":portrait,"level":1+floori(float(xp)/100.0),"rank":0})
	# Equal XP is one competition place; id only stabilizes its visual order.
	normalized.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a.xp > b.xp if a.xp != b.xp else a.id < b.id
	)
	var positions: Dictionary = {}
	var previous_xp := -1
	var shared_rank := 0
	for index in range(normalized.size()):
		if normalized[index].xp != previous_xp:
			shared_rank = index+1
			previous_xp = normalized[index].xp
		normalized[index].rank = shared_rank
		positions[normalized[index].id] = index
	_entries = normalized
	_positions = positions
	return true


func top(limit: int = 100) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for index in range(mini(maxi(limit,0),_entries.size())):
		result.append(_entries[index].duplicate(true))
	return result


func around(player_id: String, before: int = 2, after: int = 2) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not _positions.has(player_id): return result
	var index: int = _positions[player_id]
	var start := maxi(0,index-mini(maxi(0,before),_entries.size()))
	var end := mini(_entries.size(),index+mini(maxi(0,after),_entries.size())+1)
	for at in range(start,end): result.append(_entries[at].duplicate(true))
	return result


func player(player_id: String) -> Dictionary:
	if not _positions.has(player_id): return {}
	return _entries[_positions[player_id]].duplicate(true)


func next_target(player_id: String) -> Dictionary:
	if not _positions.has(player_id): return {}
	var mine: Dictionary = _entries[_positions[player_id]]
	var target: Dictionary = {}
	for row in _entries:
		if row.xp > mine.xp and (target.is_empty() or row.xp < target.xp):
			target = row
	if target.is_empty(): return {}
	var overtake_xp: int = target.xp+1
	var projected_rank := 1
	for row in _entries:
		if row.xp > overtake_xp: projected_rank += 1
	return {
		"target_id":target.id,"name":target.name,"target_rank":target.rank,
		"next_higher_xp":target.xp,"gap_to_overtake":overtake_xp-int(mine.xp),"next_rank":projected_rank
	}


func _copy_rows(rows: Array[Dictionary]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for row in rows: result.append(row.duplicate(true))
	return result
