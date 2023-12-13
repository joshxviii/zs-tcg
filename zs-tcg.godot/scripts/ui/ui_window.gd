class_name UIWindow extends Node

signal opened
signal closed

func open():
	emit_signal("opened")

func close():
	emit_signal("closed")
