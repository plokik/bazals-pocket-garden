# Malovaný detail rostliny — schválený směr

Uživatel 2026-09-19 schválil výřez odpovědí „ANO, VÝBORNÉ“. Schválený výřez je `approved-direction.png`. Předchozí ploché panely a obrysové ikony nahradil malovaný styl, společný dřevěný rám a barevné ikony. Rozložení a herní akce zůstávají stejné.

Po následném potvrzení „Souhlasím“ je malovaný detail výchozí podobou skutečné `main.tscn` při běžném startu. Přepínač návrhu už není potřeba. `tools/open_detail_study.ps1` nadále otevírá tutéž hru s oddělenou testovací zahradou. Existující instalace Androidu nebyla v tomto kroku aktualizována. Přesný schválený nativní snímek je zaznamenán v `production-approval.json` a zůstává nezměněný.

## Podklady

Jeden atlas `assets/ui/detail_painted_v2/skin_source.png` vznikl vestavěným imagegen podle schváleného výřezu. První výstup obsahoval neprůhlednou šachovnici; proto byl prostřednictvím imagegen upraven na jednolité klíčovací pozadí. Godot odstraní klíčovací barvu a vyřízne oblasti pouze v paměti; původní PNG se nemění. Ikony jsou cachované, panely využívají devítidílné škálování. Text ani hodnoty nejsou součástí atlasu.

Původní zdroj schváleného návrhu: `exec-0318edaf-5abe-4fc5-90e2-8fdf1d12ec50.png`. Zdroj atlasu: `exec-f96cc5a2-8d84-4f0c-bea8-93cc0d80b901.png`.

## Imagegen prompt

Create ONE production UI SKIN TEXTURE ATLAS for Godot, using reference image 1 (user-approved game UI) as the strict style source. This is a single technical sprite-sheet asset, not a mockup. Preserve the exact bold colorful hand-painted comic aesthetic, dark green/brown contours, warm yellow cream surfaces, soft painted bevels and glossy turquoise watering-can style. Output exactly 1536x1152 pixels, four equal columns and three equal rows of 384x384 square cells, precise evenly spaced grid with NO VISIBLE GRID LINES. Real transparent alpha background everywhere outside each sprite, absolutely no checkerboard, no shadows extending to neighbor cells. Each sprite centered in its cell with generous 36 pixel transparent safety margin on all sides. NO text anywhere except the question-mark glyph specified below. NO captions, NO numbers, NO labels, NO plant scene. Row 1 left to right: (1) one EMPTY square rounded panel with warm carved wooden border and pale butter cream painted interior, suitable for nine-slice stretching, corners rounded, center almost uniform subtle diagonal brush grain, no inner ornaments; (2) EMPTY rounded square cream button, dark brown outline and warm raised bevel, light yellow center, exactly the buttons in reference minus all icon/text; (3) EMPTY rounded square turquoise-tinted button with dark teal outline and painted bevel, exact water-button background minus all icon/text; (4) EMPTY rounded square light sage cream panel with olive edge and delicate painted bevel suitable for maturation footer, no leaves or ornaments. Row 2 left to right: (1) blue glossy water droplet icon from reference, (2) green healthy leaf icon from reference, (3) golden sun icon from reference, (4) turquoise watering can icon from reference with handle, left-pointing spout and one blue droplet. Row 3 left to right: (1) ochre rolled-top fertilizer pouch with green leaf emblem from reference, (2) cyan/white curling wind swirls with one green leaf from reference, (3) illustrated open cream herbarium book with brown binding and one little green leaf on page, (4) round turquoise ceramic help badge with a cream question mark '?'. Make all icons large and balanced within their cells, same black-green outline thickness, same lighting from upper left, same two-tone shading, completely isolated on true alpha. Keep all corners and contours crisp without antialiased white halos. This is an atlas consumed as one texture in the game; regular cell placement is crucial. Match the approved illustration, not thin line icons, not flat web UI.

Následná úprava: zachovat všech 12 prvků a rozložení atlasu, nahradit šachovnici čistou barvou RGB(255,0,255), také v otvorech konvičky a mezi částmi větru, bez textů a bez změn kresby.

## Ověření nativní verze

- Explicitní import Godotu: `.godot/painted-v2-import.log`, návratový kód 0.
- Nativní GPU/GUI kontrola: `.godot/painted-v2-title.log`, `DETAIL_STUDY_CHECKS=45`, `DETAIL_STUDY_INTEGRATION=PASSED`, návratový kód 0. Ověřeny skutečné akce péče, zásoby, přepínání rostlin, herbář, návrat, omezení pohybu a rozložení 432×960 / 360×800. Po kontrole následovala pouze úprava odstínu neaktivní ikony slunce; aktuální hratelný start ověřuje i tuto úpravu.
- Aktuální snímek `preview-godot.png` pochází z `.godot/detail-study/play-20260919-150733215Z/detail-study-godot.png`. Hratelné okno emitovalo `DETAIL_STUDY_PLAYABLE=READY`; jeho viditelné okno a název byly ověřeny.
- Zdroj atlasu SHA-256: `5F542615072F73F88D5EF73431338BA6B5E90390E9F090F4591CED8F72FE2782`.
- Spuštění: `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/open_detail_study.ps1 -GodotPath R:\_projekty\Godot_v4.7-stable_win64.exe`.

Regresní běh bez přepínače návrhu: `.godot/validation/20260919-150452Z`. Vlastní kandidát má výše uvedené samostatné GUI kontroly. Android a výkon na fyzickém telefonu nebyly v tomto kroku ověřovány.

Celková regrese dokončena: 6 767 kontrol a všech 34 povinných vizuálních případů prošlo. Markery: MVP_TESTS_PASSED=6767, HOW_TO_GROW_CAPTURE=PASSED, HOW_TO_GROW_VISUALS=PASSED, HOW_TO_GROW_VALIDATION=PASSED. Report: .godot/validation/20260919-150452Z/report.md. Historické případy v režimu report jsou informativní, nikoli nově schválené reference.

## Přijetí do běžné hry

`main.tscn` nyní vždy instancuje malovaný detail i animovanou rostlinu, nezávisle na argumentech spuštění. Z původních 6 767 funkčních kontrol se upravila pouze dvě očekávání prezentace: herbář má pojmenovanou kreslenou ikonu s dotykovým cílem nejméně 44×44 místo 64px textového tlačítka; po vylepšení konvičky zůstává přesné množství 135 ml viditelné ve dvou řádcích i v tooltipu.

Finální cílený běh bez přepínače: `.godot/painted-default-final.log` — 45/45, návratový kód 0. Snímek: `preview-default.png`.

Samostatné porovnání s přesným dříve schváleným snímkem: `.godot/detail-study/painted-default-final/approved-comparison/report.md` — PASS, MAE 0.777, RMSE 9.315, změněné pixely 1.275 %. Používá původní toleranci 4 / 12 / 6 %, žádné masky a žádnou nově odvozenou referenci. Drobné rozdíly odpovídají rozšíření horních dotykových cílů z 42 na 44 px. Konfigurace je v `approved-visual-case.json`.

### Výsledek celkové regrese po přepnutí výchozí obrazovky

Běh `.godot/validation/20260919-151717Z`: `MVP_TESTS_PASSED=6767`, `HOW_TO_GROW_CAPTURE=PASSED`. Celkový vizuální výsledek je **FAILED**, nikoli plný PASS: 30 povinných případů prošlo a čtyři nadále porovnávají detail se starým vzhledem Phase 184.

| Historická kontrola | MAE | RMSE | Změněné pixely |
| --- | ---: | ---: | ---: |
| detail-realtime | 52.611 | 84.954 | 68.622 % |
| feedback-water | 52.582 | 84.935 | 68.595 % |
| feedback-growth | 52.480 | 84.839 | 68.566 % |
| phase151-detail-runtime-approved | 52.611 | 84.954 | 68.622 % |

Všechny čtyři překračují původní prahy MAE 4 / RMSE 12 / změna 6 %. Prohlédnuty všechny čtyři porovnávací PNG; rozdíly jsou v přijaté podobě panelů, ikon, záhlaví a změně rozdělení prostoru detailu, zatímco HUD a navigace zůstávají shodné. Historický capture záměrně skrývá herbář a používá stav sklizně, takže tyto reference nelze poctivě nahradit nově schváleným snímkem rostoucí rostliny. Původní manifest, limity a referenční PNG nebyly změněny. Čtyři historické kontroly zůstávají jako otevřená úloha migrace vizuální sady; tento krok netvrdí kompletně zelené CI ani nový Android release.

Aktuální schválený vzhled má vlastní výše uvedené přísné porovnání, které prošlo bez masek. Schválený referenční snímek zůstal zachován pod původním SHA-256.
