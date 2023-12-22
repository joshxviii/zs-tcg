extends Node2D

var card_path = "res://objects/zs_card.tscn"
var op_cards : Dictionary = {}

@onready var opponenent_pos = $opponenet_hand.position

func update_opponenet_cards(move_data:Dictionary):
	var is_added = move_data["added"]
	var card_id = move_data["card_id"]
	var space_index = move_data["space_index"]
	var card_inst = move_data["card_inst"]
	
	if is_added:
		if !op_cards.has(card_inst):
			var new_card = load(card_path).instantiate()
			new_card.id = card_id
			new_card.draggable=false
			new_card.position = opponenent_pos
			add_child(new_card)
			op_cards[card_inst] = new_card
			
			match space_index:
				1:
					Global.BOARD.space_1.add(new_card)
				2:
					Global.BOARD.space_2.add(new_card)
				3:
					Global.BOARD.space_3.add(new_card)
				4:
					Global.BOARD.space_4.add(new_card)
				5:
					Global.BOARD.space_5.add(new_card)
				_:
					pass
			#new_card.move_to
	else:
		if op_cards.has(card_inst):
			op_cards[card_inst].queue_free()
			op_cards.erase(card_inst)

	#space.add(new_card)
