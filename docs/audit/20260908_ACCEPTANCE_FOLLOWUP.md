# Dokončení přijetí na telefonu — 8. září 2026

Tento průchod navazuje na [opravy větrání a záhlaví](20260908_RACK_HEADER_CLEANUP.md).
Ověřuje tři dohodnuté body: 30 minut hraní, běžnou připomínku po restartu
telefonu a potvrzenou obnovu zálohy v oddělené testovací aplikaci.

## Ruční hraní

Vlastník potvrdil „Ano, 30 minut a nic dalšího“ na otázku po nejméně
30 minutách aktivního hraní a dalších chybách, výrazném zahřívání nebo
zpomalování. Dříve hlášené větrání a modré body byly opraveny v aktuálním
preview. Toto je lidské potvrzení průchodu a subjektivní plynulosti; nejde
o instrumentované měření spotřeby baterie, paměti nebo všech režimů displeje.

`ANDROID_MANUAL_PLAY_30_MIN=PASSED_USER_CONFIRMED`.

## Běžná připomínka po restartu

Hra naplánovala běžnou připomínku při přechodu na domovskou obrazovku:
„Květináč 1 · Přemokřená půda.“ Nešlo o tlačítko testu za 20 sekund.
Před restartem byl uložen trigger `1788898020657`, slot 1 a vlastní alarm;
žádné vlastní oznámení nebylo aktivní. Restart je doložen resetem uptime
z 12 248,73 s na 51,15 s a `sys.boot_completed=1`.

První čtení po restartu ještě neukázalo obnovený alarm ani doručení.
Později se bez opětovného otevření hry skutečně objevilo vlastní oznámení
4401. Jeho čas vytvoření `1788898177549` je 156,892 s po původním termínu.
Název a text odpovídají běžné péči o květináč 1. Plánovací preference se
po doručení vyprázdnily. Při testu nebylo měněno nastavení MIUI, čas
zařízení ani notifikační preference. Hra používá nepřesný alarm
`setAndAllowWhileIdle`; tento průchod nedokládá přesné doručení na sekundu.

[Před restartem](../../.godot/acceptance-followup/20260908/reboot-before.json),
[první čtení po restartu](../../.godot/acceptance-followup/20260908/reboot-after-first.json),
[doručení po restartu](../../.godot/acceptance-followup/20260908/reboot-after-wait.json),
[vlastní oznámení a jeho čas](../../.godot/acceptance-followup/20260908/delivered-notification.json).

`ANDROID_NORMAL_REMINDER_AFTER_REBOOT=PASSED_DEVICE_OBSERVED`.
Vlastník následně potvrdil „Ano, otevřelo květináč 1“. Také pořízený
[snímek aplikace](../../.godot/acceptance-followup/20260908/reboot-opened-slot1.png)
ukazuje otevřený detail rostliny.

`ANDROID_REBOOT_REMINDER_OPEN_TARGET=PASSED_USER_CONFIRMED`.

## Obnova v oddělené aplikaci

Na stejném telefonu je vedle původní hry nainstalována aplikace
**Pocket Garden TEST**, package `com.howtogrow.game.acceptance`.
Má samostatné aplikační úložiště. Její APK vzniklo z nezávislé kopie
aktuálních zdrojů; všech 2 052 původních runtime souborů bylo ověřeno
hashem před exportem i po něm. Původní aplikace nebyla přeinstalována.

| Aplikace | SHA-256 nainstalovaného APK |
| --- | --- |
| Původní hra, `com.howtogrow.game` | `65ECD51DC99A5BB2CE27C4180A7F6878D826CC04F18D9D5EB8F191570C60A0E2` |
| Pocket Garden TEST | `E9616F47000A032B1083D2C8A2375081061E56FE79C62EA25E513F72AE2B877B` |

Obě mají versionName `0.69.0-rc59`, code 76 a schema 41. Testovací APK
prošlo kontrolami podpisu, payloadu, manifestu, ABI, notifikačního DEX,
privacy allowlistu a 16KiB zarovnání. Čistý import testovací kopie narazil
na nativní pád importéru fontu; následný import a export prošly s nezávislou
kopií existující importní cache. Tento export tedy není novým důkazem
čistého importu. [Exportní evidence](../../.godot/acceptance-testcopy/20260908/apk-ready.json),
[readback obou instalací](../../.godot/acceptance-followup/20260908/installed-packages.json).

Vlastníkem exportovaný soubor `bazals-pocket-garden-2026-09-08.htgbackup`
zůstal v telefonu. Jeho SHA-256 je
`7dec72b8b3e9ec561713b36874800816e916fb06f60362d290ceaf6e91d974ad`.
Kontrolní součet payloadu je platný; obsah odpovídá náhledu úrovně 4,
10 mincí, 341 XP a čtyř obsazených květináčů. Hlasitost hudby je 55 %.
Raw záloha ani raw save nejsou uloženy v auditní evidenci.
[Sanitizované ověření zálohy](../../.godot/acceptance-followup/20260908/user-backup-verified.json).

V testovací aplikaci byla nejprve běžným ovládáním změněna hlasitost hudby
na 25 %. Její výchozí stav byl úroveň 1, 30 mincí a žádná obsazená rostlina.
Přes Nastavení → Záloha postupu → Vybrat zálohu k obnově byl otevřen skutečný
Android picker. Vybrán byl uvedený soubor, prohlédnut správný náhled a
stisknuto **Potvrdit obnovu**. Tyto interakce provedl agent přes ADB na
fyzickém telefonu; nejsou vydávány za další ruční průchod vlastníka.

Hra zobrazila „Záloha byla obnovena a bezpečně uložena.“ Readback potvrdil
shodu všech kontrolovaných stabilních polí se zálohou: schema, úroveň/XP,
mince, počet rostlin, motiv, hash rozložení a zvuková nastavení. Hudba se
obnovila na 55 %. Automatický soubor `how_to_grow_save.before_import.json`
přesně odpovídá primary save přečtenému bezprostředně před potvrzením,
SHA-256 `0890fabce0e72e37f4b1e998233a5ebba5d0a7206339a2d41eb5de44197a61d2`.

Následoval force-stop pouze testovací aplikace, kontrola ukončení jejího
procesu a nové spuštění. Obnovená pole i before-import hash zůstaly stejné.
Původní hra zachovala úroveň 5, 22 mincí, 400 XP, čtyři rostliny, motiv
`lagoon`, rozložení a zvuková nastavení. Její raw hash se běžným během
a přechodem do pozadí měnil; netvrdíme identitu celého živého save.

[Náhled](../../.godot/acceptance-followup/20260908/test-import-preview.png),
[potvrzená obnova](../../.godot/acceptance-followup/20260908/test-restored.png),
[stav před potvrzením](../../.godot/acceptance-followup/20260908/test-immediately-before-confirm.json),
[automatická záloha](../../.godot/acceptance-followup/20260908/test-automatic-before-import.json),
[obnovená hra po restartu](../../.godot/acceptance-followup/20260908/test-after-restart.png),
[readback po restartu](../../.godot/acceptance-followup/20260908/test-after-restart.json),
[before-import po restartu](../../.godot/acceptance-followup/20260908/test-before-import-after-restart.json),
[původní hra před](../../.godot/acceptance-followup/20260908/live-before-clone-restore.json)
a [po](../../.godot/acceptance-followup/20260908/live-after-clone-restore.json).

`ANDROID_TEST_COPY_BACKUP_RESTORE=PASSED_DEVICE_UI_AND_RESTART`.
`ANDROID_TEST_COPY_BEFORE_IMPORT=PASSED_EXACT_HASH_AND_RESTART`.
`ANDROID_LIVE_PROGRESS_PRESERVED=PASSED_STABLE_FIELDS`.

## Výsledek a rozsah

**Všechny tři dohodnuté body jsou splněné pro aktuální preview.**
[Souhrnná kontrola evidence](../../.godot/acceptance-followup/20260908/acceptance-result.json)
má 12/12 technických kontrol a odděleně zaznamenaná dvě potvrzení vlastníka.
Testovací aplikace zůstává nainstalovaná se svou obnovou a automatickou
zálohou; po testu byla zastavena a na telefonu znovu otevřena původní hra.

`CURRENT_PREVIEW_AGREED_ACCEPTANCE=PASSED`.

Tento výsledek nemění hash ani historické výsledky immutable RC59 a
nezaškrtává neprovedené položky rozšířené šablony, například měření baterie,
audio focus, všechny frekvence displeje nebo úplný první permission flow.
Podepsaný AAB a publikace nejsou součástí tohoto průchodu.
