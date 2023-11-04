extends Node3D
class_name CannonBall

const SPEED = 12.0

var ExplosionScene := preload("res://scenes/explosion.tscn")


func _process(delta: float) -> void:
	global_position += -global_transform.basis.z * SPEED * delta


func _on_hit_area_body_entered(body: Node3D) -> void:
	if body is Player:
		var player := body as Player
		player.die()

	var explosion := ExplosionScene.instantiate()
	get_tree().root.add_child(explosion)
	explosion.global_transform.origin = global_position

	queue_free()
