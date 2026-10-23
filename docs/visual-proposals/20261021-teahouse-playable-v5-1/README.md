# Čajovna v5.1 – opravy osmi doložených nálezů

Tento krok opravuje osm vad z docs/audit/20261021-teahouse-v5/findings.json.
Zůstává samostatným hratelným prototypem; není zapojený do savů, ekonomiky
ani výchozí hlavní scény. Schválené vizuální reference se nemění.

Myš i dotyk nyní zpracují poslední souřadnici při puštění tahu. Nepotřebné
bylinky mají bodový cíl (286,330) mimo karty receptu. Počet bylinek v řetězci
zůstává ve spodním oznámení, takže herní kameny nezakrývá žádná cedulka.
Dokončení směsi se potvrzuje až po příletu bylinek a informace se neopakuje
ve dvou panelech. Stejně je odstraněné duplicitní výsledkové oznámení.

Proud vychází ze skutečné hubice a zobrazuje se až nad hladinou, s plynulým
náběhem. Růst hladiny i zvuk jsou navázané na jeho viditelnost. Konvička si
zachovává původní pohyb, velikost a PNG. Lokální zvuková smyčka pokryje celé
držení a správně končí při puštění, ztlumení, ztrátě fokusu nebo restartu.
Sdílený WAV a jeho import se nemění.

Nový průhledný atlas tea-panels-v5-1.png vznikl vestavěným imagegen jako
upřesnění schváleného stylu. Obsahuje prázdné krémové/zelené panely, vlastní
dřevěný rám s krémovým vnitřkem a samostatné ornamenty. Devítidílné skládání
zachovává rohy; ozdobné lístky se kreslí zvlášť ve vlastním poměru stran.
Servírovací plocha nemá zelené zbytky ani vložený obdélník z jiného podkladu.
Původní pozadí, kameny, bylinky, profesor, berušky a schválený lesk se používají
dál. Model ani bodování se nemění. Přesné zadání a originální atlas jsou v
source-v5.1/art/tea-panels-v5-1.prompt.txt a tea-panels-v5-1.png.

cajovna-v5-1-cela-objednavka.mp4 je skutečná celá první objednávka nahraná
v Godot Movie Maker přes skutečné vstupy. Jde o hru, nikoli animovanou ilustraci.
Herní audio má v exportu konstantní zesílení 12 dB; žádné zvuky nejsou přidané.
Prvních 0,1 s technického sestavení viewportu je oříznuto, samotná objednávka
zůstává celá. Nativní rozlišení je 432×960 při 30 FPS, bez zvětšování.

Původních 659 nativních kontrol zůstalo zachovaných a přibyly regrese pro
konkrétní nalezené vady. runtime-report.json obsahuje výsledky jednotlivých
ID V5-01 až V5-08, skutečné vstupy a GPU důkazy. Porovnání auditu před/po je
uložené v audit-before.json a audit-after.json. review-status.json uvádí výsledky
modelu, celkové regrese hlavní hry, integritu referencí, media a SHA256 zdrojů.

Nová podoba panelů a opravený průchod čekají na vizuální schválení majitele.
Telefon, APK, GitHub a release nejsou součástí tohoto kroku.
