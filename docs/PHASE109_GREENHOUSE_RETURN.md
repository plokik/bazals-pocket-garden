# Fáze 109 — skleníkový návrat a kompaktní mobilní rozložení

Stav: **hotovo v hlavním projektu · automatické desktopové brány prošly**.

Fáze 109 odstraňuje poslední zjištěný překryv skleníku na fyzické geometrii 360×800 a zviditelňuje akce, které na hráče ve skleníku čekají. Jde o změnu runtime a prezentace nad existujícím skleníkovým stavem. Katalog tří plodin, ekonomika, odměny, úrovňové zámky a save schema 32 zůstávají beze změny.

## Návrat a odvozený stav

- `GreenhouseSimulation.advance(real_seconds)` vrací stabilně seřazené události `greenhouse_ready` pouze při skutečném přechodu zalitého záhonu ze stavu růstu do stavu připraveného ke sklizni.
- Událost obsahuje `kind`, `source`, `bed_index`, `bed_number`, `crop_id` a `crop_name`. Neplatný, nezalitý, už hotový nebo nulový krok událost nevytvoří.
- Offline postup přidává skleníkové události do stejné lifecycle fronty jako dosavadní návratové události květináčů. Smíšený návrat proto nic nezahodí a souhrn zobrazí oba typy.
- Samotné dozrání nepřipisuje mince ani XP. Odměna zůstává výhradně atomickou součástí jediné skutečné sklizně.
- Návratový řádek má tvar `Skleník · záhon N · PLODINA · PŘIPRAVENO KE SKLIZNI`. Tlačítko `ZKONTROLOVAT ZAHRADU` souhrn pouze zavře; nemění stav záhonu ani automaticky nesklízí.
- `GameSession.get_greenhouse_attention_summary()` odvozuje `needs_water`, `ready` a jejich součet `action_count`. Jde pouze o čtecí stav, nikoli o nový save kontrakt.

Tlačítko skleníku na stojanu si zachovává rozměr 124×64 px. Pokud existuje alespoň jedna akce, přidá druhý řádek `N AKCE`; při nulovém součtu zůstane původní text beze změny. Stav se obnovuje při sestavení a obnovení UI, po akci ve skleníku, po offline návratu a během aktivního běhu přibližně každých 0,25 s.

## Kompaktní mobilní geometrie

Pro obsahovou plochu 360×620 px, která odpovídá zařízení 360×800 po odečtení horní a dolní navigace, platí explicitní kompaktní větev:

| Prvek | Geometrie |
| --- | --- |
| skleník | `Rect2(18, 174, 324, 240)` |
| záhon 1 / 3 | `x=30`, `146×74` |
| záhon 2 / 4 | `x=184`, `146×74` |
| horní řada záhonů | `y=246` |
| dolní řada záhonů | `y=328` |
| stavový panel | `Rect2(16, 430, 328, 96)` |
| tři volby plodiny | `x=16/128/240`, `y=542`, `104×64` |
| hlavní akce obsazeného záhonu | `Rect2(16, 542, 328, 64)` |

Spodní rezerva je 14 px. Záhony se stavovým panelem už nepřekrývají a všechny tři volby zůstávají samostatnými 64px dotykovými cíli. Dosavadní rozložení pro 432×780 zůstává v původní větvi.

## Automatické důkazy

Všechny následující výsledky vznikly přímo v `C:\_projekty\How to grow_`:

| Brána | Výsledek | Artefakt |
| --- | --- | --- |
| regrese + obrazová validace | `1299/1299`, capture, visuals a full validation `PASSED` | `.godot/validation/20260821-143411Z` |
| progression | `132/132`, 27 save/load roundtripů, L90, 11 351 mincí, 114 zakázek | `.godot/progression/20260821-143705Z` |
| endurance | `48/48`, 7 roundtripů, růst uzlů/orphanů/zdrojů `0/0/0`, paměť `+0,02 MiB` | `.godot/endurance/20260821-143720Z` |
| responsive | `8/8`, včetně přesného `phase109_greenhouse_360x800` | `.godot/responsive/20260821-143741Z` |
| performance | CPU p95 max. `9,429 ms`, frame p95 max. `16,699 ms`, 449 draw calls, 85,73 MiB | `.godot/performance/20260821-143755Z` |

Tři nové snímky `comic-greenhouse-level2-compact.png`, `comic-return-summary-greenhouse-ready.png` a `comic-rack-greenhouse-attention.png` jsou pouze reportovací. Schválené reference, `references/visual-cases.json`, crop, masky, tolerance a zdrojové PNG nebyly touto fází změněny.

## Release hranice

Fáze 109 nevytvořila ani neinstalovala APK nebo AAB. Immutable RC35 `0.49.0-rc35` / code 52 / schema 32 zůstává byte-for-byte nezměněný, a proto tuto novější runtime změnu neobsahuje. Až bude potřeba distribuovat fázi 109 na Android, musí vzniknout nový kandidát RC36; RC35 se nesmí přepsat.

Automatické desktopové brány jsou `PASSED`. Lidská L2 kontrola čitelnosti a dotyku na cílovém Android zařízení, přirozené dozrání s aktualizací odznaku, skutečné upozornění, delší bateriový/tepelný běh a veřejné publikování zůstávají samostatně `PENDING`.

## Navazující RC36

Po uzavření source-only fáze vzniklo nové immutable RC36 `0.50.0-rc36` / code 53; historické tvrzení výše popisuje okamžik dokončení fáze 109 a RC35 zůstalo nedotčené. Release `.godot/release-candidate/20260821-160145Z` vytvořil `builds/android/bazals-pocket-garden-0.50.0-rc36-arm64-debug.apk` o 106 193 804 B a SHA-256 `9987F544E5FC692BA0F05BE183FDCDB6E426572A769FDC6D9CA01DDB44936860`.

Platný audit `.godot/android-device-audit/20260821-163933Z` nainstaloval RC36 přes RC35 bez smazání dat, potvrdil hash, zachování save schema 32 → 32, 54/54 odemčených a interaktivních vzorků, 100 % času v popředí a 0 crash/ANR/fatal nálezů. Fyzické snímky potvrdily nepřekrývající se skleník, tři čitelné volby a zámek okurky; skutečná sklizeň změnila 22 → 46 mincí a 27 → 35 XP a stojan následně ukázal přesně `3 AKCE`.

Tento dílčí fyzický průchod nepotvrdil stisk konkrétní volby plodiny ani nové přirozené offline dozrání se skleníkovým řádkem. Úplná lidská, notification, backup/import, delší bateriová/tepelná a publikační brána proto zůstává otevřená; další ověřování se má vyžádat pouze jako jediný závěrečný dávkový checklist.
