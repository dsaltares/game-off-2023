extends CanvasLayer
class_name Transitions

const TRANSITION_DURATION := 1.0

@onready var black_texture: TextureRect = %BlackTexture

func fade_in() -> void:
	black_texture.modulate = Color.WHITE
	var tween := get_tree().create_tween()
	(
		tween
		. tween_property(black_texture, 'modulate', Color(Color.WHITE, 0.0), TRANSITION_DURATION)
		. set_ease(Tween.EASE_IN_OUT)
		. set_trans(Tween.TRANS_QUAD)
	)
	tween.play()
	await tween.finished

func fade_out() -> void:
	black_texture.modulate = Color(Color.WHITE, 0.0)
	var tween := get_tree().create_tween()
	(
		tween
		. tween_property(black_texture, 'modulate', Color.WHITE, TRANSITION_DURATION)
		. set_ease(Tween.EASE_IN_OUT)
		. set_trans(Tween.TRANS_QUAD)
	)
	tween.play()
	await tween.finished
