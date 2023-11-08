extends CharacterBody3D
class_name GreenMonster

@export var patrol : Path3D
@export var detect_player_range := 5.0
@export var attack_player_range := 2.0

const MAX_SPEED := 5
const TIME_TO_HALT = 0.2
const TIME_TO_FACE := 0.2
const TIME_TO_MAX_SPEED = 0.3
const ARRIVE_DISTANCE = 0.05

@onready var anim_tree := %AnimationTree
@onready var anim_state_machine: AnimationNodeStateMachinePlayback = %AnimationTree.get(
	"parameters/playback"
)
@onready var anim_player: AnimationPlayer = %AnimationPlayer
@onready var damage_area := %DamageArea

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var target_angle := 0.0
var target_position := Vector3.ZERO
var look_at_target := Vector3.ZERO
var is_dead := false
var attacking := false


func _physics_process(delta: float) -> void:
	_update_vertical_velocity(delta)
	_update_horizontal_velocity(delta)
	_update_look_at(delta)
	_update_animations()
	_update_damage_area()

	move_and_slide()


func _update_vertical_velocity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta


func _update_horizontal_velocity(delta: float) -> void:
	var pos_to_target := (target_position - global_position) * Vector3(1.0, 0.0, 1.0)
	var direction_to_target := pos_to_target.normalized()
	var distance_to_target := pos_to_target.length()
	var direction := Vector3.ZERO

	if target_position and distance_to_target > ARRIVE_DISTANCE and !is_dead:
		direction = direction_to_target

	var acceleration := MAX_SPEED / TIME_TO_MAX_SPEED if direction else MAX_SPEED / TIME_TO_HALT
	var horizontal_speed := clampf(
		Vector2(velocity.x, velocity.z).length() + acceleration * delta, 0, MAX_SPEED
	)
	velocity.x = direction.x * horizontal_speed
	velocity.z = direction.z * horizontal_speed


func _update_animations() -> void:
	var horizontal_velocity := Vector2(velocity.x, velocity.z)
	var horizontal_speed := horizontal_velocity.length()
	anim_tree.set("parameters/IWR/blend_position", horizontal_speed / MAX_SPEED)
	anim_tree.set("parameters/conditions/is_dead", is_dead)


func _update_look_at(delta: float) -> void:
	if is_dead:
		return

	if look_at_target:
		var look_at_dir := (look_at_target - global_position).normalized()
		target_angle = Vector2(-look_at_dir.z, -look_at_dir.x).angle()
	elif velocity.x > 0.0 or velocity.z > 0.0:
		target_angle = Vector2(-velocity.z, -velocity.x).angle()

	global_rotation.y = lerp_angle(global_rotation.y, target_angle, delta / TIME_TO_FACE)


func _update_damage_area() -> void:
	for body in damage_area.get_overlapping_bodies():
		if body.has_method('damage'):
			body.damage()

func attack() -> void:
	if attacking:
		return
		
	anim_state_machine.travel("Bite")
	attacking = true
	await get_tree().create_timer(0.2).timeout
	damage_area.monitoring = true
	

func die() -> void:
	is_dead = true
	await get_tree().create_timer(4.0).timeout
	queue_free()


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == 'Bite_Front':
		attacking = false
		damage_area.monitoring = false
