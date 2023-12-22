extends Control


func _on_menu_pressed():
	self.show()

func _on_back_pressed():
	self.hide()


func _on_leave_pressed():
	Global.return_to_title()
