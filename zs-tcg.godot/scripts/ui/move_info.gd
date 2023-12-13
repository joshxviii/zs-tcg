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

@onready var m1_box = $moves/move_1
@onready var m2_box = $moves/move_2

var card : Card2D
var focus_out

func _ready():
	open()
	pass
		

func _on_move_1_button_down(button_pressed):
	m1.button_pressed=button_pressed
	m1_icon.button_pressed=button_pressed
	if button_pressed:
		m2.button_pressed=false
		if card: card.selected_move = 1

func _on_move_2_button_down(button_pressed):
	m2.button_pressed=button_pressed
	m2_icon.button_pressed=button_pressed
	if button_pressed:
		m1.button_pressed=false
		if card: card.selected_move = 2


func update_info():
	if card:
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
			m1_icon.texture_normal = TextureHandler.new().get_texture("res://assets/textures/ui/type_indicator_"+str(card.m1_attributes["type"])+".png")
		else: m1_box.visible = false

		if card.m2_attributes.size() > 0:
			m2_name.text = card.m2_attributes["name"]
			m2_power.text =  "+" + str(card.m2_attributes["power"])
			m2_icon.texture_normal = TextureHandler.new().get_texture("res://assets/textures/ui/type_indicator_"+str(card.m2_attributes["type"])+".png")
		else: m2_box.visible = false

func open():
	pass
	
func close():
	super.close()
	if m1.button_pressed:card.selected_move = 1
	elif m2.button_pressed:card.selected_move = 2
	else:card.selected_move = 0
	queue_free()
