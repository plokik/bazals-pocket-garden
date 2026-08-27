# Fáze 161 — schválená malovaná Denní výzva

`PHASE161_SOURCE_ACCEPTANCE=APPROVED_BY_USER`

`PHASE161_IMPLEMENTATION=IMPLEMENTED_DYNAMIC_RUNTIME`

`PHASE161_TECHNICAL_VALIDATION=PASSED_1556_HARD_GATES`

`PHASE161_RESPONSIVE_VALIDATION=PASSED_14_OF_14`

`PHASE161_GODOT_RENDER_ACCEPTANCE=APPROVED_BY_USER`

`PHASE161_USER_VISUAL_ACCEPTANCE=APPROVED_BY_USER`

`PHASE161_VISUAL_BASELINE_TRANSITION=PASSED_APPEND_ONLY_FIVE_STATE_RUNTIME_GATES`

`PHASE161_MOBILE_ACCEPTANCE=DEFERRED_PHONE_UNAVAILABLE`

`PHASE161_APK=NOT_CREATED`

`PHASE161_PUBLISHING=OUT_OF_SCOPE`

`PHASE161_RC57=IMMUTABLE`

## Schválený cíl

Uživatel schválil malovaný návrh Denní výzvy se živým dřevěným rámem,
popínavkami, modrou hlavičkou, pergamenovými pásy, botanickou scénou a
barevnými akčními plochami. Přesná append-only kopie je
`docs/visual-proposals/phase161/user-approved-painted-daily-challenge-screen-v1.png`
o rozměru 853 × 1844 a SHA-256
`7972356773A32026E400C97C27DF4F70881723F50B2E74E28A010D696A12533E`.

Tento návrh obsahuje konkrétní texty, HUD a stav `prepare_rain`, proto je pouze
report-only výtvarný cíl. Nesmí být použit jako jedna runtime obrazovka ani
tvrdý baseline před schválením skutečného Godot renderu.

## Čistý runtime asset a vrstvy

Godot používá nový neutrální RGBA plate
`assets/ui/visual/phase161/daily_challenge/daily_challenge_clean_backdrop_v3.png`
o rozměru 853 × 1844 a SHA-256
`678FA27DEBE01723AAD39E6ABC775B847015D321115A7754796E8ED33C4C72B6`.
Neobsahuje žádná písmena, čísla, herní hodnoty, HUD ani navigaci. Vnější bílé
pozadí bylo odstraněno deterministickým edge-connected maskováním; RGB malby
zůstalo beze změny. Neutrální obloha umožňuje pravdivě přidávat počasí a
význam úkolu až za běhu.

Runtime skládá samostatně:

- celoplošný input-blocking scrim, přes který zůstává patrný živý HUD a spodní
  navigace;
- čistý malovaný plate s rámem, deskami, pergamenem, bazalkou, květináčem,
  podmiskou a čidlem;
- všechny texty jako živé Godot `Label` uzly;
- čtyři skutečná dotyková `Button` CTA nad prázdnými malovanými plochami;
- stavové barevné vrstvy pro disabled akci a připravenou odměnu;
- procedurální kontext bez textu pro všech čtrnáct typů výzev; dnešní i
  zítřejší počasí zůstává živým dynamickým textem.

Zachovaný `DailyChallengePresenter` je jediným zdrojem názvu, popisu, stavu,
dostupnosti cíle a textu odměny. Save schema 41, odměna 12 mincí + 10 XP +
botanický balíček, denní UTC pravidlo, navigace a modal exclusivity se nemění.

## Stavový kontrakt

- `ACTIVE`: modrá aktivní akce a šedá odměna;
- `NO_TARGET`: akce je šedá a pravdivě čeká na vhodný stav;
- `READY`: akce je šedá, odměna zelená a aktivní;
- `READY + queue_full`: mince a XP lze stále vyzvednout, text pravdivě oznámí
  plný zásobník balíčků;
- `CLAIMED`: obě hlavní akce jsou neaktivní a odměna je označena jako
  vyzvednutá.

Podporovaná ID zůstávají přesně:
`plant`, `rescue`, `treat`, `harvest`, `start_drying`, `package`, `sell`,
`ventilate`, `lamp`, `fertilize`, `water`, `prepare_rain`, `prepare_cloud` a
`prepare_dry`.

## Ověření a pravdivé brány

Capture vytváří samostatné snímky aktivního, splněného, plného, vyzvednutého a
nedostupného stavu. Schválený koncept je ve `visual-cases.json` pouze
`gate=false`. Po výslovném schválení skutečného vrstveného Godot renderu
vzniklo pět samostatných append-only referencí pro aktivní, splněný, plný,
vyzvednutý a nedostupný stav. Každá je vlastní tvrdou branou bez cropu nebo
masek; koncept zůstává `gate=false`.

Úplná deterministická validation
`.godot/validation/20260826-092919Z` prošla 1 541/1 541 regresními kontrolami,
capture markerem, vizuálním porovnáním a všemi existujícími tvrdými obrazovými
branami. Phase161 koncept zůstává úmyslně report-only; jeho metriky proti
živému vrstvenému renderu jsou MAE 44,312, RMSE 68,225 a changed ratio
66,503 %, takže automatický PASS není vydáván za lidské schválení vzhledu.

Samostatný responsive audit `.godot/responsive/20260826-092316Z` prošel
14/14 případů. Skutečný modal na 360 × 800 nemá vodorovné přetečení a čtyři
akční plochy zachovávají mobilní minimum. Snímky pro lidskou kontrolu jsou:

- `.godot/validation/20260826-092919Z/comic-phase161-daily-challenge-active.png`;
- `.godot/validation/20260826-092919Z/comic-phase161-daily-challenge-completed.png`;
- `.godot/validation/20260826-092919Z/comic-phase161-daily-challenge-ready-queue-full.png`;
- `.godot/validation/20260826-092919Z/comic-phase161-daily-challenge-claimed.png`;
- `.godot/validation/20260826-092919Z/comic-phase161-daily-challenge-unavailable.png`;
- `.godot/responsive/20260826-092316Z/phase161_daily_challenge_360x800.png`.

Uživatel všech pět skutečných stavů výslovně schválil nad během
`.godot/validation/20260826-180748Z`; append-only runtime reference vycházejí z
pozdějšího společného běhu `.godot/validation/20260827-150703Z`. Telefon není k
dispozici, nové APK se nevytváří, nic se nepublikuje a immutable RC57 se
nepřepisuje.

Závěrečná plná validace `.godot/validation/20260827-153641Z` potvrdila
`MVP_TESTS_PASSED=1556`, `HOW_TO_GROW_CAPTURE=PASSED`,
`HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Všech pět
aktivních Phase161 runtime bran se shoduje s odsouhlasenými referencemi přesně
MAE/RMSE/changed ratio `0/0/0`.
