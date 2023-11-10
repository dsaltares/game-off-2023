extends StaticBody3D
class_name Spikes

@export var delay := 0.0

@onready var hazard_area := %HazardArea
@onready var animation_player := %AnimationPlayer

func _ready() -> void:
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
		
	animation_player.play("idle")


func _physics_process(_delta: float) -> void:
	if !hazard_area.monitoring:
		return
		
	for body in hazard_area.get_overlapping_bodies():
		if body.has_method("damage"):
			body.damage()
