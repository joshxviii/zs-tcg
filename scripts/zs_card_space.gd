@tool
@icon("res://assets/icons/card_space2D.svg")
class_name CardSpace2D extends StaticBody2D
func _get_class(): return "CardSpace2D"

@export_color_no_alpha var highlight_color := Color.LIGHT_BLUE:
	set(value):
		modulate = Color(value,0.5)
		highlight_color = value

@export var disabled:= false
@export var MAX_CARDS := 1

@onready var anim = $animator 

var space_pos:=Vector2.ZERO #used for targeting and tracking spaces on board
#var space_index:=0 #only used for tracking spaces on board/multiplayer

enum {
	ADDED,
	REMOVED,
	KILLED
}

var selected := false:
	set(value):
		if value && has_open_space:
			#var tween = get_tree().create_tween()
			#tween.tween_property($area,"modulate",Color(highlight_color,1),0.0).set_ease(Tween.EASE_IN)
			modulate=Color(highlight_color,1.0)
		else:
			#var tween = get_tree().create_tween()
			#tween.tween_property($area,"modulate",Color(highlight_color,0.5),0.0).set_ease(Tween.EASE_IN)
			modulate=Color(highlight_color,0.5)
		selected = value

@onready var open_position := global_position

signal card_returned(card:Card2D)

signal card_added(card:Card2D)
signal card_removed(card:Card2D)
var cards : Array[Card2D] = []

signal space_changed(space:CardSpace2D)

var has_open_space:=true:
	get:
		if cards.size()<MAX_CARDS:
			return true
		else:
			return false

func add(card:Card2D):
	#print("added " + _get_class())
	if card.owner_space:
		if card.owner_space!=self: card.owner_space.remove(card)
	cards.append(card)
	card.owner_space = self
	card_added.emit(card)
	space_changed.emit(self,card,space_pos,ADDED)
	#var tween = get_tree().create_tween()
	#tween.tween_property($area,"modulate",Color(highlight_color,0.5),0.0).set_ease(Tween.EASE_IN)
	modulate=Color(highlight_color,0.5)
	pass
	
func remove(card:Card2D):
	#print("removed " + _get_class())
	card.prev_owner_space = self
	cards.erase(card)
	card_removed.emit(card)
	if card.current_health>0: space_changed.emit(self,card,space_pos,REMOVED)
	else: space_changed.emit(self,card,space_pos,KILLED)

func card_return(card:Card2D):
	card_returned.emit(card)
