extends StaticBody3D
class_name Bouncer

@onready var anim_tree: AnimationNodeStateMachinePlayback = %AnimationTree.get('parameters/playback')


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method('high_jump'):
		body.high_jump()
		anim_tree.travel("Bounce")
