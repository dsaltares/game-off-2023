extends Node3D
class_name Main

@onready var fps_label: Label = %FPSLabel


func _process(_delta: float) -> void:
	fps_label.text = str(Engine.get_frames_per_second())
