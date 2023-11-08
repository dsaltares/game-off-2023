extends Leaf
class_name FollowPlayer


func tick(actor: Node, _blackboard: Blackboard) -> int:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return FAILURE

	actor.target_position = player.global_position
	actor.look_at_target = Vector3.ZERO
	return SUCCESS
