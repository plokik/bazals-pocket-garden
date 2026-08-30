# Fyzický Android audit RC59

Datum šablony: **2026-08-30**

Aktuální stav: `RC59_PHYSICAL_ANDROID_AUDIT=PENDING`

RC58 má historický technický audit na Xiaomi, ale tento důkaz nepokrývá aktuální
zdroje fází 166–184 ani sestavený RC59. Tento dokument nic nepředstírá jako
provedené. Instalace RC59 smí začít až po výslovném souhlasu vlastníka telefonu.

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
| package / versionName / versionCode | `PENDING` | `PENDING` | `PENDING` |
| hash instalovaného APK | `PENDING` | `PENDING` | `PENDING` |
| save schema | `PENDING` | `PENDING` | musí být `41_TO_41` |
| mince / XP | `PENDING` | `PENDING` | musí se zachovat |
| počet slotů / obsazených slotů | `PENDING` | `PENDING` | musí se zachovat |
| foreground vzorky | n/a | `PENDING` | bez neočekávaného pádu |
| fatal / ANR | n/a | `PENDING` | 0 v auditním okně |
| notifikační a alarmová evidence | `PENDING` | `PENDING` | package-scoped pouze |

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
- [ ] Naplánovat testovací připomínku a zachytit skutečné oznámení mimo hru.
- [ ] Ověřit běžnou připomínku na reálném care boundary.
- [ ] Restartovat pouze se souhlasem vlastníka; připomínka se obnoví a nepoužije
  exact alarm.
- [ ] Klepnutí otevře správný květináč/centrum péče.

### `.htgbackup`

- [ ] Otevřít systémový picker a zrušit jej bez změny hry.
- [ ] Exportovat `.htgbackup` do uživatelem zvoleného místa.
- [ ] Ověřit, že soubor neobsahuje tvrzení o šifrování; checksum je pouze
  integrita.
- [ ] Importovat stejný soubor, zobrazit náhled a zrušit bez změny.
- [ ] Potvrdit obnovu až na testovací kopii a ověřit automatickou before-import
  zálohu.

### Offline, systém a výkon

- [ ] Spustit hru v airplane mode; všechny herní funkce kromě otevření externího
  webu zůstávají dostupné.
- [ ] Pozastavit/obnovit aplikaci a přerušit ji systémovým dialogem.
- [ ] Ověřit ztrátu a návrat audio focusu.
- [ ] Projít dostupné 60/90/120Hz režimy bez změny herního času.
- [ ] Nejméně 30 minut aktivního průchodu: subjektivní plynulost, teplota,
  baterie a stabilní paměť.
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
RC59_ANDROID_TECHNICAL_GATE=PENDING
RC59_ANDROID_SAVE_GATE=PENDING
RC59_ANDROID_NOTIFICATION_GATE=PENDING
RC59_ANDROID_BACKUP_PICKER_GATE=PENDING
RC59_ANDROID_HUMAN_VISUAL_GATE=PENDING
RC59_ANDROID_HUMAN_TOUCH_GATE=PENDING
RC59_ANDROID_THERMAL_BATTERY_GATE=PENDING
RC59_PHYSICAL_ANDROID_AUDIT=PENDING
```

Celkový stav se smí změnit na `PASSED` jen tehdy, když byl přesný RC59 skutečně
nainstalován a všechny povinné technické i lidské kroky mají důkaz.
