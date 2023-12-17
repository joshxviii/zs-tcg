extends Node

func _ready():
	var scene = load("res://main_menu.tscn").instantiate()
	get_tree().root.add_child.call_deferred(scene)
	
