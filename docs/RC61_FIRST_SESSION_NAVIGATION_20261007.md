# První hráčská relace – jasnější navigace

Datum: 7. října 2026. Výchozí commit: `e887933` na `fix/rc61-feedback-motion`.

## Co se změnilo

Profesor místo obecného „UKÁZAT MÍSTO“ pojmenuje cíl aktuálního úkolu:

| Úkol | Tlačítko |
| --- | --- |
| První semínko | K SEMÍNKŮM |
| První zálivka | K ZÁLIVCE |
| Návštěva měření | OTEVŘÍT MĚŘENÍ |
| Růst | K ROSTLINĚ |
| Sklizeň, sušení, balení a prodej | OTEVŘÍT SKLAD |

Text vlastní stávající `GuideDialogPresenter`. Main používá původní navigační obsluhu. Tlačítko otevře místo; samo nezasadí, nezalije, nesklidí ani neprodá. Běžné rady a dokončený cyklus nadále nabízejí „ROZUMÍM“. Rozložení, obrázky, animace, ceny, herní časy a schéma uložených dat se nemění.

## Ověření

- Celý projektový runner: **6 873 úspěšných kontrol**, capture PASS, visuals PASS, validation PASS.
- **34 schválených vizuálních bran** prošlo; reference, masky a tolerance nebyly upraveny.
- Nový integrační test projde všech devět výukových kroků přes skutečné tlačítko Profesora, vždy po serializaci a načtení relace. Kontroluje cílovou obrazovku, detail/semínka, šířku textu a zachování rostliny, mincí, XP a semen. Návštěva měření splní svůj původní výukový krok.
- Další kontrola rozlišuje běžnou radu a dokončený cyklus, aby nepřevzaly navigaci z předchozího úkolu.
- První CI průchod odhalil závod v novém testu: načtení relace záměrně obnoví běh času a na pomalejším stroji mezi dvěma snímky povyrostla rostlina. Test proto po načtení výslovně zastaví simulační čas pro ověření samotné navigace. Porovnání kompletního stavu rostliny zůstává přesné; produkční běh času se nemění.
- Samostatný scénář nové hry bez změn profilů prošel zasazením, zálivkou, měřením, růstem, sklizní, sušením a balením až k první zakázce „Svěží lístky na pesto“. Obsluhu spouští existující UI signály; čekání posouvá deterministicky v simulaci. Není to fyzický dotykový test ani měření délky reálné relace.
- Výsledek scénáře: 4,9 g sušiny, kvalita 96,69 %, jedna dokončená zakázka, dokončená úvodní cesta; příjem 57 mincí a 48 XP zahrnuje první jednorázovou odměnu. Uložená relace se následně správně načetla. Scénář používá vlastní APPDATA; hráčův save se nepoužívá.
- V tomto konkrétním scénáři trval růst 840 simulačních sekund a sušení 180 sekund. Nejde o univerzální dobu pro všechny podmínky ani důvod k automatické změně vyvážení.

Lokální důkazy: `.godot/first-session-20261007/validation-final/`, `first-order-audit.json`, `order-audit.log` a samostatné snímky průvodce v `after/` a `compact/` (432×960 a 360×800). Nejsou schválenými novými referencemi.

Telefon nebyl testován. Verze hry, hlavní větev ani publikovaný release se nemění.

## Další pracovní krok

Prověřit čekání a návrat do hry: srozumitelnost zbývajícího času, přechod růst → sklizeň a sušení → balení, návratový souhrn a jednorázové odměny. Teprve podle zjištění navrhnout úpravu vedení hráče během čekání; časy a ekonomiku zatím ponechat.
