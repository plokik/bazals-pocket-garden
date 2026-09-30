# RC61 — dokončená sada oprav a měření

Kandidát `RC61-STABILITY-FINAL-20260930-V6`, Godot 4.7, verze 0.71.0-rc61, Android code 78, save schema 41. Navazuje na commit `9ee5ccf` ve větvi `fix/rc61-feedback-motion`. Jde o testovací debug balíky; vydaný GitHub RC61 není přepsaný.

## Opravy

- Detail rostliny používá dříve opravenou animaci ruky s konví a světla. Omezení kreslení brání přesahu do navigace; přerušení animace vrací ikonku do klidové polohy.
- Dva atlasy malovaných ovládacích prvků mají 24 hotových výřezů. `tools/bake_painted_ui.gd` reprodukuje původní odstranění magenty, ořez a převzorkování. Hra při startu neopakuje pixelové smyčky; původní atlasy zůstávají zachované.
- Titulek pokoje zakrývá celou původní podkladovou cedulku i na kratším displeji. Schválené rozložení při šířce 432 px zůstává zachované.
- Loading respektuje uložené omezení pohybu: klidné logo a ornamenty, statické berušky, krátké prolnutí místo mrakového rozpouštění. Ukazatel načítání nadále ukazuje postup. Čtení preference je omezené na 2 MiB a nemění save ani stav obnovy.
- Nativní počáteční splash používá schválené logo hry místo loga Godotu.
- Export vynechává 14 prokazatelně nepoužívaných historických podkladů. Zdrojové soubory nebyly smazané. Všech 299 původních importovaných textur, které zůstaly v APK, má shodné bajty s V2.
- Exporty mají jeden trvalý lokální debug podpis pro obě ABI. Klíč je v ignorovaném `.tooling/debug-signing/debug.keystore`, nikdy v Gitu. Každý export porovnává veřejný certifikát APK s tímto klíčem.
- CI používá už schválené RC61 reference, 34 aktivních bran a minimum 6849 regresních kontrol. Digest manifestu používá stejné LF konce řádků jako Git; PNG jsou nadále hashované beze změny bajtů. Žádná reference, maska ani tolerance se nezměnila.

## Automatické výsledky

| Kontrola | Výsledek | Lokální důkaz |
|---|---|---|
| Kompletní regrese, capture, vizuály | PASS; 6849 kontrol, 34/34 aktivních bran, 20 diagnostik | `.godot/validation/20260930-194307Z` |
| Statické CI, vizuální kontrakty, startup preference | PASS; pinned digest `D799AB4F869DCB13EBE5B6E5CD0C08BFE9FA352D82C4D88315B9CB67B2791DD7` | `.godot/ci/20260930-200455Z` |
| Výkon, sedm scénářů, 360 měřených snímků v každém | PASS; nejhorší CPU p95 19.556 ms, snímek p95 16.723 ms, 422 draw calls, 94.46 MiB sledované statické paměti | `.godot/performance/20260930-191104Z` |
| Zátěž, 48 cyklů napříč obrazovkami a dialogy | PASS; růst uzlů/orphanů/prostředků 0, změna statické paměti +0.059 MiB | `.godot/endurance/20260930-191409Z` |
| Pěstitelská progrese | PASS; 132 cyklů, 27 save roundtripů, výsledná úroveň 90 | `.godot/progression/20260930-191409Z` |
| Responzivní rozložení a safe area | PASS; 15 případů včetně malých displejů | `.godot/responsive/20260930-191409Z` |
| Opakované vytvoření výřezů | PASS; 24 PNG se shodným SHA-256 | `.godot/stability-final-20260930/baked-pixels.json` |
| Android export obou ABI | PASS; podpis/identita, payload, manifest, notifikace, privacy allowlist a 16KB alignment | `.godot/stability-final-20260930/export-*-brand.log` |

Výkonové hodnoty jsou měření na PC, nikoli FPS nebo spotřeba telefonu. Zátěžový průchod je ohraničený test, nikoli důkaz absence všech dlouhodobých úniků.

## Android API 36, vlastní testovací emulátor

Profil `Bazal_Stability_20260930`, x86_64, 1080×1920, host GPU. Původní starší AVD ani skutečný hráčský telefon nebyly vymazané.

- Aktualizace V2 → V5 a V5 → finální V6 přes `adb install -r` zachovaly celý save ukončené aplikace před prvním startem. Důkaz: `android-in-place-update.json`, `android-final-update.json` v adresáři tohoto auditu.
- Start, přechod do pokoje, běžné i omezené animace, postupující loading bar a Home/návrat byly ověřené. Dřívější průchod zasazením, zálivkou a přepínáním světla je v `RC61_STABILITY_REPORT.md`; dotčená herní logika se v této sadě neměnila.
- Export skutečným systémovým výběrem souboru vytvořil `.htgbackup`. Výběr zálohy ukázal náhled a potvrzení obnovilo postup. Readback potvrdil SHA-256 payloadu, schema, mince, XP, předání zahrady a druh/stádium všech rostlin. Omezení pohybu se po obnově pro účely následujícího testu přepnulo na plné animace.
- Snímky a sanitizované výsledky jsou v `.godot/stability-final-20260930`; záznam startu `android-normal-start-final.mp4`.

### Naměřený start

| Metrika | Předchozí V2 | Finální V6, tři ukončené procesy |
|---|---|---|
| Threaded load hlavní scény | 3809 / 4083 ms | 4272 / 2782 / 2619 ms |
| Vytvoření UI | 1834 / 1861 ms | 1547 / 1403 / 1616 ms |
| `STARTUP_MAIN_READY_MS`, od požadavku na hlavní scénu | 6048 / 6323 ms | 6172 / 4743 / 4789 ms |
| Android marker bezprostředně před příkazem launcheru → MAIN_READY | původně neměřeno | 10548 / 7937 / 7998 ms |

Finální medián vnitřní připravenosti je 4789 ms. Tyto běhy mají zahřátou filesystem cache a různou počáteční shader cache; nejde o řízené srovnání výkonu fyzického zařízení. Celý start je stále delší než samotné načtení hlavní scény. MAIN_READY nezahrnuje dokončení následného 0.95s mrakového přechodu. `am start -W` měří vykreslení Android aktivity, nikoli připravenost hry.

## Přesné finální APK

| ABI | Soubor | Bajty / MiB | SHA-256 |
|---|---|---|---|
| arm64 | `builds/android/bazals-pocket-garden-0.71.0-rc61-stability-20260930-v6-arm64-debug.apk` | 231564875 / 220.84 | `B12F7E04A38AF07DA625DFA51AC72533AC9F5EE8EFFE880A78526B49883173EC` |
| x86_64 | `builds/android/bazals-pocket-garden-0.71.0-rc61-stability-20260930-v6-x86_64-debug.apk` | 236481917 / 225.53 | `DF50549FC2EC50C6DA086E272054FD79578A29EB2D18178C8BFA468BE5F73547` |

Arm64 je proti V2 menší o 17675397 B (16.86 MiB). Nativní vlastní logo přidává přibližně 1.47 MiB proti mezilehlému V5; proto konečný rozdíl není dříve naměřených 18.32 MiB. Certifikát obou finálních balíků: `4EB193C20F460CD700071D4AA445AB47612C860461EBD8384C6654263E3A7A96`.

Výhradně V6 je finální kandidát. Mezilehlý V3 neprošel payload kontrolou; V4 měl jiný testovací podpis a nebyl přijatý jako kompatibilní aktualizace. Jeden širší návrh titulku překročil původní vizuální toleranci; byl opraven tak, aby zachoval schválenou základní šířku. Tyto mezilehlé výsledky nejsou finální PASS.

## Omezení

- Fyzický telefon není připojený: skutečná baterie, teplota, FPS, dlouhé hraní, notifikace OEM a aktualizace reálných hráčských dat vyžadují samostatný telefonový průchod.
- Dříve vyzkoušený SwiftShader nevykreslil hru kvůli limitu fragmentových uniformů. Finální test proběhl s host GPU; problém softwarového backendu nebyl opravený a není potvrzená kompatibilita zařízení se stejně nízkým limitem.
- Systémový DocumentsUI na tomto ATD vracel černý screencap. Průchod soubory byl proveden přes skutečnou hierarchii Android UI a potvrzený exportem, náhledem ve hře a readbackem. Vizuální podoba systémového pickeru tím není přijatá.
- Testovací podpis byl zachován z V2 x86_64 tohoto emulátoru. Starší telefonní APK s jiným podpisem nelze aktualizovat tímto klíčem bez předchozího bezpečného řešení zálohy; tento audit skutečný telefon neodinstalovával.
- Google Play, produkční keystore/AAB, nová vydaná verze a rozsáhlý přepis monolitů nejsou součástí této sady oprav.
