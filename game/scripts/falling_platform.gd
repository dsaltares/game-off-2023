extends AnimatableBody3D
class_name FallingPlatform

@export var warning_time := 1.5

const SHAKE_DURATION := 0.2
const FALL_DURATION := 0.5
const SHAKE_INTENSITY := 0.6

@onready var model := %Model
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
			. tween_property(model, "position", movement, SHAKE_DURATION * 0.5)
			. as_relative()
			. set_ease(Tween.EASE_IN_OUT)
			. set_trans(Tween.TRANS_QUAD)
		)
		(
			tween
			. tween_property(model, "position", -movement, SHAKE_DURATION * 0.5)
			. as_relative()
			. set_ease(Tween.EASE_IN_OUT)
			. set_trans(Tween.TRANS_QUAD)
		)
	tween.tween_callback(_on_warning_finished)
	(
		tween
		. tween_property(model, "scale", Vector3(0.0, 0.0, 0.0), FALL_DURATION)
		. set_ease(Tween.EASE_IN_OUT)
		. set_trans(Tween.TRANS_QUAD)
	)
	(
		tween
		. parallel()
		. tween_property(model, "position", Vector3.DOWN * 3.0, FALL_DURATION)
		. as_relative()
		. set_ease(Tween.EASE_IN_OUT)
		. set_trans(Tween.TRANS_QUAD)
	)
	tween.play()

func _on_area_3d_body_entered(_body: Node3D) -> void:
	fall()
	area.set_deferred("monitoring", false)

func _on_warning_finished() -> void:
	collision_shape.disabled = true
