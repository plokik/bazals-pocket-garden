# Rendered whole-game UI audit, 2026-10-27

## Coverage and provenance

- Final merged matrix: `final/coverage.json`, 54 distinct UI states at logical 432x960, 360x640 and 600x900, with safe insets 12/24/14/32. All 162 expected panels were open and all 162 PNGs saved.
- `after` is the complete 162-state run. `tea-final` replaces 30 relevant tea states after the atlas texture-filter correction. `narrow-final` replaces the three diagnosis states after the missing-title correction. `narrow-shopfinal` replaces twelve shop states (4 categories/modes x 3 sizes) after the wallet natural-width correction. Every merged record identifies its capture run and original PNG. This is not a claim that all 162 snapshots came from one immutable source revision.
- Final runtime manifest: `shop-source-after.json`, SHA256 `0229c69840282161792875970adf5be7d506de6aba69a38b65eff9db552e258d`. All scripts and assets, including untracked runtime helpers, plus main.tscn/project.godot were hashed. Before/after the final shop capture the manifests match. The earlier tea-only manifest explicitly covered tracked files only.
- Both complete and targeted native Godot processes exited 0. Their logs have no SCRIPT ERROR, ERROR or native WARNING lines. This is a static UI audit, not a full regression suite result.

## Review artifacts

- Compact contact sheets: `final-contact-1.jpg` through `final-contact-4.jpg`.
- Standard and wide sheets: `final-432x960-contact-1.jpg` through 4, `final-600x900-contact-1.jpg` through 4.
- Six source before/after pairs: `review-01-guide.png`, `review-02-plant_detail.png`, `review-03-level_progression.png`, `review-04-botanical_pack.png`, `review-05-wheel.png`, `review-06-shop_sell.png`. `review-pairs.json` points to source screenshots. These are diagnostic review artifacts; approved references were not changed.
- `audit-open-issues.jpg` shows the four known compact-layout issue areas plus the map for context. The map column is a control view, not a newly asserted issue.

## Confirmed remaining issues

1. At 360x640 the lower greenhouse bed targets 3 and 4 overlap the status card. Rectangles: bed3 `(17.27,318.69,161.92,64)`, bed4 `(179.19,318.69,161.54,64)`. A distinct compact greenhouse arrangement is needed. All four targets do not overlap the status card at 432x960 or 600x900.
2. The film-style new-game handover scene at 360x640 still has long text behind the bottom buttons. The ordinary guide was fixed; the tutorial is a separate state and is not claimed fixed.
3. The custom drawn secondary caption `Proudění 58%` slightly clips on the right of the compact plant-care button. This skin-drawn text is not reported by ordinary Label geometry checks.
4. The compact workshop entry `PŘIPRAVIT SMĚS` remains small: actual button bounds 133.83x32.85 logical px, rendered caption about 6.69px. The RESET shortcut overlaps the right end of the workshop order sign.

No further confirmed missing titles or new clipping were found in a quick visual contact-sheet scan of all 432x960 and 600x900 states. Diagnosis title was separately rechecked in fresh full-size captures after its correction.

## Geometry candidates, not confirmed visible defects

The matrix contains 12 `label_outside_view` warnings, one selected-detail Label in each of the four greenhouse states at each size. Its internal rect is much taller than the visible two text rows. The visible rows fit the status card, so this is recorded separately from the real bed/status overlap and not asserted to be visible clipping. Controls behind modal overlays also occur in the inventory; visibility in the scene tree does not imply that they are actionable through the overlay. Expected clipped rows inside scroll containers are excluded from overflow warnings.

## Boundaries

- Fresh isolated fixtures wrote only under an APPDATA directory containing `full-game-audit-20261027`. Real saved games were not overwritten.
- Simulation is paused. Requested scroll positions were applied and shared feedback was explicitly finished after setup, preventing frozen route-transition stripes. These are settled still images, not acceptance of continuous animations.
- Minigame pouring/results are deterministic visual fixtures, not a claim that the whole action sequence was played in this harness.
- No Android native ad/file-picker surfaces, emulator/device rendering, physical phone, or platform permissions were audited by this desktop SubViewport harness.
- The legacy movable room-decoration slots are hidden/disabled by the current painted workshop and were explicitly marked unreachable rather than fabricated as player-accessible coverage.
- Production source, tests, and approved reference assets were not edited by the capture worker.
