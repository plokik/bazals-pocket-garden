# Fáze 121 — ochrana akcí při fyzickém swipu

Fáze 121 stabilizuje globální vodorovnou navigaci z fáze 119 podle nálezu na skutečném telefonu. Swipe přes kartu v Obchodě správně změnil hlavní obrazovku, ale uvolnění prstu současně dokončilo `pressed` původního nákupního tlačítka. Navigace tak omylem koupila Pažitku a Bazalku za celkem 28 mincí.

## Runtime kontrakt

- Jakmile je gesto bezpečně uzamčené jako vodorovné, akční tlačítka ignorují stisk během tahu i následný release téhož gesta.
- Ochrana zůstává aktivní přes doručení GUI release a ruší se odloženě v dalším průchodu hlavní smyčkou.
- Každý nový dotyk používá vlastní generaci, takže staré odložené uvolnění nemůže odemknout právě probíhající gesto.
- Svislý scroll ani běžné samostatné klepnutí nejsou blokované.
- Čtyři hlavní obrazovky, směrový modro-zlatý efekt a bezpečné hranice bez přetáčení zůstávají beze změny.

## Regrese

Integrační test používá skutečné nákupní tlačítko Bazalky. Ověří nulovou změnu mincí i inventáře při signálu během vodorovného tahu a při signálu stejného release. Samostatná testovací akce v následujícím snímku současně potvrzuje, že ochrana nezůstala viset a běžný tap opět projde.

## Oprava hráčského postupu

RC45 fyzický audit začal s 73 mincemi, 2 semínky Bazalky a 0 semínky Pažitky. Dvě nechtěné transakce zanechaly 45 mincí, 3 semínka Bazalky a 1 semínko Pažitky. Před dalším spuštěním bude primární save na telefonu opraven pouze v těchto třech polích; celý původní soubor se nejprve zachová jako privátní on-device recovery kopie a po readbacku se ověří, že XP, rostliny i ostatní stav zůstaly stejné.

## Release hranice

- Zdrojová/exportní identita: `0.58.0-rc46`, Android version code `63`, save schema `37`.
- RC45 zůstává immutable důkazem fáze 120 a nesmí se přepsat.
- Immutable RC46 vzniklo až po úplné validaci a release automatizaci; 120sekundový technický device audit prošel.
- Publikování zůstává na přání uživatele mimo rozsah.
- Technický fyzický PASS a subjektivní lidské potvrzení se vykazují odděleně.

## Fyzický výsledek RC46

Oba původní vodorovné reprodukční tahy prošly: swipe přes cenu Pažitky i Bazalky přepnul obrazovku a zachoval 73 mincí, 2 semínka Bazalky a 0 semínek Pažitky. Následný svislý scroll přes katalog ale odhalil stejnou release kolizi na kartě vybavení: po odloženém save klesly mince 73→41 a `grow_lamp` se změnila 1→2. RC46 proto není finální oprava. Hráčský stav byl po privátní on-device záloze opraven pouze v těchto dvou polích; legitimní živý zisk XP 205→206 zůstal zachován.

`PHASE121_SWIPE_TRANSACTION_GUARD=PARTIAL_HORIZONTAL_PASSED_VERTICAL_SCROLL_FAILED_SUPERSEDED_BY_PHASE122`
