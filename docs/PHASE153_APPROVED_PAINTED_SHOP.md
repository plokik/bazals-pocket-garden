# Fáze 153 — schválený malovaný Obchod

PHASE153_SOURCE_ACCEPTANCE=APPROVED_BY_USER
PHASE153_IMPLEMENTATION=IMPLEMENTED_DYNAMIC_RUNTIME
PHASE153_TECHNICAL_VALIDATION=PASSED_FUNCTIONAL_RESPONSIVE_AND_VISUAL
PHASE153_GODOT_RENDER_ACCEPTANCE=PASSED_INTERNAL_COHESION_AUDIT
PHASE153_USER_VISUAL_ACCEPTANCE=APPROVED_BY_USER
PHASE153_VISUAL_BASELINE_TRANSITION=PASSED_APPEND_ONLY_RUNTIME_GATE
PHASE153_MOBILE_ACCEPTANCE=DEFERRED_PHONE_UNAVAILABLE
PHASE153_APK=NOT_CREATED
PHASE153_PUBLISHING=OUT_OF_SCOPE

Závazná návrhová reference:
`docs/visual-proposals/phase153/user-approved-painted-shop-screen-v1.png`

SHA-256:
`5A69E32D9BA3EE96FEB911F653C4F21CB41D972AF5F6599DA173EB0DEA41D972`

## Runtime kontrakt

- obraz pana Kořínka zůstává byte-exact; mění se pouze import na mipmapy a jeho
  profilovaný výřez;
- hero zabírá výraznější horní část Obchodu a používá integrovanou tmavě
  tyrkysovou ceduli se zlatým rámem;
- dynamická zpráva obchodníka má vlastní malovanou plaketu a neleží jako volný
  text přes postavu;
- peněženka, všech 11 druhů semen, hnojivo, pět vylepšení, denní zásoby,
  vzácnost, ceny a stav vyprodání zůstávají dynamické;
- zachovány jsou režimy `NABÍDKA`, `POMŮCKY`, `VYBAVENÍ` a `VÝKUP`, skutečné
  transakce, vertikální scroll a vodorovná navigace;
- produktové karty používají jednotný krémový malovaný podklad, dřevěné
  ukotvení, společnou velikost, mipmapované rostliny a kontaktní stín;
- schválený náhled se nikdy nepoužije jako zapečená runtime obrazovka.

## Přijetí

Schválení návrhu neznamenalo automatické schválení výsledku v Godotu. Přesný
target zůstává report-only, protože obsahuje jednu konkrétní peněženku, zásobu
a výběr kategorie. Uživatel proto po úplné validaci samostatně posoudil a
schválil skutečný dynamický Godot render. Telefon není dostupný, proto se
nevytváří APK.

## Důkazy

- funkční regrese: `MVP_TESTS_PASSED=1506`;
- responzivní matice: `.godot/responsive/20260825-111352Z`, 10/10 případů
  včetně `phase153_shop_360x800`;
- finální úplná validace: `.godot/validation/20260825-115747Z`, kde platí
  `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED` a
  `HOW_TO_GROW_VALIDATION=PASSED`;
- skutečný schválený render:
  `.godot/validation/20260825-115747Z/comic-phase153-shop.png`;
- všech 19 závazných obrazových případů zůstalo zelených; nový
  `phase153-shop-runtime-approved` prošel přesně s MAE 0, RMSE 0 a 0 %
  změněných pixelů. Koncepční porovnání
  Phase153 je záměrně report-only a dosáhlo MAE 62,789, RMSE 91,724 a
  82,364 % změněných pixelů, protože návrh obsahuje zapečený konkrétní stav,
  zatímco runtime je plně dynamický;
- závěrečný Quick: `.godot/automation/20260825-120031Z`,
  `AUTOMATION_TECHNICAL_GATE=PASSED` a `HOW_TO_GROW_AUTOMATION=PASSED`.

Interní kontrola skutečného renderu nenašla ořez, překryv ani rozpad hierarchie.
Technická i lidská vizuální brána jsou uzavřené oddělenými důkazy.

Uživatel 25. 8. 2026 skutečný Godot render výslovně schválil. Schválený snímek
byl proto uložen jako nový append-only baseline
`assets/ui/comic/reference_phase153_shop_runtime_v1.png` se SHA-256
`3DD2EEFC3ECB1B50D6394E1368B67B62FD64D4C0CD65CE48C5784C6602754C12`.
Původní koncept zůstává nezměněný a report-only; nový samostatný případ
`phase153-shop-runtime-approved` je tvrdá obrazová brána bez masky.
