# Žebříček pěstitelů – ovladatelný návrh

Samostatný návrh ke schválení. Zobrazuje **160 smyšlených hráčů**, nikoli skutečné online výsledky. Nenapojuje GameSession, SaveManager ani síť a neuděluje herní XP. Produkční exporty ho vylučují pravidlem `prototypes/**`.

Spuštění z kořene úplného projektu v Godotu 4.7:

```powershell
& 'R:/_projekty/Godot_v4.7-stable_win64.exe' --path . 'res://prototypes/grower-leaderboard-review/review.tscn'
```

Záložky a návrat ovládá myš/dotyk. Jen pro posouzení návrhu: **P** přidá ukázkových 45 XP, **O** přepne ukázku bez připojení, **R** vrátí původní data, **M** vypne efekt postupu a **Esc** zavře/otevře žebříček. Žádné z těchto tlačítek nepřidává XP do skutečné hry.

Model lze ověřit příkazem:

```powershell
& 'R:/_projekty/Godot_v4.7-stable_win64.exe' --headless --path . --script 'res://prototypes/grower-leaderboard-review/run_model_tests.gd'
```

Nepoužívat samostatný `--check-only`. `capture_review.gd` je automatizovaný scénář vstupů pro úplný záznamový mirror s rozlišením 1080×2400 a izolovanou cestou APPDATA obsahující `grower-leaderboard-review-20261024`; soubory ukládá do `../capture` vzhledem ke kořeni mirroru. Záznam nezachycuje Android.

Pravidla návrhu:

- Hlavní pěstitelská úroveň vychází z kumulativních XP: `1 + floor(XP / 100)`. Shodnou úroveň rozlišují XP; zcela shodné XP sdílejí příčku.
- Výchozí pohled „Kolem mě“ ukazuje dva hráče před a dva za hráčem. Na krajích seznamu se počet přirozeně zkracuje.
- „Nejlepších 100“ ukazuje prvních 100 profilů; vlastní profil je stále vidět nahoře, i když do stovky nepatří. Při shodě na hranici může být skupina rozdělená limitem 100 profilů; jejich skutečné sdílené pořadí zůstává správné.
- Cíl počítá XP potřebné k překonání nejbližší vyšší skupiny, včetně jednoho XP navíc. Jméno při shodě pouze reprezentuje tuto skupinu.
- Posun oznámí krátké zvýraznění pořadí. Nepřidává se bonus, měna ani časově omezená soutěž.
- Stav bez připojení ponechá přehled a upozorní na jeho možnou neaktuálnost; v návrhu je také pouze simulovaný.

Náhledy a další postup: [dokumentace návrhu](../../docs/visual-proposals/20261024-grower-leaderboard-v1/README.md).
