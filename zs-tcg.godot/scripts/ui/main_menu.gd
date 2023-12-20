extends Control

func _ready(): 
	$main_menu/version.text = Global.VERSION

func _on_singleplayer_pressed():
	var scene = load("res://singleplayer_scene.tscn").instantiate()
	get_tree().root.add_child(scene)
	Global.PLAYAREA = scene
	self.hide()
	pass

#region Main Title Menu
func _on_multiplayer_pressed():
	$mutliplayer.show()
	$main_menu.hide()
func _on_options_pressed():
	$options.show()
	$main_menu.hide()
#endregion

func _on_multiplayer_back_pressed():
	$main_menu.show()
	$mutliplayer.hide()


func _on_multiplayer_online_pressed():
	$mutliplayer/online.show()
	$mutliplayer/multiplayer_menu.hide()

func _on_multiplayer_lan_pressed():
	$mutliplayer/lan.show()
	$mutliplayer/multiplayer_menu.hide()

func _on_online_back_pressed():
	$mutliplayer/multiplayer_menu.show()
	$mutliplayer/online.hide()

func _on_lan_back_pressed():
	$mutliplayer/multiplayer_menu.show()
	$mutliplayer/lan.hide()

func _on_options_back_pressed():
	$main_menu.show()
	$options.hide()


func _on_exit_pressed():
	get_tree().quit()
