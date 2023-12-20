extends Node

func _ready():
	var db = load("res://objects/zs_database.tscn").instantiate()
	get_tree().root.add_child.call_deferred(db)
	var scene = load("res://main_menu.tscn").instantiate()
	get_tree().root.add_child.call_deferred(scene)
	
