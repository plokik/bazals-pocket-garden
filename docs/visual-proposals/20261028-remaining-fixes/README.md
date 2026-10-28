# Zbývající opravy – obnovená nová verze

**Aktuální stav: nová verze z přehledového obrázku obnovena na výslovné přání uživatele.** Po vysvětlení záměny uživatel požádal znovu o tuto podobu úvodu, skleníku, dílny, mapy a péče. Všech 1 687 runtime souborů je přesně shodných s původním novým manifestem `e23230193a61d7424cab9556380476e789d3a7810c1356875ae4c9a687ab35f7`. Krátkodobý návrat ke starým obrazovkám zůstává doložen jako historie v [restoration.json](restoration.json). [Doklad nové obnovy](new-version-restored.json).

Původní návrh navazoval na audit z 27. 10. 2026. Schválené assety a obrazové reference zůstaly beze změny; neproběhl push, release ani instalace do telefonu.

## Co se změnilo

1. **Úvodní filmové karty:** celé všechny tři texty, mezera pod jménem Profesora Bazala a před tlačítky. Na nízkém displeji se výška řídí obsahem; celá postava zůstává pod kartou a v bezpečné ploše. Další a Převzít zahradu používají původní herní kroky. Běžná nápověda se po úvodu obnoví.
2. **Skleník:** kompaktní záhlaví uvolní místo, svislý výřez původní malby zachová proporce a posune společně rostliny, půdu, obrysy i dotykové cíle. Všechny čtyři záhony jsou dostupné. Kompletní stav a zakázka se vejdou do spodní karty. Běžná 432 × 960 kamera zůstává zachovaná.
3. **Dílna a kolo:** skutečná výška přípravy směsi alespoň 52 px s čitelným písmem. Odpočet má vlastní místo pod štítkem zakázky a na malém displeji 48px cíl. Po zavření jiného dialogu lze na kolo znovu klepnout bez čekání na jeho čtvrtsekundovou aktualizaci.
4. **Mapa úrovní:** na malém displeji je samostatně posuvný přiblížený výřez původní malované cesty. Terče úrovní mají alespoň 48 px, bez překryvu; aktuální úroveň je po otevření ve výřezu. Přesun prstem nespustí úroveň. Návrat zachová pozici mapy i postup. Původní velká mapa se zachovává.
5. **Proudění:** text a procenta se vejdou dovnitř malovaného tlačítka. Úzká varianta má tři řádky a vyšší řadu ovladačů; široká obnoví původní dva řádky a výšku. Léčba a větrání mají původní účinky, cenu, XP i uložený stav.

## Způsob ověření

- Původní náhledy jsou neměnné kopie předchozího auditu s kontrolními součty; chybějící původní 360 × 800 a druhá/třetí úvodní stránka nejsou vymyšleny jako „před“.
- Čerstvé záběry skutečného desktopového rendereru Godot: 360 × 640, 360 × 800, 432 × 960 a 600 × 900 s bezpečnými okraji 12/24/14/32 px. V každé velikosti všechny tři filmové karty, čtyři výběry záhonů, růst a sklizeň, péče, dílna a mapa.
- Funkční kontroly používají skutečný směrovaný vstup: Další/Převzít zahradu, všechny čtyři záhony, posun mapy i klepnutí na všech deset úrovní, přípravu směsi, kolo a Zpět. Ověřují text i vnitřní odsazení, bezpečné plochy a zachování dat.
- Testovací APPDATA a herní soubory jsou oddělené od hráčova profilu. Tento průchod neobsahuje nativní Android či fyzický telefon; ADB aktuálně nehlásil žádné připojené zařízení.
- Statické snímky mají pozastavenou simulaci a dokončený přechod obrazovek. Nejsou důkazem souvislého měření FPS. Původní animace, textury a pravidla jsou zachovány.

## Výsledky a obrazové páry

| Položka | Před / po |
|---|---|
| Úvodní filmová karta | [Celý text a Profesor](final-review-01-tutorial.png) |
| Skleník | [Všechny čtyři záhony](final-review-02-greenhouse_empty.png) |
| Proudění | [Text uvnitř rámečku](final-review-03-plant_detail_actions.png) |
| Dílna | [Příprava směsi a odpočet](final-review-04-workshop.png), [detail tlačítka](final-review-detail-workbench.png), [detail kola](final-review-detail-wheel.png) |
| Mapa | [Větší body na posuvné cestě](final-review-05-teahouse_map.png) |

- **9 942 / 9 942 funkčních kontrol prošlo**, testovací proces skončil 0.
- **48 / 48 obrazových stavů otevřeno a uloženo**, renderovací procesy skončily 0; žádná potvrzená přetečení ani parser/script chyby. Původní úplný průchod byl zachován, čtyři snímky péče byly po doladění odsazení znovu zachyceny. [Matice a původ snímků](coverage.json), [identita zdroje](runtime-identity.json), [doklad výsledků](validation.json).
- V běžném skleníku 432 × 960 je RGB rozdíl všech tří kontrolovaných stavů proti předchozím snímkům **0**.
- **33 / 34 schválených obrazových bran prošlo.** Jediná neprošlá je dlouhodobě evidovaná `phase162-cosmetic-showroom-runtime-approved`: reference obsahuje starý pokoj, současná hra dílnu (MAE 14,091654; RMSE 35,357709; změněno 26,9796 %). Celková obrazová validace tedy zůstává **FAILED**, přestože nové herní opravy funkčně prošly. Referenci ani limity neobcházíme.

Kontaktní přehledy: [360 × 640](final-contact-360x640.jpg), [360 × 800](final-contact-360x800.jpg), [432 × 960](final-contact-432x960.jpg), [600 × 900](final-contact-600x900.jpg).

### Showroom – připravené sjednocení reference

K odstranění zastaralého porovnání je připravený dnešní [přesný PNG kandidát](showroom-runtime-reference-candidate.png) a [porovnání staré reference s aktuální dílnou](showroom-reference-proposal.jpg). [Návrh aktualizace](showroom-reference-proposal.json) obsahuje kontrolní součty a zachovává stejné limity i masky. Aktivní reference dosud přepsána nebyla; kandidát čeká na osobní vizuální schválení.

Projektový [validační postup](../../../.agents/skills/how-to-grow-validation/SKILL.md) k referencím výslovně ukládá: „Treat every manifest `reference` as read-only“ a „Never derive a new approved reference silently from current output.“ Proto je nový snímek nabídnut ke schválení odděleně a aktuální neprošlý výsledek je zachovaný.

Úplné lokální pracovní důkazy jsou v `.godot/remaining-fixes-20261028/`; kanonický běh v `final-validation/`. U prvního průběžného funkčního běhu neprošla stará přesná textová podmínka „LÉČBA PŮSOBÍ“, protože text nově může být zalomený. Podmínka nyní normalizuje pouze zalomení; veškeré kontroly tlaku nemoci, proudění, XP, zakázané opakované akce i skutečného uložení zůstaly a rozšířily se o čtyři velikosti. Finální celá sada výše prošla po poslední úpravě zdroje.

## Opětovná obnova nové verze

Na výslovnou žádost uživatele byla nová verze z přehledového obrázku obnovena z přesných záloh. Čerstvě znovu prošlo **9 942 funkčních kontrol** a **48 snímků** ve čtyřech velikostech bez hlášeného přetečení. Celý runtime má shodný kontrolní součet s původní novou verzí. Obrazová validace má stejnou známou neshodu historické reference showroomu: **33 / 34 bran**, celkově FAILED. Aktivní reference ani hráčova data se neměnily. Bez push, release a aktualizace emulátoru. [Doklad](new-version-restored.json).
