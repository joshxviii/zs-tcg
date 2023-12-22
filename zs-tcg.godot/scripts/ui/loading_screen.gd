@tool
extends Control

@onready var point = $circle/cirlce_dots

func _process(delta):
	
	point.progress_ratio += delta/2
