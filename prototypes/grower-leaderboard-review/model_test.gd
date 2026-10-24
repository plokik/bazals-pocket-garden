extends RefCounted

const Model := preload("res://prototypes/grower-leaderboard-review/leaderboard_model.gd")


static func _row(id: String, xp: int, name: String = "Pěstitel", portrait: int = 0) -> Dictionary:
	return {"id":id,"name":name,"xp":xp,"portrait":portrait}


static func _ids(rows: Array[Dictionary]) -> Array[String]:
	var result: Array[String] = []
	for row in rows: result.append(row.id)
	return result


static func run(check: Callable) -> void:
	var model := Model.new()
	check.call(model.entries.is_empty() and model.top().is_empty(),"Žebříček model: nový náhled nezačíná předstíranými online výsledky")
	check.call(model.player("missing").is_empty() and model.around("missing").is_empty() and model.next_target("missing").is_empty(),"Žebříček model: neznámý hráč nemá vymyšlené umístění ani cíl")
	var fixture: Array = [_row("top-b",1001,"Bára",1),_row("third",999,"Tomáš",2),_row("low",0,"Věra",31),_row("top-a",1001,"Áňa"),_row("fourth",901,"Dan",3)]
	check.call(model.load_entries(fixture),"Žebříček model: načte nezávislá ukázková data")
	check.call(_ids(model.entries) == ["top-a","top-b","third","fourth","low"],"Žebříček model: pořadí je XP sestupně a při shodě stabilní id")
	check.call(model.player("top-a").rank == 1 and model.player("top-b").rank == 1 and model.player("third").rank == 3 and model.player("fourth").rank == 4,"Žebříček model: shodné XP sdílí competition rank a další místo přeskočí")
	check.call(model.player("top-a").level == 11 and model.player("third").level == 10 and model.player("low").level == 1,"Žebříček model: hlavní úroveň pokračuje nad desítku a nula XP je úroveň1")
	check.call(model.next_target("top-a").is_empty() and model.next_target("top-b").is_empty(),"Žebříček model: oba sdílení lídři nemají falešného dalšího soupeře")
	var next: Dictionary = model.next_target("third")
	check.call(next == {"target_id":"top-a","name":"Áňa","target_rank":1,"next_higher_xp":1001,"gap_to_overtake":3,"next_rank":1},"Žebříček model: cíl vybere nejbližší vyšší skupinu a stabilní jméno")
	fixture.reverse()
	var stable := model.entries
	check.call(model.load_entries(fixture) and model.entries == stable,"Žebříček model: jiné vstupní pořadí nemění výsledky ani sdílené příčky")
	check.call(model.top(0).is_empty() and model.top(-10).is_empty() and model.top(1).size() == 1 and model.top(999).size() == 5,"Žebříček model: limit se bezpečně omezí bez prázdných přídavných řádků")
	check.call(_ids(model.around("top-a")) == ["top-a","top-b","third"] and _ids(model.around("low")) == ["third","fourth","low"],"Žebříček model: okolí respektuje začátek i konec pořadí")
	check.call(_ids(model.around("third",0,0)) == ["third"] and _ids(model.around("third",-4,-8)) == ["third"],"Žebříček model: nulové a záporné okolí vrátí jen hráče")
	check.call(model.around("third",0x7fffffffffffffff,0x7fffffffffffffff).size() == 5,"Žebříček model: extrémní rozsah okolí nepřeteče")

	var wide: Array = []
	for index in range(150): wide.append(_row("p%03d" % index,(150-index)*10,"Pěstitel %d" % index,index%4))
	check.call(model.load_entries(wide) and model.top().size() == 100,"Žebříček model: výchozí vrchol obsahuje nejvýše100 záznamů")
	check.call(not _ids(model.top()).has("p120") and model.player("p120").rank == 121,"Žebříček model: hráč mimo prvních100 si ponechá skutečnou příčku")
	check.call(_ids(model.around("p120")) == ["p118","p119","p120","p121","p122"],"Žebříček model: samostatné okolí najde hráče i za první stovkou")
	check.call(_ids(model.around("p000")) == ["p000","p001","p002"] and _ids(model.around("p149")) == ["p147","p148","p149"],"Žebříček model: široký žebříček nezdvojuje okrajové řádky")
	var wide_target := model.next_target("p120")
	check.call(wide_target.target_id == "p119" and wide_target.next_higher_xp == 310 and wide_target.gap_to_overtake == 11 and wide_target.next_rank == 120,"Žebříček model: motivující cíl je nejbližší soupeř, nikoli vzdálený lídr")

	var boundary := Model.new()
	check.call(boundary.load_entries([_row("a",500),_row("b",499)]),"Žebříček model: načte soupeře vzdálené1XP")
	var boundary_target := boundary.next_target("b")
	check.call(boundary_target.gap_to_overtake == 2 and boundary_target.next_rank == 1,"Žebříček model: vyžaduje o1XP více než pouhé dorovnání soupeře")
	check.call(boundary.load_entries([_row("a",500),_row("b",500)]) and boundary.player("b").rank == 1 and boundary.next_target("b").is_empty(),"Žebříček model: pouhé dorovnání opravdu vytvoří sdílenou příčku")
	check.call(boundary.load_entries([_row("a",500),_row("b",501)]) and boundary.player("b").rank == 1 and boundary.player("a").rank == 2,"Žebříček model: teprve další1XP soupeře jednoznačně předstihne")
	check.call(boundary.load_entries([_row("a",100),_row("b",99),_row("c",98)]),"Žebříček model: načte těsné sousední skupiny")
	var jump := boundary.next_target("c")
	check.call(jump.target_id == "b" and jump.target_rank == 2 and jump.gap_to_overtake == 2 and jump.next_rank == 1,"Žebříček model: předpokládaná příčka správně zahrne současné dorovnání vyššího lídra")
	check.call(boundary.load_entries([_row("a",100),_row("b",99),_row("c",100)]) and boundary.player("c").rank == jump.next_rank,"Žebříček model: promítnutá příčka souhlasí s opětovným skutečným seřazením")
	check.call(boundary.load_entries([_row("z",30),_row("a",30),_row("m",30)]) and _ids(boundary.entries) == ["a","m","z"] and boundary.player("z").rank == 1 and boundary.next_target("z").is_empty(),"Žebříček model: všichni se stejnými XP jsou sdílení lídři")
	for value in [0,99,100,999,1000,Model.MAX_XP]:
		check.call(boundary.load_entries([_row("limit",value)]) and boundary.player("limit").level == 1+floori(float(value)/100.0),"Žebříček model: přesná úroveň na hranici XP %d" % value)

	var names := Model.new()
	var name_cases := {"   Áňa   Nováková  ":"Áňa Nováková","Eva\nKřížová\t":"Eva Křížová","O’Brian-Čech":"O’Brian-Čech","abcdefghijklmnopqrST":"abcdefghijklmnopqr","\u202eMila\u2066":"Mila"}
	for raw_name in name_cases:
		check.call(names.load_entries([_row("safe",1,raw_name)]) and names.player("safe").name == name_cases[raw_name],"Žebříček model: bezpečné zobrazované jméno %s" % JSON.stringify(raw_name))
	check.call(names.load_entries([_row("markup",1,"<b>[color=red]Jana🌱[/color]</b>")]) and not RegEx.create_from_string("[<>\\[\\]\\r\\n\\t]").search(names.player("markup").name) and names.player("markup").name.length() <= 18,"Žebříček model: zobrazené jméno nemá značky, řídicí znaky ani nepřiměřenou délku")
	check.call(names.load_entries([_row("marks",1,"A\u0301ňa")]) and names.player("marks").name == "A\u0301ňa","Žebříček model: zachová běžná kombinovaná diakritická znaménka")

	# Invalid rows follow a valid new row, proving there is no partial replacement.
	var saved := model.entries
	var malformed: Array = [null,true,42,"row",[],{},
		{"id":"bad","name":"Jana","portrait":0},
		{"id":"bad","xp":1,"portrait":0},
		{"name":"Jana","xp":1,"portrait":0},
		{"id":"bad","name":"Jana","xp":1}]
	for bad_xp in [-1,Model.MAX_XP+1,1.0,true,false,"100",null]:
		var row := _row("bad",1)
		row.xp = bad_xp
		malformed.append(row)
	for bad_portrait in [-1,Model.MAX_PORTRAIT+1,1.0,true,false,"0",null]:
		var row := _row("bad",1)
		row.portrait = bad_portrait
		malformed.append(row)
	for bad_id in ["","spaced id","line\nbreak","line\n","line\r\n","áňa","x".repeat(65),true,100,null]:
		var row := _row("bad",1)
		row.id = bad_id
		malformed.append(row)
	for bad_name in ["","   ","!!!","\n\r\t","\u202e\u2066","\u0301",true,100,null,[]]:
		var row := _row("bad",1)
		row.name = bad_name
		malformed.append(row)
	for index in range(malformed.size()):
		check.call(not model.load_entries([_row("uncommitted",100),malformed[index]]),"Žebříček model: odmítne poškozený řádek%d" % index)
		check.call(model.entries == saved and model.player("uncommitted").is_empty(),"Žebříček model: vadná dávka%d nezmění původní pořadí ani lookup" % index)
	check.call(not model.load_entries([_row("same",1),_row("same",999)]) and model.entries == saved,"Žebříček model: duplicitní id zruší celou dávku i při rozdílných XP")
	check.call(not model.load_entries([_row("same",1),_row("same",1)]) and model.entries == saved,"Žebříček model: identická duplicitní kopie rovněž nevytvoří falešného soupeře")

	var original: Array = [_row("mine",123,"Moje jméno"),_row("rival",200,"Rival")]
	original[0].untrusted = {"nested":["do not expose"]}
	check.call(model.load_entries(original) and not model.player("mine").has("untrusted"),"Žebříček model: normalizuje pouze známá pole ukázky")
	var immutable := model.entries
	original[0].name = "Změněno"
	original[0].xp = 999
	original.clear()
	check.call(model.entries == immutable,"Žebříček model: následná změna vstupní fixture nemění pořadí")
	var returned_entries := model.entries
	returned_entries[0].xp = 0
	returned_entries.clear()
	check.call(model.entries == immutable,"Žebříček model: instance property nepředává vlastnictví vnitřních dat")
	var returned_top := model.top()
	returned_top[0].name = "Změněno"
	returned_top.clear()
	check.call(model.entries == immutable,"Žebříček model: úprava top pole a slovníku nemění model")
	var returned_around := model.around("mine")
	returned_around[0].rank = 999
	returned_around.pop_back()
	check.call(model.entries == immutable,"Žebříček model: úprava okolí nemění uložené příčky")
	var returned_player := model.player("mine")
	returned_player.name = "Změněno"
	returned_player.erase("xp")
	check.call(model.entries == immutable,"Žebříček model: detail hráče je samostatná kopie")
	var returned_target := model.next_target("mine")
	returned_target.name = "Změněno"
	returned_target.next_rank = 999
	check.call(model.entries == immutable and model.next_target("mine").name == "Rival","Žebříček model: cíl nepředává vnitřní záznam soupeře")
	check.call(model.load_entries([]) and model.entries.is_empty() and model.player("mine").is_empty() and model.around("rival").is_empty(),"Žebříček model: prázdná platná fixture vyčistí i dřívější lookup")
