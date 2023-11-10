extends Node3D
class_name Coin

@onready var animation_player: AnimationPlayer = %AnimationPlayer

func _ready() -> void:
	animation_player.play("idle")


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method('pick_up_coin'):
		body.pick_up_coin()
		queue_free()
