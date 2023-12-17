extends Control



func _ready(): 
	$main_menu/version.text = Global.VERSION


func _on_singleplayer_pressed():
	var scene = load("res://singleplayer_scene.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()
	pass

func _on_multiplayer_lan_pressed():
	pass

func _on_options_pressed():
	pass
