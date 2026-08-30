# RC59 preflight

Audit date: 2026-08-30 (Europe/Prague)

## Verdict

`RC59_PREFLIGHT=PASSED_WITH_SANITIZATION_AND_VISUAL_APPROVAL_BLOCKERS`

The authoritative checkout is `C:\_projekty\How to grow_`. The original RC58 commit and immutable artifacts remain unchanged. No stash, reset, clean, destructive checkout, history rewrite, push, phone installation, signing-key creation, or Google Play upload was performed.

## Protected Git state

- Working branch: `release/rc59-prep`
- Branch base and unchanged HEAD: `5ae1f0d7b7043260ed265c8363314217994ba3f9`
- Exact base tag: `v0.68.0-rc58`
- `master` remains at the same RC58 commit.
- Repository is not shallow and `git fsck --no-dangling --no-reflogs` passed.
- No Git remotes are configured.
- Tags found: `v0.45.0-rc29`, `v0.50.0-rc36`, `phase164-source-baseline`, `v0.68.0-rc58`.

The pre-RC59 snapshot contained:

- 22 modified tracked files;
- 260 untracked files;
- 0 staged, deleted, renamed, or conflicted files;
- tracked diff of 3,008 insertions and 563 deletions;
- `git diff --check` PASS.

The source still identifies itself as `0.68.0-rc58`, Android version code 75, and save schema 41. Version identity is deliberately unchanged until the source and visual gates are closed.

## Untracked inventory summary

| Category | Files | Size |
| --- | ---: | ---: |
| Runtime-referenced source and sidecars | 54 | 9.83 MiB |
| Tests and versioned visual references | 63 | 13.73 MiB |
| Documentation and visual evidence | 115 | 89.37 MiB |
| Source artwork and deterministic builders | 28 | 1.75 MiB |
| Build, cache, duplicate-only, or unclear | 0 | 0 B |
| **Total** | **260** | **114.68 MiB** |

All 82 untracked PNG files have their Godot `.import` sidecars and all 34 untracked GDScript files have `.uid` sidecars. These sidecars follow the established repository convention and are not disposable cache.

The full file-level classification is recorded in `docs/RC59_ASSET_INVENTORY.csv` and explained in `docs/RC59_ASSET_INVENTORY.md`.

## Sensitive and local data audit

No keystore, private key, release password, API token, JWT, email address, unignored APK/AAB, archive, or `local.properties` file was found in the candidate source set.

Four inherited public-hygiene findings were sanitized in the RC59 working tree:

- the personal Codex Python path was removed from the defaults in `tools/run_project_automation.ps1` and `tools/run_release_candidate.ps1`; callers can pass `-PythonPath`, while the validation runner retains its neutral resolver;
- the physical device serial was replaced by `REDACTED` in `docs/PHASE127_FINAL_VISUAL_SYSTEM.md` and `docs/PHASE138_RC54_ANDROID_HANDOFF.md`;
- `.gitignore` now also excludes `.env`, `.env.*`, `*.pem`, `*.key`, and `*.pfx`.

The historical RC58 commit still contains the two historical serial/path strings. History was not rewritten. A future public repository should therefore be created from a clean sanitized snapshot unless the user separately authorizes a history-cleaning plan.

## Ignored local data

The following local areas are intentionally outside the baseline and were not deleted:

| Area | Approximate physical size |
| --- | ---: |
| `.godot` | 16.2 GiB |
| `builds` | 4.42 GiB |
| `.tooling` | 2.59 GiB |
| generated Android tree | 1.61 GiB |
| `.idea` | 0.14 MiB |

`.godot/validation` contains active and historical evidence. Cleanup or relocation requires a separate exact protected-evidence inventory and is not part of this preflight.

## RC58 integrity

Protected immutable APK:

- Path: `builds/android/bazals-pocket-garden-0.68.0-rc58-arm64-debug.apk`
- Size: 224,368,317 bytes
- SHA-256: `0A7F173D8C97B552168A407C31F1F8AE85109A34C2F6F4786029551064F0C6F5`

The mutable general alias remains byte-identical. Neither file was opened for writing.

## Android configuration snapshot

- Godot 4.7 stable, GL Compatibility, portrait application.
- Package: `com.howtogrow.game`.
- minSdk 24, target/compile SDK 36.
- ARM64 APK/AAB presets and a separate x86_64 emulator preset.
- Immersive and edge-to-edge enabled.
- `POST_NOTIFICATIONS` and `RECEIVE_BOOT_COMPLETED` only.
- No `INTERNET`, broad storage, or exact-alarm permission.
- Care reminders use `setAndAllowWhileIdle`, not an exact alarm.
- Backup import/export uses the system document picker.
- Release/upload keystore is not present in the repository.

The current export uses `all_resources` plus explicit exclusions. Asset inventory found a proven source-only leak at `assets/ui/visual/phase167/**`; the export filter must be changed and validated before RC59 artifacts are created.

## Fresh baseline validation

Fresh artifacts: `.godot/validation/20260830-123617Z`

- Pillow preflight: PASS.
- Godot regression suite: `MVP_TESTS_PASSED=6745`.
- Deterministic capture: `HOW_TO_GROW_CAPTURE=PASSED`.
- Hard visual gates: 24/34 PASS, 10/34 FAILED.
- Overall visual validation: FAILED as expected.

The ten failures exactly reproduce the known pre-existing visual-approval boundary. No golden reference, threshold, crop, or mask was changed. They must be reviewed by the user before RC59 can proceed to 34/34.

## Remaining blockers after preflight

1. User decision for the ten current visual comparisons.
2. Verified export pruning and a measured ARM64 APK/AAB size audit.
3. RC59 version bump only after the baseline content is committed coherently.
4. Existing external upload key or explicit user decision about key creation.
5. Full automated release run and one separate physical Android human batch.

