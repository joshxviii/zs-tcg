@tool
@icon("res://assets/icons/card_hand2D.svg")
class_name CardHand2D extends CardSpace2D
func _get_class(): return "CardHand2D"

const SEPERATION_SCALE = 300.0

signal selection_changed(current:Card2D,previous:Card2D)

var can_select=true
var swap_card  : Card2D
var hovered:=false
var prev_selected_card

@onready var selected_card : Card2D:
	set(value):
		if selected_card != value:
			if value:
				value.draggable = true
				value.move_to(Vector2(value.target_pos.x, value.target_pos.y -50),0,value.target_z_layer+10,false)
			if selected_card:
				selected_card.draggable = false
				selected_card.move_to(Vector2(selected_card.target_pos.x, selected_card.target_pos.y),0,selected_card.target_z_layer,false)
			selected_card=value
		else: pass 

func _ready():
	if not Engine.is_editor_hint(): Global.PLAYER_HAND = self


func _on_card_added(card):
	card.selected_move=0
	card.facing_direction = 0
	card.draggable=false
	update_hand()

func _on_card_removed(_card):
	update_hand()
	pass # Replace with function body.

func update_hand():
	can_select=false
	var a = 1.0/cards.size()
	for i in cards.size():
		var card = cards[i]
		var b = (.5*a) + ((i)*a)
		var c = Vector2(global_position.x+SEPERATION_SCALE*(b-.5),global_position.y)
		card.target_z_layer=cards.size()-i
		if !card.dragging:
			card.move_to(c)
			card.z_index=cards.size()-i
		card.target_pos = c
	scale.x = log(6*cards.size()+1)+1
	await get_tree().create_timer(.4).timeout
	can_select=true

func _on_input_event(_viewport, _e, _shape_idx):##Select card hovered over
	pass

func _process(_delta):
	if not Engine.is_editor_hint():
		if Global.can_drag:
			if selected_card:
				var tween = get_tree().create_tween()
				tween.tween_property(selected_card,"rotation",( (get_global_mouse_position().x - selected_card.position.x)/-360 ) ,0.12).set_ease(Tween.EASE_IN)
				#selected_card.rotation=( (get_global_mouse_position().x - selected_card.position.x)/-360 )
			if hovered && cards.size() > 0:
				var select_pos = get_global_mouse_position()-Vector2(cards.size()/2.0,0)
				if !Global.is_dragging:
					if can_select:
						var test_card = cards[0]
						for card in cards:
							if card.target_pos.distance_to(select_pos) < test_card.target_pos.distance_to(select_pos):
								test_card = card
						selected_card = test_card
						selection_changed.emit(selected_card,prev_selected_card)
						var tween = get_tree().create_tween()
						tween.tween_property(selected_card,"rotation",( (get_global_mouse_position().x - position.x)/360 ) ,0.12).set_ease(Tween.EASE_IN)
			if Global.is_dragging && cards.has(Global.dragged_card):
				var dragged_card = swap_card
				swap_card = cards[0]
				for card in cards:
					if card.target_pos.distance_to(get_global_mouse_position()) < swap_card.target_pos.distance_to(get_global_mouse_position()):
						swap_card = card
				if Global.dragged_card != swap_card:
					if cards.has(swap_card):
						
						insert(Global.dragged_card,swap_card,cards)
						update_hand()
							
							#swap(Global.dragged_card,swap_card,cards)
							#update_hand()
		else:selected_card=null

func swap(c1:Card2D,c2:Card2D,a:Array[Card2D]):
	var i = a.find(c1)
	var j = a.find(c2)
	a[i] = c2
	a[j] = c1
	
func insert(c1:Card2D,c2:Card2D,a:Array[Card2D]):
	var i = a.find(c1)
	var j = a.find(c2)
	a.remove_at(i)
	a.insert(j,c1)
	
	#if get_global_mouse_position().x-c2.position.x>0:
		#a.remove_at(i)
		#a.insert(j,c1)
	#else:
		#a.remove_at(i)
		#a.insert(j,c1)

	
	

	

	
	pass
	#var i = a.find(c1)
	#var j = a.find(c2)
	#
	#if j==a.size()-1:
		#a.append(c1)
	#else:
		#a.insert(j,c1)
	#a.remove_at(i)

	
func _on_mouse_entered():
	hovered=true
func _on_mouse_exited():
	hovered=false
	if selected_card:
		selected_card=null


func _on_selection_changed(_current, _previous):
	#print(current)
	#print(previous)
	pass


func _on_card_returned(card):
	
	if card == selected_card:
		card.draggable = true
		card.move_to(Vector2(card.target_pos.x, card.target_pos.y -50),0,card.target_z_layer+10,false)
	else: card.move_to(Vector2(card.target_pos.x, card.target_pos.y),0,card.target_z_layer,false)
	pass # Replace with function body.
