@tool
extends TextureButton

@onready var pack = $pack_view/zs_pack

func _process(delta):
	#print(pack.rotation)
	pack.rotation.y += delta*1.5
	pass

func _on_toggled(toggled_on):
	var tween = create_tween()
	if toggled_on: tween.tween_property($pack_view/camera,"fov",60,0.1)
	else: tween.tween_property($pack_view/camera,"fov",75,0.1)
