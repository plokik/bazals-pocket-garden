# Fáze 155 — schválený malovaný Herbář

Fáze převádí uživatelem schválenou kompozici Herbáře do skutečného dynamického
Godot rozhraní. Schválená předloha je archivovaná append-only jako
`docs/visual-proposals/phase155/user-approved-painted-herbarium-screen-v1.png`
s SHA-256
`9aba0f190f2acfc3c7795616b8e9a6c0e2f3805c10b3f0bdc8fc6a9cfdd4c697`.
Není použita jako zapečený screenshot hry a zůstává pouze report-only vizuálním
cílem.

## Runtime řešení

Čisté malované prostředí je oddělená vrstva
`assets/ui/visual/phase155/herbarium_clean_backdrop_v1.png` s SHA-256
`9f2bf8a11d0191fca4867ef56e56120ed36eff2f66de2722f574de2606d04a48`.
Neobsahuje text, hodnoty, portréty druhů, postup ani odměny. Nad něj Godot skládá:

- dynamický titul a dvě živá souhrnná pole sbírky a mistrovství;
- všech jedenáct druhů vrácených autoritativním katalogem;
- živé portréty, objevení, vzácnost, hodnost, popis, vlastnosti a statistiky;
- skutečný postup a tlačítka mistrovských odměn;
- přehrání předání zahrady, stavovou zprávu a obě zavírací dotykové plochy;
- svislý mobilní scroll `herbarium` bez vodorovného přetékání.

Komponent zůstává `fullscreen_herbarium_modal_v1`, takže se nemění blokování hry,
navigace ani starší funkční kontrakty. Zdrojové PNG rostlin ani immutable RC55
nejsou změněné.

## Vizuální a release hranice

`phase155-herbarium-approved-target` porovnává schválený návrh se skutečným
`comic-phase155-herbarium.png`, ale zůstává úmyslně report-only. Uživatel
samostatně schválil skutečný Godot render 25. 8. 2026. Jeho byte-exact append-only
kopie `assets/ui/comic/reference_phase155_herbarium_runtime_v1.png` má SHA-256
`8af6514760bba55dd78f47a0945febbd744ed65ae4462c1703399f32e9cc4530` a případ
`phase155-herbarium-runtime-approved` ji chrání jako tvrdou bránu. Telefon není
v této fázi dostupný, nevzniká APK a nic se nepublikuje.

PHASE155_SOURCE_ACCEPTANCE=APPROVED_BY_USER

PHASE155_IMPLEMENTATION=IMPLEMENTED_DYNAMIC_RUNTIME

Finální validační brána po aktivaci schváleného baseline
`.godot/validation/20260825-155831Z` prošla s
`MVP_TESTS_PASSED=1515`, `HOW_TO_GROW_CAPTURE=PASSED`,
`HOW_TO_GROW_VISUALS=PASSED` a `HOW_TO_GROW_VALIDATION=PASSED`. Všech 21
tvrdých obrazových bran zůstalo zelených a nový runtime gate dosáhl přesné
shody MAE 0,000 / RMSE 0,000 / 0,000 % změněných pixelů. Report-only srovnání
konceptu má MAE 49,797, RMSE 72,805 a 77,612 % změněných pixelů; rozdíl je
očekávaný, protože předloha není zapečený runtime screenshot. Responzivní audit
`.godot/responsive/20260825-154636Z` prošel 12/12 včetně samostatného
`phase155_herbarium_360x800`. Závěrečný Quick po uzavření baseline
`.godot/automation/20260825-160228Z` skončil
`AUTOMATION_TECHNICAL_GATE=PASSED` a `HOW_TO_GROW_AUTOMATION=PASSED` bez
zařízení, APK nebo publikování.

PHASE155_TECHNICAL_VALIDATION=PASSED

PHASE155_GODOT_RENDER_ACCEPTANCE=APPROVED_BY_USER

PHASE155_USER_VISUAL_ACCEPTANCE=APPROVED_BY_USER

PHASE155_VISUAL_BASELINE_TRANSITION=PASSED_APPEND_ONLY_RUNTIME_GATE

PHASE155_MOBILE_ACCEPTANCE=DEFERRED_PHONE_UNAVAILABLE

PHASE155_APK=NOT_CREATED

PHASE155_PUBLISHING=OUT_OF_SCOPE

PHASE155_RC55=IMMUTABLE
