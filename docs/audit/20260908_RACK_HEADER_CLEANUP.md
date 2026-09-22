# Rostliny — odstranění bodů u záhlaví, 8. září 2026

Vlastník požádal o odstranění modrých bodů vedle otazníku a nápisu
MOJE ROSTLINY na kartě Rostliny.

## Příčina a rozsah

Telefon používá uložený vzhled `lagoon`. Body tvořila procedurálně kreslená
řada devíti dekorativních světýlek se spojovacími tahy ve funkci
`PlantRoomOverview._draw_cosmetic_atmosphere()`. Jejich středy zasahovaly
za otazník a pod nadpis. Nejsou součástí malovaného PNG pozadí ani ikony.

Odstraněno bylo pouze sedm řádků, které tuto řadu vykreslovaly. Změna
platí také pro fialovou variantu stejné řady. Barva motivu, ostatní částice,
rozložení, otazník, počítadlo, ovládání i předchozí oprava větrání zůstaly
zachované. Žádný PNG asset, schválená reference ani uložený vzhled se neměnil.

[Telefon před úpravou](../../.godot/rack-header-cleanup/20260908/before-current.png),
[sanitizovaný stav a motiv](../../.godot/rack-header-cleanup/20260908/before-cleanup.json).

## Ověření

Úplná validace prošla `MVP_TESTS_PASSED=6758`, 34/34 obrazovými branami
a `HOW_TO_GROW_VALIDATION=PASSED`; 20 dalších porovnání zůstává diagnostických.
Reference ani tolerance se neměnily. [Report](../../.godot/rack-header-cleanup/20260908/validation/report.md),
[stav validace](../../.godot/rack-header-cleanup/20260908/validation/validation-status.txt).

Export prošel kontrolami runtime payloadu, manifestu, ABI, notifikačního
kódu a 16KiB zarovnání. Výsledný preview byl podepsán původním existujícím
debug klíčem; certifikát a zarovnání byly ověřeny před instalací.

Na telefonu je nyní
[samostatné preview APK](../../.godot/preview/20260908-rack-header-cleanup/bazals-pocket-garden-rack-header-cleanup-preview-device.apk)
s SHA-256 `65ECD51DC99A5BB2CE27C4180A7F6878D826CC04F18D9D5EB8F191570C60A0E2`.
Obsahuje i předchozí opravu větrání a přes `adb install -r` nahradilo
preview `AF005B2F…24C2A4C1`. Balíčková identita zůstává `0.69.0-rc59` /
code 76 / schema 41; nejde o nový immutable RC59. Původní RC59 APK zůstává
na hashi `206AC5349731D95570E0E59DD43229A5AB608AA139EA78979FCB3DE907021E7D`.

[Třicetisekundový audit](../../.godot/android-device-audit/20260908-194128Z/report.md)
ověřil přesný nainstalovaný hash, 5/5 platných vzorků, 100 % v popředí,
nulu fatal/ANR nálezů a zachování stabilních hodnot postupu.
Čtení před a po potvrzuje schema 41, 22 mincí, 400 XP (úroveň 5), čtyři
obsazené květináče, motiv `lagoon` a stejné rozložení pokoje.

Prohlédnutý [snímek telefonu po aktualizaci](../../.godot/rack-header-cleanup/20260908/after-header-cleanup.png)
potvrzuje čisté okolí otazníku a nadpisu při stejném motivu; žádné přepnutí
vzhledu nebylo potřeba. [Před instalací](../../.godot/rack-header-cleanup/20260908/before-install.json),
[po instalaci](../../.godot/rack-header-cleanup/20260908/after-install.json).

Tato drobná úprava neuzavírá zbývající ruční přijetí celé hry, ověření
připomínek po restartu telefonu ani obnovu zálohy na testovací kopii.
