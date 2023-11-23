@tool
class_name ControlHint
extends Node3D

@onready var label_3d: Label3D = %Label3D
@onready var sprite_3d: Sprite3D = %Sprite3D

@export_enum("Move", "Look", "Jump", "Attack") var action := 'Move' : get = get_action, set = set_action

const ActionTextures := {
	'Move': {
		'none': preload("res://textures/controls/Keyboard/Dark/wasd.png"),
		'xbox': preload("res://textures/controls/Xbox/XboxSeriesX_Left_Stick.png"),
		'playstation': preload("res://textures/controls/PS4/PS4_Left_Stick.png"),
		'steamdeck': preload("res://textures/controls/Steam/SteamDeck_Left_Stick.png"),
	},
	'Look': {
		'none': preload("res://textures/controls/Keyboard/Dark/Mouse_Simple_Key_Dark.png"),
		'xbox': preload("res://textures/controls/Xbox/XboxSeriesX_Right_Stick.png"),
		'playstation': preload("res://textures/controls/PS4/PS4_Right_Stick.png"),
		'steamdeck': preload("res://textures/controls/Steam/SteamDeck_Right_Stick.png"),
	},
	'Jump': {
		'none': preload("res://textures/controls/Keyboard/Dark/Space_Key_Dark.png"),
		'xbox': preload("res://textures/controls/Xbox/XboxSeriesX_A.png"),
		'playstation': preload("res://textures/controls/PS4/PS4_Cross.png"),
		'steamdeck': preload("res://textures/controls/Steam/SteamDeck_A.png"),
	},
	'Attack': {
		'none': preload("res://textures/controls/Keyboard/Dark/Mouse_Left_Key_Dark.png"),
		'xbox': preload("res://textures/controls/Xbox/XboxSeriesX_B.png"),
		'playstation': preload("res://textures/controls/PS4/PS4_Circle.png"),
		'steamdeck': preload("res://textures/controls/Steam/SteamDeck_B.png"),
	},
}

func _ready() -> void:
	_update_ui()


func get_controller_type() -> String:
	const controller_names_by_type := {
		'xbox': ['xbox'],
		'playstation': ['dualshock', 'dualsense', 'ps4', 'ps5', 'sony', 'playstation'],
		'steamdeck': ['steam']
	}

	if Input.get_connected_joypads().size() == 0:
		return 'none'

	var joypad_name = Input.get_joy_name(0).to_lower()
	for controller_type in controller_names_by_type.keys():
		for name in controller_names_by_type.get(controller_type):
			if joypad_name.find(name) != -1:
				return controller_type

	return 'none'
	
func get_action() -> String:
	return action

func set_action(new_action: String) -> void:
	action = new_action
	_update_ui()
	
func _update_ui() -> void:
	if !label_3d or !sprite_3d:
		return
		
	var controller := get_controller_type()
	var texture = ActionTextures.get(action, {}).get(controller)
	sprite_3d.texture = texture
	label_3d.text = action
	
