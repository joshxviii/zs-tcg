extends CanvasLayer

const move_info_path = preload("res://objects/ui/move_info.tscn")
const focus_out_path = preload("res://objects/ui/focus_out.tscn")

var ui_focused:=false

func _ready():
	Global.GUI = self
	pass # Replace with function body.

func create_move_info(card : Card2D):
	var closer = create_focus_out()
	ui_focused=true
	var move_info = move_info_path.instantiate()
	add_child(move_info)
	move_info.card = card
	move_info.position = card.get_global_mouse_position()-Vector2(10,10)
	move_info.update_info()
	await closer.closed
	move_info.close()

func create_focus_out() -> Control:
	var focus_out = focus_out_path.instantiate()
	add_child(focus_out)
	return focus_out
