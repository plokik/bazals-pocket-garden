# Výrobky v dílně a první dodávka pro čajovnu

Návrh, ilustrace, ceny a odměna schváleny uživatelem „Souhlasím“ 17. 10. 2026.

V dílně otevři **Připravit směs → Výrobky a čajovna**. Tlačítko **Péče** vrátí
původní čtyři recepty. Ve skladu jsou hotové výrobky uvedeny v samostatné kartě
s přímým odkazem do dílny. Při otevření levandule nebo meduňky ze skladu vede
„Využít v dílně“ rovnou na odpovídající nový výrobek; staré odkazy máty a rozmarýnu
zachovávají původní recepty.

| Výrobek | Suché nezabalené byliny | Cena přípravy | Pevná prodejní cena |
| --- | --- | ---: | ---: |
| Levandulový sáček | 2 g levandule | 2 mince | 24 mincí |
| Mátovo-meduňkový čaj | 1 g máty + 1 g meduňky | 3 mince | 20 mincí |
| Dárkový balíček bylin | 1 g levandule + 1 g rozmarýnu + 1 g máty | 4 mince | 32 mincí |

Recept je dostupný po odemčení potřebných druhů v botanickém obchodě.
Čajovna U zeleného lístku se otevře na úrovni 5, po zpřístupnění levandule.
Zakázka nemá časový limit a požaduje **jeden kus od každého výrobku**.
Odměna **80 mincí + 2 semínka meduňky** se uděluje právě jednou.
Hotové výrobky z dřívějška se počítají a přebytečné kusy zůstávají hráči.
Pokud se dvě semínka do zásoby nevejdou, předání počká a nic se neodečte.

Výrobky mají vlastní počty, nezabírají květináče ani sloty pro sklizené šarže.
Jeden druh může mít nejvýše 9999 kusů. Prodej z obrazovky výrobku prodá jeden kus
za uvedenou pevnou cenu; nepřičítá druhý bonus za prodej sklizně. Výroba ani prodej
nevytvářejí dodatečná XP, sklizně či pokrok původních objednávek rostlin.

## Ukládání a bezpečnost transakcí

Save schema **44** přidává jediný nový objekt `workshop_products`:

```json
{
  "products": {"lavender":0,"tea":0,"gift":0},
  "teahouse":"available"
}
```

Stavy zakázky: `available`, `active`, `completed`. Schema 43 a starší začíná
s prázdnými výrobky a novou nabídkou; podstrčené novější klíče ignoruje. Původní
data migruje GameSession dosavadním způsobem. Hranice kola štěstí zůstává 43.
Počet kusů přijímá jen konečná celá nezáporná čísla v omezeném rozsahu a tři
kanonická ID. Neplatný stav aktuální zakázky se bezpečně uzavře jako `completed`.

Výroba, prodej, přijetí a předání se uloží jednou transakcí před potvrzující
animací. Při neúspěchu se vrátí přesné dotčené šarže, mince, počty výrobků,
semínka, objevení druhu i související pity počitadlo. Read-only save a reentrantní
callbacky změnu nepovolí. Zavření animace neruší již uloženou výrobu.

## Kód a grafika

- `scripts/workshop_products.gd`: katalog, zásoby, stav zakázky a transakce.
- `scripts/ui/workshop_products_panel.gd`: schválené obrazovky a zpětná vazba.
- `scripts/ui/workshop_stock_panel.gd`: skutečné skladové počty.
- `assets/ui/workshop/products/`: schválené originály PNG a prompty.
- Import ilustrací má limit 512 px; originální PNG zůstávají nezměněné.
- Malované nine-patch rámečky používají lineární filtr, aby nevznikaly švy.
- `tests/workshop_products_test.gd`: migrace, šarže, chyby zápisu, obnovení a UI.

Nativní snímky a výsledek ověření jsou v
`docs/visual-proposals/20261017-teahouse-integration-v1/`.
