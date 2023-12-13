@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("DataBaseHandler", "Node", preload("db_handler.gd"), preload("db_handler.svg"))
	pass


func _exit_tree():
	remove_custom_type("DataBaseHandler")
	pass
