# RC61 continuous validation

`RC61 validation` is a deliberately read-only GitHub Actions gate for the source project. The historical filename is retained. It does not publish, sign, export or install the game; GitHub Actions retains diagnostic logs as an artifact for 14 days.

## Automated pull-request gates

The Windows job:

1. checks out the repository with read-only `contents` permission;
2. installs Python 3.12 and pinned `Pillow==11.3.0`;
3. downloads the exact `4.7-stable` Windows editor from the official `godotengine/godot-builds` GitHub release and verifies it against that release's `SHA512-SUMS.txt`;
4. checks project/export version coherence and keeps `SAVE_SCHEMA=46` explicit;
5. requires the three Android presets to share version code, package ID, and export exclusions;
6. rejects missing literal `res://` resources and runtime resources hidden by an export exclusion; the only explicit exception is the existing `docs/visual-proposals/**` design-contract metadata declared in `visual_design_system.gd`, which is verified as present but is intentionally not packaged;
7. runs the focused headless GDScript visual-contract audit, including a fresh Godot asset import;
8. runs the complete `tests/test_runner.gd` regression suite and requires its `MVP_TESTS_PASSED=<count>` marker;
9. requires at least 6,849 regression checks, preventing an accidentally reduced suite from passing;
10. pins the approved visual contract to 54 cases, 34 active gates and digest `81C18A8090A80C4A6B1D05124FD6CCE974AB48FA44D998B630992FBEC133CF7F`;
11. hashes the visual manifest and every referenced golden image before and after the run, failing if validation modified any of them.
12. rejects a drive-bound Godot 4.7 executable path in any project PowerShell tool, preserving relocatability between disks and checkout names.

The required export exclusions are `docs/**`, `tests/**`, `tools/**`, `builds/**`, `assets/ui/visual/**/source/**`, `assets/ui/visual/phase167/**`, `assets/ui/visual/phase149/player_room/qa/**`, `assets/ui/visual/phase150/greenhouse/qa/**`, and the exact unused `assets/ui/visual/phase150/greenhouse/greenhouse_phase150_registered_clean_donor_candidate_v1.png`. The CI runner never offers an update-baseline or golden-rewrite mode. APK/AAB exporters also reject the five audited QA/donor basenames in raw, import-sidecar and compiled-texture payload entries.

Both import runners use Godot's `--import` mode to wait for resource imports before exiting. The 2026-09-09 clean-source rerun and the earlier native failure are recorded separately in the [post-audit report](audit/20260909_POST_AUDIT_PRUNING.md).

## Local Windows invocation

Run the same headless gates from the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\run_ci_validation.ps1 `
  -PythonPath '<python-with-Pillow>' `
  -ExpectedSaveSchema 46 `
  -ExpectedMinimumRegressionTests 6849 `
  -ExpectedVisualCases 54 `
  -ExpectedActiveVisualGates 34 `
  -ExpectedGoldenDigest 81C18A8090A80C4A6B1D05124FD6CCE974AB48FA44D998B630992FBEC133CF7F
```

Bez parametru `-GodotPath` se použije `HOW_TO_GROW_GODOT`, Godot umístěný vedle složky projektu nebo `godot4`/`godot` z `PATH`. Cestu lze stále zadat explicitně, pokud editor leží jinde.

On a real Windows desktop with a functioning renderer, append `-FullVisualValidation` to invoke the existing `how-to-grow-validation` skill runner as an additional gate. This intentionally is not enabled on the headless hosted runner: deterministic screenshot capture needs a real renderer, while the hosted gate remains responsible for import, GDScript, static asset/export, and visual-contract correctness.

## Evidence and boundaries

Primary CI evidence is written under `.godot/ci/<UTC timestamp>` and `.godot/visual-contract/<UTC timestamp>`. The regression runner also uses ignored local paths such as `.godot/mvp-tests.log`, `.godot/asset-import.log`, `.godot/test-appdata/` and Godot's import cache. The workflow uploads diagnostic logs on success or failure and retains them for 14 days; successful markers and failure diagnostics also remain in the normal GitHub Actions job log.

The nine workshop/navigation PNG mappings were approved on 2026-10-20. Their [approval record](audit/workshop-navigation-20261020/approval.json) pins the reviewed candidates and the previous references. The original palette manifest and PNGs remain unchanged; all 54 cases, 34 gates, masks, crops and thresholds are retained.

The pinned digest is an accidental-drift guard, not a substitute for repository review rules: any intentional baseline update must include its dated visual approval record and an explicit review of the new digest. On a future remote, protect the workflow, visual manifest and golden references with branch rules or CODEOWNERS.

An automated PASS does not prove physical Android behavior, touch comfort, device heat/battery, notification delivery, a signed AAB, Google Play review readiness, or human visual acceptance. Those remain separate release gates. No Android signing secrets are referenced by this workflow.
