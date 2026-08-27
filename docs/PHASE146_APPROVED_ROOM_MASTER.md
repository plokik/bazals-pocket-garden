# Fáze 146 – schválený celoplošný master Pokoje

`PHASE146_APPROVED_ROOM_MASTER=IMPLEMENTED`

## Záměr

Fáze 146 nahrazuje postupné skládání nesourodých pokojových dekorací jednou
schválenou obrazovou kompozicí. Obrazovka Rostliny, herní ekonomika, dvacet
existujících pokojových slotů a save schema 41 zůstávají beze změny.

## Schválené vrstvy

- plný master: `assets/ui/player_room/player_room_interior_phase146_approved_full_v1.png`
  - rozměr `887 × 1774`
  - SHA-256 `3e6b98d39133e92327f6571ec6baaca34cfdde400b7614084f8b35fcdef8db59`
- prázdný základ: `assets/ui/player_room/player_room_interior_phase146_approved_empty_v1.png`
  - rozměr `887 × 1774`
  - SHA-256 `433d3c6e6926b51dee80444c4e52c9f29cdaa44eedd9fc106b2198728177abbe`
- aktivní neměnný RGB zdroj oddělených pevných dekorací: `assets/ui/visual/phase146/source/player_room_fixed_decor_isolated_checker_v3.png`
  - rozměr `887 × 1774`
  - SHA-256 `41379dbb3ad31c8da5d50cacc6cf31eb781476421d7f26230bf467e4ab5594fe`
- aktivní odvozená transparentní runtime vrstva: `assets/ui/visual/phase146/player_room_fixed_decor_layer_v3.png`
  - rozměr `887 × 1774`, formát RGBA
  - SHA-256 `50436214dd2e98264a6e53ea219a398a3ae9e96b730176a6ec7556a9adc323f3`

Všechny PNG jsou nové verzované soubory. Předchozí Phase 123–145 zdroje ani
immutable RC55 nebyly přepsány. Transparentní vrstvu reprodukovatelně vytváří
`tools/extract_phase146_room_master_layer.gd`; zdrojové PNG přitom neupravuje.
Původní checker `v1`, první čistší pokus `v2` i obě odvozené vrstvy zůstaly
zachované, ale runtime je nepoužívá. V3 vznikla po zjištění, že v1 obsahuje
zapečené šedé stíny a v2 navíc překrývá konvičku, pelíšek a misky.

## Runtime smlouva

- prázdný master kreslí architekturu, čtyři police stojanu, pravé police,
  komodu, šest držáků úspěchů, podlahu a koberec jako jeden obraz;
- dvanáct zakoupitelných rostlin zůstává pohyblivých mezi dvanácti sloty a
  používá schválené Phase 143 RGBA vrstvy;
- osm pevných dekorací se kreslí z jediné přesně zarovnané transparentní RGBA
  vrstvy odvozené ze schváleného vzhledu; pod nimi se proto nepřenášejí žádné
  obdélníkové kusy pozadí ani polic;
- knihy, sklenice, hnojiva, obraz, lampička, květináče, konvička, pelíšek a
  misky jsou ve zdroji v samostatných nepřekrývajících se buňkách bez
  zapečeného vrženého stínu; Godot přidává jednotný jemný kontaktní stín až
  podle skutečné police nebo podlahy;
- vnořené květináče jsou proti schválené vrstvě posunuté o `8 px` dolů a
  úzká přední hrana komodové police se znovu vykreslí nad jejich spodkem;
  květináče tak stojí za hranou police místo dojmu nalepeného výřezu, bez
  změny nebo přemalování zdrojového PNG;
- stará samostatná police a držáky úspěchů se znovu nepřekreslují, protože jsou
  součástí základního obrazu;
- titulek, návrat na stojan a volba vzhledu jsou seskupené vlevo nad oknem;
  horní pravá police s knihami a bylinkovými sklenicemi tak zůstává viditelná;
- interaktivní plusy, nákup, vlastnictví, přesouvání, téma pokoje a živé okno
  zůstávají funkční.

## Technické důkazy

- úplná validation po opravě usazení vnořených květináčů:
  `.godot/validation/20260824-173415Z`
  - `MVP_TESTS_PASSED=1477`
  - `HOW_TO_GROW_CAPTURE=PASSED`
  - `HOW_TO_GROW_VISUALS=PASSED`
  - `HOW_TO_GROW_VALIDATION=PASSED`
- skutečný Godot render:
  `.godot/validation/20260824-173415Z/comic-phase146-player-room-approved-master.png`
- visual contract: `.godot/visual-contract/20260824-165444Z`
  - `353` profilovaných PNG
  - `0` neprofilovaných PNG
  - `133` runtime PNG
- responsive: `.godot/responsive/20260824-173637Z` — `9/9 PASSED`
- Quick automatizace: `.godot/automation/20260824-173839Z` —
  `HOW_TO_GROW_AUTOMATION=PASSED`

Technický PASS potvrzuje načtení assetů, integritu profilů, funkční sloty,
regresi a rozložení. Subjektivní přijetí skutečného herního obrazu je záměrně
samostatná brána.

## Brány

`PHASE146_SOURCE_ACCEPTANCE=APPROVED_BY_USER`

`PHASE146_TECHNICAL_VALIDATION=PASSED`

`PHASE146_GODOT_RENDER_ACCEPTANCE=PENDING`

`PHASE146_MOBILE_ACCEPTANCE=DEFERRED_PHONE_UNAVAILABLE`

`PHASE146_PUBLISHING=OUT_OF_SCOPE`
