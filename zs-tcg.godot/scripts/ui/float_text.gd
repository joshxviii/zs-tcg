extends Control

var color : Color = Color.WHITE
var text : String = "HELLO"
var text_scale : float = 1.0

func start(time:=0.5):
	$text.text = text
	$text.scale = Vector2(1.0,1.0)*text_scale
	modulate = color
	var tween = create_tween()
	tween.parallel().tween_property(self,"position",Vector2(global_position.x,global_position.y-30),time).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($text,"modulate",Color(color,0),time).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	queue_free()
