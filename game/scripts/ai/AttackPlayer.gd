extends Leaf
class_name AttackPlayer


func tick(actor: Node, blackboard: Blackboard) -> int:
	var player = get_tree().get_first_node_in_group('player')
	if not player:
		return FAILURE
		
	actor.target_position = Vector3.ZERO
	actor.look_at_target = player.global_position
	actor.attack()
	return SUCCESS

