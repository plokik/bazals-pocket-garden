# Fáze 166 — přesouvání a výměna pokojových rostlin podržením

`PHASE166_ROOM_PLANT_DRAG=IMPLEMENTED_SOURCE_ONLY`

`PHASE166_ROOM_PLANT_SWAP=IMPLEMENTED_SOURCE_ONLY`

`PHASE166_TECHNICAL_VALIDATION=PASSED_SWAP_FULL_VALIDATION`

`PHASE166_GODOT_RENDER=PASSED_INTERNAL_REVIEW`

`PHASE166_HUMAN_MOBILE_ACCEPTANCE=PENDING_NEW_APK`

`PHASE166_APK=NOT_CREATED_RC58_UNCHANGED`

`PHASE166_SAVE_SCHEMA=41_UNCHANGED`

## Ovládání

Podrž vlastní pokojovou rostlinu přibližně 0,45 sekundy. Krátký indikátor
podržení přejde do přetažení: rostlina s květináčem a podmiskou následuje
prst nebo myš, volné pozice se zvýrazní zeleně. Puštění na libovolném volném
místě stojanu (3 sloupce × 4 police) ji položí. Obsazený cíl se zvýrazní
zlatě a nápověda předem oznámí výměnu: po puštění se obě rostliny prohodí,
druhá se vrátí na původní místo taženého květináče. V obou případech se
celé nové rozmístění ihned uloží. Výměna funguje i na plném stojanu 12/12.
Krátké klepnutí dál otevírá původní nabídku dekorací.

Výměna nikdy nezahodí ani nezdvojí druhou rostlinu.
Puštění mimo stojan nebo nad ovládacím tlačítkem přesun zruší. Puštění na
původním místě nic nemění. Rychlý pohyb před dokončením podržení je zrušený
pokus, nikoli nákup nebo přepnutí záložky. Přesun nemění mince, XP,
vlastnictví, herní bonusy ani ceny a funguje i s nulovým zůstatkem.

## Implementační hranice

- `RoomPlantDragController` spravuje jediný kontakt, čas podržení a toleranci
  pohybu 12 logických pixelů. Více prstů, Escape/Zpět, modal, změna obrazovky,
  změna rozmístění, resize nebo ztráta focusu ruší rozehraný přesun.
- Zrušení běžného gesta zachová informaci o dosud držených kontaktech až do
  jejich puštění. Ztráta systémového focusu naopak uvolní vstupní stav, aby
  chybějící OS release nezablokoval další ovládání.
- Godot posílá emulované pointer události před jejich nativním zdrojem.
  Emulovaný press/release se potlačuje jako jeden pár; skutečný prst/myš
  provádí právě jednu akci. Zbytek GUI včetně následujícího klepnutí funguje
  dál. [Godot Input implementace](https://github.com/godotengine/godot/blob/master/core/input/input.cpp)
- Doménová operace `move_room_plant` před změnou kteréhokoli konce znovu
  ověří rozsah 0–11, očekávanou identitu zdroje, vlastnictví a kompatibilitu
  obou výsledných umístění. Neznámý, nevlastněný nebo nerostlinný cíl i
  nekonzistentní duplicitní ID zruší celou operaci bez částečné mutace.
- Ukládání prochází stávajícím `Main._save_current_session()` a atomickým
  `SaveManager`. Při blokovaném nebo neúspěšném zápisu zůstává autoritativní
  stávající recovery dialog; nevypíše se falešné potvrzení uložení.
- Vykreslení používá stávající RGBA assety, stejné rozměry keramiky a
  podmisek a stávající přizpůsobení listů výšce cílové police. Za pohybu se
  zdroj nekreslí podruhé. PNG ani schválené obrazové reference se nemění.
- Nejde o úpravu pěstitelských Rostlin, skleníku, pevných pokojových dekorací
  nebo save formátu. RC58 a všechny starší APK zůstávají immutable.

## Ověření

Regrese zahrnuje modelové přesuny všech 12 druhů do všech 12 pozic, stejně
širokou matici výměn s jiným druhem a výměn zpět, plný stojan, odmítnuté
transakce, skutečný diskový save/load, čistý pointer kontrolér a skutečnou
`main.tscn` s Viewport vstupem. Dotyková emulace se testuje přes
`Input.parse_input_event()` v obou směrech, nikoli jen voláním signálů.
Vstupy i save používají izolovaná testovací data, ne profil hráče.

Deterministický renderer doplňuje nezávazné snímky
`comic-phase166-player-room-drag-preview.png` a
`comic-phase166-player-room-drag-placed.png`. První zachycuje přetažení,
druhý skutečně uložené položení orchideje z první do třetí police.
Další dvojice `comic-phase166-player-room-swap-preview.png` a
`comic-phase166-player-room-swap-placed.png` zachytí následnou skutečnou
výměnu této orchideje s kapradinou ve druhé polici a uložené oba konce.
Stávající obrazové brány, tolerance a referenční soubory zůstávají beze změny.

### Stabilní snímek již existující animace Obchodu

První dva úplné běhy zachytily jedinou nestálou bránu mimo Pokoj: reakční
zoom obchodníka běžel podle skutečné délky snímků. Porovnání
`.godot/validation/20260827-193153Z` a `20260827-194107Z` zaznamenala
6,802 % a 7,732 % změněných pixelů při původním limitu 6 %. Regresní testy
i všechny ostatní závazné obrazové případy prošly.

Capture nyní zastaví pouze testovací tween a explicitně odehraje první
1/60 sekundy pozdravu před stejným dokončením layoutu. Nejde o tvrzení,
že historická reference měla přesně tento timestamp; jde o reprodukovatelný
časný animační stav v původní toleranci. Produkční animace se nemění.
Samostatný GPU důkaz v `.godot/phase166-shop-probe/` reprodukoval druhý
neúspěšný běh a poté dvakrát zachytil nový pevný stav s identickým SHA-256
`7A9BD9407556160AFD1A42E2C1BDD90164306A99CC1FEC644FBF2D3D86458B0C`.
Původní brána pro tento stav měří MAE 0,537679, RMSE 2,232905 a
1,5618 % změněných pixelů. Schválená reference, masky a limity zůstávají
beze změny; dočasný diagnostický skript není součástí zdrojové změny.

### Původní ověření před doplněním výměny

Úplná automatizace `.godot/automation/20260827-195909Z` skončila s
`AUTOMATION_TECHNICAL_GATE=PASSED`, `HOW_TO_GROW_AUTOMATION=PASSED` a
nativním exit 0. Jednotlivé kroky VisualContract, Validation, Performance,
Endurance, Progression a Responsive mají rovněž `PASSED` a exit 0.

- `.godot/validation/20260827-195921Z`: `MVP_TESTS_PASSED=1989`
  (431 nových kontrol této fáze), `HOW_TO_GROW_CAPTURE=PASSED`,
  `HOW_TO_GROW_VISUALS=PASSED`, `HOW_TO_GROW_VALIDATION=PASSED`;
- všech 34 závazných obrazových případů prošlo. Schválené dynamické stavy
  prázdného, částečného, telefonního a plného Pokoje i oba stavy nové dekorace
  mají MAE 0, RMSE 0 a 0 % změněných pixelů;
- skutečné snímky tažení a položení v této validační složce byly vizuálně
  zkontrolovány: zdroj se nekreslí dvakrát, cíl zvýrazní volné místo a po
  položení se listy přizpůsobí cílové polici, bez změny keramiky a podmisky;
- `.godot/performance/20260827-200212Z`: CPU p95 nejvýše 13,248 ms,
  frame p95 16,701 ms, nejvýše 557 draw calls a 90,14 MiB;
- `.godot/endurance/20260827-200256Z`: 48/48 cyklů, sedm save roundtripů,
  nulový růst uzlů/orphanů/zdrojů, +0,01 MiB;
- `.godot/progression/20260827-200308Z`: 132/132 cyklů a 27 roundtripů;
- `.godot/responsive/20260827-200313Z`: 15/15 případů; samostatné
  integrační kontroly nových hit oblastí zahrnují obsah 432 × 780 a
  360 × 620, minimálně 56 px a žádné překrytí sousedních buněk.

Immutable RC58 byl po testech znovu ověřen: SHA-256
`0A7F173D8C97B552168A407C31F1F8AE85109A34C2F6F4786029551064F0C6F5`.
Zdrojové PNG, vizuální manifest, reference a release identita se nezměnily.

Závěrečný Quick `.godot/automation/20260827-200525Z` po doplnění dokumentace
znovu ověřil VisualContract a všech 1 989 regresních kontrol; oba kroky i
`AUTOMATION_TECHNICAL_GATE` a `HOW_TO_GROW_AUTOMATION` skončily `PASSED`,
nativní exit 0. Telefonní test nebyl vyžádán ani spuštěn.

### Doplnění výměny obsazených míst

Uživatel následně výslovně požádal o výměnu dvou květináčů. Rozšířená
cílená sada `.godot/phase166-swap-tests.log` prošla s
`PHASE166_TESTS_PASSED=1040`, nativním exit 0 a bez skriptových chyb.
Model ověřuje 922 kontrol, čistý kontrolér 63 a skutečný Viewport vstup 55.
Mezi nimi je plný stojan, swap tam/zpět, zachování mincí/XP/vlastnictví,
záloha původního rozmístění, neplatné cíle, zrušení po změně cílové rostliny,
produkční save z myši i nativního dotyku a pravdivý recovery dialog při
odmítnutém zápisu.

Nový úplný běh `.godot/validation/20260827-202200Z` ověřil výměnu zvlášť:
`MVP_TESTS_PASSED=2598`, `HOW_TO_GROW_CAPTURE=PASSED`,
`HOW_TO_GROW_VISUALS=PASSED`, `HOW_TO_GROW_VALIDATION=PASSED`, nativní
exit 0. Všech 34 závazných obrazových bran prošlo; dynamické pokojové
reference si zachovaly MAE 0, RMSE 0 a 0 % změněných pixelů. Oba nové
GPU snímky výměny byly interně prohlédnuty: zlatý cíl a text oznamují
prohození, po puštění zůstane každá rostlina právě na opačném místě a obě
se přizpůsobí výšce cílových polic. Jde o skutečný runtime a uložený stav,
nikoli o kreslený návrh nebo automatické uživatelské schválení.

Žádný zdrojový PNG, schválená reference, obrazový manifest ani release
identita nebyly upraveny. Hash immutable RC58 byl znovu ověřen a zůstal
shodný s výše uvedeným. Předchozí výkonový a Android audit zůstává
historickým důkazem; nový telefonní audit se tímto netvrdí.

Finální Quick `.godot/automation/20260827-202626Z` znovu prošel grafickým
kontraktem i všech 2 598 regresních kontrol: `AUTOMATION_TECHNICAL_GATE=PASSED`,
`HOW_TO_GROW_AUTOMATION=PASSED`, oba kroky i orchestrátor mají exit 0.

Nový APK se v této fázi nevytváří. Technický desktopový PASS nepředstavuje
fyzické otestování nového gesta na telefonu ani uživatelovo schválení.
