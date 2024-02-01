@icon("res://assets/icons/card_deck2D.svg")
class_name CardDeck2D extends CardSpace2D

var card_path = "res://objects/zs_card.tscn"

##Whether or not you can move cards into the deck
@export var can_add_to := false
@export var straight_to_hand := false

@export var randomized := false

signal deck_changed

##cards in this deck by their id numbers
@export var deck : Array[int] = []

var top:Card2D

const DECK_SPERATION := 5

func _ready():
	Global.PLAYER_DECK = self
	check_deck()
		
func check_deck():
	if cards.size() < MAX_CARDS && deck.size() > 0: generate_card()
	elif deck.size() < 1 && randomized: generate_random_card()
	for i in cards.size():
		var card = cards[i]
		var offset = DECK_SPERATION*(cards.size()-1-i)
		#print(card.id)
		card.z_index=cards.size()-i
		var tween = get_tree().create_tween()
		tween.tween_property(card,"position",Vector2(global_position.x,  global_position.y - offset),0.3).set_ease(Tween.EASE_IN)
		card.target_pos = card.position
		card.target_z_layer=cards.size()-i
		#card.modulate.a = i/(VISIBLE_DECK_SIZE-1.0)+.1
#		if i < VISIBLE_DECK_SIZE:
#			var tween = create_tween()
#
#			#tween.tween_property(card,"position",Vector2(global_position.x,  global_position.y + offset ),.2).set_ease(Tween.EASE_IN)
#		else: card.position = Vector2(global_position.x,  global_position.y + offset2)
		#card.position = Vector2(position.x,  position.y + offset )
		#print(visible_deck[-(i+1)].id)
	if cards.size() > 0:
		open_position = cards[0].position
		if !straight_to_hand:
			cards[0].input_pickable = true
			cards[0].draggable = true
		
func generate_card():
	var new_card = load(card_path).instantiate() 
	get_parent().call_deferred("add_child",new_card)
	new_card.id = deck[0]
	new_card.draggable = false
	new_card.position = position
	new_card.owner_space = self
	new_card.z_index=-1
	new_card.facing_direction = 1
	cards.append(new_card)
	deck.remove_at(0)
	check_deck()
	
func generate_random_card():
	var max_id = Global.DB.Database["cards"].size()
	deck.append(randi_range(0,max_id-1))
	check_deck()

func _on_card_added(card):
	card.move_to(self.global_position)
	card.z_index=-1
	card.facing_direction = 1
	card.draggable = false
	await get_tree().create_timer(.3).timeout
	deck.append(card.id)
	remove(card)
	card.queue_free()
	check_deck()

func _on_card_removed(_card):
	check_deck()
	pass # Replace with function body.

func auto_add_to_hand(amount):
	for i in amount:
		await get_tree().create_timer(0.1).timeout
		Global.PLAYER_HAND.add(cards[0])

func _on_input_event(_viewport, e, _shape_idx):
	if e is InputEventMouseButton and e.pressed and e.button_mask==1 and !e.double_click:
		if straight_to_hand && Global.PLAYER_HAND && cards.size() > 0:
			if Global.PLAYER_HAND.has_open_space && cards.size() <= MAX_CARDS:
				Global.PLAYER_HAND.add(cards[0])


func _on_card_returned(card):
	card.move_to(card.target_pos)
	card.z_index = card.target_z_layer
	card.facing_direction = 1
	check_deck()
	pass # Replace with function body.
