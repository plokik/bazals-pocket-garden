# RC59 continuous validation

`RC59 validation` is a deliberately read-only GitHub Actions gate for the source project. It prepares CI for a future remote repository; it does not publish, sign, export, install, or send project artifacts to another service.

## Automated pull-request gates

The Windows job:

1. checks out the repository with read-only `contents` permission;
2. installs Python 3.12 and pinned `Pillow==11.3.0`;
3. downloads the exact `4.7-stable` Windows editor from the official `godotengine/godot-builds` GitHub release and verifies it against that release's `SHA512-SUMS.txt`;
4. checks project/export version coherence and keeps `SAVE_SCHEMA=41` explicit;
5. requires the three Android presets to share version code, package ID, and export exclusions;
6. rejects missing literal `res://` resources and runtime resources hidden by an export exclusion; the only explicit exception is the existing `docs/visual-proposals/**` design-contract metadata declared in `visual_design_system.gd`, which is verified as present but is intentionally not packaged;
7. runs the focused headless GDScript visual-contract audit, including a fresh Godot asset import;
8. runs the complete `tests/test_runner.gd` regression suite and requires its `MVP_TESTS_PASSED=<count>` marker;
9. requires at least 6,747 regression checks, preventing an accidentally reduced suite from passing;
10. pins the approved visual contract to 54 cases, 34 active gates and digest `77946B927604C1CB0C8D7931BD8FFC167E299C858C35B97D548FC07F691E7170`;
11. hashes the visual manifest and every referenced golden image before and after the run, failing if validation modified any of them.
12. rejects a drive-bound Godot 4.7 executable path in any project PowerShell tool, preserving relocatability between disks and checkout names.

The required export exclusions are `docs/**`, `tests/**`, `tools/**`, `builds/**`, `assets/ui/visual/**/source/**`, and `assets/ui/visual/phase167/**`. The CI runner never offers an update-baseline or golden-rewrite mode.

## Local Windows invocation

Run the same headless gates from the repository root:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\run_ci_validation.ps1 `
  -PythonPath '<python-with-Pillow>' `
  -ExpectedSaveSchema 41 `
  -ExpectedMinimumRegressionTests 6747 `
  -ExpectedVisualCases 54 `
  -ExpectedActiveVisualGates 34 `
  -ExpectedGoldenDigest 77946B927604C1CB0C8D7931BD8FFC167E299C858C35B97D548FC07F691E7170
```

Bez parametru `-GodotPath` se použije `HOW_TO_GROW_GODOT`, Godot umístěný vedle složky projektu nebo `godot4`/`godot` z `PATH`. Cestu lze stále zadat explicitně, pokud editor leží jinde.

On a real Windows desktop with a functioning renderer, append `-FullVisualValidation` to invoke the existing `how-to-grow-validation` skill runner as an additional gate. This intentionally is not enabled on the headless hosted runner: deterministic screenshot capture needs a real renderer, while the hosted gate remains responsible for import, GDScript, static asset/export, and visual-contract correctness.

## Evidence and boundaries

Primary CI evidence is written under `.godot/ci/<UTC timestamp>` and `.godot/visual-contract/<UTC timestamp>`. The regression runner also uses ignored local paths such as `.godot/mvp-tests.log`, `.godot/asset-import.log`, `.godot/test-appdata/` and Godot's import cache. The workflow intentionally has no artifact-upload step; successful markers and failure diagnostics remain in the normal GitHub Actions job log.

The pinned digest is an accidental-drift guard, not a substitute for repository review rules: any intentional baseline update must include its dated visual approval record and an explicit review of the new digest. On a future remote, protect the workflow, visual manifest and golden references with branch rules or CODEOWNERS.

An automated PASS does not prove physical Android behavior, touch comfort, device heat/battery, notification delivery, a signed AAB, Google Play review readiness, or human visual acceptance. Those remain separate release gates. No Android signing secrets are referenced by this workflow.
