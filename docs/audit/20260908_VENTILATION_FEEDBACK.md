# Větrání — hlášení z ručního hraní 8. září 2026

Vlastník během ručního hraní RC59 ohlásil procento zaseknuté na 22 při
klepání na světle modré tlačítko Vyvětrat u jednotlivých rostlin. Upřesnil,
že ostatní ovládání fungovalo a stejný problém pozoroval u všech rostlin.
Přesný název procentního ukazatele nepotvrdil; stav při původním hlášení
se nepodařilo zachytit. Hlášení proto není důkazem zamrznutí celé aplikace.

## Zjištěný stav

- Aktuální čtení uloženého stavu: čtyři živé rostliny, proudění přibližně
  99,8 %, vláha půdy 95–99 %, žádná aktivní plíseň.
- Detail petržele ukazoval vláhu 97 %, zdraví 99 %, růst 2,4 % a PODMÍNKY
  25 %. Proudění tedy bylo v zachyceném stavu dostatečné.
- Podmínky odpovídají nejslabšímu ze šesti faktorů. Petržel má horní ideál
  vláhy 76 %; při vláze 97 % je vodní faktor `1 - (97 - 76) / 28 = 0.25`.
  Další větrání tento limit mokré půdy okamžitě neodstraní.
- V omezeném výpisu logu aktuálního procesu nebyla nalezena chyba Godotu
  ani pád. Tento výpis neprokazuje nepřítomnost všech dřívějších chyb.
- Mobilní tlačítko původně neukazovalo proudění. Diagnostika navíc při
  vláze nad 88 % vždy nabízela K VĚTRÁNÍ, i když proudění již bylo plné.
  To je reprodukovatelná chyba doporučení a srozumitelnosti odezvy.

Lokální evidence: [snímek detailu](../../.godot/ventilation-incident/20260908/first-plant-detail.png),
[sanitizovaný stav](../../.godot/ventilation-incident/20260908/current-sanitized-state.json),
[omezený výpis chyb](../../.godot/ventilation-incident/20260908/log-errors.json).
Raw save ani sériové číslo telefonu se neukládaly.

## Oprava a ověření

- Tlačítko Vyvětrat nyní viditelně uvádí aktuální proudění v procentech.
  Třířádkový popisek se vejde vedle původní ikony; popisky léčby jsou stejné.
- Při přemokření a proudění alespoň 40 % diagnostika doporučí nezalévat
  a nechat půdu přirozeně proschnout. CTA vrací k rostlině. Pod 40 % nadále
  vede k větrání. Jde o stávající diagnostickou hranici pro stojatý vzduch,
  nikoli změnu výpočtu podmínek, rychlosti růstu nebo herního vyvážení.
- Regrese obsahují mokrou petržel s podmínkami 22 % a 25 %, zvýšení
  proudění na 100 %, zachování skutečné vláhy i podmínek a hranici 39/40 %.
- Úplná validace prošla `MVP_TESTS_PASSED=6758`, 34/34 obrazovými branami a
  `HOW_TO_GROW_VALIDATION=PASSED`. Schválené reference ani tolerance
  se neměnily. [Report](../../.godot/ventilation-incident/20260908/validation/report.md),
  [stav validace](../../.godot/ventilation-incident/20260908/validation/validation-status.txt),
  [prohlédnutý mobilní render detailu](../../.godot/ventilation-incident/20260908/validation/comic-detail-idle.png).

## Android preview a skutečné klepnutí

Pro toto ověření byl na telefonu samostatný
[preview APK](../../.godot/preview/20260908-ventilation-feedback/bazals-pocket-garden-ventilation-feedback-preview-device.apk)
s SHA-256 `AF005B2F83187CA300C8D8E42BF2041B65518ED7043900D581BDCE2124C2A4C1`.
Zachovává balíčkovou identitu `0.69.0-rc59` / code 76 / schema 41, ale
nejde o původní immutable RC59. Tento preview později nahradila
[úprava záhlaví Rostlin](20260908_RACK_HEADER_CLEANUP.md), která opravu
větrání obsahuje. Immutable RC59 zůstává na původním hashi
`206AC5349731D95570E0E59DD43229A5AB608AA139EA78979FCB3DE907021E7D`.

Export prošel kontrolou APK payloadu, manifestu, ABI, notifikačního kódu
a 16KiB zarovnání. Izolovaný Godot export použil jiný vývojový podpis;
tento mezivýstup nebyl instalován. Výsledný `-device.apk` byl podepsán
existujícím původním debug klíčem. Ověření certifikátu se shodovalo s
instalovaným RC59 (`05d8041a…8d0f88`); podpis i zarovnání znovu prošly.
Původní klíč se neměnil. [Exportní log](../../.godot/ventilation-incident/20260908/export-output.txt).

Aktualizace přes `adb install -r` zachovala 22 mincí, 395 XP, čtyři
obsazené květináče, schema 41 a původní rozložení pokoje.
Třicetisekundový [audit preview](../../.godot/android-device-audit/20260908-191724Z/report.md)
ověřil přesný nainstalovaný hash, 5/5 platných vzorků, 100 % v popředí
a nulu fatal/ANR nálezů. Nejde o třicetiminutové hraní.

Následně bylo provedeno skutečné klepnutí přes ADB na modré tlačítko
u petržele: proudění `99.65093 → 100.0`, XP `395 → 396`, mince stále 22.
Změna XP odpovídá běžné odměně za úspěšnou péči. Nový popisek byl na
telefonu čitelný. Diagnostika zobrazila proudění 100 %, mokrou půdu 96 %,
pokyn nechat ji proschnout a tlačítko ZPĚT K ROSTLINĚ. Návrat reagoval.

- [Před klepnutím](../../.godot/ventilation-incident/20260908/preview-before-current-sanitized-state.json)
- [Po klepnutí](../../.godot/ventilation-incident/20260908/preview-after-current-sanitized-state.json)
- [Výsledek na telefonu](../../.godot/ventilation-incident/20260908/preview-after-vent.png)
- [Diagnostika na telefonu](../../.godot/ventilation-incident/20260908/preview-diagnosis.png)
- [Stav po ověření](../../.godot/ventilation-incident/20260908/after-preview-validation.json)

Technická oprava odezvy a nápovědy je ověřená; původní přesný ukazatel
22 % ani lidské přijetí nového chování tím nejsou zpětně potvrzené.

Ruční přijetí zůstává otevřené. Toto hlášení ani automatická diagnostika
nepotvrzují dokončení 30 minut hraní, tepelnou stabilitu, připomínky po
restartu telefonu nebo obnovu zálohy na testovací kopii.
