extends Node3D
class_name Level

func _ready() -> void:
	EventBus.connect("player_died", _on_player_died)
	
func _on_player_died() -> void:
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()
