extends UIWindow




func _on_gui_input(e):
	if e is InputEventMouseButton and e.pressed:
		closed.emit()
		queue_free()


func _on_mouse_entered():
	closed.emit()
	queue_free()
	pass # Replace with function body.
