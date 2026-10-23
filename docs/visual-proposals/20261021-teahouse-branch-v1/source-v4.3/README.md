# Čajovna U zeleného lístku – prototyp v4.3, větvička s beruškami

Samostatná Godot scéna: res://prototypes/teahouse/tea_prototype.tscn.
Výchozí scéna hry, ekonomika a uložený postup se nemění.
Prototyp nenačítá GameSession ani SaveManager.

Spoj tažením alespoň tři stejné sousední bylinky; spojování jde i šikmo.
Vrácením po posledním úseku řetězec zkrátíš. Po uvolnění se bylinky přidají do
receptu, zbývající dílky spadnou a deska se doplní. Každý recept má 18 tahů,
bez časového limitu. Delší řetězce dávají více bodů. Nápověda je zdarma.
Zaseknutá deska se automaticky zamíchá bez spotřeby tahu.

Po dokončení směsi drž tlačítko nalévání a pusť ho v zeleném pásmu.
Nepřesnost ovlivňuje pouze bodový bonus. Nic ze skladu se nespotřebuje.
Tři pracovní recepty: Svěží ráno, Klidný večer a Zahradní posezení.
Bazal je zatím jediný testovací host. Verze 2 používá nový návrh malovaného
hrnku a konvičky, plynulé naklánění, omezenou hladinu čaje uvnitř hrnku,
jemnou páru a dvousekundové jiskření. Noví zákazníci, ekonomika a vstup ze hry
jsou další etapa; tato verze se soustředí na vzhled a animace podle zpětné vazby.
Heřmánek je v této minihře návrh ingredience, nepřidává se do katalogu rostlin.

Verze 3 přidává světelné odlesky podél řetězce, malé lístky a pyl při sběru,
krátký záblesk u správné ingredience v receptu, vlnky a kapky při nalévání,
teplé rozsvícení za hotovým šálkem a jemné listové jiskření nad čajem.
Efekty používají původní grafiku. Pravidla, skórování a uložený postup se nemění.
Částice mají pevný limit 84 a nejvýše 12 současných záblesků. Restart i klidný
režim dočasné efekty vyčistí; grafická vrstva nepřijímá kliknutí ani dotyky.

Verze 4 dolaďuje čitelnost sběru: bylinky padají s malým odstupem po sloupcích
a při příchodu shora se přesně oříznou do hrací desky. Let do receptu má plynulý
rozjezd a dojezd. Počítadla a malé zelené linky receptu se doplňují při skutečném
doletu každé bylinky, i když hráč rychle naváže dalším tahem stejného druhu.
Po posledním sběru se na krátkou chvíli potvrdí „Směs je připravená“ a teprve pak
se objeví nalévání. Klidný režim tento mezikrok přeskočí. Změny jsou pouze vizuální.

Verze 4.1 odstraňuje testovací přepínače receptů a technický text pod tlačítky.
Objednávky pokračují přes tlačítko „Další objednávka“. Úvodní návod se zobrazí
jen při prvním otevření této samostatné scény; restart ani další objednávka ho
neopakují. Později ho hráč vyvolá přes „Nápověda“, která také označí možnou cestu.
Návod se v tomto prototypu pamatuje pouze po dobu otevřené scény; hráčské savy
se kvůli němu nemění. Zprávy ke skutečnému tahu nebo dokončení zůstávají krátkodobé.
Malovaný návrh v5 je samostatná ilustrace, jeho prostředí zatím není zapojené.

Verze 4.2 posouvá návod a dvojici Nápověda / Zkusit znovu společně o 60 logických
pixelů dolů. Od desky tak mají odstup 69 místo 9 pixelů. Velikost prvků, mezera
mezi návodem a tlačítky i umístění ovládání nalévání zůstávají stejné.

Verze 4.3 přidává do mezery pod deskou samostatnou dekorativní větvičku a dvě
berušky. Malovaný průhledný atlas je v art/tea-branch-ladybug-v1.png, přesné zadání
imagegen v sousedním souboru .prompt.txt. Těla jsou malovaná, šest nohou se pohybuje
za běhu. Berušky mají oddělené úseky stonku, pomalu lezou, na konci se zastaví
a plynule otočí. Dekorace nereaguje na dotyk ani fokus a nezasahuje do herního RNG.
Klidný režim zmrazí celé pózy; při nalévání je větvička skrytá a její čas neběží.
tea_branch_review.gd natočí dvanáctisekundovou ukázku komponenty na statickém
malovaném návrhu v5b. Tento záznam je animovaný výtvarný návrh, nikoli gameplay.

Ovládání: myš / dotyk, případně šipky (zaměření desky), mezerník (přidat dílek),
Enter (potvrdit), Backspace (zrušit výběr), R (restart), Esc (zavřít).
Tab přechází mezi tlačítky. Zvuky i pohyb lze přepínat v záhlaví.
Při ztrátě fokusu se rozpracovaný tah zruší a nalévání pozastaví.
Restart zachová nastavení zvuku a pohybu, body se neukládají.
Poslední sběr se nejdříve dokončí a potom se objeví scéna nalévání.
Zrušení vedlejšího prstu nepřeruší aktivní nalévání. Automatické promíchání
desky je výslovně oznámeno a animováno; pravidla, náklady a skórování jsou stejné.

## Ověření

Spouštět v úplném projektu s --path . a logem uvnitř .godot/.
Model: --headless --script res://prototypes/teahouse/tea_board_model_test.gd.
Runtime a skutečné události myši/dotyku vyžadují renderer:
--script res://prototypes/teahouse/tea_runtime_review.gd -- --output=<adresář>.
S --demo lze natočit deterministickou ukázku přímo přes Godot Movie Maker.
Fyzický Android nebyl v této etapě testován.

## Grafika

Stávající obraz dílny, profesor, panely, fonty a audio se pouze čtou.
Nový atlas art/herb-symbols-v1.png vznikl vestavěným nástrojem imagegen,
čistá průhlednost je zachovaná. Jde pouze o pracovní návrh pro tento prototyp.
Původní assety se nenahrazují. Přesné zadání je v art/herb-symbols-v1.prompt.txt.
Nové nezměněné PNG: art/tea-cup-v2.png a art/tea-pot-v2.png; oba návrhy vznikly
vestavěným imagegen podle stávající malované výtvarné reference.
Zadání: art/tea-cup-v2.prompt.txt a art/tea-pot-v2.prompt.txt.
Pohyb, tekutina a částice se kreslí až za běhu; obrázky se neupravují.
Předchozí prototyp včetně zdrojů a ukázky je zachovaný v
docs/visual-proposals/20261021-teahouse-prototype-v1/.
