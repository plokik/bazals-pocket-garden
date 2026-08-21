# Fáze 106 — volba skleníkové plodiny

Stav: dokončeno, zabaleno, technicky ověřeno a ručně přijato na fyzickém telefonu. Fáze rozšiřuje funkční skleník bez nové měny, obchodu, inventáře semen nebo grafických souborů. Immutable RC34 obsahuje papriku, save schema 31 i opravený návrat spodním tlačítkem `ROSTLINY`; historický RC33 zůstává nedotčený na schema 30.

## Herní rozsah

| Plodina | Výsadba | Růst | Sklizeň | Čisté mince |
| --- | ---: | ---: | ---: | ---: |
| Cherry rajče | 10 mincí | 6 hodin | 24 mincí + 8 XP | +14 |
| Sladká paprika | 14 mincí | 8 hodin | 34 mincí + 11 XP | +20 |

- Prázdný vybraný záhon nabízí dvě explicitní 64px volby místo nejednoznačné výchozí akce.
- Po zasazení obě plodiny používají stejný tok: jedna bezplatná zálivka, online/offline růst a jednorázová sklizeň.
- Čtyři záhony zůstávají samostatné; jejich plodiny, časy ani odměny se navzájem nemění.
- Paprika má vlastní oranžovožlutou kódovou kresbu. Zdrojové PNG ani stávající obrazové reference se neměnily.
- Spodní tlačítko `ROSTLINY` je kanonický návrat na stojan. Cesta `skleník → Sklad → ROSTLINY` proto nezachovává skleník jako skrytou podlokaci; přímé tlačítko `STOJAN` ve skleníku zůstává beze změny.

## Ukládání a důvěryhodnost

- Hlavní save se zvyšuje z 30 na 31.
- Schema 30 autorizuje pouze historické `cherry_tomato`; podvržené `sweet_pepper` z takového save se nenačte.
- Schema 31 autorizuje přesně `cherry_tomato` a `sweet_pepper`. Neznámá ID, vadné typy, růst nad cílový čas a další položky nad čtyři záhony jsou odmítnuté nebo bezpečně omezené.
- UI volá explicitní `plant_greenhouse_crop(slot, crop_id)`. Původní obecná akce dál volí rajče pouze kvůli zpětné kompatibilitě existujících volání a testů.

## Ověření

- Autoritativní release validace: `.godot/validation/20260820-204609Z`.
- Funkční výsledek: `MVP_TESTS_PASSED=1278`, včetně skutečných stisků `skleník → Sklad → ROSTLINY`.
- Obrazový výsledek: `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED`, `HOW_TO_GROW_VALIDATION=PASSED`.
- Responzivní matice: `.godot/responsive/20260820-195655Z`, 7/7 případů. Kontroluje oba 64px cíle, hranice obrazovky a jejich nepřekrytí.
- `comic-greenhouse-preview.png` potvrzuje obě volby na prázdném záhonu; `comic-greenhouse-pepper-growing.png` potvrzuje odlišnou papriku při 75% růstu. Oba snímky jsou reportovací, nikoli nové schválené reference.
- Žádná reference, maska ani tolerance validační brány se nezměnila.

## Android hranice

- Soubor: `builds/android/bazals-pocket-garden-0.48.0-rc34-arm64-debug.apk`.
- Verze: `0.48.0-rc34` / code 51 / save schema 31.
- Velikost: 101,27 MiB.
- SHA-256: `D31E42B303319020CDBB839B3935F1008190D410172EEAEC88BE9986C2CCAB02`.
- Lokální release audit: `.godot/release-candidate/20260820-204608Z`. Validace, výkon, 48cyklová endurance, 132cyklový postup, responzivní matice 7/7, Gradle export, podpis v2, APK payload i notification payload prošly.
- Fyzický audit `.godot/android-device-audit/20260820-204916Z` nainstaloval RC34 přes RC33 bez mazání dat, potvrdil shodný hash, migraci save 30 → 31 a sémantické zachování stabilních hodnot. Během 60 sekund prošlo 11/11 vzorků, aplikace byla 100 % času v popředí a fatální nálezy zůstaly na nule.
- Technická fyzická brána je `PASSED`. Dne 20. 8. 2026 uživatel ručně potvrdil volbu, zasazení a zálivku papriky, zachování rozpracovaného záhonu i opravenou cestu `skleník → Sklad → ROSTLINY → stojan`; tato dotyková část je `PASSED`. Skutečné systémové upozornění, delší bateriový běh a teplota zůstávají samostatnou lidskou bránou.
