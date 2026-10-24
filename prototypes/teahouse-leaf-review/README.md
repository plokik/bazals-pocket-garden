# Kouzelný lístek – izolovaný návrh

Stav: **čeká na osobní schválení vzhledu a pravidla**. Produkční hra na lístek ani novou ozdobu neodkazuje; Android export vylučuje celý `prototypes/**`.

- Šest nebo více stejných bylinek v jednom platném řetězci získá jeden lístek, pokud recept ještě pokračuje.
- Lze si nechat nejvýše jeden. Po klepnutí na něj hráč vybere některou z nedokončených bylinek v receptu.
- Lístek doplní až tři chybějící bylinky bez spotřeby tahu. Nemění desku ani její náhodnou posloupnost.
- Zrušení výběru lístek nespotřebuje. Nový pokus jej vynuluje; dokončený recept už žádný další nezískává.
- Klidný pohyb, myš, dotyk a klávesnice jsou podporované. Výsledek návrhu lze znovu rozehrát, nic se nepřidává do skutečného inventáře.

`review.tscn` je samostatně hratelná úroveň10 s původní přirozenou deskou. `demo-path.json` dokumentuje legální cestu, kterou prochází video přes skutečné události vstupu.

`chapter_ornament.gd` je pouze návrh umístění čajového medailonu po dokončení kapitoly. Zatím nemá produkční vlastnictví, přidělování ani zápis do uložené hry. V záznamu je umístěn do skutečné dílny v odděleném testovacím profilu.

Oba PNG v `art/` vznikly pomocí vestavěného generátoru obrázků 24.10.2026. Zdrojové obrázky mají skutečnou průhlednost; zachováváme jejich poměr stran. Malované listy a medailon jsou návrh ke schválení.

Ověření modelu: 642 kontrol. Ověření ovládání: 56 kontrol. Podrobné aktuální výsledky a video jsou v `docs/visual-proposals/20261024-teahouse-next-v1/`.
