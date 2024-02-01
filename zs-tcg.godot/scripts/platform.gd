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

func _on_player_space_1_card_added(card):
	if Global.PLAYAREA.turn_points<=0:card.prev_owner_space.add(card)
	else:
		board_changed.emit(1,card,true)
	Global.PLAYAREA.turn_points -= 1
func _on_player_space_1_card_removed(card):board_changed.emit(1,card,false)
func _on_player_space_2_card_added(card):
	if Global.PLAYAREA.turn_points<=0:card.prev_owner_space.add(card)
	else:
		board_changed.emit(2,card,true)
	Global.PLAYAREA.turn_points -= 1
func _on_player_space_2_card_removed(card):board_changed.emit(2,card,false)
func _on_player_space_3_card_added(card):
	if Global.PLAYAREA.turn_points<=0:card.prev_owner_space.add(card)
	else:
		board_changed.emit(3,card,true)
	Global.PLAYAREA.turn_points -= 1
func _on_player_space_3_card_removed(card):board_changed.emit(3,card,false)
func _on_player_space_4_card_added(card):
	if Global.PLAYAREA.turn_points<=0:card.prev_owner_space.add(card)
	else:
		board_changed.emit(4,card,true)
	Global.PLAYAREA.turn_points -= 1
func _on_player_space_4_card_removed(card):board_changed.emit(4,card,false)
func _on_player_space_5_card_added(card):
	if Global.PLAYAREA.turn_points<=0:card.prev_owner_space.add(card)
	else:
		board_changed.emit(5,card,true)
	Global.PLAYAREA.turn_points -= 1
func _on_player_space_5_card_removed(card):board_changed.emit(5,card,false)


func lock_spaces():
	if player_space_1.cards.size()>0: player_space_1.cards[0].draggable=false;player_space_1.locked=true
	if player_space_2.cards.size()>0: player_space_2.cards[0].draggable=false;player_space_2.locked=true
	if player_space_3.cards.size()>0: player_space_3.cards[0].draggable=false;player_space_3.locked=true
	if player_space_4.cards.size()>0: player_space_4.cards[0].draggable=false;player_space_4.locked=true
	if player_space_5.cards.size()>0: player_space_5.cards[0].draggable=false;player_space_5.locked=true

func flip_opponent_cards():
	if space_1.cards.size()>0: space_1.cards[0].facing_direction=0
	if space_2.cards.size()>0: space_2.cards[0].facing_direction=0
	if space_3.cards.size()>0: space_3.cards[0].facing_direction=0
	if space_4.cards.size()>0: space_4.cards[0].facing_direction=0
	if space_5.cards.size()>0: space_5.cards[0].facing_direction=0
