# Fáze 147 — schválený malovaný cartoon master

`PHASE147_APPROVED_PAINTED_CARTOON_MASTER=IMPLEMENTED`

`PHASE147_STYLE_ACCEPTANCE=APPROVED_BY_USER`

`PHASE147_RUNTIME_INTEGRATION=IN_PROGRESS_PLAYER_ROOM_COMPLETED_BY_PHASE148`

`PHASE147_TECHNICAL_VALIDATION=PASSED`

`PHASE147_GODOT_RENDER_ACCEPTANCE=PLAYER_ROOM_PENDING_USER_APPROVAL`

`PHASE147_MOBILE_ACCEPTANCE=DEFERRED_PHONE_UNAVAILABLE`

`PHASE147_APK=NOT_CREATED`

`PHASE147_PUBLISHING=OUT_OF_SCOPE_BY_USER`

## Závazný výtvarný master

Uživatel dne 2026-08-24 výslovně schválil obrázek
`docs/visual-proposals/phase147/approved-painted-cartoon-style-master-v1.png`
jako závazný grafický master pro postupné překreslení celé hry. SHA-256 masteru
je `20E5251D8A967D09D4AD6BBFD8BFB40A4CF2093ADC120774114F4D925B9C5F80`.

Master neurčuje jedinou zapečenou obrazovku. Určuje společnou výtvarnou gramatiku
pro prostředí a samostatné funkční assety:

- sytá ručně malovaná 2D cartoon ilustrace bez pixel artu;
- silné, hladké tmavě olivově hnědé obrysové linky;
- tvarované barevné plochy, dva až čtyři kroky malovaného/cel stínování a jen
  výběrové měkké přechody;
- teplé světlo zleva shora, zřetelné materiálové odlesky a kontrolované kontaktní
  stíny;
- ostré čitelné žilkování listů a jednotná materiálová kresba dřeva, keramiky,
  skla, kovu, zeminy a vegetace;
- uvěřitelné vzájemné měřítko, sdílené baseline a fyzické usazení předmětů;
- žádné nalepené výřezy, bílé lemy, napevno vykreslená šachovnice, pixel art,
  ploché placeholdery ani lesklý 3D render.

Současné ikony, tlačítka, navigační lišta a jejich funkce jsou zachované. Nový
styl se na staré runtime assety nepřeznačuje zpětně: obrazovka může přejít na
`phase147_approved_painted_cartoon_v1` teprve po dokončení celé její viditelné
rodiny prostředí a dynamických vrstev. Tím se v jedné vydané obrazovce nemíchá
starý a nový výtvarný jazyk.

## Produkční pořadí

1. Pokoj — prostředí, 12 koupitelných rostlin, keramika, dekorace, úspěchy a
   budoucí kočičí kout jako samostatné funkční vrstvy.
2. Skleník — dva pěstební boxy a všechny růstové/stavové vrstvy.
3. Stojan a detail rostlin — každá růstová fáze a stav péče.
4. Sklad, obchod a měření.
5. Modální ilustrace. Stávající HUD a navigační chrome se zachovají.

Pozice se standardně zachovávají. Velikost lze upravit pouze tehdy, když je to
nutné pro uvěřitelné reálné měřítko, čitelnost nebo bezpečnou dotykovou oblast;
taková změna zůstává samostatně posouditelná.

## Fáze 147 — uložené návrhové zdroje

| Soubor | Role | SHA-256 | Runtime |
|---|---|---|---|
| `approved-painted-cartoon-style-master-v1.png` | závazná kalibrace linky, barvy, světla, stínu a materiálu | `20E5251D8A967D09D4AD6BBFD8BFB40A4CF2093ADC120774114F4D925B9C5F80` | reference only |
| `player-room-painted-cartoon-production-target-v1.png` | kompoziční cíl Pokoje ve schváleném stylu | `26A4387743AEBA8B9F464493D2563BF584620D28E2539E13E73EB076B421794D` | reference only |
| `player-room-painted-cartoon-empty-environment-v1.png` | čistá malovaná základna prostředí bez pohyblivých dekorací | `C88708F5B26FB9F817C9535DAFDD87EB380D8F2D20D7F82B1A52EEFC40CEF9E6` | source only |
| `player-room-painted-cartoon-plants-atlas-checker-source-v1.png` | výtvarný zdroj 12 rostlin | `0735BB39144E113228088973DE87B4A4C655D5557391477D54E0BE4513572D24` | forbidden until real alpha isolation |
| `player-room-painted-cartoon-decor-atlas-checker-source-v1.png` | výtvarný zdroj dekorací | `6E56BD543A7FFB423A1F82D0CE73A317C87C88B7FB9516262F3F5B84F5179C8C` | forbidden until real alpha isolation |

Oba atlasové zdroje jsou RGB a jejich šachovnice je součást obrazu, nikoli alfa
kanál. Proto nesmějí být zkopírovány do `assets/` ani použity v runtime. Fáze 148
z nich po výslovném souhlasu uživatele vyrábí verzované RGBA vrstvy výhradně
změnou alfa kanálu; zdrojové RGB zůstává bajtově nezměněné. První kompletní
produkční integrace Pokoje je tím hotová, ostatní obrazovkové rodiny masteru
zůstávají v plánovaném pořadí.

## Hranice přijetí

Schválení výtvarného masteru neznamená schválení budoucího skutečného Godot
renderu. Každá kompletně převedená obrazovka musí projít automatickou validací,
skutečným Godot capturem a samostatným lidským vizuálním přijetím. Fyzický Android
audit zůstává oddělený a odložený, dokud telefon nebude k dispozici. Immutable
RC55, save schema 41, ekonomika a herní logika se touto source-only fází nemění.

Úplná validation `.godot/validation/20260824-182814Z` prošla s 1 478/1 478
kontrolami a markery `HOW_TO_GROW_CAPTURE=PASSED`,
`HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Tato brána
potvrzuje pouze bezpečný style-lock a nezměněný současný runtime; není náhradou
za budoucí posouzení skutečně překresleného Pokoje. Závěrečný Quick
`.godot/automation/20260824-183156Z` prošel s
`HOW_TO_GROW_AUTOMATION=PASSED`; visual contract eviduje 353 profilovaných,
0 neprofilovaných a 133 runtime PNG. Device gate nebyl vyžádán a lidská brána
zůstává `PENDING_SINGLE_HUMAN_BATCH`.

Fáze 148 následně dokončila první obrazovkovou rodinu: malované prostředí Pokoje,
12 rostlin a 9 dekorací už běží pod tímto masterem jako samostatné funkční vrstvy.
Interní kontrola nativního Godot renderu prošla; subjektivní uživatelské a mobilní
přijetí zůstávají oddělené.
