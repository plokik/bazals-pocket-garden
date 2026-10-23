# Schválené výrobky a čajovna — zapojení do hry

Uživatel schválil vzhled, tři výrobky, ceny a odměnu slovem **„Souhlasím“**.
Tato složka obsahuje skutečné snímky běžné scény `main.tscn`, nikoli oddělený
ukázkový model. Zápis při průchodu používá skutečný SaveManager s izolovaným
APPDATA. Osobní desktopový ani telefonní profil se neotevíral.

## Výsledek

- Tři výrobky, samostatné skladové počty a obousměrné odkazy dílna/sklad.
- Přijetí, rozpracování, předání a trvale dokončená jednorázová zakázka.
- Odemčení potřebných bylin; čajovna na úrovni 5.
- Odměna 80 mincí a dvě semínka meduňky; ochrana limitu semen i dvojkliku.
- Staré čtyři recepty mají všechny dosavadní akce, animace a přechody k rostlinám.
- Save schema 44 s explicitní hranicí; schema 43 dostane prázdnou novou zásobu.

## Skutečný nativní průchod

Testovací stav: úroveň 5, 100 mincí a po 6 g čtyř potřebných suchých bylin.
Přijetí zakázky je ihned ve skutečném souboru. Výroba jednoho kusu od každého
stojí celkem 9 mincí. Před prvními snímky animace je každý kus již zapsaný.
Sklad potvrdí tři kusy. Po předání zůstává 171 mincí, dvě získaná semínka meduňky,
nula předaných výrobků a `teahouse=completed`. Tento save se načetl do nového
GameSession; opakované vyzvednutí odměny bylo odmítnuté.

Snímky šířek 360/432 ukazují všechny nové recepty, nabídku, stav předání i
dokončení po načtení. `storage-products-432.png` ukazuje skutečný sklad.
`care-recipes-*` dokládají dostupné původní recepty. `saved-completed.json` je
testovací uložená hra, ne hráčův osobní profil.

## Vizuální a funkční ověření

Přesné markery, počty a omezení jsou v `verification.json`.
Logy jsou pod `.godot/teahouse-integration-20261017/`.

- Kompletní funkční sada: **MVP_TESTS_PASSED=7665**.
- Nativní průchod skutečné hry: **80 kontrol**, šířky 360 a 432 px.
- Migrace skutečného dřívějšího emulátorového profilu schema 43: **32 kontrol**,
  zachované mince 39, XP 100, semínka, deset květináčů, tři skladové šarže a dekorace.
- Schválené originály všech tří nových ilustrací mají shodné SHA-256 jako návrh.
- Kompletní nativní snímání doběhlo s `HOW_TO_GROW_CAPTURE=PASSED`.
- Z 34 vizuálních bran prošlo 25 a 9 selhalo. Není tedy vydán marker
  `HOW_TO_GROW_VALIDATION=PASSED`.

Každé neúspěšné porovnání bylo prohlédnuto. Osm porovnává původní pokoj s již
dříve schválenou malovanou dílnou; deváté porovnává starou spodní lištu a text
Pokoj s dřívější současnou lištou a textem Dílna. Pro ověření vznikla úplná kopie
projektu s uloženými zdroji `main.gd`, `game_session.gd` a `workshop_modal.gd`
**před touto integrací**. Stejné snímání a původní manifest v této kopii opět
vrátily stejných devět selhávajících bran. Nová selhávající brána: **0**.
Původní i aktuální výsledky jsou zachované v `baseline-capture/report.json`
a `validation-final/report.json`; tolerance ani schválené baseline se neupravovaly.

Toto potvrzuje zachování současné hry mimo nový obsah, nikoli aktuálnost všech
historických referencí. Sada zůstává jako celek červená, dokud se samostatně
nevyřeší zastaralé reference se souhlasem uživatele.

Starší diagnostika Phase 166 se pokoušela přesouvat rostliny ve schválené pevné
malbě dílny a ukončovala celé snímání. Nově se tento report-only scénář označí
`PHASE166_DIAGNOSTIC_NOT_APPLICABLE=fixed_workshop_shelves` pouze u pevné dílny.
Nemá případ ve `visual-cases.json`. Pro starou přesouvatelnou scénu zůstává
původní průchod. Testy pevné dílny stále ověřují odmítnutí neplatného přesunu
a zachování zakoupených dekorací. Reference, masky a prahy se nezměnily.

Starší testy „budoucího schema 44“ nyní testují `SAVE_SCHEMA+1`, aby nová platná
verze zůstala podporovaná a další neznámá verze byla stále odmítnutá.
Samostatná hranice kola štěstí 43 je chráněná původním testem migrace.

Telefon ani Android APK nebyly v tomto kroku testovány. Nevznikl release ani
publikace na GitHub. Původní schválené obrázky a koncepty zůstaly zachované.
