extends Marker2D

var space : CardSpace2D

func _ready():
	modulate = Color(1,1,1,0)
	var tween = create_tween()
	tween.tween_property(self,"modulate",Color(1,1,1,1),.1)

func _on_texture_button_pressed():
	if get_parent():
		get_parent().target_space = space
		get_parent().update_target()
	pass # Replace with function body.
