# Rozmarýnové tonikum — 11. 10. 2026

Navazující hratelný návrh ke schválení po schválené mátové výživě.

## Co přibylo

- Druhý konkrétní bylinný recept v Bazalově dílně: **2 g suchého nezabaleného
  rozmarýnu + 4 mince → až 20 bodů zdraví vybrané rostliny**.
- Použije se ihned na živou rostlinu se zdravím pod 85. Nevytváří další zásobu
  lahviček. Zdraví nepřekročí 100; u 84 bodů přidá 16 a právě to oznámí.
- Výběr ukazuje jméno/slot a zdraví rostliny. Ještě před použitím je vidět
  očekávaná změna; po dokončení se vypíše skutečný výsledek.
- Původní univerzální tonikum (2 g libovolných bylin + 3 mince, +12 zdraví)
  zůstává dostupné. Rozmarýn je silnější volba za konkrétní druh bylin a minci
  navíc. Tato herní čísla jsou součást návrhu k posouzení.
- Schválený hmoždíř a palička zůstaly. Rozmarýnové větvičky a lahvička jsou
  nové malované komponenty. Animace trvá 2,4 s, omezený pohyb ukáže statický
  výsledek. Nápis „Použito“ rozlišuje okamžitý účinek od hnojiva do zásoby.

## Zachování postupu a chování

Žádné nové klíče save, migrace, měny ani časovače. Výroba používá existující
zdraví a skladové šarže. Zápis proběhne před animací; při chybě se vrátí přesné
šarže, mince a zdraví. Zpět ukončí jen animaci. Dvojklik během míchání nevytvoří
druhý účinek. Během animace je blokovaný také výběr jiné rostliny.

Rozšířená společná komponenta animuje oba recepty. Výběry cílové rostliny
sdílejí zvolený slot a aktualizují se podle dostupných oslabených rostlin.

## Ověření a náhledy

- Kompletní funkční runner: **MVP_TESTS_PASSED=7506**, proces exit 0.
- Přibylo 20 kontrol: druh/fáze/množství surovin, neplatné cíle, rollback,
  spotřeba více šarží, limit zdraví, nedostatek mincí, načtení, výběr druhé
  rostliny, dvojklik, Zpět, omezené animace a selhání zápisu v UI.
- Nativní Godot renderer: **ROSEMARY_RECIPE_NATIVE_CAPTURE=PASSED**, exit 0;
  `rosemary-360.png`, `rosemary-432.png`, fáze animace a stav bez vhodného cíle.
- Schválená mátová karta je pixelově shodná: RGB výřez [40,117,304,507] proti
  předchozímu schválenému snímku při šířce 360, průměrná chyba **0,0**.
  Výřez nezahrnuje změněný souhrnný počet bylin a posuvník delšího seznamu.
  Podrobnosti jsou v `mint-comparison.json`.
- Schválené reference nebyly měněné. Celá historická golden sada nebyla v tomto
  průchodu spuštěná; kontrola se zaměřila na dotčené recepty.
- Ve funkčním logu je stejných 40 starších diagnostik chybějících metadat
  `action_content` / `action_icon` z testu větrání a očekávané negativní testy
  katalogu/save. Nejsou zde `SCRIPT ERROR`, `Parse Error` ani neúspěšné kontroly.

Podklady běhu: `.godot/workshop-rosemary-20261011/`. Testy i capture používají
oddělené APPDATA; osobní profil nebyl použit. Fyzický telefon se netestuje.

## Android sestavení

Zdrojový export `builds/android/rosemary-workshop-current-source.apk`, SHA256
`86B2219F803F91F146F71FDBCF0D88B2795F63229AD529521DE6D8098BE9C10C`.
Exportní kontroly podpisu, ABI, payloadu, manifestu, SDK a 16 KB zarovnání prošly.
Izolovaná testovací kopie `builds/android/rosemary-workshop-wheeltest.apk`,
balíček `com.howtogrow.game.wheeltest`, SHA256
`0015AE3117A19A6A7BF63BCB1EEC0769C48947A702066B272EC2B0B4C09D87F2`.

Dotykový průchod na API 36 x86_64 v read-only emulátoru potvrdil skutečné
posouvání seznamu, dvojklik s jediným účinkem, odečet 4 mincí a 2 g rozmarýnu,
zachování ostatních bylin a znovunačtení výsledku po restartu. Zdraví po výrobě
bylo přibližně 80,008 místo přesných 80 kvůli normálnímu běhu simulace;
izolované funkční testy ověřují samotný přírůstek přesně +20.

Po jazykové korekci výsledné zprávy byl zopakován celý runner (7506), nativní
capture a Android průchod v novém APK včetně restartu. Finální snímky jsou
`android-final-before.png`, `android-final-after.png`; `rosemary-crafting-android.mp4`
je 8,7sekundový přímý H.264 záznam obrazovky emulátoru. `verification.json`
váže výsledky k finálním hashům APK. Emulátor byl ukončen bez uložení snapshotu.

## Grafika

Jeden nový produkční soubor: `assets/ui/workshop/rosemary_crafting_atlas_v1.png`
(1774 × 887 RGBA, skutečná průhlednost). Vytvořen built-in imagegen podle
schváleného mátového atlasu; přesný prompt a původ jsou v sousedním
`rosemary_crafting_atlas_v1.prompt.md`. Původní atlas se nezměnil.

Změny zůstávají lokálně pro osobní schválení, bez nového release.
