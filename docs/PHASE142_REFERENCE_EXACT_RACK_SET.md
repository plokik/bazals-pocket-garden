# Fáze 142 — věrná referenční sada stojanu

Stav implementace: `PHASE142_REFERENCE_EXACT_RACK_SET=IMPLEMENTED`

Věrnost zdroji: `PHASE142_SOURCE_FIDELITY=APPROVED_REFERENCE_RGB`

Technická validace: `PHASE142_TECHNICAL_VALIDATION=PASSED`

Skutečný Godot render: `PHASE142_GODOT_RENDER_ACCEPTANCE=PENDING`

Mobilní přijetí: `PHASE142_MOBILE_ACCEPTANCE=PENDING`

Publikování: `OUT_OF_SCOPE_BY_USER`

## Závazný vizuální cíl

Uživatel po porovnání Phase 141 výslovně požadoval skutečně věrnou shodu s
odsouhlaseným celým Pokojem. Závazná předloha je verzovaná v
`assets/ui/visual/phase142/source/player_room_rack_approved_reference_v1.png`.
Phase 142 proto nepoužívá nově namalované podobné rostliny: barevné RGB pixely
všech dvanácti runtime vrstev pocházejí přímo z této předlohy.

## Reprodukční postup

- ImageGen vytvořil samostatnou prázdnou vrstvu stojanu a černobílou
  segmentační masku. Tyto dvě vrstvy slouží pouze k oddělení popředí a nejsou
  považované za zdroj kresby rostlin.
- `tools/extract_phase142_reference_plants.gd` vezme RGB výhradně ze schválené
  předlohy, z masky převezme pouze alfa kanál, vyplní uzavřené falešné mezery a
  uloží dvanáct samostatných transparentních PNG.
- Předloha, prázdná vrstva, maska, aktivní podklad i všechny runtime vrstvy jsou
  nové verzované soubory. Phase 139 a Phase 141 zůstávají beze změny.
- Kontrolní složený obraz
  `.godot/phase142-reference-extraction-v3/player_room_rack_recomposed_preview_v3.png`
  vrací všechny rostliny na původní souřadnice. Celková MAE proti schválenému
  obrazu je 6,854; odchylka pochází převážně z dopočítaného prázdného pozadí,
  nikoli z RGB kresby rostlin.

## Herní integrace

- Aktivní Pokoj používá prázdný podklad
  `player_room_interior_phase142_exact_empty_v1.png` a dvanáct RGBA vrstev
  `*_reference_exact_v1.png`.
- Nové source-space kotvy odpovídají skutečným kontaktním hranám čtyř polic:
  `y = 743, 955, 1180, 1395`; každý řádek má tři sloty.
- Proměnlivé velikosti pláten nejsou vizuálně sjednocované přepočtem obsahu.
  Každý profil používá přesné měřítko `432 / 887` a vlastní pivot uprostřed
  květináče. Tím zůstává zachována velikost keramických květináčů i podmisek z
  předlohy.
- Stávající nákup, vlastnictví, bezplatné přesouvání a odstranění zůstávají
  funkční pro všech 12 slotů. Save schema 41 ani ekonomika se nemění.
- Obrazovka `ROSTLINY`, pěstitelské rostliny, skleník, Phase 140 dekorace a
  pravá část Pokoje se touto fází nemění.

## Hranice přijetí

Závěrečná validation `.godot/validation/20260823-192225Z` prošla s
`MVP_TESTS_PASSED=1460`, `HOW_TO_GROW_CAPTURE=PASSED`,
`HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Responsive
`.godot/responsive/20260823-192111Z` prošel 9/9 případů včetně 360 × 800;
věrné obrazové kotvy jsou oddělené od neviditelných, bezpečně širších
dotykových zón. Visual contract
`.godot/visual-contract/20260823-192135Z` eviduje 329 profilovaných PNG, 0
neprofilovaných a 130 runtime PNG. Závěrečný Quick průchod
`.godot/automation/20260823-192642Z` skončil
`HOW_TO_GROW_AUTOMATION=PASSED`.

Implementace, zdrojová věrnost a technický PASS nejsou vydávány za uživatelské
schválení skutečného herního renderu. Samostatně se předkládá capture
`.godot/validation/20260823-192225Z/comic-phase142-player-room-reference-exact-rack-set.png`.
Až následné výslovné uživatelské potvrzení může změnit
`PHASE142_GODOT_RENDER_ACCEPTANCE`; mobilní brána zůstává otevřená do nové
APK a fyzické kontroly telefonu.

Immutable RC54, jeho alias APK, nainstalovaná aplikace a hráčský save nejsou v
této source-only fázi přepsané.
