extends SpringArm3D
class_name CameraRig

@export var target: Node3D
@export var follow_time := 0.2
@export var mouse_sensitivity := 0.005


func _physics_process(delta):
	if !target:
		return

	global_position = global_position.lerp(target.global_position, delta / follow_time)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensitivity
		rotation.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 30.0)
