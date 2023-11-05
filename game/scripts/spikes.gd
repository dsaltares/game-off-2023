extends StaticBody3D
class_name Spikes

@onready var hazard_area := %HazardArea
@onready var animation_player := %AnimationPlayer


func _ready() -> void:
	animation_player.play("idle")


func _physics_process(_delta: float) -> void:
	for body in hazard_area.get_overlapping_bodies():
		if body.has_method("damage"):
			body.damage()
