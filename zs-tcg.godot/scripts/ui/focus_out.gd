extends UIWindow


func _ready():
	var tween = create_tween()
	tween.tween_property(self,"modulate",Color(1,1,1,1),.1)

func _on_gui_input(e):
	if e is InputEventMouseButton:
		closed.emit()
		var tween = create_tween()
		tween.tween_property(self,"modulate",Color(1,1,1,0),.1)
		await tween.finished
		queue_free()


func _on_mouse_entered():
	#closed.emit()
	#queue_free()
	pass # Replace with function body.
