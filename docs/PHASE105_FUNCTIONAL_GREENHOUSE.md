# Fáze 105 — první funkční skleník

Stav: funkčně dokončeno v hlavním projektu. RC32 / code 49 bezpečně převedl fyzický telefon na save schema 30; oprava systémového Zpět z Androidu 16 je zabalena v neměnném ARM64 kandidátu `0.47.0-rc33` / code 50. RC33 byl 20. srpna 2026 nainstalován na Xiaomi a automatická fyzická technická brána prošla. Ruční gesto Zpět a skutečné systémové upozornění ještě čekají.

## Herní rozsah

- Skleník používá čtyři samostatné záhony v mřížce 2×2.
- První a zatím jedinou zeleninou je cherry rajče.
- Zasazení stojí 10 stávajících mincí. Nevzniká nová měna, semenný inventář ani druhý obchod.
- Po zasazení je potřeba jedna bezplatná zálivka. Teprve ta spustí růst.
- Růst trvá šest hodin skutečného času a pokračuje i při zavřené aplikaci.
- Zralá sklizeň připíše 24 mincí a 8 XP a uvolní záhon. Čistý mincový výsledek jednoho dokončeného cyklu je tedy +14 mincí.
- Všechny čtyři záhony jsou nezávislé a mohou současně pěstovat stejnou plodinu.

## Mobilní obrazovka

- Každý záhon je samostatný dotykový cíl o rozměru nejméně 64×64 px.
- Vybraný záhon má zlaté zvýraznění, vlastní stavovou kartu a jednu velkou kontextovou akci `ZASADIT`, `ZALÍT` nebo `SKLIDIT`.
- Během růstu je akce bezpečně vypnutá a karta ukazuje procenta i zbývající čas.
- Tlačítko `STOJAN` i systémové Android Zpět vracejí hráče do přijaté domácí lokace bez nové hlavní záložky.
- Obraz je kreslený kódem; žádné zdrojové PNG ani schválené vizuální reference se neměnily.

## Ukládání a kompatibilita

- Hlavní save se zvyšuje z 29 na 30. Samostatná hranice `GREENHOUSE_SCHEMA` autorizuje pouze čtyři známé stavy záhonů a uzavřený katalog plodin.
- Schema 29 ignoruje podvržený budoucí `greenhouse_beds`, takže starší save nemůže vytvořit hotovou placenou úrodu.
- Schema 30 odmítá neznámá ID plodin a vadné typy, omezí růst na cílový čas, nezalitý růst vynuluje a načte nejvýše čtyři záhony.
- Online i offline postup používají stejný skleníkový čas. Stav každého záhonu přežije save/load round-trip.
- RC31 neumí schema 30 načíst. Před první instalací RC32 je proto povinná nová přenosná `.htgbackup` záloha aktuálního stavu RC31.

## Automatické důkazy

- Funkční regrese RC33: `MVP_TESTS_PASSED=1269`.
- Úplná validace: `.godot/validation/20260820-193137Z`, `HOW_TO_GROW_CAPTURE=PASSED`, všechny povinné obrazové brány prošly a `HOW_TO_GROW_VALIDATION=PASSED`.
- Responzivní matice: 7/7, `.godot/responsive/20260820-193408Z`.
- Nové snímky `comic-greenhouse-preview.png`, `comic-greenhouse-growing.png` a `comic-greenhouse-ready.png` jsou pouze reportovací. Ruční kontrola potvrdila čitelnou mřížku, konzistentní peněženku a stavy prázdný / 50 % / sklizeň.
- Dva historické rozdíly `feedback-unlock` a `screen-transition` tvořily výhradně schválené šipky fáze 103. Dvě úzké masky přesně kryjí pouze jejich obrysy; mimo ně zůstalo 0 % pixelů nad tolerancí a RMSE 0,052. Referenční PNG ani prahy se nezměnily.
- Výkon: `.godot/performance/20260820-193308Z`, nejvyšší CPU p95 10,060 ms, frame p95 16,696 ms, nejvýše 449 draw calls.
- Endurance: `.godot/endurance/20260820-193351Z`, 48/48 cyklů, 7 save/load round-tripů a nulový růst uzlů, orphanů i zdrojů.
- Postup a ekonomika: `.godot/progression/20260820-193402Z`, 132/132 cyklů, 27 save/load round-tripů, 112 zakázek a finální úroveň 90.

## Android QA kandidáti

- Soubor: `builds/android/bazals-pocket-garden-phase105-rc32-qa-debug.apk`.
- Verze: `0.47.0-rc32` / code 49 / save schema 30.
- Velikost: 101,26 MiB.
- SHA-256: `510009787DF418A355B5C41CF07FC603920B7C8DCE3533B45D3641CE910DF0BA`.
- Export prošel Gradle kontrolou, podpisem APK Signature Scheme v2, kontrolou obsahu APK a notification payloadu.
- Přenosná záloha RC31 `bazals-pocket-garden-2026-08-20 (2).htgbackup` prošla kontrolou integrity; obsahuje save schema 29, 62 mincí, 122 XP, dvě vlastněné dekorace a dvě obsazená dekorační místa.
- Fyzický audit `.godot/android-device-audit/20260820-181832Z` bezpečně nainstaloval RC32 přes předchozí build, ověřil shodný SHA-256, migraci save schema 29 → 30, zachování stabilních polí a 11/11 platných vzorků během 60 sekund se 100% pobytem aplikace v popředí a nulovým počtem fatálních nálezů.
- `PHASE105_ANDROID_TECHNICAL_GATE=PASSED`.
- `PHASE105_PHYSICAL_ANDROID_MANUAL_GATE=IN_PROGRESS`.

Aktuální RC33:

- Soubor: `builds/android/bazals-pocket-garden-0.47.0-rc33-arm64-debug.apk`.
- Verze: `0.47.0-rc33` / code 50 / save schema 30.
- Velikost: 101,26 MiB.
- SHA-256: `68C438C2B8E423969B10E5A242A6981E790A09A26DB156BE538495BD9C94CA34`.
- Release důkazy: `.godot/release-candidate/20260820-193137Z`; lokální release výsledek `RELEASE_CANDIDATE=PASSED_LOCAL`, fyzická brána `PENDING`.
- APK prošlo Gradle exportem, podpisem APK Signature Scheme v2, kontrolou obsahu, notification payloadu i povinným Android Back manifestem.
- Fyzický audit `.godot/android-device-audit/20260820-194126Z` nainstaloval přesně tento hash, potvrdil verzi/code, save schema 30 → 30 a sémantické zachování stavu. Během 60 sekund získal 11/11 platných vzorků, 100 % času v popředí a nulový počet fatálních nálezů; technická brána je `PASSED`.
- HyperOS odmítl vzdálenou injekci systémového tlačítka Zpět bez privilegovaného oprávnění `INJECT_EVENTS`. To není pád ani chyba hry; tento jednotlivý vstup a doručení upozornění proto zůstávají ruční bránou.

## Automatický Android 16 emulátor

- Trvalý virtuální telefon `HowToGrow_API36` používá Android 16 / API 36 / x86_64 a hostitelský GPU. Samostatný exportní profil `Android Emulator x86_64` ponechá produkční ARM64 kandidáty beze změny.
- Emulátorové APK po opravě: `builds/android/bazals-pocket-garden-phase105-rc32-emulator-x86_64-debug.apk`, 105,95 MiB, SHA-256 `C70E37AF420AD4246E5A50042AC669DD320C48C9811BF682AF639BC5BAF6972B`.
- Export znovu prošel Gradle sestavením, podpisem APK v2, kontrolou runtime obsahu, notification payloadu i novou kontrolou Android Back manifestu.
- Funkční regrese po opravě: `MVP_TESTS_PASSED=1269`. Finální validační běh `.godot/validation/20260820-193137Z` zachytil všechny obrazy a všech 15/15 povinných pixelových bran prošlo. Schválené šipky fáze 103 kryjí pouze dvě úzké masky; referenční PNG ani tolerance se neměnily.
- Na čistém emulátorovém postupu automatika zasadila a zalila dva nezávislé záhony, ověřila zůstatek 10 mincí, schema 30 a zachování obou záhonů i jejich offline růstu po ukončení a opětovném spuštění aplikace.
- Android 16 odhalil chybu původního RC32: systémové Zpět ze skleníku ukončilo proces. Oprava nastavuje `application/config/quit_on_go_back=false` už při inicializaci Godotu a `android:enableOnBackInvokedCallback="false"` v Android manifestu; export tuto volbu nově povinně kontroluje.
- Po opravě systémové Zpět vrátilo skleník i hráčský pokoj na stojan při zachování stejného procesu. Druhé Zpět z čistého stojanu aplikaci bezpečně ukončilo a save zůstal čitelný se schema 30, 10 mincemi, čtyřmi záhony a dvěma obsazenými záhony.
- Obrazové důkazy jsou v `.godot/emulator-audit/20260820-191224Z-back-fix`; během finální navigační kontroly nebyl zachycen pád, ANR ani GDScript chyba. Jediný diagnostický záznam byl nefatální první překlad shader cache.
- Produkční ARM64 soubor RC32 zůstává neměnný. Oprava tlačítka Zpět je zahrnuta v samostatném RC33 a nepřepisuje existující kandidát.

## Krátká fyzická kontrola RC33

1. Hotovo automaticky: RC33 bylo nainstalováno přes stávající data bez mazání profilu a ověřeno proti přesnému SHA-256.
2. Hotovo technicky: sémantické porovnání potvrdilo zachování save schema 30 a stabilních hodnot. Vizuální kontrola mincí, dekorací a rozpracovaných záhonů zůstává vhodným ručním potvrzením.
3. Otevřít skleník a použít systémové gesto Zpět: hra se musí vrátit na stojan a nesmí se ukončit.
4. Stejně ověřit návrat z hráčského pokoje. Další Zpět z čistého stojanu má hru bezpečně uložit a ukončit; po opětovném otevření musí save zůstat zachován.
5. Spustit 20sekundové testovací upozornění, zhasnout displej a potvrdit skutečné doručení. Tento krok zůstává hardwarový kvůli systémovému oprávnění a úspoře baterie.

## Ruční telefonní kontrola po bezpečné instalaci

1. Hotovo: v RC31 vytvořena a ověřena nová přenosná `.htgbackup` záloha.
2. Hotovo automaticky i ručně: RC32 byla nainstalována bez ztráty stávajícího save a hráč potvrdil zachované mince, knihy, monsteru i rozmístění dekorací v pokoji (`pokoj ready`).
3. Hotovo ručně: hráč potvrdil čitelnou a dotykově dostupnou obrazovku skleníku se čtyřmi prázdnými záhony v mřížce 2×2 (`skleník ready`).
4. Hotovo ručně: na záhonu 1 bylo zasazeno cherry rajče, odečet přesně 10 mincí proběhl správně a záhon přešel do stavu čekání na zálivku (`záhon 1 ready`).
5. Hotovo ručně: bezplatná zálivka záhonu 1 nezměnila zůstatek, spustila přibližně šestihodinový růst a další akce zůstala během růstu bezpečně vypnutá (`zálivka ready`).
6. Zasadit a zalít také záhon 2; záhon 1 se nesmí změnit ani přepnout.
7. Vrátit se na stojan systémovým Zpět, aplikaci úplně zavřít a znovu otevřít.
8. Ve skleníku potvrdit oba rostoucí záhony, zachovaný zůstatek a nižší zbývající čas.
9. Po doběhnutí alespoň jednoho záhonu potvrdit oranžové `SKLIDIT`, odměnu +24 mincí / +8 XP a návrat záhonu do volného stavu.
