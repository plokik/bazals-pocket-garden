# Bazal’s Pocket Garden 0.71.0-rc61

RC61 je testovací Android prerelease zaměřená na první minuty hry a příjemnější práci s rostlinami.

## Novinky

- Nová živá úvodní obrazovka s logem Bazala, animovaným postupem načítání, beruškami a rozplynutím do pokoje.
- Přepracované obrazovky denní výzvy a bylinkového herbáře ve sjednoceném malovaném stylu.
- Výraznější detail rostliny, bezpečnější modaly a opravené okraje tlačítek, ikon a scrollovacích ploch.
- Nová animace zasazení: ruka vloží semínko do květináče a rostlina na ni naváže.
- Hráč může obsazený květináč vyčistit a zvolit pro něj novou rostlinu; potvrzení chrání původní rostlinu před nechtěnou výměnou.

## Ověření

- Funkční regrese: `MVP_TESTS_PASSED=6821`.
- Release kandidát před publikací ověřuje vizuální kontrakt, deterministickou validaci, výkon, endurance, postup, responzivní rozvržení a podepsaný ARM64 debug APK.

## Rozsah

Jde o GitHub prerelease s debug APK. Google Play ani produkční AAB nejsou součástí tohoto vydání.
