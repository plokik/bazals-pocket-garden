# Phase169 — čisté okraje pokojových květináčů

## Rozsah

Technická oprava uživatelem nahlášeného šedého lemu a světlých zbytků
pozadí u pokojových rostlin. Nejde o novou malbu ani redesign. Rozměry,
rozmístění, květy, keramický dekor, stojan, prostředí, ovládání a save
zůstávají zachované. APK je výslovně odložené.

```text
PHASE169_ROOM_PLANT_EDGES=IMPLEMENTED
PHASE169_ALPHA_AUDIT=PASSED_12_ASSETS
PHASE169_REGRESSION=PASSED_6626
PHASE169_GPU_VISUAL_REVIEW=PASSED_DESKTOP_8_NATIVE_FRAMES_AND_SWAP
PHASE169_FULL_VALIDATION=PASSED_34_OF_34_GATES
PHASE169_QUICK=PASSED
PHASE169_ANDROID_ACCEPTANCE=NOT_RUN_SOURCE_ONLY
PHASE169_USER_VISUAL_ACCEPTANCE=PENDING_REVIEW_OF_FIX
```

## Potvrzené příčiny

- Zdrojové obrázky obsahovaly šedohnědé neprůhledné zbytky pozadí kolem
  spodních obrysů podmisek. Nešlo o další obrys kreslený Godotem.
- Mezi některými listy a stonky zůstaly malé bílé/šedé plošky původního
  pozadí. Zvětšený audit je odlišil od skutečných odlesků uvnitř listů,
  světlých žilek a růžových květů.
- Phase167 obnovovala ztracené okvětní pixely pomocí `max(new_alpha,
  old_alpha)`. Tato aditivní oprava neuměla odstranit už existující zbytky.
  Její historický PASS proto nebyl důkazem dokonale čistého vnitřního výřezu.
- Všech dvanáct importů mělo lossless kompresi, mipmapy, straight alpha
  a zapnuté doplnění barvy transparentního okraje; jejich cache odpovídala
  zdrojům. Samotné nastavení importu neprůhledné zbytky neopraví.

## Provedená oprava

`tools/build_phase169_room_plant_edges.py` vytváří nové verzované deriváty
v `assets/ui/visual/phase169/player_room/`. Navazuje na uživatelem dříve
povolené deterministické odstranění pozadí. Původní PNG ani schválené
reference nepřepisuje a nevolá generování nové grafiky.

- U všech 12 květináčů odstranil **8 096 pixelů vnějšího šedého pozadí**.
  Maska je omezena na spodní část obrázku a barevné oblasti napojené na
  průhledný okraj; tmavý obrys keramiky a vnitřní malba zůstávají.
- V 10 rostlinách odstranil **1 421 pixelů ověřených neutrálních otvorů**.
  Jde o úzké, ručně prohlédnuté oblasti se zadanými souřadnicemi a počátky
  propojených oblastí. Nepoužívá plošné odstranění bílé barvy.
- Celkem se mění jen alfa 9 517 zdrojových pixelů. **Všechny RGB bajty,
  včetně nyní neviditelných, jsou přesně stejné jako v Phase167.**
- Zůstává celé původní plátno s paddingem, zdrojové měřicí body, geometrie
  keramiky 57 × 54, izotropní koruny, kontaktní linie i mipmapové filtrování.
- Runtime načítá nové deriváty přes stejné vizuální profily. Není přidán
  shader, filtr celého pokoje ani práce navíc při vykreslování/tažení.

Builder kontroluje původní SHA256, všech dvanáct druhů a pixelové invarianty
před zápisem. `--check` přepočítá výsledek bez zápisu a ověří manifest;
`--write` odmítne přepsat existující odlišný produkční derivát.

## Regrese a vizuální důkazy

Nových 172 kontrol nad předchozími 6 454 ověřuje skutečné RGB/alfa, pevně
připnuté zdrojové i výstupní hashe, nezávislé kontrolní pixely lemu,
zaměřené otvory, zachování růžových květů, vnitřku keramiky a celé geometrie,
skutečně načtené mipmapy a bezeztrátový import.

Původní Phase167 audity aditivní obnovy nad archivními PNG pokračují
beze změny; kontrola živého profilu nyní očekává Phase169. Stávající
testy přesouvání, výměn a úsporného vykreslování zůstávají zapojené.

- Builder `--write` a následný `--check`: PASS, native exit 0.
- Zkušební srovnání `.godot/phase169-alpha-trial-v3/`: všech 12 zdrojů
  prohlédnuto zvětšeně, včetně masek změn. Jde o diagnostiku textur,
  nikoli o snímek hry nebo telefonu.
- Úplná validace `.godot/validation/20260828-180417Z/`: native exit 0,
  `MVP_TESTS_PASSED=6626`, `HOW_TO_GROW_CAPTURE=PASSED`,
  `HOW_TO_GROW_VISUALS=PASSED`, `HOW_TO_GROW_VALIDATION=PASSED`;
  **34/34 aktivních obrazových bran PASS**. Capture stderr je prázdný.
  Regresní log obsahuje očekávané selhání zápisu v negativním Phase91
  save testu; nejde o pád testovací sady ani novou chybu.
- Pět stávajících Phase167 bran prošlo bez přebaselinování. Plný pokoj,
  pokoj s cloche a čistá podlaha mají MAE 0,144119 / RMSE 2,338530 /
  podíl změn 0,456 %. Řídce vybavený pokoj má 0,143 % a phone-save fixture
  0,1681 %. Phone-save fixture je desktopový test, nikoli nový snímek telefonu.
- Porovnání reportů Phase168 a Phase169 potvrdilo nula změněných hashů
  referencí či vykazovaných parametrů bran. Heatmapa plného pokoje byla
  prohlédnuta: rozdíly jsou u podmisek a vyčištěných mezer mezi listy.
- Cílený skutečný GPU capture `.godot/phase169-rack-final/` má explicitní
  `HOW_TO_GROW_CAPTURE=PASSED` a prázdný stderr. Všech osm nativních snímků
  (čtyři rotace řad × běžný/kompaktní pokoj) bylo prohlédnuto, stejně jako
  runtime náhled výměny a stav po položení. Keramika, květy a dosednutí
  zůstávají zachované i po přesunu mezi policemi.
- Závěrečný Quick `.godot/automation/20260828-182116Z/`: native exit 0,
  VisualContract i Regression PASS, opět `MVP_TESTS_PASSED=6626` a
  `HOW_TO_GROW_AUTOMATION=PASSED`. Telefon nebyl požadován; ruční brána
  zůstává odděleně otevřená a publikování je mimo rozsah.

## Náhledy skutečného renderu

Jde o přímé, hashově ověřené kopie GPU snímků, ne domalované návrhy,
nové schválené reference nebo fotografie telefonu:

- [Celá hra s HUDem](visual-proposals/phase169/player-room-clean-edges-runtime-v1.png),
  1080 × 2400, SHA256
  `64E39380C3D6E6D78D1F7B6AEC83F116531D19D86E31AEDE3B0B7EDD2660E29C`.
- [Nativní detail komponenty Pokoje](visual-proposals/phase169/player-room-clean-edges-native-v1.png),
  1080 × 1950 bez globálního HUDu, SHA256
  `5AA2A37E8969547A0284135E08ACDACEF5D18DF7DDA7A090D1A8D9206F9E3173`.

Žádná obrazová reference, maska, tolerance ani mapování bran se kvůli
opravě nepřepisuje. Technická validace není uživatelské přijetí ani
fyzická kontrola telefonu.

## Zachované vydání

Immutable RC58 zůstává `0.68.0-rc58` / Android code 75 / save schema 41.
APK SHA256:
`0A7F173D8C97B552168A407C31F1F8AE85109A34C2F6F4786029551064F0C6F5`.
Přesun z Phase166, geometrie z Phase167 a runtime view z Phase168 se nemění.
Hash runtime view zůstal
`25315E1B78C46D4765F5274C64C1F12FA1750A682B53E5483683EC93CDD034C0`;
schválený nativní Phase167 náhled zůstal
`7273D26C64A662B2479947D640C68C2C5478B93F3E623F546EF93A1B9C29EC8D`.
HEAD je stále `5ae1f0d7b7043260ed265c8363314217994ba3f9` a
`git diff --check` prošel (pouze upozornění na budoucí LF → CRLF).
Nový APK, instalace, zásah do skutečného save, commit ani cleanup neproběhly.
