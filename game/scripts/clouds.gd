@tool

extends Node3D
class_name Clouds

@onready var model := %Model
@onready var animation_player := %AnimationPlayer

var clouds : Array[PackedScene] = [
	preload("res://models/Cloud_1.gltf"),
	preload("res://models/Cloud_2.gltf"),
	preload("res://models/Cloud_3.gltf")
]

func _ready() -> void:
	model.add_child(clouds.pick_random().instantiate())
	
	if Engine.is_editor_hint():
		return
	
	animation_player.play('idle')
	var random_start := randf_range(0, animation_player.get_animation('idle').length)
	animation_player.seek(random_start, true)

