extends Node3D
class_name LevelManager

const SAVE_GAME_PATH = "user://save.cfg"
const SAVE_GAME_SECTION = "SaveGame"

@onready var level_slot: Node3D = $LevelSlot
@onready var transitions: CanvasLayer = %Transitions

var levels : PackedStringArray = []
var num_levels := 0
var current_level := 0

func _ready() -> void:
	levels = DirAccess.get_files_at("res://scenes/levels")
	num_levels = levels.size()
	
	EventBus.connect("player_died", _on_player_died)
	EventBus.connect("level_completed", _on_level_completed)
	
	load_game()
	load_level()

	
func _on_player_died() -> void:
	await get_tree().create_timer(1.0).timeout	
	load_level()
	

func _on_level_completed() -> void:
	print('level completed')
	save_game()

func load_level() -> void:
	if level_slot.get_child_count() > 0:
		await transitions.fade_out()
	
	for child in level_slot.get_children():
		child.queue_free()
		
	var LevelScene := load("res://scenes/levels/" + levels[current_level]) as PackedScene
	var level := LevelScene.instantiate()
	level_slot.add_child(level)
	
	await transitions.fade_in()

func save_game() -> void:
	var config := ConfigFile.new()
	config.set_value(SAVE_GAME_SECTION, 'current_level', current_level)
	config.save(SAVE_GAME_PATH)
	print('game saved')
	
func load_game() -> void:
	print('loading from: ', OS.get_data_dir())
	var config := ConfigFile.new()
	var err := config.load(SAVE_GAME_PATH)
	
	if err != OK:
		current_level = 0
		print('could not load game')
		return
	
	current_level = config.get_value(SAVE_GAME_SECTION, 'current_level', 0)
	print('game loaded')
