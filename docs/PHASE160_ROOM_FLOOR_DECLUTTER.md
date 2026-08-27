# Fáze 160 — vyčištění podlahy Pokoje

`PHASE160_ROOM_FLOOR_DECLUTTER=IMPLEMENTED`

`PHASE160_SAVE_SCHEMA=41_UNCHANGED`

`PHASE160_RC57_IMMUTABILITY=PRESERVED`

`PHASE160_TECHNICAL_VALIDATION=PASSED`

`PHASE160_RENDER_INSPECTION=PASSED`

`PHASE160_GODOT_VISUAL_ACCEPTANCE=APPROVED_BY_USER`

`PHASE160_USER_VISUAL_ACCEPTANCE=APPROVED_BY_USER`

`PHASE160_VISUAL_BASELINE_TRANSITION=PASSED_APPEND_ONLY_RUNTIME_GATE`

`PHASE160_ANDROID_APK=NOT_CREATED`

`PHASE160_PUBLISHING=OUT_OF_SCOPE_BY_USER`

## Schválený zásah

Uživatel označil čtyři objekty na podlaze Pokoje za vizuálně nepasující a
schválil jejich odstranění ze současného runtime: plastovou konvičku, kočičí
pelíšek a dvojici misek. Nejde o nové překreslení ani o náhradu jinými drobnými
objekty. Pravá podlahová plocha má zůstat čistá, dokud nevznikne jednotně
namalovaný pet kout propojený se skutečným nákupem mazlíčka.

Mapování existujícího obsahu:

- `plastic_watering_can` je historický nákup ve slotu 17;
- `cat_corner` je historický nákup ve slotu 19;
- obě misky jsou pouze přední vizuální vrstva `room_pet_bowls`, která se dříve
  kreslila společně s `cat_corner`.

## Save-safe dormant režim

Obě katalogová ID zůstávají čitelná jako historické účtenky. Schema 41,
`owned_room_decorations`, dvacetiprvkové pole `room_decoration_slots`, ceny i
staré uložené pozice zůstávají beze změny. Načtení a opětovné uložení tedy
vlastnictví ani umístění nemaže.

Nový nákup je zablokovaný stavem `reserved_for_redesign`. Sloty 17 a 19 nemají
v živém Pokoji sprite, prázdný marker, aktivní hitbox ani nabídku v showroomu.
Počet viditelně umístěných dekorací je veden odděleně od počtu uložených
historických účtenek.

Historický Phase149 full master obsahuje odmítnuté podlahové objekty. Proto jej
produkční Pokoj už nesmí automaticky vybrat ani při starém rozložení 20/20.
Zůstává dostupný pouze pro explicitní report-only capture
`phase149_exact_player_room_target_report_only_v1`; soubor ani jeho reference
se nepřepisují.

## Zdrojové assety a budoucí smlouva

Původní PNG konvičky, pelíšku a misek zůstávají nezměněná a reprodukovatelná.
Phase160 používá výhradně runtime suppression. To zachovává auditní historii a
zároveň brání návratu nalepeně působících objektů do aktuální kompozice.

Slot 19 je rezervovaný pro budoucí celek `pet_purchase_and_integrated_corner`:
nejprve skutečný mazlíček a až potom společně navržený pelíšek, voda a krmivo.
Samostatné misky ani samostatná péče o dekoraci se v této fázi nepřidávají.

## Ověření a brány

Deterministický capture `comic-phase160-player-room-clean-floor.png` ponechává
v sanitizovaném uloženém stavu obě dormant ID, ale očekává čistou podlahu bez
konvičky, pelíšku i misek. Regrese kontroluje zablokovaný nákup, nezměněné
mince, round-trip starých účtenek a pozic, skryté hitboxy, produkční zákaz
Phase149 masteru a zachování historických PNG.

Technický PASS zůstává oddělený od lidského vizuálního schválení. Uživatel
výslovně schválil skutečný Godot render
`comic-phase160-player-room-clean-floor.png` dne 26. srpna 2026. Tento přesný
snímek byl proto append-only povýšen na referenci
`assets/ui/comic/reference_phase160_player_room_clean_floor_runtime_v1.png` se
SHA-256
`A0A7D7D1A4120320FC0084AF65429E9F997AC9CAD29E51DECF20278869363BD2`.
APK se v této fázi nevytváří.

Úplná validace `.godot/validation/20260826-050101Z` prošla s
`MVP_TESTS_PASSED=1534`, `HOW_TO_GROW_CAPTURE=PASSED`,
`HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Phase149
historická obrazová brána po opravě pořadí report metadat znovu prošla.

Skutečný Godot render `comic-phase160-player-room-clean-floor.png` byl
zkontrolován v původním rozlišení: konvička, pelíšek, tyrkysová i oranžová miska
nejsou viditelné, pravá podlaha je čistá a terárium, police, knihy, sklenice,
rostliny ani spodní navigace nejsou oříznuté. Nový tvrdý případ
`phase160-player-room-clean-floor-runtime-approved` porovnává celý obraz bez
cropu a bez masky, používá stejnou normalizaci 432 × 960 a stejné omezené
tolerance jako ostatní schválené runtime obrazovky.

Úplná validační reprodukce po povýšení baseline
`.godot/validation/20260826-064438Z` prošla s
`MVP_TESTS_PASSED=1535`, `HOW_TO_GROW_CAPTURE=PASSED`,
`HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Všech 22
tvrdých obrazových bran prošlo. Nový případ skončil přesně
`mean_abs_error=0.000`, `rmse=0.000` a `changed_ratio=0.000 %`; schválený
render a nově zachycený deterministický render jsou po normalizaci totožné.

Responzivní matice `.godot/responsive/20260826-050545Z` prošla 13/13 včetně
samostatného Pokoje na 360 × 800 a ověřila, že dormant sloty 17/19 jsou skryté,
disabled a používají `MOUSE_FILTER_IGNORE`. Capture má 1080 × 2400 a SHA-256
`A0A7D7D1A4120320FC0084AF65429E9F997AC9CAD29E51DECF20278869363BD2`.
