class_name TextureHandler

const missing_texture ="res://assets/textures/missing.png"

func get_texture(path:String) -> Resource:
	if FileAccess.file_exists(path):
		return load(path)
	else: 
		push_warning(" \"" + path + "\" was not found.")
		return load(missing_texture)
