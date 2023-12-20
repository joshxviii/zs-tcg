extends CanvasLayer

const move_info_path = preload("res://objects/ui/move_info.tscn")
const focus_out_path = preload("res://objects/ui/focus_out.tscn")
const float_text_path = preload("res://objects/ui/float_text.tscn")

var ui_focused:=false

func _ready():
	Global.GUI = self

func create_move_info(card : Card2D):
	var closer = create_focus_out()
	ui_focused=true
	var move_info = move_info_path.instantiate()
	move_info.card = card
	move_info.position = card.get_global_mouse_position()-Vector2(10,-20)
	add_child(move_info)
	move_info.update_info()
	await closer.closed
	move_info.close()

func create_float_text(pos:Vector2,text:String,color:=Color.WHITE):
	var float_text = float_text_path.instantiate()
	add_child(float_text)
	float_text.global_position = pos
	float_text.text = text
	float_text.color = color
	float_text.start()
	

func create_focus_out() -> Control:
	var focus_out = focus_out_path.instantiate()
	add_child(focus_out)
	return focus_out
