# Kočka v zahradě – náhled ke schválení

Malovaná zrzavá kočka s krémovými tlapkami a zelenýma očima. V pokoji má proutěný pelíšek se zeleným polštářkem, misku s vodou a misku s krmením. Občas projde pokojem, kolem stojanu nebo skleníkem. Mezi chůzí odpočívá, lehá si, protahuje se, zívá, olizuje tlapku a čistí si srst.

## Náhledy

- `cat-behaviors.gif`: detail ze skutečně renderované hry; klidové pauzy jsou pro ukázku zkrácené.
- `cat-gameplay.gif`: průchod pokojem, stojanem a skleníkem, přibližně 33 sekund.
- `cat-room-sleep.png`, `cat-rack-walk.png`, `cat-greenhouse-walk.png`: umístění na podlaze a mezi ovládacími prvky.

## Rozsah

Komponenta nezachytává dotyky ani nemění ukládání, mince, rostliny nebo herní pravidla. Pohyb se pozastaví při dialogu, herní pauze a uspání aplikace. Při omezených animacích kočka v pokoji klidně spí. Pelíšek a misky jsou součástí společné ilustrace; péče a krmení nyní nemají herní ekonomiku ani povinné časovače.

## Ověření

Finální funkční sada: `MVP_TESTS_PASSED=6976`. Z toho 26 nových kontrol ověřuje skutečné snímky pohybu, průchod třemi místy, odstup od ikon stojanu a záhonů, zastavení animací a zachování stavu po patnácti minutách simulace.

Oficiální vizuální sada: 34 chráněných bran prošlo; 54 případů celkem, ostatní jsou diagnostické. Schválené PNG, manifest, masky ani prahy nebyly upraveny. Nový pelíšek/kočka mění přibližně 1,6 % pokojového záběru v dotčených chráněných porovnáních. Závěrečné motion náhledy ověřují opravenou trasu nad ikonami stojanu. Poslední úprava omezuje překreslování při vypnutých animacích; nemění statický výsledek porovnání.

Výtvarné přijetí: **ČEKÁ NA OSOBNÍ SCHVÁLENÍ UŽIVATELEM**. Tento dokument nepovyšuje nové obrázky na schválené referenční PNG. Technické důkazy jsou v `.godot/cat-companion-20261010/`; aktuální funkční log je `final-functional-current.log`, vizuální report je `validation-final/report.md`.

Generování: vestavěný `imagegen`; původní RGBA soubory a zadání jsou v `assets/pets/garden_cat_v1/`. Produkční obrázky nebyly dodatečně přemalované, Godot používá měřené výřezy siluet. Tato lokální verze nebyla nahrána na GitHub ani instalována na telefon/emulátor.
