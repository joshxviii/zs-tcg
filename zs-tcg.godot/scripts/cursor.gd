class_name Cursor extends Area2D


# Load the custom images for the mouse cursor.
var arrow = load("res://assets/textures/cursor/0.png")
var beam = load("res://assets/textures/cursor/1.png")
var point = load("res://assets/textures/cursor/2.png")
var drag = load("res://assets/textures/cursor/6.png")
#var beam = load("res://assets/textures/cursor/1.png")


func load_cursor():
	Input.set_custom_mouse_cursor(arrow, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(beam, Input.CURSOR_IBEAM)
	Input.set_custom_mouse_cursor(point, Input.CURSOR_POINTING_HAND)
	Input.set_custom_mouse_cursor(drag, Input.CURSOR_DRAG)

func _process(_delta):
	position = get_global_mouse_position()
