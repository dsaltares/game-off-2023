extends CharacterBody3D

const MOUSE_SENSITIVITY := 0.005
const MAX_SPEED := 8.0
const JUMP_HEIGHT := 3.2
const JUMP_DISTANCE_TO_PEAK := 3.5
const JUMP_DISTANCE_AFTER_PEAK := 2.5
const TIME_TO_MAX_SPEED := 0.25
const TIME_TO_HALT := 0.15
const TIME_TO_HALT_AIR := 1.0
const TIME_TO_FACE := 0.1

@onready var coyote_timer := %CoyoteTimer
@onready var anim_tree := %AnimationTree
@onready
var anim_playback := anim_tree.get("parameters/playback") as AnimationNodeStateMachinePlayback
@onready var spring_arm := %SpringArm3D
@onready var model := %Rig

var can_jump := false
var was_on_floor := true
var attack_animations := ["Attack_Horizontal", "Attack_Diagonal", "Attack_Stab"]


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
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

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, spring_arm.rotation.y)
	var time_to_halt := TIME_TO_HALT if is_on_floor() else TIME_TO_HALT_AIR
	var acceleration := MAX_SPEED / TIME_TO_MAX_SPEED if direction else MAX_SPEED / time_to_halt
	var horizontal_speed := clampf(
		Vector2(velocity.x, velocity.z).length() + acceleration * delta, 0, MAX_SPEED
	)
	velocity.x = direction.x * horizontal_speed
	velocity.z = direction.z * horizontal_speed

	var horizontal_velocity := Vector2(velocity.x, velocity.z)

	if horizontal_velocity.length_squared() > 0.0:
		model.rotation.y = lerp_angle(model.rotation.y, spring_arm.rotation.y, delta / TIME_TO_FACE)

	var model_velocity = velocity * model.global_transform.basis
	anim_tree.set(
		"parameters/IWR/blend_position", Vector2(model_velocity.x, -model_velocity.z) / MAX_SPEED
	)
	anim_tree.set("parameters/conditions/is_on_floor", is_on_floor())
	anim_tree.set("parameters/conditions/is_in_air", !is_on_floor())

	move_and_slide()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		spring_arm.rotation.y -= event.relative.x * MOUSE_SENSITIVITY
		spring_arm.rotation_degrees.x = clamp(
			spring_arm.rotation_degrees.x - event.relative.y * MOUSE_SENSITIVITY, -90.0, 60.0
		)
		spring_arm.rotation.x -= event.relative.y * MOUSE_SENSITIVITY

	if event.is_action_pressed("attack"):
		anim_playback.travel(attack_animations.pick_random())


func _on_coyote_timer_timeout() -> void:
	can_jump = is_on_floor()
