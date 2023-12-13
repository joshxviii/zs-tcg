extends CardSpace2D

func _on_card_added(card):
	card.move_to(self.global_position)
	card.facing_direction = 0
	card.draggable = false
	await get_tree().create_timer(.5).timeout
	remove(card)
	card.queue_free()
	pass # Replace with function body.
