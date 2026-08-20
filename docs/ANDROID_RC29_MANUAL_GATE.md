# RC29 — ruční Android brána

Tento runbook uzavírá pouze lidskou část interního kandidáta `0.45.0-rc29` / code 46 / save schema 28. Automatický skript nesmí sám změnit výsledek na `PASSED`.

## Identita běhu

- Tester:
- Datum a čas:
- Zařízení / Android:
- APK: `builds/android/bazals-pocket-garden-0.45.0-rc29-arm64-debug.apk`
- Očekávaný SHA-256: `E10D2F655310E98AD4ACB3F0490145592A222D4B2049225D364FF5FF7BB51EA7`
- Adresář technického auditu:
- Důkazové screenshoty nebo video:

## Předpoklady

1. Telefon je odemčený, interaktivní a je připojené právě jedno autorizované zařízení.
2. Kandidát se instaluje přes předchozí sestavení bez mazání dat.
3. Technický audit se spustí z kořene projektu:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\run_android_device_audit.ps1 -Install -ApkPath 'C:\_projekty\How to grow_\builds\android\bazals-pocket-garden-0.45.0-rc29-arm64-debug.apk' -SampleSeconds 300
```

4. `APK identity`, crash/ANR, save schema a stabilní save pole musí skončit `PASSED`. Oznámení nebo alarm označený pouze `AVAILABLE` není ruční průchod.

## Poslední technický předběh

- Běh: `.godot/android-device-audit/20260820-043712Z`
- Zařízení: Xiaomi `2201116SG`, Android 13 (SDK 33), 1080 × 2400, výřez nahoře 90 px
- Výsledek: `TECHNICAL_GATE=PASSED`; nainstalovaný APK má očekávaný SHA-256, save schema zůstalo 28 → 28 a stabilní postup se zachoval
- Stabilita: 300 sekund, 54/54 platných odemčených a interaktivních vzorků, 100 % v popředí, 0 crash/ANR/Godot fatal nálezů
- Rozsah důkazu: technický předběh sám nepotvrzuje žádný z níže uvedených osmnácti ručních bodů

## Kontrolní body

U každého bodu doplňte `PASS`, `FAIL` nebo `BLOCKED` a cestu k důkazu. Bez výsledku všech osmnácti bodů zůstává `PHYSICAL_ANDROID_MANUAL_GATE=PENDING`.

| ID | Kontrola | Podmínka PASS | Výsledek / důkaz |
|---:|---|---|---|
| 01 | Aktualizace bez ztráty save | RC29 je nainstalované přes předchozí build; schema přejde 23 → 28 a úroveň, mince i obsazené květináče se zachovají. | |
| 02 | Safe area a čitelnost | Kamera ani výřez nezakrývají text; všechny dotykové cíle jsou viditelné a dosažitelné. | |
| 03 | Scroll a swipe | Svislý scroll funguje ve Skladu, Obchodu, Měření a Deníku; vodorovný swipe funguje mimo jejich scroll plochy. | |
| 04 | Export zálohy | Android document picker vytvoří čitelný soubor `.htgbackup`. | |
| 05 | Náhled importu | Před potvrzením import ukáže očekávanou úroveň, mince a obsazené květináče. | |
| 06 | Potvrzený import | Import obnoví záměrně změněný postup a obnovený stav přežije restart aplikace. | |
| 07 | Dvojí potvrzení nové hry | První `ZAČÍT NOVOU HRU` pouze zobrazí varování; reset provede až `OPRAVDU ZAČÍT ZNOVU`. | |
| 08 | Náhled předchozí hry | Po resetu `OBNOVIT PŘEDCHOZÍ HRU` ukáže původní hodnoty ještě před potvrzením. | |
| 09 | Obnova předchozí hry | `POTVRDIT NÁVRAT` obnoví původní postup a ten přežije restart aplikace. | |
| 10 | Zrušení pickeru | Zrušení document pickeru nevytvoří falešný návratový souhrn. | |
| 11 | Pozadí a celý cyklus | Návrat z pozadí započte skutečný čas, načte save a umožní dokončit alespoň jeden celý pěstitelský cyklus. | |
| 12 | Testovací oznámení | Volba `OVĚŘIT UPOZORNĚNÍ ZA 20 S` doručí systémové oznámení po zavření nebo opuštění aplikace. | |
| 13 | Cíl oznámení | Klepnutí na oznámení otevře přesný květináč nebo Sklad podle payloadu. | |
| 14 | Systémové Zpět | Pořadí je modal → detail rostliny → vedlejší záložka → Rostliny → bezpečné ukončení. | |
| 15 | Reálný čas v detailu | Detail nemá pause/speed ovladače, ukazuje ETA a po návratu odpovídá skutečně uplynulému času. | |
| 16 | Oznámení po restartu | Běžná připomínka dorazí po zavření aplikace a naplánování se obnoví po restartu telefonu. | |
| 17 | Komfort animací | Při plném stojanu, scrollu a otevírání modalů nejsou rušivé záseky, trhání ani nepříjemný pohyb. | |
| 18 | Baterie a teplota | Po reprezentativním průchodu tester vyhodnotí spotřebu a zahřívání jako přijatelné; zapíše počáteční a konečné hodnoty. | |

## Povinný výkonový vzorek

Před bodem 17 projděte alespoň deset minut tyto stavy: plný stojan, rychlý scroll Obchodu, otevření větších modalů, detail rostliny a návrat aplikace z pozadí. Zapište délku vzorku, pozorované záseky, počáteční a konečnou baterii a teplotu. Krátké `gfxinfo` z automatického auditu je pouze evidence, ne PASS.

## Závěr

- `PHYSICAL_ANDROID_MANUAL_GATE=`
- Neúspěšné nebo blokované body:
- Odkaz na důkazy:
- Podpis testera / datum:

Výsledek smí být `PASSED` pouze tehdy, když je všech 18 bodů ručně označeno `PASS` a technická brána stejného APK také prošla. Release keystore, podepsané AAB a store review se uzavírají samostatně jako `PUBLISHING_GATE`.
