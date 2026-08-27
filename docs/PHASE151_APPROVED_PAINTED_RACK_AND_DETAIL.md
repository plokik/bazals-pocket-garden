# Fáze 151 — schválený malovaný stojan a detail

PHASE151_SOURCE_ACCEPTANCE=APPROVED_BY_USER
PHASE151_PREVIEW_ACCEPTANCE=APPROVED_BY_USER
PHASE151_TECHNICAL_VALIDATION=PASSED_FUNCTIONAL_AND_RESPONSIVE
PHASE151_GODOT_RENDER_ACCEPTANCE=PASSED_USER_APPROVED
PHASE151_USER_VISUAL_ACCEPTANCE=PASSED_USER_APPROVED_20260825
PHASE151_VISUAL_BASELINE_TRANSITION=PASSED_APPEND_ONLY
PHASE151_STRICT_VISUAL_GATE=PASSED
PHASE151_MOBILE_ACCEPTANCE=DEFERRED_PHONE_UNAVAILABLE
PHASE151_APK=NOT_CREATED
PHASE151_PUBLISHING=OUT_OF_SCOPE

## Závazné reference

- Stojan: `docs/visual-proposals/phase151/user-approved-painted-rack-screen-v1.png`
  - SHA-256: `7540369AD83E2DCB0A707052C649E8C0E919D621086B970985EA891EFF02697C`
- Detail: `docs/visual-proposals/phase151/user-approved-painted-detail-screen-v1.png`
  - SHA-256: `599283F38AFD50CFC6D121613F9687E15707CDF56ED1DE6FE743765727BCAFDE`

Reference určují malbu, měřítko, materiály, usazení květináčů, zámky a světlo. Nejsou runtime obrazovkou: obsahují zapečené hodnoty jednoho konkrétního stavu.

## Runtime kontrakt

- zachovat přesně deset slotů ve mřížce 2 × 5;
- zachovat všech 11 druhů a šest stavů každého druhu;
- zachovat dynamické popisky, stavové ikony, úrovně zámků, světla, animace, výběr, swipe a všechny akce;
- nepřenášet z reference zapečené mince, úroveň, růst ani obsah slotů;
- používat společnou polici, baseline, podmisku a kontaktní stín;
- fialový zámek je samostatný průhledný malovaný asset bez zapečeného textu úrovně;
- zdrojové PNG rostlin zůstávají byte-exact; mění se pouze Godot import sidecary na lineární filtrování s mipmapami.

Deterministická evidence je v `assets/ui/visual/phase151/rack/phase151_runtime_manifest.json`.

## Hranice přijetí

Technický PASS nebyl zaměněn za lidské přijetí. Uživatel nejprve schválil
návrhové reference a dne 2026-08-25 následně výslovně schválil i skutečné
Godot rendery Stojanu, Detailu a Skladu. Mobilní přijetí a APK zůstávají
odděleně odložené, protože telefon není dostupný.

## Aktuální důkazy

- úplná funkční regrese: `MVP_TESTS_PASSED=1502`;
- finální přesná validace: `.godot/validation/20260825-102405Z`;
- skutečný stojan: `comic-rack-greenhouse-attention.png`;
- skutečný detail: `comic-detail-idle.png`;
- responzivní matice: `.godot/responsive/20260825-095148Z`, `9/9 PASSED`.
- závěrečný Quick: `.godot/automation/20260825-095505Z`, `HOW_TO_GROW_AUTOMATION=PASSED`.

Závěrečný přesný běh `.godot/validation/20260825-102405Z` potvrdil
`MVP_TESTS_PASSED=1502`, `HOW_TO_GROW_CAPTURE=PASSED`,
`HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Pro pět
historických kompozitních případů vznikly nové verzované Phase151 reference;
původní Phase6, Phase7 a Phase89 PNG zůstaly zachované. Tři nové přesné runtime
brány `phase151-rack-runtime-approved`, `phase151-detail-runtime-approved` a
`phase152-storage-runtime-approved` prošly s nulovou odchylkou. Návrhové
koncepty zůstávají report-only, protože obsahují zapečený konkrétní herní stav.
