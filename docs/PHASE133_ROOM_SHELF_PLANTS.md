# Fáze 133 — pokojové rostliny 3 × 4 s podmiskami

`PHASE133_ROOM_SHELF_PLANTS=IMPLEMENTED`

`PHASE133_TECHNICAL_VALIDATION=PASSED`

`PHASE133_MOBILE_ACCEPTANCE=PENDING`

## Cíl a hranice

Každá ze čtyř polic velkého stojanu v Pokoji má tři skutečná rostlinná místa. Celkem vzniká dvanáct kategoriálně bezpečných slotů; osm existujících pokojových rostlin zůstává kosmetických, neumírá, nepotřebuje péči a dál používá společnou mincovou peněženku. Fáze nepřidává nový druh, bonus ani druhou ekonomiku a nemění obrazovku `ROSTLINY`.

## Vizuální skladba

Zdrojové kotvy stojanu tvoří přesnou mřížku 3 × 4 v prostoru podkladu 887 × 1774 px. Sloupce mají souřadnice 115 / 285 / 455 px a řádky zůstávají na čtyřech fyzických policích. Všechny pokojové rostliny používají menší sjednocené designové rozměry, původní kvalitní transparentní kresby a stejné pořadí vrstev:

1. kompaktní kontaktní stín;
2. podmiska položená na dřevěné polici;
3. květináč a vegetace ukotvené do podmisky;
4. nenápadný ovládací znak pouze u prázdného místa.

Společná podmiska je samostatný transparentní asset `assets/ui/visual/phase133/room_plant_saucer_v1.png` o rozměrech 256 × 103 px a SHA-256 `01C9A1EAAEEF16786100B6D322F271845CAD3171071E5DB500AC1E9C9C6ACD65`. Profil `room_plant_saucer` ji zobrazuje jako nenápadných 34 × 14 designových pixelů s vlastním pivotem a mírně zjemněnou alfou. Teplá slonovinová keramika, tenký tyrkysový lem, tmavý komiksový obrys a světlo zleva nahoře navazují na master `phase131_living_botanical_master_v1`, aniž by podmiska přebila různobarevné květináče.

## Save migrace

`SAVE_SCHEMA = 40` a `ROOM_THREE_PER_SHELF_SCHEMA = 40` chrání novou dvacetislotovou topologii. Staré schema 38–39 mělo osm rostlin na indexech 0–7 a osm pevných dekorací na 8–15. Migrace proto používá explicitní mapu `0,2,3,5,6,8,9,11,12–19`: původní levá a pravá rostlina zůstane na stejné polici, nová prostřední místa jsou prázdná a knihy, hnojiva, květináče, lampička, obraz, konvička, sklenice i kočičí kout se beze ztráty posunou na 12–19. Schema 40 pak ukládá všech dvacet pozic přímo.

## Ověření

Regrese výslovně kontroluje 12 rostlinných a 8 pevných slotů, úplnou migraci schema 39 → 40, aktuální round-trip, hash a profil podmisky, vrstvení, mřížku 3 × 4 a zachování 64px dotykových cílů. Capture přidává report-only `comic-phase133-player-room-shelf-plants.png`; schválené reference, jejich cropy, masky ani tolerance se nepřepisují.

Úplná validace `.godot/validation/20260823-084346Z` prošla s `MVP_TESTS_PASSED=1424`, `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`; žádná schválená reference, crop, maska ani tolerance se nepřepsala. Responsive audit `.godot/responsive/20260823-083747Z` prošel 9/9 případů včetně 360 × 800 a potvrdil všech 20 dotykových cílů nejméně 64 × 64 px. Vizuální kontrakt `.godot/visual-contract/20260823-084558Z` prošel s 248 profilovanými PNG, 0 neprofilovanými a 123 runtime PNG v master profilu. Report-only `comic-phase133-player-room-shelf-plants.png` byl ručně zkontrolovaný v plném záběru; podmisky po zmenšení nepřebíjejí květináče a všechny čtyři police čitelně drží tři pozice.

Quick automatizace `.godot/automation/20260823-084635Z` prošla visual contractem i regresí s `AUTOMATION_TECHNICAL_GATE=PASSED` a `HOW_TO_GROW_AUTOMATION=PASSED`. Device gate nebyla vyžádaná a lidská mobilní brána správně zůstává `PENDING_SINGLE_HUMAN_BATCH`. Immutable RC53 `0.64.0-rc53` / code 70 / schema 39, nainstalovaná APK a telefon zůstávají nedotčené. První budoucí Android build s touto změnou musí mít novou immutable identitu a schema 40. Publikování zůstává mimo rozsah.

## Použitý generační brief

Vestavěný ImageGen dostal jako výtvarné reference `measurement_corner_backdrop_v1.png` a `player_room_interior_phase132_living_v1.png`. Brief požadoval jedinou mělkou širokou keramickou podmisku, teplou slonovinu, tenký tlumený tyrkysový lem, čistý tmavý komiksový obrys, horní levé světlo, kompaktní kontaktní stín, čitelnost kolem 48 px a zákaz rostliny, květináče, textu, rámu, pozadí nebo dalších objektů. Generovaný originál zůstal zachovaný; projekt používá pouze technicky vyčištěný průhledný výřez v novém verzovaném souboru.
