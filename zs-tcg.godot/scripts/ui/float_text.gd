extends Control

var color : Color = Color.WHITE
var text : String = "HELLO"
var time := 0.5

func start():
	$text.text = text
	modulate = color
	var tween = create_tween()
	tween.parallel().tween_property(self,"position",Vector2(global_position.x,global_position.y-40),time).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property($text,"modulate",Color(color,0),time).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	queue_free()
