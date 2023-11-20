extends Node3D
class_name LevelEnd

@onready var gem: Area3D = %Gem
@onready var anim_player: AnimationPlayer = $Gem/AnimationPlayer


func _ready() -> void:
	anim_player.play("idle")

func _on_gem_body_entered(body: Node3D) -> void:
	if body.has_method('pick_up_gem'):
		gem.queue_free()
		body.pick_up_gem()
	
