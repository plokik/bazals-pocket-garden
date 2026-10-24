# Čajovna: lístek, odměna a ověření kapitoly

**Aktualizace 24. 10. 2026: bonus kouzelného lístku uživatel výslovně zamítl a byl úplně odstraněn, včetně tlačítka a efektů. Nenahrazuje ho jiný bonus. Čajový medailon a reference showroomu stále čekají na samostatné schválení.**

Video, snímky a původní protokoly níže jsou archivem dřívějšího návrhu; bonus už není součástí aktuálního zdrojového stromu. Do běžné Android hry nikdy nebyl přidán. Podrobnosti odstranění jsou v `removal-verification.json`.

## Původní návrh a aktuální rozhodnutí

1. **Kouzelný lístek – ZAMÍTNUTO, ODSTRANĚNO:** původně měl řetězec šesti bylinek získat pomoc pro doplnění až tří kusů. Pravidlo, ovládání ani efekty se do hry nezařadí.
2. **Čajový medailon:** malovaná ozdoba na volné stěně dílny po dokončení kapitoly. V tomto návrhu je zatím ukázkou umístění, bez přidělení vlastnictví nebo zásahu do uložené hry.
3. **Reference showroomu:** [přesné porovnání](showroom/README.md) historické reference a již existující dílny. Schválení tohoto bodu je samostatné; reference nebyla změněna.

![Skutečný průchod návrhem](gameplay-listek-a-odmena.mp4)

Video je 1080×2400, 30 snímků/s, přibližně 48 sekund, s původní hudbou a zvuky. Zachycuje skutečné vstupy do samostatně hratelného návrhu, přirozenou desku úrovně 10, získání lístku, výběr máty, dokončení receptu a nalití čaje. V závěru ukazuje medailon ve skutečné dílně na odděleném připraveném profilu. Nejde o záznam Androidu.

## Co je v běžné hře

Android verze obsahuje deset úrovní, mapu, dílnu, uložené hvězdy, první odměny a kapitolu. Nové prototypové soubory jsou vyloučené z exportu pravidlem `prototypes/**`. Fyzický telefon nebyl v této etapě testován. Nevzniká nový release.

Finální APK: `builds/android/bazals-pocket-garden-20261024-chapter10-notice-x86_64.apk`, SHA-256 `30AEC72B6A99FE10F1F0D863556D968F944D546449965F93DE6C1FBA71BEB6C8`. Obě aktualizace proběhly pomocí `install -r`; při každé bylo všech 32 privátních souborů před prvním spuštěním bajtově porovnáno a zachováno. Soukromé zálohy zůstávají mimo Git v `tmp/teahouse-next-20261024/`.

Výsledky skutečných dotykových průchodů jsou v `device-verification.json`; jejich snímky jsou označené `emulator-*`. Automatizace porovnává desku po každém tahu a zastaví při rozdílu. Tento technický průchod nenahrazuje osobní posouzení zábavnosti nebo výkonu na telefonu. Emulátor část doby sdílel počítač s renderováním videa; podle těchto časů nehodnotíme výkon hry.

Dokončeno všech **10 úrovní**, 119 tahů (včetně šesti zakřivených gest), 21 hvězd. Odměny +40 a +80 mincí byly vyzvednuté právě jednou. Po opětovném otevření odměny a restartu zůstalo 450 mincí, 20 semínek meduňky a celý postup. Při průchodu nalezené překrytí potvrzovacího textu tlačítkem je opravené; snímky `emulator-notice-before.png` a `emulator-notice-fixed.png` ukazují rozdíl.

## Historické ověření před odstraněním bonusu

- Plná funkční regrese po opravě potvrzení: **9 093 kontrol**; šest nových kontrol ověřuje skutečně vykreslený text při úspěchu i selhání ukládání, jeho čitelnost a odstup od tlačítek. Původní protokol 9 087 kontrol zůstává zachovaný; finální běh je v `quest-notice-validation/`.
- Izolovaný lístek: **642 modelových a 56 UI kontrol**. Včetně myši, dotyku, rušení, přepnutí okna, změny rozměrů, klidného pohybu, restartu a opakování z výsledku.
- Finální vizuální běh má **33/34**; jedinou odchylkou je stará reference showroomu se stejnými hodnotami jako před opravou. Čerstvě zachyceno 187 snímků. Porovnání po opravě potvrzení je v `quest-notice-validation/`. Reference showroomu čeká na samostatné schválení; celkovou vizuální validaci neoznačujeme za zelenou.
- Všech 54 schválených referenčních obrázků zůstalo nezměněných. Nové prvky posuzuje tento návrh, nejsou zahrnuté do historických schválených referencí.
- U medailonu byla zkontrolována alfa, poměr stran a odstup od police, cedulky i kola. Opraveno původní překrytí s cedulkou; finální záběr ukazuje jeho nové umístění.

Identita zdrojů a instalačního balíku je v `delivery.json`; ověřený stav nahrání na GitHub a jeho CI je uvedený v závěrečném předání v chatu. Historické protokoly starších návrhů zůstávají zachované jako záznam příslušné etapy.

Video bylo zachyceno před následnou opravou pozice zprávy v dialogu odměny; tento dialog ve videu není. `capture-source-snapshot.json` popisuje zdroje skutečného záznamu a nepředstírá shodu s pozdější opravou.
