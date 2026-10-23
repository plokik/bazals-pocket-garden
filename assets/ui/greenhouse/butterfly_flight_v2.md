# Motýl — list 4 × 3

Rozměr 1448 × 1086 (4:3), 12 stejně velkých buněk 362 × 362, skutečná plocha původní malby 320 × 320. Formát odpovídá listům `cat_poses_v1.png` a `cat_actions_v1.png`. Jednotlivé pózy mají průhledný okraj a stejné umístění těla; obrázek motýla není natažený do poměru 4:3.

Zdroj: původní `butterfly_amber_v1.png`, beze změny barev a kresby. List vznikl předvykreslením 12 fází v Godotu, bez nové AI generace. Horní a spodní části křídel mají rozdílné prohnutí a mírně posunutý průběh pohybu. Vykreslení odstraňuje slabý šum v průhledném okraji a používá čtyři podpixelové vzorky.

Opakování generace: z kořene projektu spustit Godot s `--path . --script res://tools/art/bake_greenhouse_butterflies.gd`. Potřebuje skutečný renderer. Nástroj čte původní obrázek a uloží tento list; neotevírá hlavní scénu ani herní profil. Zdroj pohybu je v `tools/art/greenhouse_butterfly_authoring.gdshader` a `scripts/ui/greenhouse_butterfly_paint.gdshaderinc`.

Ve hře se sousední snímky průběžně prolínají, včetně spojení posledního s prvním. Aura používá stejný list, snímky i jejich poměr prolnutí. Zůstává zachovaná původní logická velikost malby 58/54/56 px, ovládání, pauza a uložený postup.
