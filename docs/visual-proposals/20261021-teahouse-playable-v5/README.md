# Hratelná malovaná čajovna v5 – skutečná celá objednávka

Majitel schválil převod malovaného vzhledu do funkčního prototypu, zachování animací
a záznam celé objednávky ke schválení. Tento krok nezapojuje čajovnu do hlavní hry,
ekonomiky ani hráčských savů. Výchozí hlavní scéna a schválené reference se nemění.

Malované prostředí, pergamenové karty, zelená tlačítka, oblé kameny a dřevěný rám jsou
teď skutečnou součástí scény prototypes/teahouse/tea_prototype.tscn. Pozadí nemá žádné
zapečené texty, herní bylinky, panely ani počítadla. Dva nové podklady vznikly vestavěným
imagegen podle schváleného v5b. Originální PNG zůstala nezměněná. Jejich přesná zadání
jsou uložená v source-v5/art/tea-environment-v5.prompt.txt a tea-ui-v5.prompt.txt.

tea_painted_skin.gd používá původní atlasové oblasti, malované panely a devítidílný
rám s pevným okrajem 16 logických pixelů. Herní mřížka zůstává (36,370,360,360),
odstupy pod deskou a původní ovládání se nemění. Nalévání má stejný dřevěný rám
s pergamenovým středem. Texty a počítadla jsou vždy živé; bylinky reagují na skutečné
tahy a doletí do skutečného receptu. Mipmapy tří importovaných textur vyhlazují jejich
zmenšování bez úprav zdrojových PNG. Stejné vyhlazení používají i původní hrnek,
konvička a místní GPU kopie portrétů profesora; sdílené importy hlavní hry se
nemění. Stávající profesor, zvuky, hudba, konvička, čaj, efekty sběru, berušky
a schválený lesk zůstávají zachované. Titulek má vlastní místo vedle dekorace;
duplicitní drobné popisky už nezasahují do spodní části rámu nalévání.

cajovna-v5-cela-objednavka.mp4 je záznam skutečného Godot runtime přes Movie Maker,
ne animace statické ilustrace. Demo používá události myši, nezávislou zkoušku modelu
jen pro načasování pauz a skutečný živý model pro veškerou hru. Živý stav ani fill
se kvůli videu nepřepisují. Viditelný kurzor ukazuje skutečné pozice vstupů, ale
nezachytává dotyky. Zvuk pochází ze hry; export přidává konstantní zesílení 12 dB
pro slyšitelný náhled, bez střihů nebo přidaných efektů a bez přebuzení. Video je
nativních 432×960 při 30 FPS,
bez zvětšování. MP4 je export FFmpeg H.264 + AAC z původního AVI. Úvodních 0,1 s
technického sestavení viewportu je oříznuto; celá objednávka včetně zadání zůstává.

Záznam ukazuje zadání profesora, spojování, sběr a pády, doplňování cílových bylinek,
připravenou směs, skutečné nalévání do zeleného pásma a výsledek objednávky.
PNG snímky jsou z téže skutečné scény; runtime-*.png ověřují i ostatní rozměry.

Výsledky modelových, vstupních, GPU a celkových regresních kontrol, kvalita nalití,
skutečná délka videa, integrita referencí a hashe zdrojů jsou v review-status.json.
Celý zdroj této verze je uložený v source-v5/. Vizuální schválení celé nové scény
čeká na majitele; schválený lesk z v4.4 je zachovaný. Telefon, APK, GitHub a release
nejsou součástí tohoto kroku.
