extends Control
class_name HUD

@onready var fps_label: Label = %FPSLabel

func _ready() -> void:
	EventBus.connect("player_coins_updated", _on_player_coins_updated)
	EventBus.connect("player_health_updated", _on_player_health_updated)

func _process(_delta: float) -> void:
	fps_label.text = str(Engine.get_frames_per_second())

func _on_player_coins_updated(coins: int) -> void:
	print('coins: ', coins)
	
func _on_player_health_updated(health: int) -> void:
	print('health: ', health)
