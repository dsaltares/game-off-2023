extends WorldEnvironment

@export var player: Player

const focus_range = 3.0


func _process(_delta: float) -> void:
	if player == null:
		return

	var camera_pos = get_viewport().get_camera_3d().global_position
	var player_pos = player.global_position
	var distance = camera_pos.distance_to(player_pos)

	var attributes = camera_attributes as CameraAttributesPractical
	attributes.dof_blur_far_distance = distance + focus_range * 0.5
	attributes.dof_blur_near_distance = distance - focus_range * 0.5
