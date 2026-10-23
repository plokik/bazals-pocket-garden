# Bazalova dílna – první návrh ke schválení

Pokoj nyní nabízí pracovní stůl. Klepnutí na „Připravit směs“ otevře dvě funkční možnosti:

- Bylinné hnojivo: 1 g suchých nezabalených bylin a 2 mince vytvoří jednu existující dávku hnojiva.
- Posilující tonikum: 2 g bylin a 3 mince obnoví 12 bodů zdraví vybrané živé rostlině se zdravím pod 85 %. Použije se ihned, neoživuje mrtvé rostliny a nenahrazuje podmínky pěstování.

Malovaný základ má dvě skříňky, slunné okno, pracovní stůl a volnou podlahu pro kocoura. Zakoupené dekorace se vykreslují z původních assetů a pod původními uloženými identifikátory. Jejich nákup ani přesouvání se neruší. Existující vzhledy fungují nad novou malbou. Starý zdroj pokoje a jeho obrazové reference zůstávají zachované. Vylepšení pracovního stolu zatím není součástí této první verze.

## Náhledy

`dilna-432.png` a `dilna-360.png` jsou snímky skutečného Godot viewportu při 432×960 a 360×800. Obsahují izolovanou demonstrační sestavu vybaveného pokoje s kocourem, nikoli hráčův osobní save. Dekorace se nepřidávají zdarma do skutečného uloženého postupu.

`recepty-360.png` ukazuje recepty s použitelnou sklizní a oslabenou rostlinou. `recepty-bez-bylin-360.png` ukazuje nedostatek zásob.

## Ověření

- Kompletní funkční sada: `MVP_TESTS_PASSED=7414`, bez GDScript parser/script chyb. Negativní scénáře v existující sadě vypisují očekávané chyby neplatných profilů/ukládání; starší testové dvojníky také vypisují chybějící metadata a headless renderer své shaderové diagnostiky.
- Nové kontroly ověřují přesné odečtení bylin a mincí, nepoužití čerstvé/sušící/zabalené sklizně, odmítnutí neplatných cílů tonika, opakovaný klik bez zásob, zachování kvality a proporcí hmotnosti, schema 42, skutečný nákup/přesun dekorace, ovládání Zpět a blokování pozadí.
- Responzivní sada: `RESPONSIVE_LAYOUT_SMOKE=PASSED`, 15 případů. Nová dílna se kontroluje přes skutečné dotykové oblasti, přístupnost rostlin a oddělení dekorací od navigace. Historická kontrola starého pokoje zůstává v samostatné větvi.
- Nativní návrhový capture: `WORKSHOP_NATIVE_CAPTURE=PASSED VIEWPORTS=2 RECIPE_STATES=2`, vlastní izolovaná složka APPDATA, bez chyb ukládání.
- `git diff --check` bez nálezů. Schválené obrazové reference a jejich prahy nebyly upraveny.

Kompletní nativní capture dokončil `HOW_TO_GROW_CAPTURE=PASSED`. Vizuální runner skončil `HOW_TO_GROW_VISUALS=FAILED`: 25 z 34 chráněných případů prošlo, 9 má odchylku. Osm případů porovnává nový návrh dílny s historickým pokojem (78,360–93,788 % změněných pixelů). Devátý je stojan s dříve odsouhlasenou spodní lištou a nyní přejmenovaným pravým vstupem do dílny (5,431 % změněných pixelů; MAE 5,590). Všechny neúspěšné porovnávací obrázky byly zkontrolovány; změny odpovídají těmto místům. Nejde o úspěšnou shodu se starými referencemi. Podrobná čísla a nezměněné prahy uvádí `.godot/workshop-review-20261011/validation/report.md`, souhrn je v `validation/failed-comparisons-contact.png`.

Logy a kompletní obrazové porovnání jsou v `.godot/workshop-review-20261011/`. Nová malba je návrh ke schválení, nikoli nová schválená golden reference. Případné odchylky od starého pokoje a dřívějších animací nejsou vydávány za shodu původních referencí.

Tento návrh nebyl publikován na GitHub, nebyl vytvořen release ani aktualizován Android/emulátor.
