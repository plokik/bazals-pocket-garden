class_name CareNotificationService
extends RefCounted

const ANDROID_BRIDGE_CLASS := "com.howtogrow.notifications.CareNotificationBridge"
const MINIMUM_BACKGROUND_DELAY_SECONDS := 60.0
const TEST_REMINDER_DELAY_SECONDS := 20.0

var backend: Variant
var platform_name := ""
var last_result: Dictionary = {}


func _init(backend_override: Variant = null, platform_override := "") -> void:
	platform_name = platform_override if not platform_override.is_empty() else OS.get_name()
	backend = backend_override
	if backend == null and platform_name == "Android":
		var wrapper := Engine.get_singleton("JavaClassWrapper")
		if wrapper != null:
			backend = wrapper.wrap(ANDROID_BRIDGE_CLASS)


func is_system_available() -> bool:
	return backend != null and bool(backend.isSupported())


func has_permission() -> bool:
	return is_system_available() and bool(backend.hasPermission())


func request_permission() -> bool:
	if not is_system_available():
		return false
	return bool(backend.requestPermission())


func enter_foreground() -> void:
	cancel_system_reminder()


func cancel_system_reminder() -> void:
	if is_system_available():
		backend.cancelReminder()
	last_result = {"state": "cancelled"}


func get_scheduled_at_millis() -> int:
	if not is_system_available():
		return 0
	return int(backend.getScheduledAtMillis())


func consume_opened_slot_index() -> int:
	if not is_system_available():
		return -1
	var slot_number := int(backend.consumeOpenedSlotNumber())
	return slot_number - 1 if slot_number > 0 else -1


func schedule_test_reminder(now_unix: float = -1.0) -> Dictionary:
	var current_unix := Time.get_unix_time_from_system() if now_unix < 0.0 else now_unix
	if not is_system_available():
		return _remember({"state": "unavailable", "scheduled": false})
	if not has_permission():
		return _remember({"state": "permission_required", "scheduled": false})
	var trigger_millis := roundi((current_unix + TEST_REMINDER_DELAY_SECONDS) * 1000.0)
	var title := "Bazal’s Pocket Garden · test upozornění"
	var body := "Test funguje. Připomínky péče mohou dorazit i mimo hru."
	var scheduled := bool(backend.scheduleReminder(trigger_millis, 1, title, body))
	return _remember({
		"state": "test_scheduled" if scheduled else "error",
		"scheduled": scheduled,
		"trigger_millis": trigger_millis,
		"delay_seconds": TEST_REMINDER_DELAY_SECONDS,
	})


func prepare_background_reminder(game_session: GameSession, now_unix: float = -1.0) -> Dictionary:
	var current_unix := Time.get_unix_time_from_system() if now_unix < 0.0 else now_unix
	if game_session == null:
		return _remember({"state": "unavailable", "scheduled": false})
	if not is_system_available():
		return _remember({"state": "in_app_only", "scheduled": false})
	if not game_session.care_reminders_enabled:
		backend.cancelReminder()
		return _remember({"state": "disabled", "scheduled": false})
	if not has_permission():
		backend.cancelReminder()
		return _remember({"state": "permission_required", "scheduled": false})
	var next_check := game_session.get_next_care_check()
	var slot_index := int(next_check.get("slot_index", -1))
	if slot_index < 0:
		backend.cancelReminder()
		return _remember({"state": "waiting", "scheduled": false})
	var raw_delay := float(next_check.get("seconds", 0.0))
	var status := str(next_check.get("status", "Kontrola rostliny"))
	# The care plan already returns the nearest meaningful boundary (care,
	# wilting, death, harvest or processing). Schedule that exact boundary;
	# introducing an extra lead here would make the UI and Android disagree.
	var delay_seconds := maxf(MINIMUM_BACKGROUND_DELAY_SECONDS, raw_delay)
	var trigger_millis := roundi((current_unix + delay_seconds) * 1000.0)
	var slot_number := slot_index + 1
	var title := "Bazal’s Pocket Garden · kontrola péče"
	var body := "Květináč %d · %s." % [slot_number, status]
	var scheduled := bool(backend.scheduleReminder(trigger_millis, slot_number, title, body))
	return _remember({
		"state": "scheduled" if scheduled else "error",
		"scheduled": scheduled,
		"trigger_millis": trigger_millis,
		"slot_number": slot_number,
		"delay_seconds": delay_seconds,
		"status": status,
	})


func get_ui_state(game_session: GameSession) -> Dictionary:
	if game_session == null:
		return {}
	if not is_system_available():
		return {
			"mode": "in_app_only",
			"button_text": "PŘIPOMÍNKY V APLIKACI · %s" % ("ZAPNUTÉ" if game_session.care_reminders_enabled else "VYPNUTÉ"),
			"summary_text": game_session.get_care_reminder_summary(),
			"enabled": game_session.care_reminders_enabled,
		}
	if not game_session.care_reminders_enabled:
		return {
			"mode": "disabled",
			"button_text": "ANDROID UPOZORNĚNÍ · VYPNUTÁ",
			"summary_text": "Připomínky v aplikaci i v Androidu jsou vypnuté.",
			"enabled": false,
		}
	if not has_permission():
		return {
			"mode": "permission_required",
			"button_text": "POVOLIT ANDROID UPOZORNĚNÍ",
			"summary_text": "Povol oznámení v Androidu; do té doby fungují jen v otevřené hře.",
			"enabled": false,
		}
	return {
		"mode": "android_enabled",
		"button_text": "ANDROID UPOZORNĚNÍ · ZAPNUTÁ",
		"summary_text": "%s Upozornění se připraví při odchodu ze hry." % game_session.get_care_reminder_summary(),
		"enabled": true,
	}


func should_request_permission(game_session: GameSession) -> bool:
	return game_session != null and game_session.care_reminders_enabled and is_system_available() and not has_permission()


func _remember(result: Dictionary) -> Dictionary:
	last_result = result
	return result
