class_name PlayArea extends Node2D

var card_path = "res://objects/zs_card.tscn"
var all_cards : Dictionary = {}

@onready var opponenent_pos = $opponenet_hand.position
@onready var turn_time_text = $status/vbox/timer/time

const PLAYERHEALTH := 100.0
const TURN_TIME := 30.0 # turn time in seconds
var turn_timer := SecondTimer.new()
const ENDTURN_TIME := 1.0
const TURN_POINTS := 3

signal hps_changed
@onready var hp_user:=PLAYERHEALTH:
	set(value):
		if value==hp_user:return
		Global.GUI.create_float_text(Vector2(80,280),str(hp_user-value),Color.RED,2.5)
		print(hp_user-value)
		hps_changed.emit(value,0)
		var tween = get_tree().create_tween()
		tween.tween_method(update_hp_text.bind($status/vbox2/user_health), hp_user, value, 0.5)
		if value<=0:
			pass
		hp_user=value
@onready var hp_opponent:=PLAYERHEALTH:
	set(value):
		if value==hp_opponent:return
		Global.GUI.create_float_text(Vector2(80,64),str(hp_opponent-value),Color.RED,2.5)
		hps_changed.emit(value,1)
		var tween = get_tree().create_tween()
		tween.tween_method(update_hp_text.bind($status/vbox2/opponent_health), hp_opponent, value, 0.5)
		if value<=0:
			pass
		hp_opponent=value

func update_hp_text(hp:float,label:Label):
	label.text = str(floor(hp))+"hp"
	#TODO play beep sounds when health changes


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
	USER_START,
	OPPONENT_START,
	USER_PLAYING,
	USER_ATTACKING,
	USER_ENDTURN,
	OPPONENT_PLAYING,
	OPPONENT_ATTACKING,
	OPPONENT_ENDTURN,
	ENDING
}

var game_state:
	set(value):
		game_state = value
		update_game_state()
func update_game_state(): #state machine for game state changes
	match game_state:
		WAITING:
			Global.GUI.create_screen_text("WAITING...")
			print("wait")
		STARTING:
			Global.GUI.create_screen_text("STARTING!",1.0)
			print("start")
			await get_tree().create_timer(1.0).timeout
			Global.PLAYER_DECK.auto_add_to_hand(3)
			match gamemode:
				SINGLEPLAYER:
					current_turn=flip_coin()
					if current_turn==USER_TURN:
						game_state=USER_START
					elif current_turn==OPPONENT_TURN:
						game_state=OPPONENT_START
				MULTIPLAYER:
					if Global.NETWORK.connection_type == Network.HOST:
						current_turn = flip_coin()
						if current_turn==USER_TURN:switch_state(USER_START)
						elif current_turn==OPPONENT_TURN:Global.NETWORK.OPPONENT.rpc("switch_game_state",USER_START)
		
		USER_START:
			if gamemode==MULTIPLAYER:Global.NETWORK.OPPONENT.rpc("switch_game_state",OPPONENT_START)
			await Global.GUI.create_coin_flip(USER_TURN).finish_flip
			switch_state(USER_PLAYING)
		USER_PLAYING:
			if gamemode==MULTIPLAYER: Global.NETWORK.OPPONENT.rpc("switch_game_state",OPPONENT_PLAYING)
			Global.GUI.create_screen_text(Global.USERDATA.display_name + "'S TURN!",1.5)
			print("user playing")
			Global.can_drag = true
			$status.mouse_filter = 2
			$status/vbox/end_turn.disabled=false
			
			turn_timer.start(TURN_TIME)
			#var tween = create_tween()
			#tween.tween_property($status/vbox/timer,"value",0,TURN_TIME)

		USER_ATTACKING:
			if gamemode==MULTIPLAYER:Global.NETWORK.OPPONENT.rpc("switch_game_state",OPPONENT_ATTACKING)
			print("user attacking")
			
			await Global.BOARD.user_attack()

			switch_state(USER_ENDTURN)
		USER_ENDTURN:
			if gamemode==MULTIPLAYER:Global.NETWORK.OPPONENT.rpc("switch_game_state",OPPONENT_ENDTURN)
			print("user end turn")
			await get_tree().create_timer(ENDTURN_TIME).timeout
			if turn_points<TURN_POINTS: turn_points+=1
			match gamemode:
				SINGLEPLAYER:switch_state(OPPONENT_PLAYING)
				MULTIPLAYER:Global.NETWORK.OPPONENT.rpc("switch_game_state",USER_PLAYING)
		
		OPPONENT_START:
			await Global.GUI.create_coin_flip(OPPONENT_TURN).finish_flip
			match gamemode:
				SINGLEPLAYER:switch_state(OPPONENT_PLAYING)
				MULTIPLAYER:pass
		OPPONENT_PLAYING:
			Global.GUI.create_screen_text("OPPONENT'S TURN!",1.5)
			print("opponent playing")
			match gamemode:
				SINGLEPLAYER:
					await get_tree().create_timer(1).timeout
					switch_state(OPPONENT_ATTACKING)
				MULTIPLAYER:pass
		OPPONENT_ATTACKING:
			print("opponent attacking")
			match gamemode:
				SINGLEPLAYER:
					await get_tree().create_timer(1).timeout
					switch_state(OPPONENT_ENDTURN)
				MULTIPLAYER:pass
		OPPONENT_ENDTURN:
			print("opponent end turn")
			match gamemode:
				SINGLEPLAYER:
					await get_tree().create_timer(1).timeout
					switch_state(USER_PLAYING)
				MULTIPLAYER:pass
		
		ENDING:
			print("end")
func switch_state(state:int):
	game_state=state

func _on_end_turn_pressed():
	end_turn()

func on_turn_timer_timeout():
	end_turn()

func end_turn():
	turn_timer.stop()
	$status/vbox/end_turn.disabled=true
	Global.can_drag = false
	Global.BOARD.lock_spaces()
	Global.GUI.close_move_info()
	if Global.is_dragging: Global.dragged_card.release()
	$status/vbox/timer.value = 100.0
	match gamemode:
		SINGLEPLAYER:pass
		MULTIPLAYER:Global.NETWORK.OPPONENT.rpc("filp_cards")
	await get_tree().create_timer(1).timeout
	turn_time_text.text="0:00"
	switch_state(USER_ATTACKING)

func _ready():
	Global.load_userdata()
	Global.can_drag = false
	turn_timer.connect("time_changed",update_turn_time)
	turn_timer.connect("timeout",on_turn_timer_timeout)
	
	match gamemode:
		SINGLEPLAYER:
			game_state=STARTING
			turn_timer.process_mode=Node.PROCESS_MODE_PAUSABLE
		MULTIPLAYER:
			game_state=WAITING
			turn_timer.process_mode=Node.PROCESS_MODE_ALWAYS

##Add or remove new cards onto the board as opponent moves
func update_opponent_cards(move_data:Dictionary):
	var event = move_data["event"]
	var card_id = move_data["card_id"]
	var space_pos = move_data["space_pos"]
	var card_inst = move_data["card_inst"]
	
	match event:
		CardSpace2D.ADDED:
			if !all_cards.has(card_inst):#if move data has a instance id
				var new_card : Card2D = load(card_path).instantiate()
				new_card.id = card_id
				new_card.inst_id = card_inst
				new_card.draggable=false
				new_card.position = opponenent_pos
				new_card.facing_direction=1
				add_child(new_card)
				all_cards[card_inst] = new_card
				Global.BOARD.op_spaces[space_pos.x].add(new_card)
		CardSpace2D.REMOVED:
			if all_cards.has(card_inst):
				all_cards[card_inst].owner_space.remove(all_cards[card_inst])
				all_cards[card_inst].move_to(opponenent_pos,0)
				all_cards.erase(all_cards[card_inst].inst_id)
		CardSpace2D.KILLED:
			pass

func retrieve_board_state():
	var _board : Board = Global.BOARD

func update_turn_time():
	turn_time_text.text = (str(int(turn_timer.time_left/60)) + ":" + str(int(turn_timer.time_left/10)%6) + str(int(turn_timer.time_left)%10))
	if (turn_timer.time_left < 6.0):
		Global.GUI.create_screen_text(str(floor(turn_timer.time_left)),0.9,Color.TOMATO)
	
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
