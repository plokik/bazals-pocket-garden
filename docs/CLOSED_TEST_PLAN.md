# Plán uzavřeného testu Bazal’s Pocket Garden

Datum pravidel a návrhu: **2026-08-30**

Stav: `PLAN_ONLY_NOT_STARTED`

## Kdy je 12/14 povinné

Google Play vyžaduje closed test s nejméně 12 testery nepřetržitě přihlášenými
po dobu alespoň 14 dní pro **osobní vývojářské účty vytvořené po 13. listopadu
2023**, než lze požádat o production access. U staršího osobního nebo
organizačního účtu se konkrétní povinnost může lišit; rozhoduje Dashboard daného
Play Console účtu.

Projekt použije 12/14 jako kvalitativní minimum bez ohledu na právní/publikační
povinnost. „Nepřetržitě přihlášený“ není totéž jako povinné denní spuštění;
denní aktivitu Google v citovaném pravidle nepožaduje. Pro tento projekt však
chceme skutečný feedback, ne jen formální opt-in.

Oficiální zdroj:
[App testing requirements for new personal developer accounts](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en).

## Cíl a kohorta

- Minimum pro bránu: 12 testerů s nepřerušeným opt-in po celých 14 dní.
- Doporučený nábor: 15–20 lidí, aby odchod jednotlivce nesrazil minimum.
- Každý tester dostane opt-in link, instalační postup, stručný scénář a jeden
  jasný feedback kanál.
- E-maily testerů zůstávají v Play Console nebo soukromém seznamu vlastníka;
  nesmí být commitnuty do repozitáře ani do validačních důkazů.
- Hra nemá vlastní účet. Tester nepotřebuje herní credentials.

## Předpoklady startu

- [ ] RC59 má podepsaný AAB, unikátní versionCode a zaznamenaný SHA-256.
- [ ] 34/34 vizuálních bran a úplná automatizace jsou PASS.
- [ ] Internal test smoke na Play-generated APK je PASS.
- [ ] Privacy policy, Data safety, Ads, App access, target audience a content
  rating jsou vyplněné pro closed track.
- [ ] Store listing a screenshoty odpovídají testovanému buildu.
- [ ] Je určen vlastník triage a soukromý feedback kanál.
- [ ] Je připraven rollback na předchozí closed-test build bez ztráty save.

## Doporučená matice

Zahrnout, pokud jsou zařízení dostupná:

- Android 7/8 nebo nejstarší reálně podporovaný API 24+ telefon;
- Android 10/11;
- Android 13 s runtime notifikačním oprávněním;
- Android 14/15;
- Android 16 / API 36;
- malý 360×800 displej, běžný 432×960 a alespoň jeden vyšší/užší telefon;
- gesture navigation i tří-tlačítkovou navigaci;
- 60 Hz a alespoň jedno 90/120Hz zařízení;
- zařízení s výřezem a zařízení s omezenější pamětí.

Ne každý tester musí pokrýt vše; matice musí mít vlastníka pro každý sloupec.

## Čtrnáctidenní scénář

| Den | Povinné zaměření |
| ---: | --- |
| 1 | opt-in, instalace z Play, nová hra, první zasazení a základní navigace |
| 2 | běžná péče, růst, světla, minigesta a systémové Zpět |
| 3 | uložení, ukončení procesu, pokračování a zachování mincí/XP/slotů |
| 4 | návrat po delší době a pravdivý offline souhrn; 72 h ověřit fixture/emulátorem, ne falešným čekáním |
| 5 | notifikace odmítnout i povolit na oddělených zařízeních; hra musí fungovat v obou stavech |
| 6 | reálná připomínka na pozadí, restart telefonu a otevření správného slotu |
| 7 | export `.htgbackup`, zrušení pickeru, import, náhled a potvrzení obnovy |
| 8 | všechny čtyři hlavní obrazovky, swipe, spodní lišta, cutout a obě navigace Androidu |
| 9 | Pokoj: nákup, podržení, přesun a výměna obsazených květináčů bez poškození save |
| 10 | Skleník: výsadba, zálivka, dozrání, sklizeň a vizuální ukotvení sazenic |
| 11 | Sklad, Obchod, Měření, Herbář, Profesor a všechny modály |
| 12 | airplane mode, pozastavení/obnovení, příchozí hovor nebo audio focus a změna orientace systému bez rotace hry |
| 13 | nejméně 30 minut souvislé hry; sledovat teplotu, baterii, paměť, záseky a opakované přechody |
| 14 | opakování nalezených chyb, finální dotazník a potvrzení přesné verze buildu |

Změnu systémového času nebo časového pásma provádět primárně na emulátoru či
vyhrazeném testovacím telefonu; tester nemá riskovat osobní zařízení.

## Feedback formulář

U každého nálezu zaznamenat:

- anonymní tester ID;
- verzi Androidu a model;
- přesný `versionName`/`versionCode`;
- kroky, očekávaný a skutečný výsledek;
- opakovatelnost;
- screenshot nebo video bez osobních notifikací a bez raw save;
- závažnost `P0` ztráta dat/crash, `P1` blokující funkce, `P2` významná chyba,
  `P3` kosmetika;
- zda se chyba objevila offline, po návratu nebo po restartu.

Externí feedback kanál může zpracovávat e-mail či technická data podle vlastních
zásad. Tato skutečnost nemění Data safety aplikace, pokud feedback není sbírán
přímo hrou.

## Výstupní kritéria

- [ ] Nejméně 12 testerů zůstalo opt-in nepřetržitě celých 14 dní. Jde o
  projektové kvalitativní minimum; zákonná/publikační povinnost se nadále řídí
  typem a datem založení Play Console účtu.
- [ ] Není otevřený P0 ani P1 a každý P2 má rozhodnutí.
- [ ] Žádná potvrzená ztráta nebo tichá změna save schema 41.
- [ ] Instalace/update z Play zachovává postup.
- [ ] Backup picker, odmítnutí notifikací, restart a offline návrat mají fyzický
  důkaz alespoň na jednom podporovaném zařízení.
- [ ] Android vitals neukazují nový crash/ANR cluster; malý vzorek se nesmí
  vydávat za statistický důkaz nuly.
- [ ] Store listing, privacy a Data safety stále odpovídají skutečnému buildu.
- [ ] Je sepsaný souhrn feedbacku a seznam přijatých/odložených oprav.

Splnění 12/14 samo o sobě není schválení produkční kvality. Production access
je samostatná žádost a produkční publikování zůstává mimo RC59.
