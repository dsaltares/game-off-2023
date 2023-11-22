extends Node3D
class_name LevelManager

const LEVELS : Array[String] = [
	"res://scenes/levels/level_01.tscn",
]

@onready var level_slot: Node3D = $LevelSlot
@onready var transitions: CanvasLayer = %Transitions

func _ready() -> void:
	
	EventBus.connect("player_died", _on_player_died)
	
	load_level(1)

	
func _on_player_died() -> void:
	await get_tree().create_timer(1.0).timeout	
	load_level(1)
	

func load_level(level_num: int) -> void:
	if level_num > LEVELS.size():
		return 
	
	if level_slot.get_child_count() > 0:
		await transitions.fade_out()
	
	for child in level_slot.get_children():
		child.queue_free()
	
	var level_file := LEVELS[level_num - 1]
	print('loading ', level_file)
		
	var LevelScene := load(level_file) as PackedScene
	var level := LevelScene.instantiate()
	level_slot.add_child(level)
	
	await transitions.fade_in()
