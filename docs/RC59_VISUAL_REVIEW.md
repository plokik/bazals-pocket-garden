# RC59 visual review gate

Date: 2026-08-30

Fresh deterministic validation output: `.godot/validation/20260830-123617Z`

## Initial technical result

- GDScript regression suite: `MVP_TESTS_PASSED=6745`
- Capture run: passed
- Visual cases passed: 24/34
- Visual cases awaiting a decision: 10/34
- Initial overall visual gate: failed until all ten cases were explicitly resolved

No approved reference, crop, mask, tolerance or threshold has been changed. The ten comparisons are presented as `Reference | Current | Diff`; the diff itself is evidence, not permission to update a baseline.

## Review group A - plant detail and feedback

The current rendering contains the later Phase172 grounding and scale work: a larger plant, a corrected saucer and a different base line on the sill. The older reference is visibly smaller and differently grounded. User judgment is required before treating the current rendering as the new approved target.

| Case | MAE | RMSE | Changed pixels |
| --- | ---: | ---: | ---: |
| `detail-realtime` | 15.696 | 46.877 | 18.652% |
| `feedback-water` | 15.667 | 46.834 | 18.645% |
| `feedback-growth` | 15.567 | 46.660 | 18.591% |
| `phase151-detail-runtime-approved` | 16.329 | 47.793 | 19.056% |

## Review group B - Professor modal

The Professor states are drawn over a newer rack and compact dock. Most of the changed area is the underlying scene, but the final modal geometry and character placement must still be accepted visually rather than inferred from the test name.

| Case | MAE | RMSE | Changed pixels |
| --- | ---: | ---: | ---: |
| `guide-explain` | 3.623 | 8.226 | 17.963% |
| `guide-celebrate` | 3.333 | 7.814 | 16.468% |
| `guide-warning` | 3.556 | 8.117 | 17.666% |

## Review group C - rack and full-screen effects

The current rendering contains the later Phase171 rack grounding and Phase183 compact four-button dock. The `feedback-unlock` and `screen-transition` overlays remain visible in both versions while the rack beneath them changes. The static rack case also changes substantially and therefore needs the same explicit judgment.

| Case | MAE | RMSE | Changed pixels |
| --- | ---: | ---: | ---: |
| `phase163-rack-runtime-approved` | 33.646 | 60.998 | 57.532% |
| `phase163-feedback-unlock-runtime-approved` | 30.301 | 54.767 | 58.761% |
| `phase163-screen-transition-runtime-approved` | 28.080 | 51.184 | 57.075% |

## User decision

The three labeled montages were presented as Reference, Current and Diff. On
2026-08-30 the user replied `Souhlasím`, accepting groups A, B and C as the
current RC59 source of truth.

The exact review images and hashes are recorded in
`docs/visual-proposals/phase184/runtime-reference-approval-v1.json`. Ten new
append-only Phase184 PNG references were copied byte-for-byte from the actual
GPU captures of the initial validation run. Historical Phase74, Phase151 and
Phase163 references were not overwritten or deleted. Capture state, dimensions,
crops, masks, tolerance and thresholds were not relaxed.

## Post-approval validation

Fresh validation output: `.godot/validation/20260830-134800Z`

- `MVP_TESTS_PASSED=6745`
- `HOW_TO_GROW_CAPTURE=PASSED`
- active visual gates: 34/34 passed
- all ten Phase184 transitions: exact 0.000 MAE, 0.000 RMSE and 0.000% changed pixels
- `HOW_TO_GROW_VISUALS=PASSED`
- `HOW_TO_GROW_VALIDATION=PASSED`

The visual contract is therefore closed for the current RC59 source baseline.
This is source-level visual acceptance, not physical Android acceptance.
