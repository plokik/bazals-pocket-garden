# Fáze 104 — dekorace hráčského pokoje

Stav: fyzicky přijato na `0.46.0-rc31` / code 48 / save schema 29. RC30 odhalil nefunkční svislý tah; RC31 opravu prošel automaticky i ručně na Xiaomi 2201116SG s Androidem 13.

## Herní rozsah

- Každé z pěti míst v hráčském pokoji je samostatný 56px dotykový cíl.
- Klepnutí otevře blokující rolovatelný výběr šesti dekorací: botanické knihy, mini monsteru, tchynin jazyk, zlatou lampičku, pokojovou kapradinu a kvetoucí begonii.
- Ceny jsou 14, 18, 24, 26, 28 a 32 mincí. Používá se jediná stávající peněženka; nevzniká další měna ani druhý obchodní inventář.
- Položka se kupuje jen jednou. Vlastněnou dekoraci lze zdarma přesouvat mezi místy. Odstranění ji pouze schová, nevrací mince a nemaže vlastnictví.
- Jedna dekorace může být současně nejvýše na jednom místě. Položení do obsazeného místa předchozí předmět bezpečně odloží.
- Dekorace jsou pouze vizuální. Nemění růst, zdraví, sklizeň, odměny, denní výzvy ani Profesorův výzkum.

## Ukládání a kompatibilita

- Hlavní save se zvyšuje z 28 na 29. Nová hranice autorizuje pouze vlastněná známá ID a pět unikátních umístění.
- Save 28 ignoruje podvržené budoucí klíče dekorací a migruje do prázdné sbírky.
- Schema 29 odstraňuje neznámá a neřetězcová ID, duplicity vlastnictví, duplicitní umístění i položky umístěné bez vlastnictví.
- Pozdější hlavní schema nesmí vymazat starší rozpracovaný Profesorův protokol. Výzkumný submodel proto přijímá známé novější top-level schema, zatímco `SaveManager` dál fail-closed odmítá skutečně budoucí nepodporovanou verzi.

## Mobilní chování

- Systémové Android Zpět nejprve zavře výběr dekorací a ponechá hráče v pokoji.
- Akční tlačítka mají nejméně 56 px a uvnitř seznamu předávají svislý tah rodičovskému scrollu.
- Karty používají svislý mobilní layout, aby se vešly i do šířky 360 px bez vodorovného přetečení.
- Deterministický capture přidává pouze report-only snímky `comic-player-room-decorated.png` a `comic-room-decoration-shop.png`; žádná nová reference se bez ručního schválení nevytváří.

## Automatické důkazy

- Funkční regrese: `MVP_TESTS_PASSED=1254`.
- Testy pokrývají ceny, nedostatek mincí, idempotentní nákup, bezplatný přesun, odstranění bez refundace, náhradu obsazeného místa, nulový vliv na rostlinu, schema 28 trust boundary, schema 29 sanitizaci a skutečný UI tok.
- Responzivní kontrola RC31 prošla ve všech 7 profilech včetně šířky 360 px: `.godot/responsive/20260820-170744Z`.
- Úplná report-only validace RC31 prošla s `MVP_TESTS_PASSED=1254`, `HOW_TO_GROW_CAPTURE=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`: `.godot/validation/20260820-170805Z`.
- Nové obrazy zůstávají záměrně report-only. Starší schválené vizuální reference se nepřepisovaly.

## Android ověření

Před první instalací schema 29 byla vytvořena a fyzicky potvrzena přenosná záloha `bazals-pocket-garden-2026-08-20.htgbackup`. Po instalacích RC30 i RC31 zůstala zachovaná společně se starší zálohou.

Přijatý QA artefakt: `builds/android/bazals-pocket-garden-phase104-rc31-qa-debug.apk`, verze `0.46.0-rc31` / code 48, SHA-256 `4C3A94777F7ECF977F5706DA96391EA981DF89FC490FA965458708E32F65FB20`.

První fyzický automatický audit RC30: `.godot/android-device-audit/20260820-163721Z`.

- Instalace přes předchozí RC29 proběhla bez smazání aplikačních dat.
- Otisk skutečně instalovaného APK přesně odpovídá kandidátu RC30.
- Hlavní save se převedl `28_TO_29`; stabilní herní pole zůstala shodná.
- Během 60 sekund vzniklo 11 platných vzorků, aplikace byla 100 % času v popředí a automatická kontrola nenašla pád ani ANR.
- Před instalací byla ve Stažených potvrzena nová přenosná záloha `bazals-pocket-garden-2026-08-20.htgbackup`; po instalaci zůstala zachovaná společně se starší zálohou.
- Technická Android brána RC30 prošla, ale následný ruční test správně odmítl nefunkční svislý tah.

## Oprava po fyzickém testu RC30

- Ruční test na Xiaomi potvrdil otevření, vzhled i systémové Zpět, ale odhalil nefunkční svislý tah.
- Příčinou byly karty vytvořené až při otevření modalu: původní konfigurace scrollu proběhla nad ještě prázdným seznamem, takže novější texty, kontejnery a vzorky barev zachytávaly dotyk.
- RC31 nastavuje mobilní scroll kontrakt přímo v komponentě a po každém vytvoření katalogu rekurzivně předává dotykový tah ze všech dynamických potomků rodičovskému `ScrollContaineru`.
- Funkční i responzivní regrese nově selže, pokud jediný dynamický potomek zůstane v blokujícím režimu.
- Kompletní regrese RC31: `MVP_TESTS_PASSED=1254`.
- Responzivní matice RC31: 7/7, `.godot/responsive/20260820-170744Z`.
- Úplná report-only validace RC31: `HOW_TO_GROW_VALIDATION=PASSED`, `.godot/validation/20260820-170805Z`; schválené reference zůstaly beze změny.
- Opravený QA artefakt: `builds/android/bazals-pocket-garden-phase104-rc31-qa-debug.apk`, SHA-256 `4C3A94777F7ECF977F5706DA96391EA981DF89FC490FA965458708E32F65FB20`.
- Fyzický technický audit RC31: `.godot/android-device-audit/20260820-171045Z`; instalace přes RC30 zachovala data, ověřila přechod `29_TO_29`, shodu APK a nulový počet nalezených pádů/ANR.

## Ruční akceptace RC31

- Uživatel potvrdil svislý tah zahájený přes text, barevný vzorek i akční tlačítko výsledkem `slide ready`.
- Nákup botanických knih odečetl přesně 14 mincí; přesun, odstranění a opětovné položení proběhly zdarma výsledkem `knihy ready`.
- Nákup mini monstery odečetl přesně 18 mincí; náhrada obsazeného místa, bezplatné nové položení knih a úplný restart aplikace zachovaly obě dekorace výsledkem `dekorace ready`.
- Bezpečný závěrečný snapshot po restartu potvrdil schema 29, zůstatek 62 mincí, vlastnictví `botanical_books` a `mini_monstera` a pět validních slotů s oběma unikátními umístěními.
- Závěrečný 20sekundový audit `.godot/android-device-audit/20260820-173405Z` prošel technickou bránou, zachoval save `29_TO_29` a neuložil surový obsah hráčské pozice.
