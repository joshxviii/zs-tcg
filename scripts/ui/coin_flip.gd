extends Control

signal finish_flip

func start(i:int):
	if i == PlayArea.USER_TURN:
		$coin.play("User")
	else:
		$coin.play("Opponent")

func _on_coin_animation_finished() -> void:
	finish_flip.emit()
	queue_free()
