# Prioritizovaný backlog po RC59

Datum návrhu: **2026-08-30**

Stav: `PLANNED_AFTER_RC59_MIXED_EXISTING_FOUNDATIONS`

Tento backlog není součástí RC59. Neopravňuje přidat nový obsah před uzavřením
release, AAB, fyzického auditu a dokumentace. Pořadí vyjadřuje doporučenou
hodnotu a riziko, nikoli slíbený termín.

Některé technické základy už existují: hra má deset dosažitelných podmínek
odznaků a RC59 zavádí sdílenou malovanou kostru šesti modalových rodin. Backlog
popisuje zbývající hráčskou prezentaci a další bezpečné oddělování, ne tvrzení,
že tyto základy chybí.

## 1. Krátký první průchod: zasazení → první zakázka

**Cíl:** nový hráč během krátké relace pochopí zasazení, péči, sklizeň, sušení,
balení a odevzdání první zakázky bez čtení dlouhého manuálu.

**Podmínky přijetí:** měřitelný scénář od čistého save; žádné přeskočení
existujících systémů; možnost nápovědu odmítnout; test na malém telefonu.

## 2. Přístupnost a čitelnost

**Cíl:** sjednotit minimální touch targety, kontrast, velikost textu, snížený
pohyb a stavovou komunikaci bez závislosti jen na barvě.

**Podmínky přijetí:** audit všech obrazovek, TalkBack/čtečka tam, kde je reálně
podporovaná, reduced-motion parity a nové vizuální brány. Výtvarný master se
nemění bez schválení.

## 3. Klidové hodiny a jemnější připomínky

**Cíl:** hráč si nastaví časové okno, intenzitu nebo typ péče, aniž by hra
vyžadovala exact alarm.

**Podmínky přijetí:** default respektující soukromí, jasné vypnutí, timezone a
DST testy, restart telefonu, aktualizovaná privacy/Data safety dokumentace.

## 4. Obrazovka O hře, podpora a právní informace

**Cíl:** jedno trvalé místo pro verzi, podporu, privacy policy, Godot/Poppins a
další third-party notices, botanický a meteorologický disclaimer.

**Podmínky přijetí:** skutečné kontakty, funkční veřejné URL, úplný licenční
soupis odpovídající AAB a žádný účet či telemetrie přidaná bokem.

Poznámka: minimální licenční a privacy dostupnost může být nutná již před
veřejným vydáním; backlog zde popisuje plnohodnotnou obrazovku, nikoli odklad
zákonné povinnosti.

## 5. Pohodlnější práce s deseti květináči

**Cíl:** rychlejší přepínání, rozpoznání stavu a hromadné ne-destruktivní kroky
bez automatického utrácení nebo změny ekonomiky.

**Podmínky přijetí:** zachování pořadí a save schema přes migraci, žádná ztráta
rostlin, undo/confirm tam, kde je krok destruktivní, mobilní test dlouhého save.

## 6. Anglická lokalizace

**Cíl:** oddělit texty od monolitických skriptů a dodat úplnou angličtinu bez
rozbití českého layoutu.

**Podmínky přijetí:** locale resources, fallback, kontrola pluralizace,
screenshoty všech modalů, store listing a privacy policy pro podporované
jazyky. Nepřekládat botanická tvrzení bez odborné kontroly.

## 7. Vitrína deseti odznaků

**Cíl:** smysluplně vystavit existující/budoucí úspěchy v Pokoji.

**Podmínky přijetí:** navázat na již existujících deset dosažitelných podmínek,
navrhnout skutečnou vitrínu a případný save model vystavení; vitrína nesmí
zobrazovat prázdný placeholder jako hotovou funkci; vizuální návrh schválit
před implementací.

## 8. První Legendary rostlina

**Cíl:** pozdní dlouhodobá odměna, nikoli paywall nebo premium měna.

**Podmínky přijetí:** rarity a ekonomika jsou předem zdokumentované; rostlina
má unikátní, ale neklamavé chování; celý lifecycle, herbář, zakázky, save a
vizuální assety mají testy. Nezačínat, dokud běžná progrese nemá data z closed
testu.

## 9. Skutečný kosmetický mazlíček

**Cíl:** volitelný vizuální společník v Pokoji bez umírání, péče jako povinnosti,
reklamy nebo premium měny.

**Podmínky přijetí:** nejprve schválený vizuální koncept, bezpečný spot/pelíšek,
animace respektující reduced motion, žádné překrytí interakcí a jednoznačné
označení kosmetické funkce. Současné paw/room dekorace nejsou důkazem hotového
mazlíčka.

## Technický backlog paralelně s obsahem

Provádět po malých testovatelných krocích, ne jako jeden rozsáhlý refaktor:

1. vyčlenit `SaveService` při zachování schema 41 a fixture testů;
2. stabilizovat `NotificationService` kolem existující Android bridge;
3. oddělit `OrderService` od UI;
4. vyčlenit `GreenhouseController`;
5. vyčlenit `RoomController`;
6. rozšířit RC59 sdílenou modalovou vrstvu na zbývající vhodné dialogy bez
   změny schválené geometrie;
7. doplnit přesný dependency/SBOM a asset provenance pipeline;
8. pokračovat v měřeném export pruning bez snížení schválené kvality.

Každý krok musí mít regresní, save, vizuální a podle dopadu Android bránu.
`main.gd` ani `game_session.gd` se nesmí rozdělit mechanicky bez charakterizačních
testů.
