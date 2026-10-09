# Schválený malovaný herbář, 9. 10. 2026

Navazuje na schválené Centrum péče a měření. Uživatel schválil skutečný
Godot náhled před/po odpovědí „Souhlasím“. Tato podoba je nyní zapojená
do běžného startu hry. Grafika proti schválenému náhledu zůstává přesná.

## Vzhled

- Zachované originální ilustrace, dřevěný rám a malované krémové karty.
- Menší portrét bez dalšího silného obrysu; popis využívá šířku karty.
- Oddělená, jemná plocha pro vlastnost bylinky.
- Sklizně, nejlepší kvalita, zakázky a usušené množství v zarovnaných řádcích.
- Tyrkysová dostupná odměna; tlumené uzamčené odměny.
- Samostatný prostor posuvníku, mezery mezi kartami, stabilní spodní akce.
- Původní 58px zásahová plocha křížku a 60px spodní akce zachovány.

## Zachování chování

`herbarium_screen_presentation.gd` přeskupuje původní obrázky, texty a tlačítka.
Hlavní scéna komponentu připojuje při startu; `HerbariumPresenter` obnovuje
nové řádky po standardním obnovení dat. Komponenta nepočítá odměny ani nemění
herní pravidla či ukládání.

Nové údaje čtou stejné `get_species_progress` jako původní presenter.
Neobjevené bylinky mají nadále skryté vlastnosti, postup a statistiky.
Tlačítka zachovávají původní hlídání dotykového posunu a původní callbacky.

## Ověření

- Deset cílených kontrol zahrnutých do kompletní sady: běžná hra s novým herbářem,
  zachování celého postupu a identity ovládacích prvků, živé údaje všech
  druhů a uzamčení, obnova po změně sklizní, správná jednorázová odměna,
  odmítnutí opakované odměny, idempotentní zapnutí, přesné obnovení historického
  stromu a pořadí, přepínání bez duplikací a vrácení odměn, zavření křížkem.
- Kompletní funkční sada: `MVP_TESTS_PASSED=6915`.
- Kompletní vizuální ověření běžné hry: všech 34 chráněných porovnání
  prošlo, `HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`.
  Historické snímky herbáře se zachovanou kompozicí chrání dosavadní referenci;
  nový běžný herbář ověřují zvlášť cílené testy a skutečné GPU snímky.
- Skutečné GPU snímky při 432×960 a 360×800: normální, zamčená,
  dokončená a maximálně zvládnutá sbírka.
- Kontrola hranic všech 11 karet v maximální hodnosti, jejich textů,
  portrétů a odměn: `HERBARIUM_ALL_SPECIES_GEOMETRY=true`.
- Kontrola křížku, šířky posuvu a odstupu spodního panelu:
  `HERBARIUM_REVIEW_GEOMETRY=true`.

Nové runtime artefakty: `.godot/herbarium-shipped-20261009/`. Běžný start
potvrzuje `HERBARIUM_DEFAULT_ENABLED=true`; šest nových stavových snímků se
pixelově shoduje se schváleným náhledem v `.godot/herbarium-polish-20261009/`.
Historický snímek se pixelově shoduje s původní kompozicí.
Kompletní konečné ověření a jeho report jsou v podadresáři `validation-final`.

Původní schválené reference, masky a tolerance se nemění. Capture helper
výslovně obnoví historickou podobu pro původní názvy; nový běžný herbář zachytí
navíc jako `comic-herbarium-painted-20261009.png`. Režim historie se nepoužívá
při obyčejném spuštění a nevrací stav herních dat.

Veškeré testy a snímky používají oddělený profil. Telefon není v tomto kroku
testován. Změna je určena pro schválený commit a push, bez nového release.
