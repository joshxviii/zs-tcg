class_name Player

var display_name := "Player"
var collection : Array = [0,1,2,3,4,87,6,12,14,14]
var deck := collection.duplicate()

var win_ratio

func _init() -> void:
	if deck.size()>20:
		deck.resize(20)
		
		
	#TODO remove this
	for n in 300:# add every card to collection
		collection.append(n)

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
	
	properties.append({
		"name": "collection",
		"type": TYPE_ARRAY,
		"usage": PROPERTY_USAGE_STORAGE
	})
	
	return properties

func get_free_collection_cards() -> Dictionary:
	var free_collection : Dictionary
	for card in collection:
		if free_collection.has(card):
			free_collection[card] += 1
		else: free_collection[card] = 1
		
	for card in deck:
		free_collection[card]-=1
		
	return free_collection
