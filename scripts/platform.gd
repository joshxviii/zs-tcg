class_name Board extends Node2D

@onready var op_spaces : Array[CardOpposeSpace2D] = [
	$opponent_space_1,
	$opponent_space_2,
	$opponent_space_3,
	$opponent_space_4,
	$opponent_space_5
	]

@onready var user_spaces : Array[CardPlaySpace2D] = [
	$player_space_1,
	$player_space_2,
	$player_space_3,
	$player_space_4,
	$player_space_5
	]

@onready var all_spaces := [user_spaces,op_spaces]

signal board_changed(space:CardSpace2D,space_pos:Vector2,card:Card2D,card_id:int,event:int)

func _init():
	Global.BOARD = self
	
func _ready() -> void:
	for i in user_spaces.size(): #give spaces on board a position. (bottom left space is 0,0)
		user_spaces[i].space_pos = Vector2(i,0)
		user_spaces[i].connect("space_changed",_on_player_space_altered)
	for i in op_spaces.size():
		op_spaces[i].space_pos = Vector2(i,1)

func get_space(coordinates:Vector2) -> CardSpace2D: # get space on board from space_pos coordinate
	if coordinates.x<0 || coordinates.x>all_spaces[coordinates.y].size()-1:
		return null
	return all_spaces[coordinates.y][coordinates.x]


func _on_player_space_altered(space:CardPlaySpace2D,card:Card2D,pos:Vector2,event:int):
	#print( str(index) + ", " + str(space) + ", " + str(!(card.prev_owner_space==space)) )
	board_changed.emit(pos,card,event)

func lock_spaces():
	for space in user_spaces:
		if space.cards.size()>0:
			space.cards[0].draggable=false
			space.locked=true

func flip_opponent_cards():
	for space in op_spaces:
		if space.cards.size()>0: space.cards[0].facing_direction=0

func user_attack():
	for space in user_spaces:
		if space.cards.size()<1:continue
		var card = space.cards[0]
		await card.attack()
	
func opponent_attack():
	for space in op_spaces:
		if space.cards.size()>0: for target in space.targets:
			if target.cards.size()>0:
				pass
			elif target.is_in_group("opposing_space"):
				pass
