# Phase184 — RC59 visual baseline

## Status

```text
PHASE184_USER_VISUAL_ACCEPTANCE=APPROVED_BY_USER
PHASE184_REFERENCE_POLICY=APPEND_ONLY
PHASE184_REFERENCE_COUNT=10
PHASE184_ACTIVE_VISUAL_GATES=34
PHASE184_VISUAL_GATE=PASSED_34_OF_34
PHASE184_MVP_TESTS_PASSED=6745
PHASE184_ANDROID_ACCEPTANCE=NOT_RUN_SOURCE_ONLY
PHASE184_PUBLISHING=NOT_REQUESTED
```

## Scope

Phase184 closes the ten differences left after phases 166–183 without changing
runtime behavior or regenerating approved art. The user reviewed three labeled
montages containing Reference, Current and Diff and approved all groups on
2026-08-30 with the message `Souhlasím`.

- Group A: current plant detail, saucer/sill grounding, watering feedback and
  growth feedback.
- Group B: three Professor Bazal states over the current rack and compact dock.
- Group C: current rack, unlock feedback and cyan-gold screen transition.

The approval is recorded in
`visual-proposals/phase184/runtime-reference-approval-v1.json`, including the
three review-image hashes, every source capture, every new reference hash and
the preserved historical reference hash.

## Append-only transition

Ten `reference_phase184_*_v1.png` files are byte-for-byte copies of actual
432×960 GPU captures from `.godot/validation/20260830-123617Z`. Existing
Phase74, Phase151 and Phase163 reference files remain untouched. No crop, mask,
pixel tolerance or threshold was changed to obtain a pass.

The active case IDs remain stable, but now point to the versioned Phase184
files and share the Phase184 approval record. This preserves downstream tooling
while keeping every older PNG available for historical comparison.

## Verification

The complete How to grow validation skill was run again after the transition:

- output: `.godot/validation/20260830-134800Z`;
- Pillow preflight passed;
- `MVP_TESTS_PASSED=6745`;
- deterministic GPU capture passed;
- all 34 active visual gates passed;
- each of the ten transitioned cases matched its approved reference exactly;
- final marker: `HOW_TO_GROW_VALIDATION=PASSED`.

Automated and user source-level visual acceptance are complete. Emulator and
physical-phone acceptance remain separate Android gates.
