# Usazení dekorací na policích dílny

Náhled ke schválení, 11. 10. 2026. Stávající malované PNG a pozadí zachovány.

- Kontakt květináčů se zarovnává podle již změřeného středu podmisky a její spodní hrany, nikoli podle průhledného okraje PNG.
- Polohy odpovídají třem namalovaným policím; rostliny jsou uvnitř sloupků. Menší jednotné měřítko zachovává poměr stran a odstup listů.
- Dvanáct uložených slotů, vlastnictví dekorací, jejich přesouvání a samostatné dotykové oblasti 56 × 56 zůstávají zachovány.
- Doplněna chybějící klasifikace již schválených obrázků pelíšku a misek do rodiny room_collectible. První responsive běh se na tomto chybějícím záznamu zastavil; po doplnění prošel.

## Ověření

- Nativní Godot/OpenGL: workshop-360.png a workshop-432.png, oba náhledy ručně zkontrolovány. shelves-detail.png je výřez skutečného snímku 432 × 960.
- 397 cílených kontrol dílny a kocoura, 0 chyb: .godot/shelf-fit-20261011/tests-final.log, CAT_CORNER_CHECKS=397 FAILURES=0, native exit 0.
- Celá responsive matice 15 případů prošla: .godot/responsive/20261011-091613Z/responsive-layout.json, RESPONSIVE_LAYOUT_SMOKE=PASSED.
- git diff --check prošel. Schválené referenční PNG ani toleranční prahy nebyly změněny. Kompletní historické golden porovnání ani kompletní funkční sada nebyly pro tuto lokální úpravu opakovány.
- Testovací stav má všechny dekorace; nejde o osobní uložený postup. Testy i zachycení používají oddělené APPDATA. Telefon, emulátor, GitHub ani release nebyly aktualizovány.
