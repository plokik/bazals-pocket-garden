# Fáze 117 — vícezáhonové skleníkové zakázky

Stav: **implementace, úplné automatické brány a immutable RC40 jsou hotové; změna se do telefonu neinstalovala**.

## Cíl

Fáze 117 přidává rozhodování do existujících skleníkových zakázek bez druhého inventáře, nové měny nebo časového limitu. Každá druhá dvousklizňová nabídka je kanonická varianta `multi_bed`: obě odpovídající sklizně musí pocházet ze dvou různých záhonů.

Sklizeň stejné plodiny z již započteného záhonu dál poskytne běžnou odměnu plodiny, ale prémiovou zakázku neposune. Hráč tak volí mezi rychlým opakováním jednoho záhonu a paralelní výsadbou dvou záhonů. Třísklizňová ředkvička zůstává standardní, aby pravidlo bylo krátké a jednoznačné.

| Varianta | Postup | Bonus oproti fázi 116 |
| --- | --- | ---: |
| `standard` | každá odpovídající sklizeň | beze změny |
| `multi_bed` | pouze první odpovídající sklizeň z každého záhonu | +8 mincí a +4 XP |

Varianta nemá denní timeout. Rozpracovaná plodina ani delší offline návrat proto nemohou kontrakt zrušit.

## Save a autorita

`GREENHOUSE_QUALITY_ORDER_SCHEMA = 36` přidává `quality_tier`, kanonický počet různých záhonů a seznam již započtených indexů.

- schema 35 zachová plodinu i dosavadní číselný postup, ale vždy ji načte jako standardní zakázku bez vyšší odměny a bez seznamu záhonů;
- schema 36 povolí `multi_bed` jen na deterministicky určené dvousklizňové sekvenci;
- indexy se deduplikují, omezí na čtyři skutečné záhony a nedokončený stav nikdy neobsahuje cílový počet kreditů;
- postup prémiové varianty se odvozuje pouze z autorizovaného seznamu záhonů;
- cíl, zákazník i oba bonusy se při načtení vždy znovu odvodí z kanonického katalogu.

UI refresh, plynutí času, zálivka, nesprávná plodina ani opakovaná sklizeň stejného záhonu nemohou vytvořit prémiovou odměnu.

## Mobilní prezentace

Stávající stavový panel používá jediný kompaktní řádek `ZAKÁZKA+` s plodinou, počtem různých záhonů a bonusem. Hlavní 64px tlačítko před sklizní rozliší nový započitatelný záhon od již použitého. Nevzniká nový modal ani další tlačítko a pět voleb plodin 64×64 px zůstává beze změny.

Diagnostický snímek `comic-greenhouse-quality-order-ready.png` je pouze reportovací. Schválené reference, crop, masky a tolerance se kvůli fázi 117 nemění.

## Verze a hranice

Zdrojová/exportní identita je `0.54.0-rc40` / code 57 / save schema 36. Immutable RC35–RC39 se nepřepsaly. Fáze nevytváří AAB, nepublikuje hru a během uzavírání fyzického důkazu fáze 112 neinstaluje novou verzi do telefonu.

## Automatické důkazy

- funkční regrese: `MVP_TESTS_PASSED=1351`;
- finální Quick po uzavření dokumentace: `.godot/automation/20260822-042507Z`, `HOW_TO_GROW_AUTOMATION=PASSED`;
- úplná validace po uzavření long-delay dokumentace: `.godot/validation/20260822-042334Z`, capture, visuals i `HOW_TO_GROW_VALIDATION=PASSED`, všech 14 aktivních obrazových bran prošlo;
- vizuální posouzení: prémiový řádek, tlačítko `SKLIDIT · ZAKÁZKA 2/2` i pět voleb plodin zůstávají celé a čitelné na plném i kompaktním obsahu;
- Full: `.godot/automation/20260822-040627Z`, validation, performance, endurance, progression i responsive `PASSED`;
- výkon: CPU p95 max. 9,164 ms, frame p95 max. 16,701 ms a max. 449 draw calls;
- endurance: 48/48, 7 save roundtripů, nulový růst uzlů, orphanů a zdrojů, statická paměť +0,02 MiB;
- progression: 132/132 a 27 diskových save/load roundtripů;
- responsive: 8/8 včetně 360×800;
- release: `.godot/release-candidate/20260822-040931Z`, export, APK v2 podpis, payload a notification payload `PASSED`;
- immutable APK: `builds/android/bazals-pocket-garden-0.54.0-rc40-arm64-debug.apk`, 106 206 088 B, SHA-256 `99927E0D24B4C7DDDBF3B13B191C1ACCB8EB562C6F553B25E685113A163F0D97`.

Hashová kontrola znovu potvrdila původní RC36–RC39. Device gate je `NOT_REQUESTED`, protože RC36 musí zůstat nainstalované do uzavření jeho přirozeného long-delay důkazu. Publikování zůstává `OUT_OF_SCOPE_BY_USER`.
