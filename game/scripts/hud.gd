@tool
class_name HUD
extends Control

const DEFAULT_MAX_HEALTH = 3

@onready var fps_label: Label = %FPSLabel
@onready var coin_label: Label = %CoinLabel
@onready var hearts_container: HBoxContainer = %HeartsContainer

var EmptyHeart := preload("res://textures/hudHeart_empty.png")
var FullHeart := preload("res://textures/hudHeart_full.png")

var coins := 0
var health := 0
var max_health := DEFAULT_MAX_HEALTH

func _ready() -> void:
	EventBus.connect("player_loaded", _on_player_loaded)
	EventBus.connect("player_coins_updated", _on_player_coins_updated)
	EventBus.connect("player_health_updated", _on_player_health_updated)
	_update_hud()

func _process(_delta: float) -> void:
	fps_label.text = str(Engine.get_frames_per_second())

func _on_player_loaded(new_coins: int, new_health: int) -> void:
	coins = new_coins
	health = new_health
	max_health = new_health
	_update_hud()

func _on_player_coins_updated(new_coins: int) -> void:
	coins = new_coins
	_update_hud()
	
func _on_player_health_updated(new_health: int) -> void:
	health = new_health
	_update_hud()

func _update_hud() -> void:
	coin_label.text = str(coins)
	
	if hearts_container.get_child_count() != max_health:
		for heart in hearts_container.get_children():
			heart.queue_free()
		for i in range(max_health):
			var heart := TextureRect.new()
			hearts_container.add_child(heart)
	
	for i in range(health):
		var heart = hearts_container.get_child(i) as TextureRect
		heart.texture = FullHeart
	
	for i in range(hearts_container.get_child_count() - health):
		var heart = hearts_container.get_child(health + i) as TextureRect
		heart.texture = EmptyHeart
