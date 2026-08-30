# Phase167 — oprava orchideje a celého pokojového stojanu

## Rozsah a stav

Oprava dvanácti kupovaných pokojových rostlin ve všech dvanácti pozicích
stojanu 3 × 4. Navazuje na rozpracované přesouvání a výměny z Phase166;
nejde o přemalování pokoje ani o změnu pěstitelské obrazovky ROSTLINY.

```text
PHASE167_ROOM_RACK_REPAIR=IMPLEMENTED
PHASE167_ALPHA_AUDIT=PASSED
PHASE167_REGRESSION=PASSED
PHASE167_CAPTURE=PASSED
PHASE167_QUICK=PASSED
PHASE167_RESPONSIVE=PASSED
PHASE167_VISUAL_REFERENCE_GATE=PASSED
PHASE167_VISUAL_BASELINE_TRANSITION=PASSED_APPEND_ONLY_FIVE_RUNTIME_GATES
PHASE167_USER_VISUAL_ACCEPTANCE=APPROVED_BY_USER
PHASE167_ANDROID_ACCEPTANCE=NOT_RUN_SOURCE_ONLY
```

Uživatel schválil opravený stojan zprávou „Souhlasím“ po předložení
skutečného renderu dne 2026-08-27. Toto grafické schválení je oddělené od
automatických výsledků i dosud neprovedeného fyzického přijetí na telefonu.
Původní neúspěšná validace zůstává zdokumentovaná níže; její výsledek se
zpětně nemění.

## Přechod po uživatelském schválení

Pět nových verzovaných referencí `assets/ui/comic/reference_phase167_player_room_*_runtime_v1.png`
navazuje na uživatelem schválenou malbu v nezměněných deterministických
stavech sparse, phone-save fixture, full, full-cloche a clean-floor.
Jde o bajtově přesné kopie skutečných GPU snímků z
`.godot/validation/20260827-213709Z/`, nikoli nově generované návrhy.
Rozložení, herní kód, samotné textury rostlin ani stavy zachycení se během
tohoto schvalovacího kroku nezměnily.

[Schvalovací záznam](visual-proposals/phase167/runtime-reference-approval-v1.json)
váže nový souhlas na přesný zobrazený render, uvádí zdrojové capture cesty
a SHA256 všech pěti nových i historických referencí. Staré případy Phase158,
Phase159 a Phase160 zůstávají diagnosticky porovnávané s původními PNG;
jejich `superseded_by` odkazuje na novou aktivní Phase167 bránu. Prázdný
pokoj a samostatné terárium zůstávají aktivními původními branami.

Počet aktivních bran zůstává **34**. U pěti náhrad se nezměnily rozměr
432 × 960, oba plné cropy, prázdné masky, pixelová tolerance 12 ani limity
MAE 4 / RMSE 12 / podíl změn 0,06. Sedmnáct dalších regresních kontrol
chrání přesné mapování, schválený snímek, hash původních PNG a tyto limity.
Koncová kontrola před spuštěním validace potvrdila 58/58 nezměněných
chráněných souborů včetně původních referencí, runtime skriptů a RC58.

## Ověření po schválení — zdrojový vizuální krok uzavřen

- Úplná validace `.godot/validation/20260827-220126Z/`: import,
  `MVP_TESTS_PASSED=6414`, `HOW_TO_GROW_CAPTURE=PASSED`,
  `HOW_TO_GROW_VISUALS=PASSED`, `HOW_TO_GROW_VALIDATION=PASSED`, native exit 0.
- **34/34 aktivních obrazových bran PASS.** Pět nových Phase167 bran má
  MAE 0, RMSE 0 a podíl změněných pixelů 0; nové skutečné PNG jsou i hashově
  totožné se schválenými referencemi. Byla prohlédnuta výsledná tabulka,
  nové reference/actual/heatmap a srovnání plného pokoje.
- Quick `.godot/automation/20260827-220422Z/`: VisualContract a Regression
  PASS, `HOW_TO_GROW_AUTOMATION=PASSED`, native exit 0. Nových 17 kontrol
  schvalovacího přechodu rozšiřuje předchozích 6 397 na 6 414.
- Předchozí responzivní důkaz 15/15 z `.godot/responsive/20260827-214227Z/`
  se zachovává; během schvalovacího kroku se runtime ani layout neměnil.
- Uživatelské přijetí grafiky je dokončené. Android přijetí je nadále
  `NOT_RUN_SOURCE_ONLY`; RC58 ani telefon se neaktualizovaly a nový APK
  bude samostatný release krok.

## Nalezené příčiny a opravy

- Orchidej se kreslila do obdélníku s jiným poměrem stran než její skutečný
  PNG. Pevné dělení textury na 55 % a samostatné korekce květináče dále
  rozpojovaly osu keramiky a stonků. Staré dělení a zvláštní násobiče jsou
  nahrazené měřenými souřadnicemi okraje květináče, středu podmisky a kontaktu
  s policí pro každý ze dvanácti druhů.
- Původní odstranění pozadí zaměnilo část růžových květů za pozadí. Nové
  samostatné odvozené PNG obnovují původní barvu a průhlednost z archivního
  atlasu: 811 ztracených růžových pixelů orchideje a 38 begonie. Celkem se
  napříč sadou obnovilo 4 886 okrajových pixelů. Původní zdroje se nepřepisují.
- Všech dvanáct květináčů včetně podmisek má společný měřený rozměr
  57 × 54 logických bodů při šířce pokoje 432. Viditelná podmiska, nikoli
  průhledný okraj PNG, určuje střed a místo dosednutí na polici.
- Horní listoví a květy se škálují stejným poměrem v obou osách podle skutečné
  mezery nad danou policí. Krátký souvislý přechod spodních listů pod květy
  je připojí ke společné keramice. Nejde o izotropní transformaci celého
  obrázku: keramika má vlastní jednotný rozměr, květy se však nenatahují.
- UV síť nemá vynechané pásy, obrácené trojúhelníky ani tvrdý řez stonku.
  Přesahující spodní listy se vejdou do vlastního místa bez zakrytí sousedního
  květináče. Síť se ukládá do cache; při tažení se pouze posouvá.
- Importované textury skutečně obsahují mipmapy. Dřívější slovní profil
  filtrování neodpovídal importům bez mipmap. Zdrojové barvy, namalované
  kontaktní stíny a pořadí předních hran nábytku zůstávají zachované.
- Dotykové oblasti sdílejí geometrii s vykreslením a nepřekrývají sousední
  řadu ani na kratším displeji. Přesun, výměna, zrušení gesta a ukládání
  z Phase166 zůstávají funkční.

## Kontroly a důkazy před grafickým schválením

- Regresní sada: **6 397 kontrol**; z toho 3 799 nových pro opravený render.
  Ověřuje 12 druhů × 12 pozic × 2 rozměry pokoje, tedy 288 umístění a 288
  modelových výměn. Kontroluje skutečné vrcholy/UV vykreslované sítě, rozměr
  keramiky, podmisky, zachování květů, kontaktní linie, viditelné okraje,
  dotykové oblasti, importované mipmapy i přesný RGB původ textur.
- Cílený skutečný GPU capture: `.godot/phase167-rack-audit-final/`, marker
  `HOW_TO_GROW_CAPTURE=PASSED`, native exit 0, bez SCRIPT ERROR/Parse Error.
  Čtyři rozmístění přesunou každý druh postupně na všechny čtyři police;
  další snímky zachycují přetažení a výměnu přes skutečnou herní scénu.
- Osm dodatečných nativních renderů používá stejný `PlayerRoomCollectionView`
  ve `SubViewport`: 432 × 780 → 1080 × 1950 a 360 × 620 → 1080 × 1860,
  čtyři rozmístění pro každý rozměr. Nejde o dodatečné zvětšení malé bitmapy,
  vygenerovaný návrh ani snímek fyzického telefonu. Všech osm bylo vizuálně
  prohlédnuto; žádná police neodřezává květy ani sousední květináč.
- Finální úplná přísná validace: `.godot/validation/20260827-213709Z/`.
  Import, 6 397 testů a capture prošly; 29/34 aktivních obrazových bran prošlo,
  5/34 selhalo. `HOW_TO_GROW_VISUALS=FAILED`, native exit 1. Všech pět
  comparison PNG je hashově totožných s prvním prohlédnutým úplným během
  `.godot/validation/20260827-212130Z/`.
- Quick automatizace: `.godot/automation/20260827-214143Z/`, VisualContract
  i Regression PASS, `HOW_TO_GROW_AUTOMATION=PASSED`, native exit 0.
  Tento režim neprovádí pixelové porovnání a neruší pět neúspěšných bran výše.
- Responzivní kontrola: `.godot/responsive/20260827-214227Z/`, 15/15 scénářů,
  `RESPONSIVE_LAYOUT_SMOKE=PASSED`, native exit 0; zahrnuje běžný a kratší
  displej, safe-area výřezy i samostatnou obrazovku Pokoje 360 × 800.

| Původní obrazová brána | MAE | RMSE | Změněné pixely |
|---|---:|---:|---:|
| Phase158 sparse | 2,110909 | 13,250633 | 4,7172 % |
| Phase158 phone-save fixture | 1,995442 | 12,867255 | 4,3731 % |
| Phase158 full | 6,047569 | 21,735063 | 13,9641 % |
| Phase159 full-cloche | 6,047569 | 21,735063 | 13,9641 % |
| Phase160 clean-floor | 6,350177 | 22,175962 | 14,8184 % |

Jde o rozdíly proti referencím zachovávajícím původní geometrii a filtrování
rostlin. Interně byly zkontrolovány comparison/heatmap výstupy všech pěti
selhávajících případů; full a full-cloche mají totožný comparison PNG.
Nové změny proti poslednímu Phase166 PASS jsou pouze na levém stojanu.
Kabinet vpravo včetně terária je pixelově shodný. Starší Phase160 reference
již před opravou vykazovala 3 543 tolerovaných odlišných pixelů terária
(historicky schválené zvětšení o 15 %); nejde o novou změnu v Phase167.
Prázdný pokoj i samostatná cloche brána zůstaly pixelově beze změny.

## Zachované zdroje a reprodukovatelnost

- Deterministický builder: `tools/build_phase167_room_plant_alpha.py`;
  přepínač `--check` znovu ověří výstupy bez zápisu. Kontrolní běh prošel
  s `PHASE167_PLANT_ALPHA=PASSED`, 12 rostlinami a 849 růžovými pixely.
- Nové deriváty a manifest: `assets/ui/visual/phase167/player_room/`.
  Žádný původní PNG z manifestu Phase148 nebyl změněn. Viditelné RGB každého
  výstupního pixelu pochází přímo z atlasu; stará průhlednost se nesnižuje.
- Původní atlas SHA256:
  `0735BB39144E113228088973DE87B4A4C655D5557391477D54E0BE4513572D24`.
- Save schema 41, vlastnictví, ceny, ekonomika, pořadí hráčových slotů a
  rozpracované změny Phase166 se zachovávají. Žádný skutečný save ani telefon
  se pro audit neupravoval.
- Immutable RC58 / Android code 75 se nepřebaloval ani neinstaloval.
  APK SHA256 zůstává
  `0A7F173D8C97B552168A407C31F1F8AE85109A34C2F6F4786029551064F0C6F5`.

## Schválený snímek

[Skutečný nový render pokoje](visual-proposals/phase167/player-room-rack-native-review-v1.png)
je neupravená kopie normal-cycle-0 z cíleného GPU capture,
SHA256 `7273D26C64A662B2479947D640C68C2C5478B93F3E623F546EF93A1B9C29EC8D`.
Uživatel jej výslovně schválil. Z tohoto souhlasu nevzniká automatické
schválení Androidu: nový APK ani fyzický telefonní audit zatím neproběhly.
