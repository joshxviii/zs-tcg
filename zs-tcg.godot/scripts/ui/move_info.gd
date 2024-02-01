extends UIWindow

@onready var m1 = $moves/move_1/name
@onready var m2 = $moves/move_2/name

@onready var info_name = $moves/name
@onready var m1_power = $moves/move_1/type/power
@onready var m2_power = $moves/move_2/type/power
@onready var m1_icon = $moves/move_1/type/icon
@onready var m2_icon = $moves/move_2/type/icon
@onready var m1_name = $moves/move_1/name
@onready var m2_name = $moves/move_2/name
@onready var m1_star = $moves/move_1/select_star
@onready var m2_star = $moves/move_2/select_star

@onready var m1_box = $moves/move_1
@onready var m2_box = $moves/move_2

var target_point
var target_space : CardSpace2D
var card : Card2D
var focus_out
var default_target : CardSpace2D

var target_mode : int

func _ready():
	#target_space = card.targeted_space
	open()
	update_info()
	pass

signal target_mode_changed(mode)
func _on_move_1_button_down(button_pressed):
	m1_star.visible=button_pressed
	if m1.button_pressed:
		if card.current_move_info.size() > 0:
			target_mode = int(card.current_move_info["target_mode"])
			if target_mode != int(card.m1_attributes["target_mode"]): target_mode_changed.emit(int(card.m1_attributes["target_mode"]))
			#target_mode_changed.emit(int(card.m1_attributes["target_mode"]))
			card.selected_move = 1
	elif !m1.button_pressed:
		if !m2.button_pressed:
			card.selected_move = 0
			target_mode_changed.emit(-1)
			target_mode = -1
func _on_move_2_button_down(button_pressed):
	m2_star.visible=button_pressed
	if m2.button_pressed:
		if card.current_move_info.size() > 0:
			target_mode = int(card.current_move_info["target_mode"])
			if target_mode != int(card.m2_attributes["target_mode"]): target_mode_changed.emit(int(card.m2_attributes["target_mode"]))
			#target_mode_changed.emit(int(card.m2_attributes["target_mode"]))
			card.selected_move = 2
	elif !m1.button_pressed:
		if !m2.button_pressed:
			card.selected_move = 0
			target_mode_changed.emit(-1)
			target_mode = -1
		
func _on_m1_icon_pressed():
	m1.button_pressed=!m1.button_pressed
func _on_m2_icon_pressed():
	m2.button_pressed=!m2.button_pressed


func update_info():
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
		m1_icon.texture_normal = ResourceLoader.load("res://assets/textures/ui/type_indicators/type_indicator_"+str(card.m1_attributes["type"])+".png")
	else: m1_box.visible = false
	if card.m2_attributes.size() > 0:
		m2_name.text = card.m2_attributes["name"]
		m2_power.text =  "+" + str(card.m2_attributes["power"])
		m2_power.modulate=Global.get_type_color(card.m2_attributes["type"])
		m2_icon.texture_normal = ResourceLoader.load("res://assets/textures/ui/type_indicators/type_indicator_"+str(card.m2_attributes["type"])+".png")
	else: m2_box.visible = false

func open():
	card.owner_space.target_selector_box.visible=true
	pass
	
func close():
	super.close()
	if card.owner_space.is_in_group("play_space"):card.owner_space.target_selector_box.visible=false
	if m1.button_pressed:card.selected_move = 1
	elif m2.button_pressed:card.selected_move = 2
	else: card.selected_move = 0
	if target_space: card.targeted_space = target_space
	queue_free()

func _on_target_mode_changed(mode):
	target_mode = mode
	card.owner_space.target_mode = mode
