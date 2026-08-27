# Fáze 114 — publikační rozsah automatizace

Stav: **hotovo ve zdrojových nástrojích; runtime a RC37 beze změny**.

## Problém

Uživatel výslovně rozhodl, že projekt se zatím nemá veřejně publikovat. Dokumentace proto používala `PUBLISHING_GATE=OUT_OF_SCOPE_BY_USER`, ale automatický pracovní a release runner dál bezpodmínečně zapisoval `PENDING_RELEASE_KEYSTORE_AAB_STORE_REVIEW`. Technický report tak zaměňoval vědomě odloženou práci za nedokončenou bránu.

## Řešení

`tools/run_project_automation.ps1` a `tools/run_release_candidate.ps1` nyní používají stejný opt-in kontrakt:

- bez přepínače je `PUBLISHING_GATE=OUT_OF_SCOPE_BY_USER`;
- pouze explicitní `-PublishingRequested` změní stav na `PENDING_RELEASE_KEYSTORE_AAB_STORE_REVIEW`;
- režimy `Release` a `ReleaseDevice` předají publikační záměr jedinému release runneru;
- JSON, Markdown i stabilní výstupní markery používají stejnou odvozenou hodnotu.

Přepínač nic nepublikuje, nevytváří AAB a nepracuje s klíčem. Pouze pravdivě vrací publikační checklist do rozsahu budoucího běhu.

```powershell
# Současný lokální vývoj: publikování je mimo rozsah.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\run_project_automation.ps1 -Mode Quick

# Budoucí vědomé vrácení publikační brány do rozsahu.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\run_project_automation.ps1 -Mode Full -PublishingRequested
```

## Hranice

Fáze 114 mění pouze PowerShell orchestrace, regresní kontrakty a dokumentaci. Nemění GDScript runtime, ekonomiku, save schema 33, exportní payload ani již vytvořený immutable RC37. Neinstaluje APK a nijak nezasahuje do dobíhajícího RC36 long-delay testu na telefonu.

## Důkazy

- PowerShell AST obou runnerů: `PASSED`.
- Výchozí Quick `.godot/automation/20260821-202456Z`: `MVP_TESTS_PASSED=1321`, technická brána `PASSED`, `AUTOMATION_PUBLISHING_GATE=OUT_OF_SCOPE_BY_USER`.
- Opt-in Quick `.godot/automation/20260821-202538Z`: stejných 1 321 kontrol a `AUTOMATION_PUBLISHING_GATE=PENDING_RELEASE_KEYSTORE_AAB_STORE_REVIEW` pouze po explicitním `-PublishingRequested`.
