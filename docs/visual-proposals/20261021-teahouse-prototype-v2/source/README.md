# Čajovna U zeleného lístku – prototyp v2 ke schválení

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
