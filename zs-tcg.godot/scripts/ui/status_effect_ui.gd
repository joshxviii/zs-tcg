extends Panel

var effect : StatusEffect

var id := 0:
	set(value):
		id=value
		$icon/type_icon.frame=int(id)
