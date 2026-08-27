extends SceneTree

const VisualDesignSystem := preload("res://scripts/ui/visual_design_system.gd")


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var output_directory := _output_directory()
	if output_directory.is_empty():
		push_error("Missing --output-dir for the visual contract audit.")
		quit(2)
		return
	var absolute_output := ProjectSettings.globalize_path(output_directory)
	var mkdir_error := DirAccess.make_dir_recursive_absolute(absolute_output)
	if mkdir_error != OK:
		push_error("Could not create visual contract output: %s" % error_string(mkdir_error))
		quit(2)
		return

	var errors := VisualDesignSystem.contract_errors()
	var missing_paths := VisualDesignSystem.unprofiled_png_paths()
	var runtime_paths := VisualDesignSystem.runtime_referenced_png_paths()
	for path in missing_paths:
		errors.append("PNG has no family or explicit profile: %s" % path)
	var png_paths := VisualDesignSystem.profiled_png_paths()
	var family_counts := {}
	for path in png_paths:
		var profile := VisualDesignSystem.profile_for_path(path)
		var family_id := str(profile.get("family", ""))
		family_counts[family_id] = int(family_counts.get(family_id, 0)) + 1

	var report := {
		"contract": VisualDesignSystem.CONTRACT_ID,
		"style": VisualDesignSystem.STYLE_ID,
		"master_art_direction": VisualDesignSystem.MASTER_ART_DIRECTION_ID,
		"master_reference_asset": VisualDesignSystem.MASTER_REFERENCE_ASSET,
		"master_reference_sha256": VisualDesignSystem.MASTER_REFERENCE_SHA256,
		"result": "PASSED" if errors.is_empty() else "FAILED",
		"scene_profiles": VisualDesignSystem.SCENE_PROFILES.size(),
		"explicit_asset_profiles": VisualDesignSystem.ASSET_PROFILES.size(),
		"profiled_pngs": png_paths.size(),
		"unprofiled_pngs": missing_paths.size(),
		"runtime_referenced_pngs": runtime_paths.size(),
		"family_counts": family_counts,
		"errors": Array(errors),
	}
	var report_path := output_directory.path_join("visual-contract.json")
	var report_file := FileAccess.open(report_path, FileAccess.WRITE)
	if report_file == null:
		push_error("Could not write visual contract report.")
		quit(2)
		return
	report_file.store_string(JSON.stringify(report, "  ") + "\n")
	report_file.close()

	print("VISUAL_CONTRACT_ID=%s" % VisualDesignSystem.CONTRACT_ID)
	print("VISUAL_CONTRACT_SCENES=%d" % VisualDesignSystem.SCENE_PROFILES.size())
	print("VISUAL_CONTRACT_EXPLICIT_ASSETS=%d" % VisualDesignSystem.ASSET_PROFILES.size())
	print("VISUAL_CONTRACT_PROFILED_PNGS=%d" % png_paths.size())
	print("VISUAL_CONTRACT_UNPROFILED_PNGS=%d" % missing_paths.size())
	print("VISUAL_MASTER_ART_DIRECTION=%s" % VisualDesignSystem.MASTER_ART_DIRECTION_ID)
	print("VISUAL_MASTER_REFERENCE=%s" % VisualDesignSystem.MASTER_REFERENCE_ASSET)
	print("VISUAL_MASTER_RUNTIME_PNGS=%d" % runtime_paths.size())
	print("VISUAL_CONTRACT_REPORT=%s" % ProjectSettings.globalize_path(report_path))
	if not errors.is_empty():
		for error in errors:
			push_error(error)
		print("VISUAL_CONTRACT_AUDIT=FAILED")
		quit(1)
		return
	print("VISUAL_CONTRACT_AUDIT=PASSED")
	quit(0)


func _output_directory() -> String:
	var arguments := OS.get_cmdline_user_args()
	for index in range(arguments.size() - 1):
		if arguments[index] == "--output-dir":
			return arguments[index + 1]
	return ""
