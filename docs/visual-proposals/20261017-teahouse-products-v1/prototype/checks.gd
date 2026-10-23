extends SceneTree
const Demo := preload("res://docs/visual-proposals/20261017-teahouse-products-v1/prototype/demo_state.gd")
var checks := 0
var failures: Array[String] = []
func _init() -> void: call_deferred("run")
func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition: failures.append(message)
func run() -> void:
	for id in Demo.ORDER:
		var model := Demo.new()
		var before := model.to_dict()
		var recipe: Dictionary = Demo.PRODUCTS[id]
		check(model.craft(id),"craft "+id)
		check(model.coins == before.coins-recipe.cost,"coins "+id)
		check(model.products[id] == 1,"one product "+id)
		for herb in Demo.HERBS:
			check(model.herbs[herb] == before.herbs[herb]-recipe.ingredients.get(herb,0),"correct herb "+id+" "+herb)
		var restored := Demo.new()
		restored.restore(model.to_dict())
		check(restored.to_dict() == model.to_dict(),"state roundtrip "+id)
		before = model.to_dict()
		check(not model.craft(id,func(_data): return false),"failed save "+id)
		check(model.to_dict() == before,"rollback craft "+id)
		check(not model.sell(id,func(_data): return false),"failed sale save "+id)
		check(model.to_dict() == before,"rollback sale "+id)
		check(model.sell(id),"sale "+id)
		check(model.coins == before.coins+recipe.sale and model.products[id] == 0,"sale exact "+id)
		before = model.to_dict()
		check(not model.sell(id) and model.to_dict() == before,"no oversell "+id)
		for ingredient in recipe.ingredients:
			model = Demo.new()
			model.herbs[ingredient] = recipe.ingredients[ingredient]-1
			before = model.to_dict()
			check(not model.craft(id) and model.to_dict() == before,"missing herb "+id+" "+ingredient)
		model = Demo.new()
		model.coins = recipe.cost-1
		before = model.to_dict()
		check(not model.craft(id) and model.to_dict() == before,"missing coins "+id)
		model = Demo.new()
		model.busy = true
		before = model.to_dict()
		check(not model.craft(id) and model.to_dict() == before,"busy guard "+id)
	var order := Demo.new()
	var before := order.to_dict()
	check(not order.deliver() and order.to_dict() == before,"no unaccepted delivery")
	check(order.accept(),"accept")
	check(not order.accept(),"no duplicate accept")
	check(not order.deliver(),"incomplete delivery")
	for id in Demo.ORDER: check(order.craft(id),"order craft "+id)
	check(order.ready_count() == 3,"all ready")
	order.craft("tea")
	before = order.to_dict()
	check(not order.deliver(func(_data): return false),"failed reward save")
	check(order.to_dict() == before,"reward rollback")
	check(order.deliver(),"deliver")
	check(order.quest == "completed","completed")
	check(order.coins == before.coins+80 and order.lemonbalm_seeds == 2,"reward exact")
	check(order.products.tea == 1 and order.products.lavender == 0 and order.products.gift == 0,"consume exact one")
	before = order.to_dict()
	check(not order.deliver() and order.to_dict() == before,"no duplicate reward")
	check(not order.accept(),"no replay")
	check(not order.craft("invalid") and not order.sell("invalid"),"unknown ids")
	var independent := Demo.new()
	check(independent.coins == 40 and independent.products.tea == 0,"independent demo state")
	print("TEAHOUSE_DEMO_CHECKS=%d FAILURES=%d" % [checks,failures.size()])
	for failure in failures: push_error(failure)
	quit(0 if failures.is_empty() else 1)
