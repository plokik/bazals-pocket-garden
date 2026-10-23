# Nově malované police s bylinkářským vybavením

11. 10. 2026. Nový vizuální návrh ke schválení. Uživatel výslovně zvolil pevnou vyváženou kompozici místo volného přesouvání dekorací. Toto rozhodnutí není automatické schválení nových referenčních PNG.

## Obsah návrhu

Šest sestav je malovaných přímo v prostoru polic se společným světlem, perspektivou, podložím a stíny. Květináče se střídají s nůžkami, provázkem, sáčky semínek, knihami, lahvičkami přísad, sušenou levandulí a sazenicemi. Staré samostatné dekorace se již nekreslí přes novou malbu.

Použitý nový produkční obrázek: assets/ui/workshop/bazal_workshop_painted_shelves_v2.png. Přesný prompt a původ jsou v sourozeneckém .prompt.md. Vytvořeno vestavěným image_gen, jediný nový produkční obraz. Původní zdroje jsou zachované.

Všech dvacet původních slotů a zakoupené dekorace zůstávají v uloženém postupu. Skryté cíle nereagují na myš/dotyk a hlavní logika odmítne pokus přesunout neviditelnou rostlinu. Recepty, navigace, vzhledy místnosti, kocour, pelíšek a misky fungují dál.

## Ověření

- workshop-432.png a workshop-360.png jsou skutečné nativní snímky z Godotu, ručně prohlédnuté; shelves-detail.png je pouze výřez prvního snímku. Testovací stav není osobní uložený postup.
- .godot/shelf-painted-v6-20261011/full-tests.log: MVP_TESTS_PASSED=7414, native exit 0, žádné GDScript parse/script chyby.
- Regrese starého přesouvatelného pokoje dále testuje jeho zachovanou původní komponentu napojenou na skutečné herní a ukládací handlery. workshop_test testuje novou pevnou malbu: odmítnutí přesunu, uchování nákupů a slotů, vypnutí skrytých cílů, recepty a návrat.
- .godot/responsive/20261011-093345Z/responsive-layout.json: všech 15 případů, RESPONSIVE_LAYOUT_SMOKE=PASSED; kontroluje také neaktivní historické cíle v dílně.
- .godot/shelf-painted-v6-20261011/capture.log: WORKSHOP_NATIVE_CAPTURE=PASSED VIEWPORTS=2 RECIPE_STATES=2, native exit 0.
- git diff --check prošel. Historické referenční obrázky a jejich tolerance nezměněny. Kompletní golden porovnání nebylo opakováno, nový obraz čeká na osobní vizuální schválení.
- Každý běh má izolované APPDATA. Osobní save, emulátor, telefon, GitHub ani release nebyly tímto úkolem aktualizovány.
