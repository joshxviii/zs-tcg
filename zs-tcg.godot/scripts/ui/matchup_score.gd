@tool
extends Control

@onready var icon := $label/matchup_icon/icon

var color : Color:
	set(value):
		color = value
		$label.self_modulate = color

var value := 100.0:
	set(s):
		value=s
		$label.text = str(int(value))
		if value==0:hide()

var effectiveness:=1.0:
	set(value):
		effectiveness=value
		icon.frame = effectiveness
		match effectiveness:
			1.5:
				icon.frame = 1
				color = Color.GREEN
			1.25:
				icon.frame = 2
				color = Color.YELLOW
			0.9:
				icon.frame = 3
				color = Color.ORANGE
			0.75:
				icon.frame = 4
				color = Color.RED
			_:
				icon.frame = 0
				color = Color.WHITE
