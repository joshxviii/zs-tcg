extends UIWindow
const matchup_path = preload("res://objects/ui/matchup_score.tscn")
var matchups := []

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
@onready var m1_target = $moves/move_1/target_mode/mode
@onready var m2_target = $moves/move_2/target_mode/mode

@onready var m1_box = $moves/move_1
@onready var m2_box = $moves/move_2

var target_point
var target_space : CardSpace2D
var card : Card2D
var focus_out
var default_target : CardSpace2D

var cur_move : int:
	set(value):
		cur_move=value
		if card.selected_move!=cur_move:
			card.selected_move=cur_move
			move_changed.emit()

func _init() -> void:
	move_changed.connect(on_move_changed)

func _ready():
	open()
	update_info()
	pass

signal move_changed
func _on_move_1_button_down(button_pressed):
	m1_star.visible=button_pressed
	if m1.button_pressed:cur_move = 1
	elif !m2.button_pressed:cur_move = 0

func _on_move_2_button_down(button_pressed):
	m2_star.visible=button_pressed
	if m2.button_pressed:cur_move = 2
	elif !m1.button_pressed:cur_move = 0
	

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
		m1_power.text = str(card.m1_attributes["power"])
		m1_power.modulate=Global.get_type_color(card.m1_attributes["type"])
		m1_icon.texture = ResourceLoader.load("res://assets/textures/ui/type_indicators/type_indicator_"+str(card.m1_attributes["type"])+".png")
		m1_target.frame = int(card.m1_attributes["target_mode"])
	else: m1_box.visible = false
	if card.m2_attributes.size() > 0:
		m2_name.text = card.m2_attributes["name"]
		m2_power.text = str(card.m2_attributes["power"])
		m2_power.modulate=Global.get_type_color(card.m2_attributes["type"])
		m2_icon.texture = ResourceLoader.load("res://assets/textures/ui/type_indicators/type_indicator_"+str(card.m2_attributes["type"])+".png")
		m2_target.frame = int(card.m2_attributes["target_mode"])
	else: m2_box.visible = false

func open():
	pass
	show_move_effectiveness()
	
func close():
	super.close()
	#if card.owner_space.is_in_group("play_space"):card.owner_space.target_selector_box.visible=false
	if m1.button_pressed:card.selected_move = 1
	elif m2.button_pressed:card.selected_move = 2
	else: card.selected_move = 0
	for info in matchups:info.queue_free()
	matchups.clear()
	queue_free()

func on_move_changed():
	show_move_effectiveness()
	
func show_move_effectiveness():
	var targets = card.owner_space.get_targets()
	
	for info in matchups:info.queue_free()
	matchups.clear()
	
	for space:CardSpace2D in targets:
		var matchup_score:=1.0
		if !space:continue
		if space.cards.size()>0:
			var target_card : Card2D = space.cards[0]
			var t1 = card.current_move_info["type"]
			var t2 = target_card.attributes["type"]
			matchup_score = Global.matchup_chart[t1][t2]
		
		var matchup_info = matchup_path.instantiate()
		matchups.append(matchup_info)
		Global.GUI.add_child(matchup_info)
		matchup_info.position = space.global_position
		matchup_info.value = card.current_move_info["power"]*matchup_score
		matchup_info.effectiveness = matchup_score
