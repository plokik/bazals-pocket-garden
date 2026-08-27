# Fáze 126 — sjednocená vizuální kamera zahrady

`PHASE126_GARDEN_VISUAL_CAMERA=IMPLEMENTED`

## Cíl

Fáze odstraňuje rozdílné měřítko mezi stojanem, skleníkem a hráčským pokojem. Pokoj už není vzdálený celkový záběr s velkým podílem prázdného stropu a podlahy: hlavní stojan a vitrína zabírají stejnou vizuální váhu jako stojan rostlin a vyvýšené záhony ve skleníku. Funkce pokoje, ekonomika, osm rostlin, osm pevných dekorací, šest míst na úspěchy i budoucí kočičí kout zůstávají zachované.

## Kamerový kontrakt

Všechny tři domácí lokace používají `phase126_garden_visual_camera_v1` ze `scripts/ui/garden_scene_framing.gd`.

| Vrstva | Referenční geometrie | Pravidlo |
|---|---:|---|
| obsah pod HUD a nad dockem | 432 × 780 | společný návrhový prostor |
| titulní pás | y 74–144 | nesmí kolidovat s 60px navigačními tlačítky |
| hlavní scéna | y 144–650 | dominantní interaktivní obsah |
| spodní obsah | y 650–780 | pouze doplňkový prostor, ne druhá hlavní karta |
| vodorovná obsazenost | 88–96 % | prostředí nesmí působit jako vzdálená miniatura |
| výšková obsazenost | 70–84 % | hlavní objekt zůstává čitelný i na 360 × 800 |

Pozadí používají jeden cover-crop výpočet. Dynamické prvky pokoje nejsou uložené v náhodných procentech viewportu: jejich kotvy jsou v souřadnicích zdrojového obrazu 887 × 1774 a při změně poměru stran se mapují stejným cropem jako samotné pozadí. Díky tomu květináče, dekorace a budoucí úspěchy zůstávají na policích. Dotykové cíle se na úzkém zařízení bezpečně omezí na povrch pokoje, aniž by se posunula kresba předmětu.

## Nový pokojový asset

- runtime asset: `assets/ui/player_room/player_room_interior_phase126.png`;
- rozměr: 887 × 1774 px;
- SHA-256: `76752D68ED8B36DE8689209EFE902E06705D473E077D053542EFF95E92EF0E38`;
- původní `player_room_interior_phase123.png` zůstává beze změny, SHA-256 `5D9CF01ABED9752914C5392BA59433F4C0673B052A9E54A71F1237FA42103382`.

Asset vznikl vestavěným generátorem obrazu jako nový verzovaný soubor. První prompt požadoval blízký čelní portrétní pokoj podle dosavadního pokoje, stojanu a skleníku, velký čtyřpolicový stojan vlevo, vitrínu úspěchů vpravo, malé množství stropu a podlahy a žádné zapečené dynamické předměty nebo UI. Druhá cílená editace odstranila omylem zapečený kočičí pelíšek a ponechala prázdný podlahový prostor pro runtime kočičí kout. Zdrojové PNG předchozích fází nebyly upravovány.

## Runtime rozložení

- osm menších pokojovek je uspořádaných do dvou sloupců a čtyř polic;
- popínavka vede z vlastního květináče podél pravého nosného sloupku stojanu a neprotíná titulní pás;
- knihy, hnojiva, skládané květináče, lampička, obraz, konvička, sklenice a kočičí kout používají vlastní zdrojové kotvy;
- šest budoucích úspěchů používá dvě řady po třech pozicích ve vitríně;
- pokojové nákupy zůstávají čistě kosmetické a nic neumírá ani nemění péči;
- pohyb za oknem dál respektuje pauzu a volbu Méně pohybu.

## Kompatibilita a release hranice

Fáze nemění autoritativní herní data, proto zachovává save schema `39`. Mění runtime a exportní payload, takže je vyhrazena nová identita RC51 `0.63.0-rc51` / code 68. Immutable RC50 a všechny starší kandidáty se nepřepisují. Publikování zůstává `OUT_OF_SCOPE_BY_USER`; technická automatizace a lidské vizuální potvrzení na telefonu se vedou odděleně.

## Ověření

- regrese: `MVP_TESTS_PASSED=1394`;
- finální validation: `.godot/validation/20260822-171510Z`, capture, visuals i full `PASSED`, všech 14 aktivních bran zelených;
- schválené reference, cropy, masky a tolerance se nezměnily; nový pokoj je report-only do lidského potvrzení;
- responsive: `.godot/responsive/20260822-171752Z`, 9/9 včetně samostatného `phase126_player_room_360x800`;
- performance: `.godot/performance/20260822-171652Z`, CPU p95 10,187 ms, frame p95 16,738 ms, 476 draw calls, 86,65 MiB;
- endurance: `.godot/endurance/20260822-171736Z`, 48/48 cyklů, sedm roundtripů, nulový růst uzlů, orphanů a zdrojů;
- progression: `.godot/progression/20260822-171747Z`, 132/132 cyklů, 11 druhů, 27 save/load roundtripů;
- release automatizace: `.godot/automation/20260822-171509Z`, `HOW_TO_GROW_AUTOMATION=PASSED`;
- release candidate: `.godot/release-candidate/20260822-171510Z`, export, podpis APK v2, entry scan, runtime payload a notification payload `PASSED`;
- immutable RC51: `builds/android/bazals-pocket-garden-0.63.0-rc51-arm64-debug.apk`, 111 812 793 B, SHA-256 `6B48C70E4A80B369E83EF50121760A1F598088D933F1CE499EFD73B17211410F`;
- fyzický technický audit: `.godot/android-device-audit/20260822-172854Z`, instalace přes předchozí build, přesná identita APK, zachování dat i schema `39_TO_39`, 11 platných foreground vzorků a 0 fatal nálezů `PASSED`; technický snímek `phase126-room.png` potvrzuje vykreslení nového pokoje na cílovém Xiaomi;
- immutable RC50 zůstává beze změny se SHA-256 `C7227D3FC8ACE61CEB214EF1F83B4BAEE3BE5402F564D013E8031D49CEAFE14D`.

Lokální i fyzická technická brána RC51 jsou `PASSED` a RC51 je nainstalované na telefonu bez ztráty existujícího save. Automatizovaná navigace potvrdila, že se nový Pokoj na telefonu vykresluje, ale subjektivní čitelnost, pocit z dotyku a výsledný vzhled jsou vedené zvlášť jako `PENDING_SINGLE_HUMAN_BATCH`. Publikování zůstává `OUT_OF_SCOPE_BY_USER`.
