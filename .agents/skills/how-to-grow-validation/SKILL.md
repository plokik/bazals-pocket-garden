---
name: how-to-grow-validation
description: Run deterministic Godot 4.7 validation for Bazal’s Pocket Garden, including asset import, the complete GDScript regression suite, fixed-state screenshots, normalized visual comparison, tolerance metrics, and heatmaps. Use when Codex changes gameplay, UI layout, HUD, navigation, rack or locked-slot visuals, capture tooling, save behavior, Android presentation, or when the user asks to validate, compare screenshots, investigate a visual regression, or produce release evidence for this project.
---

# Bazal’s Pocket Garden validation

Use the bundled runner as the source of truth for project validation. Keep the workflow deterministic and leave approved reference PNGs unchanged.

## Run the workflow

1. Locate the repository root containing `project.godot`. Prefer the current repository. Use an explicit `-ProjectRoot` only when the skill is being tested from another checkout.
2. Inspect `git status --short` before validation. Preserve unrelated user changes.
3. Resolve Python with Pillow. In the Codex desktop app, call the workspace dependency loader and use its bundled Python path.
4. Run from the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents\skills\how-to-grow-validation\scripts\run_validation.ps1 -PythonPath '<python-path>'
```

5. Confirm both `MVP_TESTS_PASSED=<count>` and `HOW_TO_GROW_VALIDATION=PASSED` in output. Do not rely only on the process exit code.
6. Open the emitted `report.md`, then inspect each failed comparison image. Report the run directory, metrics, failed thresholds, and the existing source changes that plausibly caused them.

### Avoid the unstable standalone parser path on Windows

- Do not run Godot 4.7 as `--check-only --script` against an absolute, external, or partially staged `.gd` file. This mode has produced native Windows access violations in the engine and can leave one application-error dialog per invocation.
- On Windows, either set the working directory to the complete project and use `--path .` with a project-local log, or pass absolute paths inside that complete project. Never point both `--path` and `--log-file` at a relative staged subdirectory from another working directory: that reproduced combination made Godot resolve an invalid `user://C:` directory and crash natively.
- Validate staged code by overlaying it into a complete project mirror and run the normal project-scoped workflow above. For a narrow parser check, use the same mirror with a `res://` entrypoint that loads the real project dependencies.
- A native Godot crash is a failed validation even when no GDScript parse message was emitted. Do not retry the same standalone command in parallel; record the native exit and move to the complete-project mirror.

Phase 47 additionally emits diagnostic `comic-local-backup.png` evidence, Phase 49 emits `comic-grower-journal.png`, Phase 62 emits `comic-detail-treatment.png`, Phase 63 emits `comic-plant-diagnosis.png`, Phase 64 emits `comic-plant-diagnosis-action.png`, Phase 65 emits `comic-fast-time-guard.png`, Phase 75 emits `comic-detail-late-harvest.png`, `comic-detail-wilted.png`, `comic-detail-dead.png`, and `comic-care-center-wilted.png`, Phase 78 emits `comic-botanical-pack.png`, and Phase 79 emits `comic-plant-behavior.png`. Keep these report-only until the user explicitly approves a reference and gate.

The runner writes only beneath `.godot/validation/<UTC timestamp>` unless `-OutputRoot` is provided. It runs the project's existing `tools/run_tests.ps1`, captures fixed states without writing into `docs/`, and creates normalized reference, actual, heatmap, and three-panel comparison images. It also emits deterministic `comic-storage.png`, `comic-shop.png`, `comic-botanist-shop-buy.png`, `comic-equipment-shop.png`, `comic-botanist-shop-sell.png`, `comic-measurement.png`, `comic-guide-explain.png`, `comic-guide-celebrate.png`, `comic-guide-warning.png`, `comic-audio-settings.png`, `comic-customer-orders.png`, `comic-seed-selector.png`, `comic-mint-room.png`, `comic-mint-detail.png`, `comic-herbarium.png`, `comic-daily-challenge.png`, `comic-botanical-pack.png`, `comic-cosmetic-showroom.png`, `comic-return-summary.png`, `comic-level-progression.png`, `comic-care-center.png`, `comic-grower-journal.png`, `comic-oregano-shop.png`, `comic-oregano-room.png`, `comic-oregano-detail.png`, `comic-detail-idle.png`, `comic-detail-late-harvest.png`, `comic-detail-wilted.png`, `comic-detail-dead.png`, `comic-care-center-wilted.png`, `comic-plant-behavior.png`, `comic-detail-water.png`, `comic-detail-growth.png`, `comic-detail-ladybug.png`, `comic-feedback-water.png`, `comic-feedback-growth.png`, `comic-feedback-coins.png`, `comic-feedback-unlock.png`, and `comic-screen-transition.png` frames. The three guide frames and five shared feedback/transition frames are approved Phase 6–7 gates. The new botanist buy/equipment/sell frames, Phase 9 audio settings, Phase 10 customer orders, Phase 11 seed/mint screens, Phase 12 herbarium, Phase 13 daily challenge, Phase 14 cosmetic showroom, Phase 15 return summary, Phase 41 level progression, Phase 42–43 care center/plan, Phase 49 grower journal, Phase 71 oregano screens, Phase 75 lifecycle screens, Phase 78 botanical-pack screen, Phase 79 plant-behavior screen, and detail idle/action/ladybug frames remain diagnostic evidence until the user explicitly approves their own references and gates.

## Select a narrower check

- Pass `-SkipTests` only when iterating on the diff implementation itself.
- Pass `-SkipCapture` only when the selected artifact directory already contains all manifest `actual` files.
- Pass `-ReportOnly` when calibrating a newly approved visual case. Never weaken an existing gate merely to make a regression pass.
- Use `scripts/visual_diff.py` directly for focused investigation of existing artifacts.

## Protect reference integrity

- Treat every manifest `reference` as read-only.
- Never add an update-baseline option to these scripts.
- Never derive a new approved reference silently from current output.
- Keep conceptual target comparisons marked `gate: false` until the user explicitly approves a regression threshold or exact baseline.
- When changing mappings, crops, masks, or thresholds, read and edit `references/visual-cases.json`, explain the evidence, and validate the new configuration against a real capture.
- Keep dynamic masks narrow. Mask only changing values or animation surfaces, not surrounding layout, frames, icons, or padding.

## Interpret results

- `mean_abs_error` measures average per-channel difference from 0 to 255.
- `rmse` emphasizes larger pixel errors.
- `changed_ratio` is the fraction of unmasked pixels whose largest channel difference exceeds `pixel_tolerance`.
- `gate: true` cases fail the run when any configured maximum is exceeded.
- `gate: false` cases always produce evidence but do not block the run.

Treat a missing reference, missing capture, invalid crop, zero unmasked pixels, nonzero Godot exit, Godot script/parse error, or missing `MVP_TESTS_PASSED` marker as a validation failure. Report renderer cleanup/RID warnings separately when the process otherwise exits successfully and emits the required capture marker.
