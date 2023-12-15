extends UIWindow

const target_arrow_path = preload("res://objects/ui/target_arrow.tscn")
const target_point_path = preload("res://objects/ui/target_point.tscn")


@onready var m1 = $moves/move_1/name
@onready var m2 = $moves/move_2/name

@onready var info_name = $moves/name
@onready var m1_power = $moves/move_1/type/power
@onready var m2_power = $moves/move_2/type/power
@onready var m1_icon = $moves/move_1/type/icon
@onready var m2_icon = $moves/move_2/type/icon
@onready var m1_name = $moves/move_1/name
@onready var m2_name = $moves/move_2/name

@onready var m1_box = $moves/move_1
@onready var m2_box = $moves/move_2

@onready var target_getter = $target_getter
@onready var target_box = $targetting_nodes

var target_point
var target_arrow
var target_space : CardSpace2D
var card : Card2D
var focus_out
var default_target : CardSpace2D

var target_mode : int

func _ready():
	target_space = card.targeted_space
	open()
	update_info()
	pass

signal target_mode_changed(mode)
func _on_move_1_button_down(button_pressed):
	if m1.button_pressed:
		if card.current_move_info.size() > 0:
			target_mode = int(card.current_move_info["target_mode"])
			if target_mode != int(card.m1_attributes["target_mode"]): target_mode_changed.emit(int(card.m1_attributes["target_mode"]))
			card.selected_move = 1
func _on_move_2_button_down(button_pressed):
	if m2.button_pressed:
		if card.current_move_info.size() > 0:
			target_mode = int(card.current_move_info["target_mode"])
			if target_mode != int(card.m2_attributes["target_mode"]): target_mode_changed.emit(int(card.m2_attributes["target_mode"]))
			card.selected_move = 2
func _on_m1_icon_pressed():
	m1.button_pressed=!m1.button_pressed
func _on_m2_icon_pressed():
	m2.button_pressed=!m2.button_pressed


func update_info():
	target_getter.global_position = card.global_position
	refresh_target_mode()
	match card.selected_move:
		1:
			m1_name.button_pressed=true
		2:
			m2_name.button_pressed=true
		_:
			pass
	if card.attributes.size() > 0:
		info_name.text = card.attributes["name"]
	if card.m1_attributes.size() > 0:
		m1_name.text = card.m1_attributes["name"]
		m1_power.text = "+" + str(card.m1_attributes["power"])
		m1_power.modulate=Global.get_type_color(card.m1_attributes["type"])
		m1_icon.texture_normal = TextureHandler.new().get_texture("res://assets/textures/ui/type_indicator_"+str(card.m1_attributes["type"])+".png")
	else: m1_box.visible = false
	if card.m2_attributes.size() > 0:
		m2_name.text = card.m2_attributes["name"]
		m2_power.text =  "+" + str(card.m2_attributes["power"])
		m2_power.modulate=Global.get_type_color(card.m2_attributes["type"])
		m2_icon.texture_normal = TextureHandler.new().get_texture("res://assets/textures/ui/type_indicator_"+str(card.m2_attributes["type"])+".png")
	else: m2_box.visible = false

func update_targets():
	target_arrow.clear_points()
	target_arrow.add_point(Vector2(0.0,0.0),0)
	target_arrow.add_point(target_space.global_position-target_arrow.global_position,1)
	pass

func open():
	pass
	
func close():
	super.close()
	if m1.button_pressed:card.selected_move = 1
	elif m2.button_pressed:card.selected_move = 2
	else: card.selected_move = 0
	if target_space: card.targeted_space = target_space
	if target_arrow: target_arrow.queue_free()
	queue_free()

func refresh_target_mode():
	target_getter.monitoring = false
	for c in target_box.get_children():
		c.queue_free()
	target_arrow = target_arrow_path.instantiate()
	target_box.add_child(target_arrow)
	target_arrow.global_position = card.global_position
	target_getter.monitoring = true
	await target_getter.body_shape_entered
	if target_space: update_targets()
	
#func create_target_arrow():
#	pass
	
func create_target(body):
	target_point = target_point_path.instantiate()
	target_box.add_child(target_point)
	target_point.space = body
	target_point.global_position = body.global_position

func _on_target_getter_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	match target_mode:
		Global.ATTACK:
			target_arrow.modulate = Color.RED
			if body.is_in_group("opposing_space"): create_target(body)
		Global.SUPPORT:
			target_arrow.modulate = Color.GREEN
			if body.is_in_group("play_space"): create_target(body)
		Global.SUPPORT_SELF:
			target_arrow.modulate = Color.GREEN
		Global.ATTACK_ALL:
			target_arrow.modulate = Color.RED
			if body.is_in_group("play_space") || body.is_in_group("opposing_space"): create_target(body)
		_:
			pass

func _on_target_mode_changed(mode):
	target_mode = mode
	match target_mode:
		Global.ATTACK:
			target_space = card.owner_space.default_target
		Global.SUPPORT:
			target_space = card.owner_space
		Global.SUPPORT_SELF:
			target_space = card.owner_space
		Global.ATTACK_ALL:
			target_space = card.owner_space.default_target
		_:
			pass
	refresh_target_mode()
