@tool
extends Area3D
class_name CircularSaw

@export var distance := 5.0
@export var speed := 3.0
@export var wait_time := 0.5

@onready var animation_player := %AnimationPlayer
@onready var model := %Model


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	var movement := -global_transform.basis.z * distance
	var duration = movement.length() / speed
	var tween := create_tween()
	tween.tween_property(model, "rotation_degrees", Vector3(0.0, 90.0, 0.0), 0.0)
	(
		tween
		. tween_property(self, "global_position", movement, duration)
		. as_relative()
		. set_delay(wait_time)
		. set_ease(Tween.EASE_IN_OUT)
		. set_trans(Tween.TRANS_QUAD)
	)
	tween.tween_property(model, "rotation_degrees", Vector3(0.0, 270.0, 0.0), 0.0)
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

	animation_player.play("idle")


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		var movement := -global_transform.basis.z * distance
		DebugDraw3D.draw_line(global_position, global_position + movement, Color.HOT_PINK)


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("damage"):
		body.damage()
