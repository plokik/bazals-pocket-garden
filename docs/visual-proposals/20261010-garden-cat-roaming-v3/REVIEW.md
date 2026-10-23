# Kocour: další trasy a spací zzZZ

Schválená velikost, malované podklady, pelíšek a misky zůstávají zachované. V pokoji se kocour prochází přes celou šířku podlahy a odpočívá střídavě na koberci a v pelíšku. K původním trasám ve stojanu a skleníku přibyly pracovní deska skladu, pult obchodu, laboratorní deska měření a parapet detailu rostliny.

Kocour se objevuje občas, sám nepřepíná hráčovu obrazovku. Ve skladu a měření se pohybuje pouze v právě viditelné malované scéně: při odrolování této plochy zmizí a jeho čas se zastaví. Přes dialogy ani ovládací panely nechodí. Dotyky nezachytává.

Při skutečném spánku stoupají čtyři písmena z/z/Z/Z, zvětšují se a plynule mizí. Po probuzení zmizí hned. Nad kobercem se odklánějí směrem doleva, nad pelíškem doprava, aby se vyhnula značkám pro květináče. Omezené animace používají statické značky.

## Ověření

- Konečná funkční sada: 6992 kontrol, včetně 42 kontrol kocoura. Žádné chyby skriptů.
- Čtrnáct nových snímků: všech sedm míst v rozlišeních 432 × 960 a 360 × 800. Animovaný GIF obsahuje 84 skutečných herních snímků.
- Běžný vizuální běh proti historickým referencím: 27/34 bran prošlo; sedm bran pokoje překročilo toleranci přidáním většího kocoura a jeho zázemí. Tento nezměněný výsledek je v `.godot/cat-companion-20261010/routes-validation/report.md`.
- Doplňkové porovnání původní grafiky s vypnutou vrstvou kocoura pouze v izolovaném snímkování: 34/34 bran prošlo. Produkční kocour zůstává zapnutý. Doklad v `.godot/cat-companion-20261010/background-preservation/report.md`.
- Schválené reference, prahy, masky a původní produkční PNG se neměnily. Nový funkční stav nevyžaduje změnu save schématu.

Aktualizace Android emulátoru používá instalaci přes stávající aplikaci (`install -r`), zálohu obou souborů s postupem a kontrolu jejich shodných hashů bezprostředně po instalaci. Fyzický telefon ani GitHub nejsou součástí tohoto kroku.

## Náhledy

- `sleep-zzz.gif`: živá animace spánku.
- `new-routes.png`: čtyři přidané malované trasy.
- `cat-*-432.png`, `cat-*-360.png`: snímky všech míst.
