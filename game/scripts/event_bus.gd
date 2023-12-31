extends Node
class_name Events

signal player_loaded(coins: int, health: int)
signal player_coins_updated(coins: int)
signal player_health_updated(health: int)
signal player_died()
signal level_completed(coins: int)
