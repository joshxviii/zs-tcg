extends UIWindow


func _ready():
	var tween = create_tween()
	tween.tween_property(self,"modulate",Color(1,1,1,1),.1)

func _on_gui_input(e):
	if e is InputEventMouseButton and e.button_mask==2:
		closed.emit()
		var tween = create_tween()
		tween.tween_property(self,"modulate",Color(1,1,1,0),.1)
		await tween.finished
		queue_free()

func _shortcut_input(event):
	print(event)

func _on_mouse_entered():
	#closed.emit()
	#queue_free()
	pass # Replace with function body.
