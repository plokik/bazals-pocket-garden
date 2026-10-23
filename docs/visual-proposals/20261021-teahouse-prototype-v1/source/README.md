# Čajovna U zeleného lístku – prototyp ke schválení

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
Bazal je zatím jediný testovací host. Hrnek a konvička jsou pracovní kresba;
finální malované nádobí, zákazníci, ekonomika a vstup ze hry jsou další etapa.
Heřmánek je v této minihře návrh ingredience, nepřidává se do katalogu rostlin.

Ovládání: myš / dotyk, případně šipky (zaměření desky), mezerník (přidat dílek),
Enter (potvrdit), Backspace (zrušit výběr), R (restart), Esc (zavřít).
Tab přechází mezi tlačítky. Zvuky i pohyb lze přepínat v záhlaví.
Při ztrátě fokusu se rozpracovaný tah zruší a nalévání pozastaví.
Restart zachová nastavení zvuku a pohybu, body se neukládají.

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
