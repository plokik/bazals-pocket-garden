extends RefCounted
## Keep the old palette approval immutable and allow only the nine PNGs that
## the owner reviewed for the current workshop/navigation baseline.

const BASE := "res://.agents/skills/how-to-grow-validation/references/"
const APPROVAL := "res://docs/audit/workshop-navigation-20261020/approval.json"
const APPROVED_ROOT := "docs/audit/workshop-navigation-20261020/"
const HISTORICAL_SHA := "fb19223970190b2a083617d3fc41489a5421092cf03c3972a0a819082c57e36c"
const REVIEW_SHA := "9dfb1ebad7af52bc25c915c871f6bc690ee268ec08d7eee48eaad465c2b4956d"
const IDS := [
	"phase149-player-room-exact-target",
	"phase158-player-room-empty-runtime-approved",
	"phase159-player-room-cloche-runtime-approved",
	"phase163-rack-runtime-approved",
	"phase167-player-room-clean-floor-runtime-approved",
	"phase167-player-room-sparse-runtime-approved",
	"phase167-player-room-phone-save-runtime-approved",
	"phase167-player-room-full-runtime-approved",
	"phase167-player-room-full-cloche-runtime-approved",
]


static func run(suite: SceneTree) -> void:
	var previous := _read(BASE + "visual-cases-sage-20261010.json")
	# Keep the original October 20 approval contract against its immutable
	# 54-case snapshot, including the now retired showroom references.
	var active := _read(BASE + "historical/visual-cases-before-showroom-retirement-20261028.json")
	var current := _read(BASE + "visual-cases.json")
	var retirement := _read(BASE + "showroom-retirement-20261028.json")
	var retained: Array = (active.get("cases", []) as Array).filter(func(record: Dictionary) -> bool: return not str(record.id) in retirement.get("retired_case_ids", []))
	var dock_approval := _read("res://docs/audit/20261028-showroom-removed/approval.json")
	var dock_record: Dictionary = dock_approval.get("reference", {})
	var expected_current: Array = retained.duplicate(true)
	for record: Dictionary in expected_current:
		if record.id == "phase163-rack-runtime-approved":
			record.reference = dock_record.get("approved_reference", "")
			record.approval_record = "docs/audit/20261028-showroom-removed/approval.json"
	suite._check(current.get("cases", []) == expected_current and retained.size() == 52 and current.get("defaults") == active.get("defaults"), "Reference dílny: pouze odstraněný showroom a výslovně schválená tříikonová lišta; ostatní případy, limity a masky beze změny")
	suite._check(dock_approval.get("status") == "APPROVED_BY_USER" and dock_approval.get("user_approval") == "Ok tak pak tedy souhlasím" \
		and FileAccess.get_sha256("res://" + str(dock_record.get("approved_reference", ""))) == str(dock_record.get("approved_sha256", "")) \
		and FileAccess.get_sha256("res://" + str(dock_record.get("previous_reference", ""))) == str(dock_record.get("previous_sha256", "")), "Reference lišty: schválení váže přesný nový PNG a zachová původní čtyřikonový snímek")
	var approval := _read(APPROVAL)
	var records := {}
	var unique := true
	for record: Dictionary in approval.get("references", []):
		var id := str(record.get("id", ""))
		unique = unique and not records.has(id) and id in IDS
		records[id] = record
	suite._check(unique and records.size() == 9 and approval.get("status") == "APPROVED_BY_USER" \
		and approval.get("user_approval") == "ok" and approval.get("approved_on") == "2026-10-20" \
		and str(approval.get("review_sha256", "")) == REVIEW_SHA \
		and FileAccess.get_sha256("res://" + str(approval.get("reviewed_preview", ""))) == REVIEW_SHA,
		"Reference dílny: výslovné schválení váže právě devět unikátních případů na přesný posouzený náhled")
	suite._check(previous.get("cases", []).size() == 54 and active.get("cases", []).size() == 54 \
		and previous.get("defaults") == active.get("defaults") \
		and _text_sha(BASE + "visual-cases-sage-20261010.json") == HISTORICAL_SHA \
		and str(approval.get("historical_manifest_sha256_lf", "")) == HISTORICAL_SHA \
		and _text_sha("res://" + str(approval.get("proposal", ""))) == str(approval.get("proposal_sha256_lf", "")),
		"Reference dílny: předchozí manifest i předložené kandidáty zachová dohledatelně a bez změny výchozích limitů")
	if previous.get("cases", []).size() != 54 or active.get("cases", []).size() != 54:
		return
	var changed := 0
	var gates := 0
	var unique_active := {}
	for index in range(54):
		var before: Dictionary = previous.cases[index]
		var after: Dictionary = active.cases[index]
		var id := str(before.id)
		var expected := before.duplicate(true)
		var intact := not unique_active.has(str(after.get("id", "")))
		unique_active[str(after.get("id", ""))] = true
		if id in IDS:
			changed += 1
			var record: Dictionary = records.get(id, {})
			expected.reference = APPROVED_ROOT + id + ".png"
			intact = intact and bool(before.get("gate", false)) \
				and record.get("previous_reference") == before.reference \
				and FileAccess.get_sha256("res://" + str(before.reference)) == str(record.get("previous_sha256", "")) \
				and record.get("approved_reference") == expected.reference \
				and FileAccess.get_sha256("res://" + str(expected.reference)) == str(record.get("approved_sha256", "")) \
				and FileAccess.get_sha256("res://" + str(record.get("approved_candidate", ""))) == str(record.get("approved_sha256", ""))
		gates += int(bool(after.get("gate", false)))
		suite._check(intact and after == expected, "Reference %s mění pouze schválenou PNG cestu; pořadí, popis, masky, ořezy, tolerance, capture i příznak brány zůstávají zachované" % id)
	suite._check(changed == 9 and gates == 34, "Reference dílny: historické schválení zachovává všech 54 případů a 34 tehdejších bran, mění přesně devět schválených snímků")


static func _read(path: String) -> Dictionary:
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}


static func _text_sha(path: String) -> String:
	# Match Git's LF source form on Windows autocrlf checkouts as well.
	return FileAccess.get_file_as_string(path).replace("\r\n", "\n").sha256_text()
