extends RefCounted
## Isolated review model. No GameSession, user save files, clock or RNG.
## Costs and rewards below are proposals, not an economy migration.
const PRODUCTS := {
	"lavender": {"name":"Levandulový sáček", "short":"SÁČEK", "file":"lavender-sachet-v1.png", "description":"Voňavý lněný sáček s květy z tvé zahrady.", "ingredients":{"lavender":2}, "cost":2, "sale":24, "action":"PŘIPRAVIT SÁČEK"},
	"tea": {"name":"Mátovo-meduňkový čaj", "short":"ČAJ", "file":"mint-lemonbalm-tea-v1.png", "description":"Dvě voňavé bylinky v jedné čajové směsi.", "ingredients":{"mint":1,"lemonbalm":1}, "cost":3, "sale":20, "action":"NAMÍCHAT ČAJ"},
	"gift": {"name":"Dárkový balíček bylin", "short":"BALÍČEK", "file":"herbal-gift-v1.png", "description":"Malý košík s pečlivě zabalenou úrodou.", "ingredients":{"lavender":1,"rosemary":1,"mint":1}, "cost":4, "sale":32, "action":"ZABALIT DÁREK"}
}
const HERBS := {"lavender":"Levandule", "mint":"Máta", "lemonbalm":"Meduňka", "rosemary":"Rozmarýn"}
const ORDER := ["lavender","tea","gift"]
const REWARD_COINS := 80
const REWARD_SEEDS := 2
var herbs := {"lavender":6,"mint":6,"lemonbalm":6,"rosemary":4}
var products := {"lavender":0,"tea":0,"gift":0}
var coins := 40
var lemonbalm_seeds := 0
var quest := "available"
var busy := false

func can_craft(id: String) -> bool:
	if busy or not PRODUCTS.has(id): return false
	var recipe: Dictionary = PRODUCTS[id]
	if coins < recipe.cost: return false
	for herb in recipe.ingredients:
		if herbs.get(herb,0) < recipe.ingredients[herb]: return false
	return true

func craft(id: String, persist := Callable()) -> bool:
	if not can_craft(id): return false
	var snapshot := to_dict()
	var recipe: Dictionary = PRODUCTS[id]
	for herb in recipe.ingredients: herbs[herb] -= recipe.ingredients[herb]
	coins -= recipe.cost
	products[id] += 1
	if persist.is_valid() and not persist.call(to_dict()):
		restore(snapshot)
		return false
	return true

func sell(id: String, persist := Callable()) -> bool:
	if busy or not PRODUCTS.has(id) or products[id] <= 0: return false
	var snapshot := to_dict()
	products[id] -= 1
	coins += PRODUCTS[id].sale
	if persist.is_valid() and not persist.call(to_dict()):
		restore(snapshot)
		return false
	return true

func accept() -> bool:
	if quest != "available": return false
	quest = "active"
	return true

func ready_count() -> int:
	var result := 0
	for id in ORDER:
		if products[id] > 0: result += 1
	return result

func deliver(persist := Callable()) -> bool:
	if busy or quest != "active" or ready_count() != 3: return false
	var snapshot := to_dict()
	for id in ORDER: products[id] -= 1
	coins += REWARD_COINS
	lemonbalm_seeds += REWARD_SEEDS
	quest = "completed"
	if persist.is_valid() and not persist.call(to_dict()):
		restore(snapshot)
		return false
	return true

func to_dict() -> Dictionary:
	return {"herbs":herbs.duplicate(),"products":products.duplicate(),"coins":coins,"lemonbalm_seeds":lemonbalm_seeds,"quest":quest}

func restore(data: Dictionary) -> void:
	herbs = data.herbs.duplicate()
	products = data.products.duplicate()
	coins = data.coins
	lemonbalm_seeds = data.lemonbalm_seeds
	quest = data.quest
