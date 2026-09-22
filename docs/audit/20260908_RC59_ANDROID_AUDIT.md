# RC59 — fyzický Android audit 8. září 2026

> Tento dokument uchovává stav původního auditu immutable RC59. Tři
> dohodnuté navazující body aktuálního preview jsou uzavřeny ve
> [follow-upu](20260908_ACCEPTANCE_FOLLOWUP.md). Níže uvedené výsledky
> a markery zůstávají historickým snapshotem tohoto auditního kroku.

RC59 bylo nedestruktivně nainstalováno na připojený Xiaomi 2201116SG
(Android 13 / API 33). Technická kontrola a níže uvedené interakce na telefonu
prošly. Celkový fyzický audit zůstává `PARTIAL`: lidské přijetí obrazu a dotyku,
30 minut aktivního hraní, teplota/baterie a další vyjmenované kroky jsou otevřené.

Při následném ručním hraní vlastník ohlásil nejasnou odezvu větrání při
22 %. Ostatní ovládání podle něj reagovalo. Vyšetření a samostatná oprava
jsou v [záznamu větrání](20260908_VENTILATION_FEEDBACK.md); původní technický
běh níže toto pozdější hlášení neuzavírá.

## Identita a zachování postupu

- Package: `com.howtogrow.game`; cílová verze `0.69.0-rc59`, code `76`.
- SHA-256 cílového i přečteného nainstalovaného APK:
  `206AC5349731D95570E0E59DD43229A5AB608AA139EA78979FCB3DE907021E7D`.
- Předchozí instalace byla **Phase181 preview** s identitou `0.68.0-rc58` /
  code `75`, hash
  `362EC8562B16583BD5EB040CED770074C90999F2740CCCC84A56E32797A773EF`.
  Nebyl to historický immutable RC58; audit proto neprokazuje přímý přechod
  z tohoto immutable artefaktu.
- Podpisy předchozí a cílové instalace byly kompatibilní. Instalace použila
  pouze `adb install -r`; bez odinstalování, mazání dat a nového začátku.
- Sanitizovaný readback zachoval schema `41 → 41`, mince `10`, XP `341`,
  počet slotů `10` a obsazených slotů `4`.

První instalační běh skončil přerušením ADB spojení před runtime vzorkováním.
Jeho `install.txt` potvrzuje úspěšnou instalaci, nikoli úplný technický PASS.
Následující samostatný audit ověřil přesný hash již nainstalovaného RC59.

Zdroje: [preflight](../../.godot/rc59-phone-session/20260908-180415Z/preflight.json),
[instalace](../../.godot/android-device-audit/20260908-180607Z/install.txt),
[dokončený audit](../../.godot/android-device-audit/20260908-180727Z/report.md).

## Dokončené technické ověření

Audit `20260908-180727Z` běžel 300 sekund: **53/53 platných vzorků**,
**100 % aplikace v popředí**, **0 package-scoped fatal/ANR nálezů**.
Identita APK, schema a stabilní hodnoty save prošly. Android `gfxinfo`
neposkytlo data pro nativní GL povrch (`UNAVAILABLE_NATIVE_GL`); výsledek
není měřením FPS ani potvrzením výkonu.

Úplná regrese zdrojů skončila `MVP_TESTS_PASSED=6747`.
Auditní pomocník nově hlídá neplatný save a neodemčené zařízení a zachovává
původní logcat buffery; cílená sada jeho mock kontrol prošla `60/60`.
Změny tohoto auditního kroku jsou v nástroji a dokumentaci; nainstalované immutable APK
se tím nezměnilo.

Zdroje: [stav technických bran](../../.godot/android-device-audit/20260908-180727Z/audit-status.txt),
[regresní výstup](../../.godot/rc59-phone-session/20260908-180415Z/regression-output.txt),
[auditní pomocník](../../tools/run_android_device_audit.ps1).

## Pozorované interakce na telefonu

Interakce byly provedeny přes ADB a ověřeny snímky aplikace a sanitizovanými
readbacky. Potvrzují zpracování těchto vstupů na skutečném telefonu;
subjektivní pohodlí fyzického dotyku a vzhledu čeká na vlastníka.

| Oblast | Výsledek a rozsah |
| --- | --- |
| Navigace | `PASSED`: Rostliny, Sklad, Obchod, Měření; swipe v obou směrech; systémové Zpět. |
| Vedlejší pohledy | `PASSED`: Pokoj, detail rostliny, Nastavení, Centrum péče a Skleník. Skleník byl prázdný; rostliny v záhonech nebyly ověřeny. |
| Přesun v Pokoji | `PASSED`: přesun pozice `0 → 1`, výměna `1 ↔ 4`; rozložení přežilo force-stop a nové spuštění aplikace. Indexy jsou od nuly. |
| Obnovení původního rozložení | `PASSED`: obrácená výměna a přesun obnovily původní hash rozložení. Mince, XP, počty slotů a schema zůstaly zachované. |
| Systémový picker | `PASSED_OPEN_CANCEL`: přes ADB ověřeno otevření a zrušení obou pickerů. Vlastník následně potvrdil skutečný export a výběr stejného souboru s náhledem úrovně 4, 10 mincí a 4 obsazených květináčů, následně zrušeným bez obnovy. Potvrzená obnova nebyla provedena. |
| Test notifikace | `PASSED_DELIVERY_AND_TAP`: skutečná testovací notifikace byla zjištěna mimo hru. Vlastník následně potvrdil klepnutí a otevření květináče 1 (bazalky); cílový pohled je zachycen snímkem. |

Hash původního i obnoveného rozložení:
`78d626436d4ab55085b9668fbb07186dc0906ab3786482f1af3b0abed033b918`.
Před restartem i po něm mělo přemístěné rozložení shodný hash
`d3ae14b61771154f1504b183bc15975c8b8cff2a4cdaec0704b0c45748465ff6`.

Při prvním návratu hra zobrazila třídenní offline interval a čtyři uhynulé
rostliny. Rostliny ani postup nebyly vymazány. Bez předinstalačního záznamu
stavu jednotlivých rostlin nelze tento nález označit za novou regresi RC59.

Notifikace: před testem bylo aktivních oznámení tohoto package `0`; po testu
`1`, ID `4401`, přítomen care channel i content intent. Kontrola přibližně
70 sekund po naplánování potvrdila doručení při aplikaci mimo popředí;
nejde o důkaz doručení přesně za 20 sekund. Povolení oznámení bylo udělené
již před auditem, takže odmítnutí a první udělení nebylo testováno.
Vlastník na přímou otázku, zda oznámení otevřelo květináč 1 (bazalku),
odpověděl „ano“. Následný snímek `23-notification-opened.png` dokládá detail
bazalky; konečný sanitizovaný save zachovává stejné hodnoty i původní pokoj.
Na samostatnou otázku o exportu zálohy a výběru téhož souboru s odpovídajícím
náhledem a jeho zrušením vlastník rovněž odpověděl „ano“. Toto je lidské
potvrzení práce s pickerem; záloha nebyla kopírována do auditní evidence.

Závěrečná systémová hodnota baterie v pětiminutovém běhu byla 37,8 °C,
telefon byl napájen z USB. Tento údaj neprokazuje spotřebu při hraní z baterie
ani 30minutovou tepelnou stabilitu.

Zdroje: [snímky a sanitizované stavy relace](../../.godot/rc59-phone-session/20260908-180415Z/),
[původní rozložení](../../.godot/rc59-phone-session/20260908-180415Z/room-before.json),
[obnovené rozložení](../../.godot/rc59-phone-session/20260908-180415Z/room-restored.json),
[před restartem](../../.godot/rc59-phone-session/20260908-180415Z/before-restart.json),
[po restartu](../../.godot/rc59-phone-session/20260908-180415Z/after-restart.json),
[notifikace před testem](../../.godot/rc59-phone-session/20260908-180415Z/notification-before.json),
[notifikace po testu](../../.godot/rc59-phone-session/20260908-180415Z/notification-after.json),
[cílový pohled po klepnutí](../../.godot/rc59-phone-session/20260908-180415Z/23-notification-opened.png),
[konečný save](../../.godot/rc59-phone-session/20260908-180415Z/final-save.json).

## Body otevřené po původním auditu

- Lidské potvrzení obrazu, čitelnosti, safe-area, animací a skutečného dotyku.
- Běžná připomínka na care boundary; odmítnutí a první udělení oprávnění;
  obnova plánování po restartu telefonu. Telefon nebyl restartován.
- Potvrzená obnova `.htgbackup` pouze na testovací kopii a kontrola po restartu.
- Nejméně 30 minut aktivního hraní s posouzením teploty, baterie a plynulosti;
  úplný první herní cyklus, audio focus a další neprovedené systémové kroky.
- Přímý upgrade z immutable RC58 a zbývající kroky
  [úplného fyzického checklistu](../PHYSICAL_ANDROID_AUDIT.md).

```text
RC59_ANDROID_TECHNICAL_GATE=PASSED_300_SECONDS
RC59_ANDROID_SAVE_GATE=PASSED_PHASE181_PREVIEW_TO_RC59
RC59_ANDROID_NOTIFICATION_GATE=PARTIAL_TEST_DELIVERY_AND_TAP_PASSED
RC59_ANDROID_BACKUP_PICKER_GATE=PASSED_EXPORT_PREVIEW_CANCEL_USER_CONFIRMED
RC59_ANDROID_BACKUP_RESTORE_GATE=PENDING_TEST_COPY
RC59_ANDROID_HUMAN_VISUAL_GATE=PENDING
RC59_ANDROID_HUMAN_TOUCH_GATE=PENDING
RC59_ANDROID_THERMAL_BATTERY_GATE=PENDING
RC59_PHYSICAL_ANDROID_AUDIT=PARTIAL
```

Evidence neobsahuje raw save ani serial zařízení; uložené screenshoty
zachycují aplikaci. Publikování nebylo součástí auditu.
