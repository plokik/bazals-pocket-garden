# Ze skladu rovnou k receptu — návrh ke schválení

11. 10. 2026. Navazuje na přehlednější dílnu.

U vybrané suché nezabalené sklizně se objeví tlačítko **VYUŽÍT V DÍLNĚ**. Otevře Bazalovu dílnu s viditelnou kartou mátové výživy pro mátu peprnou, rozmarýnového tonika pro rozmarýn nebo základního bylinného hnojiva pro ostatní druhy. Základní recept nadále používá společnou zásobu suchých bylin, jak uvádí jeho karta.

Jde pouze o přechod k receptu. Nespotřebuje byliny ani mince a je dostupný i při nedostatečných zásobách na výrobu. Hráč uvidí chybějící množství v existujícím dialogu; výrobu spouští až tam. Zavření receptů vrací pohled na dílnu. Do skladu vede jeho běžná spodní záložka.

Původní balení zůstává samostatnou hlavní akcí. Čerstvá, právě sušená, zabalená nebo prázdná sklizeň novou volbu nemá. Tlačítko má nejméně 56 px na výšku a oddělený prostor pod balením. Používá současný malovaný zelený rámeček, nepřidává novou grafiku, odměnu ani uložená pole.

## Ověření

- Kompletní sada: `MVP_TESTS_PASSED=7538`, návratový kód 0. Samostatné kontroly dílny: 107/107. Nový izolovaný profil pro každý běh; bez chyb skriptů a parsování. Staré diagnostiky metadat ventilace zůstávají mimo tuto změnu.
- Funkční testy doplňují správný recept pro tři druhy, přechod bez utrácení, dvojklik, nedostatek mincí, dotykový tah, blokující dialog, neplatné množství, návrat a rychlé zavření před dokončením automatického posunu.
- Nativní Godot: 360 × 800 a 432 × 960 px; skutečné snímky skladu a otevřených receptů.
- Sušení a zabalená sklizeň jsou v obou velikostech pixelově stejné jako před změnou: čtyři porovnání, průměrná RGB odchylka 0 (`comparison.json`).
- Malované atlasy a skript animace dílny zůstaly beze změny (`art-check.json`). Ceny, účinky, práce se zásobami a ukládací schéma se nemění.
- Android API 36 x86_64: skutečný dotyk na nové tlačítko otevřel mátovou výživu; systémové Zpět zavřelo recepty do dílny. Porovnání uložených dat potvrdilo stejné mince, semínka, dávky hnojiva, sklizeň, XP, postup druhů i hmotnosti a fáze uskladněných bylin. Součástí návrhu je přímý záznam `storage-to-workshop-android.mp4`.
- Schválené vizuální reference se nemění. Nové PNG jsou návrh k posouzení. Plná historická golden sada v tomto kroku neběžela.
- Osobní profil a fyzický telefon nebyly použity. Bez commitu, publikace na GitHub či nového releasu.

Finální počty kontrol, Android a identita sestavení jsou v `verification.json`. Pracovní logy a izolované profily leží v `.godot/workshop-storage-20261011/`.

Testovací APK: `builds/android/storage-workshop-current-source.apk`; oddělený balíček `com.howtogrow.game.wheeltest` v `builds/android/storage-workshop-wheeltest.apk`. Vlastní read-only emulátor byl po ověření ukončen bez uložení snapshotu.

## Změněné části

- `scripts/ui/storage_pipeline_presenter.gd`: viditelnost odkazu a vysvětlení dvou možností využití suché byliny.
- `scripts/main.gd`: tlačítko a bezpečný přechod ze skladu.
- `scripts/ui/workshop_modal.gd`: posun na odpovídající kartu po dokončení rozložení a zrušení odloženého posunu při zavření.
- `tests/workshop_test.gd`: regresní scénáře propojení.
