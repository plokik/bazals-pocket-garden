# Průchod hrou v Android emulátoru – 23. 10. 2026

Aktuální zdrojová verze `c113d7bf` byla ovládána skutečnými dotyky a tahy přes ADB v emulátoru `Bazal_Current_Source_API36`. Nejde o přehrání deterministických snímků ani o nový běh funkční sady. Ověřený instalovaný APK má SHA-256 `f50f9a1c4ad277682ce884e22dc4b382222e1bb686a96ee588eb0ec5abd3c2c9`.

Výsledek: **5 potvrzených nedostatků**. Během průchodu nebyl pozorován pád hry. Dvě ukončení systémovým Zpět z kořenové obrazovky byla běžným ukončením aplikace; černý prázdný launcher emulátoru není pád hry.

## Nalezené závady

| ID | Priorita | Závada a dopad | Důkaz |
|---|---|---|---|
| A01 | P2 | V dílně otevřít recepty, sjet k Posilujícímu toniku, rozbalit výběr rostliny a stisknout systémové Zpět. Zavře se celý dialog receptů místo samotné rozbalené nabídky. Zopakováno dvakrát. | [Před](evidence/back-popup-before.png), [po](evidence/back-popup-after.png), [nativní záznam](evidence/back-popup-repro.mp4). |
| A02 | P2 | Nastavení nabízí VIBRACE · ZAP, ale instalovaný APK nežádá o `android.permission.VIBRATE`. Godot při vyvolání haptiky vypisuje `SecurityException: VIBRATE permission not found`. Oprava patří do Android exportu/manifestu; ověření síly vibrací vyžaduje fyzický telefon. | [Nastavení](evidence/settings-vibrations.png), [požadovaná oprávnění a runtime log](android-haptics.txt). |
| A03 | P3 | Kouzelný showroom ukazuje předchozí podobu pokoje s odlišnými policemi a výzdobou; současná dílna používá jinou malbu. Také popisy slibují bubliny nebo girlandu z původního návrhu. Po nákupu tyrkysové varianty za 35 mincí se změnil barevný tón současné dílny; neoznačujeme nákup za nefunkční. Problémem je nesoulad náhledu s výsledkem. | [Showroom](evidence/old-showroom.png), [skutečná dílna po nákupu](evidence/actual-workshop.png). |
| A04 | P3 | Nová hra: výběr semínka zobrazuje `V zásobě: 1 semínek`. Chybí české skloňování podle počtu. | [Nový profil s jedním semínkem](evidence/seed-single.png). |
| A05 | P3 | V tutorialu při kroku Zabalit ručka pod zvýrazněným tlačítkem zasahuje do následujícího tlačítka Využít v dílně. Správný krok funguje, ale ručka zhoršuje čitelnost vedlejší akce. Výpočet polohy kontroluje kartu profesora a okraj obrazovky, nikoli sousední ovládací prvky. | [Překrytí ručkou](evidence/tutorial-hand-overlap.png). |

Místa k následné opravě: `scripts/main.gd:722` (pořadí obsluhy Zpět), `scripts/audio_soundscape.gd:223` a Android export (haptika), `scripts/ui/cosmetic_showroom_visual.gd` a malba showroomu, `scripts/ui/seed_selector_presenter.gd:25` (skloňování), `scripts/ui/guided_tutorial.gd:302` (poloha ručky). Tento audit produkční kód neopravuje.

## Co bylo skutečně ověřeno

| Oblast | Provedený průchod |
|---|---|
| Nová hra a profesor | Tři úvodní filmové stránky, tlumení pozadí, animovaný text, navazující vedení ke stojanu, výběru semínka, sázení, zalití, měření a růstu. Později načten skutečný rozpracovaný profil po přirozeném offline dozrání; sklizeň a zahájení sušení. Čekací krok lze odložit tlačítkem Nechat sušit. Závěr je evidován samostatně níže. |
| Stojan a detail | Prázdný a obsazený stojan, uzamčené pozice začátečníka, zdravá, zralá, nemocná, zvadlá a uhynulá rostlina. Kontrola detailu bazalky, rozmarýnu a levandule, náhled odumřelého oregana. Úspěšné ošetření rozmarýnu, větrání, přepnutí lampy a potvrzená výměna za mátu. |
| Diagnostika a herbář | Zdravé i nemocné podmínky, doporučený zásah, přechod zpět k ošetření, rolování herbářem a navazující mistrovství. U levandule na stojanu a v navštíveném detailu nebylo zjištěno oříznutí. [Detail](evidence/lavender.png). |
| Sklad | Výběr šarže v dlouhé nabídce, sklizeň, spuštění sušení, prázdné místo na stojanu po sklizni, připravená suchá šarže, zabalení/prodej a změna mincí. Prohlédnuta nástěnka zakázek i zásoby výrobků. |
| Obchod | Všechny čtyři záložky: nabídka, pomůcky, vybavení a výkup; posuv seznamů a stavy dostupnosti. Nebyl proveden nákup každé položky nebo každé úrovně vybavení. |
| Měření | Senzory, graf, legenda, vysvětlení měřených hodnot a pěstitelská nápověda při rolování. |
| Dílna | Nová pevná malovaná kompozice, dialog receptů a jeho posuv. Výroba mátového receptu s hmoždířem a září. Rozbalovací nabídka tonika odhalila A01; aplikace všech čtyř receptů nebyla samostatně dokončena. |
| Výrobky a zakázka čajovny | Všechny tři karty výrobků. Vyroben a prodán čaj, přijata a odevzdána zakázka, zkontrolována změna zásob a připsaná odměna. |
| Hratelná čajovna | Skutečné spojování prstem včetně šikmých tahů, neplatný krátký tah, nápověda, propadání a doplňování dílků. Splněny oba cíle objednávky, podržené nalévání, výsledek a další objednávka, přepnutí klidného pohybu. [Výsledek](evidence/tea-result.png). |
| Kolo štěstí | Bezplatné roztočení a připsání odměny, dvě odměny potvrzené testovacím reklamním SDK, zobrazení vyčerpaného denního limitu, běžící odpočet obnovy. [Denní limit](evidence/wheel-limit.png). Při zavření reklamy se může nejdříve objevit souhrn návratu do zahrady. Zrušení reklamy bez odměny nebylo jednoznačně ověřeno. |
| Denní výzva, balíček, úrovně | Prohlédnuta denní výzva a prázdná botanická zásilka. Vyzvednuta odměna za úroveň 10, navštíven a rolován pěstitelský deník. Získána zásilka za profesorovu kapitolu a otevřena jako duplicitní semínko pažitky. |
| Profesorův výzkum | Na modelem validovaných testovacích profilech vyzvednuty všechny tři příběhové kapitoly, přijat týdenní protokol a vyzvednuta připravená týdenní odměna. Zkontrolováno čekání na další protokol. Profily umožňují navštívit pozdní stavy; nejde o tvrzení, že byly během tohoto auditu odehrány týdny postupu. |
| Centrum péče a nastavení | Prioritní karty, obrazovka Android připomínek ve vypnutém stavu, přepnutí hudby, zvuků, vibrací a omezení animací zpět do původní testovací polohy. Dialog zálohy a potvrzovací stav nové hry; destruktivní potvrzení nebylo provedeno. |
| Skleník venku | Venkovní malba, tři motýli, jejich let a jemná aura, lesk dveří, efekt kliky a vstup dovnitř. Zakoupen čajovník za 60 mincí a ověřen stav trvalého vlastnictví i venkovní malba. [Motýli](evidence/butterflies.png). |
| Skleník uvnitř | Čtyři záhony s různými stavy; úspěšně zasazeno rajče, zalita paprika a sklizeno zralé rajče, zkontrolována změna mincí a XP. |
| Kocour a myš | Průchod stojanem, detailem a venkovní scénou. Nativně zachycena venkovní honička s myší. V dílně dva 55sekundové záznamy pokrývají spánek se Zzz, protažení, zívání, olizování, čištění, sezení, cestu k vodě, pití, chůzi i návrat do pelíšku. [Přehled snímků](evidence/cat-cycle.png). V těchto vzorcích nebylo potvrzeno nové oříznutí nebo skok mezi obrazovkami. |
| Android návrat a rozložení | Návrat z pozadí, přirozený offline postup, standardní rozlišení 1080×2400 a doplňkový venkovní záznam při 1080×2040; override rozlišení poté odstraněn. Doplňkový záznam nepokrývá celý cyklus kocoura na druhém poměru stran. |

## Rozsah a meze

- Základem byl čerstvý profil a pět připravených pozdních profilů, vytvořených skutečným modelem hry a ověřených round-trip načtením. Původní hráčské soubory byly pro audit odloženy beze změny; výsledek obnovy je uveden ve `verification.json`.
- Jde o průchod hlavními obrazovkami a reprezentativními animacemi. Není to vyčerpávající důkaz všech kombinací druhů, chorob, zakázek, přerušení a každého snímku všech atlasů. Nativní záznamy mají 14 Mb/s a nemají zvuk. Nebyla posuzována kvalita hudby a nebyl měřen dlouhodobý výkon telefonu.
- Neproběhl fyzický telefon, skutečný půlnoční reset kola, dlouhodobé doručování notifikací, zaplnění disku ani export/import přes všechny poskytovatele Android dokumentů. Automatické funkční testy a schválené vizuální reference se v tomto průchodu neměnily ani znovu nespouštěly; audit používá stejný již ověřený APK.
- Hypotéza o neviditelnosti kocoura při některých rozměrech scény nebyla v tomto průchodu jednoznačně potvrzena jako chyba běžícího emulátoru. Nezapočítává se do nálezů. Běžná pauza kocoura mimo obrazovku ani záměrná nepřítomnost ve skladu a obchodě se za chybu nepovažují.
- Úplné lokální screenshoty, záznamy, gesta, pomocné skripty a testovací profily zůstávají v ignorované složce `tmp/emulator-gameplay-audit-20261023`. Do zprávy byly přeneseny jen vybrané důkazy. Nebyl vytvořen commit, push ani release.

## Dokončení tutorialu a obnova profilu

Výuková bazalka přirozeně dozrála při odloženém testovacím profilu. Sušení pak doběhlo ve skutečném tříminutovém čase při přepnutí aplikace do pozadí. Následovalo ruční zabalení a prodej. Uložený model potvrzuje `journey_completed=true`, `journey_reward_claimed=true`, `journey_step=9`; zůstatek testovacího profilu je 77 mincí. [Závěr s profesorem](evidence/tutorial-complete.png), [stav modelu](tutorial-completion.json).

Před opětovným spuštěním původní hry bylo všech **30 původních aplikačních souborů shodných po bajtech** s předtestovou kopií. Původní adresář nebyl při auditu přepisován. Testovací soubory jsou odložené zvlášť, původní profil je obnovený a aktuální hra běží. Přirozený offline postup po spuštění je běžné chování hry. Kontrola zahrnuje aplikační adresář `files`, nikoli tvrzení o identitě všech Android SDK preferencí; před obnovou nezůstala nevyřízená reklamní odměna. Rozlišení je opět 1080×2400 a APK zůstal stejný. Produkční soubory a schválené reference zůstaly beze změn.
