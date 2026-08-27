# Fáze 156 — RC56 Android handoff

Stav implementace: `PHASE156_RC56_ANDROID_HANDOFF=IMPLEMENTED`

## Cíl

Fáze 156 balí schválené dynamické obrazovky Pokoje, Skleníku, Skladu,
Obchodu, Měření a Herbáře z fází 149–155 do nového Android kandidátu. Zdrojová
identita je `0.67.0-rc56`, Android version code 73 a save schema zůstává 41,
protože se nemění datový formát uložené hry.

## Bezpečnostní hranice

- immutable RC55 `0.66.0-rc55` se nepřepisuje ani nemaže;
- instalace do telefonu používá aktualizaci bez vymazání aplikačních dat;
- raw save se neukládá do důkazů a audit uchovává jen sanitizovaný souhrn;
- publikování zůstává `OUT_OF_SCOPE_BY_USER`;
- technický automatický výsledek, technický audit skutečného zařízení a lidské
  posouzení vzhledu a dotyku zůstávají samostatné brány.

## Brány

- `PHASE156_SAVE_SCHEMA=41_UNCHANGED`
- `PHASE156_RC55_IMMUTABILITY=PRESERVED`
- `PHASE156_INSTALL_DATA_POLICY=PRESERVE_APP_DATA`
- `PHASE156_PUBLISHING=OUT_OF_SCOPE_BY_USER`
- `PHASE156_TECHNICAL_VALIDATION=PASSED`
- `PHASE156_APK=READY_IMMUTABLE`
- `PHASE156_APK_SHA256=91C48EC2DE794E1A83901585CCC998E31A50396E679CE785B98BD26FA2FA3AE7`
- `PHASE156_DEVICE_GATE=PASSED_TECHNICAL`
- `PHASE156_PHYSICAL_VISUAL_AUDIT=FAILED_DETAIL_HEADER_OVERFLOW`
- `PHASE156_HUMAN_MOBILE_ACCEPTANCE=NOT_CLAIMED`
- `PHASE156_SUPERSEDED_BY=PHASE157_RC57`

Technická automatizace i audit připojeného Xiaomi prošly bez pádu, ANR nebo
poškození save. Následná fyzická navigace však odhalila, že pravé tlačítko
`HERBÁŘ` v detailu rostliny přetékalo za pravý okraj. RC56 proto zůstává
immutable důkazem, ale není aktuálním kandidátem k lidskému převzetí.
