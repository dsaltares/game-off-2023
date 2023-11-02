extends SpringArm3D
class_name CameraRig

@export var target: Node3D
@export var target_offset: Vector3 = Vector3(0, 0, 0)
@export var follow_time := 0.2
@export var mouse_sensitivity := 0.005

@onready var camera := %Camera3D


func _physics_process(delta):
	if !target:
		return

	var target_position := target.global_position + target_offset
	global_position = global_position.lerp(target_position, delta / follow_time)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensitivity
		rotation.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 30.0)
