# Fáze 112 — lokální mobilní přijetí RC36

Stav: **dokončeno · krátká lidská, reboot i přirozená long-delay brána prošly**.

## Cíl a hranice

Fáze 112 ověřuje na fyzickém telefonu skutečné dotyky, systémové dialogy a návratové cesty immutable RC36. Nemění hru, ekonomiku, save schema 32 ani Android artefakt. Publikování, AAB, release keystore a Google Play zůstávají výslovně mimo rozsah.

Autoritativní APK zůstává `builds/android/bazals-pocket-garden-0.50.0-rc36-arm64-debug.apk`:

- verze `0.50.0-rc36`, code 53;
- velikost 106 193 804 B;
- SHA-256 `9987F544E5FC692BA0F05BE183FDCDB6E426572A769FDC6D9CA01DDB44936860`.

## Automatický předběžný důkaz

Nedestruktivní audit `.godot/android-device-audit/20260821-184424Z` proběhl na Xiaomi 2201116SG / Android 13 bez instalace a bez smazání dat:

- instalovaný hash přesně odpovídá immutable RC36;
- save zůstal schema `32_TO_32` a sémantická kontrola prošla;
- zachováno 66 mincí, 159 XP, 10 slotů a stav příběhu;
- 54/54 platných vzorků, 100 % v popředí, 0 crash/ANR/Godot fatal nálezů;
- `ANDROID_TECHNICAL_GATE=PASSED`;
- nativní Godot surface neposkytl frame data, proto `UNAVAILABLE_NATIVE_GL` není výkonový PASS;
- package-scoped notification řádky nedokládají skutečné doručení;
- baterie skončila na 96 % a 40,2 °C při USB napájení; systémový thermal údaj byl nekonzistentní a není lidským teplotním verdiktem.

Fyzické screenshoty z auditů `20260821-163933Z` a `20260821-184424Z` potvrzují bez ořezu návratový modal, čtyři skleníkové záhony, výběr tří plodin, stojan s `3 AKCE`, obchod a bezpečné horní i spodní okraje. Dřívější ruční průchod také potvrdil skutečnou sklizeň 22 → 46 mincí a 27 → 35 XP. Toto nejsou náhrady za níže uvedené dotyky a systémové dialogy.

Před ručním průchodem je `POST_NOTIFICATIONS` na telefonu `granted=false`; oprávnění se musí udělit normálním Android dialogem vyvolaným ze hry.

## Jediný souhrnný ruční průchod

Pokud kterýkoli bod selže, průchod se zastaví a nahlásí se číslo bodu. Odpověď `hotovo` znamená, že byly lidsky pozorovány všechny body 1–6 bez chyby. Uživatel tento výsledek potvrdil 21. srpna 2026.

1. **Bezpečná výchozí záloha.** Na stojanu otevři `ZVUK` → `ZÁLOHA POSTUPU`. Jednou otevři `VYTVOŘIT ZÁLOHU` a systémový dialog zruš; hra nesmí ukázat falešný návratový souhrn. Potom zálohu vytvoř a ulož jako `.htgbackup` do telefonu.
2. **Skutečný dotyk ve skleníku.** V `ROSTLINY` → `SKLENÍK` vyber volný záhon; pokud žádný není, nejdřív jeden skliď. Klepni na dostupné `RAJČE` nebo `PAPRIKA`: mince se odečtou právě jednou a záhon musí ukázat potřebu zálivky. Klepni na zálivku a ověř stav růstu/zálivky i dosažitelnou spodní navigaci.
3. **Květináč a systémové Zpět.** Na stojanu osaď první dostupný květináč semínkem, otevři jeho detail a použij systémové gesto/tlačítko Zpět. Musí se vrátit do stojanu. Otevři libovolný modal a Zpět jej musí nejdřív zavřít. Přejdi na `SKLAD`, `OBCHOD` nebo `MĚŘENÍ`; další Zpět se musí vrátit na `ROSTLINY`, ne hru okamžitě ukončit. Zároveň zkontroluj svislý tah v dlouhém seznamu a vodorovný tah mimo seznam.
4. **Skutečné Android upozornění.** Ve stojanu otevři `CENTRUM PÉČE`, klepni na `POVOLIT ANDROID UPOZORNĚNÍ` a v systémovém dialogu povol oznámení. Potom klepni na `OVĚŘIT UPOZORNĚNÍ ZA 20 S`, přejdi na plochu a počkej alespoň 25 sekund. Upozornění musí dorazit; po klepnutí se musí otevřít hra a květináč 1, nikoli náhodná obrazovka.
5. **Import a restart.** Přes `ZVUK` → `ZÁLOHA POSTUPU` zvol `VYBRAT ZÁLOHU K OBNOVĚ`. Před potvrzením musí náhled ukázat původní úroveň, mince a počet obsazených květináčů. `POTVRDIT OBNOVU` musí vrátit původní stav. Hru úplně zavři a znovu spusť; obnovený stav musí zůstat.
6. **Bezpečná nová hra a návrat.** Znovu otevři `ZÁLOHA POSTUPU`. První `ZAČÍT NOVOU HRU` musí jen změnit tlačítko na `OPRAVDU ZAČÍT ZNOVU`; teprve druhé klepnutí smí založit novou hru. Potom se vrať do `ZÁLOHA POSTUPU`: `OBNOVIT PŘEDCHOZÍ HRU` musí nejdřív ukázat původní úroveň, mince a počet rostlin a změnit se na `POTVRDIT NÁVRAT`. Potvrď návrat, hru znovu spusť a ověř původní postup. Během celého průchodu nesmí být animace nepříjemná, ovládání nedosažitelné ani telefon nezvykle horký.

## Výsledek lidského průchodu

Všech šest bodů výše bylo uživatelem potvrzeno jako `PASSED` jednou souhrnnou odpovědí `hotovo`:

- document picker šel bezpečně zrušit a přenositelná `.htgbackup` záloha vznikla;
- výběr skleníkové plodiny, jednorázové odečtení mincí a zálivka reagovaly na skutečný dotyk;
- detail květináče, modal, vedlejší záložka, svislý seznam a vodorovný tah dodržely očekávanou mobilní navigaci;
- oprávnění bylo uděleno systémovým Android dialogem, 20sekundové upozornění dorazilo a jeho klepnutí otevřelo květináč 1;
- import ukázal náhled, vrátil původní postup a přežil restart;
- dvoukroková nová hra i dvoukrokový návrat předchozí hry fungovaly a obnovený postup přežil další restart;
- krátký průchod byl ovladatelný, animace příjemná a uživatel nepozoroval nezvyklé zahřívání.

Navazující readback `.godot/android-device-audit/20260821-190953Z` nic neinstaloval ani nemazal. Potvrdil přesný hash RC36, save schema `32_TO_32`, původních 66 mincí, 159 XP, 10 slotů a 0 obsazených pokojových květináčů. Všech 11/11 vzorků bylo platných a v popředí, fatal count zůstal 0 a `ANDROID_TECHNICAL_GATE=PASSED`. Android současně hlásil `POST_NOTIFICATIONS: granted=true`, tři package-scoped alarm řádky a třináct notification řádků včetně aktivního záznamu `Bazal’s Pocket Garden · test upozornění`; `phase112-final.png` zachycuje skutečné oznámení v systémové liště. Tyto systémové důkazy doplňují, ale nenahrazují výše uvedené lidské potvrzení klepnutí a cíle.

Závěrečná deterministická validace `.godot/validation/20260821-191441Z` skončila `MVP_TESTS_PASSED=1308`, `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Všech 14 aktivních pixelových gate prošlo; `room` a `locked-slots` zůstaly pouze reportovací a žádná schválená reference, maska ani tolerance se nezměnila.

Po finálním zápisu dokumentace prošel také autonomní `Quick` běh `.godot/automation/20260821-191729Z`: regrese skončila exit kódem 0, log obsahuje `MVP_TESTS_PASSED=1308` a report emituje `AUTOMATION_TECHNICAL_GATE=PASSED` i `HOW_TO_GROW_AUTOMATION=PASSED`. Obecný runner záměrně dál vypisuje statický lidský checklist jako pending, protože lidské pozorování nesmí sám schválit; autoritativní rozdělení aktuálního výsledku je v níže uvedených značkách fáze 112.

## Oddělené dlouhodobé důkazy

Připomínka po skutečném restartu telefonu je dokončená. Hra po rebootu nebyla ručně otevřena, `CareBootReceiver` přijal `BOOT_COMPLETED` v 21:35:57 a obnovený alarm v 21:36:51 doručil systémové oznámení `Bazal’s Pocket Garden · kontrola péče` s textem `Květináč 1 · Potřebuje světlo.`. Snímek `.godot/android-long-delay/20260821-213651Z/phase112-reboot-reminder.png` a souhrn `reboot-reminder-evidence.md` zároveň potvrzují launcher v popředí a vyčištění doručeného reminder payloadu. `PHASE112_REBOOT_REMINDER_GATE=PASSED`.

Přirozený skleníkový návrat byl dokončen 22. srpna 2026 bez změny systémového času, instalace novějšího APK nebo ADB injekce dotyku. Před jediným úspěšným otevřením aplikace byl proces nepřítomný a sanitizovaný read-only výpočet potvrzoval, že osmihodinová sladká paprika v záhonu 1 už přirozeně dosáhla `READY`. Po odemčení telefonu návratový souhrn přímo zobrazil `Během nepřítomnosti uběhlo 8 h 47 min.` a řádek `Skleník · záhon 1 · SLADKÁ PAPRIKA · PŘIPRAVENO KE SKLIZNI`. Současně ukázal stejné `greenhouse_ready` řádky pro zbývající tři záhony.

Snímek `.godot/android-long-delay/20260821-213651Z/phase112-greenhouse-ready-return.png` má SHA-256 `0F84BC07A2E822B3F76A5984B5390CB309CFE8A2A493976C147CBAF6E8EB3347`. Sanitizovaný post-launch stav potvrdil schema 32, záhon 1 `sweet_pepper` / `28800/28800` / `READY`, záhon 2 `cherry_tomato` / `21600/21600` / `READY`, záhony 3–4 `sweet_pepper` / `28800/28800` / `READY` a targeted fatal count 0. Raw save ani úplný logcat se nepersistovaly; úplný sanitizovaný souhrn je v `greenhouse-ready-evidence.md`. `PHASE112_LONG_DELAY_GATE=PASSED`.

Po tomto finálním zápisu prošla úplná validace `.godot/validation/20260822-042334Z` s `MVP_TESTS_PASSED=1351`, capture, visuals i `HOW_TO_GROW_VALIDATION=PASSED` a všemi 14 aktivními obrazovými branami. Následný Quick `.godot/automation/20260822-042507Z` skončil exit kódem 0 a markery `AUTOMATION_TECHNICAL_GATE=PASSED` i `HOW_TO_GROW_AUTOMATION=PASSED`. Tyto automatické výsledky nenahrazují lidské potvrzení krátké mobilní brány; pouze dokazují technickou integritu aktuálního zdrojového stavu.

## Výstupní značky

Celá lokální fáze je uzavřena v tomto stavu:

```text
ANDROID_TECHNICAL_GATE=PASSED
PHASE112_SHORT_PHYSICAL_GATE=PASSED
PHASE112_REBOOT_REMINDER_GATE=PASSED
PHASE112_LONG_DELAY_GATE=PASSED
PUBLISHING_GATE=OUT_OF_SCOPE_BY_USER
```
