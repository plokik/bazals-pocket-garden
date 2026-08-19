class_name SaveManager
extends RefCounted

const SAVE_PATH := "user://how_to_grow_save.json"
const BACKUP_PATH := "user://how_to_grow_save.backup.json"
const TEMP_PATH := "user://how_to_grow_save.tmp.json"
const RECOVERY_PATH := "user://how_to_grow_save.unreadable.json"
const BEFORE_IMPORT_PATH := "user://how_to_grow_save.before_import.json"
const BEFORE_NEW_GAME_PATH := "user://how_to_grow_save.before_new_game.json"
const PORTABLE_BACKUP_FORMAT := "how_to_grow_portable_backup"
const PORTABLE_BACKUP_VERSION := 1
const PORTABLE_BACKUP_EXTENSION := "htgbackup"
const PORTABLE_BACKUP_MAX_BYTES := 2 * 1024 * 1024
const STATUS_NEW := "new"
const STATUS_PRIMARY := "primary"
const STATUS_BACKUP_RECOVERED := "backup_recovered"
const STATUS_BACKUP_READ_ONLY := "backup_read_only"
const STATUS_CORRUPT := "corrupt"
const STATUS_UNSUPPORTED := "unsupported"

static var last_load_status := STATUS_NEW
static var last_load_message := ""
static var writes_blocked := false
static var last_successful_save_unix := 0.0
static var last_save_error_message := ""
static var last_load_offline_seconds_applied := 0.0


static func save_session(session: GameSession) -> bool:
	last_save_error_message = ""
	if writes_blocked:
		last_save_error_message = "Uložená hra je chráněná. Pokračování zatím zůstává pouze v paměti telefonu."
		push_warning("Save write was blocked to protect an unreadable or newer save.")
		return false
	var saved := _save_session_to_paths(session, SAVE_PATH, BACKUP_PATH, TEMP_PATH)
	if saved:
		last_successful_save_unix = Time.get_unix_time_from_system()
	else:
		last_save_error_message = "Telefon teď nedokázal zapsat uloženou hru. Poslední změny jsou zatím jen v paměti aplikace."
	return saved


static func create_portable_backup(session: GameSession) -> String:
	if session == null or writes_blocked:
		return ""
	var payload_text := JSON.stringify(session.to_dict())
	var payload_base64 := Marshalls.raw_to_base64(payload_text.to_utf8_buffer())
	return JSON.stringify({
		"format": PORTABLE_BACKUP_FORMAT,
		"version": PORTABLE_BACKUP_VERSION,
		"created_at_unix": Time.get_unix_time_from_system(),
		"payload": payload_base64,
		"sha256": payload_text.sha256_text(),
	}, "  ")


static func decode_portable_backup(text: String) -> Dictionary:
	if text.to_utf8_buffer().size() > PORTABLE_BACKUP_MAX_BYTES:
		return {"ok": false, "status": STATUS_CORRUPT, "data": {}, "message": "Záloha je příliš velká nebo neplatná."}
	var parser := JSON.new()
	if parser.parse(text) != OK or not parser.data is Dictionary:
		return {"ok": false, "status": STATUS_CORRUPT, "data": {}, "message": "Soubor není platná záloha Bazal’s Pocket Garden."}
	var envelope: Dictionary = parser.data
	if str(envelope.get("format", "")) != PORTABLE_BACKUP_FORMAT or int(envelope.get("version", 0)) != PORTABLE_BACKUP_VERSION:
		return {"ok": false, "status": STATUS_CORRUPT, "data": {}, "message": "Soubor nemá podporovaný formát zálohy."}
	var payload_base64 := str(envelope.get("payload", ""))
	var payload_text := Marshalls.base64_to_raw(payload_base64).get_string_from_utf8()
	if payload_text.is_empty() or payload_text.sha256_text() != str(envelope.get("sha256", "")):
		return {"ok": false, "status": STATUS_CORRUPT, "data": {}, "message": "Záloha je poškozená nebo neúplná."}
	var decoded := _decode_data_result(payload_text)
	if decoded.status == STATUS_UNSUPPORTED:
		return {"ok": false, "status": STATUS_UNSUPPORTED, "data": {}, "message": "Záloha pochází z novější verze hry."}
	if decoded.status != STATUS_PRIMARY:
		return {"ok": false, "status": STATUS_CORRUPT, "data": {}, "message": "Záloha neobsahuje platný herní postup."}
	return {"ok": true, "status": STATUS_PRIMARY, "data": decoded.data, "message": "Záloha je platná a připravená k obnovení."}


static func export_portable_backup_to_path(session: GameSession, path: String) -> Dictionary:
	var backup_text := create_portable_backup(session)
	if backup_text.is_empty():
		return {"ok": false, "message": "Zálohu teď nelze vytvořit, protože je uložený postup chráněný."}
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return {"ok": false, "message": "Vybraný soubor se nepodařilo otevřít pro zápis."}
	file.store_string(backup_text)
	file.flush()
	file.close()
	return {"ok": true, "message": "Záloha postupu byla bezpečně exportována."}


static func read_portable_backup_from_path(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"ok": false, "status": STATUS_CORRUPT, "data": {}, "message": "Vybraný soubor se nepodařilo přečíst."}
	if file.get_length() > PORTABLE_BACKUP_MAX_BYTES:
		file.close()
		return {"ok": false, "status": STATUS_CORRUPT, "data": {}, "message": "Záloha je příliš velká nebo neplatná."}
	var text := file.get_as_text()
	file.close()
	return decode_portable_backup(text)


static func install_portable_session(imported_session: GameSession) -> Dictionary:
	return _install_portable_session_to_paths(imported_session, SAVE_PATH, BACKUP_PATH, TEMP_PATH, BEFORE_IMPORT_PATH)


static func install_new_game_session(new_session: GameSession) -> Dictionary:
	return _install_new_game_session_to_paths(new_session, SAVE_PATH, BACKUP_PATH, TEMP_PATH, BEFORE_NEW_GAME_PATH)


static func read_before_new_game_backup() -> Dictionary:
	return _read_before_new_game_backup_from_path(BEFORE_NEW_GAME_PATH)


static func restore_before_new_game_session(profile: Dictionary) -> Dictionary:
	return _restore_before_new_game_session_from_paths(profile, SAVE_PATH, BACKUP_PATH, TEMP_PATH, BEFORE_NEW_GAME_PATH, BEFORE_IMPORT_PATH)


static func _install_new_game_session_to_paths(new_session: GameSession, save_path: String, backup_path: String, temp_path: String, before_new_game_path: String) -> Dictionary:
	var result := _install_portable_session_to_paths(new_session, save_path, backup_path, temp_path, before_new_game_path)
	if not bool(result.get("ok", false)):
		result["message"] = "Novou hru se nepodařilo bezpečně připravit; původní postup zůstal aktivní."
		return result
	last_load_status = STATUS_PRIMARY
	last_load_message = "Byla zahájena nová lokální hra."
	writes_blocked = false
	result["message"] = "Nová hra byla připravena. Předchozí postup zůstal v bezpečnostní kopii."
	return result


static func _read_before_new_game_backup_from_path(path: String) -> Dictionary:
	var result := _read_data_result(path)
	match str(result.get("status", STATUS_NEW)):
		STATUS_PRIMARY:
			return {"ok": true, "status": STATUS_PRIMARY, "data": (result.get("data", {}) as Dictionary).duplicate(true), "message": "Předchozí hra je připravená k obnovení."}
		STATUS_UNSUPPORTED:
			return {"ok": false, "status": STATUS_UNSUPPORTED, "data": {}, "message": "Kopie předchozí hry pochází z novější verze a zůstala nedotčená."}
		STATUS_CORRUPT:
			return {"ok": false, "status": STATUS_CORRUPT, "data": {}, "message": "Kopie předchozí hry není čitelná a zůstala nedotčená."}
		_:
			return {"ok": false, "status": STATUS_NEW, "data": {}, "message": "Žádná předchozí hra zatím není uložená."}


static func _restore_before_new_game_session_from_paths(profile: Dictionary, save_path: String, backup_path: String, temp_path: String, before_new_game_path: String, before_import_path: String) -> Dictionary:
	var available := _read_before_new_game_backup_from_path(before_new_game_path)
	if not bool(available.get("ok", false)):
		return available
	var restored := GameSession.new(profile)
	restored.from_dict(available.get("data", {}) as Dictionary)
	var result := _install_portable_session_to_paths(restored, save_path, backup_path, temp_path, before_import_path)
	if not bool(result.get("ok", false)):
		result["message"] = "Předchozí hru se nepodařilo bezpečně obnovit; současný postup zůstal aktivní."
		return result
	var copy_consumed := true
	if FileAccess.file_exists(before_new_game_path):
		copy_consumed = DirAccess.remove_absolute(ProjectSettings.globalize_path(before_new_game_path)) == OK
	last_load_status = STATUS_PRIMARY
	last_load_message = "Předchozí lokální hra byla obnovena."
	writes_blocked = false
	result["session"] = restored
	result["message"] = "Předchozí hra byla obnovena. Novější postup zůstal v bezpečnostní kopii." if copy_consumed else "Předchozí hra byla obnovena; její původní kopii se nepodařilo odstranit."
	return result


static func _install_portable_session_to_paths(imported_session: GameSession, save_path: String, backup_path: String, temp_path: String, before_import_path: String) -> Dictionary:
	if imported_session == null or writes_blocked:
		return {"ok": false, "message": "Obnovu nelze provést, dokud je uložený postup chráněný."}
	if FileAccess.file_exists(save_path):
		if _read_supported_data(save_path).is_empty():
			return {"ok": false, "message": "Aktuální uložená hra není čitelná a zůstala nedotčená."}
		var before_import_absolute := ProjectSettings.globalize_path(before_import_path)
		if FileAccess.file_exists(before_import_path):
			var remove_error := DirAccess.remove_absolute(before_import_absolute)
			if remove_error != OK:
				return {"ok": false, "message": "Starší bezpečnostní kopii před obnovou nelze nahradit."}
		var preserve_error := DirAccess.copy_absolute(ProjectSettings.globalize_path(save_path), before_import_absolute)
		if preserve_error != OK:
			return {"ok": false, "message": "Aktuální postup se nepodařilo bezpečně uchovat před obnovou."}
	if not _save_session_to_paths(imported_session, save_path, backup_path, temp_path):
		return {"ok": false, "message": "Obnovenou zálohu se nepodařilo zapsat; původní postup zůstal aktivní."}
	last_successful_save_unix = Time.get_unix_time_from_system()
	last_save_error_message = ""
	return {"ok": true, "message": "Záloha byla obnovena a bezpečně uložena."}


static func _save_session_to_paths(session: GameSession, save_path: String, backup_path: String, temp_path: String) -> bool:
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		push_error("Temporary save file could not be opened: %s" % FileAccess.get_open_error())
		return false
	file.store_string(JSON.stringify(session.to_dict(), "  "))
	file.flush()
	file.close()

	var save_absolute := ProjectSettings.globalize_path(save_path)
	var backup_absolute := ProjectSettings.globalize_path(backup_path)
	var temp_absolute := ProjectSettings.globalize_path(temp_path)
	if _read_supported_data(temp_path).is_empty():
		push_error("Temporary save did not pass validation and was not installed.")
		DirAccess.remove_absolute(temp_absolute)
		return false
	if FileAccess.file_exists(save_path) and _read_supported_data(save_path).is_empty():
		push_error("Unreadable primary save was not overwritten.")
		DirAccess.remove_absolute(temp_absolute)
		return false
	if not FileAccess.file_exists(save_path):
		# A surviving backup can be the only readable copy after an interrupted
		# recovery. Do not rotate or remove it until the new primary is installed.
		var first_replace_error := DirAccess.rename_absolute(temp_absolute, save_absolute)
		if first_replace_error == OK and not _read_supported_data(save_path).is_empty():
			return true
		push_error("Temporary save could not create a validated primary save: %s" % error_string(first_replace_error))
		if FileAccess.file_exists(save_path) and _read_supported_data(save_path).is_empty():
			DirAccess.remove_absolute(save_absolute)
		if FileAccess.file_exists(temp_path):
			DirAccess.remove_absolute(temp_absolute)
		return false

	var rotation_path := "%s.rotation" % backup_path
	var rotation_absolute := ProjectSettings.globalize_path(rotation_path)
	var backup_is_valid := not _read_supported_data(backup_path).is_empty()
	if FileAccess.file_exists(rotation_path):
		var remove_rotation_error := DirAccess.remove_absolute(rotation_absolute)
		if remove_rotation_error != OK:
			push_error("Stale save rotation could not be removed: %s" % error_string(remove_rotation_error))
			DirAccess.remove_absolute(temp_absolute)
			return false
	if backup_is_valid:
		var stage_backup_error := DirAccess.copy_absolute(save_absolute, rotation_absolute)
		if stage_backup_error != OK or _read_supported_data(rotation_path).is_empty():
			push_error("Current save could not be staged for backup rotation: %s" % error_string(stage_backup_error))
			if FileAccess.file_exists(rotation_path):
				DirAccess.remove_absolute(rotation_absolute)
			DirAccess.remove_absolute(temp_absolute)
			return false
	else:
		# The primary is still intact here, so replacing an absent or unreadable
		# backup cannot remove the last valid copy of the player's progress.
		if FileAccess.file_exists(backup_path):
			var remove_invalid_backup_error := DirAccess.remove_absolute(backup_absolute)
			if remove_invalid_backup_error != OK:
				push_error("Unreadable save backup could not be replaced: %s" % error_string(remove_invalid_backup_error))
				DirAccess.remove_absolute(temp_absolute)
				return false
		var create_backup_error := DirAccess.copy_absolute(save_absolute, backup_absolute)
		if create_backup_error != OK or _read_supported_data(backup_path).is_empty():
			push_error("Current save could not be preserved as a validated backup: %s" % error_string(create_backup_error))
			if FileAccess.file_exists(backup_path) and _read_supported_data(backup_path).is_empty():
				DirAccess.remove_absolute(backup_absolute)
			DirAccess.remove_absolute(temp_absolute)
			return false

	var remove_primary_error := DirAccess.remove_absolute(save_absolute)
	if remove_primary_error != OK:
		push_error("Current save could not be prepared for replacement: %s" % error_string(remove_primary_error))
		if FileAccess.file_exists(rotation_path):
			DirAccess.remove_absolute(rotation_absolute)
		DirAccess.remove_absolute(temp_absolute)
		return false
	var replace_error := DirAccess.rename_absolute(temp_absolute, save_absolute)
	if replace_error != OK or _read_supported_data(save_path).is_empty():
		push_error("Temporary save could not replace the current save: %s" % error_string(replace_error))
		if FileAccess.file_exists(save_path) and _read_supported_data(save_path).is_empty():
			DirAccess.remove_absolute(save_absolute)
		var restore_path := rotation_path if not _read_supported_data(rotation_path).is_empty() else backup_path
		if not _read_supported_data(restore_path).is_empty():
			var restore_error := DirAccess.copy_absolute(ProjectSettings.globalize_path(restore_path), save_absolute)
			if restore_error != OK:
				push_error("Previous save remains in backup but could not be restored as primary: %s" % error_string(restore_error))
		if FileAccess.file_exists(temp_path):
			DirAccess.remove_absolute(temp_absolute)
		if FileAccess.file_exists(rotation_path):
			DirAccess.remove_absolute(rotation_absolute)
		return false

	# Only now, after the new primary passed validation, may the previous backup
	# be replaced by the immediately preceding primary save.
	if FileAccess.file_exists(rotation_path):
		if FileAccess.file_exists(backup_path):
			var remove_old_backup_error := DirAccess.remove_absolute(backup_absolute)
			if remove_old_backup_error != OK:
				push_warning("New primary is safe, but the older backup could not be rotated: %s" % error_string(remove_old_backup_error))
				DirAccess.remove_absolute(rotation_absolute)
				return true
		var finish_rotation_error := DirAccess.rename_absolute(rotation_absolute, backup_absolute)
		if finish_rotation_error != OK:
			push_warning("New primary is safe, but the staged backup could not be installed: %s" % error_string(finish_rotation_error))
	return true


static func load_session(profile: Dictionary) -> GameSession:
	return _load_session_from_paths(profile, SAVE_PATH, BACKUP_PATH, RECOVERY_PATH)


static func _load_session_from_paths(profile: Dictionary, save_path: String, backup_path: String, recovery_path: String, unix_time := -1.0) -> GameSession:
	last_load_offline_seconds_applied = 0.0
	last_successful_save_unix = 0.0
	var session := GameSession.new(profile)
	var result := _load_data_with_recovery(save_path, backup_path, recovery_path)
	last_load_status = str(result.status)
	last_load_message = str(result.message)
	writes_blocked = last_load_status in [STATUS_BACKUP_READ_ONLY, STATUS_CORRUPT, STATUS_UNSUPPORTED]
	var data: Dictionary = result.data
	if data.is_empty():
		return session
	session.from_dict(data)
	last_successful_save_unix = maxf(0.0, session.saved_at_unix)
	var effective_unix := Time.get_unix_time_from_system() if unix_time < 0.0 else unix_time
	var offline_seconds := effective_unix - session.saved_at_unix
	last_load_offline_seconds_applied = session.advance_offline(offline_seconds)
	return session


static func consume_last_load_offline_seconds() -> float:
	var applied := last_load_offline_seconds_applied
	last_load_offline_seconds_applied = 0.0
	return applied


static func _load_data_with_recovery(save_path: String, backup_path: String, recovery_path: String) -> Dictionary:
	var primary_exists := FileAccess.file_exists(save_path)
	var primary_result := _read_data_result(save_path) if primary_exists else {"status": STATUS_NEW, "data": {}}
	if primary_result.status == STATUS_PRIMARY:
		return {"status": STATUS_PRIMARY, "data": primary_result.data, "message": "Lokální save byl načten."}
	# A readable save from a newer game version is authoritative. Falling back to
	# an older backup here would silently downgrade progress and unblock writes.
	if primary_result.status == STATUS_UNSUPPORTED:
		return {"status": STATUS_UNSUPPORTED, "data": {}, "message": "Save pochází z novější nepodporované verze a zůstal nedotčený."}
	var backup_result := _read_data_result(backup_path) if FileAccess.file_exists(backup_path) else {"status": STATUS_NEW, "data": {}}
	if backup_result.status == STATUS_PRIMARY:
		if _heal_primary_from_backup(save_path, backup_path, recovery_path):
			return {"status": STATUS_BACKUP_RECOVERED, "data": backup_result.data, "message": "Poškozený save byl obnoven z poslední platné zálohy."}
		return {"status": STATUS_BACKUP_READ_ONLY, "data": backup_result.data, "message": "Načetla se platná záloha pouze pro čtení; primární soubor se nepodařilo bezpečně opravit a zápis zůstal zablokovaný."}
	if not primary_exists:
		return {"status": STATUS_NEW, "data": {}, "message": "Nová lokální hra."}
	return {"status": STATUS_CORRUPT, "data": {}, "message": "Save je poškozený a zůstal nedotčený."}


static func _heal_primary_from_backup(save_path: String, backup_path: String, recovery_path: String) -> bool:
	var save_absolute := ProjectSettings.globalize_path(save_path)
	var backup_absolute := ProjectSettings.globalize_path(backup_path)
	var recovery_absolute := ProjectSettings.globalize_path(recovery_path)
	if FileAccess.file_exists(recovery_path):
		DirAccess.remove_absolute(recovery_absolute)
	if FileAccess.file_exists(save_path):
		var preserve_error := DirAccess.rename_absolute(save_absolute, recovery_absolute)
		if preserve_error != OK:
			return false
	var copy_error := DirAccess.copy_absolute(backup_absolute, save_absolute)
	return copy_error == OK


static func discard_unreadable_save_for_new_game() -> bool:
	var ok := true
	for path in [SAVE_PATH, BACKUP_PATH, TEMP_PATH]:
		if FileAccess.file_exists(path):
			ok = DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) == OK and ok
	writes_blocked = false
	last_save_error_message = ""
	last_load_offline_seconds_applied = 0.0
	last_load_status = STATUS_NEW
	last_load_message = "Byla připravena nová lokální hra."
	return ok


static func _read_supported_data(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	return _decode_supported_data(file.get_as_text())


static func _read_data_result(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"status": STATUS_NEW, "data": {}}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"status": STATUS_CORRUPT, "data": {}}
	return _decode_data_result(file.get_as_text())


static func _decode_data_result(text: String) -> Dictionary:
	var parser := JSON.new()
	if parser.parse(text) != OK or not parser.data is Dictionary:
		return {"status": STATUS_CORRUPT, "data": {}}
	var parsed: Dictionary = parser.data
	var raw_schema: Variant = parsed.get("schema", 0)
	if raw_schema is bool or not (raw_schema is int or raw_schema is float):
		return {"status": STATUS_CORRUPT, "data": {}}
	var numeric_schema := float(raw_schema)
	if not is_finite(numeric_schema) or numeric_schema != floor(numeric_schema) or numeric_schema < 1.0:
		return {"status": STATUS_CORRUPT, "data": {}}
	if numeric_schema > float(GameSession.SAVE_SCHEMA):
		return {"status": STATUS_UNSUPPORTED, "data": {}}
	return {"status": STATUS_PRIMARY, "data": parsed}


static func _decode_supported_data(text: String) -> Dictionary:
	var result := _decode_data_result(text)
	return result.data if result.status == STATUS_PRIMARY else {}
