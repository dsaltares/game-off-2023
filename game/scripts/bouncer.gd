extends StaticBody3D
class_name Bouncer

@onready var animation_player: AnimationPlayer = %AnimationPlayer


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		var player := body as Player
		player.high_jump()
		animation_player.play("bounce")
