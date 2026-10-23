# Lišta stojanu – návrh ke schválení

Společný malovaný šalvějový podklad místo čtyř výrazně orámovaných karet. Původní PNG ikony zůstaly beze změny. Čtyři 68 × 68 dotykové cíle mají mezery 10 px; popisky používají jednotnou velikost 9 místo 6–7. Zkratka ZÁM je nahrazena symbolem zámku; odemčení a upozornění na výzkum mají původní chování.

## Ověření

- PHASE183_TESTS_PASSED=41; výzkum, zamčení/odemčení, rozložení a nastavení.
- Nativní Godot: všechna čtyři tlačítka otevřou svou obrazovku a systémové Zpět ji zavře.
- RESPONSIVE_LAYOUT_SMOKE=PASSED, 15 případů včetně menšího displeje a safe area.
- Nativní snímky 432 × 960 a 360 × 800. Porovnání před/po: mimo oblast lišty jsou obrazy pixelově shodné.
- git diff --check bez chyb. Uživatelský profil byl izolován; schválené reference zůstaly beze změny.

Zdrojový projekt je upravený; návrh zatím nebyl instalován do emulátoru, nahrán na GitHub ani převeden na schválenou vizuální referenci.

Snímky: porovnani.png, stojan-432.png, stojan-360.png, odemceny-vyzkum-360.png.
