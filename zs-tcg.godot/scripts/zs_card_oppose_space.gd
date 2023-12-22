@icon("res://assets/icons/card_play_space2D.svg")
class_name CardOpposeSpace2D extends CardSpace2D


func _on_card_added(card):
	card.move_to(self.global_position,0)
	card.draggable = false
	card.target_pos = global_position

func _on_card_returned(card):
	card.move_to(card.target_pos)
	card.draggable = false
	pass # Replace with function body.
