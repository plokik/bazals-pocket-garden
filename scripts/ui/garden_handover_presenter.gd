class_name GardenHandoverPresenter
extends RefCounted

const GuideCharacter := preload("res://scripts/ui/guide_character.gd")

const PAGES: Array[Dictionary] = [
	{
		"title": "PŘEDÁNÍ ZAHRADY",
		"text": "Tahle malá zahrada patřila naší botanické dílně. Vítr roznesl její semena a z herbáře zůstaly jen prázdné stránky.",
		"mood": GuideCharacter.Mood.EXPLAIN,
		"confirm_label": "DALŠÍ",
	},
	{
		"title": "PŘEDÁNÍ ZAHRADY",
		"text": "Předávám ji tobě. Pěstuj nové druhy, pozoruj jejich potřeby a každým objevem vrať jednu stránku do herbáře.",
		"mood": GuideCharacter.Mood.EXPLAIN,
		"confirm_label": "DALŠÍ",
	},
	{
		"title": "PŘEDÁNÍ ZAHRADY",
		"text": "Začni bazalkou. Prvním cyklem tě provedu krok za krokem; potom už bude zahrada růst podle tvých rozhodnutí.",
		"mood": GuideCharacter.Mood.CELEBRATE,
		"confirm_label": "PŘEVZÍT ZAHRADU",
	},
]

var _active := false
var _replay := false
var _page_index := 0
var _finished := false
var _skipped := false


func begin(replay: bool = false) -> Dictionary:
	_active = true
	_replay = replay
	_page_index = 0
	_finished = false
	_skipped = false
	return state()


func advance() -> Dictionary:
	if not _active:
		return state()
	if _page_index + 1 < PAGES.size():
		_page_index += 1
		return state()
	_active = false
	return _terminal_state(false)


func skip() -> Dictionary:
	if not _active:
		return state()
	_active = false
	return _terminal_state(true)


func reset() -> void:
	_active = false
	_replay = false
	_page_index = 0
	_finished = false
	_skipped = false


func state() -> Dictionary:
	var page_count := PAGES.size()
	var safe_index := clampi(_page_index, 0, maxi(0, page_count - 1))
	var page: Dictionary = PAGES[safe_index] if page_count > 0 else {}
	var page_text := str(page.get("text", ""))
	return {
		"active": _active,
		"replay": _replay,
		"page_index": safe_index,
		"page_number": safe_index + 1 if page_count > 0 else 0,
		"page_count": page_count,
		"title": str(page.get("title", "")),
		"text": page_text,
		"body": page_text,
		"mood": int(page.get("mood", GuideCharacter.Mood.EXPLAIN)),
		"confirm_label": str(page.get("confirm_label", "DALŠÍ")),
		"finished": _finished,
		"skipped": _skipped,
	}


func get_state() -> Dictionary:
	return state()


func _terminal_state(skipped: bool) -> Dictionary:
	_finished = true
	_skipped = skipped
	return state()
