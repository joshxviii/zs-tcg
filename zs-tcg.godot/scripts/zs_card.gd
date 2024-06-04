@icon("res://assets/icons/card2D.svg")
class_name Card2D extends Area2D
func _get_class(): return "Card2D"

#region Variables
signal id_changed
##ID for the Card. this number will determine all attributes of the card such as its name and stats.
@export_range(0,999) var id := 0:
	set(new_id):
		if new_id!=id:
			if new_id<0: id=0
			else: id=new_id
			if get_parent() != null: id_changed.emit()

var inst_id := get_instance_id()

##Data for the card
@onready var attributes : Dictionary = Global.DB.retrive_attributes("cards",id)
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
var started_interaction = false #When the mouse is first pressed while hovering over card set this to true.
##Whether the card is currently been moved or not
var selected_spaces : Array[CardSpace2D]
var selected_space : CardSpace2D:
	set(value):
		if value:
			value.selected = true
			if value.is_in_group("card_hand"):
				selected_spaces.clear()
				add_to_hand(value)
		selected_space=value
		
var owner_space : CardSpace2D
var prev_owner_space : CardSpace2D
#var targeted_space : CardSpace2D
@onready var DEFAULT_SCALE = scale
var offset := -16
@onready var target_pos := position
var target_z_layer := 0

@onready var ui = $animation_rot/card_ui
@onready var front = $animation_rot/card_ui/front
@onready var back = $animation_rot/card_ui/back
@onready var profile = $animation_rot/card_ui/front/profile
@onready var border = $animation_rot/card_ui/front/border
@onready var border_back = $animation_rot/card_ui/front/background
@onready var back_img = $animation_rot/card_ui/back/texture
@onready var shadow = $animation_rot/card_ui/shadow

@onready var name_text = $animation_rot/card_ui/front/name
@onready var type_icon = $animation_rot/card_ui/front/type_icon
@onready var m1_box = $animation_rot/card_ui/front/vbox/m1_box
@onready var m2_box = $animation_rot/card_ui/front/vbox/m2_box
@onready var m1_indicator = $animation_rot/card_ui/front/vbox/m1_box/type_icon
@onready var m2_indicator = $animation_rot/card_ui/front/vbox/m2_box/type_icon
@onready var m1_star = $animation_rot/card_ui/front/vbox/m1_box/select_star
@onready var m2_star = $animation_rot/card_ui/front/vbox/m2_box/select_star
@onready var m1_text = $animation_rot/card_ui/front/vbox/m1_box/move
@onready var m2_text = $animation_rot/card_ui/front/vbox/m2_box/move
@onready var hp_text = $animation_rot/card_ui/front/hp

@onready var animator = $animation_rot/card_ui/animation_player

@onready var atk_animator : AnimationPlayer = $attack_animations

##Health variables
var max_health : int = 0
@onready var current_health : int:
	set(value):
		
		if value<current_health:
			atk_animator.play("effect/hit")
		
		if value > max_health:
			current_health = max_health
		elif value <= 0:
			current_health = 0
			die()
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
	
	$animation_rot/card_ui/ID.text = str("%03d" % id)
	
	if attributes.has("name"): 
		attributes = Global.DB.retrive_attributes("cards",id)
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
		border_back.texture = Global.image_load("res://assets/textures/cards/card_layers/border_background_" + "0" + ".png")
		back_img.texture = Global.image_load("res://assets/textures/cards/card_layers/back_" + "0" + ".png")
		
	if attributes.has("move_1"):
		m1_attributes = Global.DB.retrive_attributes("moves",attributes["move_1"])
		m1_text.text = m1_attributes["name"]
		m1_indicator.frame = m1_attributes["type"]
		m1_text.visible_characters = 13
		current_move_info=m1_attributes
	else:
		m1_attributes = {}
		m1_box.visible = false

	if attributes.has("move_2"):
		m2_attributes = Global.DB.retrive_attributes("moves",attributes["move_2"])
		m2_text.text = m2_attributes["name"]
		m2_indicator.frame = m2_attributes["type"]
		m2_text.visible_characters = 13
	else: 
		m2_attributes = {}
		m2_box.visible = false
#endregion

#region Dragging/Moving Card

func _process(_delta):
	if dragging: process_drag()

func _on_input_event(_viewport, e, _shape_idx):
	if Global.can_drag:
		#pressed Left Mouse Button
		if e is InputEventMouseButton and e.button_mask==1 and !e.double_click and e.button_index==1:
			started_interaction = true
		#moved Mouse
		if e is InputEventMouseMotion and e.pressure>=1.0 and e.button_mask==1 and e.velocity.length()>8.0:
			if !Global.is_dragging && draggable && started_interaction:
				dragging = true
				started_interaction = false
				var tween = get_tree().create_tween()
				tween.parallel().tween_property(shadow,"position",Vector2(14,23),0.06).set_ease(Tween.EASE_IN)
				tween.parallel().tween_property(self,"global_position",( Vector2(get_global_mouse_position().x+90, get_global_mouse_position().y)),0.12).set_ease(Tween.EASE_IN)
				tween.parallel().tween_property(self,"rotation",( 1 ) ,0.12).set_ease(Tween.EASE_IN)
				#shadow.position=Vector2(14,23)
				#global_position=( Vector2(get_global_mouse_position().x+90, get_global_mouse_position().y))
				#rotation=1
				
		#realeased Left Mouse Button
		if e is InputEventMouseButton and e.button_mask==0 and !e.double_click and e.button_index==1:
			if !Global.is_dragging && Global.can_drag && started_interaction:
				if owner_space:
					if owner_space.is_in_group("play_space") && Global.GUI:
						if Global.GUI.move_info:
							if Global.GUI.move_info.card==self: Global.GUI.close_move_info()
							else:Global.GUI.create_move_info(self)
						else:Global.GUI.create_move_info(self)
					#elif owner_space.is_in_group("card_deck"):
						#dragging = true
						#add_to_hand()

		#if e is InputEventMouseButton and e.pressed and !e.double_click and e.button_mask==2:
			#if owner_space && Global.GUI:
				#if owner_space.is_in_group("play_space"):
					#if Global.GUI.move_info:
						#if Global.GUI.move_info.card==self: Global.GUI.close_move_info()
						#else:Global.GUI.create_move_info(self)
					#else:Global.GUI.create_move_info(self)
			
func _input(e):
	if Global.can_drag:
		if e is InputEventMouseButton and !e.pressed || e is InputEventMouseMotion and e.pressure==0.0:##Release mouse button
			if dragging: release()

func release():
	selected_spaces.clear()
	
	dragging = false
	
	await get_tree().create_timer(0.05).timeout # release buffer
	
	started_interaction = false
	draggable=false
	
	var tween = get_tree().create_tween()
	tween.tween_property(shadow,"position",Vector2(3,2),0.06).set_ease(Tween.EASE_IN)
	#shadow.position = Vector2(3,2)
	
	#if owner_space: owner_space.input_pickable=true
	if selected_space && selected_space!=owner_space:
		if selected_space.is_in_group("play_space"): play_on_space(selected_space)
	elif owner_space: owner_space.card_return(self)
	else:
		tween.tween_property(self,"rotation",0,0.3).set_ease(Tween.EASE_IN)
		#rotation=0
		
		await tween.finished
		draggable=true

func _on_facing_changed():
	if get_parent() != null:
		if is_facing_down: animator.play("front_to_back")
		else: animator.play("back_to_front")

func move_to(pos:Vector2,rot:=0,z_layer:=target_z_layer,wait:=true,time:=.3):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(self,"position",pos,time).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self,"rotation",rot,time).set_ease(Tween.EASE_OUT)
	
	#position=pos
	#rotation=rot
	
	if wait:
		await tween.finished
		z_index = z_layer
	else:
		z_index = z_layer
		pass

func process_drag():
	z_index = target_z_layer+100
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self,"global_position",( Vector2(get_global_mouse_position().x, get_global_mouse_position().y - offset)),0.12).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self,"rotation",( (get_global_mouse_position().x - position.x)/360 ) ,0.12).set_ease(Tween.EASE_IN)
	#global_position=get_global_mouse_position()
	
	if selected_spaces.size() > 0:
		var temp = selected_spaces[0]
		for space in selected_spaces:
			space.selected = false
			if space.global_position.distance_to(get_global_mouse_position()) < temp.global_position.distance_to(get_global_mouse_position()):
				temp = space
		selected_space=temp

func _on_body_entered(space): # added spaces to a list of selected spaces
	if space != owner_space:
		if space.is_in_group("card_deck"):
			if space.can_add_to: selected_spaces.append(space)
		elif space.has_open_space:
			selected_spaces.append(space)
		elif space.is_in_group("play_space") && space.cards.size()>0:
			if space.can_swap && space.cards[0].draggable: selected_spaces.append(space)
		
		#if space.is_in_group("play_space") && !space.has_open_space && space.cards.size()>0:
			#if space.can_swap && space.cards[0].draggable:
				#selected_spaces.append(space)
		#elif space.is_in_group("card_deck"):
			#if space.can_add_to: selected_spaces.append(space)
		##elif space.is_in_group("card_hand"): pass
		#elif space.is_in_group("card_hand"):
			#if space selected_spaces.append(space)
		#elif space.has_open_space:
			#selected_spaces.append(space)

func _on_body_exited(space):
	selected_spaces.erase(space)
	space.selected = false
	selected_space = null
#endregion

func play_on_space(space : CardPlaySpace2D):
	if owner_space.is_in_group("play_space"): space.add(self)
	elif !space.has_open_space && space.can_swap: space.add(self)
	elif Global.PLAYAREA.try_take_turn(): space.add(self)
	elif owner_space: owner_space.card_return(self)

func add_to_hand(hand : CardHand2D) -> bool:
	if hand.has_open_space:
		if owner_space.is_in_group("card_deck") and Global.PLAYAREA.try_take_turn():
			hand.add(self)
			facing_direction = 0
			return true
		elif owner_space.is_in_group("play_space"):
			Global.PLAYAREA.turn_points+=1
			hand.add(self)
			return true
		else:
			release()
			return false
	else:
		Global.GUI.create_float_text(get_global_mouse_position(),"FULL HAND!")
		release()
		return false

func attack_anim(target_pos:Vector2,anim:String):
	atk_animator.target_position = target_pos
	atk_animator.play(anim)
	await atk_animator.animation_finished

func attack_directly():pass

func attack():
	
	var anim = "attack/default"
	
	await attack_anim(Vector2.UP,anim)
	
	#damage all the cards
	for target : CardSpace2D in owner_space.targets:
		if target.cards.size()>0:
			for card in target.cards:
				card.current_health-=current_move_info["power"]
				Global.card_updated.emit(card)
		else:
			attack_directly()
	
	#Global.card_attacked.emit(self,owner_space,current_move_info["power"],anim)
	
	#if target.is_in_group("opposing_space"):
		#if target.cards.size()<1:
			#pass#attack directly
		#else:
			#target_card = target.cards[0]
			#card.attack(target_card)
			#target_card.current_health-=card.current_move_info["power"]
	#elif target.is_in_group("play_space"):
		#if target.cards.size()<1:continue
		#target_card = target.cards[0]

func die(death_animation:="death_1"):
	if  Global.PLAYAREA.all_cards.has(inst_id): Global.PLAYAREA.all_cards.erase(inst_id)
	if owner_space: owner_space.remove(self)
	
	draggable=false
	
	animator.play(death_animation)
	await animator.animation_finished
	
	queue_free()
