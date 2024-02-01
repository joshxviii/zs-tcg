extends Node2D

var card_path = "res://objects/zs_card.tscn"
var op_cards : Dictionary = {}

@onready var opponenent_pos = $opponenet_hand.position

const PLAYERHEALTH := 100.0
const TURN_TIME := 600.0
const ENDTURN_TIME := 2.0
const TURN_POINTS := 3

var user_health := PLAYERHEALTH
var opponent_health := PLAYERHEALTH
var turn_points := TURN_POINTS:
	set(value):
		turn_points = value
		$status/turn_points.text = str(turn_points)
		if turn_points == 0: Global.GUI.create_float_text(get_global_mouse_position(),"OUT OF MOVES!")
		#if turn_points <= 0: Global.can_drag = false
	get:
		return turn_points

enum {
	USER_TURN,
	OPPONENT_TURN
}
var current_turn:=-1

enum {
	SINGLEPLAYER,
	MULTIPLAYER
}
var gamemode:=-1

enum {
	WAITING,
	STARTING,
	USER_PLAYING,
	USER_ENDTURN,
	USER_ATTACKING,
	OPPONENT_PLAYING,
	OPPONENT_ENDTURN,
	OPPONENT_ATTACKING,
	ENDING
}
var state_tween
var game_state:
	set(value):
		game_state = value
		update_game_state()
func update_game_state():
	if state_tween: state_tween.kill()
	state_tween = create_tween()
	match game_state:
		WAITING:
			print("wait")
			pass
		STARTING:
			print("start")

			await get_tree().create_timer(1.0).timeout
			
			Global.PLAYER_DECK.auto_add_to_hand(3)
			
			if gamemode==SINGLEPLAYER:
				current_turn=USER_TURN#TODO remove
				#current_turn = randi_range(USER_TURN,OPPONENT_TURN)
				if current_turn==USER_TURN:
					game_state=USER_PLAYING
				elif current_turn==OPPONENT_TURN:
					game_state=OPPONENT_PLAYING
			elif Global.NETWORK.connection_type == Network.HOST:
				current_turn = Global.NETWORK.flip_coin()
				if current_turn==USER_TURN:
					Global.NETWORK.USER.rpc("switch_game_state",USER_PLAYING)
				elif current_turn==OPPONENT_TURN:
					Global.NETWORK.OPPONENT.rpc("switch_game_state",USER_PLAYING)
			pass
		USER_ATTACKING:
			print("user attack")
			if gamemode==MULTIPLAYER:
				Global.NETWORK.OPPONENT.rpc("switch_game_state",OPPONENT_ATTACKING)
			await get_tree().create_timer(1).timeout
			game_state = USER_PLAYING
			pass
		USER_PLAYING:
			print("user play")
			if gamemode==MULTIPLAYER:
				Global.NETWORK.OPPONENT.rpc("switch_game_state",OPPONENT_PLAYING)
			Global.can_drag = true
			$status.mouse_filter = 2
			$status/vbox/end_turn.disabled=false
			state_tween.tween_property($status/vbox/timer,"value",0,TURN_TIME)
			await state_tween.finished
			game_state = USER_ENDTURN
			pass
		USER_ENDTURN:
			print("end turn")
			if gamemode==MULTIPLAYER:
				Global.NETWORK.OPPONENT.rpc("switch_game_state",OPPONENT_ENDTURN)
			Global.can_drag = false
			Global.BOARD.lock_spaces()
			Global.GUI.close_move_info()
			if Global.is_dragging: Global.dragged_card.release()
			$status/vbox/end_turn.disabled=true
			$status/vbox/timer.value = 100.0
			await get_tree().create_timer(ENDTURN_TIME).timeout
			if turn_points<TURN_POINTS: turn_points+=1
			if gamemode==MULTIPLAYER:
				Global.NETWORK.OPPONENT.rpc("switch_game_state",USER_ATTACKING)
		OPPONENT_ATTACKING:
			print("opponent attacking")
			pass
		OPPONENT_PLAYING:
			print("opponent playing")
			pass
		OPPONENT_ENDTURN:
			print("opponent end turn")
			Global.BOARD.flip_opponent_cards()
			pass
		ENDING:
			pass
func _on_end_turn_pressed():
	game_state = USER_ENDTURN
	
func _ready():
	Global.can_drag = false
	if gamemode==SINGLEPLAYER: game_state=STARTING
	else: game_state=WAITING

##Add or remove new cards onto the board as opponent moves
func update_opponent_cards(move_data:Dictionary):
	var is_added = move_data["added"]
	var card_id = move_data["card_id"]
	var space_index = move_data["space_index"]
	var card_inst = move_data["card_inst"]
	
	if is_added:
		if !op_cards.has(card_inst):#ife move data has a instance id
			var new_card : Card2D = load(card_path).instantiate()
			new_card.id = card_id
			new_card.draggable=false
			new_card.position = opponenent_pos
			new_card.facing_direction=1
			add_child(new_card)
			op_cards[card_inst] = new_card
			
			match space_index:
				1:
					Global.BOARD.space_1.add(new_card)
				2:
					Global.BOARD.space_2.add(new_card)
				3:
					Global.BOARD.space_3.add(new_card)
				4:
					Global.BOARD.space_4.add(new_card)
				5:
					Global.BOARD.space_5.add(new_card)
				_:
					pass
			#new_card.move_to
	else:
		if op_cards.has(card_inst):
			op_cards[card_inst].owner_space.remove(op_cards[card_inst])
			op_cards[card_inst].queue_free()
			op_cards.erase(card_inst)

	#space.add(new_card)

func damage_user(damage:float):
	user_health -= damage
	$status/opponent_health.text = str(user_health)
	pass
func damage_opponent(damage:float):
	opponent_health -= damage
	$status/user_health.text = str(opponent_health)
	pass
	



