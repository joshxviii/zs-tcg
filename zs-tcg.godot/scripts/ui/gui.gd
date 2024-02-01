extends CanvasLayer

const move_info_path = preload("res://objects/ui/move_info.tscn")
const focus_out_path = preload("res://objects/ui/focus_out.tscn")
const float_text_path = preload("res://objects/ui/float_text.tscn")

var ui_focused:=false

func _ready():
	Global.GUI = self

var move_info
var focus_out
func create_move_info(card : Card2D):
	close_move_info()
	ui_focused=true
	move_info = move_info_path.instantiate()
	move_info.card = card
	move_info.position = card.get_global_mouse_position()-Vector2(10,-20)
	var closer = create_focus_out(card.owner_space)
	add_child(move_info)
	move_info.update_info()
	await closer.closed
	if move_info: move_info.close()

func create_float_text(pos:Vector2,text:String,color:=Color.WHITE):
	var float_text = float_text_path.instantiate()
	add_child(float_text)
	float_text.global_position = pos
	float_text.text = text
	float_text.color = color
	float_text.start()
	

func create_focus_out(parent=self) -> Control:
	focus_out = focus_out_path.instantiate()
	parent.add_child(focus_out)
	return focus_out

#func close_user_windows():
	#if focus_out: focus_out.close()
	##if move_info: move_info.queue_free()

func close_move_info():
	if move_info: move_info.close()
	move_info=null
