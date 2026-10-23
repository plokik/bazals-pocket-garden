# Druhé přepracování usazení rostlin v dílně

Návrh ke schválení, 11. 10. 2026. Předchozí v4 uživatel odmítl.

## Změny

- Celé obrázky se již nezmenšují podle nejvyššího listu: nádoby mají společné fyzické rozměry odpovídající policím. Na 432px displeji jde o podmisku přibližně 32px širokou, oproti různým menším nádobám v předchozím návrhu.
- Existující geometrie souvislého stonku přizpůsobuje spodní spoj a olistění skutečnému otvoru police. Koruny mají jednotné měřítko v obou osách; celé květy se neořezávají. Historická geometrie původního pokoje je nezměněná.
- Nové kontaktní stíny, mírně teplejší světlo vlevo a tlumenější světlo v pravé skříni. Přední hrana police se vykresluje z původního pozadí před podmiskami.
- Zachovány původní PNG, pozadí, vlastnictví, všech 12 slotů, přesouvání a samostatné dotykové oblasti 56 × 56. Pelíšek, misky a kocour jsou nezměněné.

## Doklady

- workshop-432.png a workshop-360.png: skutečný nativní OpenGL render. Ručně posouzeny oba rozměry.
- swapped-432.png a swapped-360.png: skutečné prohození orchideje z levé horní do pravé spodní police pomocí herní akce; následně vráceno. Jde o syntetický testovací stav, v prohozených snímcích je přechodná animace mincí ze založení testovacího stavu, nikoli změna odměny za přesun.
- shelves-detail.png je výřez nativního náhledu. before-after.png: vlevo odmítnutý v4, vpravo nový v5. Žádné doplňování grafiky do snímku.
- Kompletní funkční sada: .godot/shelf-fit-v5-20261011/full-tests.log, MVP_TESTS_PASSED=7414, native exit 0; bez GDScript parse/script chyb. Očekávaná hlášení negativních testů a existující headless diagnostika nejsou vizuální akceptace.
- Responsive matice: .godot/responsive/20261011-092206Z/responsive-layout.json, všech 15 případů, RESPONSIVE_LAYOUT_SMOKE=PASSED.
- Nativní zachycení: .godot/shelf-fit-v5-20261011/swapped-capture.log, WORKSHOP_NATIVE_CAPTURE=PASSED, native exit 0.
- comparison.json zaznamenává kontrolu rozdílů proti odmítnutému v4 mimo obě skříně: 0 pixelů nad tolerancí 12, největší odchylka kanálu 7 (drobné rozdíly nativního vzorkování mezi snímky). Schválené historické reference a prahy jsou beze změny; celá golden sada nebyla znovu spouštěna.
- Izolované APPDATA pro každou úlohu; osobní save, telefon, emulátor, GitHub a release nezměněny. git diff --check prošel.
