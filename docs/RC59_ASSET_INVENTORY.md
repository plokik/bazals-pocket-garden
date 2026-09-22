# RC59 asset inventory

> **HISTORICKÝ SNAPSHOT.** Tento inventář klasifikuje 260 tehdy nových souborů ke dni 2026-08-30. Po commitu už jeho hodnoty `git_state=untracked` nejsou aktuální a dokument nepokrývá celý dnešní projekt. Úplný audit z 2026-09-06 je v `docs/audit/20260906_ASSET_INVENTORY.csv` a `docs/audit/20260906_AUDIT_REPORT.md`.

Snapshot date: 2026-08-30 (Europe/Prague)

Machine-readable inventory: [historical CSV](audit/history/RC59_ASSET_INVENTORY.csv). Its bytes are preserved; `docs/audit/.gdignore` keeps audit tables out of Godot's translation importer.

## Boundary and method

This inventory covers the 260 files that were untracked at the beginning of RC59 preparation. RC59 reports generated afterwards are intentionally not counted in their own source snapshot.

Classification was verified with Git, `rg`, GDScript `preload/load` and literal `res://` paths, JSON and visual manifests, validation cases, deterministic generation scripts, and actual APK import mappings. No file was classified only from its name. No source, evidence, reference, cache, or historical artifact was deleted or moved.

## Classification

| Primary category | Files | Bytes | MiB | Git action | Export action |
| --- | ---: | ---: | ---: | --- | --- |
| Runtime referenced | 54 | 10,306,566 | 9.83 | Keep | Include |
| Tests and versioned references | 63 | 14,400,098 | 13.73 | Keep | Already excluded |
| Documentation and visual evidence | 115 | 93,714,781 | 89.37 | Keep | Already excluded |
| Source artwork and builders | 28 | 1,831,663 | 1.75 | Keep | Exclude source family |
| Build, cache, duplicate-only, or unclear | 0 | 0 | 0 | — | — |
| **Total** | **260** | **120,253,108** | **114.68** |  |  |

Every row includes SHA-256, byte size, lifecycle, reference evidence, current filter match, proposed export action, sidecar relationship, duplicate group, and evidence protection status.

## Runtime closure

The 54 runtime files are:

- 18 PNG files with 18 `.import` sidecars;
- 8 GDScript files with 8 `.uid` sidecars;
- the Phase169 plant-edge provenance manifest;
- the Phase170 rack-saucer runtime manifest.

Current runtime families that must remain packaged:

- `assets/ui/visual/phase169/**`: twelve cleaned room plants loaded through the visual system and manifest-driven family;
- `assets/ui/visual/phase170/**`: current ceramic saucer and runtime manifest;
- `assets/ui/visual/phase171/**`: current painted plant rack;
- `assets/ui/visual/phase183/**`: current compact dock icons and painted floor extension;
- all eight new UI controllers/helpers under `scripts/ui`.

These families must not be removed by a broad phase-number or visual-directory exclusion.

## Source artwork boundary

`assets/ui/visual/phase167/**` is the deterministic intermediate source used to produce the Phase169 cleaned runtime plants. The runtime `VisualDesignSystem` loads Phase169, not Phase167.

The Phase167 family currently leaks into Android because all three presets use `export_filter="all_resources"`. Direct inspection of the current Phase183 APK found its Phase167 imported payload at 2,092,178 compressed bytes.

The minimum safe export-filter change is therefore:

```text
assets/ui/visual/phase167/**
```

The three deterministic builder scripts remain versioned under `tools/**` and are already excluded from Android export.

## Tests, references, and evidence

The 63 test/reference files contain:

- five Phase167 approved golden PNG files with their `.import` sidecars;
- the Phase167 approval metadata;
- fourteen new regression tests with `.uid` sidecars;
- twelve focused capture tools with `.uid` sidecars.

The 115 documentation files contain eighteen phase reports and ninety-seven visual/evidence files after the Phase167 approval metadata is classified with its golden references. `docs/**`, `tests/**`, `tools/**`, and `assets/ui/comic/**` are already excluded from Android export.

The evidence PNG files account for most of the untracked source size but are append-only audit material. They should be committed separately from runtime code so that future evidence retention or relocation can be decided without obscuring the source baseline. No support folder outside the project has been designated, so no move is proposed without user approval.

## Duplicate review

These three approved golden PNG files are byte-identical:

- `reference_phase167_player_room_clean_floor_runtime_v1.png`
- `reference_phase167_player_room_full_runtime_v1.png`
- `reference_phase167_player_room_full_cloche_runtime_v1.png`

Shared SHA-256:

`2B2FBC2F6CD44C7F94831E6C91C6CD2C5AD8336C25A7A3FC2E8677A5F7DBA40B`

They remain separate semantic validation IDs. They must not be removed, hard-linked, or silently replaced merely because their current pixels match. Git will deduplicate the blob internally.

## APK size evidence

Current Phase183 x86_64 preview:

- total APK: 240,853,270 bytes;
- 313 mapped PNG imports: 154,317,129 compressed bytes;
- conservative runtime closure: 156 PNG imports, 77,735,830 compressed bytes;
- 157 additional `all_resources` PNG imports: 76,581,299 compressed bytes.

A pure arithmetic projection after excluding all 157 extras is approximately 156.66 MiB for the x86_64 preview. This is **not** a verified build result. Some dynamically formatted or data-driven paths cannot be excluded until the dependency and payload scanners explicitly prove their coverage.

The safe strategy for RC59 is:

1. keep `all_resources`;
2. add exact, evidence-backed exclusions in small batches;
3. extend payload checks to reject forbidden source/historical families;
4. export and run the application after every batch;
5. consider a selected-resources whitelist only after dynamic JSON and formatted Phase169 paths have dedicated coverage.

## Large local data outside the candidate set

Files at least 1 MiB total approximately 22.62 GB. The largest groups are generated or ignored:

| Area | Large-file payload |
| --- | ---: |
| `.godot` generated evidence/cache | 12,796.42 MiB |
| `builds` immutable/historical artifacts | 4,520.86 MiB |
| `.tooling` local toolchain | 2,352.05 MiB |
| generated Android tree | 1,453.87 MiB |
| tracked runtime/source assets | 264.21 MiB |
| untracked documentation evidence | 87.31 MiB |

No untracked APK, AAB, ZIP, PSD, keystore, private key, or archive was found. No cleanup is authorized by this inventory.

## Verdict

`RC59_ASSET_INVENTORY=PASSED_NO_UNCLEAR_FILES`

Baseline inclusion is safe after the Phase167 export exclusion is implemented and validated. Visual golden references remain blocked on the separate user approval gate.
