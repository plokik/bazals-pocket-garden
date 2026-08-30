# RC59 Android size audit

Date: 2026-08-30

This audit measures one exact, low-risk export exclusion before RC59. It does not delete source assets, change the save schema, replace RC58, create a release signing key, publish to Google Play, or install anything on a phone.

## Immutable baseline

- RC58 ARM64 debug APK: `builds/android/bazals-pocket-garden-0.68.0-rc58-arm64-debug.apk`
- Size: 224,368,317 bytes (213.97 MiB)
- SHA-256: `0A7F173D8C97B552168A407C31F1F8AE85109A34C2F6F4786029551064F0C6F5`
- State after this audit: unchanged

RC58 package composition measured during the audit:

- imported CTEX payload: 142,821,696 compressed bytes (136.21 MiB), 284 entries;
- native libraries: 77,592,248 compressed bytes;
- DEX: 2,353,108 compressed bytes.

## Exact Phase167 exclusion

`assets/ui/visual/phase167/**` is a deterministic source/intermediate family used to produce the newer Phase169 runtime assets. The game loads the Phase169 results; the Phase167 intermediate family was nevertheless included by `all_resources`.

The following exact filter was added to all three Android presets:

```text
assets/ui/visual/phase167/**
```

No Phase169, Phase170, Phase171 or Phase183 family was excluded.

### Reproducible x86_64 comparison

- Before: `.godot/emulator-preview/20260829-221017Z/bazals-pocket-garden-phase183-emulator-x86_64-debug.apk`
  - 240,853,270 bytes (229.70 MiB)
  - SHA-256: `0A4CD44CEBDD85B82BE101420E9F327E625273CA03772D42FEFC98F25A112834`
- After: `.godot/rc59-size-audit/20260830-phase167-exclusion/bazals-pocket-garden-current-x86_64-debug.apk`
  - 238,752,947 bytes (227.69 MiB)
  - SHA-256: `CBD56B8CAEA623A048CDBDD4FFF8E87924481E5968BD3D2304D5AEFC7B2783DD`
- Exact reduction: 2,100,323 bytes (approximately 2.00 MiB, 0.872%)
- Removed package entries: 25
  - 12 Phase167 CTEX entries;
  - 12 associated import metadata entries;
  - one Phase167 manifest entry.
- Removed compressed payload: 2,092,178 bytes
- Removed uncompressed payload: 2,099,815 bytes

### Current ARM64 audit export

- Path: `.godot/rc59-size-audit/20260830-phase167-exclusion/bazals-pocket-garden-current-arm64-debug.apk`
- Size: 233,835,901 bytes (223.00 MiB)
- SHA-256: `4CC735FA8470432EE3E7CA32EDD483EDFA17432DD067613F3E0CFBCF0213CADC`
- Payload scan: passed
- APK signature check: passed
- Notification implementation check: passed

This is a temporary technical audit build, not RC59 and not an immutable release artifact.

## Remaining size profile

The current Phase183 x86_64 APK before this exclusion contained:

- imported CTEX payload: 154,318,712 compressed bytes across 314 entries;
- native libraries: 82,505,208 compressed bytes.

The source tree contains 485 PNG files totaling approximately 360.82 MiB. A conservative static inventory suggests that a substantially larger reduction may be possible by excluding older historical and QA-only image families, but the earlier estimate of roughly 73 MiB is not a measured release result. Each additional family must be proven unreachable from runtime code and data, exported as an isolated batch, and followed by the complete deterministic and visual gates.

## Decision

- Exact Phase167 exclusion: technically passed and retained.
- Broad asset deletion: not performed.
- Transition to `selected_resources`: not performed.
- Google Play AAB size: pending an actual signed or locally test-signed AAB.
- RC59 size target: not yet closed.
