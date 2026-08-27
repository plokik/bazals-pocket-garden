# Fáze 145 — vrstvené detaily Pokoje

Stav implementace: `PHASE145_LAYERED_ROOM_DETAILS=IMPLEMENTED`

Technická validace: `PHASE145_TECHNICAL_VALIDATION=PASSED`

Skutečný Godot render: `PHASE145_GODOT_RENDER_ACCEPTANCE=PENDING`

Mobilní přijetí: `PHASE145_MOBILE_ACCEPTANCE=DEFERRED_PHONE_UNAVAILABLE`

Android artefakt: `PHASE145_APK=NOT_CREATED`

Publikování: `PHASE145_PUBLISHING=OUT_OF_SCOPE_BY_USER`

## Rozsah

Fáze řeší pouze pravou spodní část obrazovky `POKOJ`. Obrazovka `ROSTLINY`,
schválených dvanáct rostlin stojanu, skleník, ekonomika a save zůstávají
beze změny. Immutable RC55 se nepřepisuje a telefon není pro tuto fázi potřeba.

Původní hladké Phase 140 assety se nepřemalovávají:

- `room_cat_bed_phase140_v1.png` — SHA-256
  `7F0959178DFD1F7FE96026F35087DB5F269A51CD852CAD29B1E182D9420BC84D`;
- `room_nested_pots_phase140_v1.png` — SHA-256
  `94E63A5591A17EE4E35F61F02959AA5A1D3115C4FFEDA84A190A54E95D10D54D`.

Jejich problém nebyla kvalita samotné malby, ale chybějící kontakt s policí a
podlahou. Runtime proto používá pro každý opravený detail samostatné vrstvy:

1. měkký kontaktní stín za předmětem;
2. hladký RGBA sprite předmětu;
3. přední hranu police nebo samostatnou přední vrstvu misek.

## Kočičí koutek

Existující nákup `cat_corner` zůstává jedinou kosmetickou položkou ve skupině
`pet_corner`. Pelíšek má podlahový stín a před ním leží společná vrstva dvou
stejně velkých keramických misek: tyrkysová s vodou a oranžová s krmivem.
Samotný mazlíček ani péče nejsou aktivní a nevzniká nový save klíč.

Zdroj misek je
`assets/ui/visual/phase145/source/room_pet_bowls_chroma_v1.png` se SHA-256
`34D31E01E6550B9FE8DB6C53BC35AFE4D0EC63ECCFDC35739FFE2C9312D0398E`.
Reprodukovatelný Godot nástroj `tools/extract_phase145_room_details.gd` z něj
odstraní pouze propojené zelené pozadí a spill na antialiasované hraně. Runtime
vrstva `room_pet_bowls_layer_v1.png` má 1307 × 447 RGBA a SHA-256
`D489A0C22470E1C691245BEC4039D7FD2D44697982B247717871E11D9A2F3CCF`.

## Vnořené květináče

Květináče zůstávají jedním samostatným zakoupitelným předmětem na spodní polici
komody. Jejich profil má o něco čitelnější stopu, pod objektem je kontaktní stín
a přes spodní hranu se kreslí jemná přední okluze police. Výsledkem má být
předmět skutečně položený na dřevě, ne nalepený obrázek.

## Hranice přijetí

Capture `comic-phase145-player-room-layered-details.png` je nový report-only
Godot render. Úplná validation `.godot/validation/20260824-072859Z` prošla s
`MVP_TESTS_PASSED=1472`, `HOW_TO_GROW_CAPTURE=PASSED`,
`HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Všech čtrnáct
dříve schválených obrazových bran zůstalo zelených bez změny referencí nebo
tolerancí. Responsive `.godot/responsive/20260824-073137Z` prošel 9/9 případů
včetně 360 × 800. Visual contract
`.godot/visual-contract/20260824-073157Z` eviduje 345 profilovaných PNG,
0 neprofilovaných a 131 runtime PNG. Závěrečná Quick automatizace
`.godot/automation/20260824-073738Z` skončila
`HOW_TO_GROW_AUTOMATION=PASSED`, technicky `PASSED`, bez zařízení a bez
publikačního kroku.

Technická brána je proto `PASSED`, ale vzhled skutečného Godot renderu zůstává
`PENDING`, dokud jej neposoudí uživatel. Mobilní kontrola je výslovně odložená,
protože telefon nyní není k dispozici; nevzniká APK ani release.
