extends CharacterBody3D
class_name Player

const MOUSE_SENSITIVITY := 0.005
const MAX_SPEED := 8.0
const JUMP_HEIGHT := 4.1
const JUMP_DISTANCE_TO_PEAK := 3.5
const JUMP_DISTANCE_AFTER_PEAK := 2.5
const TIME_TO_MAX_SPEED := 0.25
const TIME_TO_HALT := 0.15
const TIME_TO_HALT_AIR := 1.0
const TIME_TO_FACE := 0.1

@export var camera_rig: CameraRig

@onready var coyote_timer := %CoyoteTimer
@onready var anim_tree := %AnimationTree
@onready var model := %Rig

const attack_types: Array[float] = [-1, -0.5, 0, 1]
const attack_animations := {
	"1H_Melee_Attack_Slice_Diagonal": true,
	"1H_Melee_Attack_Slice_Horizontal": true,
	"1H_Melee_Attack_Chop": true,
	"1H_Melee_Attack_Stab": true,
}

var can_jump := false
var attacking := false
var target_angle: float = 0.0


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	if camera_rig == null:
		return

	if is_on_floor():
		can_jump = true
	else:
		var section_distance = (
			JUMP_DISTANCE_TO_PEAK if velocity.y > 0.0 else JUMP_DISTANCE_AFTER_PEAK
		)
		var gravity = 2 * JUMP_HEIGHT * pow(MAX_SPEED, 2) / pow(section_distance, 2)
		velocity.y -= gravity * delta

		if coyote_timer.is_stopped():
			coyote_timer.start()

	if Input.is_action_just_pressed("jump") and can_jump:
		velocity.y = 2 * JUMP_HEIGHT * MAX_SPEED / JUMP_DISTANCE_TO_PEAK
		can_jump = false
		model.scale = Vector3(0.75, 1.25, 0.75)

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, camera_rig.rotation.y)
	var time_to_halt := TIME_TO_HALT if is_on_floor() else TIME_TO_HALT_AIR
	var acceleration := MAX_SPEED / TIME_TO_MAX_SPEED if direction else MAX_SPEED / time_to_halt
	var horizontal_speed := clampf(
		Vector2(velocity.x, velocity.z).length() + acceleration * delta, 0, MAX_SPEED
	)
	velocity.x = direction.x * horizontal_speed
	velocity.z = direction.z * horizontal_speed

	if Vector2(velocity.z, velocity.x).length() > 0:
		target_angle = Vector2(-velocity.z, -velocity.x).angle()

	rotation.y = lerp_angle(rotation.y, target_angle, delta / TIME_TO_FACE)
	model.scale = lerp(model.scale, Vector3(1, 1, 1), delta / 0.2)

	if Input.is_action_just_pressed("attack") and not attacking:
		anim_tree.set("parameters/attack_type/blend_position", attack_types.pick_random())
		anim_tree.set("parameters/attack/request", true)
		attacking = true

	anim_tree.set(
		"parameters/locomotion/IWR/blend_position",
		Vector2(velocity.x, velocity.z).length() / MAX_SPEED
	)
	anim_tree.set("parameters/locomotion/conditions/is_on_floor", is_on_floor())
	anim_tree.set("parameters/locomotion/conditions/is_in_air", !is_on_floor())

	move_and_slide()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_coyote_timer_timeout() -> void:
	can_jump = is_on_floor()


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if attack_animations.has(anim_name):
		attacking = false
