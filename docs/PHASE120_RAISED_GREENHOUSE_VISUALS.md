# Fáze 120 — živý skleník s vyvýšenými záhony

Stav: lokální implementace, uživatelské perspektivní doladění, vizuální validace a immutable RC45 jsou dokončené; instalační device gate čeká pouze na připojení telefonu.

`PHASE120_RAISED_GREENHOUSE_VISUALS=PASSED_LOCAL`

## Cíl

Fáze převádí funkční skleník z plochého technického náhledu na čitelné herní prostředí inspirované uživatelskou referencí. Reference určuje atmosféru a hierarchii, nikoli hotový asset. Nové originální pozadí proto neobsahuje text, tlačítka, HUD, záhony ani herní stav; všechny interaktivní a proměnlivé prvky zůstávají vykreslené a řízené Godotem.

## Vizuální kontrakt

- Čtyři dřevěné vyvýšené záhony zůstávají v perspektivní sestavě 2×2 a každý má samostatný nejméně 64px dotykový cíl.
- Kompaktní obsah 360×620 používá menší zadní dvojici `145×96` px na souřadnicích `(26,170)` a `(189,170)` a větší přední dvojici `162×128` px na `(14,278)` a `(184,278)`. Horní zemina, boční rám a vysoká přední stěna nesmějí být nahrazené plochou kartou nebo truhlíkem.
- Běžný obsah 432×780 používá zadní záhony `178×144` px na `(28,190)` a `(226,190)` a přední `196×200` px na `(14,362)` a `(222,362)`. Zadní řada je tedy užší a výš, přední širší a blíž hráči; řady se nepřekrývají a sledují perspektivu podlahy.
- Vybraný záhon má zlatý směrový akcent; růst používá vlastní průběh, čekání na zálivku kapku a připravená sklizeň zlatý stavový akcent.
- Pět plodin, jejich ceny, zámky úrovní 1–5, zakázka, Zakázka+, reputace i všechny odměny zůstávají funkčně beze změny.
- Ambientní světlo se zastaví při pauze a vypne při omezeném pohybu. Deterministické capture běhy proto zůstávají stabilní.
- Stavový panel, primární akce a pět 64×64 voleb osiva se nesmějí překrýt se záhony ani spodní navigací.

## Asset a integrita

- Originální prostředí: `assets/ui/greenhouse/greenhouse_interior_phase120.png`.
- Zdrojová uživatelská reference se nekopíruje do exportu a není runtime závislostí.
- Dřívější schválené reference, crop, masky a tolerance se automaticky nepřepisují.
- Save schema zůstává `37`; tato fáze nepřidává měnu, plodinu ani nový uložený klíč.

## Generování originálního prostředí

Asset vznikl vestavěným režimem `imagegen` jako nový bitmapový podklad. Finální prompt požadoval: „Originální portrétní mobilní herní skleník v teplém ručně malovaném komiksovém stylu; prosklená zelená konstrukce, slunná zahrada, medová dřevěná podlaha a dekorativní listy pouze při krajích. Střed, horní titulková plocha a spodní část musí zůstat klidné pro skutečné Godot UI a matici 2×2. Prostředí bez textu, HUD, tlačítek, ikon, ukazatelů, postav, záhonů, truhlíků, loga a watermarku; uživatelská reference slouží pouze pro náladu a hierarchii, nikoli ke kopírování kresby.“

## Verze a distribuce

- Zdrojová/exportní identita: `0.57.0-rc45`, Android version code `62`.
- Cílový immutable ARM64 artefakt: `builds/android/bazals-pocket-garden-0.57.0-rc45-arm64-debug.apk`.
- Aktualizace telefonu musí použít explicitní verzovaný artefakt a `adb install -r`; data aplikace se nesmějí mazat.
- RC36 až RC44 zůstávají immutable; RC44 je zachovaný jako stav před perspektivním doladěním. Veřejné publikování je dál `OUT_OF_SCOPE_BY_USER`.

## Lokální přijetí

- Regrese: `MVP_TESTS_PASSED=1374`; navíc přesně hlídá perspektivní geometrii pro kompaktní i běžný mobilní obsah.
- Finální how-to-grow validation: `.godot/validation/20260822-102541Z`, capture, visuals, full validation a všech 14 aktivních obrazových gate `PASSED`.
- Performance: CPU p95 nejvýše 12,643 ms, frame p95 16,700 ms, 449 draw calls a 86,16 MiB statické paměti.
- Endurance: 48/48, sedm save roundtripů, nulový růst uzlů, orphanů i zdrojů a 0,02 MiB růstu paměti.
- Progression: 132/132, všech 11 druhů a 27 diskových save/load roundtripů.
- Responsive: 8/8 včetně přesné kompaktní geometrie vyvýšených záhonů.
- Release: `.godot/release-candidate/20260822-102540Z`, export, APK Signature Scheme v2, payload i notification payload `PASSED`.

Immutable `builds/android/bazals-pocket-garden-0.57.0-rc45-arm64-debug.apk` má 108 222 968 B a SHA-256 `F58C6A79965B9DB77ACEF7338050CA46D444E0882DB56C531F6133D072F425A0`. Alias je bajtově shodný. RC44 zůstalo nedotčené s 108 222 804 B a SHA-256 `3C72EE3261DB5E23BB0B16EEB71C7FC95827028CF0923A62388A61D12CF7C850`.

## Obnova validačního pokrytí

Po uvolnění zaplněného disku bylo odstraněno 13 starých necitovaných validačních adresářů a jeden prázdný adresář neúspěšného release pokusu. Žádný zdrojový soubor ani dokument na ně neodkazoval; finální release validation `.godot/validation/20260822-102541Z`, release audit `.godot/release-candidate/20260822-102540Z`, immutable APK i schválené reference zůstaly zachované.

Náhradní úplná validation `.godot/validation/20260822-104207Z` znovu vytvořila 215 souborů o 209 277 613 B a prošla s `MVP_TESTS_PASSED=1374`, `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Všech 14 aktivních obrazových bran prošlo a SHA-256 `comic-greenhouse-preview.png` přesně odpovídá původní finální release validaci. Tento nový balík obnovuje současné validační pokrytí, ale záměrně se nevydává za historické meziběhy pod jejich původními časovými značkami.

## Otevřená fyzická brána

`PHASE120_ANDROID_DEVICE_GATE=PENDING_DEVICE_CONNECTION`

Telefon nebyl při uzavření lokálních bran dostupný přes ADB, proto RC45 zatím není nainstalované a poslední nainstalovanou verzí zůstává RC36. Po připojení se RC45 nedestruktivně nainstaluje přes existující aplikaci pomocí explicitního verzovaného APK a `adb install -r`; data aplikace se nemažou. Technický audit musí ověřit přesnou identitu, migraci schema 32 → 37, zachování významového save a nulové crash/ANR/fatal nálezy. Automatický technický průchod se vykáže odděleně od subjektivního lidského potvrzení dotyku, čitelnosti, prostorového dojmu a pocitu z animací.
