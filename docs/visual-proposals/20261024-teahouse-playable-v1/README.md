# Čajovna: první tři hratelné úrovně

Stav 24. 10. 2026: zapojeno do hlavní hry, nainstalováno a ověřeno v Android emulátoru. Nové rozhraní a průchod jsou připravené k osobnímu schválení; nejde o novou schválenou vizuální referenci. Změny této etapy zůstávají lokální, bez commitu, GitHub push a release.

## Co lze hrát

- Šipka **ČAJOVNA →** otevírá malovanou mapu. Záložka **Dílna** zpřístupní skutečnou výrobu, uložený vzhled, živého kocoura a kolo štěstí.
- Úroveň 1: Svěží ráno, 6 máty + 3 meduňky, 20 tahů. Úroveň 2: Klidný večer, 8 heřmánku + 6 levandule, 18 tahů. Úroveň 3: Zahradní posezení, po 6 mátě, meduňce a heřmánku, 18 tahů. Bez časového limitu.
- Nejlepší výsledek 1–3 hvězdy se ukládá; postup odemyká úrovně postupně. První dokončení každé vydá 30 mincí a 2 semínka meduňky. Úkol za 6 hvězd vydá jednou 40 mincí. Další vyznačená místa 4–10 jsou výslovně připravované úrovně.
- Odměna a postup se potvrdí jediným uložením. Selhání zápisu vrátí transakci a ponechá výsledek k opakovanému potvrzení. Plné zásoby ponechají semínka k pozdějšímu vyzvednutí. Opakování, zavření ani opožděný callback neduplikují odměnu.
- Formát uložení 47; migrace starších profilů zachovává původní herní data a začíná s prázdným postupem čajovny.

## Skutečný průchod

[Přehrát záznam](gameplay-cajovna.mp4): 50,30 s, 1080 × 2400, 30 fps, H.264 CRF 17 + AAC 256 kbit/s. Obsahuje produkční mapu, dílnu, skutečné ovládání celé první objednávky, nalévání, odměnu, odemčení druhé úrovně a výrobu. Hudba i efekty pocházejí ze hry; zvuk neklipuje (maximum −13,1 dBFS).

Záznam používá izolovaný demonstrační profil a produkční skripty, pouze rozlišení movie renderu je zvýšené na 1080 × 2400. `capture.json` obsahuje skutečné průběžné stavy. `source-snapshot.json` identifikuje zachycené zdroje; následné dvě opravy prvního spuštění a životnosti odloženého stylování jsou v `delivery-source-snapshot.json`. Grafika a pravidla mezi oběma stavy nebyly změněny. Soubory `emulator-*.png` jsou skutečné snímky finálního Android balíčku.

## Ověření

- **8 593 funkčních kontrol prošlo**, `HOW_TO_GROW_CI=PASSED`: `.godot/ci/20261024-074420Z`. Obsahuje všechny tři úrovně přes skutečné ovládání, nalévání, návraty, nedostupnou úroveň, rollback, duplicity, migraci, plné zásoby, výměnu profilu a bezpečné oblasti.
- Android odhalil a pomohl opravit první otevření čajovny v `Main._ready`: odloženě přidaná vstupní vrstva blokovala dialog obnovy. Regresní test nyní skutečně kliká na potvrzení obnovy při prvním spuštění. Paleta bezpečně přeskočí zrušené ovládací prvky čekající na odložené stylování.
- Deterministický vizuální běh `.godot/validation/20261024-072840Z`: **33/34 vynucovaných porovnání prošlo**, celkový stav zůstává **FAILED**. Jediná neshoda showroomu (MAE 14,091654, RMSE 35,357709, 26,9796 %) je totožná s již zdokumentovanou opravou z commitu `252566e`, před touto etapou. Historická reference stále ukazuje starý pokoj. Izolovaný render HEAD `2ae007b` potvrdil stejný obsah showroomu; rozdíl proti novému snímku je pouze v hodnotách podkladového HUD. Viz [historický audit](../../audit/20261023-emulator-fixes/README.md) a [současný report](visual-report.md).
- Historické snímky samostatné dílny nyní výslovně zavřou nový hub běžným `close()`, takže stále porovnávají původní rozložení se současným živým rendererem. Reference, manifest, masky, ořezy i prahy zůstaly nezměněné. Digest schválených referencí: `81C18A8090A80C4A6B1D05124FD6CCE974AB48FA44D998B630992FBEC133CF7F`.
- Export prošel podpisem, původní podpisovou identitou, ABI, manifestem, obsahem balíčku, reklamním SDK allowlistem a 16KB zarovnáním. APK SHA-256: `1D2D27391F3AF82F06D17DDCA398F3F7A6DA615FED20260865FC8B3EC0D98850`.

## Emulátor a uložená hra

AVD `Bazal_Current_Source_API36`, `emulator-5554`, 1080 × 2400. Aktualizace proběhla přes `adb install -r`; první aktualizace ponechala všech 30 původních souborů shodných po bajtech. Primární save i jeho záloha byly už před aktualizací prázdné (0 B). Původní archiv zůstává v `tmp/teahouse-levels-20261024/device-before/original-files.tar`.

Po výslovném souhlasu „Ano, založ novou testovací hru“ byla nová hra založena oběma potvrzeními v herním dialogu. Tutorial byl přeskočen přes UI. První úroveň byla dokončena nativními Android gesty, nalita za tři hvězdy a výsledek vyzvednut. Poté byly otevřeny dílna a skutečné recepty. Restart aplikace potvrdil v hlavním souboru i záloze schéma 47, `best_stars=[3,0,0]`, odměnu pouze za první úroveň, 60 mincí a 2 semínka meduňky. Nový proces nemá chyby skriptů ani fatální výjimky. Hra zůstává otevřená na mapě s odemčenou druhou úrovní.

Fyzický telefon ani dlouhodobý výkon se v této etapě netestovaly.
