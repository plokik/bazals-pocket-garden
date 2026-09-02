# Bazal’s Pocket Garden — release readiness

Tento checklist odděluje technicky ověřené části vertikálního řezu od kroků, které vyžadují člověka nebo fyzické zařízení. Stav se nesmí označit jako hotový pouze podle existence kódu.

## RC59 po přesunu na disk R — 2026-09-02

Autoritativní checkout je nyní `R:\_projekty\Bazal's Pocket Garden` a Godot
4.7 leží vedle něj. Přesunový audit opravil pevné výchozí cesty deseti runnerů
a konflikt globálního Android SDK na C s přeneseným SDK na R. Kompletní lokální
validace z nového kořene prošla 6 747 regresními kontrolami, 34/34 aktivními
obrazovými branami, výkonem, endurance, progresí a 15/15 responzivními případy.
Skutečný jednorázový ARM64 debug export následně prošel podpisem v2, payloadem,
manifestem, privacy allowlistem i 16KB alignmentem. [Přesné změny, cesty,
hashes a důkazy](RC59_VALIDATION_REPORT.md).

`RC59_RELOCATION_GATE=PASSED`.
`RC59_LOCAL_TECHNICAL_GATE=PASSED`.
`RC59_PHYSICAL_ANDROID_GATE=NOT_REQUESTED`.
`RC59_SIGNED_AAB_GATE=PENDING_EXISTING_SIGNING_CONFIGURATION`.
`RC59_MANUAL_VISUAL_GATE=PENDING_SINGLE_HUMAN_BATCH`.
`RC59_PUBLISHING_GATE=OUT_OF_SCOPE_BY_USER`.

Immutable RC58 (224 368 317 B,
`0A7F173D8C97B552168A407C31F1F8AE85109A34C2F6F4786029551064F0C6F5`) i
RC59 (233 837 732 B,
`206AC5349731D95570E0E59DD43229A5AB608AA139EA78979FCB3DE907021E7D`) po
přesunu byte-exaktně souhlasí. Audit nevytvořil klíč, podepsaný AAB, instalaci
do telefonu ani publikaci.

## Aktuální zdrojová změna a emulátorový preview — Phase183

Přerostlý spodní panel stojanu byl odstraněn. Na malovaném pokračování
dřevěné podlahy je jediná centrovaná řada čtyř stejných 68 × 68 cílů:
mazlík/vzhled, Profesorův výzkum, Péče a Nastavení. Každý cíl obsahuje
samostatné transparentní PNG 48 × 48 bez bílého obdélníku. Profesor je
vždy viditelný; před odemčením vysvětluje podmínku a ukazuje `ZÁM`, po
odemčení otevírá existující výzkum a zachovává dynamický vykřičník.
Péče používá dynamický číselný badge. Horní otazník zůstává pouze
obecnou nápovědou. [Rozsah a důkazy](PHASE183_COMPACT_RACK_DOCK.md).

Cílená sada `PHASE183_TESTS_PASSED=41`, responzivní kontrola 15/15 a
real-GPU capture `.godot/phase183-rack-dock/20260829-2315Z` jsou PASS.
Úplná validace `.godot/validation/20260829-215900Z` prošla
`MVP_TESTS_PASSED=6745` a `HOW_TO_GROW_CAPTURE=PASSED`. Tvrdá obrazová brána
zůstává `FAILED` na deseti historických případech. Všech deset comparison
obrazů bylo prohlédnuto: změny odpovídají dříve evidovanému novému stojanu,
dosednutí detailu a nyní záměrně také kompaktnímu Phase183 doku. Reference,
masky ani tolerance nebyly přepsány.

Samostatný emulátorový APK
`.godot/emulator-preview/20260829-221017Z/bazals-pocket-garden-phase183-emulator-x86_64-debug.apk`
má 240 853 270 B a SHA-256
`0A4CD44CEBDD85B82BE101420E9F327E625273CA03772D42FEFC98F25A112834`.
Export, podpis, payload a instalace `adb install -r` do `emulator-5554`
prošly; balíček `com.howtogrow.game` je v popředí jako
`0.68.0-rc58-emulator` / code 75. Nová čtveřice se na skutečné Android
obrazovce vykreslila. Starý poškozený save emulátoru vyvolává fail-closed
ochranu při pokusu o uložení; nebyl smazán ani nahrazen. Proto je úplný
nedestruktivní klikací audit emulátoru `BLOCKED_BY_PROTECTED_OLD_SAVE`, zatímco
interakční kontrakty v Godotu jsou PASS.

Závěrečný Quick po dokumentaci
`.godot/automation/20260829-222857Z` prošel vizuálním kontraktem i celou
regresí a skončil `AUTOMATION_TECHNICAL_GATE=PASSED` a
`HOW_TO_GROW_AUTOMATION=PASSED`. Device krok nebyl součástí Quicku a lidské
vizuální přijetí zůstává samostatné.

`PHASE183_SOURCE_AND_INTERACTION_CONTRACT=PASSED`.
`PHASE183_TARGETED_TESTS=PASSED_41`.
`PHASE183_RESPONSIVE=PASSED_15_OF_15`.
`PHASE183_GPU_CAPTURE=PASSED`.
`PHASE183_FULL_REGRESSION=PASSED_6745`.
`PHASE183_FULL_VISUAL_GATE=FAILED_10_HISTORICAL_REFERENCES`.
`PHASE183_EMULATOR_PREVIEW_INSTALL=PASSED_PRESERVE_DATA`.
`PHASE183_EMULATOR_FOREGROUND=PASSED`.
`PHASE183_EMULATOR_CLICK_AUDIT=BLOCKED_BY_PROTECTED_OLD_SAVE`.
`PHASE183_QUICK_AUTOMATION=PASSED`.
`PHASE183_USER_VISUAL_ACCEPTANCE=PENDING_USER_REVIEW`.
`PHASE183_PHONE=NOT_TOUCHED`.
`PHASE183_OFFICIAL_RC59=NOT_CREATED_VISUAL_BASELINES_PENDING`.

Immutable RC58 i obecný alias zůstávají byte-exaktně na SHA-256
`0A7F173D8C97B552168A407C31F1F8AE85109A34C2F6F4786029551064F0C6F5`.

## Aktuální zdrojová změna — Phase182

Otazník ve stojanu `ROSTLINY` nyní vždy otevírá obecnou nápovědu. Odemčený
Profesorův výzkum má vlastní malovanou ikonku, samostatný 64px dotykový cíl a
jediný attention badge. Dynamická geometrie drží titul `MOJE ROSTLINY` mimo oba
vstupy při 432 × 960 i 360 × 800. Mobilní tooltip texty jsou centrálně
potlačené, takže Android při podržení nevytváří černé systémové obdélníky;
desktopová nápověda je zachovaná v krémovém komiksovém stylu. Schválená PNG
nebyla změněna. [Rozsah a důkazy](PHASE182_PROFESSOR_LAUNCHER_AND_TOOLTIP_POLICY.md).

Cílených 35 kontrol PASS. GPU capture
`.godot/phase182-visual-20260829-194057Z` PASS. Úplná validace
`.godot/validation/20260829-194327Z` prošla 6 743 regresními kontrolami a
capturem. Celková obrazová brána dál selhává na stejných deseti historických
případech jako předchozí běh `20260829-175257Z`; jejich názvy, metriky i
aktuální SHA-256 jsou shodné a všechny comparison obrazy byly prohlédnuty.
Reference ani tolerance se neměnily.
Závěrečný Quick po dokumentaci
`.godot/automation/20260829-195508Z` skončil
`AUTOMATION_TECHNICAL_GATE=PASSED` a `HOW_TO_GROW_AUTOMATION=PASSED`.

`PHASE182_SOURCE_AND_INTERACTION_CONTRACT=PASSED`.
`PHASE182_TARGETED_TESTS=PASSED_35`.
`PHASE182_FULL_REGRESSION=PASSED_6743`.
`PHASE182_GPU_CAPTURE=PASSED`.
`PHASE182_FULL_VISUAL_GATE=FAILED_SAME_10_HISTORICAL_REFERENCES`.
`PHASE182_QUICK_AUTOMATION=PASSED`.
`PHASE182_USER_VISUAL_ACCEPTANCE=PENDING_USER_REVIEW`.
`PHASE182_ANDROID_PHYSICAL_TOOLTIP_AUDIT=NOT_RUN`.
`PHASE182_APK=NOT_CREATED`.

Immutable RC58, obecný APK alias i hráčský save zůstávají beze změny.

## Aktuální oprava a Android preview — Phase181

Zhasínací animace každého světla ve stojanu `ROSTLINY` je nyní ukotvená ke
středu čočky konkrétního indexu. Kruh se při vypnutí zmenšuje dovnitř a paprsky
se vracejí do právě stisknutého svítidla; žádná větev už nepoužívá společný
střed stojanu. Schválené PNG nebylo změněno.
[Úplná oprava a Android důkazy](PHASE181_RACK_LIGHT_OFF_ANCHOR.md).

25 cílených kontrol PASS. Real-GPU capture
`.godot/phase181-light-off-anchor/20260829-175117Z` ověřil vypnutí indexů
`0, 2, 4, 5, 7, 9` a skončil
`PHASE181_RACK_LIGHT_OFF_ANCHORS=PASSED`. Úplná validace
`.godot/validation/20260829-175257Z` prošla 6 737 regresními kontrolami a
capturem. Celková obrazová brána dál poctivě selhává na stejných deseti
historických referencích; všech deset aktuálních comparison souborů je proti
běhu `20260829-131635Z` SHA-256 shodných a bylo znovu prohlédnuto. Reference,
masky ani tolerance se neměnily. Závěrečný Quick po dokumentaci
`.godot/automation/20260829-182624Z`
skončil technickým PASS.

Preview
`.godot/preview/20260829-180305Z/bazals-pocket-garden-phase181-preview.apk`
má 231 970 265 B a SHA-256
`362EC8562B16583BD5EB040CED770074C90999F2740CCCC84A56E32797A773EF`.
Nedestruktivní instalace a audit
`.godot/android-device-audit/20260829-180449Z` potvrdily shodný nainstalovaný
hash, save `41_TO_41`, 21 platných vzorků, 100 % foreground a nula fatal/ANR
nálezů. Cílené fyzické klepnutí na levé, prostřední a pravé svítidlo zachytilo
vypínací efekt vždy přímo u správné čočky. Jde o technický PASS; subjektivní
vzhled a pohodlí animace musí potvrdit uživatel.

`PHASE181_RACK_LIGHT_OFF_ANCHOR=PASSED`.
`PHASE181_ANDROID_PREVIEW_INSTALL=PASSED_PRESERVE_DATA`.
`PHASE181_ANDROID_TARGETED_LIGHT_TEST=PASSED_LEFT_MIDDLE_RIGHT`.
`PHASE181_FULL_VISUAL_GATE=FAILED_SAME_10_HISTORICAL_REFERENCES`.
`PHASE181_USER_VISUAL_ACCEPTANCE=PENDING_USER_REVIEW`.
`PHASE181_OFFICIAL_RC59=NOT_CREATED_VISUAL_BASELINES_PENDING`.
`PHASE181_PUBLISHING=OUT_OF_SCOPE_BY_USER`.

Immutable RC58 i obecný alias zůstávají byte-exaktně na SHA-256
`0A7F173D8C97B552168A407C31F1F8AE85109A34C2F6F4786029551064F0C6F5`.

## Předchozí Android preview — Phase180

Současný pracovní strom fází 166–179 je nainstalovaný na Xiaomi jako
samostatné preview APK. Není označen jako RC59, protože fail-closed release
runner dál pravdivě eviduje deset čekajících vizuálních baseline. Preview
zachovává balíčkovou identitu `0.68.0-rc58` / code 75 / schema 41, ale má
explicitní evidence cestu a nesmí být zaměněno s immutable RC58.
[Úplný Android preview handoff](PHASE180_ANDROID_PREVIEW_HANDOFF.md).

Quick `.godot/automation/20260829-130151Z` skončil 6 733 regresními
kontrolami a technickým PASS. APK
`.godot/preview/20260829-130337Z/bazals-pocket-garden-phase179-preview.apk`
má 231 969 753 B, SHA-256
`6CAC8B67FC559F43C49876B03C8F7046AE0FE76F7F69D2A1C6B6828A0B402E75`
a prošel exportem, podpisem, entry scanem, úplným runtime payloadem i
notifikačním payloadem.

Povinný následný full run `.godot/validation/20260829-131635Z` znovu prošel
6 733 regresními kontrolami a capturem. Jeho celková obrazová brána zůstává
`FAILED` na přesně stejných deseti historických referencích jako běh
`20260829-101254Z`; všech deset comparison souborů je mezi běhy SHA-256
shodných. Nejde tedy o novou regresi preview světel a žádná reference, maska
ani tolerance nebyla automaticky přepsaná.

Nedestruktivní instalace a audit
`.godot/android-device-audit/20260829-130523Z` potvrdily přesnou shodu
nainstalovaného hashe, save `41_TO_41`, zachované jádro postupu, 22/22
platných vzorků, 100 % foreground a nula fatal/ANR nálezů. Skutečný snímek
aplikace v popředí dokládá současný stojan pod legitimním návratovým
souhrnem. Immutable RC58 a obecný alias mají dál původní SHA-256
`0A7F173D8C97B552168A407C31F1F8AE85109A34C2F6F4786029551064F0C6F5`.

`PHASE180_ANDROID_PREVIEW_EXPORT=PASSED`.
`PHASE180_ANDROID_PREVIEW_INSTALL=PASSED_PRESERVE_DATA`.
`PHASE180_ANDROID_TECHNICAL_GATE=PASSED`.
`PHASE180_REGRESSION_TESTS=PASSED_6733`.
`PHASE180_FULL_VISUAL_GATE=FAILED_SAME_10_HISTORICAL_REFERENCES`.
`PHASE180_ANDROID_VISUAL_ACCEPTANCE=PENDING_USER_REVIEW`.
`PHASE180_OFFICIAL_RC59=NOT_CREATED_VISUAL_BASELINES_PENDING`.
`PHASE180_PUBLISHING=OUT_OF_SCOPE_BY_USER`.

## Předchozí zdrojová změna — Phase179

Každé z deseti skutečných mosazných světel ve stojanu `ROSTLINY` lze nyní
samostatně rozsvítit a zhasnout klepnutím. Akce mění skutečný `lamp_on`
příslušné rostliny, zachovává výběr slotu a ukládá se ve stávajícím schema 41.
Potvrzuje se až puštěním na stejném svítidle; pohyb nad 14 px nebo globální
swipe gesto zruší. Zapnutí trvá 0,42 s, vypnutí 0,24 s a každý z deseti indexů
má vlastní plynulý přechod, kužel, čočku i odezvu odmítnutí. Režim Méně
pohybu odstraňuje pulz a přechod urychlí. Schválené Phase163 PNG svítidla je
byte-exaktně zachované. [Funkce a skutečné GPU rendery](PHASE179_INDEPENDENT_RACK_LIGHTS.md).

21 cílených kontrol PASS. Skutečný GPU capture
`.godot/phase179-rack-lights/20260829-100948Z` skončil značkami
`PHASE179_INDEPENDENT_LIGHT_STATES=PASSED`,
`PHASE179_CONCURRENT_LIGHT_ANIMATION=PASSED`,
`PHASE179_RACK_LIGHTS_CAPTURE=PASSED` a `HOW_TO_GROW_CAPTURE=PASSED`.
Úplná validace `.godot/validation/20260829-101254Z` prošla 6 733 testy a
capturem, ale celkově zůstala **FAILED**: **24/34 obrazových bran PASS**.
Stejných deset starších porovnání jako v Phase178 bylo znovu prohlédnuto;
žádné neukazuje novou lampovou regresi. Quick
`.godot/automation/20260829-102406Z` skončil VisualContract + Regression
PASS, technickou bránou `PASSED` a `HOW_TO_GROW_AUTOMATION=PASSED`.

`PHASE179_LOCAL_TECHNICAL_RACK_LIGHTS=PASSED`.
`PHASE179_FULL_VALIDATION=FAILED_10_UNCHANGED_PREEXISTING_VISUAL_GATES`.
`PHASE179_QUICK_AUTOMATION=PASSED`.
`PHASE179_USER_VISUAL_ACCEPTANCE=PENDING_USER_REVIEW`.
`PHASE179_ANDROID_ACCEPTANCE=NOT_RUN_APK_DEFERRED_BY_USER`.
Immutable RC58, APK, hráčská data a předchozí pracovní změny jsou zachované.

## Předchozí zdrojová změna — Phase178

Malé sazenice ve všech čtyřech záhonech jsou nově usazené hlouběji v půdě,
takže stonky vizuálně nevyrůstají z předního dřevěného lemu. Seedling-only
baseline ve zdrojovém prostoru je `[802, 802, 1148, 1148]`: zadní dvojice se
posunula dozadu o 11 zdrojových pixelů (přibližně 13 px ve skutečném 1080px
výřezu), přední o 7 (přibližně 9 px). Vodorovné středy z Phase177, velikost,
dospělé plodiny, selection polygony a původní PNG zůstávají beze změny.
[Oprava a skutečné GPU rendery](PHASE178_GREENHOUSE_SEEDLING_DEPTH.md).

35 cílených kontrol PASS. Skutečný GPU capture `.godot/phase178-final`
skončil značkami `PHASE178_FOUR_SEEDLING_STATES=PASSED`,
`PHASE178_GREENHOUSE_CAPTURE=PASSED` a `HOW_TO_GROW_CAPTURE=PASSED`.
Úplná validace `.godot/validation/20260829-082238Z` prošla 6 720 testy a
capturem, ale celkově zůstala **FAILED**, protože aktivní obrazové brány jsou
**24/34 PASS / FAILED**. Deset
neprošlých porovnání má přesně stejné názvy i metriky jako Phase177 a všechna
comparison byla znovu prohlédnuta, takže dnešní změna nepřidala novou
odchylku. Quick `.godot/automation/20260829-082945Z` skončil
VisualContract + Regression PASS, technickou bránou `PASSED` a
`HOW_TO_GROW_AUTOMATION=PASSED`.

`PHASE178_LOCAL_TECHNICAL_SEEDLING_DEPTH=PASSED`.
`PHASE178_FULL_VALIDATION=FAILED_10_UNCHANGED_PREEXISTING_VISUAL_GATES`.
`PHASE178_QUICK_AUTOMATION=PASSED`.
`PHASE178_USER_VISUAL_ACCEPTANCE=PENDING_USER_REVIEW`.
`PHASE178_ANDROID_ACCEPTANCE=NOT_RUN_APK_DEFERRED_BY_USER`.
Immutable RC58, APK, hráčská data a předchozí pracovní změny jsou zachované.

## Předchozí zdrojová změna — Phase177

Malé sazenice ve dvou předních záhonech už nepřekračují šikmé dřevěné
boky. Velikost a baseline se nemění; pouze jejich středy používají skutečnou
perspektivu `260,5 / 626,5` místo vnějších středů obdélníkových crop bounds.
Zadní záhony, dospělé plodiny, Phase176 obrysy, dotykové plochy a původní
PNG zůstávají beze změny. [Oprava a skutečné GPU rendery](PHASE177_GREENHOUSE_SEEDLING_CONTAINMENT.md).

26 cílených kontrol PASS. Úplný běh
`.godot/validation/20260829-065003Z`: **6 711 testů PASS**, capture PASS,
**24/34 obrazových bran PASS / FAILED**. Všech deset neprošlých porovnání
má přesně stejné názvy a metriky jako Phase176; všechna comparison byla
znovu prohlédnutá. Reference, masky ani tolerance se nemění.
Quick `.godot/automation/20260829-065831Z` skončil VisualContract +
Regression PASS a technickou bránou `PASSED`.

`PHASE177_LOCAL_TECHNICAL_SEEDLING_CONTAINMENT=PASSED`.
`PHASE177_USER_VISUAL_ACCEPTANCE=PENDING_USER_REVIEW`.
`PHASE177_ANDROID_ACCEPTANCE=NOT_RUN_APK_DEFERRED_BY_USER`.
Immutable RC58, APK, hráčská data a předchozí pracovní změny jsou zachované.

## Předchozí zdrojová změna — Phase176

Dva přední žluté obrysy Skleníku nyní sledují perspektivu malovaného
dřevěného rámu stejně jako zadní dvojice opravená v Phase174. Záhony 3 a 4
mají samostatné zrcadlové selection polygony; soil/crop geometrie, dotykové
plochy a původní PNG zůstávají beze změny. [Souřadnice a skutečné GPU
výřezy](PHASE176_GREENHOUSE_FRONT_SELECTION.md).

17 cílených kontrol a všech osm kliknutí ve dvou rozloženích PASS. Zadní
záhony jsou před/po pixelově totožné. Úplný běh
`.godot/validation/20260829-014854Z`: **6 702 testů PASS**, capture PASS,
**24/34 obrazových bran PASS / FAILED**. Přesně stejných deset starších
bran i jejich metriky zůstává shodných s Phase175; žádná nová neprošla.
Reference, masky ani tolerance se nemění. Quick
`.godot/automation/20260829-015512Z` skončil technickým PASS a
`HOW_TO_GROW_AUTOMATION=PASSED`.

`PHASE176_LOCAL_TECHNICAL_FRONT_SELECTION=PASSED`.
`PHASE176_USER_VISUAL_ACCEPTANCE=PENDING_USER_REVIEW`.
`PHASE176_ANDROID_ACCEPTANCE=NOT_RUN_APK_DEFERRED_BY_USER`.
Immutable RC58, APK, hráčská data a předchozí pracovní změny jsou zachované.

## Předchozí zdrojová změna — Phase175

Horní HUD už neořezává konec dne ani dlouhý zůstatek mincí. Obě hodnoty
mají širší shodnou bezpečnou oblast a společný měřicí helper volí největší
font, který se celý vejde při 432 × 960 i 360 × 800. Karty, ikony a panel
úrovně zůstávají beze změny. [Metriky a GPU důkazy](PHASE175_HUD_VALUE_FIT.md).

32 cílených kontrol a šest GPU stavů PASS. Úplný běh
`.godot/validation/20260829-005654Z`: **6 701 testů PASS**, capture PASS,
HUD brána PASS s **0,000 % změněných nemaskovaných pixelů**. Celkově
**24/34 obrazových bran PASS / FAILED** kvůli přesně stejné množině deseti
dříve známých porovnání jako Phase174; žádná nová neprošlá brána.
Reference, masky ani tolerance se nemění.
Quick `.godot/automation/20260829-010437Z` skončil VisualContract +
Regression PASS a `HOW_TO_GROW_AUTOMATION=PASSED`.

`PHASE175_LOCAL_TECHNICAL_HUD=PASSED`.
`PHASE175_USER_VISUAL_ACCEPTANCE=PENDING_USER_REVIEW`.
`PHASE175_ANDROID_ACCEPTANCE=NOT_RUN_APK_DEFERRED_BY_USER`.
Immutable RC58, APK, hráčská data a předchozí pracovní změny jsou zachované.

## Předchozí zdrojová změna — Phase174

Pouze žluté zvýraznění zadních dvou polí Skleníku je zarovnané podle
perspektivy původních dřevěných hran. Přední zvýraznění a jeho celé snímky
jsou před/po pixelově totožné v obou rozloženích. Plodiny, dotykové cíle
a ostatní obrazovky se nemění. [Výřezy a důkazy](PHASE174_GREENHOUSE_REAR_SELECTION.md).

16 cílených kontrol a všechna čtyři kliknutí v každém ze dvou rozložení PASS.
Úplný běh `.godot/validation/20260829-000147Z`: **6 676 testů PASS**,
GPU capture PASS, **24/34 obrazových bran PASS**, celkově **FAILED**.
Deset neprošlých porovnání včetně metrik je přesně stejných jako Phase173;
žádná nová neprošlá brána. Reference, masky a tolerance se nemění.

`PHASE174_USER_VISUAL_ACCEPTANCE=PENDING_USER_REVIEW`.
`PHASE174_ANDROID_ACCEPTANCE=NOT_RUN_APK_DEFERRED_BY_USER`.
Immutable RC58, hráčská data a předchozí změny zůstávají zachované.

## Předchozí zdrojová změna — Phase173

Horní lišta detailu už nemá bílé/krémové mezery kolem zaoblených tlačítek.
Lokální podklad je shodný s tmavým HUDem; velikost ovládání, PNG a dosednutí
rostliny se nemění. [Skutečné snímky a výsledky](PHASE173_DETAIL_HEADER_EDGES.md).

11 cílených kontrol, 202 GPU pixelových sond a automatické kliknutí přes
Godot GUI na obě šipky, Herbář i stojan PASS. Běžné a úzké rozložení mimo
horní lištu a její převzorkovaný okraj zůstává pixelově shodné s Phase172.

Úplná validace `.godot/validation/20260828-232653Z`: **6 670 testů PASS**,
capture PASS, **24/34 obrazových bran PASS**, tedy celkově **FAILED**.
Jde o stejných deset neprošlých bran jako dříve; čtyři detaily navíc
zachycují nynější záměrnou změnu podkladu. Všechny byly prohlédnuté.
Reference, masky a tolerance zůstávají beze změny.
Quick `.godot/automation/20260828-233052Z`: **PASSED**, exit 0.

`PHASE173_USER_VISUAL_ACCEPTANCE=PENDING_USER_REVIEW`.
`PHASE173_ANDROID_ACCEPTANCE=NOT_RUN_APK_DEFERRED_BY_USER`.
RC58, předchozí pracovní změny, hráčská data a grafika rostlin jsou zachované.

## Předchozí zdrojová změna — Phase172

Detail rostliny po otevření ze stojanu používá stejnou malovanou terakotovou
podmisku jako schválený stojan. Keramika je ukotvená podle změřené horní
plochy parapetu a při animaci se nepohybuje; efekty péče zůstávají aktivní.
Celý canvas i podmiska se vejdou také do skutečného detailu 360 × 300.
[Oprava detailu, skutečné snímky a testy](PHASE172_PLANT_DETAIL_SILL_GROUNDING.md).

Regrese **6 662 kontrol PASS**, cílená sada **84 PASS** včetně 3 752
animačních kombinací, 12 GPU snímků a Quick PASS. Úplná validace
`.godot/validation/20260828-220639Z` má **24/34 obrazových bran PASS**, tedy
celkově **FAILED**, nikoli PASS: šest starších rozdílů stojanu a čtyři
rozdíly nově opraveného detailu vůči původním referencím. Všech deset
porovnání bylo prohlédnuto. Reference, masky a tolerance jsou nezměněné.

`PHASE172_USER_VISUAL_ACCEPTANCE=PENDING_USER_REVIEW`.
`PHASE172_ANDROID_ACCEPTANCE=NOT_RUN_APK_DEFERRED_BY_USER`.
Schválení Phase171 stojanu je zaznamenané zvlášť; samostatné dialogové
a efektové reference nebyly automaticky schváleny ani nahrazeny.
110 chráněných souborů je hashově nezměněných včetně původních PNG,
Phase170 podmisky, Phase171 stojanu, referencí, kanonického capture a RC58 APK.
Žádná změna ekonomiky, save schématu, hráčských dat, verze nebo instalace.

## Předchozí zdrojová změna — Phase171

Pěstitelský stojan ROSTLINY má novou společnou malbu a změřené dosednutí
otevřených i zamčených nádob na obou policích. Štítky patří na čela desek,
stavové ikony nezasahují do podmisek a všechny názvy mají měřený font-fit.
Uživatel při zadání Phase172 schválil také skutečný celý stojan Phase171.
Původní rostliny, lampy, zamčené PNG, podmiska, Pokoj a detail jsou zachované.
[Skutečný snímek, konstrukce a důkazy Phase171](PHASE171_PAINTED_RACK_GROUNDING.md).

Regrese **6 652 kontrol PASS**, cílené testy **41 PASS**, 1 340 kombinací
kontaktů/siluet, 280 případů textu a osm skutečných GPU snímků prošly.
Hlavní agent prohlédl všechny snímky pro běžný i kratší displej.
Quick `.godot/automation/20260828-205331Z`: native exit 0,
VisualContract + Regression PASS, `HOW_TO_GROW_AUTOMATION=PASSED`.

**Úplná validace není PASS**: `.godot/validation/20260828-204526Z`
má native exit 1 a `HOW_TO_GROW_VISUALS=FAILED`, **28/34 bran PASS**.
Šest neprošlých bran je starý stojan, tři překryvy Profesora Bazala
a efekty odemčení/přechodu nad stojanem. Prohlédnuté heatmapy ukazují
změněné prostředí pod nezměněnými ovládacími prvky/efekty. Srovnání se
skutečným Phase170 během má 135/191 původních snímků byte-exact.
Žádné reference, masky ani tolerance se nepřepisují; Quick neznamená
splnění těchto šesti obrazových bran.

`USER_VISUAL_ACCEPTANCE=APPROVED_BY_USER` pro stojan Phase171.
`REFERENCE_TRANSITION=NOT_APPLIED_SEPARATE_OVERLAY_APPROVAL_REQUIRED`.
`ANDROID_ACCEPTANCE=NOT_RUN_APK_DEFERRED_BY_USER`.
103 předem chráněných souborů, schválená Phase170 podmiska a její
manifest i kanonický capture jsou hashově nezměněné. RC58/code75/schema41
a původní immutable APK zůstávají beze změny. Existující Phase166–170
práce, hráčská data i starší důkazy jsou zachované, bez commitu nebo cleanupu.

## Předchozí zdrojová změna — Phase170

ROSTLINY používají novou mělkou malovanou terakotovou podmisku místo
plochých tyrkysových kruhů. Všech 67 původních rostlinných PNG zůstává
beze změny; měřená základna správně usazuje každý stav na podmisku
a původní polici. Celý květináč už neplave nad statickou keramikou.
Pokoj, detail, stojan, světla, zamčené nádoby a HUD se nemění.
[Rozsah, skutečný GPU náhled a důkazy Phase170](PHASE170_RACK_CERAMIC_SAUCERS.md).

Funkční regrese **6 640 kontrol PASS**, cílená sada 29 kontrol PASS,
matice 1 340 geometrií a osm skutečných GPU snímků prošly. Závěrečný
Quick `.godot/automation/20260828-193710Z` má native exit 0,
VisualContract + Regression PASS a `HOW_TO_GROW_AUTOMATION=PASSED`.

**Úplná validace ale zatím není PASS**:
`.godot/validation/20260828-193100Z` má native exit 1,
`HOW_TO_GROW_VISUALS=FAILED`, **30/34 aktivních obrazových bran PASS**.
Neprošly `guide-explain`, `guide-warning` a dvě Phase163 brány efektu
odemčení/přechodu. Porovnání s předchozím skutečným Phase169 během
prokázalo změněné pixely pouze u čtyř aktivních květináčů a podmisek;
dialogy, efekty ani okolí se nezměnily. Všechny reference, masky a prahy
zůstávají zachované. Quick tento výsledek nepřebíjí.

`USER_VISUAL_ACCEPTANCE=SAUCER_APPROVED_RACK_POSITION_REJECTED`: uživatel
následně schválil podmisku, ale požádal o opravu jejího usazení vůči celému
stojanu. Tuto výhradu řeší Phase171; historický výsledek testů se nemění.
`ANDROID_ACCEPTANCE=NOT_RUN_APK_DEFERRED_BY_USER`: žádný nový build
ani instalace. Původní immutable RC58, verze/code/schema i všech
103 předem chráněných souborů jsou hashově nezměněné. Existující
Phase166–169 práce, hráčská data i historické důkazy zůstávají zachované.

## Předchozí zdrojová změna — Phase169

Oprava odstranila šedé lemy podmisek a ověřené světlé zbytky pozadí
u dvanácti pokojových rostlin. Nové verzované deriváty mění pouze alfa
kanál, nikoli RGB malbu, plátno, měřicí body nebo geometrii. Původní PNG,
schválené reference, ekonomika, save i přesouvání rostlin jsou zachované.
[Rozsah a skutečné snímky Phase169](PHASE169_ROOM_PLANT_EDGE_CLEANUP.md).

Úplná validace `.godot/validation/20260828-180417Z` prošla s native exit 0:
`MVP_TESTS_PASSED=6626`, capture, visuals a validation PASS,
**34/34 aktivních obrazových bran**. Ve srovnání s předchozím Phase168
reportem se nezměnil žádný hash reference ani vykazované nastavení brány.
Plně vybavený pokoj má MAE 0,144119 / RMSE 2,338530 / změněný podíl
0,456 %; jde o očekávanou lokální opravu, nikoli nulový rozdíl renderů.

Cílený GPU capture `.godot/phase169-rack-final` má explicitní PASS a prázdný
stderr. Interně jsou prohlédnuté všechny čtyři cykly řad v běžné i kompaktní
velikosti (osm nativních snímků) a plný runtime včetně náhledu a výsledku
výměny. `USER_VISUAL_ACCEPTANCE=PENDING_REVIEW_OF_FIX` zůstává oddělené
od technického výsledku. Závěrečný Quick
`.godot/automation/20260828-182116Z` prošel VisualContractem i 6 626
regresními kontrolami, s native exit 0 a `HOW_TO_GROW_AUTOMATION=PASSED`.

`ANDROID_ACCEPTANCE=NOT_RUN_SOURCE_ONLY`: APK se podle zadání vynechává.
Immutable RC58 `0.68.0-rc58` / code 75 / schema 41 ani jeho SHA256 se
nemění. Existující rozpracované změny Phase166–168 zůstávají zachované;
nový build, instalace, zásah do hráčského save, commit ani cleanup neproběhly.

## Předchozí zdrojová změna — Phase168

Pokoj nyní odpočívá bez vlastního frame ticku a překresluje se jen při
skutečné změně. Podržení probudí indikátor; pohyb a puštění fungují dál
přes hlavní vstup i po uspání view. Geometrie se počítá pouze při novém
meshi nebo rozměru a nezměněný refresh znovu nekopíruje celý katalog.
[Rozsah, měření a důkazy Phase168](PHASE168_ROOM_RENDER_EFFICIENCY.md).

**Úplná source-only automatizace prošla všemi šesti kroky**:
`.godot/automation/20260827-223753Z`, native exit 0. Finální validace
`.godot/validation/20260827-223801Z` má `MVP_TESTS_PASSED=6454`,
capture, visuals i validation PASS a 34/34 aktivních obrazových bran.
Pět Phase167 referencí má MAE/RMSE/podíl změn 0; osm snímků přesunů,
výměn a jednotlivých řad je i hashově shodných s předchozím Phase167 během.
Manifest, tolerance ani jediný chráněný PNG se nepřepisovaly.

Sedm výkonových scénářů nově zahrnuje plně vybavený Pokoj a skutečné
tažení přes Viewport. Za 360 klidových snímků klesly CanvasItem redraw
callbacky z 360 na 0, při tažení ze 720 na 360. Dvě měření po změně
prošla se stejnými limity a bez růstu mesh cache. Obecná endurance prošla
48/48 cyklů, progrese 132/132 a responzivní matice 15/15.
Závěrečný Quick `.godot/automation/20260827-224616Z` znovu prošel
VisualContractem i 6 454 regresními kontrolami, native exit 0.

APK a telefon se podle posledního zadání vynechávají:
`ANDROID_ACCEPTANCE=NOT_RUN_SOURCE_ONLY`. Technický desktopový PASS
neprokazuje fyzickou odezvu dotyku, teplotu nebo baterii telefonu.
Runtime zůstává `0.68.0-rc58` / code 75 / schema 41; hash immutable
RC58 i všech 91 předem chráněných souborů zůstal zachovaný. Existující
rozpracované Phase166/167 změny nebyly vráceny ani automaticky commitnuty.

## Předchozí zdrojová změna — Phase167

Oprava orchideje a všech dvanácti pokojových rostlin sjednocuje skutečně
měřenou keramiku, dosednutí na police, souvislé stonky a nezkreslené květy.
Nové odvozené PNG obnovují ztracené části květů z původního atlasu bez změny
malby nebo archivních PNG. Geometrie a dotykové oblasti fungují i po výměně
rostlin mezi policemi. Přesný rozsah, skutečný náhled a důkazy obsahuje
[audit Phase167](PHASE167_ROOM_RACK_VISUAL_REPAIR.md).

**Uživatel opravený render schválil. Funkční regrese: 6 414 kontrol PASS.
Přísné obrazové porovnání: 34/34 aktivních bran PASS.** Úplná validace
`.godot/validation/20260827-220126Z` má všechny povinné markery a native
exit 0. Pět nových verzovaných Phase167 referencí chrání schválený stojan
se stejnými tolerancemi, cropy a maskami; všech pět má MAE/RMSE/podíl změn 0.
Původní PNG jsou zachované a stará porovnání zůstávají diagnostická.
Předchozí FAILED běh `.godot/validation/20260827-213709Z` zůstává historickým
důkazem před schválením, nikoli zpětně změněným výsledkem.

Cílený GPU capture `.godot/phase167-rack-audit-final` prošel včetně nativních
snímků pro běžný i kratší pokoj a zachování přetažení/výměn. Interní vizuální
kontrola je oddělená od `USER_VISUAL_ACCEPTANCE=APPROVED_BY_USER` a
`ANDROID_ACCEPTANCE=NOT_RUN_SOURCE_ONLY`. Immutable RC58, telefonní data,
save schema 41 a rozpracovaná Phase166 zůstávají zachované; žádný nový APK
ani fyzický audit touto opravou nevznikl.

Quick `.godot/automation/20260827-220422Z` prošel (VisualContract + Regression,
native exit 0). Předchozí responzivní matice `.godot/responsive/20260827-214227Z`
prošla 15/15 scénářů; schvalovací krok runtime ani layout neměnil.
Zdrojová vizuální oprava je uzavřená, fyzické přijetí nového APK tím nevzniká.

## Předchozí zdrojová změna — Phase166 (historické výsledky)

Pokoj má podržení a přetažení vlastněných rostlin ve stojanu 3 × 4:
prázdný cíl znamená přesun, obsazený cíl atomickou výměnu obou květináčů.
Zachovává zrušení přerušených gest a save schema 41. Původní přesouvání
prošlo úplnou automatizací `.godot/automation/20260827-195909Z`.
Dodatečně vyžádané výměny prošly 1 040 cílenými kontrolami a novou úplnou
validací `.godot/validation/20260827-202200Z`: 2 598 regresních kontrol,
34/34 obrazových bran, capture a interní kontrola skutečného GPU renderu
mají `PASSED`. Zdrojové PNG i schválené reference zůstaly beze změny.
[Samostatný audit fáze 166](PHASE166_ROOM_PLANT_DRAG.md) odděluje
aktuální ověření, historické výsledky a dosud neprovedené fyzické přijetí.

Tato změna je **source-only**. Immutable RC58 `0.68.0-rc58` / code 75
z Phase165 se nepřebaluje a jeho dřívější Android PASS neprokazuje nové
gesto. Nový APK ani nový telefonní audit v Phase166 dosud nevznikly.

## Ověřeno automaticky

| Oblast | Stav | Důkaz |
|---|---|---|
| Import Godot 4.7 | Prošlo | Součást posledního validačního běhu |
| Regresní sada — historický baseline fáze 82 | Prošlo | `MVP_TESTS_PASSED=838` / `20260818-104639Z` |
| Regresní sada — fáze 83 | Prošlo | `MVP_TESTS_PASSED=861` / `20260818-114416Z` |
| Regresní sada — fáze 84 | Prošlo | `MVP_TESTS_PASSED=882` / `20260818-123342Z` |
| Regresní sada — fáze 88 nad RC27 | Prošlo v hlavním projektu | `MVP_TESTS_PASSED=933` / `20260818-165822Z` |
| Regresní sada — fáze 90 | Prošlo v čerstvém integračním zrcadle | `MVP_TESTS_PASSED=937` / `20260818-180031Z` |
| Regresní sada — fáze 91 | Prošlo v hlavním projektu | `MVP_TESTS_PASSED=951` / `20260818-190146Z` |
| Regresní sada — fáze 93 | Prošlo v hlavním projektu | `MVP_TESTS_PASSED=1036` / `20260818-210938Z` |
| Regresní sada — fáze 94 / RC28 | Prošlo lokálně | `MVP_TESTS_PASSED=1036` / `20260818-214533Z` |
| Regresní sada — auditní zpevnění fáze 94 | Prošlo v hlavním projektu | `MVP_TESTS_PASSED=1040` / `20260818-220409Z`; PowerShell AST/helper smoke `PASSED` |
| Regresní sada — finální privacy a APK identity fáze 94 | Prošlo v hlavním projektu | `MVP_TESTS_PASSED=1042`; 6/6 cílených kontrol fáze 94 a PowerShell AST/helper smoke `PASSED` |
| Regresní sada — fáze 95 | Prošla v hlavním projektu | `MVP_TESTS_PASSED=1078` / `.godot/validation/20260819-071937Z` |
| Regresní sada — fáze 96 | Prošla v hlavním projektu | `MVP_TESTS_PASSED=1108` / `.godot/validation/20260819-101102Z` |
| Regresní sada — fáze 97 | Prošla v hlavním projektu | `MVP_TESTS_PASSED=1140` / `.godot/validation/20260819-121431Z` |
| Regresní sada — fáze 98 | Prošla v hlavním projektu | `MVP_TESTS_PASSED=1176` / `.godot/validation/20260819-143453Z` |
| Regresní sada — fáze 99 | Prošla v hlavním projektu | `MVP_TESTS_PASSED=1204` / `.godot/validation/20260819-155446Z` |
| Regresní sada — RC29 | Prošla v release běhu | `MVP_TESTS_PASSED=1204` / `.godot/validation/20260819-162251Z`; 14/14 aktivních vizuálních gate |
| Celý první cyklus přes UI | Prošlo | Slot → zasadit → zalít → měření → růst → sklizeň → sušení → balení → prodej |
| Save kompatibilita fáze 97 | Prošla v hlavním projektu | Hlavní schema 1–26; lifecycle 20, inventář semen 21, balíčky 22, první kapitola 23, druhá 24, směsi 25 a třetí kapitola 26. Story trust boundary 23/24/26 ignorují starší injekce, aktivní ID se odvozuje a schema 25 po legitimním dokončení prvních dvou kapitol založí čistou třetí |
| Save kompatibilita fáze 98 | Prošla v hlavním projektu | Hlavní schema 1–27; schema 27 přidává oddělený týdenní výzkum a zachovává story trust boundary 23/24/26. Kořenové schema musí být přesné konečné celé číslo, reálné UTC dny jsou přesná ohraničená celá čísla a rollback-safe high-water brání opakovaným týdnům i odměnám |
| Save kompatibilita fáze 99 | Prošla v hlavním projektu | Hlavní schema 1–28; schema 27 aktivní protokol migruje na `balanced_v1` bez ztráty postupu. Schema 28 zachová bezpečnou historii při neznámém `protocol_id`, ale zahodí jeho neautoritativní active assignment. Story trust boundary 23/24/26, směsi 25 a základ výzkumu 27 zůstávají oddělené |
| Izolace testovacích dat | Prošlo | Testy a capture používají vlastní `APPDATA` pod `.godot/` |
| Oficiální vizuální validace | Prošlo | Běh fáze 90 v čerstvém integračním zrcadle `20260818-180031Z`: `HOW_TO_GROW_VALIDATION=PASSED`, všech 14 aktivních gate prošlo bez oslabení tolerancí a schválené reference i manifest zůstaly beze změny |
| Finální vizuální validace fáze 91 | Prošlo v hlavním projektu | `.godot/validation/20260818-190146Z`: capture, visuals i úplná validace `PASSED`, 14/14 aktivních gate, beze změny referencí a tolerancí |
| Finální vizuální validace fáze 93 | Prošlo v hlavním projektu | `.godot/validation/20260818-210938Z`: capture, visuals i úplná validace `PASSED`, 14/14 aktivních gate; snímky aktivní a připravené kapitoly jsou report-only a schválené reference, manifest i tolerance zůstaly beze změny |
| Finální vizuální validace fáze 94 / RC28 | Prošlo lokálně | `.godot/validation/20260818-214533Z`: capture, visuals i úplná validace `PASSED`, 14/14 aktivních gate; schválené reference a tolerance zůstaly beze změny |
| Finální validace po auditním zpevnění | Prošlo v hlavním projektu | `.godot/validation/20260818-220409Z`: 1040/1040, capture, visuals i úplná validace `PASSED`, 14/14 aktivních gate |
| Finální regresní kontrola privacy a APK identity | Prošlo v hlavním projektu | 1042/1042; 6/6 cílených kontrol fáze 94 a PowerShell AST/helper smoke `PASSED` |
| Finální vizuální validace fáze 95 | Prošla v hlavním projektu | `.godot/validation/20260819-071937Z`: 1078/1078, capture, visuals i úplná validace `PASSED`, 14/14 aktivních gate |
| Finální vizuální validace fáze 96 | Prošla v hlavním projektu | `.godot/validation/20260819-101102Z`: 1108/1108, capture, visuals i úplná validace `PASSED`, 14/14 aktivních gate; `comic-herbal-blend-order.png` je report-only a reference, manifest i tolerance se nezměnily |
| Finální vizuální validace fáze 97 | Prošla v hlavním projektu | `.godot/validation/20260819-121431Z`: 1140/1140, capture, visuals i úplná validace `PASSED`, 14/14 aktivních gate; čtyři nové příběhové/deníkové PNG jsou report-only a reference, manifest i tolerance se nezměnily |
| Finální vizuální validace fáze 98 | Prošla v hlavním projektu | `.godot/validation/20260819-143453Z`: 1176/1176, capture, visuals i úplná validace `PASSED`, 14/14 aktivních gate; tři nové týdenní PNG jsou report-only a reference, manifest i tolerance se nezměnily |
| Finální vizuální validace fáze 99 | Prošla v hlavním projektu | `.godot/validation/20260819-155446Z`: 1204/1204, capture, visuals i úplná validace `PASSED`, 14/14 aktivních gate; pět nových protokolových/showroom PNG je report-only a reference, manifest, crop, masky i tolerance se nezměnily |
| Fáze 6–7 | Schváleno | Tři pózy průvodce a pět efektových/přechodových stavů mají nové immutable reference |
| Fáze 9 | Prošlo | Procedurální hudba/SFX, haptika a uložitelný fullscreen panel nastavení |
| Fáze 10 | Prošlo | Tři deterministické zakázky, kvalita/hmotnost, odměny, rotace a UI-driven odevzdání |
| Fáze 11–12 | Prošlo | Druh máty, výběr semene, herbář a pět mistrovských hodností |
| Fáze 13 | Prošlo | Jeden globální den/počasí, předpověď a denní úkol s jednorázovou odměnou |
| Fáze 14 | Prošlo | Tři uložené kosmetické vzhledy bez vlivu na simulaci |
| Fáze 15 | Prošlo lokálně | Save recovery, background/resume a auditovatelný RC runner `0.15.0-rc1` |
| Fáze 17 | Prošlo | Uložitelný denní sklad pana Kořínka, atomický nákup, vyprodání a ochrana proti manipulaci s časem |
| Fáze 18 | Prošlo | Druhové zakázky, férový výpočet odměny a dvě uložené denní výměny nabídky |
| Fáze 19 | Prošlo lokálně | Samostatný katalog rostlin, navigační služba a komponenta tabule zakázek se zpětně kompatibilními obálkami |
| Fáze 20 | Prošlo lokálně | Samostatný prezentační katalog druhů a skladový presenter bez přestavby UI nebo změny herní logiky |
| Fáze 21 | Prošlo lokálně | Samostatný presenter nákupu, kategorií a výkupu pana Kořínka; transakce, denní refresh a save zůstávají v orchestraci |
| Fáze 22 | Prošlo lokálně | Samostatný read-only presenter denní výzvy; odměna, save, audio a modalová orchestrace zůstávají v hlavní scéně |
| Fáze 23 | Prošlo lokálně | Samostatný presenter tří kosmetických karet; nákup, výběr motivu, překreslení pokoje a save zůstávají v doménové orchestraci |
| Fáze 24 | Prošlo lokálně | Samostatný presenter počtů a dostupnosti tří druhů semen; zasazení, spotřeba inventáře, journey, save a audio zůstávají v orchestraci |
| Fáze 25 | Prošlo lokálně | Samostatný read-only presenter tří karet herbáře; vyzvednutí mistrovské odměny, ekonomika, save a audio zůstávají v orchestraci |
| Fáze 26 | Prošlo lokálně | Samostatný read-only presenter deseti měření, grafových vzorků a druhové nápovědy; simulace i schválený strom měření zůstávají nedotčené |
| Fáze 27 | Prošlo lokálně | Samostatný read-only souhrn vybraného slotu a tří karet zásob; pipeline, zakázky, inventářové mutace a save zůstávají mimo presenter |
| Fáze 28 | Prošlo lokálně | Samostatný read-only presenter růstové fáze, růstového ukazatele a tří vitálních karet; péče, animace, simulace a save zůstávají v doménové orchestraci |
| Fáze 29 | Prošlo lokálně | Samostatný presenter návratového textu; lifecycle, offline simulace, třídenní limit, save a modalová orchestrace zůstávají v hlavní scéně |
| Fáze 30 | Prošlo lokálně | Samostatný presenter recovery textů a potvrzovacího tlačítka; ochrana zápisu, mazání souborů, nová relace a save zůstávají mimo presenter |
| Fáze 31 | Prošlo lokálně | Samostatný presenter viditelnosti, dostupnosti a textů pěti akcí detailu; callbacky péče, simulace, efekty a save zůstávají v hlavní scéně |
| Fáze 32 | Prošlo lokálně | Samostatný presenter textu pauzy a výběru pěti rychlostí; změna simulace, callbacky, dialog a save zůstávají v hlavní scéně |
| Fáze 33 | Prošlo lokálně | Primitive-only presenter počtu obsazených pozic a označení vybraného květináče; výběr, zámky, swipe a přechod do detailu zůstávají mimo presenter |
| Fáze 34 | Prošlo lokálně | Primitive-only presenter textu dne a velikosti fontu pro 1–6+ číslic; světový čas, launcher výzvy, HUD strom a modal zůstávají mimo presenter |
| Fáze 35 | Prošlo lokálně | Primitive-only presenter textu úrovně a XP; progress bar, přičítání, tweeny, odměny a postup zůstávají mimo presenter |
| Fáze 36 | Prošlo lokálně | Primitive-only presenter průběžné hodnoty mincí; ekonomika, tween, ikona, dočasný zisk a částice zůstávají mimo presenter |
| Fáze 37 | Prošlo lokálně | Primitive-only presenter čtyř nastavení, dvou posuvníků a stavové zprávy; session, audio, haptika, callbacky a save zůstávají mimo presenter |
| Fáze 38 | Prošlo lokálně | Presenter dvou dialogových textů a čisté klasifikace nálady průvodce; modal, postava, mluvení, tweens a feedback zůstávají mimo presenter |
| Fáze 39 | Prošlo lokálně | Jednotné zprávy a barvy pana Kořínka i nákupního feedbacku; transakce, sklad, ceny, save, pulz a reakční tween zůstávají v orchestraci |
| Fáze 40 | Prošlo lokálně | Pět globálních pomůcek ve třech úrovních, atomické nákupy, level locky, skutečné simulační účinky, schema 12 a samostatný mobilní katalog vybavení |
| Fáze 41 | Prošlo lokálně | Cesta pěstitele 1–10, transparentní vstup z XP karty, uložené jednorázové odměny, automatické otevření při level-upu a bezpečná migrace schema 13 |
| Fáze 42 | Prošlo lokálně | Centrum péče pro 10 slotů, deterministická priorita problémů, bezpečné mobilní cíle a přesný přechod na detail nebo do skladu bez automatické péče |
| Fáze 43 | Prošlo lokálně | Predikce další kontroly podle simulace, bezpečné předběžné hranice, jednorázová neblokující odezva a uložitelný in-app přepínač v schema 14 |
| Fáze 44 | Prošlo lokálně | Vlastní Godot 4.7 Gradle vrstva, dobrovolné Android 13+ oprávnění, jeden lokální alarm nejbližší péče, restart recovery a desktopový fallback; fyzické doručení čeká na telefon |
| Fáze 45 | Prošlo lokálně | Future-save precedence, UTC denní odměny, dosažitelné dlouhodobé zakázky a jednotná release metadata ve schema 15 |
| Fáze 46 | Prošlo lokálně | Jednotné kontrolované ukládání, retry dialog, ochrana při zavírání a cold-start návratový souhrn bez dvojího posunu |
| Fáze 47 | Prošlo lokálně i fyzicky | Přenositelná `.htgbackup` záloha, kontrola integrity a kompatibility, náhled před importem a bezpečnostní kopie původního postupu; RC12 export/import ověřen na Xiaomi |
| Fáze 48 | Technicky prošlo, ruční část částečně | Pět minut na Xiaomi Redmi Note 11 Pro 5G: zachovaný save, 0 crash/ANR, thermal status 0, 31,2–34,3 °C a potvrzené rolování; RC12 doplnila bezpečný obraz i přenos zálohy, oznámení po restartu telefonu čeká |
| Fáze 49 | Prošlo lokálně | Odvozený Pěstitelský deník, osm dlouhodobých odznaků, automatická další priorita a samostatný rolovatelný mobilní modal bez nové ekonomiky či save migrace |
| Fáze 50 | Nahrazeno přísnější bránou | Původní launcher dostal ve fázi 76 kontrolu odemčeného telefonu, interaktivního popředí a skutečného pokrytí vzorků; neplatný záznam už se nesmí vydávat za průchod |
| Fáze 51 | Prošlo lokálně | Jeden krok rostliny publikuje jedinou změnu, skryté animační komponenty nespouštějí průběžný proces a CPU p95 9,738 ms prošlo 10ms bránou |
| Fáze 52 | Prošlo lokálně | Aktivní-only UI refresh, 30Hz ambient pokoje, pozastavení zakrytých animací, pětiscénářová výkonová matice a čisté ukončení screenshotové validace bez RID/ObjectDB úniků |
| Fáze 53 | Prošlo lokálně | Android-only 20sekundový self-test upozornění, pravdivý stav oprávnění, ochrana testu před přepsáním při odchodu a přesný ruční auditní postup |
| Fáze 54 | Prošlo lokálně | Jednorázový Android deep link z upozornění na přesný květináč nebo Sklad, cold-start i běžící aplikace a DEX kontrola nativního bridge |
| Fáze 55 | Prošlo lokálně | Systémové Zpět nejprve zavře modal, detail nebo vedlejší záložku; chráněný save neobejde a čistý pokoj končí pouze přes kontrolované uložení |
| Fáze 56 | Prošlo lokálně | Pravdivá verze a čas posledního save, dvoukroková nová hra, atomický zápis a samostatná interní kopie předchozího postupu |
| Fáze 58 | Prošlo lokálně | Podmíněná dvoukroková obnova předchozí hry s náhledem a bezpečnostní kopií právě aktivního novějšího postupu |
| Fáze 59 | Prošlo lokálně i fyzicky | Android export zachoval přesnou `.htgbackup` příponu, import ji přijal, aktivní schema 15 i `before_import` kopie přežily restart aplikace; starší `.htgbackup.json` zůstává regresně podporovaný |
| Fáze 60 | Prošlo lokálně, fyzická kontrola čeká | Cesta pěstitele používá jednotný mobilní scroll; focus-only Android překryv nespouští suspend/resume a foreground upozornění už nepřekreslí otevřenou hru |
| Fáze 61 | Prošlo lokálně i fyzicky | Herbář používá jednotný mobilní scroll a 350×/1000× stabilizuje pouze dekorativní atmosféru bez zpomalení simulace nebo měření |
| Fáze 62 | Prošlo lokálně | Kontextová aktivní léčba nemocné rostliny používá existující postřik, přirozený anti-spam a podmínku nepřemokřené půdy bez nové save migrace |
| Fáze 63 | Prošlo lokálně | Mobilní diagnostika čte sedm oblastí stavu rostliny, řadí problémy podle závažnosti a doporučuje bezpečný další krok bez změny save |
| Fáze 64 | Prošlo lokálně | Typované CTA diagnostiky vede na správnou péči, Měření, Sklad, semínka nebo zásoby v obchodě bez automatického zásahu |
| Fáze 65 | Prošlo lokálně, APK nainstalováno | Při 350×/1000× se nová krize, zralost nebo konec sušení jednou pozastaví a otevře Centrum péče bez automatické akce; volba je uložená ve schema 16 |
| Fáze 66 | Prošlo lokálně, fyzická kontrola čeká | Denní úkol vychází ze skutečného stavu zahrady, přesměruje hráče na přesný květináč nebo Sklad a nikdy neprovede akci automaticky |
| Fáze 67 | Prošlo lokálně, fyzická kontrola čeká | Výběr semen, Centrum péče a Kouzelný showroom sdílejí plynulé svislé gesto; pokoj prošel 10ms CPU bránou bez změny obrazu nebo simulace |
| Fáze 68 | Prošlo lokálně | Povinný endurance průchod opakuje obrazovky, deset modalů, simulaci a skutečný diskový save/load a omezuje růst uzlů, orphanů, zdrojů i paměti |
| Fáze 69 | Prošlo lokálně | Sedm poměrů displeje a safe-area výřezů, čtyři obrazovky, čtrnáct blokujících modalů, auditní PNG/JSON a kontrola odkrytých okrajů |
| Fáze 70 | Prošlo lokálně | Třicet úplných cyklů všech tří druhů, skutečná ekonomika a save/load, úroveň 19, deset slotů, maximální vybavení a mistrovství 5/5 |
| Fáze 71 | Prošlo lokálně | Oregano je čtvrtá plnohodnotná bylina s vlastním profilem, ekonomikou, herbářem, odborným textem a šestistavovou komiksovou rodinou |
| Fáze 72 | Prošlo lokálně | Uložený denní plán připravuje přesný květináč na zítřejší počasí, zůstává stabilní při 1000× a zachovává jedinou UTC odměnu |
| Fáze 73 | Prošlo lokálně | Pevné reálné cykly 5/6/12/14 hodin, dvanáctiminutová výuková bazalka, bez hráčské pauzy či násobiče a schema 19 s bezpečnou migrací |
| Fáze 74 | Hotovo · 100 % | Časová karta, verzované oficiální reference, všechna aktivní vizuální gate a 48cyklová čtyřdruhová postupová brána prošly |
| Fáze 75 | Hotovo · 100 % | Schema 20, `Stage.DEAD`, vadnutí po 2 h, úhyn po 3 h, záchrana, čerstvost, UI, offline souhrn a nejbližší upozornění pokrývá aktuální regresní sada |
| Fáze 76 | Hotovo lokálně · 100 % | Jeden kanonický katalog pěti rarit, pravdivé objevování herbáře, uzamčené karty, rarity v semínkách i obchodě a zpevněný Android audit; save schema zůstává 20 |
| Fáze 77 | Hotovo lokálně · 100 % | Schema 21, jediný obecný inventář semen, normalizace schema 1–20 do rozsahu 0–9 999 bez dvojího započtení, bezpečná budoucí ID a atomické limity nákupu; bez nové grafiky, RNG nebo plateb |
| Fáze 78 | Hotovo lokálně · 100 % | Schema 22, zapečetěný deterministický výsledek při přidělení, fronta nejvýše 32 balíčků, jeden zdroj po vedené cestě a nejvýše jeden z vyzvednuté denní výzvy, veřejné šance, ochrana po čtyřech duplicitách a atomické otevření; bez klíčů, reklam, nákupu nebo plateb |
| Fáze 79 | Hotovo lokálně · 100 % | Čtyři explicitní profilové vlastnosti bez skrytého vlivu rarity, společný katalog a aktivace, shodná online/offline fyzika, odhad péče, bezpečný osmý diagnostický bod a presentation-only herbář/výběr semen; save schema zůstává 22 |
| Fáze 80 | Hotovo lokálně · 100 % | Explicitní manifest profilů, profilově řízená prezentace, dynamický Kořínkův obchod a stock, exportní payload z manifestu a postup `12 × počet druhů`; neznámý druh už nedostane bazalkový fallback |
| Fáze 81 | Hotovo lokálně · 100 % | První Epic levandule, šestistavová RGBA rodina, 18h růst/4h sušení, L5 vzácná zásoba, objevením podmíněná zakázka, `VOŇAVÝ KVĚT` +12 % při kondici ≥85 % a sjednocená botanical-pack pity kanonizace; schema zůstává 22 |
| Fáze 82 | Hotovo lokálně · 100 % | Detail zobrazuje odznak a kódově kreslené halo pouze při skutečně aktivní vlastnosti; kvalifikovaná zálivka máty emituje právě jednu kanonickou odezvu `plant_behavior` se skutečnou změnou zdraví. Save schema zůstává 22 a ekonomika se nemění. Důkaz: `MVP_TESTS_PASSED=838`, `.godot/validation/20260818-104639Z`, `HOW_TO_GROW_VALIDATION=PASSED`, 14/14 aktivních gate; oba nové snímky jsou report-only. |
| Fáze 83 | Hotovo lokálně · 100 % | Šestý profil `allium_schoenoprasum`, Common pažitka, přesný osmihodinový ideál přes 31 680 s × 1,10, L2 obchod 2/2/3, vlastní zakázka, schema 22, šest dynamických karet a vlastní šestistavová grafika. Důkaz: `MVP_TESTS_PASSED=861`, `.godot/validation/20260818-114416Z`, `HOW_TO_GROW_VALIDATION=PASSED`, `.godot/progression/20260818-114524Z`, 72/72 cyklů a 15 roundtripů. |
| Fáze 84 | Hotovo lokálně · 100 % | Sedmý profil `origanum_majorana`, Rare majoránka, 10h růst, 3h základní sušení a `VŮNĚ PO USUŠENÍ`, která při kvalitě ≥80 % zkrátí společný runtime/ETA cíl na 2 h 24 min. L3 obchod 1/1/2/1, vlastní zakázka, schema 22 a šestistavová grafika. Důkaz: `MVP_TESTS_PASSED=882`, `.godot/validation/20260818-123342Z`, `HOW_TO_GROW_VALIDATION=PASSED`, `.godot/progression/20260818-123451Z`, 84/84 cyklů a 17 roundtripů. |
| Fáze 85 | Hotovo v hlavním projektu · 100 % | Osmý profil `petroselinum_crispum`, Common petržel, 9h růst, 2h sušení a denní `TOLERANCE POLOSTÍNU` pod 5 400 lux se světelným faktorem nejméně 60 %. L2 obchod, cena 17, zásoba 2 + cyklus 0/1/0/0, vlastní objevením podmíněná zakázka, schema 22 a šestistavová grafika. Důkaz: `MVP_TESTS_PASSED=906`, `.godot/validation/20260818-135642Z`, `HOW_TO_GROW_VALIDATION=PASSED`, `.godot/progression/20260818-135824Z`, 96/96 cyklů a 20 roundtripů. |
| Fáze 86 | Hotovo v hlavním projektu · 100 % | Devátý profil `melissa_officinalis`, Common meduňka, 8h růst, 2h sušení a `BOHATÝ SAMOVÝSEV`, který zvyšuje společnou deterministickou šanci vrácení semínka po prodeji z 58 % na 75 %. L3 obchod, cena 18, zásoba 3/2/2/2, vlastní objevením podmíněná zakázka, schema 22 a šestistavová grafika. Důkaz: `MVP_TESTS_PASSED=928`, `.godot/validation/20260818-144151Z`, `HOW_TO_GROW_VALIDATION=PASSED`, `.godot/progression/20260818-144312Z`, 108/108 cyklů a 22 roundtripů. |
| Fáze 88 | Hotovo v hlavním projektu · 100 % | Botanický balíček doplněn do společného blocking, endurance a responsive kontraktu; detailové šipky obtáčejí pouze odemčené sloty; všech 9 zalamovaných seed karet odvozuje skutečnou výšku i dotykové minimum z mobilního layoutu. Důkaz: `MVP_TESTS_PASSED=933`, `.godot/validation/20260818-165822Z`, 14/14 gate. Stavové kolečko bylo tehdy odloženo k samostatnému obrazovému schválení a uzavírá je fáze 89. |
| Fáze 89 | Hotovo v hlavním projektu · 100 % | Stavové odznaky jsou nad pravým okrajem štítku a nepřekrývají jména. Geometrie kontroluje všech 10 slotů při 432×960, umístění uvnitř slotu a nulové vzájemné kolize. Nové reference jsou append-only, původní Phase 7 důkazy zůstávají zachované a limity se neuvolnily. Důkaz: `MVP_TESTS_PASSED=935`, `.godot/validation/20260818-174414Z`, všechny validační markery prošly, 14/14 aktivních gate, responsive `20260818-173952Z` 7/7 a endurance `20260818-174016Z` 48/48 se 7 roundtripy. |
| Fáze 90 | Hotovo v hlavním projektu · 100 % | Odstraněn nepřipojený `time_control_presenter.gd` + `.uid`, pět soukromých mrtvých helperů a registrace motivu pro nepoužívaný `OptionButton`. Veřejné `get_journey_progress`, save kompatibilita `speed_multiplier` / `paused` a fast-time migrace i diagnostika zůstaly zachované. Důkaz v hlavním projektu: `MVP_TESTS_PASSED=937`, validace `20260818-180716Z` 14/14; zrcadlo navíc prošlo endurance `20260818-180200Z` 48/48 se 7 roundtripy a responsive `20260818-180217Z` 7/7. Schema 22, ekonomika i RC27 beze změny; žádný nový Android build. |
| Fáze 91 | Hotovo v hlavním projektu · 100 % | Ventilation no-op XP fix, hostile-save normalizace a timestamp high-water, `backup_read_only` recovery a bezpečná rotace, přísnější ekonomické/pečovatelské profily, přesný Android script payload, citovaný APK cíl, immutable preflight a guard proti nativním Godot parser pádům. Důkaz: 951/951, validation `20260818-190146Z` 14/14, progression `20260818-190326Z` 108/108, endurance `20260818-190340Z` 48/48, responsive `20260818-190359Z` 7/7, performance `20260818-190416Z` a prošlý actual payload smoke. Schema 22, ekonomika, RC27 a telefonní data beze změny; RC28 nevznikl. |
| Fáze 92 | Hotovo v hlavním projektu · 100 % | Třístránkové `PŘEDÁNÍ ZAHRADY`, bezpečné přijetí/přeskočení, mutation-free replay a pravdivé dokončení Herbáře bez změny schema 22, ekonomiky nebo RC27. Důkaz: 985/985, validation `20260818-195847Z` 14/14, progression `20260818-200017Z` 108/108, endurance `20260818-200029Z` 48/48, responsive `20260818-200049Z` 7/7 a performance `20260818-200102Z`. |
| Fáze 93 | Hotovo v hlavním projektu · 100 % | Schema 23 a kapitola `lost_herbarium_pages`: pět přesných cílů, uložené přečtení/pozornost, fullscreen modal s pěti kartami a CTA, atomická odměna 75 mincí + 60 XP + 1 zapečetěný balíček + 1 Profesorova pečeť a bezpečná migrace schema ≤22. Důkaz: 1036/1036, validation `20260818-210938Z` 14/14, progression `20260818-211108Z` 108/108, endurance `20260818-211120Z` 48/48, responsive `20260818-211139Z` 7/7 a 16 modalů, performance `20260818-211153Z`. RC27 zůstává immutable schema 22; RC28, nový APK ani telefonní audit nevznikly. |
| Fáze 94 | Automatická technická část hotová · 100 % | `0.44.0-rc28` / code 45 balí zdrojové schema 23 do nového immutable ARM64 debug APK. Release audit `20260818-214533Z`, 1036/1036, validation 14/14, performance `20260818-214643Z`, endurance `20260818-214726Z` 48/48, progression `20260818-214736Z` 108/108 a responsive `20260818-214740Z` 7/7 prošly. Auditní zpevnění prošlo validation `20260818-220409Z` 1040/1040; finální privacy a APK identity prošly 1042/1042, 6/6 cílených kontrol a PowerShell AST/helper smoke. Běh `20260819-043532Z` dokládá instalaci a migraci 22 → 23; sanitizovaný běh `20260819-045658Z` finální skript a shodnou APK identitu. Ruční mobilní a publikační brány zůstávají `PENDING`. |
| Fáze 95 | Hotovo v hlavním projektu · 100 % | Desátý profil `salvia_officinalis` jako Rare / `VZÁCNÁ` / ★★ rostlina, žádný současný Legendary profil, šest přesných assetů, `modest_feeding` 0,75× v pásmu živin 24–60 %, dosažitelná zakázka, kapitola `silver_sage_legacy`, atomická odměna 100 mincí + 80 XP + 2 semínka šalvěje + druhá pečeť a hlavní schema 24. Důkaz: 1078/1078, validation `20260819-071937Z` 14/14, progression `20260819-072119Z` 120/120 a 25 roundtripů, endurance `20260819-072119Z` 48/48, responsive `20260819-072118Z` 7/7 a performance `20260819-072116Z`. Nevznikl APK ani telefonní audit; RC28/code45/schema23 zůstává historicky immutable. |
| Fáze 96 | Hotovo v hlavním projektu · 100 % | Tři dvoudruhové směsi `evening_freshness`, `soup_pair` a `aromatic_sachet`; deterministický plán dvou balíčků, přesná failure diagnostika, atomická spotřeba, dvojí mastery/seed roll a právě jedna globální zakázka. Směsi neplní daily `sell` ani Profesorův konkrétní druh. Schema 25 bezpečně migruje 24 → 25, kanonizuje směsi a claim mistrovství předem hlídá seed cap. Důkaz: 1108/1108, validation `20260819-101102Z` 14/14, progression `20260819-101241Z` 120/120 a 25 roundtripů, endurance `20260819-101241Z` 48/48, responsive `20260819-101238Z` 7/7 a performance `20260819-101302Z`. Bez nového APK a telefonu; RC28/code45/schema23 zůstává immutable. |
| Fáze 97 | Hotovo v hlavním projektu · 100 % | Třetí kapitola `grand_herbarium_exhibition` / `Velká herbářová výstava` s cíli 10/3/3/3/4, atomickou odměnou 150 mincí + 120 XP + 3 hnojiva + titul `MISTR HERBÁŘE` + třetí pečeť, devátý odznak deníku a hlavní schema 26 s trust boundary 23/24/26. Důkaz: 1140/1140, validation `20260819-121431Z` 14/14, progression `20260819-121604Z` 120/120 a 25 roundtripů, endurance `20260819-121621Z` 48/48, responsive `20260819-121643Z` 7/7 plus geometrie 432×960 a 360×800, performance `20260819-121700Z`. Bez nového APK a telefonu; RC28/code45/schema23 zůstává immutable. |
| Fáze 98 | Hotovo v hlavním projektu · 100 % | Samostatný opakovatelný `Profesorův týdenní protokol` po třech kapitolách, explicitní přijetí, cíle 3/2/2/2/2, neexpirující aktivní stav, pondělní nabídky bez backlogu/streak trestu, atomická odměna 45 mincí + 35 XP + 1 hnojivo, `completed_count`, desátý odznak `VÝZKUMNÝ PARTNER` za 4 dokončení a hlavní schema 27 s přísným integer/UTC hardeningem. Důkaz: 1176/1176, validation `20260819-143453Z` 14/14, progression `20260819-143648Z` 120/120 a 25 roundtripů, endurance `20260819-143700Z` 48/48, responsive `20260819-143722Z` 7/7, performance `20260819-143737Z`. Bez nového APK a telefonu; RC28/code45/schema23 zůstává immutable. |
| Fáze 99 | Hotovo v hlavním projektu · 100 % | Tři deterministické týdenní protokoly, immutable varianta po přijetí, hlavní schema 28 a `Badatelská pracovna` za 360 mincí po 6 dokončeních bez herního bonusu. Důkaz: 1204/1204, validation `20260819-155446Z` 14/14, progression `20260819-155623Z` 120/120 a 25 roundtripů, endurance `20260819-155637Z` 48/48, responsive `20260819-155656Z` 7/7, performance `20260819-155711Z`. |
| Fáze 100 / RC29 | Automatická technická část hotová · 100 % | `0.45.0-rc29` / code 46 / zdrojové i save schema 28 balí celý stav fáze 99. Release `20260819-162250Z`, immutable APK, podpis, payload, technická instalace, APK identity a migrace 23 → 28 prošly. Ruční 18bodová mobilní a publikační brána zůstávají `PENDING`. |
| Fáze 101 | Hotovo v hlavním projektu · 100 % | Kontextová denní výzva `rescue` dává zvadlé rostlině přednost před sklizní a počasím, vede na přesný květináč a dokončí se až po opravě kritické příčiny a úspěšném jednorázovém odstranění poškozených listů. Samotná péče ani neplatný pokus odměnu nevydají; zdravá zralá rostlina dál používá `harvest`. Save schema 28, ekonomika, PNG i layout beze změny. Důkaz: 1212/1212, validation `20260820-063931Z`, capture/visuals/full `PASSED`, 14/14 aktivních gate. Bez nového APK/AAB; ruční mobilní a publikační brána zůstávají `PENDING`. |
| Endurance | Prošlo | Běh fáze 90 v integračním zrcadle `20260818-180200Z`: 48 cyklů, 7 save/load roundtripů, růst uzlů/orphanů/zdrojů 0 a finální růst statické paměti 0,02 MiB |
| Endurance fáze 91 | Prošlo v hlavním projektu | `20260818-190340Z`: 48/48, 7 roundtripů, růst uzlů/orphanů/zdrojů 0, statická paměť +0,02 MiB |
| Endurance fáze 93 | Prošlo v hlavním projektu | `20260818-211120Z`: 48/48, 7 roundtripů, růst uzlů/orphanů/zdrojů 0, statická paměť +0,02 MiB |
| Endurance fáze 94 / RC28 | Prošlo lokálně | `20260818-214726Z`: 48/48, 7 roundtripů, růst uzlů/orphanů/zdrojů 0, statická paměť +0,02 MiB |
| Endurance fáze 95 | Prošlo v hlavním projektu | `.godot/endurance/20260819-072119Z`: 48/48, 7 roundtripů, růst uzlů/orphanů/zdrojů 0, statická paměť +0,02 MiB |
| Endurance fáze 96 | Prošlo v hlavním projektu | `.godot/endurance/20260819-101241Z`: 48/48, 7 roundtripů, růst uzlů/orphanů/zdrojů 0, statická paměť +0,02 MiB |
| Endurance fáze 97 | Prošlo v hlavním projektu | `.godot/endurance/20260819-121621Z`: 48/48, 7 roundtripů, růst uzlů/orphanů/zdrojů 0, statická paměť +0,02 MiB |
| Endurance fáze 98 | Prošlo v hlavním projektu | `.godot/endurance/20260819-143700Z`: 48/48, 7 roundtripů, růst uzlů/orphanů/zdrojů 0, statická paměť +0,03 MiB |
| Endurance RC29 | Prošlo v release běhu | `.godot/endurance/20260819-162454Z`: 48/48, 7 roundtripů, růst uzlů/orphanů/zdrojů 0, statická paměť +0,03 MiB |
| Postup a ekonomika | Prošlo | Běh fáze 88 `20260818-165822Z`: 108 úplných cyklů, přesně 12 pro každý z 9 druhů, 101 zakázek, 22 save/load roundtripů a konečný stav L69 / 9 527 mincí bez umělého připsání měny |
| Postup a ekonomika fáze 91 | Prošlo v hlavním projektu | `20260818-190326Z`: 108/108, 22 roundtripů, L69, 9 527 mincí a 101 zakázek |
| Postup a ekonomika fáze 93 | Prošlo v hlavním projektu | `20260818-211108Z`: 108/108, 22 roundtripů, L69, 9 527 mincí a 101 zakázek |
| Postup a ekonomika fáze 94 / RC28 | Prošlo lokálně | `20260818-214736Z`: 108/108 cyklů devíti druhů, 22 roundtripů, L69, 9 527 mincí a 101 zakázek |
| Postup a ekonomika fáze 95 | Prošlo v hlavním projektu | `.godot/progression/20260819-072119Z`: 120/120 cyklů deseti druhů, 25 roundtripů, L80, 10 569 mincí a 108 zakázek |
| Postup a ekonomika fáze 96 | Prošlo v hlavním projektu | `.godot/progression/20260819-101241Z`: 120/120 cyklů deseti druhů, 25 roundtripů, L81, 10 051 mincí a 100 zakázek |
| Postup a ekonomika fáze 97 | Prošlo v hlavním projektu | `.godot/progression/20260819-121604Z`: 120/120 cyklů deseti druhů, 25 roundtripů, L81, 10 051 mincí a 100 zakázek |
| Postup a ekonomika fáze 98 | Prošlo v hlavním projektu | `.godot/progression/20260819-143648Z`: 120/120 cyklů deseti druhů, 25 roundtripů, L81, 10 051 mincí a 100 zakázek |
| Postup a ekonomika RC29 | Prošlo v release běhu | `.godot/progression/20260819-162504Z`: 120/120 cyklů deseti druhů, 25 roundtripů, L81, 10 051 mincí a 100 zakázek |
| Responzivní layout | Prošlo | Běh fáze 90 v integračním zrcadle `20260818-180217Z`: 7/7 displejů a výřezů, 4 obrazovky, 15 modalů, minimální bezpečný obsah 360×800 a žádný bílý nebo průhledný odkrytý okraj |
| Responzivní layout fáze 91 | Prošlo v hlavním projektu | `20260818-190359Z`: 7/7 případů |
| Responzivní layout fáze 93 | Prošlo v hlavním projektu | `20260818-211139Z`: 7/7 displejů a výřezů, čtyři obrazovky a všech 16 blokujících modalů |
| Responzivní layout fáze 94 / RC28 | Prošlo lokálně | `20260818-214740Z`: 7/7 displejů a safe-area případů |
| Responzivní layout fáze 95 | Prošel v hlavním projektu | `.godot/responsive/20260819-072118Z`: 7/7 displejů a safe-area případů |
| Responzivní layout fáze 96 | Prošel v hlavním projektu | `.godot/responsive/20260819-101238Z`: 7/7 displejů a safe-area případů |
| Responzivní layout fáze 97 | Prošel v hlavním projektu | `.godot/responsive/20260819-121643Z`: 7/7 displejů a safe-area případů; samostatné jednotkové/runtime kontroly potvrdily geometrii Profesorova a deníkového modalu při 432×960 i 360×800 |
| Responzivní layout fáze 98 | Prošel v hlavním projektu | `.godot/responsive/20260819-143722Z`: 7/7 displejů a safe-area případů |
| Responzivní layout RC29 | Prošel v release běhu | `.godot/responsive/20260819-162508Z`: 7/7 displejů a safe-area případů |
| Android payload | Prošlo | RC27 Gradle ARM64 debug APK, devět manifestových profilů a jejich textury, notification bridge/receivery, runtime závislosti, podpis v2 a SHA-256 ověřeny |
| Android payload fáze 91 | Prošlo v hlavním projektu | Přesné dvojice `.gdc` + `.gd.remap`, zákaz raw/osiřelých skriptů, volitelný `-ToolRoot`, citovaný `-ApkPath` s mezerami, export, podpis, entry scan, payload i notification payload jsou `PASSED`; `.godot/phase91-android-payload-smoke.apk`, 103,49 MiB, SHA-256 `387E98BCE9AA224D35EB95229D625483944EDFAD0141A467A8021A881D865AF6`. Jde o validační smoke, ne RC28; bez instalace do telefonu a změny dat. |
| Android payload RC28 | Prošlo lokálně | ARM64 debug APK `0.44.0-rc28` / code 45 / schema 23, podpis a exportní payload prošly v release auditu `20260818-214533Z`; 108 558 035 B, SHA-256 `074444E4586C10729F743B9902C68689809298E750398C3CF6BB13988BCF6399` |
| Android payload RC29 | Prošlo v release běhu | ARM64 debug APK `0.45.0-rc29` / code 46 / schema 28, podpis, payload a notification payload `PASSED`; 110 561 232 B, SHA-256 `E10D2F655310E98AD4ACB3F0490145592A222D4B2049225D364FF5FF7BB51EA7` |
| Android auditní nástroj fáze 94 | Prošel staticky, testově i finálním sanitizovaným fyzickým během | Instalace vyžaduje explicitní immutable `-ApkPath`; package probe persistuje jen vlastní `package-metadata.txt`, nikdy celý package dump/path, a `apk-identity.txt` s reportem vyžadují shodný očekávaný a nainstalovaný SHA-256. Pre/post save snapshoty obsahují jen sanitizované významové hodnoty, raw save ani celé telefonní výpisy se nepersistují a nedostupná pádová nebo APK identity evidence selže uzavřeně. Běh `20260819-045658Z` prošel a zakázané úplné výpisy nevytvořil; všech 18 ručních polí čeká. |
| Desktop výkon | Prošlo | RC27 běh `20260818-153424Z`: CPU p95 Pokoj 9,469, Sklad 5,284, Obchod 3,580, Měření 5,299 a Deník 5,429 ms; frame p95 16,687 ms, 443 draw calls a 78,37 MiB |
| Desktop výkon fáze 91 | Prošlo v hlavním projektu | `20260818-190416Z`: nejvyšší CPU p95 13,895 ms, frame p95 16,893 ms, max. 443 draw calls a 78,52 MiB |
| Desktop výkon fáze 93 | Prošlo v hlavním projektu | `20260818-211153Z`: nejvyšší CPU p95 11,807 ms, frame p95 16,690 ms, max. 443 draw calls a 79,99 MiB |
| Desktop výkon fáze 94 / RC28 | Prošlo lokálně | `20260818-214643Z`: nejvyšší CPU p95 8,074 ms, frame p95 16,703 ms, max. 443 draw calls a 79,99 MiB |
| Desktop výkon fáze 95 | Prošel v hlavním projektu | `.godot/performance/20260819-072116Z`: nejvyšší CPU p95 11,569 ms, frame p95 16,707 ms, max. 443 draw calls a 80,96 MiB |
| Desktop výkon fáze 96 | Prošel v hlavním projektu | `.godot/performance/20260819-101302Z`: nejvyšší CPU p95 9,966 ms, frame p95 16,695 ms, max. 443 draw calls a 82,16 MiB |
| Desktop výkon fáze 97 | Prošel v hlavním projektu | `.godot/performance/20260819-121700Z`: nejvyšší CPU p95 9,960 ms, frame p95 16,686 ms, max. 443 draw calls a 82,37 MiB |
| Desktop výkon fáze 98 | Prošel v hlavním projektu | `.godot/performance/20260819-143737Z`: nejvyšší CPU p95 10,691 ms, frame p95 16,692 ms, max. 443 draw calls a 82,88 MiB |
| Desktop výkon RC29 | Prošel v release běhu | `.godot/performance/20260819-162410Z`: nejvyšší CPU p95 10,075 ms, frame p95 16,687 ms, max. 443 draw calls a 83,19 MiB |
| Release candidate | Prošlo lokálně | Audit `20260818-153320Z`: `0.43.0-rc27`, code 44, schema 22, 928 regresí a 14/14 vizuálních gate |
| Fyzický Android audit | Automatická technická část prošla | Běh `20260818-154709Z`: 300 s, 54 platných vzorků, 100 % v popředí, schema 22 a 0 fatálních nálezů; záloha/import, upozornění, dotyk, teplota a baterie zůstávají ruční `PENDING` |
| Release candidate RC28 | Prošlo lokálně | Audit `20260818-214533Z`: `0.44.0-rc28`, code 45, schema 23, 1036/1036 regresí, 14/14 vizuálních gate a nový immutable APK |
| Fyzický Android audit RC28 | Automatická technická část prošla | `20260819-043532Z`: instalace `adb install -r`, schema 22 → 23 a semantic preservation 21 mincí / 260 XP / 10 slotů / 2 obsazených `PASSED`. `20260819-045658Z`: finální sanitizovaný skript, schema 23 → 23 a stabilní save `PASSED`, 300 s, 54 platných vzorků, 100 % v popředí, crash/ANR `PASSED`, fatal 0, expected/installed SHA-256 shodný a APK identity `PASSED`; notification evidence 2 a alarm evidence 13 jsou `AVAILABLE`, zakázané úplné výpisy chybějí. Všech 18 ručních polí je `PENDING`. |
| Release candidate RC29 | Prošlo lokálně | Audit `.godot/release-candidate/20260819-162250Z`: `0.45.0-rc29`, code 46, zdrojové i save schema 28, 1204/1204 regresí, 14/14 vizuálních gate a immutable APK |
| Fyzický Android audit RC29 | Automatická technická část prošla | `.godot/android-device-audit/20260819-162632Z`: 300 s, 54/54 platných vzorků, 100 % v popředí, fatal 0, APK identity `PASSED`, save 23 → 28 a zachování 21 mincí / 260 XP / 10 slotů / 2 obsazených `PASSED`; notifications 1 a alarms 13 pouze `AVAILABLE`. Všech 18 ručních polí je `PENDING`. |
| Android `gfxinfo`, baterie a thermal RC29 | Pouze evidence — ruční posouzení čeká | 42 snímků, 9 janky (21,43 %), p95 48 ms, p99 750 ms; baterie 55 %, 40,2 °C, thermal status 0, maximum 21 °C. Tyto hodnoty nejsou výkonovým, bateriovým ani tepelným průchodem. |
| Regresní sada — fáze 108 / RC35 | Prošla v hlavním projektu | `MVP_TESTS_PASSED=1289`; runner vyžaduje marker i exit code 0 |
| Úplná validace fáze 108 / RC35 | Prošla v hlavním projektu | `.godot/validation/20260820-215826Z`: 1289/1289, capture, visuals a full validation `PASSED`; schválené reference, crop, masky a tolerance beze změny |
| Dlouhé technické brány fáze 108 | Prošly v hlavním projektu | Endurance `20260820-220003Z`, progression `20260820-220029Z`, responsive `20260820-220046Z` a performance `20260820-220059Z` |
| Regresní sada — fáze 109 | Prošla v hlavním projektu | `MVP_TESTS_PASSED=1299`; jednorázové dozrání, návratový souhrn, odznak akcí a kompaktní geometrie |
| Úplná validace fáze 109 | Prošla v hlavním projektu | `.godot/validation/20260821-143411Z`: 1299/1299, capture, visuals a full validation `PASSED`; tři nové snímky jsou report-only a schválené vizuální kontrakty beze změny |
| Dlouhé technické brány fáze 109 | Prošly v hlavním projektu | Progression `20260821-143705Z` 132/132, endurance `20260821-143720Z` 48/48, responsive `20260821-143741Z` 8/8 a performance `20260821-143755Z` v limitech |
| Android artefakt RC35 po stabilizaci | Immutable kandidát zachován, alias synchronizován | RC35/code 52/schema 32: `106 191 776` B, SHA-256 `54F4CBE062693324E1C01AD7A3F371166E5ACAB3997D634A762FA324F5D876A2`; přepisovatelný alias je bajtově shodný |
| Krátké fyzické přijetí RC36 / fáze 112 | Prošlo na Xiaomi / Android 13 | Uživatel jedním průchodem potvrdil výběr a zálivku skleníkové plodiny, Back/tahy, `.htgbackup` export/import, novou hru/návrat, oprávnění i skutečné oznámení s cílem; `PHASE112_SHORT_PHYSICAL_GATE=PASSED` |
| Readback a finální validace po fázi 112 | Automatická technická část prošla | Android `.godot/android-device-audit/20260821-190953Z`: přesný RC36 hash, save 32 → 32, 66 mincí / 159 XP, 11/11 foreground, fatal 0, oprávnění granted a skutečný notification record; validation `.godot/validation/20260821-191441Z`: 1308/1308 a 14/14 aktivních obrazových gate |
| Reboot a přirozený návrat RC36 / fáze 112 | Prošly | `.godot/android-long-delay/20260821-213651Z`: `BOOT_COMPLETED` 21:35:57, obnovený alarm a skutečné oznámení; po 8 h 47 min. jediný návrat ukázal `greenhouse_ready` / `PŘIPRAVENO KE SKLIZNI` pro všechny čtyři záhony, fatal 0 |
| Fáze 113 / RC37 — skleníková ředkvička | Lokální release prošel, telefon odložen | Schema 33, 4 plodiny, 1 317/1 317 kontrol; release `.godot/release-candidate/20260821-200404Z` PASS, APK 106 195 376 B, SHA-256 `F985BA22C278B74C1AEBE8D7A878BA21B6EE11053234BA062A9A098A57C3898B`; RC37 zatím není instalováno |
| Fáze 114 — publikační rozsah | Zdrojové nástroje prošly | 1 321/1 321; výchozí Quick `.godot/automation/20260821-202456Z` vrací `OUT_OF_SCOPE_BY_USER`, opt-in Quick `.godot/automation/20260821-202538Z` vrací `PENDING_RELEASE_KEYSTORE_AAB_STORE_REVIEW`; runtime, schema a RC37 beze změny |
| Fáze 115 / RC38 — skleníkový lilek | Lokální release prošel, telefon odložen | Schema 34, 5 plodin, 1 330/1 330 kontrol; release `.godot/release-candidate/20260821-210729Z` PASS, APK 106 197 360 B, SHA-256 `939E3E931DC32CD527A0207106DA2C1EDE3A9BD9B63F1F9718D40CB322FB3E0D`; RC38 zatím není instalováno |
| Fáze 116 / RC39 — skleníkové zakázky | Lokální release prošel, telefon odložen | Schema 35, jedna trvalá kanonická zakázka, 1 342/1 342 kontrol; release `.godot/release-candidate/20260821-214027Z` PASS, APK 106 203 248 B, SHA-256 `3F110A4E187C9AFE0034D149E6E47B7B2C7B643CE2DDDA3F5ACD7701F83F3C78`; RC39 zatím není instalováno |
| Fáze 117 / RC40 — prémiové vícezáhonové zakázky | Lokální release prošel, telefon odložen | Schema 36, `multi_bed` vyžaduje dva různé záhony, 1 351/1 351 kontrol; release `.godot/release-candidate/20260822-040931Z` PASS, APK 106 206 088 B, SHA-256 `99927E0D24B4C7DDDBF3B13B191C1ACCB8EB562C6F553B25E685113A163F0D97`; RC40 není instalováno |
| Fáze 118 / RC41 — reputace skleníku | Lokální release prošel, telefon nevyžádán | Schema 37, milníky 3/8/15 s jednorázovými odměnami a finální kosmetickou cedulí, 1 360/1 360 kontrol; release `.godot/release-candidate/20260822-045830Z` PASS, APK 106 209 964 B, SHA-256 `A8E14970A5A6F09B67493B34DE701D2E9ACC8496617D2453B93DD7690159D6AE`; RC41 není instalováno |
| Fáze 119 / RC43 — globální swipe | Lokální release prošel, telefon nevyžádán | Čtyři hlavní obrazovky, 18px axis lock, 90px swipe, scroll arbitráž a směrová odezva, schema 37 beze změny, 1 370/1 370 kontrol; release `.godot/release-candidate/20260822-054242Z` PASS, APK 106 213 160 B, SHA-256 `8D890542F3C49274225E5847E64C503E7E529DEAF5C8252717EC1AAC6E4990F8`; RC42 i RC43 nejsou instalované |
| Fáze 120 / RC45 — živý perspektivní skleník | Lokální release prošel, připojení telefonu čeká | Originální prostředí, menší zadní a větší přední vyvýšené záhony, schema 37 beze změny, 1 374/1 374 kontrol; release `.godot/release-candidate/20260822-102540Z` PASS, APK 108 222 968 B, SHA-256 `F58C6A79965B9DB77ACEF7338050CA46D444E0882DB56C531F6133D072F425A0`; RC44 zachováno, device gate `PENDING_DEVICE_CONNECTION` |
| Fáze 121 / RC46 — vodorovná ochrana transakcí | Částečný fyzický PASS, vertikální nález předán fázi 122 | Vodorovný tah přes nákupní tlačítko už nekoupí osivo; RC46 108 222 272 B, SHA-256 `1266E897FD8D0CDB23BD1F2FC27F1B19894BAD92989060A4EAB2C7412ED7F1C5`. Svislý scroll ale fyzicky odhalil nechtěný nákup lampy; save byl přesně obnoven a RC46 zůstalo immutable. |
| Fáze 122 / RC47 — svislá ochrana transakcí | Technické a cílené fyzické brány prošly | 1 377/1 377, 14/14 aktivních obrazových bran, release `.godot/release-candidate/20260822-120356Z`, automation `.godot/automation/20260822-120356Z`, device audit `.godot/android-device-audit/20260822-120721Z`; APK 108 222 588 B, SHA-256 `3BC47AB155065EDE0E0AECB246026E62A324B4B25CDF5BAF76FD117AA5FCDC7F`; svislý stav okamžitě i po 20 s beze změny, vodorovný tah přes Pažitku také beze změny. |
| Fáze 123 / RC48 — sbírkový pokoj | Lokální release prošel, historický kandidát zachován | Schema 38, osm pokojovek, šest pevných dekorací a vitrína úspěchů; 1 378/1 378, release `.godot/release-candidate/20260822-133618Z`, APK 110 185 562 B, SHA-256 `D28E3D33AC95B14F8B79067C3F90C639833A25A9F133EF3BDBB41E36BB936F58`. |
| Fáze 124 / RC49 — živý pokoj a budoucí mazlíček | Technická mobilní brána prošla, lidské hodnocení čeká | Schema 39, kočičí kout, sklenice s bylinkami a živé okno; 1 384/1 384, release `.godot/release-candidate/20260822-144818Z`, device audit `.godot/android-device-audit/20260822-150135Z`; APK 110 188 738 B, SHA-256 `86A1F064581BC8DD3FE8026BD4A2B7ACAAB8DED0C3E00D47FD80B9EC427CDE79`, save 37 → 39 zachován. |
| Fáze 125 / RC50 — čistý stojan a hráčské nastavení | Technická mobilní brána prošla, lidské hodnocení čeká | Schema 39; sklizené a zpracovávané rostliny mizí ze stojanu, samostatná Péče a PNG Nastavení, rezervovaný dok pro budoucí obsah; 1 390/1 390, validation `.godot/validation/20260822-155002Z`, release `.godot/release-candidate/20260822-155610Z`, device audit `.godot/android-device-audit/20260822-162951Z`; APK 110 260 465 B, SHA-256 `C7227D3FC8ACE61CEB214EF1F83B4BAEE3BE5402F564D013E8031D49CEAFE14D`, save 39 → 39 zachován. |
| Fáze 126 / RC51 — sjednocená vizuální kamera | Lokální i fyzická technická brána prošly; lidská brána čeká | Schema 39; společný framing stojanu, pokoje a skleníku, blízký pokoj 2 × 4, zdrojové kotvy, 360 × 800 gate; 1 394/1 394, validation `.godot/validation/20260822-171510Z`, release `.godot/release-candidate/20260822-171510Z`, responsive 9/9; APK 111 812 793 B, SHA-256 `6B48C70E4A80B369E83EF50121760A1F598088D933F1CE499EFD73B17211410F`. Instalace a technický audit `.godot/android-device-audit/20260822-172854Z` prošly se zachovaným savem. |
| Fáze 127 / RC53 — finální vizuální systém | Lokální i fyzická technická brána prošly; lidská brána čeká | Schema 39; společné tokeny, šest rodin, tři scénové profily, 32 explicitních profilů a 241/241 klasifikovaných PNG. Validation `.godot/validation/20260822-193736Z` má 1 400/1 400, release `.godot/release-candidate/20260822-193734Z` a responsive 9/9 prošly. APK 119 704 601 B, SHA-256 `1224BFB7BF54CBFA866E99914A9D19ADADB712FDDB1C1DE9477608B964104131`; audit `.godot/android-device-audit/20260822-194103Z` potvrdil přesnou instalaci a save 39 → 39. RC52 zůstává immutable mezisestavení. |
| Fáze 138 / RC54 — integrovaný pokoj na Androidu | Lokální i fyzická technická brána prošly; lidský vzhled čeká | Schema 40; schválená sada osmi integrovaných RGBA ve funkční mřížce 3 × 4, 265/265 profilovaných PNG a 0 neprofilovaných. Validation `.godot/validation/20260823-115514Z` má 1 440/1 440, release `.godot/release-candidate/20260823-115502Z` a responsive 9/9 prošly. APK 150 226 188 B, SHA-256 `31373DA90973A2F131A9A5177BA8D9B958F8767B13BED5493015EC1FE19A23E5`; audit `.godot/android-device-audit/20260823-115900Z` potvrdil přesnou instalaci, save 39 → 40, 11/11 foreground vzorků a 0 crash/ANR nálezů. |
| Fáze 139 — sjednocená výtvarná sada Pokoje | Lokální technická brána prošla; mobilní vzhled čeká | Source-only nad immutable RC54. Schválený celý pokoj, 12 funkčních slotů, osm hladkých 591 × 887 RGBA a společná 84 × 126 geometrie květináče/podmisky. Validation `.godot/validation/20260823-132935Z` má 1 445/1 445, responsive `.godot/responsive/20260823-133225Z` 9/9, visual contract 278 profilovaných / 0 neprofilovaných PNG a závěrečný Quick `.godot/automation/20260823-133606Z` prošly. APK, telefon i save beze změny. |
| Fáze 140 — společná sada dekorací Pokoje | Implementovaná, technická a lidská brána stále čeká | Source-only nad immutable RC54. Deset nových pravostranných dekorací, druhá nástěnná police, šest držáků úspěchů, samostatná konvička a prázdný pelíšek bez misek; samostatný Godot render je report-only. |
| Fáze 141 — finální koupitelný stojan | Lokální technická i Godot vizuální brána prošly; mobil čeká | Source-only nad immutable RC54. Schema 41, 12 koupitelných pokojovek, čtyři police po třech, jednotná keramika a 12 hladkých 591 × 887 RGBA. Validation `.godot/validation/20260823-173713Z` má 1 456/1 456, responsive `.godot/responsive/20260823-174052Z` 9/9, visual contract `.godot/visual-contract/20260823-174114Z` 313 profilovaných / 0 neprofilovaných PNG a Quick po schválení `.godot/automation/20260823-181336Z` prošel. Uživatel schválil skutečný Godot render; APK, telefon i obrazovka Rostliny beze změny. |
| Fáze 142 — věrná referenční sada stojanu | Implementovaná a technicky prošla; skutečný Godot render čeká na uživatele | Source-only nad immutable RC54. RGB všech 12 aktivních rostlin pochází přímo z odsouhlasené celopokojové předlohy; samostatná maska dodává pouze průhlednost. Nový prázdný podklad a přesné kotvy `y = 743/955/1180/1395` zachovávají 4 × 3 nákupní a přesouvatelné sloty, schema 41 i obrazovku Rostliny. Validation `.godot/validation/20260823-192225Z` má 1 460/1 460, responsive 9/9, visual contract 329/329 profilovaných PNG a Quick `.godot/automation/20260823-192642Z` prošel. Lidské přijetí Godot renderu, APK a mobilní brána jsou oddělené. |
| Fáze 143 — schválená jednotná sada stojanu | Zdroj, technická brána i skutečný Godot render schváleny; mobil čeká | RGB 12 aktivních sestav pochází přímo ze schváleného společného náhledu; maska dodává jen alfa kanál. Jediné izotropní měřítko, 4 × 3 společných os a beze změny schema 41, nákupu, přesunu i obrazovky Rostliny. Validation `.godot/validation/20260823-201449Z` má 1 464/1 464, responsive 9/9, visual contract 343/343 profilovaných PNG a Quick `.godot/automation/20260823-201840Z` prošel. Skutečný Godot capture je `APPROVED_BY_USER`; mobilní přijetí zůstává oddělené. |
| Fáze 144 / RC55 — schválený stojan v Android kandidátu | Lokální technická brána prošla; instalace a mobilní vzhled čekají | `0.66.0-rc55` / code 72 / schema 41. Release `.godot/release-candidate/20260824-045554Z`, validation `.godot/validation/20260824-045602Z` 1 467/1 467, performance, endurance 48/48, progression 132/132, responsive 9/9, podpis i payload prošly. APK 175 560 935 B, SHA-256 `A6F7DF58FC58DCBCFBEDF568B7B43FCF47766AFFE8BF289BE330B028B9D25ECD`; RC54 zůstalo nezměněné. Zařízení `NOT_REQUESTED`, publikování `OUT_OF_SCOPE_BY_USER`. |
| Fáze 145 — vrstvené detaily Pokoje | Lokální technická brána prošla; Godot vzhled čeká na uživatele, mobil je odložen | Source-only nad immutable RC55. Pelíšek a vnořené květináče dostaly kontaktní stíny a povrchové okluze; kočičí kout přidává samostatnou přední RGBA vrstvu dvou stejně velkých keramických misek. Schema 41, ekonomika, Rostliny a skleník beze změny. Validation `.godot/validation/20260824-072859Z` 1 472/1 472, responsive `.godot/responsive/20260824-073137Z` 9/9, visual contract `.godot/visual-contract/20260824-073157Z` 345 profilovaných / 0 neprofilovaných PNG. APK nevzniklo. |
| Fáze 146 — schválený celoplošný master Pokoje | Lokální technická brána prošla; Godot vzhled čeká na uživatele, mobil je odložen | Source-only nad immutable RC55. Schválený prázdný master, 12 funkčních Phase143 rostlin a osm pevných dekorací z bezstínové RGBA vrstvy; zdrojové PNG zůstávají nedotčené. Následná korekce posunula vnořené květináče o 8 zdrojových pixelů níž a znovu nad jejich spodkem vykreslila přední hranu police. Validation `.godot/validation/20260824-173415Z` 1 477/1 477, responsive `.godot/responsive/20260824-173637Z` 9/9, visual contract `.godot/visual-contract/20260824-165444Z` 353 profilovaných / 0 neprofilovaných PNG. APK nevzniklo. |
| Fáze 147 — schválený malovaný cartoon master | Style-lock a lokální technická brána prošly; první rodinu dokončila fáze 148 | Source-only nad immutable RC55. Uživatelem schválený sytý malovaný master má hashově uzamčenou linku, barvu, světlo, stín, materiály a produkční pořadí. RGB atlasy s napevno vykreslenou šachovnicí zůstávají zakázané v runtime. Validation `.godot/validation/20260824-182814Z` 1 478/1 478, capture i visuals `PASSED`; Quick `.godot/automation/20260824-183156Z` prošel. |
| Fáze 148 — malovaný cartoon Pokoj | Technická brána i interní Godot render QA prošly; uživatelský a mobilní vzhled čekají | První kompletní obrazovková rodina nového masteru: prostředí 853 × 1844, 12 funkčních rostlin a 9 dekorací jako 21 samostatných RGBA vrstev. Alpha-only v3 zachovává RGB bajtově, checker i halo risk jsou nula; podmisky mají jednotné optické měřítko a bez natahování. Validation `.godot/validation/20260824-194329Z` 1 485/1 485, capture, visuals i úplná brána `PASSED`; Quick `.godot/automation/20260824-195259Z` i nezávislý vizuální audit prošly. Uživatel `PENDING_USER_APPROVAL`, mobil `DEFERRED_PHONE_UNAVAILABLE`, APK nevzniklo. |
| Fáze 149 — přesný hráčský pokoj | Lokální technická i uživatelská vizuální brána prošly; mobil je odložen | Přesný target crop 853 × 1548, kanonický master shodný se zdrojem, 20 funkčních slotů a 21 target-derived vrstev. Validation `.godot/validation/20260824-214738Z` má 1 490/1 490, responsive 9/9 a gated diff MAE 6,805 / RMSE 12,005. Uživatel 25. 8. 2026 schválil skutečný Godot render a navazující Quick `.godot/automation/20260825-042058Z` prošel. Mobil `DEFERRED_PHONE_UNAVAILABLE`, APK nevzniklo a RC55 zůstává immutable. |
| Fáze 150 — schválený malovaný skleník | Lokální technická, interní Godot cohesion i uživatelská vizuální brána prošly; mobil čeká | Schválený target 864 × 1544, dvě společné vyvýšené krabice, čtyři funkční záhony a šest alfa-only runtime crop vrstev se zachovanými Phase127 RGB/SHA. Půdní ostrůvky byly odstraněny, sazenic je přesně šest a stavové ikony patří rámu záhonu. Finální validation `.godot/validation/20260825-071114Z` má 1 496/1 496, capture i visuals `PASSED`; responsive `.godot/responsive/20260825-061207Z` prošel 9/9, Quick `.godot/automation/20260825-071439Z` prošel a report-only konceptuální diff je MAE 40,199 / RMSE 63,783. Uživatel 25. 8. 2026 skutečný render schválil (`APPROVED_BY_USER`), mobil `DEFERRED_PHONE_UNAVAILABLE`, APK nevzniklo a RC55 zůstává immutable. |
| Fáze 154 — schválené malované Měření | Lokální technická, interní Godot cohesion i uživatelská vizuální brána prošly; mobil čeká | Schválený koncept je report-only. Živý runtime používá byte-exact malovanou laboratoř, deset dynamických hodnot, hladké ikony, 72hodinový graf, nápovědu a svislý scroll. Finální validation `.godot/validation/20260825-132647Z` má 1 510/1 510 a 20/20 tvrdých bran; nový append-only runtime baseline má přesnou shodu 0/0/0. Responsive `.godot/responsive/20260825-124928Z` prošel 11/11 a Quick `.godot/automation/20260825-132926Z` je PASS. Uživatel 25. 8. 2026 schválil skutečný render. Telefon je nedostupný, APK nevzniklo a RC55 zůstává immutable. |
| Fáze 155 — schválený malovaný Herbář | Lokální technická, interní cohesion i uživatelská vizuální brána prošly; mobil čeká | Schválený koncept zůstává report-only. Čistá malovaná kniha neobsahuje zapečené hodnoty ani druhy; 11 portrétů, popisy, vlastnosti, mistrovství, odměny, předání zahrady a mobilní scroll zůstávají dynamické. Finální validation `.godot/validation/20260825-155831Z` má 1515/1515 a 21/21 tvrdých bran; nový append-only runtime gate SHA `8af651…4530` dosáhl přesné shody 0/0/0. Responsive `.godot/responsive/20260825-154636Z` prošel 12/12 a Quick `.godot/automation/20260825-160228Z` je PASS. Telefon je nedostupný, APK nevzniklo a RC55 zůstává immutable. |

Aktuální autoritativní zdrojový stav je lokálně dokončená fáze 154 nad posledním immutable lokálním releasem RC55 `0.66.0-rc55` / code 72 / save schema 41. Nainstalovaný stav telefonu zůstává fáze 138 / RC54 se schema 40; RC55 ani Phase146–154 se neinstalovaly. Historické RC47–RC55 i jejich důkazy zůstávají platné a immutable. Phase154 má `TECHNICAL_VALIDATION=PASSED`, `GODOT_RENDER_ACCEPTANCE=PASSED_INTERNAL_COHESION_AUDIT`, `USER_VISUAL_ACCEPTANCE=APPROVED_BY_USER`, `VISUAL_BASELINE_TRANSITION=PASSED_APPEND_ONLY_RUNTIME_GATE`, mobil `DEFERRED_PHONE_UNAVAILABLE`, APK `NOT_CREATED` a publikování `OUT_OF_SCOPE`.

Fáze 16–72 uzavřely obsahovou, save a základní mobilní technickou kostru včetně čtvrtého druhu, předpovědi a dlouhodobých technických bran. Fáze 73–75 převedly růst na návratové reálné cykly a přidaly bezpečný životní cyklus po dozrání. Fáze 76–79 zavedly rarity, obecný inventář semen, férové Botanické balíčky a čtyři explicitní profilové vlastnosti bez skrytého bonusu rarity. Fáze 80 odstranila pevné čtyřdruhové produkční routování: manifest nyní řídí profily, textury, runtime obchod, exportní payload i počet postupových cyklů. Fáze 81–86 rozšířily katalog na devět druhů. RC27 všechny tyto fáze balí do schema 22 a jeho automatická fyzická technická brána prošla na odemčeném telefonu v popředí. Publikační brána dál čeká na release keystore, AAB, store review a ruční dokončení zálohy, oznámení a hardwarového UX.

Fáze 94 zachovává tento RC27 baseline jako historický a přidává nový interní RC28 se zdrojovým schema 23. Jeho release, validační, výkonová, endurance, postupová, responzivní, APK payload i automatická fyzická technická brána prošly. Automatická technická část je proto hotová na 100 %, ale tento stav nezahrnuje ruční mobilní kontrolu ani Google Play publikaci.

Fáze 95 včetně korekce rarity je hotová v hlavním projektu na 100 %. Autoritativní actual brány jsou zelené: 1078/1078 kontrol, validation `20260819-071937Z` s 14/14 gate, progression `20260819-072119Z` 120/120 s 25 roundtripy, endurance `20260819-072119Z` 48/48, responsive `20260819-072118Z` 7/7 a performance `20260819-072116Z` v limitech. Obsahuje Rare / `VZÁCNÁ` / ★★ šalvěj, žádný současný Legendary profil, desátou explicitní vlastnost, druhou Profesorovu kapitolu a zdrojové schema 24. Fáze 95 sama nevytvořila APK ani telefonní audit; tehdejším posledním artefaktem byl historický immutable RC28 `0.44.0-rc28` / code 45 / schema 23.

Fáze 96 je hotová v hlavním projektu na 100 %. Autoritativní actual brány jsou zelené: 1108/1108 kontrol, validation `20260819-101102Z` s capture/visuals/full `PASSED` a 14/14 gate, progression `20260819-101241Z` 120/120 s 25 roundtripy, endurance `20260819-101241Z` 48/48, responsive `20260819-101238Z` 7/7 a performance `20260819-101302Z` v limitech. Obsahuje tři dvoudruhové směsi, atomický dvoubalíčkový fulfillment a zdrojové schema 25. Fáze 96 sama nevytvořila APK ani telefonní audit; tehdejším posledním artefaktem byl historický immutable RC28 `0.44.0-rc28` / code 45 / schema 23.

Fáze 97 je hotová v hlavním projektu na 100 %. Autoritativní actual brány jsou zelené: 1140/1140 kontrol, validation `20260819-121431Z` s capture/visuals/full `PASSED` a 14/14 gate, progression `20260819-121604Z` 120/120 s 25 roundtripy, endurance `20260819-121621Z` 48/48, responsive `20260819-121643Z` 7/7 plus explicitní geometrie 432×960 a 360×800 a performance `20260819-121700Z` v limitech. Obsahuje třetí Profesorovu kapitolu, titul `MISTR HERBÁŘE`, devátý odznak Pěstitelského deníku a zdrojové schema 26. Fáze 97 sama nevytvořila APK ani telefonní audit; tehdejším posledním artefaktem byl historický immutable RC28 `0.44.0-rc28` / code 45 / schema 23.

Fáze 98 je hotová v hlavním projektu na 100 %. Autoritativní actual brány jsou zelené: 1176/1176 kontrol, validation `20260819-143453Z` s capture/visuals/full `PASSED` a 14/14 gate, progression `20260819-143648Z` 120/120 s 25 roundtripy, endurance `20260819-143700Z` 48/48, responsive `20260819-143722Z` 7/7 a performance `20260819-143737Z` v limitech. Obsahuje samostatný opakovatelný Profesorův týdenní protokol, `completed_count`, desátý odznak `VÝZKUMNÝ PARTNER` a zdrojové schema 27 se zpřísněnou validací schema/UTC dnů. Fáze 98 sama nevytvořila APK ani telefonní audit; tehdejším posledním artefaktem byl historický immutable RC28 `0.44.0-rc28` / code 45 / schema 23.

Fáze 82 nemění uložená data, růst, ekonomiku ani pravidla vlastností; zpřesňuje pouze jejich okamžitou prezentaci a odezvu při přímé akci hráče. Odznak `VLASTNOST AKTIVNÍ` a halo jsou active-only a mátová odezva nevznikne při selhání, plném zdraví, nevhodné vláze, jiném traitu ani časovém kroku. `comic-behavior-active-badge.png` a `comic-feedback-plant-behavior.png` zůstávají report-only. Oficiální běh `20260818-104639Z` prošel 838 kontrolami a 14/14 aktivními gate; navazující audit `20260818-104750Z` prošel 60/60 pěstitelskými cykly a 13 save/load roundtripy.

Fáze 83 zachovává baseline fáze 82 jako historický důkaz a nepřepisuje jej. Nové uzavření doložil skutečný import a regresní běh `MVP_TESTS_PASSED=861`, úplná validační brána `.godot/validation/20260818-114416Z` bez oslabení pixelových tolerancí a dynamický postup `.godot/progression/20260818-114524Z` se 72/72 cykly a 15 diskovými roundtripy.

Fáze 84 zachovává oba historické baseline a přidává sedmý plně dynamický druh bez změny save schema. Hlavní projekt doložil `MVP_TESTS_PASSED=882`, úplnou validační bránu `.godot/validation/20260818-123342Z` se 14/14 aktivními gate a dynamický postup `.godot/progression/20260818-123451Z` s 84/84 cykly, 12 sklizněmi každého druhu, 74 zakázkami a 17 diskovými roundtripy. Sedm nových snímků majoránky je výhradně report-only; schválené reference, manifest a tolerance se nezměnily. Immutable RC26 tuto lokální fázi neobsahuje.

Fáze 85 zachovává všechny historické baseline a přidává osmý plně dynamický druh bez změny save schema. Hlavní projekt doložil `MVP_TESTS_PASSED=906`, validační bránu `.godot/validation/20260818-135642Z` se 14/14 aktivními gate a postup `.godot/progression/20260818-135824Z` s 96/96 cykly, 12 sklizněmi každého druhu, 89 zakázkami a 20 diskovými roundtripy. Sedm nových snímků petržele je append-only report-only; schválené reference, manifest a tolerance se nezměnily. Immutable RC26 tuto lokální fázi neobsahuje a fyzická Android brána nebyla touto desktopovou validací nahrazena.

Fáze 86 zachovává všechny historické baseline a přidává devátý plně dynamický druh bez změny save schema. Hlavní projekt doložil `MVP_TESTS_PASSED=928`, validační bránu `.godot/validation/20260818-144151Z` se 14/14 aktivními gate a postup `.godot/progression/20260818-144312Z` se 108/108 cykly, 12 sklizněmi každého druhu, 101 zakázkami a 22 diskovými roundtripy. Sedm nových snímků meduňky je append-only report-only; schválené reference, manifest a tolerance se nezměnily. Immutable RC26 tuto lokální fázi neobsahuje a fyzická Android brána nebyla touto desktopovou validací nahrazena.

Fáze 89 uzavírá výhradně odložené překrytí stavového odznaku a názvu v Pokoji. Uživatel schválil kandidáta se stavem nad pravým okrajem štítku. Regresní geometrie při 432×960 ověřuje všech deset pozic, úplné oddělení od textu, hranice vlastního slotu a vzájemné nekolidování. Dotčené případy `feedback-unlock` a `screen-transition` používají nové verzované reference; původní soubory Phase 7 zůstávají immutable. Crop, masky, pixelová tolerance 12 a prahy MAE 4 / RMSE 12 / changed ratio 0,06 se nezměnily. Save schema 22, hra i RC27 zůstávají beze změny. Finální běh v hlavním projektu `MVP_TESTS_PASSED=935` a `.godot/validation/20260818-174414Z` prošel markery `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED`, `HOW_TO_GROW_VALIDATION=PASSED` a 14/14 aktivními gate. Responzivní audit `.godot/responsive/20260818-173952Z` prošel 7/7 a endurance `.godot/endurance/20260818-174016Z` dokončilo 48/48 cyklů, 7 diskových roundtripů, nulový růst uzlů/orphanů/zdrojů a 0,02 MiB růstu statické paměti.

Fáze 90 je úzce omezený technický úklid dokončený v hlavním projektu. Vyřazuje jen nepřipojený `time_control_presenter.gd` s `.uid`, soukromé helpery `_load_plant_profile`, `_load_profile`, `_style_box`, `_build_shop_placeholder_tile`, `_get_care_attention_slots` a mrtvé registrace motivu pro `OptionButton`. Veřejné `get_journey_progress`, legacy save pole `speed_multiplier` / `paused`, fast-time migrační ochrany a diagnostika zůstávají součástí kompatibilního kontraktu. Hlavní projekt prošel 937/937 regresemi a validací `.godot/validation/20260818-180716Z` se 14/14 aktivními gate; zrcadlo navíc prošlo endurance `.godot/endurance/20260818-180200Z` se 48 cykly, 7 roundtripy, nulovým růstem uzlů/orphanů/zdrojů a +0,02 MiB statické paměti a responsive `.godot/responsive/20260818-180217Z` se 7/7 případy. Schema 22, ekonomika a RC27 se nemění; generované cache a existující APK nebyly ručně přepisované a Android se znovu nesestavoval.

Fáze 91 je v hlavním projektu **hotová · 100 %**. Uzavírá no-op XP větrání; bezpečně normalizuje hostile typy uložené ekonomiky, kolekcí, grafu, hlasitostí, světového času a timestampu; drží posledních 72 konečných měření a serializační timestamp high-water. Neúspěšně opravená platná záloha se načte jako `backup_read_only`, zablokuje zápis a zachová primary i backup; bezpečná rotace nemaže poslední čitelnou kopii před ověřením náhrady. Profilový loader odmítne chybějící, nečíselnou, nekonečnou, obrácenou a fyzicky rozpornou ekonomiku nebo péči. Všech devět současných profilů dál prochází beze změny pravidel.

Exportní audit fáze 91 odvozuje přesnou sadu současných skriptů a vyžaduje pro každý `.gdc` i `.gd.remap`; raw `.gd`, chybějící partner nebo osiřelý retired payload je chyba. Parametr `-ApkPath` je předaný jako citovaný exportní argument, takže může obsahovat mezery, a volitelný `-ToolRoot` dovoluje použít již připravený přenosný JDK/Android SDK mimo projektovou `.tooling`. Actual payload smoke prošel `GODOT_GRADLE_EXPORT=PASSED`, `APK_SIGNATURE_CHECK=PASSED`, `APK_ENTRY_SCAN=PASSED`, `APK_PAYLOAD_CHECK=PASSED` a `ANDROID_NOTIFICATION_PAYLOAD_CHECK=PASSED`. Testovací `.godot/phase91-android-payload-smoke.apk` má 103,49 MiB a SHA-256 `387E98BCE9AA224D35EB95229D625483944EDFAD0141A467A8021A881D865AF6`. `run_release_candidate.ps1` správně odmítl existující immutable RC27 ještě před exportem a jeho SHA-256 zůstal `6B632B9687CFB47ABACB403AC6A9717A2DE93970DC7424F8F7C285A748456002`. V rámci fáze 91 RC28 nebyl založen, testovací APK se neinstaloval do telefonu a hráčská data se nezměnila; RC27 tehdy zůstal jediným vydaným APK.

Hlavní projekt prošel 951/951, validací `.godot/validation/20260818-190146Z` s capture, visuals i úplnou validací `PASSED` a 14/14 gate, progression `.godot/progression/20260818-190326Z` se 108/108 cykly, 22 roundtripy, L69, 9 527 mincemi a 101 zakázkami, endurance `.godot/endurance/20260818-190340Z` se 48/48, 7 roundtripy, nulovým růstem uzlů/orphanů/zdrojů a +0,02 MiB, responsive `.godot/responsive/20260818-190359Z` se 7/7 a performance `.godot/performance/20260818-190416Z` s nejvyšším CPU p95 13,895 ms, frame p95 16,893 ms, 443 draw calls a 78,52 MiB. Ruční telefonní a publikační brány zůstávají otevřené.

Fáze 92 je **hotová v hlavním projektu · 100 %**. Třístránkové `PŘEDÁNÍ ZAHRADY` se u nové hry dokončí pouze přijetím nebo výslovným přeskočením; do té doby zůstává `intro_completed=false` a pozadí ani systémové Zpět nemohou stav změnit. Herbář nabízí mutation-free replay a pravdivý souhrn `x/y · procento`, který se na úzkém mobilním panelu vejde do dvou řádků. Potvrzení používá standardní save cestu, respektuje `backup_read_only` a blokaci autosave. Schema 22, ekonomika, `0.43.0-rc27`, code 44 i immutable APK zůstávají beze změny; tato desktopová fáze nepotřebovala telefon ani nový Android artefakt.

Hlavní projekt prošel 985/985 kontrolami a validací `.godot/validation/20260818-195847Z` s capture, visuals i úplnou validací `PASSED` a 14/14 aktivními gate. Progression `.godot/progression/20260818-200017Z` dokončil 108/108 cyklů, 22 roundtripů, L69, 9 527 mincí a 101 zakázek; endurance `.godot/endurance/20260818-200029Z` prošlo 48/48, 7 roundtripy, nulovým růstem uzlů/orphanů/zdrojů a +0,02 MiB; responsive `.godot/responsive/20260818-200049Z` prošel 7/7; performance `.godot/performance/20260818-200102Z` naměřil nejvyšší CPU p95 8,872 ms, frame p95 16,692 ms, 443 draw calls a 78,63 MiB. Schválené reference, manifest i tolerance zůstaly beze změny. Historická evidence fáze 91 a RC27 níže zůstává autoritativní.

Fáze 93 je **hotová v hlavním projektu · 100 %**. Po dokončení vedené cesty odemkne `lost_herbarium_pages` a sleduje přesně pět cílů: kvalifikovaný offline návrat po alespoň 1 800 s, dvě různé nevýukové sklizně s kvalitou alespoň 75 %, jednu druhovou zakázku, pět skutečně objevených druhů a denní výzvy ve dvou různých přísně rostoucích UTC dnech. Schema nejvýše 22 začne akční čítače na nule, objevování odvodí ze sbírky a kapitolu odemkne pouze dokončené cestě. Fullscreen blokující modal má pět rolovatelných karet, kontextové CTA a stav `!` pro nepřečtenou nebo připravenou kapitolu; stávající čtyři záložky zůstávají beze změny. Návratový souhrn umí přidat jednu příběhovou řádku.

Vyzvednutí je atomické a idempotentní: připisuje právě 75 mincí, 60 XP, jeden zapečetěný balíček a jednu Profesorovu pečeť. Balíček garantuje způsobilý dosud neobjevený ani dříve nepřidělený druh, pokud takový existuje; jinak používá běžný deterministický výsledek. Plná fronta nebo nedostupný pack pool nemění žádnou část odměny ani kapitoly. Hlavní projekt prošel 1036/1036 kontrolami, `.godot/validation/20260818-210938Z` se všemi třemi markery `PASSED` a 14/14 aktivními gate, `.godot/progression/20260818-211108Z` se 108/108 cykly a 22 roundtripy, `.godot/endurance/20260818-211120Z` se 48/48, 7 roundtripy, nulovým růstem uzlů/orphanů/zdrojů a +0,02 MiB, `.godot/responsive/20260818-211139Z` se 7/7 a 16 modaly a `.godot/performance/20260818-211153Z` s CPU p95 11,807 ms, frame p95 16,690 ms, 443 draw calls a 79,99 MiB. Oba nové příběhové snímky jsou report-only; schválené reference, manifest a tolerance se nezměnily.

Při auditu Windows dialogů byl nativní Godot 4.7 pád reprodukován kombinací relativního staged `--path` a relativního `--log-file` z jiného pracovního adresáře: engine nejprve hlásil neplatné `user://C:` a poté `signal 11`. Jde o access violation procesu Godot; jedna chybná invokace může vytvořit jeden dialog „Chyba aplikace“. Workflow nyní zakazuje externí či částečný `--check-only --script`, stejný padající příkaz se nesmí opakovat paralelně a staging se ověřuje pouze v úplném mirroru standardním project-scoped runnerem. Native crash je selhání brány i bez GDScript parse hlášky.

Fáze 94 má **automatickou technickou část hotovou · 100 %**. `0.44.0-rc28` / code 45 balí beze změny herních pravidel zdrojové schema 23. Release audit `.godot/release-candidate/20260818-214533Z` zahrnuje 1036/1036 kontrol, validaci `.godot/validation/20260818-214533Z` se všemi třemi markery `PASSED` a 14/14 gate, performance `.godot/performance/20260818-214643Z` s CPU p95 8,074 ms, frame p95 16,703 ms, 443 draw calls a 79,99 MiB, endurance `.godot/endurance/20260818-214726Z` se 48/48 cykly, 7 roundtripy, nulovým růstem uzlů/orphanů/zdrojů a +0,02 MiB, progression `.godot/progression/20260818-214736Z` se 108/108 cykly devíti druhů, 22 roundtripy, L69, 9 527 mincemi a 101 zakázkami a responsive `.godot/responsive/20260818-214740Z` se 7/7 případy. Toto procento neoznačuje ruční mobilní ani veřejnou publikační bránu za hotovou.

Následné auditní zpevnění je nasazené a ověřené úplnou validací `.godot/validation/20260818-220409Z`: `MVP_TESTS_PASSED=1040`, capture, visuals i úplná validace `PASSED` a 14/14 aktivních gate. Finální privacy a APK-identity kontrakt navíc prošel 1042/1042 regresními kontrolami, 6/6 cílenými kontrolami fáze 94 a PowerShell AST/helper smoke. Tento novější zdrojový průchod nepřepisuje release záznam `20260818-214533Z`, který správně zachycuje svou vloženou sadu 1036 kontrol.

Při `-Install` musí být uvedený explicitní immutable `-ApkPath`. Audit před a po `adb install -r` zapíše pouze sanitizované schema, mince, XP, počet slotů, počet obsazených květináčů a informační stav příběhu; raw save existuje jen krátce v paměti. Mince, XP a oba počty jsou srovnávané jako stabilní technická brána, zatímco příběhové hodnoty jsou informativní kvůli legitimní migraci fáze 93. Package probe se zpracuje pouze v paměti a do `package-metadata.txt` zapíše jen vlastní package, verzi, code a boolean dostupnosti `run-as`; `package-dump.txt` ani `package-path.txt` nevznikají. `apk-identity.txt` a report ukládají očekávaný i nainstalovaný SHA-256 a nedostupný nebo neshodný otisk technickou bránu zastaví. Celé výpisy oznámení, alarmů a logcatu ani raw save se nepersistují. Ukládají se pouze řádky vztahující se k balíčku, konečný omezený seznam pádových nálezů a skalární souhrny baterie a teploty. Nedostupná pádová evidence selže uzavřeně; baterie a teplota zůstávají ručním `PENDING`.

Fyzický audit `.godot/android-device-audit/20260819-043532Z` je autoritativní pro instalaci RC28 přes `adb install -r`, migraci schema 22 → 23 a semantic preservation: 21 mincí, 260 XP, 10 slotů i 2 obsazené květináče zůstaly stejné. Během 300 sekund bylo platných 55/55 odemčených a interaktivních foreground vzorků, aplikace zůstala ve 100 % vzorků v popředí a fatal count byl 0. Výsledkem je platné `AUDIT_STATE=CAPTURED` s `TECHNICAL_GATE=PASSED`.

Navazující autoritativní sanitizovaný audit `.godot/android-device-audit/20260819-045658Z` dokládá finální skript a kryptografickou identitu stejného APK. Za 300 sekund zachytil 54 platných vzorků se 100% pobytem v popředí, crash/ANR brána prošla s fatal count 0 a schema 23 → 23 i stabilní save prošly. Očekávaný a nainstalovaný SHA-256 jsou shodně `074444E4586C10729F743B9902C68689809298E750398C3CF6BB13988BCF6399`; APK identity je `PASSED`. Dva řádky evidence oznámení a 13 řádků alarmů jsou pouze `AVAILABLE`, nikoli důkaz skutečného doručení nebo deep linku. `package-dump.txt`, `package-path.txt` ani zakázané úplné telefonní logy nevznikly. Baterie 97 %, 29,6 °C a thermal status 0 z prvního běhu jsou pouze automatický podklad; lidská kontrola výdrže a teploty zůstává `PENDING`. Historická evidence RC27 a fáze 93 zůstává beze změny.

## Fáze 95 — nasazená a ověřená v hlavním projektu

- `salvia_officinalis` je desátý profil a Rare / `VZÁCNÁ` / ★★ rostlina: 20 h růst, 5 h sušení, cena 42 mincí, odemčení L7, vlastní zakázka a šest vlastních produkčních assetů. Současný katalog nemá žádný Legendary profil.
- `modest_feeding` / `STŘÍDMÁ VÝŽIVA` násobí úbytek živin 0,75× pouze včetně hranic profilového pásma 24–60 %. Online, offline, ETA i Centrum péče sdílejí po částech počítanou sazbu; bez traitu zůstává 0,9/h a s traitem v pásmu 0,675/h.
- Veřejné základní váhy Botanického balíčku zůstávají Common/Rare/Epic/Legendary/Special `55/30/10/5/0`. Protože současný desetidruhový pool nemá Legendary ani Special profil, přesné aktivní šance jsou `57.894737/31.578947/10.526316/0/0 %` a UI ukazuje `57.9/31.6/10.5/0/0 %`; způsobilých profilů je 10 a na nové hře je 8 dosud neudělených.
- `silver_sage_legacy` se odemkne až po claimu první kapitoly. Cíle jsou přesně 7 objevených druhů, 1 druh s mistrovstvím alespoň 3, kvalitní sklizně 3 různých druhů od 80 %, zakázky 2 různých konkrétních druhů a 1 skutečně otevřený balíček. Odměna 100 mincí, 80 XP, 2 semínka šalvěje a druhá pečeť je atomická; seed cap, stale ID, hostile save i opakovaný claim jsou bezpečné.
- Hlavní schema je 24. Hranice první kapitoly zůstává explicitně 23 a hranice druhé kapitoly je 24; starší save nikdy nemůže podvrhnout budoucí kapitolu nebo přeskočit první claim.
- Autoritativní actual důkaz pochází z hlavního `.godot/`: tests 1078/1078; validation `20260819-071937Z` 14/14 a capture, visuals i úplná validace `PASSED`; progression `20260819-072119Z` 120/120, 25 roundtripů, L80, 10 569 mincí, 108 zakázek; endurance `20260819-072119Z` 48/48 a 7 roundtripů, růst uzlů/orphanů/zdrojů 0, +0,02 MiB; responsive `20260819-072118Z` 7/7; performance `20260819-072116Z` CPU p95 11,569 ms, frame p95 16,707 ms, 443 draw calls, 80,96 MiB.
- Korekce fáze 95 je nasazená do `C:\_projekty\How to grow_`, ale Android export, APK, instalace ani fyzický audit se neprováděly; níže uvedený RC28/schema23 je historický immutable artefakt fáze 94.

## Fáze 96 — nasazená a ověřená v hlavním projektu

- Tři kanonické směsi jsou `evening_freshness` (máta + meduňka), `soup_pair` (petržel + majoránka) a `aromatic_sachet` (levandule + rozmarýn). Nabídnou se až po objevení obou ingrediencí.
- Fulfillment plán automaticky vybere přesně dva různé zabalené sloty, přičemž vyhovující právě vybraný slot má přednost a ostatní následují ve vzestupném pořadí. Pokud chybí druh, hmotnost nebo kvalita, UI pojmenuje přesnou první překážku a stav zůstane beze změny.
- Úspěch atomicky spotřebuje oba balíčky, přičte právě jednu globální zakázku, ale druhový mastery postup i deterministický seed roll provede pro obě ingredience. Meduňka si zachovává 75% šanci. Směsi záměrně neplní denní `sell` ani Profesorovu zakázku na konkrétní druh.
- Pětiřádkový blok zakázky ukazuje název, `SMĚS · 2 BYLINY`, dva přesné požadavky a stav; připravené CTA je `ODEVZDAT 2×`. `comic-herbal-blend-order.png` je append-only report-only diagnostika, nikoli nová gate. Schválené reference, `references/visual-cases.json`, crop, masky a tolerance se nezměnily.
- Hlavní schema je 25. Schema nejvýše 24 ignoruje injekci `kind`, `blend_id` i požadavků a bezpečně zachová nebo obnoví staré single zakázky. Schema 25 přijímá pouze známá kanonická ID, omezuje hostile sequence a deduplikuje aktivní směsi. Story trust boundary zůstávají 23/24. Claim mistrovské odměny před jakoukoli mutací kontroluje kapacitu semínka, takže seed cap nemůže změnit hodnost, mince, XP ani inventář.
- Autoritativní actual důkaz: tests 1108/1108; validation `.godot/validation/20260819-101102Z` s capture, visuals i úplnou validací `PASSED` a 14/14 gate; progression `.godot/progression/20260819-101241Z` 120/120, 25 roundtripů, L81, 10 051 mincí a 100 zakázek; endurance `.godot/endurance/20260819-101241Z` 48/48, 7 roundtripů, růst uzlů/orphanů/zdrojů 0 a +0,02 MiB; responsive `.godot/responsive/20260819-101238Z` 7/7; performance `.godot/performance/20260819-101302Z` CPU p95 9,966 ms, frame p95 16,695 ms, 443 draw calls a 82,16 MiB.
- Fáze 96 je nasazená do `C:\_projekty\How to grow_`, ale Android export, APK, instalace ani nový telefonní audit se bez dostupného mobilu neprováděly. Níže uvedený RC28/code45/schema23 je historický immutable artefakt fáze 94.

## Fáze 97 — nasazená a ověřená v hlavním projektu

- `grand_herbarium_exhibition` / `Velká herbářová výstava` se odemkne až autoritativním claimem `silver_sage_legacy`. Pět cílů má pevné cílové hodnoty 10/3/3/3/4: deset viditelných objevů, tři druhy s mistrovstvím alespoň 3, tři přísně rostoucí UTC dny vyzvednutí po odemčení, zakázky tří různých konkrétních druhů po odemčení a výstavní sklizně šalvěje plus tří různých nešalvějových druhů po odemčení v kvalitě alespoň 85 %. `any`, směsi a výuková sklizeň se nepočítají.
- Odměna je atomických 150 mincí, 120 XP, 3 dávky hnojiva, třetí Profesorova pečeť a titul `herbarium_master` / `MISTR HERBÁŘE`; nepřidává semínko ani Botanický balíček. Titul současně tvoří devátý odvozený odznak Pěstitelského deníku.
- Hlavní schema je 26 a story trust boundary jsou 23/24/26. Schema 25 ignoruje vložený stav třetí kapitoly a po legitimním dokončení prvních dvou vytvoří čistou nepřečtenou třetí; aktivní ID se vždy odvozuje. Claim implikuje přečtení a hostile typy, duplicity, klesající dny, stale ID ani opakovaný claim nevytvářejí postup nebo odměnu.
- Čtyři append-only PNG `comic-professor-exhibition-active.png`, `comic-professor-exhibition-ready.png`, `comic-professor-exhibition-claimed.png` a `comic-grower-journal-herbarium-master.png` jsou report-only. `references/visual-cases.json`, schválené PNG, crop, masky a tolerance se nezměnily.
- Autoritativní actual důkaz: tests 1140/1140; validation `.godot/validation/20260819-121431Z` s capture, visuals i úplnou validací `PASSED` a 14/14 gate; progression `.godot/progression/20260819-121604Z` 120/120, 25 roundtripů, L81, 10 051 mincí a 100 zakázek; endurance `.godot/endurance/20260819-121621Z` 48/48, 7 roundtripů, růst uzlů/orphanů/zdrojů 0 a +0,02 MiB; responsive `.godot/responsive/20260819-121643Z` 7/7 plus explicitní geometrie 432×960 a 360×800; performance `.godot/performance/20260819-121700Z` CPU p95 9,960 ms, frame p95 16,686 ms, 443 draw calls a 82,37 MiB.
- Fáze 97 je nasazená do `C:\_projekty\How to grow_`, ale Android export, APK, instalace ani nový telefonní audit se bez dostupného mobilu neprováděly. Níže uvedený RC28/code45/schema23 je historický immutable artefakt fáze 94.

## Fáze 98 — nasazená a ověřená v hlavním projektu

- `professor_weekly_protocol` / `Profesorův týdenní protokol` je samostatný opakovatelný systém po autoritativním claimu třetí kapitoly, nikoli čtvrtá story kapitola. Nabídka vyžaduje explicitní přijetí.
- Pět cílů 3/2/2/2/2 znamená tři různé smysluplné úspěšné péče, dvě nevýukové sklizně s kvalitou alespoň 80 %, dvě úspěšná zabalení, dva skutečně doručené balíčky a denní odměnu ve dvou přísně rostoucích UTC dnech po přijetí. Jednobalíčkové prodejní/objednávkové cesty započítají jeden kus, směs dva.
- Aktivní protokol neexpiruje. Nové nabídky začínají v pondělí 00:00 UTC, po pozdním claimu se nabídne jen aktuální týden a neexistuje backlog, streak ani trest. Odměna se připíše atomicky a idempotentně: 45 mincí, 35 XP a jedna dávka hnojiva bez semínka, balíčku, pečeti nebo titulu.
- `completed_count` po čtyřech dokončeních přidá desátý odznak `research_partner` / `VÝZKUMNÝ PARTNER`. Tři story pečetě a titul `MISTR HERBÁŘE` zůstávají konečné. Prezentační latch po claimu třetí kapitoly zachová obrazovku `MISTR HERBÁŘE`; týdenní nabídku zobrazí až další otevření jediného Profesorova modalu.
- Hlavní schema je 27. Týdenní stav je oddělený od story trust boundary 23/24/26, rollback-safe high-water používá aktuální den, uložený čas i dosavadní maximum a schema i reálné UTC dny přijímají pouze přesná konečná ohraničená celá čísla.
- Tři append-only PNG `comic-professor-weekly-research-active.png`, `comic-professor-weekly-research-ready.png` a `comic-professor-weekly-research-cooldown.png` jsou report-only. `references/visual-cases.json`, schválené PNG, crop, masky a tolerance se nezměnily.
- Autoritativní actual důkaz: tests 1176/1176; validation `.godot/validation/20260819-143453Z` s capture, visuals i úplnou validací `PASSED` a 14/14 gate; progression `.godot/progression/20260819-143648Z` 120/120, 25 roundtripů, L81, 10 051 mincí a 100 zakázek; endurance `.godot/endurance/20260819-143700Z` 48/48, 7 roundtripů, růst uzlů/orphanů/zdrojů 0 a +0,03 MiB; responsive `.godot/responsive/20260819-143722Z` 7/7; performance `.godot/performance/20260819-143737Z` CPU p95 10,691 ms, frame p95 16,692 ms, 443 draw calls a 82,88 MiB.
- Fáze 98 je nasazená do `C:\_projekty\How to grow_`, ale Android export, APK, instalace ani nový telefonní audit se bez dostupného mobilu neprováděly. Níže uvedený RC28/code45/schema23 je historický immutable artefakt fáze 94.

## Fáze 99 — nasazená a ověřená v hlavním projektu

- Pondělní UTC cyklus deterministicky rotuje tři varianty. `balanced_v1` / `Vyvážený protokol` má cíle 3/2 při 80 %/2/2/2, `quality_focus_v1` / `Kontrola kvality` 2/3 při 90 %/2/2/2 a `processing_focus_v1` / `Zpracování a odbyt` 2/2 při 80 %/3/3/2.
- Nabídku je nutné výslovně přijmout. Přijaté `protocol_id` je immutable: aktivní protokol neexpiruje, neposune se s dalším týdnem ani rollbackem hodin a po save/load zachová vlastní cíle. Odměna zůstává 45 mincí, 35 XP a jedna dávka hnojiva; není backlog, streak ani trest.
- Hlavní schema je 28. Legacy schema 27 migruje offer, active, ready i cooldown bez ztráty postupu a každý jeho aktivní protokol připne k `balanced_v1`. Neznámé schema-28 `protocol_id` odstraní jen neautoritativní aktivní přiřazení, ale zachová bezpečnou claimed historii a `completed_count`. Claim rollback chrání výzkum, mince, XP i hnojivo před dílčí odměnou. Story trust boundary zůstávají 23/24/26 a směsi 25.
- Po šesti dokončeních lze za 360 mincí odemknout čtvrtý kódově kreslený vzhled `research_study` / `Badatelská pracovna`. Nemá herní bonus. Showroom pravdivě zobrazuje stav `x/4`, zatímco historický `room_collector` zůstává navázaný pouze na tři základní motivy.
- Pět append-only PNG `comic-professor-weekly-research-variant-balanced.png`, `comic-professor-weekly-research-variant-quality.png`, `comic-professor-weekly-research-variant-processing.png`, `comic-cosmetic-showroom-research-study-locked.png` a `comic-cosmetic-showroom-research-study-selected.png` je report-only. `references/visual-cases.json`, schválené PNG, crop, masky ani tolerance se nezměnily.
- Autoritativní actual důkaz: tests 1204/1204; validation `.godot/validation/20260819-155446Z` s capture, visuals i úplnou validací `PASSED` a 14/14 gate; progression `.godot/progression/20260819-155623Z` 120/120, 25 roundtripů, L81, 10 051 mincí a 100 zakázek; endurance `.godot/endurance/20260819-155637Z` 48/48, 7 roundtripů, růst uzlů/orphanů/zdrojů 0/0/0 a +0,03 MiB; responsive `.godot/responsive/20260819-155656Z` 7/7; performance `.godot/performance/20260819-155711Z` CPU p95 11,838 ms, frame p95 16,759 ms, 443 draw calls a 83,19 MiB.
- Fáze 99 je nasazená do `C:\_projekty\How to grow_`, ale sama Android export, APK, instalaci ani telefonní audit neprovedla. V okamžiku jejího uzavření byl posledním Android artefaktem RC28 `0.44.0-rc28` / code 45 / schema 23; jde o historický stav před RC29.

## Fáze 100 / RC29 — automatická technická část hotová

- Projekt a Android preset jsou sjednocené na `0.45.0-rc29`, version code 46 a zdrojové i save schema 28. Kandidát obsahuje celý stav fáze 99 včetně tří týdenních protokolů a `Badatelské pracovny`.
- Release běh `.godot/release-candidate/20260819-162250Z` prošel: validation `.godot/validation/20260819-162251Z` 1204/1204 a 14/14 gate; performance `.godot/performance/20260819-162410Z` CPU p95 10,075 ms, frame p95 16,687 ms, 443 draw calls a 83,19 MiB; endurance `.godot/endurance/20260819-162454Z` 48/48, 7 roundtripů, růst uzlů/orphanů/zdrojů 0 a +0,03 MiB; progression `.godot/progression/20260819-162504Z` 120/120, 25 roundtripů, L81, 10 051 mincí a 100 zakázek; responsive `.godot/responsive/20260819-162508Z` 7/7. Payload, podpis a notification payload jsou `PASSED`.
- Immutable APK `builds/android/bazals-pocket-garden-0.45.0-rc29-arm64-debug.apk` má 110 561 232 B (105,44 MiB) a SHA-256 `E10D2F655310E98AD4ACB3F0490145592A222D4B2049225D364FF5FF7BB51EA7`.
- Přepisovatelný výchozí export `builds/android/bazals-pocket-garden-debug.apk` byl po úspěšném RC29 auditu nahrazen stejnými 110 561 232 B a stejným SHA-256. Nejde o druhý immutable kandidát; autoritativním důkazem zůstává verzovaný APK výše.
- Technický audit `.godot/android-device-audit/20260819-162632Z` trval 300 sekund, získal 54/54 platných odemčených a interaktivních vzorků, 100 % času v popředí a fatal count 0. APK identity, crash/ANR, save schema a semantic comparison jsou `PASSED`; migrace 23 → 28 zachovala 21 mincí, 260 XP, 10 slotů a 2 obsazené květináče.
- Nainstalovaný save má story stav `LOCKED` a 0 pečetí. Obsah fáze 99 je v APK, ale na tomto konkrétním postupu ještě není odemčený. Notification evidence 1 a alarm evidence 13 jsou pouze `AVAILABLE`, nikoli potvrzení doručení, deep linku nebo obnovy po restartu.
- `gfxinfo` ze 42 snímků uvádí 9 janky (21,43 %), p95 48 ms a p99 750 ms. Jde pouze o podklad k ručnímu posouzení, **ne o výkonový průchod**. Stejně tak baterie 55 %, 40,2 °C, thermal status 0 a maximum 21 °C z thermal servisu nejsou automatickým schválením výdrže nebo teploty.
- `PHYSICAL_ANDROID_MANUAL_GATE=PENDING`: všech 18 bodů zálohy/importu, oznámení, restartu, systémového Zpět, dotyku, safe area, scrollu, návratu z pozadí, celého cyklu, komfortu animací, baterie a teploty čeká na člověka. Jednotný postup a důkazová pole jsou v `docs/ANDROID_RC29_MANUAL_GATE.md`. `PUBLISHING_GATE=PENDING_RELEASE_KEYSTORE_AAB_STORE_REVIEW` zůstává otevřený.
- Následné source-only zpevnění exportu ponechalo všechny zdrojové PNG beze změny a vyloučilo pouze prokazatelně nepoužívané raw/legacy textury. Dočasný ignorovaný APK `.godot/apk-size-audit/rc29-pruned-debug.apk` prošel podpisem, kontrolou payloadu i notification bridge, má 104 419 741 B (99,58 MiB) a SHA-256 `0A263739031DEAA7BC2C0B1F330157FCD8A5A81DA63B58087EC331BC28391EA5`; proti immutable RC29 šetří 6 141 491 B (5,55 %). Následná validace `.godot/validation/20260819-191410Z` prošla 1204/1204 a 14/14 aktivních gate. Jde o ověření budoucího exportního nastavení, nikoli o nový immutable release kandidát, a původní RC29 APK zůstává nedotčený.
- Následný technický audit stejného immutable RC29 `.godot/android-device-audit/20260820-043712Z` znovu prošel: instalovaný hash přesně odpovídal, save schema zůstalo 28 → 28 a zachovalo 23 mincí, 37 XP, počet slotů i jeden obsazený květináč. Běh trval 300 sekund, měl 54/54 platných odemčených a interaktivních vzorků, 100 % v popředí a 0 crash/ANR/Godot fatal nálezů. `gfxinfo` z 45 snímků uvádí 3 janky (6,67 %), p95 16 ms a p99 450 ms; jde o lepší krátký vzorek, nikoli ruční výkonový PASS. Baterie zůstala na 100 % a její teplota vzrostla z 29,3 °C na 31,9 °C. Thermal service hlásil maximum 10 °C, které není s bateriovým čidlem konzistentní, proto se pro rozhodnutí o teplotě nepoužívá. Čtyři package-scoped notification řádky ani nulový alarm nedokládají skutečné herní oznámení. Všech 18 ručních bodů proto správně zůstává otevřených. Auditní skript nyní místo neexistujícího souhrnného pole čte samostatně AC, USB, bezdrátové a dokové napájení; parser smoke prošel a úplná validace `.godot/validation/20260820-044727Z` skončila 1204/1204 a všemi aktivními gate `PASSED`.
- Lokální publikační cesta nyní obsahuje oddělený Gradle preset `Android Release AAB`, explicitní minSdk 24 / targetSdk 36 a skript, který přijímá release heslo pouze proměnnou prostředí a odmítá přepsat existující balíček. Smoke `.godot/android-release-aab/20260820-062151Z` vytvořil testovací AAB o 50 745 011 B (48,39 MiB), SHA-256 `8D48D4FBF64CE7BB49C62C946444611C2A605BFBD476F9525506F95B5BB560A7`; export, JAR podpis, payload ARM64 a notification/deep-link DEX kontrola jsou `PASSED`. Jednorázový 30denní testovací klíč byl po běhu odstraněn a AAB je záměrně pouze smoke důkaz, nikoli balíček pro Play Console. Exportem generovaný install-time asset-pack payload a release manifest jsou přesně ignorované, vlastní `src/main` Android zdroje zůstávají sledované. `PUBLISHING_GATE` dál čeká na produkční upload key, finální verzování, Play App Signing a store review.

## Aktuální připravený a nainstalovaný Android artefakt RC47

- Soubor: `C:\_projekty\How to grow_\builds\android\bazals-pocket-garden-0.59.0-rc47-arm64-debug.apk`
- Výchozí exportní alias: `C:\_projekty\How to grow_\builds\android\bazals-pocket-garden-debug.apk` — bajtově shodný s RC47, ale přepisovatelný při dalším úspěšném release běhu
- Velikost: `108 222 588` B
- Verze: `0.59.0-rc47`, version code `64`, save schema `37`
- SHA-256 obou současných souborů: `3BC47AB155065EDE0E0AECB246026E62A324B4B25CDF5BAF76FD117AA5FCDC7F`
- Release audit: `.godot/release-candidate/20260822-120356Z`
- Automatizace: `.godot/automation/20260822-120356Z`
- Fyzická instalace a technický audit: `.godot/android-device-audit/20260822-120721Z`, `PASSED_TECHNICAL`

RC47 je finální immutable interní kandidát fáze 122 po fyzickém uzavření vodorovné i svislé transakční ochrany. RC45 zůstává immutable: 108 222 968 B, SHA-256 `F58C6A79965B9DB77ACEF7338050CA46D444E0882DB56C531F6133D072F425A0`; RC46 zůstává immutable: 108 222 272 B, SHA-256 `1266E897FD8D0CDB23BD1F2FC27F1B19894BAD92989060A4EAB2C7412ED7F1C5`. AAB ani veřejný upload nevznikly.

## Historický fyzicky přijatý Android artefakt RC36

- Soubor: `C:\_projekty\How to grow_\builds\android\bazals-pocket-garden-0.50.0-rc36-arm64-debug.apk`
- Výchozí exportní alias byl v době RC36 release bajtově shodný; dnes ukazuje na aktuální RC47
- Architektura: ARM64
- Verze: `0.50.0-rc36`, version code `53`, save schema `32`
- Velikost: `101,27 MiB` (`106 193 804` B)
- SHA-256 obou souborů: `9987F544E5FC692BA0F05BE183FDCDB6E426572A769FDC6D9CA01DDB44936860`
- Podpis: standardní Godot debug certifikát, ověřené APK Signature Scheme v2
- Účel: interní instalace a kontrola na telefonu; nejde o Google Play release balíček.

Úplný lokální release audit RC36 je `.godot/release-candidate/20260821-160145Z`, instalační technický záznam `.godot/android-device-audit/20260821-163933Z`, finální readback po krátkém lidském přijetí `.godot/android-device-audit/20260821-190953Z` a uzavřený reboot/greenhouse-ready důkaz `.godot/android-long-delay/20260821-213651Z`. Verzovaný RC36 APK je immutable a zůstává posledním kandidátem s dokončeným tehdejším úplným lidským přijetím. Obecný alias už patří RC47 a nesmí se používat jako důkaz identity RC36.

## Historický Android artefakt RC29

- Soubor: `C:\_projekty\How to grow_\builds\android\bazals-pocket-garden-0.45.0-rc29-arm64-debug.apk`
- Stav v době RC29 auditu: výchozí exportní alias `C:\_projekty\How to grow_\builds\android\bazals-pocket-garden-debug.apk` byl bajtově shodný s RC29; dnes ukazuje na aktuální RC47
- Architektura: ARM64
- Verze: `0.45.0-rc29`, version code `46`, zdrojové i save schema `28`
- Velikost: `105,44 MiB` (`110 561 232` B)
- SHA-256: `E10D2F655310E98AD4ACB3F0490145592A222D4B2049225D364FF5FF7BB51EA7`
- Podpis: standardní Godot debug certifikát, ověřené APK Signature Scheme v2
- Účel: historická interní instalace a kontrola na telefonu; nejde o Google Play release balíček.

Úplný lokální release audit je uložený v `C:\_projekty\How to grow_\.godot\release-candidate\20260819-162250Z`, první technický fyzický záznam v `.godot/android-device-audit/20260819-162632Z` a poslední opakovací běh v `.godot/android-device-audit/20260820-043712Z`. Artefakt je verzovaný a immutable; případný další build musí dostat nové jméno nebo verzi.

## Historický Android artefakt RC28

- Soubor: `C:\_projekty\How to grow_\builds\android\bazals-pocket-garden-0.44.0-rc28-arm64-debug.apk`
- Architektura: ARM64
- Verze: `0.44.0-rc28`, version code `45`, save schema `23`
- Velikost: `103,53 MiB` (`108 558 035` B)
- SHA-256: `074444E4586C10729F743B9902C68689809298E750398C3CF6BB13988BCF6399`
- Podpis: standardní Godot debug certifikát, ověřené APK Signature Scheme v2
- Účel: historická interní instalace a kontrola na telefonu; nejde o Google Play release balíček.

Historický release audit RC28 je `.godot/release-candidate/20260818-214533Z`, migrační fyzický záznam `.godot/android-device-audit/20260819-043532Z` a finální sanitizovaný technický záznam `.godot/android-device-audit/20260819-045658Z`.

## Historický Android artefakt RC27

- Soubor: `C:\_projekty\How to grow_\builds\android\bazals-pocket-garden-0.43.0-rc27-arm64-debug.apk`
- Architektura: ARM64
- Verze: `0.43.0-rc27`, version code `44`, save schema `22`
- Velikost: `103,48 MiB` (`108 508 185` B)
- SHA-256: `6B632B9687CFB47ABACB403AC6A9717A2DE93970DC7424F8F7C285A748456002`
- Podpis: standardní Godot debug certifikát, ověřené APK Signature Scheme v2
- Účel: historická interní instalace a kontrola na telefonu; nejde o Google Play release balíček.

Úplný lokální RC27 audit je uložený v `C:\_projekty\How to grow_\.godot\release-candidate\20260818-153320Z` a jeho fyzický záznam v `.godot/android-device-audit/20260818-154709Z`. Aktuální hlavní projekt i RC29 používají schema 28 (lifecycle 20, inventář semen 21, Botanické balíčky 22, první kapitola 23, druhá kapitola 24, směsi 25, třetí kapitola 26, základ týdenního výzkumu 27 a varianty protokolů 28), ale `0.43.0-rc27` / code 44 zůstává na schema 22 a RC28 `0.44.0-rc28` / code 45 na schema 23. `phase91-payload-smoke.apk` je pouze historický izolovaný validační artefakt; fáze 95–99 samy Android build nevytvořily a jejich společný export přinesla až fáze 100 / RC29.

Historický pokus RC26 `20260818-044332Z` zůstává správně vedený jako **neplatný**. RC27 běh `20260818-154709Z` už proběhl za platných podmínek: 54/54 vzorků bylo odemčených, interaktivních a v popředí, schema 22 souhlasilo a pád/ANR/Godot chyba se neobjevily. Nulový počet snímků z `gfxinfo` se u nativního Godot GL rendereru dál označuje jako `UNAVAILABLE_NATIVE_GL`, ne jako průchod nebo selhání výkonu.

## Historická ruční brána RC29

1. **Technicky ověřeno:** RC29 byl nainstalován přes předchozí build bez mazání dat; sanitizované pre/post srovnání doložilo schema 23 → 28 a zachování 21 mincí, 260 XP, 10 slotů i 2 obsazených květináčů. Expected a installed SHA-256 se shodují a nevznikly zakázané úplné telefonní výpisy.
2. Na telefonu se ověří výřez displeje, čitelnost, dotykové cíle, svislý scroll, vodorovný swipe a hierarchie systémového Zpět od modalu přes detail a vedlejší záložku až po bezpečné ukončení.
3. `.htgbackup` se vyexportuje, náhled importu ukáže očekávanou úroveň, mince a obsazené květináče a potvrzená obnova přežije restart aplikace; zrušení document pickeru nesmí vytvořit falešný návratový souhrn.
4. V Centru péče se ověří 20sekundové testovací oznámení, klepnutí na přesný květináč nebo Sklad a běžné upozornění po zavření aplikace i restartu telefonu.
5. Ověří se návrat z pozadí, skutečně uplynulý čas, obnovení save, návratový souhrn a alespoň jeden celý pěstitelský cyklus včetně návratu ke zralé nebo zanedbané rostlině.
6. Při plném stojanu se lidsky posoudí plynulost, teplota a spotřeba; desktopový smoke ani posledních 45 `gfxinfo` snímků s 6,67 % janky, p95 16 ms a p99 450 ms tento krok nenahrazuje.

Dřívější ruční kontroly mobilního UX a přenos `.htgbackup` i platné technické záznamy RC27 a RC28 zůstávají historickými dílčími důkazy. RC29 má platné technické záznamy `.godot/android-device-audit/20260819-162632Z` a `.godot/android-device-audit/20260820-043712Z`; `PHYSICAL_ANDROID_TECHNICAL_GATE=PASSED`. Všech 18 polí aktuálního ručního auditu je nepotvrzených. `PHYSICAL_ANDROID_MANUAL_GATE=PENDING` zůstává otevřený pro zálohu/import, skutečné doručení a cíl oznámení včetně restartu, dotyk, safe area, hierarchii systémového Zpět, návrat z pozadí, celý cyklus, komfort animací, teplotu a baterii. Poslední krátký vzorek ponechal baterii na 100 % a zvýšil její čidlo z 29,3 °C na 31,9 °C; thermal maximum 10 °C je nekonzistentní a není podkladem k PASS. Lokální AAB pipeline je prokázaná, ale `PUBLISHING_GATE=PENDING_RELEASE_KEYSTORE_AAB_STORE_REVIEW` dál čeká na produkční upload key, finální AAB, Play App Signing a store review.

## RC34 — skleník se dvěma plodinami

`0.48.0-rc34` / code 51 / save schema 31 je historický immutable interní Android kandidát. Obsahuje explicitní volbu cherry rajčete nebo sladké papriky, opravenou cestu `skleník → Sklad → ROSTLINY → stojan` a všechny dříve dokončené fáze. APK `builds/android/bazals-pocket-garden-0.48.0-rc34-arm64-debug.apk` má 101,27 MiB a SHA-256 `D31E42B303319020CDBB839B3935F1008190D410172EEAEC88BE9986C2CCAB02`.

Lokální release audit `.godot/release-candidate/20260820-204608Z` prošel. Validace `.godot/validation/20260820-204609Z` dokončila 1278/1278 kontrol, capture, visuals a všechny povinné gate. Performance `.godot/performance/20260820-204728Z` naměřilo nejvyšší CPU p95 9,075 ms, frame p95 16,699 ms, nejvýše 449 draw calls a 85,63 MiB. Endurance `.godot/endurance/20260820-204811Z` prošlo 48/48 cykly, 7 roundtripy a nulovým růstem uzlů, orphanů i zdrojů. Progression `.godot/progression/20260820-204821Z` dokončil 132/132 cyklů, 27 roundtripů, úroveň 90, 11 246 mincí a 112 zakázek. Responsive `.godot/responsive/20260820-204826Z` prošel 7/7; Gradle export, podpis APK v2, entry scan, runtime payload a notification payload jsou `PASSED`.

Fyzický audit `.godot/android-device-audit/20260820-204916Z` nainstaloval RC34 přes RC33 bez mazání dat, potvrdil přesnou identitu APK, migraci save schema 30 → 31 a zachování stabilních významových hodnot. Za 60 sekund prošlo 11/11 platných foreground vzorků, poměr popředí byl 100 % a fatal count 0. `PHYSICAL_ANDROID_TECHNICAL_GATE=PASSED`. Dne 20. 8. 2026 uživatel ručně potvrdil volbu, zasazení a zálivku papriky, zachování rozpracovaného záhonu i opravenou cestu `skleník → Sklad → ROSTLINY → stojan`; dotyková část RC34 je `PASSED`. Skutečné upozornění, delší bateriový běh a teplota zůstávají `PENDING`. Veřejná brána dál čeká na produkční upload key, AAB a store review.

## RC35 — postup skleníku a salátová okurka

`0.49.0-rc35` / code 52 / save schema 32 je historický immutable interní Android kandidát. Přidává třetí plodinu, salátovou okurku, a autoritativní postupové zámky: rajče od úrovně 1, paprika od úrovně 2 a okurka od úrovně 4. Všechny tři volby jsou dvouřádkové 64px dotykové cíle; zamčenou výsadbu odmítne UI i `GameSession` bez odečtení mincí. APK `builds/android/bazals-pocket-garden-0.49.0-rc35-arm64-debug.apk` má 106 191 776 B (101,27 MiB) a SHA-256 `54F4CBE062693324E1C01AD7A3F371166E5ACAB3997D634A762FA324F5D876A2`.

Lokální release audit `.godot/release-candidate/20260820-212051Z` prošel. Validace `.godot/validation/20260820-212051Z` dokončila 1286/1286 kontrol, capture, visuals a všechny povinné gate beze změny schválených referencí a tolerancí. Performance `.godot/performance/20260820-212215Z` naměřilo nejvyšší CPU p95 8,876 ms, frame p95 16,698 ms, nejvýše 449 draw calls a 85,71 MiB. Endurance `.godot/endurance/20260820-212259Z` prošlo 48/48 cykly, 7 roundtripy a nulovým růstem uzlů, orphanů i zdrojů. Progression `.godot/progression/20260820-212310Z` dokončil 132/132 cyklů, 27 roundtripů, úroveň 90, 11 246 mincí a 112 zakázek. Responsive `.godot/responsive/20260820-212315Z` prošel 7/7; Gradle export, podpis APK v2, entry scan, runtime payload a notification payload jsou `PASSED`.

První záznam `.godot/android-device-audit/20260820-212422Z` nebyl platným runtime auditem, protože telefon spal; nesmí se vydávat za průchod. Jeho předinstalační sanitizovaný snímek ale zachytil původní schema 31, 22 mincí, 127 XP, 10 slotů a 1 obsazený květináč. Následující platný audit `.godot/android-device-audit/20260820-212656Z` ověřil přesnou identitu nainstalovaného APK, schema 32 a stejné významové hodnoty. Za 60 sekund prošlo 11/11 foreground vzorků, poměr popředí byl 100 % a fatal count 0. `PHYSICAL_ANDROID_TECHNICAL_GATE=PASSED`. Ruční čitelnost tří voleb a zámku okurky, skutečné upozornění, delší bateriový běh a teplota zůstávají `PENDING`; veřejná brána dál čeká na produkční upload key, AAB a store review.

## Fáze 108 — stabilizace RC35

Fáze 108 nemění runtime, gameplay, ekonomiku ani save a nevytváří nový kandidát. `tools/run_tests.ps1` nyní přijme průchod pouze při současném PASS markeru a exit code 0. Release runner bezpečně připraví a hashově ověří alias před jeho nahrazením a zaznamená jeho cestu i SHA-256. Interní Android debug preset má explicitní minSdk 24 / targetSdk 36 a tomato E2E používá viditelné `crop_buttons[0]` namísto skrytého legacy tlačítka.

Automatické důkazy jsou zelené: 1289/1289 testů; validation `.godot/validation/20260820-215826Z` s full/capture/visual `PASSED`; endurance `.godot/endurance/20260820-220003Z`; progression `.godot/progression/20260820-220029Z`; responsive `.godot/responsive/20260820-220046Z`; performance `.godot/performance/20260820-220059Z`. Reference, crop, masky, tolerance a zdrojové PNG zůstaly beze změny.

Read-only kontrola připojeného telefonu znovu potvrdila přesně nainstalované RC35/code 52, save schema 32, úroveň 2, 22 mincí, 127 XP a hru v popředí. Neproběhla instalace ani smazání dat. Operační systém odmítl injekci vstupu přes ADB, takže lidská L2 kontrola čitelnosti a dotyku zůstává `PENDING`, stejně jako skutečná výsadba okurky po přirozeném dosažení úrovně 4, skutečné upozornění a delší posouzení baterie/teploty. `PUBLISHING_GATE=PENDING_RELEASE_KEYSTORE_AAB_STORE_REVIEW` dál čeká na produkční upload key, finální AAB, Play App Signing a store review.

## Fáze 109 — skleníkový návrat a kompaktní mobilní rozložení

Fáze 109 je runtime změna ve zdrojovém projektu. Zalité záhony při skutečném přechodu do sklizně vytvářejí jednorázovou `greenhouse_ready` událost, offline návrat ji přidá k dosavadním lifecycle událostem a návratový souhrn zobrazí přesný záhon i plodinu. Tlačítko skleníku na stojanu odvozeně ukazuje součet záhonů čekajících na zálivku nebo sklizeň. Kompaktní větev pro obsah 360×620 opravuje 26px překryv spodních záhonů se stavovým panelem a zachovává tři oddělené volby plodiny o výšce 64 px. Save schema 32, ekonomika, odměny, katalog i úrovňové zámky se nemění.

Automatické důkazy v hlavním projektu jsou zelené: validation `.godot/validation/20260821-143411Z` s `MVP_TESTS_PASSED=1299` a capture/visuals/full `PASSED`; progression `.godot/progression/20260821-143705Z` 132/132 a 27 roundtripů; endurance `.godot/endurance/20260821-143720Z` 48/48, 7 roundtripů a růst uzlů/orphanů/zdrojů 0/0/0; responsive `.godot/responsive/20260821-143741Z` 8/8 včetně přesného 360×800; performance `.godot/performance/20260821-143755Z` s CPU p95 max. 9,429 ms, frame p95 max. 16,699 ms, 449 draw calls a 85,73 MiB. Tři nové snímky jsou report-only; schválené reference, manifest, crop, masky a tolerance zůstaly beze změny.

Při dokončení samotné fáze 109 nevznikl APK/AAB a immutable RC35 ani jeho tehdejší alias se nezměnily. Navazující RC36 popsané níže tuto distribuci provedlo bez přepsání RC35. `PHYSICAL_ANDROID_MANUAL_GATE=PENDING` dál zahrnuje zbývající lidské a systémové body; `PUBLISHING_GATE=PENDING_RELEASE_KEYSTORE_AAB_STORE_REVIEW` se nemění.

## RC36 — fáze 109 na fyzickém Androidu

`0.50.0-rc36` / code 53 / save schema 32 bylo v době této fáze posledním nainstalovaným immutable interním Android kandidátem a dnes zůstává historickým kandidátem s úplným tehdejším lidským přijetím. Release `.godot/release-candidate/20260821-160145Z` prošel validací, performance, endurance, progression, responsive maticí 8/8, Android exportem, podpisem, payloadem i notification payloadem. Verzovaný APK `builds/android/bazals-pocket-garden-0.50.0-rc36-arm64-debug.apk` má 106 193 804 B a SHA-256 `9987F544E5FC692BA0F05BE183FDCDB6E426572A769FDC6D9CA01DDB44936860`; přepisovatelný alias byl v době release bajtově shodný a dnes ukazuje na RC47. RC35 zůstalo 106 191 776 B se svým původním SHA-256 `54F4CBE062693324E1C01AD7A3F371166E5ACAB3997D634A762FA324F5D876A2`.

Platný pětiminutový audit `.godot/android-device-audit/20260821-163933Z` nainstaloval RC36 přes RC35 bez mazání dat. Očekávaný a nainstalovaný hash se shodují, save zůstal schema 32 → 32 a stabilní mince, XP, počet slotů i obsazených květináčů byly zachované. Audit získal 54/54 odemčených a interaktivních vzorků, hra byla ve 100 % vzorků v popředí a fatal count byl 0; `PHYSICAL_ANDROID_TECHNICAL_GATE=PASSED`. Krátké `gfxinfo` mělo 45 snímků, p95 12 ms a 2 janky snímky; konečná baterie byla 100 % při USB napájení a 32,3 °C. Jde o technický podklad, ne automatický lidský výkonový nebo tepelný PASS.

Čtyři fyzické snímky a provedená sklizeň částečně uzavřely UX fáze 109: návratový modal i skleník byly bez překryvu, tři volby a zámek okurky byly čitelné, sklizeň změnila 22 → 46 mincí a 27 → 35 XP a návrat na stojan ukázal přesně `3 AKCE`. Tlačítko konkrétní plodiny nebylo v tomto průchodu stisknuto a zralé záhony mohly existovat už před offline intervalem, takže přirozené nové dozrání s návratovým skleníkovým řádkem se nesmí vydávat za fyzicky potvrzené. Záloha/import, nový/obnovený save, systémové Zpět, skutečné oznámení včetně rebootu a lidské posouzení delší spotřeby/teploty zůstávají v jediném `PENDING_SINGLE_HUMAN_BATCH`.

## Fáze 110 — autonomní pracovní a release workflow

Fáze 110 přidává `tools/run_project_automation.ps1` jako jediný doporučený vstup pro technickou práci. `Quick` deleguje autoritativní regresi, výchozí `Full` skládá validaci, performance, endurance, progression a responsive matici, `Release` deleguje existujícímu immutable release runneru a `ReleaseDevice` k právě vytvořenému verzovanému APK přidá nedestruktivní instalaci a technický audit telefonu.

Orchestrace nepřebírá logiku dílčích bran. Každý podproces musí současně skončit exit kódem 0, emitovat povinné PASS markery a neobsahovat parserovou ani testovou chybu. Běh vždy zapisuje `automation-report.json`, `automation-report.md`, snapshot dirty pracovního stromu a oddělené logy pod `.godot/automation/<UTC timestamp>/`. Release režimy odmítnou existující immutable cestu před dlouhou prací, nikdy neinstalují obecný alias a telefonní režim nikdy nepoužívá `-ClearAppData`.

Automatizace nesmí vydávat subjektivní nebo systémové pozorování za technický PASS. Čitelnost a pocit z dotyku na konkrétním hardwaru, Android document picker a destruktivní restore scénáře, skutečné doručení/deep link/reboot oznámení a lidské posouzení výdrže či teploty zůstávají `PENDING_SINGLE_HUMAN_BATCH`. Mají být vyžádány jednou na konci, nikoli jako série potvrzení mezi automatickými kroky.

Fáze 110 mění pouze nástroje, testy a dokumentaci. Runtime, ekonomika, save schema 32 i exportovaný payload zůstávají beze změny; immutable RC36 `0.50.0-rc36` / code 53 se nesmí znovu sestavit ani přepsat.

První skutečný `Quick` běh `.godot/automation/20260821-175834Z` prošel s `MVP_TESTS_PASSED=1308`. Výchozí `Full` běh `.godot/automation/20260821-175920Z` prošel všech pět kroků a skončil `AUTOMATION_TECHNICAL_GATE=PASSED` a `HOW_TO_GROW_AUTOMATION=PASSED`. Přesná validation `.godot/validation/20260821-175920Z` má capture/visuals/full `PASSED`; performance `.godot/performance/20260821-180048Z` naměřilo CPU p95 max. 9,334 ms, frame p95 max. 16,695 ms, 449 draw calls a 85,73 MiB; endurance `.godot/endurance/20260821-180132Z` dokončilo 48/48 cyklů s konečným růstem 0 uzlů, 0 orphanů a 0 zdrojů; progression `.godot/progression/20260821-180142Z` dokončilo 132/132 cyklů a 27 roundtripů; responsive `.godot/responsive/20260821-180148Z` prošlo 8/8 případů včetně `phase109_greenhouse_360x800`. Schválené reference ani jejich tolerance nebyly změněny kvůli průchodu.

## Fáze 111 — zdrojový baseline RC36

Fáze 111 ukládá ověřený stav fází 103–110 jako jediný zdrojový commit a anotovaný tag `v0.50.0-rc36`. Před snapshotem byly zkontrolovány všechny sledované i nesledované změny, textová povaha souborů, diff whitespace, exportní identita a absence vloženého keystoru, hesla nebo generovaných APK/AAB. `.godot`, `.tooling`, `builds` a lokální tajemství zůstávají mimo Git.

Snapshot nemění runtime, ekonomiku, save schema 32, export preset ani existující APK. Autoritativní RC36 proto zůstává nedotčené a fáze 111 pouze přidává reprodukovatelný zdrojový bod pro další vývoj. Přesné validační artefakty jsou uvedené v `docs/PHASE111_SOURCE_BASELINE.md`; tehdy otevřený lidský blok následně uzavřela krátká část fáze 112 a veřejná distribuce zůstává mimo současný rozsah.

## Fáze 112 — lokální mobilní přijetí RC36

Uživatel 21. srpna 2026 jednou souhrnnou odpovědí `hotovo` potvrdil všech šest bodů `docs/PHASE112_LOCAL_MOBILE_ACCEPTANCE.md`: bezpečné zrušení pickeru a export `.htgbackup`, skutečný dotyk výběru a zálivky skleníkové plodiny, systémové Zpět a oba směry tahu, systémové povolení a doručení 20sekundového upozornění s cílem květináče 1, import s náhledem a restartem a dvoukrokovou novou hru i návrat předchozího postupu. Krátký subjektivní průchod byl ovladatelný, animace příjemná a bez nezvyklého zahřívání.

Navazující nedestruktivní audit `.godot/android-device-audit/20260821-190953Z` bez instalace a bez mazání dat znovu potvrdil přesný SHA-256 RC36, save schema `32_TO_32`, původních 66 mincí, 159 XP, 10 slotů a 0 obsazených pokojových květináčů. Měl 11/11 platných foreground vzorků, fatal count 0 a `ANDROID_TECHNICAL_GATE=PASSED`. Systém hlásil udělené `POST_NOTIFICATIONS`, tři package-scoped alarm řádky a třináct notification řádků; `phase112-final.png` zachycuje skutečné testovací oznámení v Android liště. Tato evidence doplňuje, ale nenahrazuje lidské potvrzení deep linku.

Závěrečná validace `.godot/validation/20260821-191441Z` prošla s `MVP_TESTS_PASSED=1308`, capture, visuals a full validation `PASSED`. Všech 14 aktivních pixelových gate je zelených, `room` a `locked-slots` zůstávají pouze reportovací a schválené reference, crop, masky ani tolerance se nezměnily.

Finální `Quick` `.godot/automation/20260821-191729Z` po zápisu původní krátké dokumentace prošel: regression exit 0, `MVP_TESTS_PASSED=1308`, `AUTOMATION_TECHNICAL_GATE=PASSED` a `HOW_TO_GROW_AUTOMATION=PASSED`. Po skutečném long-delay návratu prošla aktuální fáze 117 navíc úplnou validací `.godot/validation/20260822-042334Z` s 1 351/1 351 kontrolami a finálním Quick `.godot/automation/20260822-042507Z`. Obecný statický lidský checklist se automaticky nepřepisuje na PASS; autoritativní důkaz fáze 112 odděleně potvrzuje krátkou lidskou, reboot i long-delay bránu.

`PHASE112_SHORT_PHYSICAL_GATE=PASSED`. Reboot větev navíc prošla bez otevření hry: `.godot/android-long-delay/20260821-213651Z` zaznamenal `BOOT_COMPLETED`, obnovený alarm a skutečné oznámení pro květináč 1, takže `PHASE112_REBOOT_REMINDER_GATE=PASSED`. Stejná složka obsahuje `phase112-greenhouse-ready-return.png` a `greenhouse-ready-evidence.md`: po 8 h 47 min. jediný úspěšný návrat bez nové instalace, změny času nebo ADB dotykové injekce zobrazil `PŘIPRAVENO KE SKLIZNI` pro všechny čtyři záhony; sanitizovaný save potvrdil schema 32 a čtyři `READY` stavy, targeted fatal count 0. `PHASE112_LONG_DELAY_GATE=PASSED`. `PUBLISHING_GATE=OUT_OF_SCOPE_BY_USER`, takže nevzniká AAB, produkční klíč ani upload do obchodu.

## Fáze 113 — ředkvička a RC37

Fáze 113 je runtime změna navazující na RC36. Skleník má čtyři plodiny a nový chybějící krok úrovně 3: `garden_radish` / `Ředkvička zahradní` za 12 mincí, se čtyřhodinovým růstem a sklizní 22 mincí + 9 XP. Čtyři volby používají samostatné mobilní cíle; kompaktní větev 360×620 drží přesně 76×64 px na x = 16/100/184/268. Kódově kreslená ředkvička nemění zdrojové PNG.

Save schema 33 přidává samostatnou trust boundary `GREENHOUSE_RADISH_SCHEMA`. Schema 32 zachová oprávněné rajče, papriku a okurku, ale vloženou placenou ředkvičku odmítne. Doménová vrstva znovu kontroluje úroveň 3 i cenu a zamčený pokus je atomický no-op.

Regrese skončila `MVP_TESTS_PASSED=1317`. Responzivní audit `.godot/responsive/20260821-195525Z` prošel 8/8. Úplná validace `.godot/validation/20260821-195615Z` skončila capture, visuals i full validation `PASSED`; všech 14 aktivních pixelových gate je zelených a schválené reference, crop, masky ani tolerance se nezměnily. Autonomní Full `.godot/automation/20260821-200116Z` prošel všemi pěti kroky. Release `.godot/release-candidate/20260821-200404Z` vytvořil nový immutable `0.51.0-rc37` / code 54 / schema 33 o velikosti 106 195 376 B a SHA-256 `F985BA22C278B74C1AEBE8D7A878BA21B6EE11053234BA062A9A098A57C3898B`; export, podpis APK v2, payload i notification payload jsou `PASSED`. RC36 nebylo přepsáno. RC37 se na telefon neinstaluje před dokončením přirozeného RC36 long-delay důkazu. AAB, produkční signing a publikování zůstávají `OUT_OF_SCOPE_BY_USER`.

## Fáze 114 — publikační rozsah automatizace

Pracovní i release runner nyní považují publikování za explicitní opt-in. Výchozí lokální běh zapisuje `publishing_gate = OUT_OF_SCOPE_BY_USER` do JSON i Markdown reportu a emituje stejný CLI marker. Pouze parametr `-PublishingRequested` vrátí `PENDING_RELEASE_KEYSTORE_AAB_STORE_REVIEW`; sám nic nepublikuje, nevytváří AAB a nečte signing tajemství.

PowerShell AST obou runnerů prošel. Quick `.godot/automation/20260821-202456Z` ověřil výchozí větev a `MVP_TESTS_PASSED=1321`; Quick `.godot/automation/20260821-202538Z` ověřil opt-in větev se stejnými 1 321 kontrolami. Fáze mění pouze nástroje, testy a dokumentaci, takže runtime, save schema 33, immutable RC37 i nainstalované RC36 zůstávají beze změny.

## Fáze 115 — lilek a RC38

Fáze 115 rozšiřuje skleník o pátou plodinu `garden_eggplant` / `Lilek vejcoplodý`. Odemkne se na úrovni 5, stojí 22 mincí, po zálivce roste 12 hodin a sklizeň dává 60 mincí + 18 XP. Kompaktní obsah 360×620 používá pět samostatných voleb 64×64 px s x = 16/82/148/214/280. Kódově kreslený lilek nemění zdrojové PNG.

Save schema 34 přidává `GREENHOUSE_EGGPLANT_SCHEMA`. Schema 33 zachová rajče, papriku, ředkvičku i okurku, ale podvržený placený lilek odmítne. Doménová výsadba ověřuje úroveň i cenu a zamčený pokus zůstává atomický no-op.

Úplná validace `.godot/validation/20260821-210729Z` prošla s `MVP_TESTS_PASSED=1330`, capture, visuals i full validation `PASSED`; všech 14 aktivních pixelových bran zůstalo zelených bez změny schválených referencí, cropů, masek nebo tolerancí. Release audit `.godot/release-candidate/20260821-210729Z` navíc prošel performance s CPU p95 max. 15,246 ms, endurance 48/48 s nulovým růstem uzlů/orphanů/zdrojů, progression 132/132 a 27 save roundtripy, responsive 8/8, Android exportem, APK v2 podpisem, payloadem i notification payloadem.

Immutable RC38 `0.52.0-rc38` / code 55 / schema 34 má 106 197 360 B a SHA-256 `939E3E931DC32CD527A0207106DA2C1EDE3A9BD9B63F1F9718D40CB322FB3E0D`. RC36 i RC37 si zachovaly své původní velikosti a SHA-256. RC38 nebylo instalováno, aby nepřerušilo přirozený RC36 long-delay důkaz; device gate je `NOT_REQUESTED` a publikování `OUT_OF_SCOPE_BY_USER`.

## Fáze 116 — skleníkové zakázky a RC39

Fáze 116 přidává jednu trvalou skleníkovou zakázku bez denního timeoutu. Odpovídající sklizeň posune postup a poslední požadovaná sklizeň atomicky přidá kanonický bonus; jiná plodina dostane pouze svou běžnou odměnu. Rotace nabízí jen plodiny skutečně odemčené hráčovou úrovní a nevytváří druhý inventář ani nový modal.

Save schema 35 přidává `GREENHOUSE_ORDER_SCHEMA`. Schema 34 zahodí vložený postup, rotaci, počet dokončení i bonus. Schema 35 přijme jen známou odemčenou plodinu a nedokončený postup, zatímco zákazníka, cíl a odměnu vždy znovu sestaví z kanonického katalogu. UI refresh, načtení, zálivka ani plynutí času odměnu nevytvářejí.

Quick `.godot/automation/20260821-213450Z` prošel s `MVP_TESTS_PASSED=1342`. Úplná validation `.godot/validation/20260821-213535Z` skončila capture, visuals i full validation `PASSED` a zachovala všech 14 aktivních pixelových bran i jejich reference a tolerance. Full `.godot/automation/20260821-213725Z` prošel validation, performance, endurance, progression i responsive: CPU p95 max. 10,091 ms, endurance 48/48 bez růstu uzlů/orphanů/zdrojů, progression 132/132 s 27 roundtripy a responsive 8/8. `comic-greenhouse-order-ready.png` je pouze reportovací.

Release `.godot/release-candidate/20260821-214027Z` vytvořil immutable RC39 `0.53.0-rc39` / code 56 / schema 35 o velikosti 106 203 248 B a SHA-256 `3F110A4E187C9AFE0034D149E6E47B7B2C7B643CE2DDDA3F5ACD7701F83F3C78`. Export, podpis APK v2, payload i notification payload jsou `PASSED`; alias je bajtově shodný. RC36–RC38 zůstaly hashově beze změny. RC39 nebylo instalováno, device gate je `NOT_REQUESTED` a publikování `OUT_OF_SCOPE_BY_USER`.

## Fáze 117 — prémiové vícezáhonové zakázky a RC40

Fáze 117 přidává kanonickou variantu `multi_bed` každé druhé dvousklizňové skleníkové nabídky. Odpovídající sklizně musí pocházet ze dvou různých záhonů. Opakovaná sklizeň již započteného záhonu dál dává běžnou odměnu plodiny, ale prémiový postup neposune. Varianta nemá timeout, nevytváří novou měnu ani inventář a proti standardu přidává přesně 8 mincí a 4 XP.

Save schema 36 přidává `GREENHOUSE_QUALITY_ORDER_SCHEMA`. Schema 35 nemůže vložit prémiový typ, vyšší odměnu ani seznam záhonů. Schema 36 povolí `multi_bed` jen na deterministicky způsobilé sekvenci, indexy deduplikuje a omezí na čtyři záhony a postup odvodí pouze z autorizovaného seznamu. Cíl, zákazník i bonusy se vždy kanonizují.

Finální validation `.godot/validation/20260822-042334Z` prošla s `MVP_TESTS_PASSED=1351`, capture, visuals i full validation `PASSED` a zachovala všech 14 aktivních pixelových bran. Full `.godot/automation/20260822-040627Z` prošel validation, performance, endurance, progression i responsive: CPU p95 max. 9,164 ms, endurance 48/48 bez růstu uzlů/orphanů/zdrojů, progression 132/132 s 27 roundtripy a responsive 8/8. `comic-greenhouse-quality-order-ready.png` je pouze reportovací.

Release `.godot/release-candidate/20260822-040931Z` vytvořil immutable RC40 `0.54.0-rc40` / code 57 / schema 36 o velikosti 106 206 088 B a SHA-256 `99927E0D24B4C7DDDBF3B13B191C1ACCB8EB562C6F553B25E685113A163F0D97`. Export, podpis APK v2, payload i notification payload jsou `PASSED`; alias je bajtově shodný. RC36–RC39 zůstaly hashově beze změny. RC40 nebylo instalováno, device gate je `NOT_REQUESTED` a publikování `OUT_OF_SCOPE_BY_USER`.

## Fáze 118 — reputace skleníku a RC41

Fáze 118 přidává tři pevné reputační milníky nad `greenhouse_orders_completed`: za 3 zakázky `SPOLEHLIVÝ PĚSTITEL` + 40 mincí + 20 XP, za 8 zakázek `DODAVATEL TRHU` + 80 mincí + 40 XP a za 15 zakázek čistě kosmetický `MISTR SKLENÍKU`. Stávající pravá horní cedule ukazuje postup k dalšímu milníku a po maximu mistrovský titul. Nevznikla nová měna, časovač, modal ani tlačítko.

Save schema 37 přidává `GREENHOUSE_REPUTATION_SCHEMA`. Uložený claimed tier je auditní stopa, zatímco autoritou je počet dokončených skleníkových zakázek. Schema 36 získá při migraci odpovídající titul bez zpětných mincí nebo XP; hostilní schema 37 nemůže vyšším tierem přeskočit počet ani odměnu. Živá odměna vzniká pouze při překročení hranice dokončením nové zakázky a round-trip ji neopakuje.

Validace `.godot/validation/20260822-045354Z` prošla s `MVP_TESTS_PASSED=1360`, capture, visuals i full validation `PASSED`; všech 14 aktivních pixelových bran zůstalo zelených a nové snímky reputace jsou report-only. Full `.godot/automation/20260822-045548Z` prošel validation, performance, endurance 48/48, progression 132/132 s 27 roundtripy a responsive 8/8. Schválené reference, crop, masky a tolerance se nezměnily.

Release `.godot/release-candidate/20260822-045830Z` vytvořil immutable RC41 `0.55.0-rc41` / code 58 / schema 37 o velikosti 106 209 964 B a SHA-256 `A8E14970A5A6F09B67493B34DE701D2E9ACC8496617D2453B93DD7690159D6AE`. Export, podpis APK v2, payload i notification payload jsou `PASSED`; alias je bajtově shodný. Hashy RC36–RC40 zůstaly beze změny. RC41 nebylo instalováno, device gate je `NOT_REQUESTED` a publikování `OUT_OF_SCOPE_BY_USER`.

## Fáze 119 — globální swipe a RC43

Fáze 119 sjednocuje vodorovnou navigaci přes čtyři hlavní obrazovky `Rostliny ↔ Sklad ↔ Obchod ↔ Měření`. Tah může začít i uvnitř svislého seznamu. Po 18 px se uzamkne zřetelná osa; vodorovná událost se zpracuje jen navigací, svislá zůstane ScrollContaineru a nejasná diagonála nic neprovede. Samotné přepnutí vyžaduje 90 px a převahu 1,3×, krajní obrazovky se neobtáčejí. Modro-zlatý přechod a cílový lesk záložky sledují fyzický směr prstu, klikací odezva zůstává beze změny.

Globální swipe je aktivní pouze na čtyřech top-level površích. Vypíná se přes blokující modaly, onboarding, systémový picker, skleník, hráčský pokoj a detail rostliny. Přechod na Rostliny vždy otevře stojan. Fáze nemění save payload, schema 37, ekonomiku, růst ani obsah skleníku.

Finální validation `.godot/validation/20260822-054057Z` prošla s `MVP_TESTS_PASSED=1370`, capture, visuals i všemi 14 aktivními pixelovými branami. Dva směrové snímky jsou report-only a schválené reference, crop, masky i tolerance se nezměnily. Release `.godot/release-candidate/20260822-054242Z` prošel výkonem (CPU p95 max. 11,940 ms, frame p95 16,768 ms, 449 draw calls, 86,12 MiB), endurance 48/48 se 7 roundtripy a nulovým růstem uzlů/orphanů/zdrojů, progression 132/132 s 27 roundtripy, responsive 8/8, exportem, podpisem APK v2 a payloadem.

Finální immutable RC43 `0.56.0-rc43` / code 60 / schema 37 má 106 213 160 B a SHA-256 `8D890542F3C49274225E5847E64C503E7E529DEAF5C8252717EC1AAC6E4990F8`. Mezilehlé RC42 `0.56.0-rc42` / code 59 má 106 212 556 B a SHA-256 `D0873803DFD5854BE0E3DB2B992A81B2C527422BC1E11D31B7B4887D0A985885`; nebylo přepsáno. Hashy RC36–RC41 zůstaly beze změny. RC42 ani RC43 nebyly instalovány, device gate je `NOT_REQUESTED` a publikování `OUT_OF_SCOPE_BY_USER`.

## Fáze 120 — živý perspektivní skleník a RC45

Fáze 120 převádí technický skleníkový náhled na originální živé prostředí se čtyřmi vyvýšenými dřevěnými záhony. Bitmapové pozadí neobsahuje text, tlačítka, HUD ani záhony; interaktivní stav zůstává plně v Godotu. Po uživatelském připomínkování používá kompaktní 360×620 geometrie menší zadní dvojici 145×96 px a větší přední dvojici 162×128 px; běžná 432×780 geometrie používá 178×144 px vzadu a 196×200 px vpředu. Zadní řada je užší a výš, přední širší a níž, takže sledují perspektivu podlahy. Zálivka, růst, připravená sklizeň, výběr, zakázky, reputace i pět osiv zůstávají čitelné a funkční. Pauza a reduced-motion zastaví ambientní pohyb.

Save schema zůstává 37 a ekonomika, plodiny i odměny se nemění. Finální validation `.godot/validation/20260822-102541Z` prošla s `MVP_TESTS_PASSED=1374`, capture, visuals i všemi 14 aktivními pixelovými branami bez změny schválených referencí, cropů, masek nebo tolerancí. Release `.godot/release-candidate/20260822-102540Z` prošel výkonem (CPU p95 max. 12,643 ms, frame p95 16,700 ms, 449 draw calls, 86,16 MiB), endurance 48/48 se sedmi roundtripy a nulovým růstem uzlů/orphanů/zdrojů, progression 132/132 s 27 roundtripy, responsive 8/8, exportem, podpisem APK v2 a payloadem.

Finální immutable RC45 `0.57.0-rc45` / code 62 / schema 37 má 108 222 968 B a SHA-256 `F58C6A79965B9DB77ACEF7338050CA46D444E0882DB56C531F6133D072F425A0`. Alias je bajtově shodný; RC44 zůstalo immutable s původním SHA-256 `3C72EE3261DB5E23BB0B16EEB71C7FC95827028CF0923A62388A61D12CF7C850`. Telefon nebyl dostupný, proto je lokální technická část `PASSED`, instalační device gate `PENDING_DEVICE_CONNECTION` a lidské potvrzení dotyku, čitelnosti, prostorového dojmu a pocitu z animací zůstává oddělené. Publikování je `OUT_OF_SCOPE_BY_USER`.

Následná recovery validation `.godot/validation/20260822-104207Z` obnovila současné validační pokrytí po odstranění 13 necitovaných meziběhů a jednoho prázdného failed-release adresáře. Vytvořila 215 souborů o 209 277 613 B, prošla 1 374 testy, capture, visuals i všemi 14 aktivními branami; finální skleníkový PNG je bajtově shodný s release validací. Historické časové značky nebyly uměle rekonstruovány a autoritativní RC45 release evidence zůstává `.godot/validation/20260822-102541Z` plus `.godot/release-candidate/20260822-102540Z`.

## Fáze 121 — vodorovná ochrana transakcí a RC46

Fyzický audit RC45 odhalil, že vodorovný tah zahájený nad nákupním tlačítkem může přepnout hlavní obrazovku a zároveň dokončit nákup. Fáze 121 zavedla společnou ochrannou callback vrstvu a podržela potlačení akce přes release téhož gesta. RC46 `0.58.0-rc46` / code 63 / schema 37 má 108 222 272 B a SHA-256 `1266E897FD8D0CDB23BD1F2FC27F1B19894BAD92989060A4EAB2C7412ED7F1C5`; cílený vodorovný retest prošel.

Svislý scroll přes katalog však následně nechtěně koupil `grow_lamp`, proto je fáze 121 pravdivě historický částečný PASS a vertikální větev přešla do fáze 122. Diagnosticky změněný save byl přesně opraven bez odinstalace a raw save neopustil telefon. RC45 i RC46 zůstávají immutable.

## Fáze 122 — svislá ochrana transakcí a RC47

Ochrana nyní potlačí akční tlačítka při každé jednoznačně uzamčené ose až do odloženého uvolnění po release. Vodorovný tah dál naviguje, svislý zůstává `ScrollContaineru` a následující samostatný tap se znovu propustí. Generační pojistka odděluje po sobě jdoucí dotyky. Integrační regrese používá skutečné tlačítko `grow_lamp`, dostatečný zůstatek a ověřuje drag, release i následný tap.

Úplná validace `.godot/validation/20260822-115223Z` prošla s `MVP_TESTS_PASSED=1377`, capture, visuals, full validation a 14/14 aktivními obrazovými branami. Release `.godot/release-candidate/20260822-120356Z` a automatizace `.godot/automation/20260822-120356Z` prošly výkonem, endurance 48/48, progression 132/132 s 27 roundtripy, responsive 8/8, exportem, podpisem a payloadem. Závěrečný Quick po uzavření dokumentace `.godot/automation/20260822-122741Z` znovu prošel 1 377 kontrolami a technickou bránou. Immutable RC47 `0.59.0-rc47` / code 64 / schema 37 má 108 222 588 B a SHA-256 `3BC47AB155065EDE0E0AECB246026E62A324B4B25CDF5BAF76FD117AA5FCDC7F`.

Audit `.godot/android-device-audit/20260822-120721Z` potvrdil přesný nainstalovaný hash, 22 platných vzorků během 120 sekund, 100 % času v popředí, 0 fatálních nálezů a schema 37 → 37. Původně chybné svislé gesto nezměnilo stav ihned ani po 20 sekundách; prošel opačný svislý směr, vodorovný tah přes Pažitku i systémové Zpět. Konečný autorizovaný stav zůstal 73 mincí, 206 XP, lampa úrovně 1, 2 semínka Bazalky, 0 semínek Pažitky a 10 rostlinných pozic. `PHASE122_VERTICAL_SCROLL_TRANSACTION_GUARD=PASSED`, technický Android stav je `PASSED_TECHNICAL`, subjektivní lidské potvrzení `PENDING_SINGLE_HUMAN_BATCH` a publikování `OUT_OF_SCOPE_BY_USER`.

## Fáze 123 — sbírkový hráčský pokoj a RC48

Hráčský pokoj nově obsahuje osm menších neumírajících pokojovek na samostatném stojanu, šest pevných dekorací a šest prázdných pozic budoucí vitríny úspěchů. Všechny předměty jsou čistě kosmetické a používají stávající mince; nákup je jednorázový, přesun zdarma a odstranění bez refundace. Popínavka fyzicky vychází z vlastního květináče a její šlahoun se kreslí za ostatními rostlinami. Bitmapové pozadí neobsahuje herní stav ani UI.

Save schema 38 a `ROOM_COLLECTION_SCHEMA` oddělují nových čtrnáct kategoriálních míst od historického schema 29. Migrace schema 29–37 zachová pouze oprávněné staré nákupy a přemapuje jejich univerzální pozice na první kompatibilní polici nebo stojan; neznámé položky, duplicity a nekompatibilní indexy se zahodí bez změny mincí.

Úplná validace `.godot/validation/20260822-132344Z` prošla s `MVP_TESTS_PASSED=1378`, capture, visuals a `HOW_TO_GROW_VALIDATION=PASSED`; všech 14 aktivních obrazových bran zůstalo zelených bez změny referencí, cropů, masek nebo tolerancí. Nové snímky pokoje jsou report-only a finální `comic-player-room-collection.png` byl vizuálně zkontrolovaný. První Release běh bezpečně skončil před exportem na příliš malém dotykovém cíli kompaktního formátu; cíle byly zvětšeny na 64 × 64 px a cílený responsive retest `.godot/responsive/20260822-133558Z` následně prošel 8/8.

Finální Release automatizace `.godot/automation/20260822-133618Z` a kandidát `.godot/release-candidate/20260822-133618Z` prošly. Performance skončilo s CPU p95 nejvýše 12,114 ms, frame p95 nejvýše 16,746 ms, 449 draw calls a 86,52 MiB; endurance dokončilo 48/48 cyklů, 7 roundtripů a nulový růst uzlů/orphanů/zdrojů; progression dokončilo 132/132 cyklů s 27 roundtripy; finální responsive matice prošla 8/8. Export, podpis APK v2, entry scan, runtime payload i notification payload jsou `PASSED`.

Immutable RC48 `0.60.0-rc48` / code 65 / schema 38 má 110 185 562 B (105,08 MiB) a SHA-256 `D28E3D33AC95B14F8B79067C3F90C639833A25A9F133EF3BDBB41E36BB936F58`. Přepisovatelný alias je hashově shodný; RC45, RC46 a RC47 zůstaly nedotčené. RC48 zatím nebylo instalováno, takže device gate je `NOT_REQUESTED`, poslední nainstalovaný artefakt je RC47 a lidské potvrzení pocitu z dotyku i čitelnosti nového pokoje zůstává `PENDING_SINGLE_HUMAN_BATCH`. Publikování je `OUT_OF_SCOPE_BY_USER`.

## Fáze 124 — živý pokoj a budoucí mazlíček

Pokoj přidává jednorázově kupovatelné sklenice se sušenými bylinkami za 24 mincí a kočičí kout za 54 mincí. Koutek obsahuje pelíšek, vodu a krmivo na podlaze u koberce a připravuje jediný budoucí pet spot, ale nevytváří neexistující kočku, péči, spotřební zásoby ani bonusy. Mrak, pták a motýl za oknem oživují interiér a při pauze nebo Méně pohybu zůstanou statické.

Save schema 39 a `ROOM_LIVING_DETAILS_SCHEMA` oddělují nové placené položky od RC48 schema 38. Starší pokoj zachová všechna legitimní data fáze 123, ale nemůže vložit dvě pozdější ID. Regrese prošla 1 384/1 384 a finální obrazová validace `.godot/validation/20260822-144550Z` má capture, visuals i úplný stav `PASSED`; `comic-player-room-living.png` byl vizuálně zkontrolovaný a schválené reference, cropy, masky ani tolerance se nezměnily.

Release automatizace `.godot/automation/20260822-144818Z` a kandidát `.godot/release-candidate/20260822-144818Z` prošly výkonem (CPU p95 9,570 ms, frame p95 16,689 ms, 449 draw calls, 86,61 MiB), endurance 48/48 se sedmi roundtripy a nulovým růstem uzlů/orphanů/zdrojů, progression 132/132 s 27 roundtripy, responsive 8/8, exportem, podpisem APK v2, entry scanem i payloadem. Immutable RC49 `0.61.0-rc49` / code 66 / schema 39 má 110 188 738 B (105,08 MiB) a SHA-256 `86A1F064581BC8DD3FE8026BD4A2B7ACAAB8DED0C3E00D47FD80B9EC427CDE79`; alias je bajtově shodný a RC47/RC48 zůstaly immutable. Audit `.godot/android-device-audit/20260822-150135Z` potvrdil přesnou instalaci, 100 % času v popředí, nulové fatální nálezy a zachovaný save schema 37 → 39. Technická Android brána je `PASSED`, lidský pocit z animací zůstává `PENDING_SINGLE_HUMAN_BATCH` a publikování `OUT_OF_SCOPE_BY_USER`.

## Fáze 125 — čistý stojan a hráčské nastavení

Oprava prezentační vrstvy stojanu mapuje `HARVESTED`, `DRYING`, `DRY` a `PACKAGED` na prázdný květináč s popiskem „VE SKLADU“, zatímco `MATURE` zůstává viditelné do skutečné sklizně. Odstraněnou kartu „Bazalka · růst“ nahradil neinteraktivní dok pro budoucí doplňky a mazlíka. Péče zůstává na Rostlinách jako 68 × 68 px zelený cíl a vedle ní je stejně velké hráčské Nastavení s 48 × 48 px transparentním PNG ozubeným kolečkem. Herní ekonomika ani save data se nemění; schema zůstává 39.

Úplná validace `.godot/validation/20260822-155002Z` prošla 1 390/1 390 kontrolami, capture, visuals i full stavem `PASSED`; všech 14 aktivních obrazových bran je zelených. Nový report-only `comic-rack-post-harvest.png` dokládá současně sklizený a sušený slot bez rostliny. Dvě historické efektové brány izolují záměrně změněný spodní 10% dok maskou; schválené reference, cropy a tolerance zůstaly beze změny. Responsive audit prošel 8/8 a kontroluje velikost, hranice i nulové kolize obou launcherů a PNG ikony.

Release automatizace `.godot/automation/20260822-155609Z` a kandidát `.godot/release-candidate/20260822-155610Z` prošly. Performance skončilo s CPU p95 nejvýše 14,567 ms, frame p95 16,710 ms, 476 draw calls a 86,57 MiB; endurance dokončilo 48/48 cyklů, sedm roundtripů a nulový růst uzlů/orphanů/zdrojů; progression dokončilo 132/132 cyklů s 27 roundtripy; responsive prošlo 8/8. Export, podpis APK v2, entry scan, runtime payload i notification payload jsou `PASSED`.

Závěrečný Quick po dokumentaci `.godot/automation/20260822-160608Z` znovu prošel regression krokem, skončil `AUTOMATION_TECHNICAL_GATE=PASSED` a `HOW_TO_GROW_AUTOMATION=PASSED` a správně ponechal `AUTOMATION_MANUAL_GATE=PENDING_SINGLE_HUMAN_BATCH`.

Immutable RC50 `0.62.0-rc50` / code 67 / schema 39 má 110 260 465 B a SHA-256 `C7227D3FC8ACE61CEB214EF1F83B4BAEE3BE5402F564D013E8031D49CEAFE14D`. Přepisovatelný alias je bajtově shodný a RC49 zůstal nedotčený. Fyzický audit `.godot/android-device-audit/20260822-162951Z` nainstaloval přesně tento artefakt bez mazání dat a potvrdil shodný hash, 11 platných runtime vzorků, 100 % času v popředí, nulové fatální nálezy a save schema 39 → 39. Sanitizovaný snímek `phase125-rc50-installed.png` dokládá skutečné spuštění na Xiaomi 2201116SG. Technická Android brána je `PASSED`; lidské vizuální potvrzení zůstává `PENDING_SINGLE_HUMAN_BATCH` a publikování `OUT_OF_SCOPE_BY_USER`.

## Fáze 126 — sjednocená vizuální kamera zahrady

Stojan, hráčský pokoj a skleník sdílejí `phase126_garden_visual_camera_v1` s referenčním obsahem 432 × 780, společným cover-cropem, titulním pásem a měřitelnými cíli obsazenosti. Pokoj používá nový blízký asset 887 × 1774, dvě rostliny na čtyřech policích, šest pozic úspěchů a zdrojové kotvy osmi pevných dekorací. Transparentní cíle zůstávají nejméně 64 px a na 360 × 800 jsou omezené dovnitř povrchu. Původní phase123 PNG zůstalo bajtově nedotčené.

Finální validace `.godot/validation/20260822-171510Z` skončila `MVP_TESTS_PASSED=1394`, capture, visuals a full `PASSED`. Všech 14 aktivních obrazových bran prošlo bez změny schválených referencí, cropů, masek nebo tolerancí; nový pokoj zůstává report-only do lidského potvrzení. Responsive `.godot/responsive/20260822-171752Z` prošlo 9/9 včetně samostatného pokoje 360 × 800.

Release automatizace `.godot/automation/20260822-171509Z` a kandidát `.godot/release-candidate/20260822-171510Z` prošly. Performance `.godot/performance/20260822-171652Z` má CPU p95 10,187 ms, frame p95 16,738 ms, nejvýše 476 draw calls a 86,65 MiB. Endurance `.godot/endurance/20260822-171736Z` dokončilo 48/48 cyklů, sedm roundtripů a nulový růst uzlů, orphanů i zdrojů. Progression `.godot/progression/20260822-171747Z` dokončilo 132/132 cyklů všech jedenácti druhů a 27 save/load roundtripů. Export, podpis APK v2, entry scan, runtime payload i notification payload jsou `PASSED`.

Immutable RC51 `0.63.0-rc51` / code 68 / schema 39 má 111 812 793 B a SHA-256 `6B48C70E4A80B369E83EF50121760A1F598088D933F1CE499EFD73B17211410F`; alias je bajtově shodný. RC50 má stále původní SHA-256 `C7227D3FC8ACE61CEB214EF1F83B4BAEE3BE5402F564D013E8031D49CEAFE14D` a zůstává immutable jako historický kandidát. RC51 bylo nainstalováno přes předchozí build a fyzický technický audit `.godot/android-device-audit/20260822-172854Z` potvrdil přesnou identitu APK, zachování save, schema `39_TO_39`, 11/11 platných foreground vzorků a nulový fatal count. Lokální i fyzická technická brána jsou `PASSED`; lidské hodnocení `PENDING_SINGLE_HUMAN_BATCH` a publikování `OUT_OF_SCOPE_BY_USER`.

## Fáze 127 — finální vizuální systém a RC53

Autoritativní kontrakt `phase127_final_visual_system_v1` sjednocuje paletu, typografii, spacing, vrstvy, šest rodin assetů a tři scénové profily pro stojan, pokoj a skleník. Každý živý pokojový nebo skleníkový prvek má explicitní rozměr, pivot, vrstvu a případný bezpečný výřez; ostatní PNG musí projít adresářovým rodinným profilem. Quick a release proto nejprve spouštějí `tools/run_visual_contract_audit.ps1` a zastaví se při neznámém nebo chybějícím assetu.

Quick `.godot/automation/20260822-193623Z` potvrdil 32 explicitních profilů, 241/241 klasifikovaných PNG, 0 neprofilovaných a `MVP_TESTS_PASSED=1400`. Úplná validation `.godot/validation/20260822-193736Z` prošla capture, visuals, full stavem i všemi 14 schválenými obrazovými branami bez přepsání jejich referencí, cropů, masek nebo tolerancí. Nové pokojové a skleníkové důkazy jsou report-only a byly zkontrolovány v plném i 360 × 800 formátu.

Release automatizace `.godot/automation/20260822-193733Z` a kandidát `.godot/release-candidate/20260822-193734Z` prošly. Performance skončilo s CPU p95 9,631 ms, frame p95 16,699 ms, nejvýše 476 draw calls a 86,94 MiB; endurance dokončilo 48/48 cyklů bez růstu uzlů, orphanů nebo zdrojů; progression dokončilo 132/132 cyklů a 27 roundtripů; responsive prošlo 9/9. Export, podpis APK v2, entry scan, runtime payload i notification payload jsou `PASSED`.

Immutable RC53 `0.64.0-rc53` / code 70 / schema 39 má 119 704 601 B a SHA-256 `1224BFB7BF54CBFA866E99914A9D19ADADB712FDDB1C1DE9477608B964104131`; alias je bajtově shodný. Immutable RC52 má dál 119 704 397 B a SHA-256 `3381B58B82D6F1BA223AE99120825BDC342F218837B54C7AC3BE9EBBF8EC1B35`. Nedestruktivní audit `.godot/android-device-audit/20260822-194103Z` potvrdil nainstalovanou verzi RC53/code 70, shodný hash, save schema `39_TO_39`, 11/11 foreground vzorků a nulový crash/ANR nález. Technická lokální i fyzická brána je `PASSED`; lidská čitelnost, dotyk a subjektivní vzhled zůstávají `PENDING_SINGLE_HUMAN_BATCH`, publikování `OUT_OF_SCOPE_BY_USER`.

## Fáze 130–131 — dva skleníkové boxy a živý botanický master

Skleník používá nový verzovaný podklad `greenhouse_interior_phase130_two_boxes_v1.png` se dvěma fyzickými vyvýšenými boxy a čtyřmi samostatnými funkčními částmi. Zdrojové souřadnice zeminy, plodin i dotykových zón se mapují stejným cover-camera kontraktem jako pozadí; čtyři samostatné truhlíkové sprity a cedulky už runtime nekreslí. Původní Phase 120 asset zůstává 887 × 1774 a SHA-256 `83C8A58CB3B775DDCB67F3B9A62F6ABD2FCF2EE128DB656D8431404DAB03372B`; nový sourozenec má stejné rozměry a SHA-256 `1CD27B4F32B1C7039FDD3CF2CC8903963F01D44A77DBD223BAC85EDE06DF9321`.

Výtvarný kontrakt `phase131_living_botanical_master_v1` používá jako autoritativní referenci `measurement_corner_backdrop_v1.png` s SHA-256 `FF3E920E8CC432240EBE9C0620E570A12B7E19AAFAAFB5FAED7A817E849DD0F5`. Audit `.godot/visual-contract/20260823-072707Z` potvrdil 246/246 klasifikovaných PNG, 0 neprofilovaných a všech 122 PNG odkazovaných runtime zdroji v master profilu.

Finální validation `.godot/validation/20260823-073335Z` prošla s `MVP_TESTS_PASSED=1414`, capture, všemi aktivními vizuálními branami a `HOW_TO_GROW_VALIDATION=PASSED`. Responzivní audit `.godot/responsive/20260823-073241Z` prošel 9/9 včetně 360 × 800 Skleníku; všechny čtyři části mají nejméně 64 px, patří do správného boxu a neprotínají spodní stavovou kartu. Report-only `comic-phase130-greenhouse-two-boxes.png` byl vizuálně zkontrolovaný v běžném i kompaktním řezu.

Jde o source-only vývoj nad immutable RC53: nový APK ani AAB nevznikl, telefon nebyl měněn, save schema zůstává 39 a publikování je `OUT_OF_SCOPE_BY_USER`. Uživatel schválil výtvarný směr; fyzická čitelnost a dotyk nové verze na telefonu zůstávají `PENDING` do budoucího release/device průchodu.

## Fáze 132 — živý botanický Pokoj

Pokoj používá nový verzovaný podklad `player_room_interior_phase132_living_v1.png` o rozměrech 887 × 1774 px a SHA-256 `ED59856A43EF174F3D85D8D04FAC409E841E984A89D19C9C1F43933BB7D11E69`. Navazuje na uživatelem přijatý Skleník a master `phase131_living_botanical_master_v1`: zachovává čtyři police se dvěma rostlinnými místy, šest úspěchových pozic, osm pevných dekorativních míst a budoucí kočičí kout, ale přidává výraznější hloubku, živější okno, čistší materiálové stíny a tyrkysové kovové akcenty. Runtime obsah zůstává samostatný; nový podklad neobsahuje zapečené rostliny, dekorace, úspěchy, mazlíčka, sloty, text ani UI.

Předchozí `player_room_interior_phase128_v2.png` zůstalo beze změny se SHA-256 `E3B33900A2BD6F432A403498B636F4955C3749F2C6E3B5A7743FFEDB9E81DFE`. Obrazovka Rostliny, `scripts/main.gd`, ekonomika dekorací, save schema 39 a všechny transakce zůstaly nedotčené.

Úplná validace `.godot/validation/20260823-080628Z` prošla s `MVP_TESTS_PASSED=1418`, capture, všemi aktivními vizuálními branami a `HOW_TO_GROW_VALIDATION=PASSED`. Responzivní audit `.godot/responsive/20260823-080548Z` prošel 9/9 včetně samostatného 360 × 800 Pokoje; všech šestnáct dotykových cílů zůstává nejméně 64 × 64 px a uvnitř scénové plochy. Report-only `comic-phase132-player-room.png` byl zkontrolovaný v plném i kompaktním řezu. Závěrečná Quick automatizace `.godot/automation/20260823-081006Z` prošla visual contractem i regresí; audit `.godot/visual-contract/20260823-081007Z` potvrdil 247 profilovaných PNG, 0 neprofilovaných a všech 122 runtime PNG v master profilu.

Fáze 132 je source-only: immutable RC53, nainstalovaná APK i telefon zůstaly beze změny. Technický lokální stav je `PASSED`; fyzická čitelnost a dotyk Phase 132 na telefonu jsou `PENDING`, publikování zůstává `OUT_OF_SCOPE_BY_USER`.

## Fáze 133 — tři pokojové rostliny na polici

Zdrojový Pokoj nyní používá 12 rostlinných slotů v přesné mřížce 3 × 4 a zachovává osm pevných dekorativních pozic. Každý rostlinný slot vykreslí profilovanou podmisku `room_plant_saucer_v1.png` přímo na polici a teprve nad ní menší květináč s vegetací. Obrazovka Rostliny, osm existujících kosmetických ID, jejich ceny, pet kontrakt i všechny herní bonusy zůstávají beze změny.

Save schema 40 zavádí `ROOM_THREE_PER_SHELF_SCHEMA`. Explicitní mapa schema 38–39 zachová původní levé a pravé rostliny na stejných policích, nové prostřední sloty nechá prázdné a pevné dekorace přesune z 8–15 na 12–19. Immutable RC53 `0.64.0-rc53` / code 70 / schema 39 a nainstalovaná APK zůstávají autoritativním vydaným artefaktem; nový APK zatím nevzniká.

Úplná validace `.godot/validation/20260823-084346Z` prošla s `MVP_TESTS_PASSED=1424`, capture, visuals i full stavem `PASSED`; schválené reference, cropy, masky a tolerance zůstaly beze změny. Responsive audit `.godot/responsive/20260823-083747Z` prošel 9/9 a vizuální kontrakt `.godot/visual-contract/20260823-084558Z` potvrdil 248 profilovaných PNG, 0 neprofilovaných a 123 runtime PNG v master profilu. Report-only `comic-phase133-player-room-shelf-plants.png` byl zkontrolovaný v plném záběru. Quick `.godot/automation/20260823-084635Z` skončil `AUTOMATION_TECHNICAL_GATE=PASSED` a `HOW_TO_GROW_AUTOMATION=PASSED`. Lokální technická část je tedy `PASSED`; lidská mobilní čitelnost a dotyk zůstávají `PENDING_SINGLE_HUMAN_BATCH`, device gate nebyla vyžádaná a publikování je `OUT_OF_SCOPE_BY_USER`.

## Fáze 134 — realistické zaplnění pokojového stojanu

Zdrojový Pokoj zachovává mřížku 3 × 4 i save schema 40, ale rostliny už nepoužívají jeden malý univerzální profil. Každý druh se vejde do 64px sloupce a řádkových výšek 80 / 70 / 68 / 58 px, takže horní police působí plněji a prostřední ani spodní rostliny nepřerůstají přes polici nad sebou. Podmiska má vyvážených 50 × 18 px a skládá se jako kontaktní stín, zadní keramika, teple modulovaná rostlina a přední lem. Zdrojové Phase 127 PNG zůstávají immutable; odpojené horní slivery řeší pouze runtime UV výřez.

Úplná validace `.godot/validation/20260823-091213Z` prošla s `MVP_TESTS_PASSED=1429`, capture, visuals i full stavem `PASSED`. Responsive `.godot/responsive/20260823-091152Z` má 9/9, visual contract `.godot/visual-contract/20260823-091431Z` má 248 profilovaných PNG, 0 neprofilovaných a 123 runtime PNG a Quick `.godot/automation/20260823-091456Z` skončil `AUTOMATION_TECHNICAL_GATE=PASSED`. Report-only `comic-phase134-player-room-shelf-fit.png` byl ručně zkontrolovaný v plném záběru. Lokální technická část je `PASSED`; nový APK nevznikl, fyzická a lidská mobilní brána je `PENDING_SINGLE_HUMAN_BATCH` a publikování zůstává `OUT_OF_SCOPE_BY_USER`.

## Fáze 135 — referenční překreslení stojanu a pokojovek

Aktivní Pokoj nyní používá nový verzovaný podklad `player_room_interior_phase135_reference_regraph_v1.png` se čtyřmi čistými dřevěnými policemi. Osm druhů pokojovek bylo překresleno do osmi samostatných RGBA; každý sprite obsahuje vlastní květináč, odpovídající podmisku, připojené uzemnění a jednotné teplé světlo zleva nahoře. Starší univerzální podmiska i všechny zdrojové Phase 127/132 PNG zůstaly bajtově zachované, ale aktivní kreslení už nevytváří dvojitou podmisku.

Funkční kontrakt se nemění: 12 dynamických nákupních a přesouvatelných slotů zůstává v mřížce 3 × 4, osm pevných dekorativních míst i šest budoucích úspěchů zůstává aktivních, pokojové rostliny neumírají a neposkytují herní bonus. Save schema zůstává 40, obrazovka Rostliny je beze změny a immutable RC53 ani nainstalovaná APK nebyly přepsány.

Úplná validace `.godot/validation/20260823-101228Z` prošla s `MVP_TESTS_PASSED=1433`, capture, visuals i full stavem `PASSED`. Report-only `comic-phase135-player-room-reference-regraph.png` byl ručně zkontrolovaný v plném záběru: všech 12 podmisek stojí na své polici, rostliny nepřesahují výše ani do sousedních sloupců. Quick `.godot/automation/20260823-101219Z` prošel visual contractem, validací, výkonem, endurance, progression i responsive auditem. Finální responsive `.godot/responsive/20260823-101525Z` má 9/9 a visual contract `.godot/visual-contract/20260823-101219Z` eviduje 257 profilovaných PNG, 0 neprofilovaných a 123 runtime PNG. Lokální technická brána je `PASSED`; nový APK nevznikl, fyzická a lidská mobilní brána zůstává `PENDING_SINGLE_HUMAN_BATCH` a publikování `OUT_OF_SCOPE_BY_USER`.

## Fáze 136 — výraznější pokojovky podle reference B

Uživatelská reference B určuje pouze cílový poměr viditelné rostliny vůči polici. Pokoj proto zachovává vlastní osmici druhů, tři dynamická místa na polici a čistě kosmetické chování bez růstu či umírání; nepřebírá čtyři bazalky, názvy, stavové ikony ani růstové fáze. Aktivní profily odstraňují jen změřené průhledné okraje přes bezpečný `source_uv`, zvětšují maximální šířku na 70 px a řádkové výškové obálky na 88 / 82 / 80 / 76 px. Zdrojové Phase 135 PNG zůstávají bajtově nedotčené.

Úplná validace `.godot/validation/20260823-103818Z` prošla s `MVP_TESTS_PASSED=1436`, capture, visuals i full stavem `PASSED`. Report-only `comic-phase136-player-room-shelf-prominence.png` byl ručně zkontrolovaný v plném záběru: rostliny jsou výraznější, podmisky stojí na policích, sousední sloupce se nepřekrývají a nižší patra nepřerůstají do vyšších. Responsive `.godot/responsive/20260823-103756Z` má 9/9 a visual contract `.godot/visual-contract/20260823-104042Z` eviduje 257 profilovaných PNG, 0 neprofilovaných a 123 runtime PNG. Quick `.godot/automation/20260823-104102Z` prošel visual contractem, validací, výkonem, endurance, progression i responsive auditem a skončil `HOW_TO_GROW_AUTOMATION=PASSED`. Lokální technická brána je `PASSED`; nový APK nevznikl, fyzická a lidská mobilní brána zůstává `PENDING_SINGLE_HUMAN_BATCH` a publikování `OUT_OF_SCOPE_BY_USER`.

## Fáze 137 — schválená integrovaná sada pokojovek

Pokoj používá osm nových verzovaných RGBA vytvořených podle uživatelem schváleného náhledu. Každý dynamický sprite spojuje botanicky odlišnou rostlinu, hlínu, jeden keramický květináč, o něco širší podmisku a připojený kontaktní stín. Aktivní spodní pivot fyzicky uzemňuje celý objekt na polici; mřížka zůstává funkční 3 × 4 bez textů, stavových ikon, růstových fází nebo herních bonusů. Starší Phase 135 assety ani obrazovka Rostliny nebyly přepsány.

Úplná validace `.godot/validation/20260823-113059Z` prošla s `MVP_TESTS_PASSED=1440`, capture, visuals i full stavem `PASSED`. Report-only `comic-phase137-player-room-integrated-shelf-set.png` byl ručně zkontrolovaný v plném záběru: všech 12 podmisek sedí na dřevěné ploše, sousední sloty se nepřekrývají a žádná nižší rostlina nepřerůstá do vyšší police. Responsive `.godot/responsive/20260823-113035Z` má 9/9 a visual contract `.godot/visual-contract/20260823-113321Z` eviduje 265 profilovaných PNG, 0 neprofilovaných a 123 runtime PNG. Automatizace `.godot/automation/20260823-113341Z` prošla visual contractem, validací, výkonem, endurance, progression i responsive auditem a skončila `HOW_TO_GROW_AUTOMATION=PASSED`. Lokální technická brána je `PASSED`; nový APK nevznikl, immutable RC53 i nainstalovaná APK zůstávají beze změny, fyzická a lidská mobilní brána je `PENDING_SINGLE_HUMAN_BATCH` a publikování `OUT_OF_SCOPE_BY_USER`.

## Fáze 138 — RC54 Android handoff

Aktuální projekt má identitu `0.65.0-rc54` / code 71 / save schema 40 a balí celý schválený Phase 137 pokoj. První orchestrace `.godot/automation/20260823-114827Z` bezpečně skončila před instalací na falešně zachyceném regex literálu v payload skeneru; nevytvořila immutable APK ani nezměnila telefon. Skener nyní rozlišuje kanonickou resource path od regexu a existující Phase 91 regresní kontrakt tuto opravu hlídá.

Finální orchestrace `.godot/automation/20260823-115501Z` prošla release i device krokem. Visual contract `.godot/visual-contract/20260823-115502Z` eviduje 265 profilovaných PNG, 0 neprofilovaných a 123 runtime PNG; validation `.godot/validation/20260823-115514Z` má 1 440/1 440, performance `.godot/performance/20260823-115715Z`, endurance `.godot/endurance/20260823-115759Z` 48/48, progression `.godot/progression/20260823-115811Z` 132/132 a responsive `.godot/responsive/20260823-115816Z` 9/9 jsou `PASSED`.

Immutable APK `builds/android/bazals-pocket-garden-0.65.0-rc54-arm64-debug.apk` má 150 226 188 B a SHA-256 `31373DA90973A2F131A9A5177BA8D9B958F8767B13BED5493015EC1FE19A23E5`; debug alias je bajtově shodný. Audit `.godot/android-device-audit/20260823-115900Z` potvrdil nainstalovanou identitu a hash, save schema `39_TO_40`, stabilní herní hodnoty, 11/11 platných odemčených interaktivních vzorků, 100 % času v popředí a 0 crash/ANR nálezů. Technická lokální i fyzická brána je `PASSED`; telefon se po auditu uzamkl a subjektivní vzhled po běžném odemčení zůstává `PENDING_SINGLE_HUMAN_BATCH`. Publikování je `OUT_OF_SCOPE_BY_USER`.

## Fáze 139 — sjednocená výtvarná sada Pokoje

Uživatelem schválený celý pokoj je nyní závazným zdrojem pravdy pro Pokoj: okno, vegetace, stojan, police, dřevo, kov, keramika, podmisky, stíny a světlo tvoří jednu hladkou malovanou sadu bez pixel-artu a bílých vystřižených lemů. Aktivní podklad `player_room_interior_phase139_unified_empty_v1.png` neobsahuje zapečené sbírkové rostliny. Osm dynamických RGBA používá společný canvas 591 × 887, designovou obálku 84 × 126, stejný spodní pivot a jednu geometrii nádoby i podmisky; liší se jen barvou, dekorem a botanickou siluetou. Všechny 12 slotů zůstávají nakupovatelné, odstranitelné a přesouvatelné. Nižší police ořezávají pouze listoví, nikoli keramiku.

Extrakční nástroj odstraňuje neutrální atlasové pozadí i světlý studiový stín, čistí poloprůhledné hrany a tónuje podmisku podle květináče. Kontaktní stín vzniká až v Godotu s teplou barvou police. Finální úplná validation `.godot/validation/20260823-132935Z` prošla s `MVP_TESTS_PASSED=1445`, capture, visuals i `HOW_TO_GROW_VALIDATION=PASSED`. Report-only `comic-phase139-player-room-unified-room-set.png` byl zkontrolovaný v nativním 1080 × 2400 renderu. Responsive `.godot/responsive/20260823-133225Z` má 9/9, visual contract `.godot/visual-contract/20260823-133246Z` eviduje 278 profilovaných PNG, 0 neprofilovaných a 124 runtime PNG a závěrečný Quick po dokumentaci `.godot/automation/20260823-133606Z` skončil `HOW_TO_GROW_AUTOMATION=PASSED`.

Fáze 139 je source-only: immutable RC54, nainstalovaná APK, telefon a save nebyly změněny. Technická lokální brána je `PASSED`; fyzická čitelnost, dotyk a subjektivní vzhled Phase 139 zůstávají `PENDING_SINGLE_HUMAN_BATCH`. Publikování zůstává `OUT_OF_SCOPE_BY_USER`.

## Fáze 140 — společná sada dekorací Pokoje

Pravá část Pokoje používá nové dynamické Phase 140 RGBA se stejným hladkým světlem a perspektivou jako schválené prostředí. Horní nástěnná police obsahuje knihy a tři sklenice; druhá trvale kreslená podpůrná police nese hnojiva a botanický obraz i v herním záběru, kde původní horní nábytek překrývá akční tlačítko. Komoda používá šest integrovaných prázdných držáků úspěchů a na spodní polici lampičku s vnořenými květináči. Konvička je uklizená u komody a prázdný pelíšek stojí u pravého okraje; žádný z nich nesmí blokovat koberec nebo průchod. Pelíšek výslovně neobsahuje misky, vodu, krmivo ani mazlíčka.

Implementace zachovává nákupní sloty, ekonomiku, save schema 40, Phase 139 rostliny i pozadí a nepřepisuje starší PNG. Report-only skutečný Godot render `comic-phase140-player-room-shared-decor-set.png`, úplná technická validace, uživatelské vizuální přijetí a mobilní přijetí jsou zatím `PENDING`. Immutable RC54, alias APK, telefon i hráčský save zůstávají beze změny; žádný APK se v tomto kroku nevytváří ani neinstaluje.

## Fáze 141 — finální koupitelná sada stojanu

Schválený vzhled stojanu je aktivní zdroj pravdy pro všech 12 nákupních slotů. Osm původních dekorativních pokojovek doplňují stříbrná aglaonema, růžová fitónie, citronová maranta a barevný koleus; každá vrstva obsahuje rostlinu, hlínu, stejně široký květináč, podmisku a společný kontaktní základ. Save schema 41 autorizuje nové položky, zatímco schema 40 je při načtení neumí podvrhnout. Vše zůstává čistě kosmetické a obrazovka `ROSTLINY` se nemění.

Úplná validation `.godot/validation/20260823-173713Z` prošla s 1 456/1 456 kontrolami a všemi povinnými vizuálními branami. Responsive `.godot/responsive/20260823-174052Z` má 9/9, visual contract `.godot/visual-contract/20260823-174114Z` eviduje 313 profilovaných PNG, 0 neprofilovaných a 130 runtime PNG a Quick po schválení `.godot/automation/20260823-181336Z` skončil `HOW_TO_GROW_AUTOMATION=PASSED`. Uživatel následně schválil report-only `comic-phase141-player-room-final-rack-set.png` jako finální Godot vzhled stojanu. Mobilní přijetí zůstává odděleně `PENDING`; immutable RC54, alias APK, telefon i hráčský save nebyly změněny.

## Fáze 142 — věrná referenční sada stojanu

Phase 142 superseduje pouze aktivní kresbu Phase 141, nikoli její historické schválení. Dvanáct nových transparentních vrstev bere RGB přímo z odsouhlasené předlohy `player_room_rack_approved_reference_v1.png`; prázdný obraz a segmentační maska slouží jen k oddělení popředí. Nové profily zachovávají původní rozměry, vlastní spodní pivot a přesné source-space měřítko `432 / 887`, takže keramika, podmisky, listová kresba, květy a společné osvětlení nejsou znovu interpretované.

Kontrolní recompozice všech 12 vrstev do prázdného pokoje je `.godot/phase142-reference-extraction-v3/player_room_rack_recomposed_preview_v3.png`; celková MAE proti schválenému plnému obrazu je 6,854. Runtime stále zachovává nákup jednou, bezplatné přesouvání a odstranění ve všech 12 rostlinných slotech, schema 41, Phase 140 dekorace a neměnnou obrazovku `ROSTLINY`. Úplná validation `.godot/validation/20260823-192225Z` prošla s 1 460/1 460 kontrolami, capture i visuals; responsive `.godot/responsive/20260823-192111Z` má 9/9, visual contract `.godot/visual-contract/20260823-192135Z` eviduje 329 profilovaných PNG, 0 neprofilovaných a 130 runtime PNG a závěrečný Quick `.godot/automation/20260823-192642Z` skončil `HOW_TO_GROW_AUTOMATION=PASSED`. Technická brána je `PASSED`; skutečný Godot capture čeká na výslovné uživatelské schválení a mobilní APK na samostatnou budoucí bránu. Immutable RC54 ani telefon nebyly změněny.

Phase 143 superseduje pouze aktivní rostlinné vrstvy Phase 142. Nový uživatelem schválený rack-only zdroj má hash `61EFDD17C01D02EAB5D21CE3D3E8F48A4C777558C4B02913108C9B44E7B05AB8`; deterministická extrakce zachovává jeho RGB a z oddělené masky přebírá pouze alfa kanál. Dvanáct aktivních vrstev používá stejné izotropní měřítko, čtyři společné kontaktní hrany polic a tři jednotné osy bez individuálního stretch nebo row-fit. Úplná validation `.godot/validation/20260823-201449Z` prošla s 1 464/1 464 kontrolami, capture i visuals; responsive `.godot/responsive/20260823-201723Z` má 9/9, visual contract `.godot/visual-contract/20260823-201722Z` eviduje 343 profilovaných PNG, 0 neprofilovaných a 130 runtime PNG a Quick `.godot/automation/20260823-201840Z` skončil `HOW_TO_GROW_AUTOMATION=PASSED`. Zdrojové přijetí i následně zobrazený skutečný Godot render jsou `APPROVED_BY_USER` a technická brána `PASSED`; mobilní přijetí zůstává `PENDING`. Obrazovka `ROSTLINY` nebyla změněna.

## Fáze 144 — RC55 Android candidate

Nová interní identita `0.66.0-rc55` / code 72 / save schema 41 balí schválený Phase 143 render bez změny uloženého datového kontraktu. První běh `.godot/automation/20260824-045005Z` bezpečně skončil před vytvořením immutable APK, protože payload audit našel source-only obraz z `assets/ui/visual/phase141/source/`. Android exportní profily nyní jednotně vylučují `assets/ui/visual/**/source/**`; runtime Phase 143 výřezy se dál exportují a žádný schválený zdroj se nepřepisuje.

Finální orchestrace `.godot/automation/20260824-045554Z` a release `.godot/release-candidate/20260824-045554Z` jsou `PASSED`. Validation `.godot/validation/20260824-045602Z` má 1 467/1 467, capture i visuals `PASSED`; visual contract `.godot/visual-contract/20260824-045555Z` eviduje 343 profilovaných, 0 neprofilovaných a 130 runtime PNG. Performance `.godot/performance/20260824-045800Z`, endurance `.godot/endurance/20260824-045844Z` 48/48, progression `.godot/progression/20260824-045855Z` 132/132 s 27 roundtripy a responsive `.godot/responsive/20260824-045901Z` 9/9 jsou `PASSED`. Podpis APK v2, entry scan, payload a notification payload také prošly.

Immutable `builds/android/bazals-pocket-garden-0.66.0-rc55-arm64-debug.apk` má 175 560 935 B a SHA-256 `A6F7DF58FC58DCBCFBEDF568B7B43FCF47766AFFE8BF289BE330B028B9D25ECD`; debug alias je bajtově shodný. Historické RC54 zůstalo přesně 150 226 188 B a SHA-256 `31373DA90973A2F131A9A5177BA8D9B958F8767B13BED5493015EC1FE19A23E5`. Lokální technická brána je `PASSED`; RC55 nebylo nainstalováno, zařízení je `NOT_REQUESTED`, mobilní přijetí `PENDING_SINGLE_HUMAN_BATCH` a publikování `OUT_OF_SCOPE_BY_USER`.

## Fáze 145 — vrstvené detaily Pokoje

Phase145 pokračuje pouze ve zdrojové kresbě pravé části Pokoje. Kočičí koutek
skládá měkký podlahový stín, původní hladký pelíšek a samostatnou přední RGBA
vrstvu dvou stejně velkých keramických misek. Vnořené květináče na komodě mají
vlastní kontaktní stín a jemnou přední okluzi police. Původní Phase140 assety
zůstaly hashově nezměněné, zatímco nová miska má reprodukovatelný chroma zdroj
a Godot extrakci bez zeleného halo.

Validation `.godot/validation/20260824-072859Z` je `PASSED` s 1 472/1 472,
capture i visuals. Responsive `.godot/responsive/20260824-073137Z` má 9/9 a
visual contract `.godot/visual-contract/20260824-073157Z` eviduje 345
profilovaných, 0 neprofilovaných a 131 runtime PNG. Závěrečný Quick
`.godot/automation/20260824-073738Z` skončil
`HOW_TO_GROW_AUTOMATION=PASSED`. Save schema 41, ekonomika,
Rostliny, skleník i immutable RC55 jsou beze změny. Skutečný report-only Godot
render čeká na uživatelské posouzení; telefon je nedostupný a APK nevzniklo.

## Fáze 146 — schválený celoplošný master Pokoje

Pokoj používá nový uživatelem schválený 887 × 1774 master jako společný
výtvarný základ. Architektura, čtyři police stojanu, pravé nástěnné police,
vitrína úspěchů, komoda a koberec jsou součástí prázdné desky. Dvanáct Phase
143 pokojovek zůstává samostatně koupitelných, přesouvatelných a odstranitelných.
Osm pevných dekorací kreslí jedna odvozená průhledná RGBA vrstva, takže se do
scény nevracejí obdélníkové kusy okolního pozadí. Aktivní oprava `v3` odděluje
všechny předměty v bezstínovém sprite-listu, odstraňuje zapečené šedé a černé
lemy i překryvy konvičky, pelíšku a misek a kontaktní stín kreslí samostatně až
Godot podle povrchu. Zdrojová PNG se nemění a vrstvu reprodukovatelně vytváří
`tools/extract_phase146_room_master_layer.gd`; starší v1/v2 zůstaly zachované,
ale runtime je nepoužívá.
Vnořené květináče po cílené vizuální kontrole dostaly zdrojový posun `8 px`
dolů. Godot následně znovu vykreslí úzkou přední hranu police nad jejich
spodkem, takže sestava sedí za hranou nábytku a nevypadá jako nalepený výřez;
samotný dekorativní PNG asset se nepřemaloval.
Ovládání Pokoje je seskupené vlevo nad oknem a nezakrývá knihy ani bylinkové
sklenice na horní pravé polici. Obrazovka Rostliny, skleník, ekonomika, save
schema 41 i immutable RC55 zůstávají beze změny.

Validation `.godot/validation/20260824-173415Z` je `PASSED` s 1 477/1 477,
capture i visuals. Visual contract `.godot/visual-contract/20260824-165444Z`
eviduje 353 profilovaných, 0 neprofilovaných a 133 runtime PNG. Responsive
`.godot/responsive/20260824-173637Z` prošel 9/9 a závěrečný Quick
`.godot/automation/20260824-173839Z` skončil
`HOW_TO_GROW_AUTOMATION=PASSED`. Technická lokální brána je `PASSED`.
Schválení zdrojového masteru je `APPROVED_BY_USER`, ale subjektivní přijetí
tohoto skutečného Godot renderu zůstává `PENDING`; telefon je nedostupný,
APK nevzniklo a publikování zůstává `OUT_OF_SCOPE_BY_USER`.

## Fáze 147 — schválený malovaný cartoon master

Uživatel schválil `docs/visual-proposals/phase147/approved-painted-cartoon-style-master-v1.png`
jako závaznou kalibraci budoucí grafiky celé hry. `VisualDesignSystem` ukládá jeho
SHA-256, sytou ručně malovanou 2D cartoon gramatiku, zachování současného UI
chrome a zákaz pixel artu, nalepených výřezů, bílých lemů i napevno vykreslené
šachovnice. Přechod je po kompletních obrazovkách: Pokoj, skleník, stojan a
detail, sklad, obchod, měření a modaly. Staré runtime assety zůstávají pod
původním profilem, dokud jejich obrazovková rodina nebude skutečně kompletní.

Uložený prázdný malovaný Pokoj je návrhový source. Dva vygenerované atlasové
zdroje jsou RGB a šachovnici mají zapečenou do obrazu, proto je regresní pojistka
zakazuje v runtime. Fáze 148 z nich po souhlasu uživatele vytvořila skutečné
samostatné RGBA vrstvy změnou pouze alfa kanálu. Validation
`.godot/validation/20260824-182814Z` prošla s 1 478/1 478, capture i visuals.
Jde o historický technický PASS style-locku; první kompletní herní render už
dokončila fáze 148 a jeho lidské přijetí zůstává samostatné. Immutable RC55,
schema 41, telefon i APK jsou beze změny. Quick `.godot/automation/20260824-183156Z` skončil
`HOW_TO_GROW_AUTOMATION=PASSED`; visual contract eviduje 353 profilovaných,
0 neprofilovaných a 133 runtime PNG.

## Fáze 148 — první kompletně přemalovaný Pokoj

Aktivní Pokoj je první obrazovková rodina dokončená pod schváleným masterem fáze
147. Malované prázdné prostředí `853 × 1844` skládá 12 funkčních pokojových
rostlin a 9 dekorací z celkem 21 samostatných RGBA vrstev. Nákup, přesun, dvacet
64px hitboxů, ekonomika a save schema 41 zůstávají beze změny.

Deterministický extraktor v3 upravuje výhradně průhlednost. Zachované RGB pixely
jsou bajtově shodné se zdrojovými atlasy, výstupní hrany mají alfu 0 a QA hlásí
21/21, checker 0 a halo risk 0. Dvanáct rostlin používá izotropní měřítko bez
deformace a společnou optickou šířku podmisek; kontaktní stín je součást malby a
runtime jej neduplikuje. Obrazové a dotykové středy sdílejí stejnou source-space
geometrii a dvojice kočičích misek se ve 432px viewportu neořezává.

Úplná validation `.godot/validation/20260824-194329Z` skončila
`MVP_TESTS_PASSED=1485`, `HOW_TO_GROW_CAPTURE=PASSED`,
`HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Interní kontrola
i nezávislý audit skutečného Godot capture jsou `PASSED`. Finální Quick
`.godot/automation/20260824-195259Z` potvrdil visual contract, regresi,
`AUTOMATION_TECHNICAL_GATE=PASSED` a `HOW_TO_GROW_AUTOMATION=PASSED`.
Subjektivní uživatelská
brána však zůstává `PENDING_USER_APPROVAL`; telefon je nedostupný, proto je mobil
`DEFERRED_PHONE_UNAVAILABLE`. APK nevzniklo, publishing je
`OUT_OF_SCOPE_BY_USER` a immutable RC55 zůstává beze změny.

## Fáze 149 — přesný hráčský pokoj podle schválené obrazovky

Uživatelem určená obrazovka je nyní přímý zdroj pravdy, ne pouze stylová
inspirace. Produkční výřez 853 × 1548 má samostatný target-derived clean plate,
12 vrstev pokojovek, 9 vrstev dekorací a jednu horní nábytkovou occlusion
vrstvu. Runtime zachovává 20 skutečných nákupních a přesouvatelných míst, ceny,
ekonomiku i save schema 41. Zapečený titulek a tlačítkový chrome mají průhledné
Godot hitboxy mapované ze stejné source-space geometrie.

Při přesně schváleném obsahu a pořadí slotů runtime vykreslí kanonický master se
SHA-256 `82D14A3B872C218B37B860F22E3980466974461A8A05784784BBD7ACEBDED8F7`,
který je bajtově shodný se závazným cropem. Po přesunu nebo odstranění používá
čistou desku a 21 funkčních target-derived RGBA vrstev. Kanonická rekonstrukce
má MAE/RMSE 0/0; dynamická vrstvová rekonstrukce má MAE 3,736, RMSE 16,269 a
11,358 % pixelů nad tolerancí 12, proto je `PHASE149_DYNAMIC_LAYER_COVERAGE`
poctivě `FAILED`. Rozšiřování masek by znovu vytvořilo viditelné nalepené části
pozadí; tato diagnostika nemění průchod kanonické obrazovky ani funkčnost slotů.

Validation `.godot/validation/20260824-214738Z` skončila
`MVP_TESTS_PASSED=1490`, `HOW_TO_GROW_CAPTURE=PASSED`,
`HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Gated porovnání
skutečného Godot renderu proti normalizované předloze prošlo s MAE 6,805, RMSE
12,005 a změnovým poměrem 18,172 %. Responsive
`.godot/responsive/20260824-214420Z` prošel 9/9. Interní technická a obrazová
brána je `PASSED`. Uživatel 25. 8. 2026 skutečný Godot render výslovně
schválil, proto je vizuální přijetí
`APPROVED_BY_USER`. Telefon je
nedostupný, takže mobil je `DEFERRED_PHONE_UNAVAILABLE`, APK `NOT_CREATED`,
publikování `OUT_OF_SCOPE_BY_USER` a immutable RC55 zůstává beze změny.
Navazující Quick `.godot/automation/20260825-042058Z` potvrdil visual contract i
regresi a skončil `AUTOMATION_TECHNICAL_GATE=PASSED` a
`HOW_TO_GROW_AUTOMATION=PASSED`.

## Fáze 150 — malovaný skleník podle schválené obrazovky

Schválený koncept 864 × 1544 určuje dva společné vyvýšené boxy, čtyři funkční
záhony a pořadí prázdný / šest sazenic / rajče 50 % / připravený lilek. Jeho
kanonická kopie je bajtově shodná, ale zůstává reference-only, protože konkrétní
stav je v obrazu zapečený. Původní Phase127 PNG nebyla změněna; deterministický
alfa-only builder z nich vytváří šest runtime vrstev se zachovaným RGB a
ověřenými zdrojovými i výstupními SHA-256. Odstranil tím hnědé půdní ostrůvky,
které předtím působily jako nalepené výřezy.

Runtime zachovává Phase130 prostředí, čtyři hitboxy, zálivku, růst, sklizeň,
ekonomiku, schema 41, HUD i navigaci. Sazenice jsou složené do tří sloupců po
dvou a stavové ikony sedí na rámu příslušného záhonu. Finální úplná validation
`.godot/validation/20260825-071114Z` skončila `MVP_TESTS_PASSED=1496`,
`PHASE150_GREENHOUSE_CAPTURE=PASSED`, `HOW_TO_GROW_CAPTURE=PASSED`,
`HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`.
Konceptuální diff zůstává report-only a žádná existující reference ani
tolerance se neoslabila.

Responzivní audit `.godot/responsive/20260825-061207Z` prošel všech 9/9 případů
a vydal `PHASE150_RESPONSIVE_GREENHOUSE=PASSED`.

Závěrečný Quick `.godot/automation/20260825-071439Z` skončil
`AUTOMATION_TECHNICAL_GATE=PASSED` a `HOW_TO_GROW_AUTOMATION=PASSED`.

Interní Godot cohesion audit je `PASSED_INTERNAL_COHESION_AUDIT`; samostatné
uživatelské přijetí skutečného renderu je `APPROVED_BY_USER`.
Telefon není dostupný, proto je mobil `DEFERRED_PHONE_UNAVAILABLE`, APK
`NOT_CREATED`, publikování `OUT_OF_SCOPE_BY_USER` a immutable RC55 zůstává
beze změny.

## Fáze 151–152 — malovaný Stojan, Detail a Sklad

Stojan a Detail používají Phase151 dynamický malovaný profil: větší policové
rostliny, sdílené baseline a podmisky, mipmapy a samostatný průhledný fialový
zámek s dynamickým textem úrovně. Sklad navazuje Phase152 workshopovou scénou
s cíleným horním výřezem; inventář, pipeline, akce, scroll a zakázky zůstávají
dynamické. Žádná zapečená hodnota schválených náhledů se nepoužívá jako herní
stav a zdrojová PNG rostlin ani workshopu se nezměnila.

Funkční regrese skončila `MVP_TESTS_PASSED=1502`. Report-only validační běh
`.godot/validation/20260825-094537Z` úspěšně vytvořil všechny capture a nové
konceptuální diffy. Responsive `.godot/responsive/20260825-095148Z` prošel 9/9.
Závěrečný Quick `.godot/automation/20260825-095505Z` skončil
`AUTOMATION_TECHNICAL_GATE=PASSED` a `HOW_TO_GROW_AUTOMATION=PASSED`.
Interní cohesion audit skutečných renderů i následné uživatelské vizuální
schválení jsou `PASSED`. Pět kompozitních baseline průvodce a stojanových
efektů přešlo na nové append-only Phase151 reference; původní soubory nebyly
přepsané ani odstraněné. Telefon je nedostupný, APK nevzniklo, publikování
zůstává mimo rozsah a RC55 je immutable.

Závěrečný přesný běh `.godot/validation/20260825-102405Z` potvrdil
`MVP_TESTS_PASSED=1502`, `HOW_TO_GROW_CAPTURE=PASSED`,
`HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Všech 18
tvrdých případů prošlo; patří mezi ně také tři nové přesné runtime brány pro
uživatelem schválený Stojan, Detail a Sklad. Konceptuální targety zůstávají
report-only, protože záměrně obsahují zapečený konkrétní herní stav.

## Fáze 153 — dynamický malovaný Obchod

Uživatelem schválený návrh Obchodu byl převeden do živého runtime bez zapečení
konkrétní peněženky, zásob nebo vybrané kategorie. Pan Kořínek, integrovaná
cedule, dialogová plaketa, peněženka, třísloupcové produktové karty a čtyři
kategorie používají Phase153 profil, zatímco všech 11 semen, hnojivo, pět
vylepšení, ceny, vzácnost, denní zásoby, nákup, výkup, scroll a transakce
zůstávají dynamické. Zdrojové PNG obchodníka nebylo změněno; import pouze
zapíná mipmapy.

Regrese skončila `MVP_TESTS_PASSED=1506`. Responsive
`.godot/responsive/20260825-111352Z` prošel 10/10 včetně samostatného případu
Obchodu na 360×800. Uživatel 25. 8. 2026 skutečný Godot render výslovně
schválil; nový append-only baseline
`assets/ui/comic/reference_phase153_shop_runtime_v1.png` má SHA-256
`3DD2EEFC3ECB1B50D6394E1368B67B62FD64D4C0CD65CE48C5784C6602754C12`.
Původní koncept zůstává report-only.

Finální úplná validace `.godot/validation/20260825-115747Z` skončila
`HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED` a
`HOW_TO_GROW_VALIDATION=PASSED`; všech 19 závazných obrazových bran prošlo.
Nový `phase153-shop-runtime-approved` dosáhl přesné shody MAE 0, RMSE 0 a
0 % změněných pixelů. Závěrečný Quick `.godot/automation/20260825-120031Z`
skončil `AUTOMATION_TECHNICAL_GATE=PASSED` a
`HOW_TO_GROW_AUTOMATION=PASSED`.

Interní cohesion audit i samostatné uživatelské vizuální přijetí jsou
`PASSED`; append-only přechod baseline je uzavřený. Telefon není dostupný, mobil je
`DEFERRED_PHONE_UNAVAILABLE`, APK `NOT_CREATED`, publikování
`OUT_OF_SCOPE_BY_USER` a immutable RC55 zůstává beze změny.

## Fáze 154 — dynamické malované Měření

Uživatelem schválená kompozice je uložená append-only a zůstává report-only.
Runtime nepoužívá zapečený screenshot: existující byte-exact malovanou laboratoř
ořezává do výraznějšího hero obrazu a skládá ji s deseti skutečnými senzorovými
hodnotami, hladkými ikonami, online stavem, 72hodinovým grafem a pěstitelskou
nápovědou. Svislý mobilní scroll i presenter zůstávají funkční. Historický
`comic-measurement.png` se nadále pořizuje v původním režimu a není přepsán.

Úplná validace `.godot/validation/20260825-132647Z` prošla 1510/1510 kontrol,
capture i všemi 20 tvrdými obrazovými branami. Nový schválený runtime případ má
MAE 0,000 / RMSE 0,000 / 0,000 % změněných pixelů. Historický případ Měření má
MAE 0,437 / RMSE 7,000 / 0,570 % změněných pixelů. Phase154 koncept zůstává
report-only s MAE 75,602 / RMSE 104,860, protože záměrně není skutečným
dynamickým stavem. Responzivní matice `.godot/responsive/20260825-124928Z`
prošla 11/11 včetně samostatného Měření na 360×800. Interní cohesion audit je
`PASSED`; skutečný dynamický render uživatel 25. 8. 2026 schválil a jeho
append-only kopie `assets/ui/comic/reference_phase154_measurement_runtime_v1.png`
se stala novou tvrdou branou. Koncept zůstává report-only. Telefon není dostupný, mobil je
`DEFERRED_PHONE_UNAVAILABLE`, APK `NOT_CREATED`, publikování `OUT_OF_SCOPE` a
immutable RC55 zůstává beze změny.

Závěrečný Quick `.godot/automation/20260825-132926Z` skončil
`AUTOMATION_TECHNICAL_GATE=PASSED`, zařízení `NOT_REQUESTED`, lidská brána
`PENDING_SINGLE_HUMAN_BATCH`, publikování `OUT_OF_SCOPE_BY_USER` a
`HOW_TO_GROW_AUTOMATION=PASSED`.

## Fáze 155 — dynamický malovaný Herbář

Uživatelem schválená kompozice je archivovaná append-only a zůstává report-only.
Runtime používá samostatnou čistou malovanou knihu bez zapečeného textu, čísel,
rostlin a odměn. Godot nad ni skládá oba živé souhrny, všech 11 druhů, jejich
portréty, vzácnost, popis, vlastnosti, statistiky, mistrovský postup a funkční
odměny. Přehrání předání zahrady, stavová zpráva, zavírání i svislý mobilní
scroll zůstávají zachované.

Finální validace `.godot/validation/20260825-155831Z` prošla 1515/1515,
capture, visuals i plným markerem a všemi 21 tvrdými branami. Nový
`phase155-herbarium-runtime-approved` má MAE 0,000 / RMSE 0,000 / 0,000 %
změněných pixelů.
Responzivní audit `.godot/responsive/20260825-154636Z` prošel 12/12 včetně
samostatného 360×800 Herbáře. Uživatel skutečný Godot render 25. 8. 2026
schválil. Jeho append-only reference
`assets/ui/comic/reference_phase155_herbarium_runtime_v1.png` má SHA-256
`8af6514760bba55dd78f47a0945febbd744ed65ae4462c1703399f32e9cc4530` a nový
tvrdý případ `phase155-herbarium-runtime-approved` jej chrání bez masky.
Závěrečný Quick po uzavření baseline `.godot/automation/20260825-160228Z` skončil
`AUTOMATION_TECHNICAL_GATE=PASSED`, `AUTOMATION_DEVICE_GATE=NOT_REQUESTED`,
`AUTOMATION_PUBLISHING_GATE=OUT_OF_SCOPE_BY_USER` a
`HOW_TO_GROW_AUTOMATION=PASSED`.
`phase155-herbarium-approved-target` zůstává pouze report-only; skutečný runtime
má vlastní schválenou tvrdou bránu. Telefon je nedostupný, APK `NOT_CREATED`,
publikování `OUT_OF_SCOPE` a immutable RC55 zůstává beze změny.

## Fáze 156–157 — RC56 handoff a opravené RC57

RC56 `0.67.0-rc56` / code 73 / schema 41 bezpečně zabalilo současný malovaný
runtime a prošlo automatickou technickou instalací. Následná fyzická navigace
ale našla přetečení záhlaví detailu, které částečně skrývalo tlačítko `HERBÁŘ`;
proto zůstal jeho vizuální výsledek pravdivě `FAILED` a immutable RC56 nebylo
přepsáno.

Fáze 157 zachovává schválené rozměry a styl záhlaví. Pouze omezuje dlouhý
prostřední název výpustkou, takže plný 68 × 50 cíl Herbáře zůstane uvnitř
mobilního obsahu. ReleaseDevice orchestrace `.godot/automation/20260825-174557Z`
prošla: validation `.godot/validation/20260825-174611Z` má 1 521/1 521,
capture i visuals `PASSED`; performance `.godot/performance/20260825-174849Z`,
endurance `.godot/endurance/20260825-174935Z`, progression
`.godot/progression/20260825-174948Z` 132/132 a responsive
`.godot/responsive/20260825-174955Z` 13/13 jsou `PASSED`.

Immutable APK
`builds/android/bazals-pocket-garden-0.67.1-rc57-arm64-debug.apk` má
215 818 726 B a SHA-256
`4908F3C0A09278ABE9B8BEB433F6F9576FE8343343908BF40858F5B2B5D5F081`.
Audit `.godot/android-device-audit/20260825-175109Z` potvrdil přesně tento
nainstalovaný hash, verzi/code, save 41 → 41, zachování stabilních hodnot,
11 platných foreground vzorků a 0 crash/ANR nálezů. Fyzické snímky v téže
složce potvrzují celý header a skutečné otevření Herbáře. Technická i cílená
fyzická brána opravy jsou `PASSED`; celkové lidské mobilní posouzení zůstává
`PENDING_SINGLE_HUMAN_BATCH` a publikování `OUT_OF_SCOPE_BY_USER`.

## Fáze 158 — oprava dynamického skládání Pokoje

Fyzický audit RC57 odhalil, že plný stav 20/20 používal čistý schválený master,
ale částečně zaplněný Pokoj skládal historické Phase 149 výřezy s přimíchaným
okolím. To vytvářelo nalepené fragmenty, přesahy polic a rozpadlé textury.
Immutable RC57 ani schválený plný master se nepřepisují.

Nekanonické stavy nyní používají 21 objektově čistých Phase 148 RGBA vrstev,
novou objektově čistou přední vrstvu nábytku a prázdné interakční značky
kreslené až nad ní. U vysokých rostlin v nižších policích se přizpůsobuje pouze
listoví nad hranou keramiky; podmiska, květináč, šířka a baseline zůstávají
beze změny.

Původní technická validation `.godot/validation/20260825-204357Z` zachytila
čtyři deterministické skutečné rendery: prázdný 0/20, řídký 4/20,
sanitizovanou přesnou topologii telefonu 10/20 a plný stav 20/20. Uživatel
následně všechny čtyři stavy výslovně schválil. Jejich přesné append-only
reference jsou nyní čtyři samostatné tvrdé runtime brány bez cropu a masek.
Závěrečná úplná validation `.godot/validation/20260827-153641Z` prošla
`MVP_TESTS_PASSED=1556`, capture, visuals i full stavem; všechny čtyři Phase158
brány mají MAE/RMSE/changed ratio `0/0/0`. Nové APK nevzniklo, publishing je
`OUT_OF_SCOPE_BY_USER` a save schema zůstává 41.

Navazující vizuální oprava mění pouze dynamickou keramiku orchideje: její
viditelná šířka a výška jsou odvozené od správného modrého květináče, oba
objekty sdílejí střed slotu a spodní baseline a listoví se vodorovně
neroztahuje. Ostatní rostliny ani kanonický master 20/20 se nemění. Detailní
důkaz je `phase158-orchid-pot-parity-preview.png` v uvedené validační složce.

## Fáze 159 — botanické terárium místo lampičky a květináčů

Uživatel schválil jeden malovaný skleněný poklop s kapradinou a mechem jako
náhradu za dvě drobné dekorace spodní police komody. Produkční asset
`assets/ui/visual/phase159/player_room/decor/botanical_cloche_phase159_v1.png`
je append-only RGBA 615 × 1013. Deterministický
`tools/build_phase159_botanical_cloche.py` zachovává verzovaný RGB zdroj,
odstraňuje pouze magenta plate, vytváří antialiasovanou alfu a kontroluje nulový
okraj, nulové RGB pod průhledností i absenci viditelného magenta lemu. Přesné
hashy a počty jsou v `phase159_botanical_cloche_qa.json`.

Save schema zůstává 41. Existující `golden_lamp` je jediný aktivní entitlement
nového terária a zachovává cenu 26 i slot 15. `nested_pots` zůstává pouze jako
historický doklad nákupu; nový nákup je zakázán a legitimní schema 38–41 save se
bez změny mincí normalizuje na jedno terárium. Persistovaný slot 14 zůstává kvůli
kompatibilitě, ale jeho marker i hitbox jsou skryté. Schema 37 jej nemůže
podvrhnout.

Runtime po uživatelem vyžádaném zvětšení používá source rect
`Rect2(610.6, 1018.8, 128.8, 193.2)`, tedy přesných 115 %, a kotvu
`Vector2(675, 1212)` se zachovaným středem i spodní baseline. Phase158 přední
hrana police zakryje spodní část objektu, takže není složený jako nálepka před
nábytkem. Uživatel oba skutečné Godot rendery v této velikosti výslovně
schválil; dvě nové append-only tvrdé runtime brány se v závěrečné validation
`.godot/validation/20260827-153641Z` shodují přesně `0/0/0`. Historický Phase149
master, save schema 41 i immutable RC57 zůstávají beze změny. Asset QA,
validation, render inspection i Godot visual acceptance jsou `PASSED`, APK
`NOT_CREATED` a publishing `OUT_OF_SCOPE_BY_USER`.

## Fáze 160 — čistá podlaha Pokoje a rezervovaný pet kout

Uživatel schválil odstranění plastové konvičky, starého pelíšku a dvojice misek
ze současného Pokoje. `plastic_watering_can` ve slotu 17 a `cat_corner` ve slotu
19 zůstávají v katalogu, vlastnictví i uložených pozicích jako historické
účtenky, ale jsou dormant: nový nákup vrací `reserved_for_redesign`, jejich
sloty nemají sprite, marker ani hitbox a obě misky se s pet koutem nekreslí.

Schema zůstává 41. Round-trip starého save nesmí smazat zaplacené vlastnictví
ani jeho původní pozice. Historický Phase149 full master, který tyto objekty
obsahuje, je nově dostupný pouze explicitnímu report-only capture a nikdy
produkčnímu Pokoji. Zdrojové PNG, jejich profily, reference i immutable RC57
zůstávají beze změny.

Budoucí slot 19 je rezervovaný pro jednotně namalovaný pet kout spojený se
skutečným nákupem mazlíčka. Phase160 nepřidává samostatnou péči, misky ani nový
coin sink. Deterministický capture
`comic-phase160-player-room-clean-floor.png` obsahuje uložené dormant účtenky,
ale musí zobrazit čistou pravou část podlahy.

Skutečný `comic-phase160-player-room-clean-floor.png` byl v původním rozlišení
zkontrolován: žádný ze čtyř odmítnutých objektů není viditelný a ostatní obsah
Pokoje zůstal celistvý. Uživatel tento přesný Godot render výslovně schválil.
Proto byl append-only uložen jako
`assets/ui/comic/reference_phase160_player_room_clean_floor_runtime_v1.png`
se SHA-256
`A0A7D7D1A4120320FC0084AF65429E9F997AC9CAD29E51DECF20278869363BD2` a případ
`phase160-player-room-clean-floor-runtime-approved` se stal 22. tvrdou
obrazovou branou bez cropu a masek.

Úplná validation po povýšení baseline
`.godot/validation/20260826-064438Z` prošla s
`MVP_TESTS_PASSED=1535`, `HOW_TO_GROW_CAPTURE=PASSED`,
`HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Všech 22
tvrdých bran prošlo; Phase160 případ má `mean_abs_error=0.000`,
`rmse=0.000` a `changed_ratio=0.000 %`.

Responzivní matice `.godot/responsive/20260826-050545Z` prošla 13/13 včetně
Pokoje na 360 × 800 a skrytých neinteraktivních slotů 17/19. Immutable RC57 má
po změně stále SHA-256
`4908F3C0A09278ABE9B8BEB433F6F9576FE8343343908BF40858F5B2B5D5F081`.

Aktuální brány: implementace `IMPLEMENTED`, save schema `41_UNCHANGED`, RC57
`PRESERVED`, technical validation `PASSED`, render inspection `PASSED`, Godot
visual acceptance `APPROVED_BY_USER`, append-only runtime baseline
`PASSED`, APK `NOT_CREATED`, publishing `OUT_OF_SCOPE_BY_USER`.

## Fáze 161 — vrstvená malovaná Denní výzva

Uživatel schválil Phase161 výtvarný koncept Denní výzvy. Přesný 853 × 1844
náhled se SHA-256 `797235…533e` je archivovaný append-only a zůstává
report-only, protože obsahuje konkrétní HUD, texty a stav `prepare_rain`.

Runtime proto používá samostatný textless 853 × 1844 RGBA plate se SHA-256
`678fa2…72b6`, živé Godot popisky a skutečná tlačítka. Neutrální botanická
scéna dostává procedurální kontext pro všech 14 typů výzvy i dnešní a zítřejší
počasí. Presenter, schema 41, UTC denní obnova, cílová navigace a odměna
12 mincí + 10 XP + botanický balíček zůstávají beze změny.

Deterministický audit odděluje `ACTIVE`, `READY`, `READY + queue_full`,
`CLAIMED` a `NO_TARGET`. Uživatel všech pět skutečných Godot stavů výslovně
schválil; každý je nyní chráněný vlastní append-only tvrdou runtime branou bez
cropu nebo masek, zatímco výtvarný koncept zůstává `gate=false`. Závěrečná
validation `.godot/validation/20260827-153641Z` prošla 1 556/1 556, capture,
visuals i full stavem a všech pět Phase161 bran má přesnou shodu `0/0/0`.
Responsive audit `.godot/responsive/20260826-092316Z` zůstává 14/14 včetně
skutečného modalu 360 × 800 bez vodorovného overflow. Technická i uživatelská
vizuální brána jsou `PASSED`; mobil je nedostupný, APK `NOT_CREATED`,
publikování `OUT_OF_SCOPE` a RC57 zůstává immutable.

## Fáze 162 — dynamický malovaný Kosmetický showroom

Uživatel schválil Phase162 výtvarný koncept Kosmetického showroomu. Přesný
841 × 1870 návrh je archivovaný append-only v
`docs/visual-proposals/phase162/user-approved-painted-cosmetic-showroom-v1.png`
se SHA-256
`BC524F1D2C3111630385256481A4ACB04CC51D99C2E4CF342D7FA468C3FC5DC0`.
Obsahuje konkrétní copy, ceny, mince a stav odemčení, proto zůstává report-only.

Runtime používá samostatný čistý 841 × 1871 plate
`assets/ui/visual/phase162/cosmetic_showroom/cosmetic_showroom_clean_backdrop_v1.png`
se SHA-256
`A696D1759EF1FE830984E0DC2C8C292FCEDC3B9B4CFEB55DBCB7E2849542FCF6`.
Čtyři pokojové miniatury, dřevěný rám a prázdné malované akční plochy jsou
obrazové; názvy, popisy, skutečná tlačítka, peněženka, ceny, výběr, nedostatek
mincí a výzkumný zámek zůstávají živými Godot vrstvami. Funkční svislý scroll a
blokování vstupu za modalem zůstávají zachované.

Fáze nemění ceny, ekonomiku, herní bonusy, pořadí ani pravidla čtyř existujících
vzhledů. `Badatelská pracovna` stále vyžaduje šest dokončených Profesorových
protokolů. Save schema zůstává 41 a immutable RC57 se nepřepisuje.

Koncept zůstává ve vizuální sadě pouze report-only (`gate=false`). Uživatel
26. srpna 2026 výslovně schválil skutečný Godot render vybraného stavu. Jeho
byte-exact append-only kopie
`assets/ui/comic/reference_phase162_cosmetic_showroom_runtime_v1.png` má SHA-256
`DFCC10B8B1B89F6D637100E6C781B6D9097976F0A9600E8B093E5665430EFE18` a nový
případ `phase162-cosmetic-showroom-runtime-approved` jej chrání jako 23. tvrdou
bránu bez cropu a masek. Úplná validation po povýšení baseline
`.godot/validation/20260826-153955Z` prošla 1 548/1 548 kontrolami, Phase162
capture i všemi 23 tvrdými obrazovými branami; nový runtime případ má přesnou
shodu MAE 0, RMSE 0 a 0 % změněných pixelů. Responsive audit
`.godot/responsive/20260826-151922Z` prošel 15/15 a závěrečná Quick automatizace
`.godot/automation/20260826-154305Z` skončila
`HOW_TO_GROW_AUTOMATION=PASSED`. Čtyři cílené stavové rendery jsou v
`.godot/phase162-only/20260826-171948Z`. Technický PASS a uživatelské schválení
jsou doloženy odděleně; `PHASE162_GODOT_RENDER_ACCEPTANCE=APPROVED_BY_USER` a
`PHASE162_VISUAL_BASELINE_TRANSITION=PASSED_APPEND_ONLY_RUNTIME_GATE`. Telefon
není dostupný, mobilní audit je
`DEFERRED_PHONE_UNAVAILABLE`, APK `NOT_CREATED`, publikování `OUT_OF_SCOPE` a
RC57 zůstává immutable.

## Fáze 163 — jednotné zamčené květináče Stojanu

Uživatel schválil přesný 872 × 1804 náhled nové podoby Stojanu uložený jako
`docs/visual-proposals/phase163/user-approved-locked-planter-rack-screen-v1.png`
se SHA-256
`BD906524ED677FB996098578E3EFBED3F19C797AC8078CBC8C7DB86AEB1BC349`.
Schválení se vztahuje na jeden typ kompaktního fialového zamčeného květináče a
jednotnou mosazně tmavou kresbu pěstebních světel. Náhled obsahuje konkrétní HUD
a herní stav, proto je evidovaný pouze jako report-only cíl (`gate=false`) a
nesmí se stát zapečenou náhradou živé obrazovky.

Dynamický runtime používá jeden transparentní master
`rack_locked_planter_phase163_v1.png` pro všech osm zamčených pozic a jeden
transparentní master `rack_grow_light_phase163_v1.png` pro všechna svítidla.
Assety vznikly deterministickým alfa-only oddělením: viditelné RGB pixely
schválené malby zůstávají beze změny, mění se pouze průhlednost a čistý
transparentní okraj.
Deset slotů, živé texty úrovní, odemčení, růst, péče, deset světelných stavů,
kliknutí a navigace zůstávají funkční. Save schema 41, ekonomika a immutable
RC57 se nemění.

Konceptuální případ `phase163-rack-locked-planter-approved-target` zůstává
report-only. Uživatel následně výslovně schválil skutečný Godot render a jeho
přesná append-only kopie je novou tvrdou Phase163 runtime branou. Historická
Phase151 rack reference zůstává zachovaná jako report-only doklad. Stejný
append-only přechod dostaly dvě kompozitní brány `feedback-unlock` a
`screen-transition`, protože jejich efekty zůstaly beze změny, ale staré
reference pod nimi obsahovaly Phase151 stojan; masky, tolerance ani pevné
capture časy se nezměnily.

Závěrečná úplná validation `.godot/validation/20260827-153641Z` prošla
`MVP_TESTS_PASSED=1556`, `HOW_TO_GROW_CAPTURE=PASSED`,
`HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Samostatný
Phase163 stojan i oba navazující efekty mají přesnou shodu `0/0/0` a celkem
prošlo všech 34 aktivních tvrdých vizuálních bran. Technická, Godot render,
uživatelská vizuální i baseline transition brána jsou `PASSED`. Mobilní audit
je `DEFERRED`, APK `NOT_CREATED`, publikování `OUT_OF_SCOPE` a RC57 zůstává
immutable.

## Fáze 164 — zdrojový baseline po vizuálním uzavření

Celý ověřený zdrojový rozsah po baseline RC36 až po uživatelem schválené
Phase163 je uzavřený anotovaným tagem `phase164-source-baseline`. Snapshot
obsahuje výhradně projektové zdroje v `assets`, `docs`, `scripts` a `tools`;
ignorované `.godot`, buildy, APK, AAB, keystore ani dočasná data nejsou jeho
součástí. Před snapshotem bylo inventarizováno 95 upravených sledovaných a 645
nových nesledovaných souborů bez nalezeného nového tajemství nebo privátního
klíče. Immutable RC57 i jeho alias zůstaly byte-exact.

Úplná orchestrace `.godot/automation/20260827-175234Z` prošla visual
contractem 450 profilovaných / 0 neprofilovaných PNG, validací 1 556/1 556 a
34/34 aktivními obrazovými branami, výkonem, endurance 48/48, progression
132/132 s 27 roundtripy a responsive maticí 15/15. Po dokumentaci musí projít
ještě Quick automatizace. Technická source brána je `PASSED`; identita
`0.67.1-rc57` / code 74, save schema 41, telefon a publikování se v této fázi
nemění. RC58 vzniká až ze samostatného navazujícího release commitu.

## Fáze 165 — RC58 Android handoff

Samostatná Phase165 povyšuje pouze release identitu na `0.68.0-rc58` / code
75. Vychází z anotovaného tagu `phase164-source-baseline`, zachovává save
schema 41 a nepřepisuje immutable RC57.

Úplná orchestrace `.godot/automation/20260827-181126Z` a release candidate
`.godot/release-candidate/20260827-181127Z` prošly visual contractem 450/0,
regresí 1 558/1 558, capture, všemi 34 aktivními obrazovými branami, výkonem,
endurance 48/48, progression 132/132, responsive maticí 15/15, Android
exportem, podpisem a payloadem. Immutable APK má 224 368 317 B a SHA-256
`0A7F173D8C97B552168A407C31F1F8AE85109A34C2F6F4786029551064F0C6F5`.

Sanitizovaný audit `.godot/android-device-audit/20260827-181643Z` potvrdil na
Xiaomi 2201116SG nainstalovanou identitu RC58 code 75 se shodným APK hashem,
22 platných vzorků, 100% foreground, nula fatal/ANR nálezů a save přechod
41_TO_41 se zachovanými 6 mincemi, 292 XP, 10 sloty a 2 obsazenými pozicemi.
Technická device brána je `PASSED_TECHNICAL`. Lidská čitelnost, dotyk,
systémové Zpět, document picker, destruktivní potvrzení, reálná upozornění,
restart, teplota a baterie zůstávají jedinou oddělenou bránou
`PENDING_SINGLE_BATCH`. Publikování zůstává `OUT_OF_SCOPE_BY_USER`.

## Reprodukce technických bran

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\run_project_automation.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\run_project_automation.ps1 -Mode Quick
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\run_project_automation.ps1 -Mode Release
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\run_project_automation.ps1 -Mode ReleaseDevice -DeviceSampleSeconds 300
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\run_tests.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .agents\skills\how-to-grow-validation\scripts\run_validation.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\run_performance_smoke.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\run_endurance_smoke.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\run_progression_smoke.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\run_responsive_layout_smoke.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\export_android.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\export_android.ps1 -ToolRoot 'C:\_projekty\How to grow_\.tooling' -ApkPath 'C:\temp\Bazal build\candidate.apk'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\export_android_release_aab.ps1 -KeystorePath 'D:\private\bazal-upload.jks' -KeyAlias 'bazal-upload'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\run_android_device_audit.ps1 -Install -ApkPath 'C:\_projekty\How to grow_\builds\android\bazals-pocket-garden-0.64.0-rc53-arm64-debug.apk' -SampleSeconds 300
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\run_release_candidate.ps1
```

Pro vizuální validaci je potřeba dostupný Python s Pillow a NumPy; na tomto pracovním počítači se předává přes parametr `-PythonPath`. Žádný z těchto kroků nesmí přepisovat schválené reference.

Android audit se bezpečně zastaví, pokud není připojené právě jedno autorizované zařízení; při více telefonech vyžaduje `-Serial`. Telefon musí zůstat odemčený, interaktivní a aplikace v popředí alespoň po 80 % vzorků, jinak je záznam `INVALID`. Postup fáze 100 je výhradně nedestruktivní aktualizace existující instalace; čistý onboarding patří do odděleného testu a nesmí se vydávat za důkaz migrace předchozího save 23 → RC29 schema 28.

## Směr po vertikálním řezu

Po schválení současné čitelnosti a ovládání je nejbezpečnější rozšiřovat hru v tomto pořadí:

1. další bylinky jako datové profily, ne nové samostatné simulace;
2. počasí a denní výzvy, které mění rozhodování;
3. kosmetické úpravy místnosti a stojanu;
4. teprve poté účty, cloud, analytika a obchodní model.
