extends DataBaseHandler

var pack_amount := 4
@onready var pack : Array[Dictionary] = []

func _ready():
	if not Engine.is_editor_hint():
		CardHandler.db = self
	pack.clear()
