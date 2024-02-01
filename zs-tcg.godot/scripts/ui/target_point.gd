extends Marker2D

const target_arrow_path = preload("res://objects/ui/target_arrow.tscn")
var target_arrow
@onready var btn = $target_selector

var space : CardSpace2D

func _ready():
	modulate = Color(1,1,1,0)
	var tween = create_tween()
	tween.tween_property(self,"modulate",Color(1,1,1,1),.1)

func _on_texture_button_toggled(button_pressed):
	if button_pressed:
		get_parent().get_parent().get_parent().targets.erase(space)
		get_parent().get_parent().get_parent().default_target = space
		get_parent().get_parent().get_parent().targets.append(space)
	else:
		get_parent().get_parent().get_parent().targets.erase(space)
	get_parent().get_parent().get_parent().update_target_arrows()


