class_name PlayArea extends Node2D

var card_path = "res://objects/zs_card.tscn"
var op_cards : Dictionary = {}

@onready var opponenent_pos = $opponenet_hand.position

const PLAYERHEALTH := 100.0
const TURN_TIME := 300.0
const ENDTURN_TIME := 1.0
const TURN_POINTS := 3

var turn_points := TURN_POINTS:
	set(value):
		turn_points = value
		var temp = turn_points
		for i in $status/turn_indicator/hbox.get_children().size():
			if temp>0: $status/turn_indicator/hbox.get_child(i).visible = true
			else: $status/turn_indicator/hbox.get_child(i).visible = false
			temp-=1
			
		$status/turn_points.text = str(turn_points)
		
		
		if turn_points < 0: turn_points = 0
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
			Global.GUI.create_screen_text("WAITING...")
			print("wait")
			pass
		STARTING:
			Global.GUI.create_screen_text("STARTING!",1.0)
			print("start")
			await get_tree().create_timer(1.0).timeout
			Global.PLAYER_DECK.auto_add_to_hand(3)
			match gamemode:
				SINGLEPLAYER:
					current_turn=flip_coin()
					await Global.GUI.create_coin_flip(current_turn).finish_flip
					
					if current_turn==USER_TURN:
						game_state=USER_PLAYING
					elif current_turn==OPPONENT_TURN:
						game_state=OPPONENT_PLAYING
				MULTIPLAYER:
					if Global.NETWORK.connection_type == Network.HOST:
						current_turn = flip_coin()
						await Global.GUI.create_coin_flip(current_turn).finish_flip
						
						if current_turn==USER_TURN:
							Global.NETWORK.USER.rpc("switch_game_state",USER_PLAYING)
						elif current_turn==OPPONENT_TURN:
							Global.NETWORK.OPPONENT.rpc("switch_game_state",USER_PLAYING)
					else: Global.GUI.create_coin_flip(!current_turn)
			pass
		USER_PLAYING:
			Global.GUI.create_screen_text(Global.USERDATA.display_name + "'S TURN!",1.5)
			print("user playing")
			if gamemode==MULTIPLAYER:
				Global.NETWORK.OPPONENT.rpc("switch_game_state",OPPONENT_PLAYING)
			Global.can_drag = true
			$status.mouse_filter = 2
			$status/vbox/end_turn.disabled=false
			state_tween.tween_property($status/vbox/timer,"value",0,TURN_TIME)
			await state_tween.finished
			end_turn()
			pass
		USER_ATTACKING:
			print("user attacking")
			if gamemode==MULTIPLAYER:
				Global.NETWORK.OPPONENT.rpc("switch_game_state",OPPONENT_ATTACKING)
			await get_tree().create_timer(1).timeout
			game_state = USER_ENDTURN
			pass
		USER_ENDTURN:
			print("user end turn")
			if gamemode==MULTIPLAYER:
				Global.NETWORK.OPPONENT.rpc("switch_game_state",OPPONENT_ENDTURN)
			await get_tree().create_timer(ENDTURN_TIME).timeout
			if turn_points<TURN_POINTS: turn_points+=1
			match gamemode:
				SINGLEPLAYER:game_state = OPPONENT_PLAYING
				MULTIPLAYER:Global.NETWORK.OPPONENT.rpc("switch_game_state",USER_PLAYING)
		OPPONENT_PLAYING:
			Global.GUI.create_screen_text("OPPONENT'S TURN!",1.5)
			print("opponent playing")
			match gamemode:
				SINGLEPLAYER:
					await get_tree().create_timer(1).timeout
					game_state = OPPONENT_ATTACKING
				MULTIPLAYER:pass
			pass
		OPPONENT_ATTACKING:
			print("opponent attacking")
			match gamemode:
				SINGLEPLAYER:
					await get_tree().create_timer(1).timeout
					game_state = OPPONENT_ENDTURN
				MULTIPLAYER:pass
			pass
		OPPONENT_ENDTURN:
			print("opponent end turn")
			Global.BOARD.flip_opponent_cards()
			match gamemode:
				SINGLEPLAYER:
					await get_tree().create_timer(1).timeout
					game_state = USER_PLAYING
				MULTIPLAYER:pass
			pass
		ENDING:
			print("end")
			pass

func _on_end_turn_pressed():
	end_turn()
	
func _ready():
	Global.can_drag = false
	if gamemode==SINGLEPLAYER:
		game_state=STARTING
	elif Global.NETWORK:
		game_state=WAITING

func end_turn():
	Global.can_drag = false
	Global.BOARD.lock_spaces()
	Global.GUI.close_move_info()
	if Global.is_dragging: Global.dragged_card.release()
	$status/vbox/end_turn.disabled=true
	$status/vbox/timer.value = 100.0
	game_state = USER_ATTACKING

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
			Global.BOARD.op_spaces[space_index-1].add(new_card)
			
			
			#match space_index:
				#1:
					#Global.BOARD.space_1.add(new_card)
				#2:
					#Global.BOARD.space_2.add(new_card)
				#3:
					#Global.BOARD.space_3.add(new_card)
				#4:
					#Global.BOARD.space_4.add(new_card)
				#5:
					#Global.BOARD.space_5.add(new_card)
				#_:
					#pass
			#new_card.move_to
	else:
		if op_cards.has(card_inst):
			op_cards[card_inst].owner_space.remove(op_cards[card_inst])
			op_cards[card_inst].queue_free()
			op_cards.erase(card_inst)

	#space.add(new_card)


func retrieve_board_state():
	var board : Board = Global.BOARD
	


func damage_user(_damage:float):
	#p1.health -= damage
	#$status/opponent_health.text = str(p1.health)
	pass
func damage_opponent(_damage:float):
	#p2.health -= damage
	#$status/user_health.text = str(p2.health)
	pass
	
func flip_coin() -> int:
	var result = randi_range(0,1)
	return result

func try_take_turn() -> bool:
	if turn_points > 0:
		turn_points-=1
		return true
	else:
		Global.GUI.create_float_text(get_global_mouse_position(),"OUT OF MOVES!")
		return false
