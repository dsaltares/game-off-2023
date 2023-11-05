@tool

extends Node3D
class_name Bridge

@export var length := 6.0 : set = _set_length, get = _get_length

const segment_length := 3.0

@onready var segments : Node3D = %Segments

var BridgeStartScene := preload("res://scenes/bridge/bridge_start.tscn")
var BridgeMiddleScene := preload("res://scenes/bridge/bridge_middle.tscn")

func _ready() -> void:
	_update_segments()

func _update_segments() -> void:
	if !segments:
		return
		
	for child in segments.get_children():
		child.queue_free()

	var num_segments := ceili(length / segment_length)
	var bridge_start = BridgeStartScene.instantiate()
	segments.add_child(bridge_start)
	
	for segment in range(num_segments - 1):
		var bridge_middle = BridgeMiddleScene.instantiate()
		bridge_middle.position = Vector3(0.0, 0.0, -(segment + 1) * segment_length)
		segments.add_child(bridge_middle)
	
	var bridge_end = BridgeStartScene.instantiate()
	bridge_end.position = Vector3(0.0, 0.0, -num_segments * segment_length)
	bridge_end.rotation_degrees.y = 180.0
	segments.add_child(bridge_end)
	
func _set_length(new_length: float) -> void:
	length = new_length
	_update_segments()
	
func _get_length() -> float:
	return length
