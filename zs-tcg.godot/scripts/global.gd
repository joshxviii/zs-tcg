extends Node

var VERSION = ProjectSettings.get_setting_with_override("application/config/version")
var NULLIMAGE = ResourceLoader.load("res://assets/textures/missing.png")

#region Variables

#region Constants

enum {
	NEUTRAL,
	KI,
	STRENGTH,
	DEFENSE,
	SPEED
}

const NEUTRAL_COLOR=Color.PERU
const KI_COLOR=Color.AQUA
const STRENGTH_COLOR=Color.CRIMSON
const DEFENSE_COLOR=Color.CHARTREUSE
const SPEED_COLOR=Color.BLUE_VIOLET
func get_type_color(type:int) -> Color:
	match type:
		NEUTRAL:
			return NEUTRAL_COLOR
		KI:
			return KI_COLOR
		STRENGTH:
			return STRENGTH_COLOR
		DEFENSE:
			return DEFENSE_COLOR
		SPEED:
			return SPEED_COLOR
		_:
			return Color.html("fff58f")

enum {
	SELF,
	FOE,
	ALLY,
	FOE_ALL,
	ALLY_ALL,
	ALL,
	ANY,
	RANDOM
}
#endregion

var SaveData : Dictionary = {"display_name":"PLAYER","user_deck":[]}

var BOARD
var CURSOR = Cursor.new()
var PLAYER_HAND : CardHand2D
var PLAYER_DECK : CardDeck2D
var PLAYAREA
var MAINMENU
var DEBUG_WINDOW
var NETWORK
var GUI 
var DB := DataBaseHandler.new()

var can_drag := true
var is_dragging := false:
	set(value):
		if value:
			if Global.GUI: Global.GUI.close_move_info()
		is_dragging=value
var dragged_card : Card2D

#endregion	

func return_to_title():
	stop_wait()
	if PLAYAREA:
		PLAYAREA.queue_free()
		PLAYAREA=null
	if NETWORK: 
		NETWORK.queue_free()
		NETWORK=null
	MAINMENU.show()
	
@onready var loading_screen = load("res://loading_screen.tscn").instantiate()
func _ready():
	var title_version = "(" + VERSION + ")"
	DisplayServer.window_set_title("ZS Trading Card Game " + title_version)
	add_child(loading_screen)
	#cursor.load_cursor()
	pass

##load image from path if there is one. otherwise load missing texture file
func image_load(path:String):
	if ResourceLoader.load(path): return ResourceLoader.load(path)
	else: return NULLIMAGE
	
func start_wait():
	loading_screen.show()
func stop_wait():
	loading_screen.hide()
	
func _input(_event):
	if Input.is_action_just_pressed("debug"):
		if !DEBUG_WINDOW:
			DEBUG_WINDOW = load("res://debugger.tscn").instantiate()
			get_tree().root.add_child(DEBUG_WINDOW)
		else: DEBUG_WINDOW.queue_free()
