# Phase 182 — samostatný Profesorův výzkum a čisté mobilní dotyky

Fáze 182 odděluje dvě dosud smíšené funkce v horní části stojanu `ROSTLINY`.
Otazník nyní vždy otevírá obecnou nápovědu. Po odemčení Profesorova výzkumu se
vedle něj objeví samostatná malovaná ikonka Profesora Bazala; jedině ta otevírá
stávající fullscreen výzkum a nese oranžový vykřičník nové či vyzvednutelné
kapitoly.

## Vizuální a dotykový kontrakt

- otazník i Profesor mají vlastní nepřekrývající se dotykovou plochu 64 × 64 px;
- Profesorův portrét má 44 × 44 px a používá existující schválenou malbu
  postavy, žádné zdrojové PNG nebylo změněno;
- titul `MOJE ROSTLINY` se po odemčení výzkumu dynamicky posune, takže se s
  portrétem ani vykřičníkem nekříží při 432 × 960 ani 360 × 800;
- detail rostliny zachovává pouze obecný otazník a nevytváří druhý výzkumný
  vstup;
- černé systémové tooltip obdélníky jsou na mobilní platformě potlačené;
  desktopové tooltipy zůstávají dostupné, ale používají krémový komiksový panel
  místo černého Godot fallbacku;
- všechna současná produktová přiřazení tooltipů procházejí jednou politikou
  `TooltipPolicy`, takže se stejná chyba nemůže nahodile vracet z jednotlivých
  obrazovek.

Záměrně se nevypíná emulace myši z dotyku: na ní závisejí existující tlačítka a
gesta. Potlačen je pouze mobilní text tooltipu, ne samotné ovládání.

## Automatické a GPU ověření

- cílená sada: `.godot/phase182-tests.log`,
  `PHASE182_TESTS_PASSED=35`;
- skutečný GPU capture:
  `.godot/phase182-visual-20260829-194057Z`, značky
  `PHASE182_PROFESSOR_LAUNCHER_GEOMETRY=PASSED`,
  `PHASE182_TOOLTIP_FREE_CAPTURE=PASSED` a
  `HOW_TO_GROW_CAPTURE=PASSED`;
- úplná validace: `.godot/validation/20260829-194327Z`,
  `MVP_TESTS_PASSED=6743` a `HOW_TO_GROW_CAPTURE=PASSED`;
- závěrečná Quick automatizace po dokumentaci:
  `.godot/automation/20260829-195508Z`,
  `AUTOMATION_TECHNICAL_GATE=PASSED` a
  `HOW_TO_GROW_AUTOMATION=PASSED`;
- všech deset neúspěšných obrazových bran je přesně stejná historická sada jako
  v `.godot/validation/20260829-175257Z`; názvy, metriky i SHA-256 všech deseti
  aktuálních snímků jsou shodné. Všechny comparison obrazy byly znovu
  prohlédnuty. Reference, masky ani tolerance se neměnily.

## Hranice přijetí

`PHASE182_SOURCE_AND_INTERACTION_CONTRACT=PASSED`.
`PHASE182_TARGETED_TESTS=PASSED_35`.
`PHASE182_FULL_REGRESSION=PASSED_6743`.
`PHASE182_GPU_CAPTURE=PASSED`.
`PHASE182_FULL_VISUAL_GATE=FAILED_SAME_10_HISTORICAL_REFERENCES`.
`PHASE182_QUICK_AUTOMATION=PASSED`.
`PHASE182_USER_VISUAL_ACCEPTANCE=PENDING_USER_REVIEW`.
`PHASE182_ANDROID_PHYSICAL_TOOLTIP_AUDIT=NOT_RUN`.
`PHASE182_APK=NOT_CREATED`.

Fáze tedy technicky opravuje rozdělení funkcí a zdroj černých obdélníků, ale
neoznačuje vzhled nové ikonky ani fyzické dlouhé podržení na telefonu za lidsky
přijaté. Immutable RC58, jeho alias, hráčský save a publikování jsou mimo tento
zásah a zůstávají beze změny.
