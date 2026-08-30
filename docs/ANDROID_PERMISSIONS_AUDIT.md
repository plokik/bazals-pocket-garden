# Android permissions audit pro RC59

Datum auditu: **2026-08-30 (Europe/Prague)**

Stav: `SOURCE_AND_AUDIT_APK_PASSED_FINAL_AAB_PENDING`

Auditovány byly:

- `android/build/src/main/AndroidManifest.xml`;
- `CareNotificationBridge.java`, `CareNotificationReceiver.java` a
  `CareBootReceiver.java`;
- `scripts/services/care_notification_service.gd` a backup flow v
  `scripts/main.gd`;
- auditní ARM64 APK
  `.godot/rc59-size-audit/20260830-phase167-exclusion/bazals-pocket-garden-current-arm64-debug.apk`,
  SHA-256 `4CC735FA8470432EE3E7CA32EDD483EDFA17432DD067613F3E0CFBCF0213CADC`.

`aapt2 36.1.0` v auditním APK potvrdil package `com.howtogrow.game`, min SDK
24, target/compile SDK 36 a právě dvě oprávnění níže. Jde o technický auditní
build s identitou RC58, nikoli finální RC59 AAB.

## Deklarovaná oprávnění

| Oprávnění | Proč existuje | Chování při odmítnutí / omezení | Verdikt |
| --- | --- | --- | --- |
| `android.permission.POST_NOTIFICATIONS` | dobrovolné systémové upozornění na kontrolu rostliny | Android 13+ může uživatel odmítnout; hra dál funguje a zachová in-app připomínky | potřebné a uživatelsky ovladatelné |
| `android.permission.RECEIVE_BOOT_COMPLETED` | po restartu znovu naplánuje již lokálně uloženou připomínku | bez broadcastu se připomínka po restartu nemusí obnovit; herní save není dotčen | úzce odůvodněné |

Android 13+ používá runtime oprávnění pro běžná oznámení:
[Notification runtime permission](https://developer.android.com/develop/ui/compose/notifications/notification-permission).

## Výslovně nepřítomná oprávnění

- `INTERNET`;
- `ACCESS_NETWORK_STATE`;
- location (`ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`);
- kamera, mikrofon, kontakty, kalendář, telefon, SMS;
- `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`, `MANAGE_EXTERNAL_STORAGE`
  a `READ_MEDIA_*`;
- reklamní ID;
- `SCHEDULE_EXACT_ALARM` a `USE_EXACT_ALARM`.

Absence `INTERNET` je ověřena z auditního APK, ne pouze ze zdrojové šablony.
Hra tedy sama nemůže navazovat běžná internetová spojení. Dobrovolné
univerzitní odkazy předává systémovému prohlížeči mimo proces hry.

## Připomínky a alarmy

`CareNotificationBridge.scheduleReminder()` používá
`AlarmManager.setAndAllowWhileIdle()`. Jde o nepřesný alarm; systém jej může
doručit později kvůli Doze nebo šetření baterie. Hra správně nežádá zvláštní
přístup pro exact alarm. Android tento postup doporučuje pro uživatelskou akci,
která má proběhnout po určité době, ale nevyžaduje přesný okamžik:
[Schedule alarms](https://developer.android.com/develop/background-work/services/alarms).

Lokální `SharedPreferences` obsahují čas spuštění, číslo slotu, titulek a text
připomínky a jednorázový příznak, že už byla vyžádána notification permission.
Receiver po zobrazení smaže data naplánované připomínky; příznak permission
promptu zůstává lokální. Oznámení má private visibility.

## Systémový výběr zálohy

Export/import `.htgbackup` volá `DisplayServer.file_dialog_show()` a uživatel
vybírá konkrétní dokument. Manifest nežádá široký přístup k souborům. Storage
Access Framework poskytuje přístup pouze k uživatelem zvolené položce bez
storage permission; viz
[Access documents and other files](https://developer.android.com/training/data-storage/shared/documents-files).

## Android komponenty

| Komponenta | Export | Účel |
| --- | --- | --- |
| launcher alias | `true` | standardní spuštění z launcheru |
| Godot activity | `false` v projektové šabloně | interní cílová activity aliasu |
| `CareNotificationReceiver` | `false` | přijme explicitní lokální PendingIntent |
| `CareBootReceiver` | `true` | přijme systémové `BOOT_COMPLETED` a `MY_PACKAGE_REPLACED` |

PendingIntent používá `FLAG_IMMUTABLE`. Aplikace má `allowBackup=false` a
`requestLegacyExternalStorage=false`.

## Zbývající RC59 kontroly

- [ ] Stejný audit zopakovat na podepsaném release AAB a na APK vytvořených
  bundletoolem.
- [ ] Potvrdit, že release pipeline prošla přesným allowlistem pouze
  `POST_NOTIFICATIONS` a `RECEIVE_BOOT_COMPLETED` a negativním DEX scanem
  analytiky, reklam, billingu, attribution a sociálních SDK.
- [ ] Ověřit merged manifest pro portrét, `appCategory=game`, `isGame=true`,
  launcher a exportované komponenty; zdrojový preset a šablona se nesmí posuzovat
  odděleně.
- [ ] Spustit runtime test povolení i odmítnutí oznámení.
- [ ] Fyzicky ověřit naplánování, opožděné doručení, restart a otevření správného
  slotu bez zpřístupnění raw save.
- [ ] Ověřit picker exportem i importem na skutečném Androidu.
- [ ] Každou budoucí změnu SDK znovu porovnat s Data safety deklarací.
