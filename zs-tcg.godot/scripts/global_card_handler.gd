extends Node

var db := DataBaseHandler.new()

var is_dragging := false
var dragged_card : Card2D

var PLAYER_HAND : CardHand2D



func _ready():
	InputMap.add_action("click")
	var ev = InputEventMouseButton.new()
	ev.button_index = MOUSE_BUTTON_LEFT
	InputMap.action_add_event("click", ev)
