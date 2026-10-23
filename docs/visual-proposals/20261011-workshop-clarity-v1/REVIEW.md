# Přehlednější Bazalovy recepty — návrh ke schválení

Datum: 11. 10. 2026. Navazuje na schválené rozmarýnové tonikum.

## Co se změnilo

- Každý recept ukazuje dostupné / potřebné množství konkrétní byliny a mincí.
- Chybějící byliny i mince se zobrazují současně, včetně množství. Zásoba se nezaokrouhluje nahoru tak, aby nedostatek vypadal jako splněná podmínka.
- Připravené tonikum ukazuje očekávané zdraví před a po použití. Při přípravě je tlačítko označené „MÍCHÁM…“.
- Uzdravená rostlina zůstane vybraná. Další dávka nemůže bez nové volby přeskočit na jiný květináč. Obě nabídky tonik sdílejí stejný výběr.
- Pokud nelze ukládat, dialog to vysvětlí a žádné suroviny nespotřebuje.

## Zachované části

Oba malované atlasy a celý skript animace mají stejný SHA-256 jako před změnou (viz `preserved-art-after.json`). Ceny, účinky, ukládací schéma a transakční zápis receptů se nemění. Změna se týká tří souborů: `scripts/ui/workshop_modal.gd`, `scripts/workshop_recipes.gd` (informace pro UI) a `tests/workshop_test.gd`.

## Ověření

- Kompletní funkční sada: `MVP_TESTS_PASSED=7516`, návratový kód 0. Běžela samostatně s novým izolovaným profilem.
- Doplněné kontroly zahrnují zachování a výslovnou změnu cíle, opakované použití, současný nedostatek, přesnost zobrazení, doplnění zásob, animaci a blokované ukládání.
- Nativní Godot: snímky při šířce 360 a 432 px, připravený recept, míchání, uzdravený cíl, nedostatek a žádný vhodný cíl. Marker `WORKSHOP_CLARITY_NATIVE_CAPTURE=PASSED`.
- Android API 36 x86_64, samostatná testovací aplikace: dvojklik i další klepnutí po uzdravení spotřebovaly celkem jen 2 g rozmarýnu a 4 mince. Zdraví první rostliny vzrostlo z 70 na 90, druhá zůstala přibližně na 55 (běžná simulace dále běžela). Ověřený ruční výběr druhé rostliny a zachování zásob i účinku po restartu. Záznam `clarity-android.mp4` má 8,43 s.
- Snímky jsou návrhy ke schválení, nikoli nové schválené reference. Plná historická sada vizuálních referencí v tomto kroku neběžela; reference se neupravovaly.
- Starší sada testů nadále vypisuje známé diagnostiky chybějících metadat animace ventilace; finální běh nemá žádné selhané kontroly ani chyby parsování či skriptů.
- Osobní uložený postup ani fyzický telefon nebyly použity. GitHub a release nejsou součástí tohoto kroku.

## Náhledy

- `rosemary-ready-360.png`, `rosemary-ready-432.png`: zásoby a očekávaný účinek.
- `missing-360.png`: současný nedostatek bylin, mincí a požadavek na novou volbu cíle.
- `healed-target-360.png`: původní rostlina po úspěšném použití zůstává vybraná.
- `mint-ready-360.png`: stejný přehled pro mátovou výživu.
- `no-target-360.png`: vysvětlení, že žádná rostlina tonikum nepotřebuje.

Podrobné výsledky a SHA-256 sestavení i změněných zdrojových souborů jsou v `verification.json`. APK zdroje: `builds/android/clarity-workshop-current-source.apk`; izolovaná testovací kopie: `builds/android/clarity-workshop-wheeltest.apk`. Po testu byl vlastní dočasný emulátor ukončen.
