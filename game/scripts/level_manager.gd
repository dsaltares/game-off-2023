extends Node3D
class_name LevelManager

const SAVE_GAME_PATH = "user://save.cfg"
const SAVE_GAME_SECTION = "SaveGame"

@onready var level_slot: Node3D = $LevelSlot
@onready var transitions: CanvasLayer = %Transitions

var levels : PackedStringArray = []
var num_levels := 0

func _ready() -> void:
	levels = DirAccess.get_files_at("res://scenes/levels")
	num_levels = levels.size()
	
	EventBus.connect("player_died", _on_player_died)
	
	load_level(1)

	
func _on_player_died() -> void:
	await get_tree().create_timer(1.0).timeout	
	load_level(1)
	

func load_level(level_num: int) -> void:
	if level_slot.get_child_count() > 0:
		await transitions.fade_out()
	
	for child in level_slot.get_children():
		child.queue_free()
	
	var path := "res://scenes/levels/level_{level_num}.tscn".format({ "level_num": "%0*d" % [2, level_num] })
	if !FileAccess.file_exists(path):
		return
		
	var LevelScene := load(path) as PackedScene
	var level := LevelScene.instantiate()
	level_slot.add_child(level)
	
	await transitions.fade_in()
