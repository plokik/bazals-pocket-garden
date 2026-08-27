# Fáze 158 — oprava kompozice vrstev pokoje

Stav implementace: `PHASE158_IMPLEMENTATION=IMPLEMENTED`

## Nález

Dynamické zobrazení pokoje skládalo čisté pozadí, samostatné zakoupené
dekorace a přední hrany polic. Historická přední vrstva Phase 149 však byla
vyříznuta z plně zařízeného cílového obrázku. Spolu se dřevem proto obsahovala
i části rostlin a dekorací. V neúplně zaplněném pokoji se tyto fragmenty
zobrazovaly jako duchové, nalepené kousky nebo nesprávné přesahy.

## Oprava

- schválený plný Phase 149 master 20/20, zdrojové malby a immutable RC57 se
  nemění;
- nový append-only asset `player_room_furniture_foreground_phase158_v2.png`
  přebírá alpha geometrii historické vrstvy byte-exact;
- viditelné RGB předních hran pochází výhradně z objektově čisté schválené
  desky pokoje;
- všechny nekanonické stavy používají dvacet jedna existujících čistých RGBA
  vrstev Phase 148 místo Phase 149 masek, které obsahovaly okolní pozadí;
- vysoké listoví se v nižších policích vertikálně přizpůsobí jen nad hranou
  keramiky. Květináč, podmiska, šířka i baseline zůstávají beze změny a nic
  nepřesahuje polici nad sebou;
- dynamická orchidej neroztahuje květy ani listy do stran; její keramická
  spodní část používá změřenou šířku i výšku modrého květináče a společnou
  středovou baseline. Běžné svislé přizpůsobení listoví konkrétní polici
  zůstává zachované. Tím mizí opticky úzký a vysoký orchidejový květináč bez
  zásahu do ostatních jedenácti rostlin nebo plného masteru 20/20;
- prázdné značky jsou samostatná interakční vrstva kreslená nad nábytkem, takže
  je přední hrany polic nepůlí;
- historický asset Phase 149 zůstává uložený a hashově doložený v manifestu;
- kapradinový append-only RGBA kandidát zůstává doložený: RGB všech ponechaných pixelů je
  byte-exact Phase 149, mění se jen alpha mimo čistou siluetu a lokální pravý
  spodní kontur odstraňuje oranžový ocásek přimíchané police. Aktivní dynamický
  profil ale stejně jako ostatní položky používá objektově čistý Phase 148
  zdroj;
- builder odmítne výstup, pokud se změní alpha geometrie, RGB neodpovídá čisté
  desce nebo proti staré vrstvě nezmění žádný chybný pixel.

## Hranice přijetí

- `PHASE158_SAVE_SCHEMA=41_UNCHANGED`
- `PHASE158_RC57_IMMUTABILITY=PRESERVED`
- `PHASE158_PUBLISHING=OUT_OF_SCOPE`
- `PHASE158_TECHNICAL_VALIDATION=PASSED`
- `PHASE158_GODOT_PARTIAL_ROOM_CAPTURE=PASSED_TECHNICAL`
- `PHASE158_USER_VISUAL_ACCEPTANCE=APPROVED_BY_USER`
- `PHASE158_FOUR_STATE_VISUAL_ACCEPTANCE=APPROVED_BY_USER`
- `PHASE158_VISUAL_BASELINE_TRANSITION=PASSED_APPEND_ONLY_FOUR_STATE_RUNTIME_GATES`
- `PHASE158_ANDROID_APK=NOT_CREATED_AFTER_VISUAL_ACCEPTANCE`

Regresní sada po opravě prošla `MVP_TESTS_PASSED=1524`. Finální úplný
čtyřstavový průchod je `.godot/validation/20260825-204357Z`; obsahuje prázdný
stav 0/20, řídký stav 4/20, sanitizovanou přesnou topologii telefonu 10/20 a
plný stav 20/20. `HOW_TO_GROW_CAPTURE=PASSED`,
`HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED` potvrzují
technickou opravu. Uživatel následně výslovně schválil všechny čtyři skutečné
stavy a po navazujícím zvětšení terária na 115 % potvrdil i nový úplný render.
Přesné append-only kopie běhu `.godot/validation/20260827-150703Z` jsou čtyři
samostatné tvrdé runtime brány bez cropu nebo masek. Původní přehled je
`.godot/validation/20260825-204357Z/phase158-four-state-contact-sheet.png`.
Detail rozměrové shody orchidejové a modré keramiky je
`.godot/validation/20260825-204357Z/phase158-orchid-pot-parity-preview.png`.

Automatické kontroly dokazují technickou kompozici a regresi; lidské přijetí je
nyní uzavřené samostatným schválením uživatele. APK, mobilní audit ani nová
release identita tím automaticky nevznikají.

Závěrečná plná validace `.godot/validation/20260827-153641Z` potvrdila
`MVP_TESTS_PASSED=1556`, `HOW_TO_GROW_CAPTURE=PASSED`,
`HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Všechny čtyři
Phase158 runtime brány se shodují s odsouhlasenými referencemi přesně
MAE/RMSE/changed ratio `0/0/0`.
