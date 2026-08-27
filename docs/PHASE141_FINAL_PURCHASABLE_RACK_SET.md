# Fáze 141 — finální koupitelná sada stojanu

Stav implementace: `PHASE141_FINAL_PURCHASABLE_RACK_SET=IMPLEMENTED`

Schválený výtvarný zdroj: `PHASE141_VISUAL_ACCEPTANCE=APPROVED_SOURCE`

Technická validace: `PHASE141_TECHNICAL_VALIDATION=PASSED`

Skutečný Godot render: `PHASE141_GODOT_RENDER_ACCEPTANCE=APPROVED_BY_USER`

Mobilní přijetí: `PHASE141_MOBILE_ACCEPTANCE=PENDING`

Publikování: `OUT_OF_SCOPE_BY_USER`

## Schválený kontrakt

Uživatel výslovně určil náhled stojanu se čtyřmi dřevěnými policemi a třemi
rostlinami na každé polici jako finální styl stojanu i koupitelných pokojových
rostlin. Schválení se vztahuje na malovaný nepixelový vzhled, jednotnou velikost
květináčů a podmisek, čisté rozestupy, společné světlo zleva nahoře a nulové
přesahy do sousedních míst nebo vyšší police.

Zdrojový návrh a skutečný herní render zůstaly dvě samostatné brány. Uživatel po
kontrole výstupu `comic-phase141-player-room-final-rack-set.png` výslovně
schválil také výsledný stojan přímo v Godotu. Toto přijetí se nevydává za
mobilní kontrolu; APK a telefon zůstávají oddělené.

## Obsah

- Dvanáct samostatných rostlinných slotů zůstává ve mřížce 4 × 3.
- Osm původních koupitelných pokojovek dostává novou Phase 141 kresbu.
- Čtyři nové koupitelné položky jsou stříbrná aglaonema, růžová fitónie,
  citronová maranta a barevný koleus.
- Každá rostlina je samostatná RGBA vrstva a lze ji přesouvat mezi rostlinnými
  sloty stávajícím nákupním systémem.
- Každý runtime PNG má plátno 591 × 887, šířku podmisky 340 zdrojových pixelů,
  kontaktní základnu `y = 850` a společný spodní pivot.
- Zdrojové ImageGen PNG jsou uloženy odděleně v `phase141/source`; normalizátor
  je nepřepisuje a odstraňuje pouze border-connected světlé pozadí, falešnou
  šachovnici a odpojené poloprůhledné halo.

## Save a ekonomika

Save schema 41 autorizuje pouze čtyři nové ID. Schema 40 zachová všechny dříve
koupené dekorace a jejich pozice, ale nemůže podvrhnout vlastnictví Phase 141
položek. Nové ceny jsou 30, 34, 36 a 40 mincí; rostliny zůstávají čistě
kosmetické, neumírají a nemění pěstitelskou simulaci.

## Zachované hranice

- Obrazovka `ROSTLINY`, její rostliny a herní pěstování se nemění.
- Prázdný pokojový podklad Phase 139 ani starší PNG se nepřepisují.
- Pravá dekorativní část Phase 140 zůstává funkční, ale její další výtvarná
  revize je oddělená od tohoto schváleného stojanu.
- Immutable RC54 a nainstalovaná APK se touto source-only implementací nemění.

## Ověření

- Úplná deterministická validace
  `.godot/validation/20260823-173713Z` prošla s
  `MVP_TESTS_PASSED=1456`, `HOW_TO_GROW_CAPTURE=PASSED`,
  `HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`.
- Skutečný Godot render je
  `comic-phase141-player-room-final-rack-set.png` ve stejné složce. Automatická
  kontrola a následné uživatelské schválení potvrdily 4 × 3 uzemněné rostliny
  bez sousedních překryvů jako finální vzhled stojanu.
- Responsive audit `.godot/responsive/20260823-174052Z` prošel 9/9 případů,
  včetně 1080 × 2400, 360 × 800 a safe-area variant.
- Visual contract `.godot/visual-contract/20260823-174114Z` eviduje 313
  profilovaných PNG, 0 neprofilovaných a 130 runtime PNG ve společném živém
  botanickém master profilu.
- Závěrečná Quick automatizace po uživatelském schválení
  `.godot/automation/20260823-181336Z` potvrdila
  `AUTOMATION_TECHNICAL_GATE=PASSED` a `HOW_TO_GROW_AUTOMATION=PASSED`;
  mobilní a lidská brána zůstaly záměrně oddělené.
