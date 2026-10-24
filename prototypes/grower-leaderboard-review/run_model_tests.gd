extends SceneTree
var checks := 0
var failures: Array[String] = []

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool,message: String) -> void:
	checks += 1
	if not ok:
		failures.append(message)
		push_error(message)

func run() -> void:
	preload("res://prototypes/grower-leaderboard-review/model_test.gd").run(check)
	print("GROWER_LEADERBOARD_MODEL_CHECKS=%d FAILURES=%d" % [checks,failures.size()])
	quit(0 if checks>0 and failures.is_empty() else 1)
