@tool
extends AnimatableBody3D
class_name MovingPlatform

@export var movement := Vector3.RIGHT
@export var speed := 1.0
@export var wait_time := 1.0


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	var duration = movement.length() / speed
	var tween := create_tween()
	(
		tween
		. tween_property(self, "global_position", movement, duration)
		. as_relative()
		. set_delay(wait_time)
		. set_ease(Tween.EASE_IN_OUT)
		. set_trans(Tween.TRANS_QUAD)
	)
	(
		tween
		. tween_property(self, "global_position", -movement, duration)
		. as_relative()
		. set_delay(wait_time)
		. set_ease(Tween.EASE_IN_OUT)
		. set_trans(Tween.TRANS_QUAD)
	)
	tween.set_loops()
	tween.play()


#func _process(_delta: float) -> void:
#	if Engine.is_editor_hint():
#		DebugDraw3D.draw_line(global_position, global_position + movement, Color.DARK_CYAN)
