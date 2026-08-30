# Phase170 — malované podmisky ve stojanu ROSTLINY

## Rozsah a výsledek

Uživatel požádal o nahrazení plochých tyrkysových podmisek v pěstitelském
stojanu. Oprava se týká pouze obrazovky **ROSTLINY**, nikoli sbírkového
Pokoje nebo detailu rostliny. Nová nízká terakotová keramika má vlastní
malovaný okraj, mělkou perspektivu a jemný kontaktní stín na dřevě.

```text
PHASE170_RACK_SAUCERS=IMPLEMENTED_SOURCE_ONLY
PHASE170_FOOTPRINTS=PASSED_67
PHASE170_FOCUSED_TESTS=PASSED_29
PHASE170_REGRESSION=PASSED_6640
PHASE170_GEOMETRY_MATRIX=PASSED_1340_LAYOUTS
PHASE170_GPU_CAPTURE=PASSED_8_FRAMES
PHASE170_INTERNAL_VISUAL_REVIEW=COMPLETED_DESKTOP
PHASE170_FULL_VALIDATION=FAILED_4_OF_34_VISUAL_GATES
PHASE170_QUICK=PASSED
PHASE170_USER_VISUAL_ACCEPTANCE=SAUCER_APPROVED_RACK_POSITION_REJECTED
PHASE170_ANDROID_ACCEPTANCE=NOT_RUN_APK_DEFERRED_BY_USER
```

**Nejde o úplný validační PASS.** Funkční kontroly a Quick prošly,
ale čtyři obrazové brány překročily toleranci starého vzhledu. Reference
ani limity se bez schválení nového renderu nepřepisují. Níže je doloženo,
že nové rozdíly těchto čtyř scénářů leží pouze u upravených květináčů.

Následná zpětná vazba uživatele schválila novou podmisku, ale odmítla
usazení celé rostliny vůči stojanu. Na tuto zbývající výhradu navazuje
[Phase171 — přemalovaný stojan a společná dosedací linie](PHASE171_PAINTED_RACK_GROUNDING.md).
Historický výsledek validace Phase170 se tím zpětně nemění.

## Příčina a oprava

- Původní podmiska nebyla malovaný asset: `_draw_phase151_rack_grounding`
  skládal zploštělé kruhy s výplní `#11a9b9` a odleskem `#70edf1`.
  Šířka vycházela z celého plátna rostliny, nikoli ze spodku keramiky.
- Celý květináč se nad statickou podmiskou houpal, otáčel a měnil měřítko.
- Zdrojové PNG mají rozdílný průhledný spodní okraj. Obzvlášť levandule
  `seed` a `young` mají skutečný spodek výrazně výše než konec plátna.

Nový `rack_planter_grounding.gd` používá jednou načtená, předem změřená
data pro všech **67 textur**: šest stavů jedenácti druhů a prázdný květináč.
Spodní kontaktní bod a šířka vycházejí z alfa nad 127/255 v posledních
60 pixelech skutečné siluety. Rozměr původního sprite zůstává stejný;
mění se pouze jeho posunutí na skutečný kontakt s podmiskou.

Podmiska má šířku 1,24× změřené základny květináče. Zachovává poměr stran
malby, její spodek leží na původní polici a keramika dosedá v 70 % její
výšky. Celý květináč už nebobuje ani nerotuje; ambientní světlo, prach,
výběr a efekty sklizně zůstávají živé. Stavové ikony, cedulky, hitboxy,
růst, sklizeň a save se nemění. Fialové zamčené květináče mají nadále
svou původní zapečenou podmisku.

Builder `tools/build_phase170_rack_footprints.py` čte PNG a zapisuje pouze
JSON měřicí data. `--check` znovu nezávisle změří a ověří manifest bez
zápisu. Runtime nečte zpět GPU textury a neprochází jejich pixely.

## Asset a původ malby

- Produkce: [rack_ceramic_saucer_phase170_v1.png](../assets/ui/visual/phase170/rack/rack_ceramic_saucer_phase170_v1.png).
- RGBA 2172 × 724, SHA256
  `CF9A59E9ECEB000CDE7BE7D452D7A790619766FF5CACDC80BEC8E55D4FC82B86`.
- Manifest: `assets/ui/visual/phase170/rack/phase170_saucer_manifest.json`.
- Explicitní profil `rack_ceramic_saucer_phase170`, lossless import,
  lineární filtrování s mipmapami a doplněním RGB transparentních okrajů.
- Runtime zdrojový obdélník `[56, 98, 2062, 528]` vynechává vzdálené
  zbytky alfa do 4/255 a ponechává jednobodový okraj antialiasingu.
  Žádné pixely uloženého PNG se kvůli tomu neupravovaly.

Použit byl vestavěný **imagegen**, nikoli externí API nebo Pythonová
přemalba. První pokus byl příliš hluboký a zlatý; druhý měl správnější
keramiku, ale neprůhlednou šachovnici. Ani jeden není použit v runtime.
Finální transparentní výstup byl beze změny zkopírován z:

`C:/Users/drikv/.codex/generated_images/019ff205-6305-74c1-82b8-7c71e77613d0/exec-1cd30784-dc3c-4812-b7ad-37176fc5d656.png`

Stylový prompt pro druhou variantu:

```text
Use case: precise-object-edit. Refine ONLY this single plant saucer production sprite. Keep the clean hand-painted cartoon rendering, level frontal ellipse, symmetry, beveled ceramic lip and centered composition. Make it a LOW shallow practical earthenware plant saucer with overall visible width about 4x height, a thin front wall; currently it is too tall/deep. Change the bright metallic golden-orange surface to warm natural matte terracotta-clay / honey-brown ceramic with a gently cream-tan lip. Highlights soft and restrained, not polished gold, no neon yellow. Match warm wooden garden shelves and teal pots, but do not draw any shelf or pot. Remove ALL external glow, all surrounding blurry painted haze, all drop shadow; outside the clean saucer silhouette must be fully transparent alpha (the game adds its own contact shadow). Preserve a crisp dark-brown outline with clean antialiased transparent edges, not black borders. Exactly one asset, no background, no text, no scene, no extra objects, no comparison collage. Genuine transparent background, no checkerboard. High resolution 1536x1024 canvas with transparent padding.
```

Finální prompt, se druhou variantou jako referencí:

```text
Use case: background-extraction. The input contains a good terracotta plant saucer but an INCORRECT baked white checkerboard background. Remove the checkerboard completely and deliver the exact saucer as a cutout on genuine RGBA transparency. No visible backdrop at all. Preserve the existing shape, position, colors, thin rim, texture, contour and shallow 4:1 proportion; do not redesign or repaint the saucer. Every pixel outside its silhouette should have alpha=0, no white/gray halo, no added shadow or glow. The interior of the bowl is solid painted ceramic, NOT a transparent hole. Exactly one centered saucer, no other objects. Output transparent PNG.
```

## Skutečné snímky a ověření

Hlavní [snímek celé hry](visual-proposals/phase170/phase170-rack-runtime.png)
je skutečný GPU render Godotu, nikoli generovaný náhled. Další důkaz
ukazuje [stav po sklizni](visual-proposals/phase170/phase170-rack-post-harvest.png).
Šest nativních snímků ve stejné složce zachycuje tři sady druhů/stavů
v běžném i kratším stojanu: všechny druhy, levanduli s rozdílným paddingem,
prázdný květináč, růst, nemoc, úhyn i sklizený stav. Všech osm snímků
bylo interně vizuálně prohlédnuto. Původní případné přesahy vysokých
korun u dolních světel nebo délka cedulky majoránky nejsou touto
opravou prohlášeny za vyřešené; malba a rozměry rostlin jsou zachované.

- Cílená sada `.godot/phase170-first/`: native exit 0,
  `PHASE170_TESTS_PASSED=29`, včetně 14 nových souhrnných kontrol.
- Matice měří 67 zdrojů × 10 pozic × 2 velikosti = **1 340 geometrií**.
  Ověřuje kontakt, nezkreslený rozměr, volný prostor nad cedulkou,
  původní SHA všech rostlin a zachování zamčených slotů i detailu.
- Cílený GPU capture `.godot/phase170-rack-v1/`: native exit 0,
  `PHASE170_RACK_CAPTURE=PASSED`, `HOW_TO_GROW_CAPTURE=PASSED`,
  prázdný stderr; GL Compatibility na NVIDIA GeForce RTX 3050 Ti.
- Úplný runner `.godot/validation/20260828-193100Z/` provedl import,
  regresi a GPU capture. `MVP_TESTS_PASSED=6640`; **30/34 obrazových
  bran PASS, 4 FAIL**, `HOW_TO_GROW_VISUALS=FAILED`, native exit 1.
- Quick `.godot/automation/20260828-193710Z/`: VisualContract a
  6 640 regresních kontrol PASS, native exit 0,
  `HOW_TO_GROW_AUTOMATION=PASSED`. Quick neprovádí pixelové porovnání
  a neruší výše uvedené čtyři FAIL výsledky.

Neprošlá porovnání vůči stále chráněným referencím:

| Obrazová brána | Výsledek | Původní limit |
| --- | ---: | ---: |
| guide-explain | změněno 6,3807 % | 6 % |
| guide-warning | změněno 6,3973 % | 6 % |
| phase163-feedback-unlock-runtime-approved | RMSE 15,245203 | 12 |
| phase163-screen-transition-runtime-approved | RMSE 14,472686 | 12 |

Porovnání skutečných snímků s posledním Phase169 během
`.godot/validation/20260828-180417Z/` lokalizovalo **všechny nové změněné
pixely** těchto čtyř scénářů do obdélníku x 109–814, y 834–1084
v obrazu 1080 × 2400: čtyři aktivní květináče a podmisky.
Dialogy, postava, přechodový efekt i okolí jsou mimo něj pixelově stejné.
Obě brány průvodce už historicky obsahovaly starší podobu světel a
zamčených nádob; jejich stávající rozdíl se nyní pouze zvětšil o podmisky.
Porovnání i heatmapy všech neprošlých scénářů byly prohlédnuty.

Všech 54 případů zachovalo oproti Phase169 stejný hash reference,
režim brány, normalizovaný rozměr, pixelovou toleranci, počet maskovaných
pixelů a prahy. Samotný manifest byl navíc hashově zachován.

## Zachování projektu a další krok

Kontrola **103 předem chráněných souborů** potvrdila nula změn:
původní rostliny, pokojové assety Phase169, stojan a světla, zamčené
nádoby, schéma/verze/export, herní relace, hlavní scéna, detail,
sbírkový Pokoj, validační manifest i immutable RC58 zůstávají zachované.
Existující rozpracovaná práce Phase166–169 nebyla vrácena ani commitnuta.

APK `0.68.0-rc58` / code 75 / schema 41 zůstává původní, SHA256:
`0A7F173D8C97B552168A407C31F1F8AE85109A34C2F6F4786029551064F0C6F5`.
Nebyl proveden build, instalace, zásah do hráčského save ani cleanup.

Další krok je schválení skutečného renderu uživatelem. Teprve potom lze
přidat nové verzované obrazové reference se stejnými přísnými limity
a znovu ověřit celý průchod. Fyzické přijetí Androidu zůstává samostatné.
