# Fyzický Android audit RC59

Datum šablony: **2026-08-30**

Aktuální stav (2026-09-08): `CURRENT_PREVIEW_AGREED_ACCEPTANCE=PASSED`.
Rozšířená šablona níže zůstává částečně neprovedená.

Vlastník potvrdil 30 minut hraní bez dalších potíží. Běžná připomínka
dorazila po restartu telefonu a vlastník potvrdil otevření květináče 1.
Skutečná obnova přes Android picker v oddělené aplikaci prošla včetně
before-import zálohy a nového spuštění.
[Dokončené dohodnuté přijetí](audit/20260908_ACCEPTANCE_FOLLOWUP.md).

Přesné RC59 bylo po souhlasu vlastníka nainstalováno na Xiaomi / Android 13.
Technické měření a vybrané interakce jsou doložené v
[auditu 2026-09-08](audit/20260908_RC59_ANDROID_AUDIT.md).
Předchozí instalací byl Phase181 preview s identitou RC58, nikoli immutable
RC58 APK. Níže uvedený ruční checklist zůstává oddělený od automatických
výsledků. Výše uvedené přijetí je omezeno na dohodnuté body aktuálního preview.

Po hlášení nejasné odezvy větrání jej na telefonu nahradilo samostatné
[preview oprav větrání a záhlaví](audit/20260908_RACK_HEADER_CLEANUP.md) se zachovaným
postupem. Verze/code zůstává stejná, přesná identita je určena novým hashem.
Původní immutable RC59 APK se nezměnilo.

## Bezpečnostní podmínky

- [ ] Telefon, serial a vlastnictví jsou potvrzené bez zápisu identifikátoru do
  veřejné dokumentace.
- [ ] Je určen přesný immutable RC59 APK a jeho SHA-256.
- [ ] Package je `com.howtogrow.game` a podpis je kompatibilní s nainstalovanou
  verzí.
- [ ] Před instalací je sanitizovaně přečtena identita verze a save schema;
  raw save se nekopíruje do evidence.
- [ ] RC58 immutable artefakt a jeho hash zůstávají nedotčené.
- [ ] Použije se pouze nedestruktivní update `adb install -r`.
- [ ] Je zakázáno `pm clear`, odinstalování, reset zařízení nebo mazání dat.
- [ ] Přepínač nástroje `-ClearAppData` se pro RC58 → RC59 audit nikdy
  nepoužije; i při samostatném výslovném použití nyní znemožní PASS brány
  zachování save a celé technické brány.
- [ ] Při nesouladu podpisu, package nebo schema se audit zastaví.

## Automatický technický readback

Před a po instalaci zaznamenat pouze sanitizované hodnoty:

| Kontrola | Před | Po | Výsledek |
| --- | --- | --- | --- |
| package / versionName / versionCode | `com.howtogrow.game / 0.68.0-rc58 / 75` (Phase181) | `com.howtogrow.game / 0.69.0-rc59 / 76` | `PASSED` |
| hash instalovaného APK | `362EC856…A773EF` | `206AC534…021E7D` | `PASSED`; úplné hashe v reportu |
| save schema | `41` | `41` | `PASSED / 41_TO_41` |
| mince / XP | `10 / 341` | `10 / 341` | `PASSED` |
| počet slotů / obsazených slotů | `10 / 4` | `10 / 4` | `PASSED` |
| foreground vzorky | n/a | `53/53; 100 %` | `PASSED`, 300 s |
| fatal / ANR | n/a | `0` | `PASSED` v auditním okně |
| notifikační a alarmová evidence | oprávnění udělené | testovací oznámení doručeno; následně běžná připomínka po rebootu aktuálního preview a potvrzený květináč 1 | `PASSED` pro tyto scénáře; první permission flow zůstává oddělený |

Automatický PASS neznamená lidské schválení obrazu, dotyku, teploty nebo
baterie.

## Povinný ruční průchod

### Instalace a save

- [ ] Update proběhl bez vymazání dat.
- [ ] Hra se spustí do očekávaného postupu.
- [ ] Zavření, force-stop a opětovné spuštění zachová postup.
- [ ] Atomické uložení a rotační záloha nevytvoří viditelnou regresi.
- [ ] Skutečný RC58 save je načten jako schema 41 bez migrace na nové schema.

Poškozený nebo příliš nový save testovat na fixture/emulátoru, ne úpravou
jediné reálné kopie hráče.

### Obraz, navigace a vstupy

- [ ] Projít Rostliny, Skleník, Pokoj, Sklad, Obchod a Měření.
- [ ] Ověřit swipe v obou směrech a animovaný indikátor směru.
- [ ] Ověřit systémové Zpět v každém modalu a na hlavních obrazovkách.
- [ ] Ověřit gesture navigation, spodní systémovou lištu a výřez displeje.
- [ ] Zkontrolovat HUD dnů, mincí a XP bez ořezu.
- [ ] Zkontrolovat všechny stojanové květináče, podmisky, světla a jejich
  animace bez nalepených hran, bílého pozadí nebo šedé siluety.
- [ ] V Pokoji podržet, přesunout a vyměnit dva obsazené sloty; restart musí
  rozložení zachovat.
- [ ] Ve Skleníku ověřit sazenice v zemi, hranice všech čtyř záhonů a stavové
  pruhy.
- [ ] Ověřit Profesorovy dialogy, Nastavení, Centrum péče, výběr semene,
  návratový souhrn a potvrzení.

### Připomínky

- [ ] Na čistém permission stavu odmítnout `POST_NOTIFICATIONS`; hra zůstane
  funkční.
- [ ] Následně povolit oznámení přes normální Android UI.
- [x] Naplánovat testovací připomínku a zachytit skutečné oznámení mimo hru. Doloženo 2026-09-08.
- [x] Ověřit běžnou připomínku na reálném care boundary. Přemokřená půda v květináči 1, 2026-09-08.
- [x] Restartovat pouze se souhlasem vlastníka; připomínka se obnoví a nepoužije
  exact alarm. Doručení po restartu a správný cíl potvrzeny 2026-09-08.
- [x] Klepnutí otevře správný květináč/centrum péče. Potvrzeno vlastníkem 2026-09-08 pro testovací květináč 1.

### `.htgbackup`

- [ ] Otevřít systémový picker a zrušit jej bez změny hry.
- [x] Exportovat `.htgbackup` do uživatelem zvoleného místa. Potvrzeno vlastníkem 2026-09-08.
- [ ] Ověřit, že soubor neobsahuje tvrzení o šifrování; checksum je pouze
  integrita.
- [x] Importovat stejný soubor, zobrazit náhled a zrušit bez změny. Vlastník 2026-09-08 potvrdil úroveň 4, 10 mincí a 4 obsazené květináče.
- [x] Potvrdit obnovu až na testovací kopii a ověřit automatickou before-import
  zálohu. Agent přes skutečné Android UI v samostatném package, přesný hash
  předchozího save a readback po restartu, 2026-09-08.

### Offline, systém a výkon

- [ ] Spustit hru v airplane mode; všechny herní funkce kromě otevření externího
  webu zůstávají dostupné.
- [ ] Pozastavit/obnovit aplikaci a přerušit ji systémovým dialogem.
- [ ] Ověřit ztrátu a návrat audio focusu.
- [ ] Projít dostupné 60/90/120Hz režimy bez změny herního času.
- [x] Nejméně 30 minut aktivního průchodu: vlastník 2026-09-08 potvrdil
  hraní bez dalších chyb, výrazného zahřívání nebo zpomalování.
- [ ] Instrumentované měření baterie a stabilní paměti během průchodu.
- [ ] 72hodinový offline limit, posun času dozadu a změnu časového pásma ověřit
  deterministickým testem nebo vyhrazeným zařízením; nevydávat simulaci za
  fyzické čekání.

## Evidence

Do verzované nebo předem určené evidence ukládat pouze:

- report s časy, verzí a hashi;
- sanitizované počty a stavové markery;
- screenshoty aplikace bez osobních notifikací nebo jiných aplikací;
- výslovné lidské `PASSED`/`FAILED` pro každý ruční krok.

Neukládat raw save, úplné dumpsys výpisy, serial, osobní notifikace, kontakty,
e-mail testerů ani data jiných aplikací.

## Závěrečný protokol

```text
RC59_ANDROID_TECHNICAL_GATE=PASSED
RC59_ANDROID_SAVE_GATE=PASSED
RC59_ANDROID_NOTIFICATION_GATE=PARTIAL
RC59_ANDROID_BACKUP_PICKER_GATE=PASSED_EXPORT_PREVIEW_CANCEL_USER_CONFIRMED
RC59_ANDROID_BACKUP_RESTORE_GATE=PENDING_TEST_COPY
RC59_ANDROID_HUMAN_VISUAL_GATE=PENDING
RC59_ANDROID_HUMAN_TOUCH_GATE=PENDING
RC59_ANDROID_THERMAL_BATTERY_GATE=PENDING
RC59_PHYSICAL_ANDROID_AUDIT=PARTIAL
```

Celkový stav se smí změnit na `PASSED` jen tehdy, když byl přesný RC59 skutečně
nainstalován a všechny povinné technické i lidské kroky mají důkaz.
