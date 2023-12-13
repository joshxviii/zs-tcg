extends Node

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



@onready var cursor = Cursor.new()

var GUI 

func _ready():
		#cursor.load_cursor()
		pass
