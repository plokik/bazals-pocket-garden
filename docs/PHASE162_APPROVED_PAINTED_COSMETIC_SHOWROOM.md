# Fáze 162 — schválený malovaný Kosmetický showroom

`PHASE162_SOURCE_ACCEPTANCE=APPROVED_BY_USER`

`PHASE162_IMPLEMENTATION=IMPLEMENTED_DYNAMIC_RUNTIME`

`PHASE162_TECHNICAL_VALIDATION=PASSED`

`PHASE162_TEST_COUNT=1548_PASSED`

`PHASE162_RESPONSIVE_VALIDATION=PASSED_15_OF_15`

`PHASE162_QUICK_AUTOMATION=PASSED`

`PHASE162_GODOT_RENDER_ACCEPTANCE=APPROVED_BY_USER`

`PHASE162_USER_VISUAL_ACCEPTANCE=APPROVED_BY_USER`

`PHASE162_VISUAL_BASELINE_TRANSITION=PASSED_APPEND_ONLY_RUNTIME_GATE`

`PHASE162_MOBILE_ACCEPTANCE=DEFERRED_PHONE_UNAVAILABLE`

`PHASE162_APK=NOT_CREATED`

`PHASE162_PUBLISHING=OUT_OF_SCOPE`

`PHASE162_SAVE_SCHEMA=41_UNCHANGED`

`PHASE162_RC57=IMMUTABLE`

## Schválený výtvarný cíl

Uživatel schválil malovaný návrh Kosmetického showroomu se čtyřmi výraznými
náhledy pokojů, dřevěným botanickým rámem, pergamenovými informačními plochami
a integrovanými zelenými akčními tlačítky. Přesná append-only kopie je
`docs/visual-proposals/phase162/user-approved-painted-cosmetic-showroom-v1.png`
o rozměru 841 × 1870 a SHA-256
`BC524F1D2C3111630385256481A4ACB04CC51D99C2E4CF342D7FA468C3FC5DC0`.

Schválení platí pro výtvarný koncept. Náhled obsahuje konkrétní texty, ceny,
stav peněženky a stav odemčení, proto zůstává pouze report-only cílem. Nesmí se
použít jako jediný zapečený runtime obraz ani jako tvrdá reference před
samostatným schválením skutečného Godot renderu.

## Čistý runtime plate a živé vrstvy

Godot používá samostatný čistý malovaný plate
`assets/ui/visual/phase162/cosmetic_showroom/cosmetic_showroom_clean_backdrop_v1.png`
o rozměru 841 × 1871 a SHA-256
`A696D1759EF1FE830984E0DC2C8C292FCEDC3B9B4CFEB55DBCB7E2849542FCF6`.
Plate zachovává dřevěný rám, čtyři pokojové miniatury, pergamen a prázdné
malované plochy tlačítek, ale neobsahuje zapečené názvy, ceny, mince, ikony ani
stavové texty.

Runtime nad plate skládá živé Godot uzly:

- nadpis, úvod, názvy a popisy všech čtyř vzhledů jako dynamické `Label`;
- skutečná tlačítka pro výběr, použití a odemčení vzhledu;
- živý stav peněženky a pravdivý počet odemčených vzhledů;
- oddělené stavy právě používaného, odemčeného, nedostupného kvůli mincím a
  zamčeného výzkumem;
- skutečné tlačítko `HOTOVO` a zachovaný mobilní svislý scroll;
- celoplošnou vstup blokující vrstvu nad živým Pokojem.

Pořadí zůstává `sunrise`, `lagoon`, `amethyst` a `research_study`. Presenter je
nadále jediným zdrojem cen, dostupnosti, výzkumného postupu, vybraného vzhledu a
textu akce. `Badatelská pracovna` proto stále vyžaduje šest dokončených
Profesorových protokolů a její existující cena i pravidla se nemění.

## Rozsah beze změny

Fáze 162 mění pouze prezentaci existujícího Kosmetického showroomu. Nemění
žádnou ekonomickou hodnotu, herní bonus, podmínku odemčení, obsah pokojových
vzhledů, save migraci ani save schema 41. Nevytváří nový druh měny, entitlement
ani další placenou položku. Immutable RC57 a jeho APK se nepřepisují.

## Ověření a pravdivé brány

Schválený koncept zůstává ve vizuální sadě pouze report-only (`gate=false`).
Uživatel 26. srpna 2026 výslovně schválil skutečný Godot render
`comic-phase162-cosmetic-showroom-selected.png`. Jeho byte-exact append-only
kopie `assets/ui/comic/reference_phase162_cosmetic_showroom_runtime_v1.png` má
SHA-256 `DFCC10B8B1B89F6D637100E6C781B6D9097976F0A9600E8B093E5665430EFE18` a
případ `phase162-cosmetic-showroom-runtime-approved` ji chrání jako 23. tvrdou
bránu bez cropu a masek. Úplná validation po povýšení baseline
`.godot/validation/20260826-153955Z` prošla 1 548/1 548 kontrolami a markery
`PHASE162_COSMETIC_SHOWROOM_CAPTURE=PASSED`, `HOW_TO_GROW_CAPTURE=PASSED`,
`HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Nový runtime
případ dosáhl přesné shody MAE 0, RMSE 0 a 0 % změněných pixelů. Responsive
audit `.godot/responsive/20260826-151922Z` prošel 15/15 a závěrečná Quick
automatizace `.godot/automation/20260826-154305Z` skončila
`HOW_TO_GROW_AUTOMATION=PASSED`. Čtyři cílené stavové rendery jsou také v
`.godot/phase162-only/20260826-171948Z`.

Technický PASS a výslovné uživatelské schválení jsou doloženy odděleně. Telefon
není k dispozici, mobilní audit je odložený, nové APK nevzniklo, nic se
nepublikuje a immutable RC57 zůstává zachované.
