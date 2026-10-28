# Předání schválených změn — 28. 10. 2026

Uživatel schválil novou hudbu a požádal o její nasazení, spuštění aktuální verze
v emulátoru a nahrání veškeré schválené práce na GitHub.

## Obsah

- Novější schválené obrazovky a opravy čitelnosti, odsazení, posouvání a dotykových cílů.
- Odstraněný showroom a jeho vstupy; tři původně velké ikony v prostřední liště.
  Uložené nákupy a dříve vybraný vzhled zůstávají podporované.
- Schválená skladba **Klidná zahrada**, 72 BPM, 1:46,667. Používá přesně schválené
  Ogg bajty. Napříč lokacemi pokračuje stejný přehrávač bez restartu skladby.
  Zvuky akcí, prostředí, nastavení hlasitosti a ztišení při důležitých efektech
  zůstávají zachované. Vložená čajovna nepřidává druhou hudební vrstvu.
- Nová reference lišty je přesný dříve předložený PNG schválený uživatelem.
  Původní PNG, tolerance, masky a ořezy nebyly přepsané ani oslabené.

## Ověření

- **9 931 / 9 931 funkčních kontrol**; celý kanonický průchod skončil PASS.
- **33 / 33 aktivních obrazových bran**, 52 porovnávaných případů a 180 zachycených stavů.
- Kontrola 56 zvukových assetů včetně historické hudby: dekódování, délky,
  stereo, rezervy hlasitosti, smyčky a SHA-256 prošly. Nová skladba má −22,974 LUFS.
- Android export prošel kontrolami podpisu, ABI, manifestu, notifikací,
  přítomnosti runtime souborů a 16KiB zarovnání. Importovaný zvuk v APK je
  byte-for-byte shodný s ověřeným lokálním zdrojem Godotu.
- Emulátor **Bazal_Current_Source_API36**, balíček **com.howtogrow.game**,
  verze **0.71.0-rc61-emulator**: instalace `adb install -r`, úspěšné spuštění,
  shodný hash nainstalovaného APK, aktivní nativní zvukový výstup. Bez zjištěných
  chyb skriptů, parseru či nativního pádu během spuštění.

APK: `builds/android/bazals-pocket-garden-20261028-approved-calm-x86_64.apk`.
SHA-256: `02a68e23dac8fa436294fb2372ab3d33bdbe4baa0593f9bce9d2251b2db1ca9a`.

[Funkční a obrazové výsledky](validation.json), [ověření emulátoru](emulator-verification.json),
[aktuální obrazovka](emulator-current.png), [schválení hudby](../../audio-proposals/20261028-modern-calm/approval.json).
Podrobné pracovní logy jsou místně v `.godot/approved-delivery-20261028/`.

První funkční průchod neprošel dvěma starými podmínkami testů, které ještě
vyžadovaly předchozí cestu k referenci lišty. Po jejich aktualizaci podle
výslovného schválení byla celá sada i capture zopakována. Neúspěšný první
průchod zůstává zachovaný a není započítán jako PASS.

## Uložení a hranice ověření

Hlavní save i jeho záloha byly **0 B již před aktualizací**. Instalace i první
spuštění zachovaly jejich přesné bajty; celá soukromá složka byla předem
zazálohována pouze lokálně. Na základě dřívějšího výslovného souhlasu
„Ano, založ novou testovací hru“ byla poté přes běžné dvojí potvrzení ve hře
založena nová testovací hra. Její neprázdný JSON byl ověřen a hra zůstává
otevřená na první scéně Profesora Bazala. Soukromé save soubory se na GitHub
nenahrávají.

Při delším čekání v ochraně poškozeného uložení se projevila starší okrajová
chyba: automatické ukládání po 15 s může vrátit druhé potvrzení nové hry na
první krok. Dva po sobě jdoucí stisky fungují; oprava tohoto chování není
součástí nynějšího předání schválených změn.

Nativní ověření zde pokrývá instalaci, spuštění, recovery nové testovací hry
a stav audio výstupu. Není vydáváno za nový průchod všech obrazovek na Androidu
ani za subjektivní poslech reproduktorů. Fyzický telefon nebyl použit.
Nový release ani online služba nevznikají.
