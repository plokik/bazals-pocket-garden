# Dílna v2 – konvička a rámeček

Na základě připomínky uživatele zůstává prostřední tlačítko stejné velikosti (204×56). Oprava se týká jeho rámečku, nikoli textu pod ním.

- Konvička se v dílně nevykresluje. Nový renderer respektuje stejné skryté historické sloty jako původní pokoj. Původní nákup, sloty a ostatní dekorace se nepřepisují.
- Malovaná textura rámečku má rozměr 128×128. Obecný řez 19 px protínal zaoblené rohy, takže se při natažení objevovaly zlomy v obrysu. Jen u tohoto tlačítka jsou řezy 26 px, filtrované lineárně, a pozice zaokrouhlená na pixely. Stejný řez platí pro normal/hover/pressed/disabled; vzhled ostatních tlačítek se nemění.
- Původní malba, kocour, recepty a uložený postup se nemění. Text pod tlačítkem zůstává zachovaný.

Ověření: `WORKSHOP_CHECKS=41 FAILURES=0`, nativní Godot screenshoty při 432×960 a 360×800, `WORKSHOP_NATIVE_CAPTURE=PASSED VIEWPORTS=2 RECIPE_STATES=2`, bez parser/script chyb; `git diff --check` bez nálezů. Náhledy používají oddělenou demonstrační uloženou sestavu. Logy jsou v `.godot/workshop-polish-20261011/`.

`ramecek-pred-po.png`: vlevo původní rámeček, vpravo opravený. `detail-opravy.png` je výřez nového nativního snímku; `dilna-432.png` a `dilna-360.png` jsou celé obrazovky. Schválené reference nebyly upraveny. Kompletní původní testování návrhu v1 zůstává zaznamenané v jeho REVIEW.md; tento průchod provedl cílené kontroly, nikoli další kompletní vizuální/regresní sadu. Android/emulátor ani GitHub nebyly aktualizovány.
