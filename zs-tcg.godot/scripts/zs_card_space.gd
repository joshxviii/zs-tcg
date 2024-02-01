@tool
@icon("res://assets/icons/card_space2D.svg")
class_name CardSpace2D extends StaticBody2D

@export_color_no_alpha var highlight_color := Color.LIGHT_BLUE:
	set(value):
		$area.modulate = Color(value,0.5)
		highlight_color = value

@export var disabled:= false
@export var MAX_CARDS := 1

var selected := false:
	set(value):
		if value && has_open_space:
			var tween = get_tree().create_tween()
			tween.tween_property($area,"modulate",Color(highlight_color,1),0.0).set_ease(Tween.EASE_IN)
		else:
			var tween = get_tree().create_tween()
			tween.tween_property($area,"modulate",Color(highlight_color,0.5),0.0).set_ease(Tween.EASE_IN)
		selected = value

@onready var open_position := global_position

signal card_returned(card:Card2D)

signal card_added(card:Card2D)
signal card_removed(card:Card2D)
var cards : Array[Card2D] = []

var has_open_space:=true:
	get:
		if cards.size()<MAX_CARDS:
			return true
		else:
			return false

func add(card:Card2D):
	if card.owner_space:
		if card.owner_space!=self: card.owner_space.remove(card)
	cards.append(card)
	card.owner_space = self
	card_added.emit(card)
	var tween = get_tree().create_tween()
	tween.tween_property($area,"modulate",Color(highlight_color,0.5),0.0).set_ease(Tween.EASE_IN)
	pass
	
func remove(card:Card2D):
	card.prev_owner_space = self
	cards.erase(card)
	card_removed.emit(card)

func card_return(card:Card2D):
	card_returned.emit(card)
