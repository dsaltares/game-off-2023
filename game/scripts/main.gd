class_name Main
extends Node3D


func _ready() -> void:
	if !OS.is_debug_build():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
