extends Node

@export var DISPLAY_NAME:=""
var USERBOARD
var op_id=0

@export var move := {"space_index":0,"card_inst":0,"card_id":0,"added":true}:
	set(value):
		if value!=move:
			move=value
			#print(DISPLAY_NAME + ": I" + str(move["card_id"]) + ", S" + str(move["space_index"]) +", A" + str(move["added"]) )

func _enter_tree():
	set_multiplayer_authority(name.to_int())

func _ready():
	if is_multiplayer_authority():
		Global.BOARD.board_changed.connect(on_board_changed)
		Global.card_attacked.connect(on_card_attacked)
		Global.card_updated.connect(on_card_update)
		USERBOARD=Global.PLAYAREA
		DISPLAY_NAME = Global.USERDATA.display_name
		$multiplayer_ui/you.text = DISPLAY_NAME
		Global.PLAYAREA.visible=true
		Global.NETWORK.timeout_timer.stop()
		Global.NETWORK.USER = self
		Global.MAINMENU.hide()
		if Global.NETWORK.connection_type==Network.JOIN:
			Global.stop_wait()
			print("Success! Joining: %s" % Global.NETWORK.address)
			rpc("start_game")
	elif !is_multiplayer_authority():
		Global.NETWORK.OPPONENT = self
		DISPLAY_NAME = Global.USERDATA.display_name
		op_id = name.to_int()
		$multiplayer_ui/you.position = Vector2(0,0)
		pass
	

@rpc("any_peer","call_remote","reliable")
func send_move_data(_id,move_data):
	if !is_multiplayer_authority():
		Global.PLAYAREA.update_opponent_cards(move_data)

@rpc("any_peer","call_remote","reliable")
func send_attack_info(inst_id, space_index:int, damage:int, anim:String):
	if !is_multiplayer_authority():
		print("AAAAAAAAAAAAA")

@rpc("any_peer","call_local","reliable")
func update_card(inst_id,health:int):
	if !is_multiplayer_authority():
		print(Global.PLAYAREA.all_cards)
		if Global.PLAYAREA.all_cards.has(inst_id):
			Global.PLAYAREA.all_cards[inst_id].current_health=health


@rpc("any_peer","call_local","reliable")
func start_game():
	Global.PLAYAREA.game_state=Global.PLAYAREA.STARTING

@rpc("any_peer","call_local","reliable")
func switch_game_state(state):
	if is_multiplayer_authority():
		Global.PLAYAREA.game_state=state

@rpc("any_peer","call_local","reliable")
func filp_cards():
	if is_multiplayer_authority():
		Global.BOARD.flip_opponent_cards()

func on_board_changed(space_index, card, event):
	if is_multiplayer_authority():
		move["space_index"] = space_index
		move["card_inst"] = card.inst_id
		move["card_id"] = card.id
		move["event"] = event
		rpc("send_move_data", Global.NETWORK.op_id, move)

func on_card_update(card:Card2D):
	if is_multiplayer_authority():
		rpc("update_card", card.inst_id, card.current_health)

func on_card_attacked(card:Card2D, target:CardSpace2D, damage:int, anim:String):
	if is_multiplayer_authority():
		rpc("send_attack_info", card.inst_id, target.space_index, damage, anim)
		print(str(card)+" "+str(target)+" "+str(damage))
