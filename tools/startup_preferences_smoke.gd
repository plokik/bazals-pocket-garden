extends SceneTree
## Isolated malformed-save and accessibility checks. Never touch player saves.
const STARTUP := preload("res://scripts/ui/startup_loading_screen.gd")
var failed := false

func _initialize() -> void:
	var directory := "res://.godot/startup-preferences-smoke"
	DirAccess.make_dir_recursive_absolute(directory)
	var primary := directory.path_join("primary.json")
	var backup := directory.path_join("backup.json")
	_write(primary, "{\"reduced_motion\": true}")
	_write(backup, "{\"reduced_motion\": false}")
	_check(STARTUP._read_reduced_motion([primary, backup]), "primary preference")
	_write(primary, "{invalid")
	_write(backup, "{\"reduced_motion\": true}")
	_check(STARTUP._read_reduced_motion([primary, backup]), "corrupt primary falls back")
	_write(primary, "[]")
	_check(STARTUP._read_reduced_motion([primary, backup]), "non-dictionary falls back")
	_write(primary, "{\"reduced_motion\": false}")
	_check(not STARTUP._read_reduced_motion([primary, backup]), "primary false overrides backup")
	_write(primary, "{\"reduced_motion\": \"false\"}")
	_check(not STARTUP._read_reduced_motion([primary, backup]), "string is not boolean")
	_write(primary, "{\"reduced_motion\": true}" + " ".repeat(2 * 1024 * 1024))
	_write(backup, "{\"reduced_motion\": false}")
	_check(not STARTUP._read_reduced_motion([primary, backup]), "oversized file is skipped")
	_check(not STARTUP._read_reduced_motion([directory.path_join("missing.json")]), "missing save defaults")
	var screen := STARTUP.new()
	screen.reduced_motion = true
	screen._build_ui()
	screen.size = Vector2(360.0, 625.0)
	screen._layout_ui()
	var base_y := float(screen.orchid_left.get_meta("base_y"))
	screen.elapsed = 4.0
	screen._animate_ornament(screen.orchid_left, 0.0, 3.5, 0.035)
	_check(screen.orchid_left.position.y == base_y and screen.orchid_left.rotation == 0.0 and screen.orchid_left.modulate.a == 1.0, "reduced ornament stays still and visible")
	screen.reduced_motion = false
	screen._animate_ornament(screen.orchid_left, 0.0, 3.5, 0.035)
	_check(screen.orchid_left.position.y != base_y and screen.orchid_left.rotation != 0.0, "normal ornament still animates")
	screen.free()
	print("STARTUP_PREFERENCES_SMOKE=%s" % ("FAILED" if failed else "PASSED"))
	quit(1 if failed else 0)

func _write(path: String, value: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(value)
	file.close()

func _check(condition: bool, message: String) -> void:
	if not condition:
		failed = true
		push_error(message)
