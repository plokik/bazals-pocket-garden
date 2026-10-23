extends RefCounted

static func run(host: SceneTree) -> void:
	var previous := {"blocked": SaveManager.writes_blocked, "status": SaveManager.last_load_status, "message": SaveManager.last_load_message, "error": SaveManager.last_save_error_message, "saved": SaveManager.last_successful_save_unix, "offline": SaveManager.last_load_offline_seconds_applied}
	var catalog: Dictionary = host._load_plant_catalog()
	var seed := GameSession.new(catalog)
	seed.coins = 117
	var supported_text := JSON.stringify(seed.to_dict())
	var future_data: Dictionary = seed.to_dict()
	future_data.schema = GameSession.SAVE_SCHEMA + 1
	future_data.coins = 999
	var future_text := JSON.stringify(future_data)
	var prefix := "user://audit_backup_protection_"
	var primary := prefix + "primary.json"
	var backup := prefix + "backup.json"
	var recovery := prefix + "recovery.json"
	var exported := prefix + "export.htgbackup"
	for data in [future_text, "", "{broken-json"]:
		_remove(primary)
		_write(backup, data)
		_write(recovery, "preserved audit copy")
		var restored := SaveManager._load_session_from_paths(catalog, primary, backup, recovery)
		var expected := SaveManager.STATUS_UNSUPPORTED if data == future_text else SaveManager.STATUS_CORRUPT
		host._check(SaveManager.last_load_status == expected and SaveManager.writes_blocked, "Ukládání: chybějící primary a jediná %s záloha zablokují zápis" % expected)
		host._check(not SaveManager.save_session(restored) and not SaveManager.save_session(restored), "Ukládání: ani opakovaný automatický save nepřepíše chráněnou jedinou zálohu")
		host._check(not FileAccess.file_exists(primary) and FileAccess.get_file_as_string(backup) == data and FileAccess.get_file_as_string(recovery) == "preserved audit copy", "Ukládání: jediná záloha i auditní kopie zůstanou bajtově stejné")
	_remove(primary)
	_remove(backup)
	SaveManager._load_session_from_paths(catalog, primary, backup, recovery)
	host._check(SaveManager.last_load_status == SaveManager.STATUS_NEW and not SaveManager.writes_blocked, "Ukládání: skutečně prázdné úložiště může založit novou hru")
	_write(backup, supported_text)
	var recovered := SaveManager._load_session_from_paths(catalog, primary, backup, recovery)
	host._check(SaveManager.last_load_status == SaveManager.STATUS_BACKUP_RECOVERED and not SaveManager.writes_blocked and recovered.coins == 117 and FileAccess.get_file_as_string(primary) == supported_text, "Ukládání: jediná platná záloha se stále obnoví se stejným postupem")
	_write(primary, "{broken-primary")
	_write(backup, future_text)
	SaveManager._load_session_from_paths(catalog, primary, backup, recovery)
	host._check(SaveManager.last_load_status == SaveManager.STATUS_UNSUPPORTED and SaveManager.writes_blocked and FileAccess.get_file_as_string(primary) == "{broken-primary" and FileAccess.get_file_as_string(backup) == future_text, "Ukládání: novější záloha je chráněná i vedle poškozeného primary")
	_write(primary, supported_text)
	var authoritative := SaveManager._load_session_from_paths(catalog, primary, backup, recovery)
	host._check(SaveManager.last_load_status == SaveManager.STATUS_PRIMARY and not SaveManager.writes_blocked and authoritative.coins == 117, "Ukládání: platné současné primary zůstává autoritativní")
	var export_result := SaveManager.export_portable_backup_to_path(seed, exported)
	var expected_export := FileAccess.get_file_as_string(exported)
	host._check(bool(export_result.get("ok", false)) and SaveManager._verify_portable_backup_export(exported, expected_export), "Export zálohy: úspěch znamená skutečný zapsaný a znovu ověřený postup")
	_write(exported, expected_export.left(expected_export.length() / 2))
	host._check(not SaveManager._verify_portable_backup_export(exported, expected_export), "Export zálohy: zkrácený soubor se nesmí potvrdit jako úplný")
	var envelope: Dictionary = JSON.parse_string(expected_export)
	envelope.sha256 = "tampered"
	var damaged := JSON.stringify(envelope)
	_write(exported, damaged)
	host._check(not SaveManager._verify_portable_backup_export(exported, damaged), "Export zálohy: shoda bajtů neobejde kontrolu obsahu a SHA-256")
	_remove(exported)
	host._check(not SaveManager._verify_portable_backup_export(exported, expected_export), "Export zálohy: zmizelý nebo nečitelný výsledek není úspěch")
	var directory_export := SaveManager.export_portable_backup_to_path(seed, "user://missing_audit_parent/subdir/export.htgbackup")
	host._check(not bool(directory_export.get("ok", true)), "Export zálohy: chyba otevření cíle se vrací hráči")
	for path in [primary, backup, recovery, exported]: _remove(path)
	SaveManager.writes_blocked = previous.blocked
	SaveManager.last_load_status = previous.status
	SaveManager.last_load_message = previous.message
	SaveManager.last_save_error_message = previous.error
	SaveManager.last_successful_save_unix = previous.saved
	SaveManager.last_load_offline_seconds_applied = previous.offline

static func _write(path: String, value: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(value)
	file.close()

static func _remove(path: String) -> void:
	if FileAccess.file_exists(path): DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
