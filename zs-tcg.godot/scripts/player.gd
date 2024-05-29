class_name Player

var display_name := "Player"
var deck : Array = [0,1,2,3]

var win_ratio

func _get_property_list():
	var properties = []
	
	properties.append({
		"name": "display_name",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_STORAGE
	})
	
	properties.append({
		"name": "deck",
		"type": TYPE_ARRAY,
		"usage": PROPERTY_USAGE_STORAGE
	})
	
	return properties
