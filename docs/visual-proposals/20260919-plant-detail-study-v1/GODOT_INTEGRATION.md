# Detail rostliny přímo ve hře

2026-09-19 — nativní kandidát k posouzení. Navazuje na webový návrh „Živý parapet“.

## Co je propojené

Kandidát instancuje skutečnou `main.tscn`. Používá existující `GameSession`, `PlantSimulation`, `PlantVitalsPresenter`, `PlantActionPresenter`, callbacky péče, ukládání, diagnostiku, herbář, navigaci a signály efektů. Vzhled pouze upravuje nad původními ovládacími prvky; nevkládá webovou stránku do hry a nepřebírá ukázkové výpočty z JavaScriptu.

Původní malované okno, rostliny všech druhů/stádií, keramika, podmisky, společný HUD a spodní navigace zůstávají součástí hry. Přeneseny jsou klidnější panely, jedna kresba ikon péče/ukazatelů/herbáře/nápovědy a čitelnější uspořádání akcí. Listy mají jemný pohyb a silnější odezvu větrání; květináč a podmiska se nehýbou. Respektuje pauzu, omezení pohybu a nemocné/uhynulé rostliny.

Nový vzhled je aktivován argumentem `--plant-detail-study`. Běžný start a schválené vizuální reference zůstávají beze změny, dokud uživatel neposoudí kandidáta ve hře.

## Spuštění

Z kořene projektu:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools\open_detail_study.ps1 -GodotPath R:\_projekty\Godot_v4.7-stable_win64.exe
```

Otevře hratelné okno Godotu. V názvu okna je označená testovací zahrada. Jde o skutečnou herní simulaci nad vygenerovanými daty; pro každý start se vytvoří oddělené APPDATA v `.godot/detail-study-appdata/play-*`. Žádný hráčský save se nečte ani nekopíruje. Telefon ani existující instalace v emulátoru se nemění.

## Cílené ověření

`tools/preview_detail_study.gd --plant-detail-study --verify` prošel **45 kontrolami**, nativní návratový kód 0, marker `DETAIL_STUDY_INTEGRATION=PASSED`.

- Reálné GUI vstupy pro zalití, větrání, hnojení a světlo změnily simulaci/zásoby a aktivovaly odezvu.
- Herbář, přepnutí vybrané rostliny a návrat ke stojanu fungovaly.
- Velikosti 432×960 a 360×800: cíle péče alespoň 44×64, popisky uvnitř tlačítek.
- Pohyb koruny, pevný květináč, omezení pohybu a nezměněná serializace při vykreslování.
- Napojení bazalky, levandule a šalvěje v prázdném, rostoucím, uhynulém a posklizňovém stavu.

Důkazy: `.godot/detail-study-final-checks.log` a `.godot/detail-study/final-captures/`. Snímky jsou kandidátní, nejsou schválenými referencemi. Celkový validační běh je uveden v doplněném výsledku níže. Android výkon a lidské přijetí nového vzhledu tím nejsou ověřeny.

## Celková regrese a otevřená ukázka

Běh `.godot/validation/20260919-143641Z` skončil kódem 0: `MVP_TESTS_PASSED=6767`, `HOW_TO_GROW_CAPTURE=PASSED`, `HOW_TO_GROW_VISUALS=PASSED`, `HOW_TO_GROW_VALIDATION=PASSED`. Všech 34 povinných vizuálních případů prošlo; historické případy v režimu report zůstávají informativní. Tato regrese běží nad běžným vzhledem bez kandidátního přepínače. Nový detail pokrývá výše uvedených 45 samostatných integračních kontrol.

Hratelná ukázka byla spuštěna a ověřena jako samostatné okno „Bazal’s Pocket Garden · návrh detailu · testovací zahrada (DEBUG)“, s markerem `DETAIL_STUDY_PLAYABLE=READY`. Snímek `preview-godot.png` pochází z nativního GPU vykreslení kandidáta. Telefon ani emulátor nebyly aktualizovány.
