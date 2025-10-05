extends Node

@export var DISPLAY_NAME:=""
var USERBOARD
var op_id=0

@export var move := {"space_pos":Vector2.ZERO,"card_inst":0,"card_id":0,"added":true}:
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
		Global.space_updated.connect(on_space_update)
		Global.PLAYAREA.hps_changed.connect(hp_update)
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
func send_attack_info(inst_id, atk_rot, atk_anim):
	if !is_multiplayer_authority():
		if Global.PLAYAREA.all_cards.has(inst_id):
			Global.PLAYAREA.all_cards[inst_id].attack_anim(atk_rot,atk_anim)

@rpc("any_peer","call_local","reliable")
func update_card(event,card_data):
	if !is_multiplayer_authority():
		if Global.PLAYAREA.all_cards.has(card_data["instance_id"]):
			var card : Card2D = Global.PLAYAREA.all_cards[card_data["instance_id"]]
			
			match int(event):
				Card2D.HEALTH_CHANGE:
					if card.current_health!=card_data["current_health"]: card.current_health=card_data["current_health"]
				Card2D.EFFECT_ADDED:
					var effect = card_data["current_status_effects"][-1]
					StatusEffect.new(card,effect["id"],effect["duration"],effect["strength"],Global.PLAYAREA.all_cards[effect["target_card_inst_id"]])
				Card2D.EFFECT_ADDED:pass
			
			if card.get_card_data()!=card_data:
				card.id=int(card_data["id"])
				card.attributes=card_data["attributes"]
				card.profile_path = card_data["profile_path"]
				card.update_attributes()
				card.atk_animator.play("effect/heal")

@rpc("any_peer","call_local","reliable")
func update_hp(hp:float,indx:int):
		if !is_multiplayer_authority():
			match indx:
				0:Global.PLAYAREA.hp_opponent=hp
				1:Global.PLAYAREA.hp_user=hp
				
@rpc("any_peer","call_local","reliable")
func animate_space(space_pos:Vector2):
	if !is_multiplayer_authority():
		Global.BOARD.get_space(space_pos).anim.play("hit")

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

func on_board_changed(space_pos, card, event):
	if is_multiplayer_authority():
		move["space_pos"] = space_pos
		move["card_inst"] = card.inst_id
		move["card_id"] = card.id
		move["event"] = event
		rpc("send_move_data", Global.NETWORK.op_id, move)

func on_card_update(card:Card2D,event:int):
	if is_multiplayer_authority():
		rpc("update_card", event, card.get_card_data())

func on_space_update(space:CardSpace2D):
	if is_multiplayer_authority():
		rpc("animate_space", Vector2(space.space_pos.x,int(space.space_pos.y+1)%2))
		
func on_card_attacked(card:Card2D):
	if is_multiplayer_authority():
		rpc("send_attack_info", card.inst_id, Vector2(card.atk_rot.x,-card.atk_rot.y), card.atk_anim)

func hp_update(hp, indx):
	if is_multiplayer_authority():
		rpc("update_hp", hp, indx)
