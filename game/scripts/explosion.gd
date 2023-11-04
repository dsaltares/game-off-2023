extends Node3D
class_name Explosion

@onready var animation_player: AnimationPlayer = %AnimationPlayer


func _ready() -> void:
	animation_player.play("explode")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "explode":
		queue_free()
