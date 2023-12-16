extends Marker2D

const target_arrow_path = preload("res://objects/ui/target_arrow.tscn")
var target_arrow
@onready var btn = $target_selector

var space : CardSpace2D

func _ready():
	modulate = Color(1,1,1,0)
	var tween = create_tween()
	tween.tween_property(self,"modulate",Color(1,1,1,1),.1)

func _on_texture_button_pressed():

	pass # Replace with function body.


func _on_texture_button_toggled(button_pressed):
	if button_pressed:
		if get_parent().get_parent() and !target_arrow:
			get_parent().get_parent().target_space = space
			#get_parent().get_parent().update_targets()
			target_arrow = target_arrow_path.instantiate()
			add_child(target_arrow)
			target_arrow.global_position = get_parent().get_parent().card.global_position
			target_arrow.add_point(Vector2(0.0,0.0),0)
			target_arrow.add_point(global_position-target_arrow.global_position,1)
			
	else:
		if target_arrow: target_arrow.queue_free()
		pass
	pass # Replace with function body.
