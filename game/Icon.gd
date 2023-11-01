extends Sprite2D

var colors: Array[Color] = [Color.REBECCA_PURPLE, Color.SEA_GREEN, Color.ALICE_BLUE, Color.RED]
var color_index: int = 0

func _ready() -> void:
	modulate = colors[color_index]

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		next_color()

func apply_color() -> void:
	modulate = colors[color_index]

func next_color() -> void:
	color_index = (color_index + 1) % colors.size()
	apply_color()
