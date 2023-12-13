@icon("res://assets/icons/card_play_space2D.svg")
class_name CardPlaySpace2D extends CardSpace2D

##Cards placed in this space will be face down
@export var lock_space := false
@export var face_down_space := false
@export var can_swap := true


func _ready():
	pass


func _on_card_added(card):
	if card.selected_move == 0: card.selected_move=1
	card.target_z_layer=0
	card.move_to(self.global_position,0)
	disabled = true
	
	if cards.size()>MAX_CARDS:
		if can_swap:
			swap()
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
