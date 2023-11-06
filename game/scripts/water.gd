@tool

extends Node3D
class_name Water

@export var water_size := Vector2(10.0, 10.0): set = _set_size, get = _get_size

@onready var collision_shape := %CollisionShape3D
@onready var mesh_instance := %Mesh

var shader := preload("res://materials/water.tres")

func _ready() -> void:
	_update_size()

func _set_size(new_size: Vector2) -> void:
	water_size = new_size
	_update_size()
	
func _get_size() -> Vector2:
	return water_size
	
func _update_size() -> void:
	if !mesh_instance or !collision_shape:
		return
		
	var plane := PlaneMesh.new()
	plane.size = water_size
	plane.subdivide_width = water_size.x
	plane.subdivide_depth = water_size.y
	plane.material = ShaderMaterial.new()
	plane.material.shader = shader
	mesh_instance.mesh = plane
	
	var box_shape := BoxShape3D.new()
	box_shape.size.x = water_size.x
	box_shape.size.y = 1.0
	box_shape.size.z = water_size.y
	collision_shape.shape = box_shape


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method('die'):
		body.die()
