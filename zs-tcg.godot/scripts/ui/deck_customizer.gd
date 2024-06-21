extends Control

const item_path = preload("res://objects/ui/collection_item.tscn")

var item_list : Dictionary

var db = DataBaseHandler.new()

var select_item_id : int

@onready var info_type_icon := $info_panel/title/type_icon
@onready var info_name := $info_panel/title/name

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	db.database_path = "res://assets/zs_cards.json"
	
	var fc = Global.USERDATA.get_free_collection_cards()
	
	for n in 24:
		var tab : HFlowContainer = HFlowContainer.new()
		var scroll = ScrollContainer.new()
		$collection_menu.add_child(scroll)
		scroll.add_child(tab)
		scroll.name = "Pack " + str(n+1)
		tab.add_theme_constant_override("v_separation",16)
		tab.clip_contents=true
		tab.size_flags_horizontal = SIZE_EXPAND_FILL
		
		var pack = db.sort_sheet_by_attribute("cards","pack_id",n)
		var has_card_in_pack:=false
		for card in pack:
			var item = item_path.instantiate()
			tab.add_child(item)
			
			if Global.USERDATA.collection.has(pack[card]["sheet_id"]):
				item.pressed.connect(on_item_pressed.bind(pack[card]))
				item.locked=false
				item.id = pack[card]["sheet_id"]
				item.item_name = pack[card]["name"]
				item.pack_id = pack[card]["pack_id"]
				item.amount = fc[item.id]
				item_list[item.id] = item
				has_card_in_pack=true
			else:item.locked=true
			
		if !has_card_in_pack: scroll.queue_free()
		
	for card in Global.USERDATA.deck: append_to_deck_ui(card)


func on_item_pressed(card):
	
	select_item_id=card["sheet_id"]
	
	update_buttons()
	
	$info_panel/title.visible = true
	
	info_name.text = card["name"]
	info_type_icon.frame = card["type"]
	
	var m1
	if card.has("move_1"):
		$info_panel/moves/move_1.visible = true
		m1 = db.retrive_attributes("moves",card["move_1"])
		$info_panel/moves/move_1/type/type/icon.frame = m1["type"]
		$info_panel/moves/move_1/type/power.text = str(m1["power"])
		$info_panel/moves/move_1/name.text = m1["name"]
		$info_panel/moves/move_1/target_mode/mode.frame = m1["target_mode"]
	else: $info_panel/moves/move_1.visible = false
	var m2
	if card.has("move_2"):
		$info_panel/moves/move_2.visible = true
		m2 = db.retrive_attributes("moves",card["move_2"])
		$info_panel/moves/move_2/type/type/icon.frame = m2["type"]
		$info_panel/moves/move_2/type/power.text = str(m2["power"])
		$info_panel/moves/move_2/name.text = m2["name"]
		$info_panel/moves/move_2/target_mode/mode.frame = m2["target_mode"]
	else: $info_panel/moves/move_2.visible = false



func _on_main_menu_pressed() -> void:
	Global.return_to_title()
	Global.save_userdata()
	queue_free()

func append_to_deck_ui(id:int):
	var info = db.retrive_attributes("cards",id)
	var item = item_path.instantiate()
	item.pressed.connect(on_item_pressed.bind(info))
	$deck_panel/deck_scroll/deck.add_child(item)
	item.deck_item=true
	item.item_name = info["name"]
	item.pack_id = info["pack_id"]
	item.id = id
	select_item_id=id
	

func remove_from_deck_ui(index:int):
	$deck_panel/deck_scroll/deck.get_child(index).queue_free()
	item_list[select_item_id].grab_focus()

func _on_remove_pressed() -> void:
	var has_item = Global.USERDATA.deck.find(select_item_id)
	if has_item>=0:
		Global.USERDATA.deck.remove_at(has_item)
		item_list[select_item_id].amount += 1
		remove_from_deck_ui(has_item)
	update_buttons()

func _on_add_pressed() -> void:
	if item_list[select_item_id].amount>0:
		Global.USERDATA.deck.append(item_list[select_item_id].id)
		item_list[select_item_id].amount -= 1
		append_to_deck_ui(item_list[select_item_id].id)
	update_buttons()

func update_buttons():
	if item_list[select_item_id].amount>0:
		$info_panel/buttons/add.disabled=false
	else:
		$info_panel/buttons/add.disabled=true
	var has_item = Global.USERDATA.deck.find(select_item_id)
	if has_item>=0:
		$info_panel/buttons/remove.disabled=false
	else:
		$info_panel/buttons/remove.disabled=true
