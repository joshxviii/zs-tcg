extends Node

var VERSION = ProjectSettings.get_setting_with_override("application/config/version")
var NULLIMAGE = ResourceLoader.load("res://assets/textures/missing.png")

var userdata_path = "user://userdata.save"
var type_matchup_path = "res://assets/type_matchups.csv"

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
const KI_COLOR=Color.DARK_TURQUOISE
const STRENGTH_COLOR=Color.CRIMSON
const DEFENSE_COLOR=Color.FOREST_GREEN
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

var matchup_chart : Array[Array] = []

func import_type_matchups():
	if FileAccess.file_exists(type_matchup_path):
		var file = FileAccess.open(type_matchup_path, FileAccess.READ)
		var line_count:=0
		while !file.eof_reached():
			var line = Array(file.get_csv_line())
			line_count+=1
			if line_count==1: continue #skip the first line
			var new_line : Array[float]
			for i in line.size():
				if i == 0: continue #skip the first column
				new_line.append(float(line[i]))
			matchup_chart.append(new_line)
			
		file.close()
		
#endregion


signal card_attacked(card:Card2D)
signal card_updated(card:Card2D,event:int)

signal space_updated(space:CardSpace2D)

#var SaveData : Dictionary = {"display_name":"PLAYER","user_deck":[]}#TODO add save data
var USERDATA := Player.new()

func _init() -> void:
	import_type_matchups()
	load_userdata()

func load_userdata():
	if FileAccess.file_exists(userdata_path):
		print("loading userdata")
		var file = FileAccess.open(userdata_path, FileAccess.READ)
		var data = file.get_var(true)
		USERDATA.display_name = data["display_name"]
		USERDATA.collection = data["collection"]
		USERDATA.deck = data["deck"]
		file.close()
	else:
		print("file not found, creating file")
		save_userdata()

func save_userdata():
	print("saving userdata")
	var file = FileAccess.open(userdata_path, FileAccess.WRITE)
	var data := {"display_name":USERDATA.display_name,"collection":USERDATA.collection,"deck":USERDATA.deck}
	file.store_var(data, true)
	file.close()

func erase_userdata():
	print("erasing userdata")
	USERDATA = Player.new()
	var file = FileAccess.open(userdata_path, FileAccess.WRITE)
	var data := {"display_name":USERDATA.display_name,"collection":USERDATA.collection,"deck":USERDATA.deck}
	file.store_var(data, true)
	file.close()
	

func _exit_tree() -> void:
	save_userdata()

var BOARD : Board
var CURSOR = Cursor.new()
var PLAYER_HAND : CardHand2D
var PLAYER_DECK : CardDeck2D
var PLAYAREA : PlayArea
var MAINMENU
var DEBUG_WINDOW
var NETWORK : Network
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
	var image = ResourceLoader.load(path)
	if image!=null: return image
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
