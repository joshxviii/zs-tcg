extends Node

func _ready():
	var db = DataBaseHandler.new()
	db.database_path = "res://assets/zs_cards.json"
	#get_tree().root.add_child.call_deferred(db)
	Global.db = db
	var scene = load("res://main_menu.tscn").instantiate()
	get_tree().root.add_child.call_deferred(scene)
	Global.MAINMENU = scene
