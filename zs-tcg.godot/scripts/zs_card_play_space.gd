@icon("res://assets/icons/card_play_space2D.svg")
class_name CardPlaySpace2D extends CardSpace2D

const target_arrow_path = preload("res://objects/ui/target_arrow.tscn")
const target_selector_path = preload("res://objects/ui/target_point.tscn")


##Cards placed in this space will be face down
@export var lock_space := false
@export var face_down_space := false
@export var can_swap := true

@onready var target_getter = $target_getter
@onready var target_selector_box = $target_getter/targetting_nodes
@onready var target_arrows_box = $target_arrows

var locked:=false:
	set(value):
		$lock.visible=value
		locked = value

var default_target : CardSpace2D
var targets : Array[CardSpace2D]


signal target_mode_changed(mode)
var target_mode : int = -1:
	set(value):
		target_mode_changed.emit(value)
		target_mode=value

func _ready():
	pass

func _on_card_added(card):
	if cards.size()>MAX_CARDS:
		if can_swap:
			if cards[0].draggable: swap()
		else:
			push_error("MAX CARDS exceeded.")
	
	if card.selected_move == 0:
		if card.m1_attributes.has("target_mode"):
			card.selected_move=1
			card.current_move_info=card.m1_attributes
	if card.current_move_info.has("target_mode"):
		target_mode = int(card.current_move_info["target_mode"])
		#card.targeted_space = default_target
		targets.append(default_target)
	
	card.target_z_layer=0
	card.move_to(self.global_position,0)
	disabled = true

	card.target_pos = global_position
	if face_down_space: card.facing_direction = 1
	else: card.facing_direction = 0
	if !lock_space:
		card.draggable=true
	else:locked=true
	refresh_target_selectors()
	highlight_arrows(true)

func _on_card_removed(_card):
	target_mode = -1
	refresh_target_selectors()
	Global.PLAYAREA.turn_points += 1
	if cards.size()<=0: locked=false
	pass # Replace with function body.

func swap():
	if cards.size()>1:
		if cards[-1].prev_owner_space:
			cards[0].move_to(cards[-1].prev_owner_space.global_position)
			cards[-1].prev_owner_space.add(cards[0])
		else: remove(cards[0])

func _on_card_returned(card):
	card.move_to(card.target_pos)
	if !lock_space: card.draggable=true
	pass # Replace with function body.


#func _on_opposing_space_getter_body_entered(body):
	#if body.is_in_group("opposing_space"):
		#default_target = body
	#pass # Replace with function body.


func refresh_target_selectors():
	target_getter.monitoring = false
	for c in target_selector_box.get_children():
		c.queue_free()
	target_getter.monitoring = true
	targets.clear()
	update_target_arrows()
func update_target_arrows():
	for i in target_arrows_box.get_children():
		i.queue_free()
	for space in targets:
		var target_arrow = target_arrow_path.instantiate()
		target_arrows_box.add_child(target_arrow)
		target_arrow.global_position = global_position
		target_arrow.add_point(Vector2(0.0,0.0),0)
		target_arrow.add_point(space.global_position-global_position,1)

func _on_target_getter_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	match local_shape_index:
		0: #get default target
			if target_mode == Global.FOE || target_mode == Global.FOE_ALL || target_mode == Global.ALL:
				default_target=body
			else:
				default_target=self
		1:
			match target_mode:
				Global.SELF:
					#target_box.modulate = Color.GREEN
					if body == self: create_target(body)
				Global.FOE:
					#target_box.modulate = Color.RED
					if body.is_in_group("opposing_space"): create_target(body)
				Global.ALLY:
					#target_box.modulate = Color.GREEN
					if body.is_in_group("play_space"): create_target(body)
				Global.FOE_ALL:
					#target_box.modulate = Color.RED
					if body.is_in_group("opposing_space"): create_target(body)
				Global.ALLY_ALL:
					#target_box.modulate = Color.RED
					if body.is_in_group("play_space"): create_target(body)
				Global.ALL:
					#target_box.modulate = Color.RED
					if body.is_in_group("play_space") || body.is_in_group("opposing_space"): create_target(body)
				Global.ANY:
					#target_box.modulate = Color.RED
					if body.is_in_group("play_space") || body.is_in_group("opposing_space"): create_target(body)
				_:
					pass 
	pass

func _on_target_mode_changed(mode):
	if target_mode == Global.FOE || target_mode == Global.FOE_ALL || target_mode == Global.ALL:
		targets.append(default_target)
	else:
		targets.append(self)
	refresh_target_selectors()

var target_selectors_button_group = ButtonGroup.new()

func create_target(body,_disable:=false):
	var target_selector = target_selector_path.instantiate()
	target_selector_box.add_child(target_selector)
	target_selector.space = body
	target_selector.global_position = body.global_position
	target_selector.btn.button_group=target_selectors_button_group
	if target_mode==Global.ALL||target_mode==Global.FOE_ALL||target_mode==Global.ALLY_ALL:
		target_selector.btn.mouse_filter = 2
		target_selector.btn.button_group = null
		target_selector.btn.disabled = true
		target_selector.btn.button_pressed = true
	elif body == default_target: target_selector.btn.button_pressed=true


func _on_mouse_entered(_shape_idx:int):
	highlight_arrows(true)
	pass # Replace with function body.

func _on_mouse_exited(_shape_idx:int):
	highlight_arrows(false)
	pass # Replace with function body.

func highlight_arrows(b:bool):
	if b:
		for i in target_arrows_box.get_children():
			var tween = create_tween()
			tween.tween_property(i,"modulate",Color(i.modulate,0.8),.3)
	else:
		for i in target_arrows_box.get_children():
			var tween = create_tween()
			tween.tween_property(i,"modulate",Color(i.modulate,i.ALPHA),.3)
