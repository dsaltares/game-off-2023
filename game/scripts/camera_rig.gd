extends SpringArm3D
class_name CameraRig

@export var target: Node3D
@export var follow_time := 0.2
@export var mouse_sensitivity := 0.005
@export var controller_rotation_sensitivity := 5.0

const MIN_ROTATION_X := -90.0
const MAX_ROTATION_X := 30


func _physics_process(delta):
	if !target:
		return

	global_position = global_position.lerp(target.global_position, delta / follow_time)
	
	
	var input := Vector3.ZERO
	input.y = -Input.get_axis("camera_left", "camera_right")
	input.x = -Input.get_axis("camera_up", "camera_down")
	
	rotation += input.limit_length(1.0) * controller_rotation_sensitivity * delta
	rotation_degrees.x = clamp(rotation_degrees.x, MIN_ROTATION_X, MAX_ROTATION_X)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensitivity
		rotation.x -= event.relative.y * mouse_sensitivity
		rotation_degrees.x = clamp(rotation_degrees.x, MIN_ROTATION_X, MAX_ROTATION_X)
