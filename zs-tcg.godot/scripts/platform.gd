extends Node2D

@onready var space_1 = $opponent_space_1
@onready var space_2 = $opponent_space_2
@onready var space_3 = $opponent_space_3
@onready var space_4 = $opponent_space_4
@onready var space_5 = $opponent_space_5

@onready var player_space_1 = $player_space_1
@onready var player_space_2 = $player_space_2
@onready var player_space_3 = $player_space_3
@onready var player_space_4 = $player_space_4
@onready var player_space_5 = $player_space_5


signal board_changed(space:CardSpace2D,space_index:int,card:Card2D,card_id:int,added:bool)

func _init():
	Global.BOARD = self

func _on_player_space_1_card_added(card):board_changed.emit(1,card,true)
func _on_player_space_1_card_removed(card):board_changed.emit(1,card,false)
func _on_player_space_2_card_added(card):board_changed.emit(2,card,true)
func _on_player_space_2_card_removed(card):board_changed.emit(2,card,false)
func _on_player_space_3_card_added(card):board_changed.emit(3,card,true)
func _on_player_space_3_card_removed(card):board_changed.emit(3,card,false)
func _on_player_space_4_card_added(card):board_changed.emit(4,card,true)
func _on_player_space_4_card_removed(card):board_changed.emit(4,card,false)
func _on_player_space_5_card_added(card):board_changed.emit(5,card,true)
func _on_player_space_5_card_removed(card):board_changed.emit(5,card,false)


func _on_board_changed(space_index, card, added):
	#if space.is_in_group("play_space"):
		#if added: print(str(card.id) + " Added To " + str(space_index))
		#else: print(str(card.id) + " Removed From " + str(space_index))
	#elif space.is_in_group("opposing_space"):
		pass
