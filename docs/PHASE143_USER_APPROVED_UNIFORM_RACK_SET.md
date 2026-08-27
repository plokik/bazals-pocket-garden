# Fáze 143 — uživatelem schválená jednotná sada stojanu

Stav implementace: `PHASE143_USER_APPROVED_UNIFORM_RACK_SET=IMPLEMENTED`

Schválení zdroje: `PHASE143_SOURCE_ACCEPTANCE=APPROVED_BY_USER`

Technická validace: `PHASE143_TECHNICAL_VALIDATION=PASSED`

Skutečný Godot render: `PHASE143_GODOT_RENDER_ACCEPTANCE=APPROVED_BY_USER`

Mobilní přijetí: `PHASE143_MOBILE_ACCEPTANCE=PENDING`

Publikování: `OUT_OF_SCOPE_BY_USER`

## Závazná šablona

Uživatel schválil společný náhled všech čtyř polic jako závazný zdroj pro
aktivní stojan. Každá police obsahuje přesně tři sestavy. Keramika, podmisky,
kontaktní linie a stíny zachovávají jednotnou optickou velikost a stejné osy;
měnit se smí rostlina a dekor květináče. Pixel-artové nebo nalepené náhrady
nejsou přípustné.

Schválený zdroj je uložen jako
`assets/ui/visual/phase143/source/player_room_rack_user_approved_v1.png` se
SHA-256
`61EFDD17C01D02EAB5D21CE3D3E8F48A4C777558C4B02913108C9B44E7B05AB8`.
Samostatná maska
`player_room_rack_plant_mask_generated_v1.png` má SHA-256
`A2A42073FF5C3EBB5F44E0CDF021E99CF5C158E61F8395139F663DC81B5A58DF`.

## Reprodukční postup

- `tools/extract_phase143_approved_rack_plants.gd` deterministicky vyhledá
  dvanáct oddělených sestav a seřadí je po policích a sloupcích.
- Každý viditelný RGB pixel runtime PNG pochází přímo ze schváleného zdroje.
  Generovaná maska dodává pouze alfa kanál; kresba se znovu nepřemalovává.
- Výřezy, spodní pivoty, zdroj i maska jsou verzované. Starší Phase 139,
  Phase 141 a Phase 142 assety se nepřepisují.

## Herní integrace

- Aktivních je dvanáct `*_approved_uniform_v1.png` profilů.
- Všechny používají jediný izotropní převod
  `(432 / 887) × (2 / 3)`. Žádný řádek ani jednotlivá rostlina se samostatně
  nenatahuje, nestlačuje nebo nepřizpůsobuje podle výšky police.
- Vizuální osy jsou `x = 147, 291, 435` a kontaktní hrany polic
  `y = 743, 955, 1180, 1395` ve zdrojovém prostoru 887 × 1774.
- Neviditelné dotykové sloty, nákup jednou, vlastnictví, bezplatné přesouvání,
  odstranění a save schema 41 zůstávají beze změny.
- Obrazovka `ROSTLINY`, pěstitelské rostliny, skleník, pravá část Pokoje,
  immutable RC54, telefon a hráčský save se touto fází nemění.

## Hranice přijetí

Uživatel nejprve schválil zdrojový náhled a následně 24. srpna 2026 výslovně
schválil také níže uvedený skutečný Godot render. Úplná validation
`.godot/validation/20260823-201449Z` prošla s
`MVP_TESTS_PASSED=1464`, `HOW_TO_GROW_CAPTURE=PASSED`,
`HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Skutečný
capture je
`.godot/validation/20260823-201449Z/comic-phase143-player-room-user-approved-uniform-rack-set.png`.

Responsive `.godot/responsive/20260823-201723Z` prošel 9/9 případů včetně
360 × 800. Visual contract `.godot/visual-contract/20260823-201722Z`
eviduje 343 profilovaných PNG, 0 neprofilovaných a 130 runtime PNG. Technický
PASS uzavřela také Quick automatizace
`.godot/automation/20260823-201840Z` s
`HOW_TO_GROW_AUTOMATION=PASSED`. Zdroj i skutečný Godot render jsou
`APPROVED_BY_USER`; mobilní přijetí zůstává samostatně `PENDING`. APK se v
této fázi nevytváří ani neinstaluje.
