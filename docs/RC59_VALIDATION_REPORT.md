# RC59 validation and relocation report

Audit date: 2026-09-02 (Europe/Prague)

## Scope and verdict

The authoritative checkout was moved from `C:\_projekty\How to grow_` to
`R:\_projekty\Bazal's Pocket Garden`. The old checkout path no longer exists;
Godot 4.7 is available beside the project at
`R:\_projekty\Godot_v4.7-stable_win64.exe`.

- `RC59_RELOCATION_GATE=PASSED`
- `RC59_LOCAL_TECHNICAL_GATE=PASSED`
- `RC59_PHYSICAL_ANDROID_GATE=NOT_REQUESTED`
- `RC59_SIGNED_AAB_GATE=PENDING_EXISTING_SIGNING_CONFIGURATION`
- `RC59_MANUAL_VISUAL_GATE=PENDING_SINGLE_HUMAN_BATCH`
- `RC59_PUBLISHING_GATE=OUT_OF_SCOPE_BY_USER`

The first two markers cover source integrity, Godot import/runtime, the full
regression and pixel suites, performance/endurance/progression/responsive
smokes, Android release configuration, and a real disposable ARM64 APK export.
They do not claim a phone audit, human acceptance, signed AAB, or Google Play
readiness.

## Relocation fixes

Two real path-dependent failures were found and corrected:

1. Ten PowerShell runners defaulted to a deleted hard-coded Godot path on
   `C:`. They now share `tools/resolve_godot_executable.ps1` and resolve in this
   order: explicit `-GodotPath`, `HOW_TO_GROW_GODOT`, Godot beside the project,
   Godot inside the project, then `godot4`/`godot` from `PATH`.
2. Godot's global Android editor setting still supplied an SDK on `C:` while
   the transferred portable SDK was on `R:`. Gradle correctly rejected the two
   conflicting paths. APK and AAB export now run Godot with an isolated
   per-export `APPDATA`, while both `ANDROID_HOME` and `ANDROID_SDK_ROOT` point
   to the same project-local SDK. The caller's original `APPDATA` is restored
   after the Godot process exits.

`tools/run_ci_validation.ps1` additionally rejects any future drive-bound
`Godot_v4.7-stable_win64.exe` path in `tools/*.ps1`.

Tracked runtime GDScript, scenes, data, tests, export configuration, and the
GitHub workflow contain no dependency on the old checkout. Old path strings
that remain in historical documentation, archived `.godot` reports, or old
Gradle intermediates are provenance only and are not runtime inputs. Active
Godot project metadata now points to the executable on `R:`. No junction or
reparse point was found inside the transferred project.

## Source and immutable-artifact integrity

- Branch before this audit: `release/rc59-prep`, HEAD
  `29d49dc732ff8bcc4905b32654e952d18bb69329`.
- `git fsck --full --no-dangling --no-reflogs`: exit 0.
- RC58: `builds/android/bazals-pocket-garden-0.68.0-rc58-arm64-debug.apk`,
  224,368,317 bytes, SHA-256
  `0A7F173D8C97B552168A407C31F1F8AE85109A34C2F6F4786029551064F0C6F5`.
- RC59: `builds/android/bazals-pocket-garden-0.69.0-rc59-arm64-debug.apk`,
  233,837,732 bytes, SHA-256
  `206AC5349731D95570E0E59DD43229A5AB608AA139EA78979FCB3DE907021E7D`.

Both immutable APKs match their pre-move byte counts and hashes. Neither was
rewritten by this audit.

## Automated validation from `R:`

### Quick and CI contracts

- Quick automation: `.godot/automation/20260902-212516Z`,
  `HOW_TO_GROW_AUTOMATION=PASSED`.
- Final CI contract: `.godot/ci/20260902-214503Z`,
  `HOW_TO_GROW_CI=PASSED`.
- Version `0.69.0-rc59`, Android version code 76, save schema 41.
- 6,747/6,747 regression checks passed.
- 54 visual cases, 34 active gates, pinned digest
  `77946B927604C1CB0C8D7931BD8FFC167E299C858C35B97D548FC07F691E7170`.
- `CI_RELOCATABLE_TOOL_PATHS=PASSED` and the approved golden set remained
  read-only.

### Full renderer validation and smokes

- Full automation: `.godot/automation/20260902-212804Z`,
  `HOW_TO_GROW_AUTOMATION=PASSED`.
- Pixel report: `.godot/validation/20260902-212813Z/report.md`, result
  `PASSED`; all 34 active visual gates passed without changing references,
  crops, masks, or tolerances.
- Performance: CPU p95 9.544 ms, frame p95 16.747 ms, maximum 516 draw calls,
  91.42 MiB maximum reported static memory; all seven scenarios passed.
- Endurance: 48 cycles, seven disk save/load roundtrips, zero node/orphan/
  resource growth, +0.04 MiB static memory.
- Progression: 132 cycles, 27 save/load roundtrips, final level 90 and 11,260
  coins without a failed gate.
- Responsive matrix: 15/15 cases passed.

These are desktop/local technical gates. They do not replace touch comfort,
device heat/battery, notification delivery, save migration on the physical
phone, or human visual review.

## Android export from `R:`

The release source-only contract passed for package `com.howtogrow.game`,
version `0.69.0-rc59`, code 76, target SDK 36. After the SDK-path isolation fix,
a normal export invocation with no `-GodotPath` produced a disposable audit
APK:

- evidence: `.godot/android-export/20260902-213838Z`;
- APK: `.godot/relocation-audit/20260902-213837Z/relocation-patched-arm64-debug.apk`;
- size: 233,837,732 bytes (223.01 MiB);
- SHA-256: `A6C9FF61081372C4BF54DC81AFEE8E96320D8721741CAC9E37C85608F718763E`;
- signature v2, single ARM64 ABI, payload, manifest/permission contract,
  notification bridge, privacy-SDK allowlist, and 16KB alignment: all passed.

This ignored debug-signed file is relocation evidence, not another immutable
release candidate, and it was not installed on a phone.

No signed AAB was built because the existing-keystore path, alias, password,
and expected signer SHA-256 are not configured in the current environment. No
key was created, copied, or modified.

## Reproduction

From the new project root, no hard-coded drive argument is required:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\run_project_automation.ps1 -Mode Quick
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\run_project_automation.ps1 -Mode Full -PythonPath '<python-with-Pillow>'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\run_ci_validation.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\export_android.ps1 -ApkPath '<new-disposable-apk-path>'
```

Use `-GodotPath` or `HOW_TO_GROW_GODOT` only when Godot is not beside the
project and is not available in `PATH`.
