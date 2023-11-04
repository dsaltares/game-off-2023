extends StaticBody3D
class_name Cannon

var BulletScene = preload("res://scenes/cannon_ball.tscn")

@onready var shooting_point: Node3D = %ShootingPoint
@onready var fire_timer: Timer = %FireTimer

@export var wait_time := 2.0


func _ready() -> void:
	fire_timer.wait_time = wait_time


func spawn_bullet() -> void:
	var cannon_ball = BulletScene.instantiate()
	cannon_ball.global_transform = shooting_point.global_transform
	get_tree().root.add_child(cannon_ball)
