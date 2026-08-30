# Fáze 183 — kompaktní čtyřikonový dok stojanu

## Cíl

Spodní panel `DOPLŇKY · MAZLÍK` zabíral téměř celou šířku, přestože jeho
tlapka ani tři barevné body nebyly funkční. Na 360 × 800 se navíc původní
výstavní lišta překrývala s tlačítkem Péče. Profesorův výzkum byl umístěný
nahoře vedle otazníku a před dokončením vedené cesty se úplně skrýval, takže
na časném save působil jako ztracená funkce.

Fáze 183 nahrazuje široký panel jednou souvislou malovanou podlahou a čtyřmi
stejně velkými ikonovými tlačítky:

1. doplňky / mazlíček / vzhled pokoje;
2. Profesorův výzkum;
3. Centrum péče;
4. hráčské nastavení.

Otazník nahoře zůstává jediným vstupem do obecné nápovědy.

## Rozvržení a interakce

- Výška rezervovaného doku zůstává 90–93 logických pixelů. Stojan, police,
  sloty, květináče i jejich dosednutí se proto nepřepočítávají.
- Čtyři tlačítka mají shodně 68 × 68 px a jsou jako jeden 272px celek
  vystředěná. Na 432 × 960 začínají na x = 80, na 360 × 800 na x = 44.
- Každé tlačítko obsahuje samostatný průhledný PNG asset v 48 × 48 px.
- Mazlíček otevírá existující kosmetický showroom, Péče stávající Centrum
  péče a ozubené kolečko stávající hráčské nastavení.
- Profesor je vždy viditelný. Před odemčením má čitelný `ZÁM` badge a klepnutí
  vysvětlí podmínku odemčení; po dokončení předání otevře stejný uložený
  příběh / týdenní výzkum jako dosud. Živý vykřičník zůstává samostatnou
  Godot vrstvou a není zapečený v PNG.
- Počet rostlin vyžadujících péči je samostatný dynamický badge. Text
  `PÉČE 2` už neroztahuje obsah tlačítka.

## Nové verzované assety

Původní PNG nebyla přepsána. Nové soubory jsou v
`assets/ui/visual/phase183/rack_dock/`:

| Soubor | Rozměr | SHA-256 | Použití |
|---|---:|---|---|
| `pet_paw_phase183_v1.png` | 1254 × 1254 RGBA | `83C1E20CC692B49DBA4FD8117FB06EF01D86CA02A5490042A2B8D0EBF354A844` | Doplňky / mazlíček |
| `professor_bazal_phase183_v1.png` | 1254 × 1254 RGBA | `40E0BDBC08CD43B02C9940A3E12067B26BBBF8B2D068DE0BAAAD8DEDE08AEDE3` | Profesorův výzkum |
| `care_leaf_phase183_v1.png` | 1254 × 1254 RGBA | `88DFB0EE74BC48C223B6AC07CEA2B0BFC480C240B31D041A3574DF2712883CC0` | Centrum péče |
| `rack_floor_extension_phase183_v1.png` | 1774 × 887 RGB | `E72F4C1D1FD1B6585B1140668B9723E9CA7E094D23A4C3082BC9C78D9057765A` | Malované pokračování podlahy |

Nastavení dál používá schválené
`assets/ui/icons/settings_gear_phase125.png` (256 × 256 RGBA,
SHA-256 `A8F8337CA0DDD92971761CEB66393638B3BAAC5DF0B3A56CE8C010C08026DCA5`).

Všechny čtyři ikony i podlahový outpaint jsou připojené k profilu
`phase183_rack_compact_four_icon_dock_v1` v `VisualDesignSystem`. Ikony mají
čistou alfa vrstvu bez bílého obdélníku; badge zámku, upozornění a počtu
zůstávají dynamické.

## Skutečný Godot render

GPU capture `.godot/phase183-rack-dock/20260829-2315Z` vykreslil a uložil osm
snímků: celý viewport a spodní výřez pro 432 × 960 i 360 × 800, vždy v zamčeném
a odemčeném stavu. Geometrická kontrola potvrdila:

- přesně čtyři viditelné, nepřekrývající se cíle 68 × 68;
- přesně čtyři PNG ikony 48 × 48 ve správném pořadí;
- vystředění celé řady v obou šířkách;
- zachovaný horní otazník bez kolize;
- viditelný zamčený Profesor a správné odstranění zámku po odemčení;
- nové malované pozadí bez návratu širokého krémovo-tyrkysového panelu.

`PHASE183_RACK_DOCK_GEOMETRY=PASSED`
`PHASE183_RACK_DOCK_CAPTURE=PASSED`

Samostatná cílená sada skončila `PHASE183_TESTS_PASSED=41` a responzivní
matice pro běžný i kompaktní mobilní canvas prošla 15/15. Úplná validace
`.godot/validation/20260829-215900Z` dokončila
`MVP_TESTS_PASSED=6745` a `HOW_TO_GROW_CAPTURE=PASSED`.

Celkový obrazový gate zůstává pravdivě `FAILED` na deseti historických
referencích: `detail-realtime`, tři guide stavy, `feedback-water`,
`feedback-growth`, dva Phase163 efektové stavy, Phase151 detail a Phase163
stojan. Všechny jejich `comparison.png` byly prohlédnuty. Odchylky odpovídají
dříve evidovanému novému dosednutí detailu a stojanu; stojanové, guide a
efektové snímky navíc správně ukazují nový spodní dok. Reference, masky ani
tolerance se bez uživatelského schválení neměnily.

## Android emulátor

Samostatný x86_64 preview je uložený v
`.godot/emulator-preview/20260829-221017Z/bazals-pocket-garden-phase183-emulator-x86_64-debug.apk`.
Má 240 853 270 B a SHA-256
`0A4CD44CEBDD85B82BE101420E9F327E625273CA03772D42FEFC98F25A112834`.
Export prošel kontrolou podpisu, APK payloadu i Android notifikační vrstvy a
`adb install -r` jej nainstaloval do `emulator-5554` bez smazání dat.
Balíček `com.howtogrow.game` běží v popředí jako
`0.68.0-rc58-emulator` / code 75 a skutečná Android obrazovka vykreslila
kompaktní čtveřici.

Emulátor obsahuje starý poškozený save. Fail-closed dialog jej nechal
nedotčený a dovolil pouze `POKRAČOVAT BEZ UKLÁDÁNÍ`; při dalším pokusu o
uložení se ochrana správně vrací. Kvůli tomu nebyl destruktivně vynucen
úplný klikací audit v emulátoru. Všechny čtyři callbacky a locked/unlocked
stavy kryje cílená Godot sada, ale fyzické proklikání zůstává oddělené.

Závěrečná Quick automatizace po dokumentaci je v
`.godot/automation/20260829-222857Z`. Vizuální kontrakt i regrese prošly a
runner vydal `AUTOMATION_TECHNICAL_GATE=PASSED` a
`HOW_TO_GROW_AUTOMATION=PASSED`. Quick záměrně nenahrazuje historické
pixelové brány ani lidské posouzení.

## Hranice přijetí

Skutečný Godot render a automatická geometrie jsou technický důkaz, ne
automatické lidské schválení vzhledu. Historická tvrdá reference Phase163
obsahuje starý spodní panel; nesmí se potichu přepsat, oslabit ani zamaskovat.
Nový dok zůstává diagnostickou změnou, dokud jej uživatel neposoudí. Immutable
RC58, obecný APK alias a telefon nejsou touto zdrojovou fází změněny.

`PHASE183_SOURCE_AND_INTERACTION_CONTRACT=PASSED`
`PHASE183_TARGETED_TESTS=PASSED_41`
`PHASE183_RESPONSIVE=PASSED_15_OF_15`
`PHASE183_FULL_REGRESSION=PASSED_6745`
`PHASE183_FULL_VISUAL_GATE=FAILED_10_HISTORICAL_REFERENCES`
`PHASE183_EMULATOR_PREVIEW_INSTALL=PASSED_PRESERVE_DATA`
`PHASE183_EMULATOR_CLICK_AUDIT=BLOCKED_BY_PROTECTED_OLD_SAVE`
`PHASE183_QUICK_AUTOMATION=PASSED`
`PHASE183_USER_VISUAL_ACCEPTANCE=PENDING_USER_REVIEW`
