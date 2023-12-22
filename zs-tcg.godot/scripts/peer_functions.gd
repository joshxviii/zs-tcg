extends Node

@export var DISPLAY_NAME:=""
var USERBOARD
var op_id=0

@export var move := {"space_index":0,"card_inst":0,"card_id":0,"added":true}:
	set(value):
		if value!=move:
			move=value
			#print(DISPLAY_NAME + ": " + str(move["card_id"]) + " - " + str(move["space_index"]) )

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	if is_multiplayer_authority():
		Global.BOARD.board_changed.connect(on_board_changed)
		USERBOARD=Global.PLAYAREA
		DISPLAY_NAME = Global.NETWORK.display_name
		$multiplayer_ui/you.text = DISPLAY_NAME
		Global.PLAYAREA.visible=true
		Global.NETWORK.timeout_timer.stop()
		Global.MAINMENU.hide()
		if Global.NETWORK.connection_type==Network.JOIN:
			Global.stop_wait()
			print("Success! Joining: %s" % Global.NETWORK.address)
	elif !is_multiplayer_authority():
		op_id = name.to_int()
		$multiplayer_ui/you.position = Vector2(0,0)
		pass
	

@rpc("any_peer","call_remote","reliable")
func send_move_data(id,move_data):
	if !is_multiplayer_authority():
		Global.PLAYAREA.update_opponenet_cards(move_data)

func on_board_changed(space_index, card, added):
	if is_multiplayer_authority():
		move["space_index"] = space_index
		move["card_inst"] = card.get_instance_id()
		move["card_id"] = card.id
		move["added"] = added
		rpc("send_move_data", Global.NETWORK.op_id, move)
