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

var PLAYER_HAND : CardHand2D
var PLAYAREA
var MAINMENU

var db := DataBaseHandler.new()

var is_dragging := false
var dragged_card : Card2D

@onready var cursor = Cursor.new()
#endregion

var GUI 

func _ready():
	var title_version = "(" + VERSION + ")"
	DisplayServer.window_set_title("ZS Trading Card Game " + title_version)
	#cursor.load_cursor()
	pass

##load image from path if there is one. otherwise load missing texture file
func image_load(path:String):
	if ResourceLoader.load(path): return ResourceLoader.load(path)
	else: return NULLIMAGE
