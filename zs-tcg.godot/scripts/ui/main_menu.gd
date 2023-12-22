extends Control

func _ready(): 
	$main_menu/version.text = Global.VERSION

func _on_singleplayer_pressed():
	var scene = load("res://playarea_scene.tscn").instantiate()
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

var display_name = ""
func _on_display_name_text_changed(new_text):
	display_name = new_text
var online_address := ""
func _on_online_address_changed(new_text):
	online_address=new_text
func _on_online_join_pressed():
	if online_address!="": Network.new().join(online_address)
	else: Network.new().join()
	if display_name!="": Global.NETWORK.display_name = display_name

func _on_online_host_pressed():
	Network.new().host()
	if display_name!="": Global.NETWORK.display_name = display_name





