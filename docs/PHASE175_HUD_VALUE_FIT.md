# Phase175 — celé hodnoty dne a mincí v HUD

## Oprava

Pevné textové obdélníky horního HUDu byly užší než skutečná malba
Poppins ExtraBold včetně obrysu a stínu. Godot proto přes `clip_text`
usekával například `DEN 1305` a u sedmimístného zůstatku zobrazil jen
prostřední číslice.

Den a mince nyní používají shodnou bezpečnou responzivní šířku. Společný
`hud_text_fitter.gd` změří skutečnou šířku malby při každé změně hodnoty
i velikosti labelu a zvolí největší font, který se celý vejde. Krátké
hodnoty zůstávají velké; dlouhé hodnoty se nezkracují suffixem ani
oddělovačem a `clip_text` zůstává poslední pojistkou.

Kresba tří karet, slunce, PNG mince, panel úrovně, XP, herní ekonomika,
save a ostatní obrazovky se nemění.

## Skutečný Godot render

GPU capture `.godot/phase175-after/captures` obsahuje šest stavů:
krátké, sedmimístné a extrémně dlouhé hodnoty pro 432 × 960 i 360 × 800.

- normální: `DEN 1305`, `1234567`, font 12 / 13;
- kompaktní: `DEN 1305`, `1234567`, font 10 / 11;
- extrémní kompaktní: `DEN 1000000`, `999999999`, font 7 / 8.

Ve všech případech je šířka malby nejvýše 49,28 px v kompaktním a
59,94 px v běžném panelu. Capture sám skončí chybou, pokud text limit
překročí.

Porovnání krátkého běžného HUDu před/po má 8 948 změněných pixelů,
všechny pouze ve dvou textových oblastech. Mimo den a mince je změněno
0 pixelů; panel úrovně má rovněž 0 změněných pixelů.

## Ověření

- cíleně `.godot/phase175-focused`: `PHASE175_TESTS_PASSED=32`, exit 0;
- hodnoty dne 7, 10, 999, 1305 a 1000000;
- mince 42, 420, 1234567 a 999999999;
- obě produkční šířky 432 a 360, obnovení velkého fontu a zachování
  animačního `scale` mince;
- GPU `.godot/phase175-after`: `PHASE175_HUD_CAPTURE=PASSED`, exit 0;
- úplná validace `.godot/validation/20260829-005654Z`:
  `MVP_TESTS_PASSED=6701`, capture PASS, samostatná brána `hud` PASS
  (MAE 0,184; RMSE 0,786; změněné nemaskované pixely 0,000 %).
- závěrečná Quick `.godot/automation/20260829-010437Z`: VisualContract,
  Regression a technická brána PASS, `HOW_TO_GROW_AUTOMATION=PASSED`.

Celková obrazová validace zůstává **FAILED, 24/34 aktivních bran PASS**.
Jde o přesně stejnou množinu deseti dříve známých neprošlých porovnání
stojanu a detailu jako v Phase174; všechny byly znovu prohlédnuté.
Oprava HUD nepřidala novou neprošlou bránu. Reference, masky a tolerance
se neměnily.

`PHASE175_LOCAL_TECHNICAL_HUD=PASSED`.
`PHASE175_USER_VISUAL_ACCEPTANCE=PENDING_USER_REVIEW`.
`PHASE175_ANDROID_ACCEPTANCE=NOT_RUN_APK_DEFERRED_BY_USER`.

Immutable RC58 i APK zůstávají beze změny.
