extends AnimatableBody3D
class_name FallingPlatform

@export var warning_time := 1.5
@export var reset := true

const SHAKE_DURATION := 0.2
const FALL_DURATION := 0.5
const SHAKE_INTENSITY := 0.6
const RESET_TIME := 1.5

@onready var rig := %Rig
@onready var collision_shape := %CollisionShape3D
@onready var area := %Area3D

func fall() -> void:
	var tween := get_tree().create_tween()
	var shakes = floor(warning_time/SHAKE_DURATION)
	for shake in range(shakes):
		var movement := Vector3(
			randf_range(-SHAKE_INTENSITY, SHAKE_INTENSITY),
			0.0,
			randf_range(-SHAKE_INTENSITY, SHAKE_INTENSITY)
		)
		(
			tween
			. tween_property(rig, "position", movement, SHAKE_DURATION * 0.5)
			. as_relative()
			. set_ease(Tween.EASE_IN_OUT)
			. set_trans(Tween.TRANS_QUAD)
		)
		(
			tween
			. tween_property(rig, "position", -movement, SHAKE_DURATION * 0.5)
			. as_relative()
			. set_ease(Tween.EASE_IN_OUT)
			. set_trans(Tween.TRANS_QUAD)
		)
	tween.tween_callback(_on_warning_finished)
	(
		tween
		. tween_property(rig, "scale", Vector3(0.0, 0.0, 0.0), FALL_DURATION)
		. set_ease(Tween.EASE_IN_OUT)
		. set_trans(Tween.TRANS_QUAD)
	)
	(
		tween
		. parallel()
		. tween_property(rig, "position", Vector3.DOWN * 3.0, FALL_DURATION)
		. as_relative()
		. set_ease(Tween.EASE_IN_OUT)
		. set_trans(Tween.TRANS_QUAD)
	)
	
	if reset:
		(
			tween
			. tween_property(rig, "scale", Vector3(1.0, 1.0, 1.0), FALL_DURATION)
			. set_delay(RESET_TIME)
			. set_ease(Tween.EASE_IN_OUT)
			. set_trans(Tween.TRANS_QUAD)
		)
		(
			tween
			. parallel()
			. tween_property(rig, "position", Vector3.ZERO, FALL_DURATION)
			. set_ease(Tween.EASE_IN_OUT)
			. set_trans(Tween.TRANS_QUAD)
		)
		tween.tween_callback(_on_reset_finished)
		
	tween.play()
	

func _on_area_3d_body_entered(_body: Node3D) -> void:
	fall()
	area.set_deferred("monitoring", false)

func _on_warning_finished() -> void:
	collision_shape.disabled = true

func _on_reset_finished() -> void:
	collision_shape.disabled = false
	area.monitoring = true
