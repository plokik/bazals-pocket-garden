# Fáze 154 — schválené malované Měření

Fáze 154 převádí uživatelem schválenou kompozici obrazovky Měření do živého
Godot runtime. Návrhový obrázek je pouze závazná výtvarná reference; není
zobrazen jako celoplošná zapečená obrazovka.

## Schválený zdroj

- target: `docs/visual-proposals/phase154/user-approved-painted-measurement-screen-v1.png`
- SHA-256: `D690ACB3D1BCF174F856E7D72498F976991879E24714F9BB1A68D81B5AB46FFB`
- společný styl: Phase147 malovaný cartoon master;
- prostředí runtime: existující byte-exact
  `assets/ui/visual/phase128/measurement_corner_backdrop_v1.png`;
- zdrojové PNG se nemění, pouze importní sidecar zapíná lineární mipmapy.

## Dynamický runtime

Malovaná laboratoř používá živý hero výřez s rostlinou, senzorem, měřidlem a
zkumavkami. Pod ním zůstává deset skutečných hodnot ve dvousloupcových kartách,
samostatné hladké ikony, 72hodinový graf, pěstitelská nápověda a svislý mobilní
scroll. Presenter i simulační model se nemění. Historický capture
`comic-measurement.png` zůstává odděleným gate a při jeho pořízení se obnoví
původní obsah karet.

Koncept zůstává v manifestu jen report-only. Skutečný dynamický Godot render
uživatel samostatně schválil 25. 8. 2026 a jeho append-only referenční kopie je
`assets/ui/comic/reference_phase154_measurement_runtime_v1.png` se SHA-256
`DCFBD62C674451A53CB286DC98292E91EA03BA2D17E79ED4E8927EA3A0E68CA5`.
Původní reference ani starší tvrdé baseline nebyly přepsány.

## Stav brány

```text
PHASE154_SOURCE_ACCEPTANCE=APPROVED_BY_USER
PHASE154_IMPLEMENTATION=IMPLEMENTED_DYNAMIC_RUNTIME
PHASE154_TECHNICAL_VALIDATION=PASSED
PHASE154_GODOT_RENDER_ACCEPTANCE=PASSED_INTERNAL_COHESION_AUDIT
PHASE154_USER_VISUAL_ACCEPTANCE=APPROVED_BY_USER
PHASE154_VISUAL_BASELINE_TRANSITION=PASSED_APPEND_ONLY_RUNTIME_GATE
PHASE154_MOBILE_ACCEPTANCE=DEFERRED_PHONE_UNAVAILABLE
PHASE154_APK=NOT_CREATED
PHASE154_PUBLISHING=OUT_OF_SCOPE
```

Immutable RC55, save schema 41, ekonomika, Rostliny, Sklad, Obchod, Skleník a
Pokoj zůstávají beze změny.

Úplná validace `.godot/validation/20260825-132647Z` prošla 1510/1510 kontrol,
capture i všemi 20 tvrdými obrazovými branami. Nový schválený runtime případ
prošel přesně s MAE 0,000 / RMSE 0,000 / 0,000 % změněných pixelů. Historický případ Měření prošel
s MAE 0,437 / RMSE 7,000 / 0,570 % změněných pixelů. Schválený Phase154 koncept
zůstává report-only (MAE 75,602 / RMSE 104,860), protože záměrně obsahuje jiný
zapečený herní stav. Responzivní matice
`.godot/responsive/20260825-124928Z` prošla 11/11 včetně samostatného skutečného
renderu Měření na 360×800.

Závěrečný Quick `.godot/automation/20260825-132926Z` skončil
`AUTOMATION_TECHNICAL_GATE=PASSED` a `HOW_TO_GROW_AUTOMATION=PASSED`;
zařízení nebylo vyžádáno a lidská brána zůstává samostatně čekající.
