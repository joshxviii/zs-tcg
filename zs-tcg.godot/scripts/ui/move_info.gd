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

var target_point
var target_arrow
var target_space : CardSpace2D
var card : Card2D
var focus_out

var target_mode : int:
	set(value):
		if value != target_mode:
			pass
		target_mode = value

func _ready():
	open()
	target_arrow = target_arrow_path.instantiate()
	add_child(target_arrow)
	pass
		

func _on_move_1_button_down(button_pressed):
	m1.button_pressed=button_pressed
	m1_icon.button_pressed=button_pressed
	if button_pressed:
		m2.button_pressed=false
		if card:
			card.selected_move = 1
			target_mode = int(card.m1_attributes["target_mode"])
func _on_move_2_button_down(button_pressed):
	m2.button_pressed=button_pressed
	m2_icon.button_pressed=button_pressed
	if button_pressed:
		m1.button_pressed=false
		if card:
			card.selected_move = 2
			target_mode = int(card.m2_attributes["target_mode"])


func update_info():
	if card:
		target_getter.global_position = card.global_position
		target_arrow.global_position = card.global_position

		if card.targeted_space:
			target_space=card.targeted_space
			update_targets()
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
	else:card.selected_move = 0
	if target_space: card.targeted_space = target_space
	if target_arrow: target_arrow.queue_free()
	queue_free()


func _on_target_getter_body_entered(body):
	match target_mode:
		Global.ATTACK:
			if body.is_in_group("opposing_space"): create_target(body)
		Global.SUPPORT:
			if body.is_in_group("play_space"): create_target(body)
		Global.SUPPORT_SELF:
			pass
		Global.ATTACK_ALL:
			if body.is_in_group("play_space") || body.is_in_group("opposing_space"): create_target(body)
		_:
			pass
func create_target(body):
	target_point = target_point_path.instantiate()
	add_child(target_point)
	target_point.space = body
	target_point.global_position = body.global_position
