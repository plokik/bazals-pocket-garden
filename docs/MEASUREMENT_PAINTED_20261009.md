# Approved painted measurement screen

The user approved the painted measurement layout on 2026-10-09, requesting one
remaining fix to the green live-value ribbon. The normal `main.tscn` startup now
installs `MeasurementScreenPresentation`; there is no player-facing preview switch.

The ribbon uses a separate sage panel with a continuous rounded outline, a 44px
minimum height, an internally centered label and an 8px gap before the care
summary. Its former shallow texture background compressed the sliced corners
until they joined badly. The source artwork is unchanged.

The presentation retains all ten live metric values, chart samples, the species
knowledge panel and mobile scrolling. Its advice comes from
`PlantDiagnosisService`, including night-time light policy and the empty/dead/
storage states. The Detail/Storage button uses the existing guarded action-button
factory and navigates without executing care or processing the harvest.

## Reference integrity and runtime evidence

Existing Phase 154 references, crops, masks and tolerances are immutable. The
capture helper explicitly selects the historical presentation for those original
filenames, then separately captures the normal current presentation as
`comic-measurement-painted-20261009.png`. This is an additional runtime artifact;
the existing Phase 154 gate does not certify the new layout. No old reference was
replaced and no threshold was relaxed.

`tests/measurement_presentation_test.gd` covers normal startup, live data/advice,
unchanged plant/economy/history, ribbon geometry, exact destination selection,
night and empty states, drying storage navigation and reversible historical
capture mode. The local regression suite passed 6,905 checks. Focused GPU captures
also passed at 432×960 and 360×800 under an isolated profile with saves blocked.

Local artifacts: `.godot/measurement-ribbon-20261009/`. Physical-phone testing is
still postponed; this change creates no release.
