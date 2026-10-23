# Mátová výživa a ověření reklam — 11. 10. 2026

Návrh ke schválení. PNG jsou skutečné snímky Godotu, nikoli návrhové makety.
Schválené vizuální reference a jejich prahy se nemění.

## Hratelný přírůstek

- V Bazalově dílně je nový recept **Mátová výživa**: 2 g suché nezabalené máty
  peprné + 3 mince → 2 běžné dávky hnojiva. Ostatní druhy máty nenahrazují.
- Hotové dávky používají stávající zásobu a ovládání hnojení. Nevzniká nový save
  klíč, měna, časovač ani dodatečná XP odměna. Původní recepty zůstávají.
- Malované lístky padají do hmoždíře, palička směs promíchá a objeví se sáček
  s +2. Animace trvá 2,4 s; omezené animace ukážou výsledek bez pohybu.
- Výsledek se uloží před animací. Zavření obrazovky jej nezruší. Během míchání
  jsou další výroby blokované. Při chybě zápisu se přesně vrátí mince, dávky
  i dotčené šarže a hodnoty rostlin.
- Okraje dialogu mají 24 px a posuvník 8 px odstup od karet.

## Náhledy

- `recipes-360.png`, `recipes-432.png`: celý dialog ve dvou mobilních šířkách.
- `mint-leaves.png`, `mint-grinding.png`, `mint-finished.png`: skutečné fáze
  animace. Zobrazená testovací zásoba je 4 g bazalky + 4 g máty, 42 mincí,
  2 hnojiva; po přípravě 6 g celkem, 39 mincí, 4 hnojiva.
- `other-recipes.png`: původní recepty po posunutí obsahu.

Grafika: `assets/ui/workshop/mint_crafting_atlas_v1.png`, vytvořená built-in
imagegen s průhledností podle schválené dílny. Přesný prompt a původ jsou
v sousedním `mint_crafting_atlas_v1.prompt.md`. Jediný atlas má čtyři oblasti
řízené komponentou `scripts/ui/workshop_craft_visual.gd`; kreslení nemění zásoby.

## Ověření

- Kompletní funkční runner: **MVP_TESTS_PASSED=7486**.
- Runner má 40 dříve existujících diagnostik chybějících `action_content` /
  `action_icon` metadat ve starém testu větrání. Stejný počet je už v předchozím
  `fortune-wheel-20261011/verified-tests.log` (7469 kontrol). Tato část nebyla
  změněna. Chyby neplatných katalogů a zápisu save patří negativním testům.
  Aktuální běh nemá `SCRIPT ERROR` ani `Parse Error`; netvrdíme zcela tichý log.
- Nativní vizuální průchod: **MINT_RECIPE_NATIVE_CAPTURE=PASSED**, šířky 360/432.
- Testy zahrnují správný druh a fázi bylin, částečnou spotřebu více šarží,
  nedostatek surovin/mincí, dvojklik, rollback při selhání uložení, opětovné
  načtení, zavření uprostřed animace a omezené animace.
- Starší kompletní golden sada se v tomto průchodu nespouštěla. Nové snímky
  jsou návrhy k posouzení, nikoli automaticky schválené baselines.
- Logy a izolační profily: `.godot/workshop-mint-20261011/` (`tests-return.log`,
  `capture-final.log`, `export.log`). Osobní desktopový profil se nepoužil.

## Skutečné testovací reklamy na Androidu

Izolovaný API 36 x86_64 emulátor `Bazal_Source_Test_API36`, spuštěný read-only
bez ukládání snapshotu; samostatný balíček `com.howtogrow.game.wheeltest`.
Použita oficiální sample rewarded jednotka, žádné živé reklamní ID.

První průchod skutečným Google SDK: jeden bezplatný tah a dvě dokončené
testovací reklamy. Výsledky: 3 mince, 2 semínka bazalky, 5 mincí. Po restartu
zůstalo 38 mincí, `free_used=true`, `ad_spins=2`, prázdné `pending` a stejné
potvrzení poslední odměny. Čtvrtý tah není dostupný.

`android-visible-ad.png` dokládá skutečnou reklamu s označením Test Ad a Reward
granted. Tento první diagnostický APK obsahoval starší prezentaci kola.
`android-final-limit.png` už pochází z nového APK s aktuálním schváleným vzhledem;
po aktualizaci se původní odměny a limit zachovaly.

ATD měl vypnuté nativní vykreslování (`debug.hwui.drawing_enabled=0`). Povolení
vykreslování bylo provedeno pouze v běžícím izolovaném emulátoru, aby se zobrazil
WebView reklamního SDK. Nejde o změnu hry ani nastavení uživatelova telefonu.
Bridge nově zapisuje doménu/kód chyby načtení do logcatu pro diagnostiku no-fill.

Při dlouhé reklamě byl nalezen překryv výhry souhrnem návratu do zahrady.
Souhrn nyní čeká na zavření kola; růst, uložený čas a zprávy se zachovají.
Toto pořadí chrání dvě nové funkční kontroly.

Na aktuální testovací kopii proběhl ještě samostatný průchod s novou fixture:
reklama držela aplikaci na pozadí 76 sekund, SDK potvrdilo odměnu a hra přidala
jednu dávku hnojiva. `android-final-ad.png` ukazuje reklamu,
`android-final-ad-result.png` nezakrytou výhru a teprve po zavření kola se
zobrazil `android-final-deferred-summary.png`. Tím je opravené pořadí ověřeno
i skutečným Android lifecycle, nejen testovacím adaptérem.

Výroba byla ověřena dotykem na aktuálním Android APK: dvě rychlá klepnutí
způsobila právě jednu výrobu (4 → 2 g máty, 42 → 39 mincí, 3 → 5 hnojiv).
`android-mint-before.png` a `android-mint-after.png` dokládají změnu;
`mint-crafting-android.mp4` je krátký přímý záznam této animace z emulátoru.
Po dalším restartu zůstaly 2 g máty, 39 mincí, 5 hnojiv a jeden použitý reklamní
tah. Izolovaný read-only emulátor byl po testu ukončen bez uložení snapshotu.

Aktuální zdrojový export pro emulátor:
`builds/android/mint-workshop-current-source.apk`, SHA256
`5A89A346C3F3C4F4D0E23087176CB6EB2D5B16CF0FAF351D38689015907C1E00`.
Export ověřil podpis, ABI, manifest, SDK allowlist, payload a 16 KB zarovnání.
Samostatná testovací kopie aktuálního zdroje:
`builds/android/mint-workshop-wheeltest.apk`, SHA256
`DF18EA60C7ED15405B2420E7D9418F7A1ECBBEFB1CCD144105986E1F292AA9F4`.

Telefon ani živé produkční reklamy nebyly testovány. Změny nejsou vydané jako
release. Podklady k testovacím jednotkám:
[Google test ads](https://developers.google.com/admob/android/test-ads).
