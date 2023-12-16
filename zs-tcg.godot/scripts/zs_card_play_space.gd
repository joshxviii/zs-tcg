@icon("res://assets/icons/card_play_space2D.svg")
class_name CardPlaySpace2D extends CardSpace2D

##Cards placed in this space will be face down
@export var lock_space := false
@export var face_down_space := false
@export var can_swap := true

var default_target : CardSpace2D

func _ready():
	pass


func _on_card_added(card):
	
	if card.selected_move == 0:
		if card.m1_attributes.has("target_mode"):
			card.selected_move=1
			card.current_move_info=card.m1_attributes
	
	if card.current_move_info.has("target_mode"):
		var mode = int(card.current_move_info["target_mode"])
		if mode == Global.FOE || mode == Global.FOE_ALL || mode == Global.ALL:
			card.targeted_space = default_target
		else:
			card.targeted_space = self
	
	card.target_z_layer=0
	card.move_to(self.global_position,0)
	disabled = true
	
	if cards.size()>MAX_CARDS:
		if can_swap:
			if cards[0].draggable: swap()
		else:
			push_error("MAX CARDS exceeded.")
	
	card.target_pos = global_position
	if face_down_space: card.facing_direction = 1
	else: card.facing_direction = 0
	
	if !lock_space: card.draggable=true


func _on_card_removed(_card):
	pass # Replace with function body.


func swap():
	if cards.size()>1:
		if cards[-1].prev_owner_space:
			cards[0].move_to(cards[-1].prev_owner_space.global_position)
			cards[-1].prev_owner_space.add(cards[0])
		else: remove(cards[0])


func _on_card_returned(card):
	card.move_to(card.target_pos)
	if !lock_space: card.draggable=true
	pass # Replace with function body.


func _on_opposing_space_getter_body_entered(body):
	if body.is_in_group("opposing_space"):
		default_target = body
	pass # Replace with function body.
