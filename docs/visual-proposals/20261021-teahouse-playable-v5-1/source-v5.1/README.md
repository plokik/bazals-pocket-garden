# Čajovna U zeleného lístku – hratelný malovaný prototyp v5.1

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
Malovaný návrh v5 byl v této etapě samostatnou ilustrací. Nyní ho nahrazuje
skutečně hratelné prostředí popsané ve verzi 5 níže.

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

Verze 4.4 přidává měkký zlatý lesk přejíždějící přes malovanou větvičku každých
sedm sekund, slabou teplou záři podle skutečné siluety lístků a tři krátké odlesky.
Nový shader nemění atlas ani vzhled berušek, nohou a kontaktního stínu. Klidný
režim tyto světelné efekty úplně vypne. Používají lokální čas komponenty, takže
při skrytí dekorace stojí také světelné efekty. Rozměry a ovládání se nemění.

Verze 5 převádí schválený malovaný vzhled do skutečné hratelné scény. Nové prostředí
art/tea-environment-v5.png neobsahuje UI ani žádný herní stav. Samostatný průhledný
atlas art/tea-ui-v5.png obsahuje prázdný dřevěný rám, oblý podklad bylinky, pergamen
a zelené tlačítko. Všechny bylinky, počítadla, texty, tlačítka i profesor se zobrazují
samostatně podle živého herního stavu. tea_painted_skin.gd skládá jejich vzhled;
u dřevěného rámu zachovává okraj 16 px a u panelů celou malovanou siluetu. Nalévání
používá stejný rám s pergamenovým středem. Původní zdroje bylinek, model, skórování,
animace, konvička i schválený lesk zůstávají beze změny. Nové podklady, atlas bylinek,
hrnek a konvička používají mipmapy pro hladké zmenšení na mobilu; zdrojová PNG se
neupravují. Portréty profesora mají místní GPU kopii s mipmapami, takže se nemusí
měnit jejich sdílené importy hlavní hry. Horní titulek má vlastní prostor vedle
dekorace. Duplicitní drobné popisky pod měřidlem nalévání už nezasahují do rámu;
pokyn nad hrnkem a zelené cílové pásmo zůstávají.

Aktuální --demo natáčí jednu celou první objednávku přes skutečné vstupy myši,
s čitelným úvodem, viditelným kurzorem, pauzami mezi tahy, skutečným nalitím do
zeleného pásma a výsledkem. Používá se --fixed-fps 30 a --write-movie. Není to
animace statického konceptu a průběh nepřepisuje živý model. Zvuk je přímo ze hry.
Tato scéna stále zůstává samostatným prototypem ke schválení, bez napojení na savy
nebo ekonomiku hlavní hry. Přesná zadání obou nových assetů jsou v art/*.prompt.txt.

Verze 5.1 opravuje osm doložených nálezů auditu. Myš i dotyk nyní zpracují poslední
souřadnici uvolnění tahu. Nepotřebné bylinky mají neutrální bodový cíl vedle skóre;
už nepřilétají do cizího receptu. Počet spojených bylinek zůstává ve spodní zprávě
a neblokuje herní kameny. Potvrzení hotové směsi přichází po doletu a neopakuje
se ve spodní liště; ani výsledek už neukazuje tutéž informaci dvakrát.

Proud, růst hladiny a zvuk se spouštějí až při skutečném převýšení hubice nad
hladinou. Zvuk má samostatnou lokální smyčku, která končí při puštění, ztrátě
fokusu, restartu nebo ztlumení. Sdílené WAV ani jeho import se kvůli tomu nemění.
Pohyb konvičky, hrnek, lesk větvičky, berušky, pravidla i bodování jsou zachované.

Nový atlas art/tea-panels-v5-1.png odděluje prázdné výplně, rohy/okraje a dvojici
ozdobných lístků. Cream/sage používají skutečné devítidílné skládání s rovnoměrně
zmenšenými rohy; dekorace se kreslí samostatně se zachovaným poměrem stran.
Nalévání má vlastní souvislý dřevěný rám s krémovým vnitřkem včetně zaoblených rohů,
bez zelených zbytků původní desky. Atlas vznikl vestavěným imagegen jako upřesnění
stávajícího stylu; přesné zadání je v sousedním .prompt.txt, raw PNG se neupravuje.

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
