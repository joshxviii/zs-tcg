extends Control


func _on_menu_pressed():
	self.show()

func _on_back_pressed():
	self.hide()


func _on_leave_pressed():
	if Global.PLAYAREA: Global.PLAYAREA.queue_free()
	Global.MAINMENU.show()
