extends Node

const SAVE_GAME_PATH = "user://save.cfg"
const SAVE_GAME_SECTION = "SaveGame"

var current_level := 1
var coins := 0

func _ready() -> void:
	EventBus.connect("level_completed", _on_level_completed)
	load_game()

func save_game() -> void:
	var config := ConfigFile.new()
	config.set_value(SAVE_GAME_SECTION, 'current_level', current_level)
	config.set_value(SAVE_GAME_SECTION, 'coins', coins)
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
	coins = config.get_value(SAVE_GAME_SECTION, 'coins', 0)
	print('game loaded')
	
func _on_level_completed(collected_coins: int) -> void:
	print('level completed with coins ', collected_coins)
	coins += collected_coins
	print('total coins ', coins)
	save_game()
