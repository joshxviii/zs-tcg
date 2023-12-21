@icon("res://assets/icons/card2D.svg")
class_name Card2D extends Area2D

#region Variables
signal id_changed
##ID for the Card. this number will determine all attributes of the card such as its name and stats.
@export_range(0,999) var id := 0:
	set(new_id):
		if new_id!=id:
			if new_id<0: id=0
			else: id=new_id
			if get_parent() != null: id_changed.emit()

##Data for the card
@onready var attributes : Dictionary = Global.db.retrive_attributes("cards",id)
@onready var m1_attributes : Dictionary = {}
@onready var m2_attributes : Dictionary = {}
var is_in_deck := false

var current_move_info:Dictionary
@onready var selected_move:=0:
	set(value):
		selected_move=value
		match selected_move:
			1:
				m1_star.visible=true
				m2_star.visible=false
				current_move_info=m1_attributes
			2:
				m1_star.visible=false
				m2_star.visible=true
				current_move_info=m2_attributes
			0:
				m1_star.visible=false
				m2_star.visible=false
				current_move_info={"target_mode":-1}


signal facing_changed
##Whether the card is acing down or not
@export_enum("Up","Down") var facing_direction:=0:
	set(value):
		if facing_direction != value:
			facing_direction = value
			facing_changed.emit()
var is_facing_down:
	get:
		if facing_direction==1: return true
		else: return false

##Mouse dragging##
##Whether you can move the card or not
var draggable:=true:
	set(value):
		#input_pickable = value
		draggable = value
var dragging:=false:
	set(value):
		Global.dragged_card = self
		Global.is_dragging = value
		dragging = value
##Whether the card is currently been moved or not
var selected_spaces : Array[CardSpace2D]
var selected_space : CardSpace2D
var owner_space : CardSpace2D
var prev_owner_space : CardSpace2D
var targeted_space : CardSpace2D
@onready var DEFAULT_SCALE = scale
var offset := -16
@onready var target_pos := position
var target_z_layer := 0

@onready var ui = $card_ui
@onready var front = $card_ui/front
@onready var back = $card_ui/back
@onready var profile = $card_ui/front/profile
@onready var border = $card_ui/front/border
@onready var border_back = $card_ui/front/background
@onready var back_img = $card_ui/back/texture
@onready var shadow = $card_ui/shadow

@onready var name_text = $card_ui/front/name
@onready var type_icon = $card_ui/front/type_icon
@onready var m1_box = $card_ui/front/vbox/m1_box
@onready var m2_box = $card_ui/front/vbox/m2_box
@onready var m1_indicator = $card_ui/front/vbox/m1_box/type_icon
@onready var m2_indicator = $card_ui/front/vbox/m2_box/type_icon
@onready var m1_star = $card_ui/front/vbox/m1_box/select_star
@onready var m2_star = $card_ui/front/vbox/m2_box/select_star
@onready var m1_text = $card_ui/front/vbox/m1_box/move
@onready var m2_text = $card_ui/front/vbox/m2_box/move
@onready var hp_text = $card_ui/front/hp

@onready var animator = $card_ui/animation_player

##Health variables
var max_health : int = 0
@onready var current_health : int:
	set(value):
		if value < 0:
			current_health = 0
		elif value > max_health:
			current_health = max_health
		else:
			current_health = value
		hp_text.text = str(current_health)
#endregion

#region Load Card
func _ready():
	load_attributes()
	if is_facing_down:
		back.visible = true

func _on_id_changed():
	load_attributes()
	

func load_attributes():##Use id number to fill in all the attributes
	
	$card_ui/ID.text = str("%03d" % id)
	
	if attributes.has("name"): 
		attributes = Global.db.retrive_attributes("cards",id)
		name_text.text = attributes["name"]
		if name_text.text.length() > 11:
			var size = clamp(13 - (name_text.text.length() - 10),9,13)
			name_text.add_theme_font_size_override("font_size",size)
		else: name_text.add_theme_font_size_override("font_size",13)

		type_icon.frame = attributes["type"]
		max_health = attributes["hp"]
		current_health = max_health
		
		profile.texture = Global.image_load("res://assets/textures/cards/profiles/" + str(id) + ".png")
		border.texture = Global.image_load("res://assets/textures/cards/card_layers/border_" + str(attributes["pack_id"]) + ".png")
		border_back.texture = Global.image_load("res://assets/textures/cards/card_layers/border_background_" + str(attributes["pack_id"]) + ".png")
		back_img.texture = Global.image_load("res://assets/textures/cards/card_layers/back_" + str(attributes["pack_id"]) + ".png")
		
	if attributes.has("move_1"):
		m1_attributes = Global.db.retrive_attributes("moves",attributes["move_1"])
		m1_text.text = m1_attributes["name"]
		m1_indicator.frame = m1_attributes["type"]
		m1_text.visible_characters = 13
		current_move_info=m1_attributes
	else:
		m1_attributes = {}
		m1_box.visible = false

	if attributes.has("move_2"):
		m2_attributes = Global.db.retrive_attributes("moves",attributes["move_2"])
		m2_text.text = m2_attributes["name"]
		m2_indicator.frame = m2_attributes["type"]
		m2_text.visible_characters = 13
	else: 
		m2_attributes = {}
		m2_box.visible = false
#endregion

#region Dragging/Moving Card
func move_to(pos:Vector2,rot:=0,z_layer:=target_z_layer,wait:=true,time:=.2):
	var tween = create_tween()
	tween.parallel().tween_property(self,"position",pos,time).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self,"rotation",rot,time).set_ease(Tween.EASE_IN)
	if wait:
		await tween.finished
		z_index = z_layer
	else:
		z_index = z_layer
		pass

func _on_facing_changed():
	if get_parent() != null:
		if is_facing_down: animator.play("front_to_back")
		else: animator.play("back_to_front")

func _process(_delta):
	if dragging:
		z_index = target_z_layer+100
		var tween = get_tree().create_tween()
		tween.parallel().tween_property(self,"global_position",( Vector2(get_global_mouse_position().x, get_global_mouse_position().y - offset)),0.12).set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(self,"rotation",( (get_global_mouse_position().x - position.x)/360 ) ,0.12).set_ease(Tween.EASE_IN)
		if selected_spaces.size() > 0:
			selected_space = selected_spaces[0]
			for space in selected_spaces:
				space.selected = false
				if space.position.distance_to(position) < selected_space.position.distance_to(position):
					selected_space = space
			selected_space.selected = true
func _on_input_event(_viewport, e, _shape_idx):
	if e is InputEventMouseButton and e.pressed and !e.double_click:##Press mouse button
		match e.button_mask:
			1:
				if !Global.is_dragging && draggable:
					dragging = true
					var tween = get_tree().create_tween()
					tween.parallel().tween_property(shadow,"position",Vector2(14,23),0.06).set_ease(Tween.EASE_IN)
					tween.parallel().tween_property(self,"global_position",( Vector2(get_global_mouse_position().x+90, get_global_mouse_position().y)),0.12).set_ease(Tween.EASE_IN)
					tween.parallel().tween_property(self,"rotation",( 1 ) ,0.12).set_ease(Tween.EASE_IN)
					if owner_space:
						if owner_space.is_in_group("card_deck"):
							if Global.PLAYER_HAND.has_open_space:
								Global.PLAYER_HAND.add(self)
								facing_direction = 0
							else:
								Global.GUI.create_float_text(get_global_mouse_position(),"FULL HAND!")
								release()
			2:
				if owner_space && Global.GUI:
					if owner_space.is_in_group("play_space"):
						Global.GUI.create_move_info(self)

func _input(e):
	if e is InputEventMouseButton and !e.pressed:##Release mouse button
		if dragging: release()

func release():
	draggable=false
	dragging = false
	var tween = get_tree().create_tween()
	tween.tween_property(shadow,"position",Vector2(3,2),0.06).set_ease(Tween.EASE_IN)
	#shadow.position = Vector2(3,2)
	#if owner_space: owner_space.input_pickable=true
	if selected_space && selected_space!=owner_space:
		selected_space.add(self)
	elif owner_space:
		owner_space.card_return(self)
	else:
		tween.tween_property(self,"rotation",0,0.3).set_ease(Tween.EASE_IN)
		await tween.finished
		draggable=true

func _on_body_entered(space):
	if space != owner_space:
		if space.is_in_group("play_space") && !space.has_open_space && space.cards.size()>0:
			if space.can_swap && space.cards[0].draggable:
				selected_spaces.append(space)
		elif space.is_in_group("card_deck"):
			if space.can_add_to: selected_spaces.append(space)
		#elif space.is_in_group("card_hand"): pass
		elif space.has_open_space: selected_spaces.append(space)

func _on_body_exited(space):
	selected_spaces.erase(space)
	space.selected = false
	selected_space = null
#endregion
