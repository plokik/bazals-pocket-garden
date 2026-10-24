extends SceneTree

var checks := 0
var failures: Array[String] = []


func _initialize() -> void:
	create_timer(45.0).timeout.connect(func():
		push_error("GROWER_LEADERBOARD_LAYOUT_TIMEOUT")
		quit(2)
	)
	call_deferred("_run")


func _check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures.append(message)
		push_error(message)


func _run() -> void:
	var tests = load("res://prototypes/grower-leaderboard-review/layout_test.gd")
	if tests == null or not tests.has_method("run"):
		push_error("GROWER_LEADERBOARD_LAYOUT_TEST_LOAD_FAILED")
		quit(2)
		return
	var measurements: Array[Dictionary] = await tests.run(self,_check,false)
	if checks == 0: failures.append("No checks executed")
	var result := {"checks":checks,"failures":failures,"measurements":measurements,"scope":"headless Control geometry, font metrics and real push_input touch-button/wheel input only; direct ScreenDrag is excluded and remains failed/unverified in separate diagnostic evidence; no raster or device acceptance"}
	var file := FileAccess.open("res://tmp/grower-leaderboard-review-20261024/layout-checks/final-result.json",FileAccess.WRITE)
	if file != null: file.store_string(JSON.stringify(result,"\t"))
	print("GROWER_LEADERBOARD_LAYOUT_CHECKS=%d FAILURES=%d" % [checks,failures.size()])
	quit(0 if failures.is_empty() else 1)
