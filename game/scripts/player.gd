extends CharacterBody3D
class_name Player

const MOUSE_SENSITIVITY := 0.005
const MAX_SPEED := 8.0
const JUMP_HEIGHT := 4.1
const JUMP_DISTANCE_TO_PEAK := 3.5
const JUMP_DISTANCE_AFTER_PEAK := 2.5
const HIGH_JUMP_HEIGHT := 9.0
const HIGH_JUMP_DISTANCE_TO_PEAK := 7.0
const HIGH_JUMP_DISTANCE_AFTER_PEAK := 5.0
const TIME_TO_MAX_SPEED := 0.25
const TIME_TO_HALT := 0.15
const TIME_TO_HALT_AIR := 1.0
const TIME_TO_FACE := 0.1
const LAND_EFFECT_HEIGHT_THRESHOLD := 4.0

@export var camera_rig: CameraRig

@onready var coyote_timer := %CoyoteTimer
@onready var anim_tree := %AnimationTree
@onready var anim_player: AnimationPlayer = %AnimationPlayer
@onready var model := %Rig
@onready var running_trail := %RunningTrail
@onready var landing_effect := %LandingEffect
@onready var immunity_timer := %ImmunityTimer
@onready var damage_area := %DamageArea

const attack_types: Array[float] = [-1, -0.5, 0, 1]
const attack_animations := {
	"1H_Melee_Attack_Slice_Diagonal": true,
	"1H_Melee_Attack_Slice_Horizontal": true,
	"1H_Melee_Attack_Chop": true,
	"1H_Melee_Attack_Stab": true,
}

enum JumpMode {
	NO_JUMP,
	JUMP,
	HIGH_JUMP,
}

var can_jump := false
var attacking := false
var was_on_floor := false
var is_dead := false
var max_jump_height := 0.0
var jump_mode := JumpMode.NO_JUMP
var target_angle := 0.0
var health: int = 3
var coins: int = 0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	if camera_rig == null:
		return

	_update_vertical_movement(delta)
	_update_horizontal_movement(delta)
	_handle_actions()
	_update_animations()
	_update_damage_area()

	was_on_floor = is_on_floor()
	move_and_slide()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_coyote_timer_timeout() -> void:
	can_jump = is_on_floor()


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if attack_animations.has(anim_name):
		attacking = false
		damage_area.monitoring = false

func _update_damage_area() -> void:
	if !damage_area.monitoring:
		return

	for body in damage_area.get_overlapping_bodies():
		if body.has_method("die"):
			body.die()

func _update_vertical_movement(delta: float) -> void:
	if is_on_floor() and not was_on_floor:
		if max_jump_height - global_position.y > LAND_EFFECT_HEIGHT_THRESHOLD:
			landing_effect.restart()
			landing_effect.emitting = true

		can_jump = true
		max_jump_height = 0.0

	else:
		max_jump_height = max(max_jump_height, global_position.y)

		var jump_height := HIGH_JUMP_HEIGHT if jump_mode == JumpMode.HIGH_JUMP else JUMP_HEIGHT
		var section_distance := 0.0
		if jump_mode == JumpMode.HIGH_JUMP:
			section_distance = (
				HIGH_JUMP_DISTANCE_TO_PEAK if velocity.y > 0.0 else HIGH_JUMP_DISTANCE_AFTER_PEAK
			)
		else:
			section_distance = (
				JUMP_DISTANCE_TO_PEAK if velocity.y > 0.0 else JUMP_DISTANCE_AFTER_PEAK
			)

		var gravity = 2 * jump_height * pow(MAX_SPEED, 2) / pow(section_distance, 2)
		velocity.y -= gravity * delta

		if coyote_timer.is_stopped():
			coyote_timer.start()


func _update_horizontal_movement(delta: float) -> void:
	var input_dir := (
		Input.get_vector("left", "right", "forward", "backward") if !is_dead else Vector2.ZERO
	)
	var direction := Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, camera_rig.rotation.y)
	var time_to_halt := TIME_TO_HALT if is_on_floor() else TIME_TO_HALT_AIR
	var acceleration := MAX_SPEED / TIME_TO_MAX_SPEED if direction else MAX_SPEED / time_to_halt
	var horizontal_speed := clampf(
		Vector2(velocity.x, velocity.z).length() + acceleration * delta, 0, MAX_SPEED
	)
	velocity.x = direction.x * horizontal_speed
	velocity.z = direction.z * horizontal_speed

	var horizontal_velocity := Vector2(velocity.x, velocity.z)

	if horizontal_velocity.length_squared() > 0:
		target_angle = Vector2(-velocity.z, -velocity.x).angle()

	rotation.y = lerp_angle(rotation.y, target_angle, delta / TIME_TO_FACE)
	model.scale = lerp(model.scale, Vector3(1, 1, 1), delta / 0.2)


func _handle_actions() -> void:
	if is_dead:
		return

	if Input.is_action_just_pressed("attack") and not attacking:
		anim_tree.set("parameters/attack_type/blend_position", attack_types.pick_random())
		anim_tree.set("parameters/attack/request", true)
		attacking = true
		damage_area.monitoring = true

	if Input.is_action_just_pressed("jump") and can_jump:
		_start_jump(JumpMode.JUMP)


func _update_animations() -> void:
	anim_tree.set(
		"parameters/locomotion/IWR/blend_position",
		Vector2(velocity.x, velocity.z).length() / MAX_SPEED
	)
	anim_tree.set("parameters/locomotion/conditions/is_on_floor", is_on_floor())
	anim_tree.set("parameters/locomotion/conditions/is_in_air", !is_on_floor())
	anim_tree.set("parameters/locomotion/conditions/is_dead", is_dead)

	var horizontal_velocity := Vector2(velocity.x, velocity.z)
	running_trail.emitting = horizontal_velocity.length() > 1.0 and is_on_floor() and !is_dead


func _start_jump(mode: JumpMode) -> void:
	jump_mode = mode
	var jump_height := JUMP_HEIGHT if mode == JumpMode.JUMP else HIGH_JUMP_HEIGHT
	var section_distance := (
		JUMP_DISTANCE_TO_PEAK if mode == JumpMode.JUMP else HIGH_JUMP_DISTANCE_TO_PEAK
	)
	velocity.y = 2 * jump_height * MAX_SPEED / section_distance
	can_jump = false
	model.scale = Vector3(0.75, 1.25, 0.75)


func damage() -> void:
	if !immunity_timer.is_stopped() or is_dead:
		return

	health -= 1
	EventBus.emit_signal("player_health_updated", health)

	if health == 0:
		die()
	else:
		anim_tree.set("parameters/damage/request", true)
		immunity_timer.start()


func die() -> void:
	is_dead = true
	EventBus.emit_signal("player_died")


func high_jump() -> void:
	_start_jump(JumpMode.HIGH_JUMP)

func pick_up_coin() -> void:
	coins += 1
	EventBus.emit_signal("player_coins_updated", coins)

func pick_up_gem() -> void:
	anim_tree.set("parameters/win/request", true)
	await get_tree().create_timer(anim_player.get_animation('Cheer').length).timeout
	EventBus.emit_signal("level_completed")
