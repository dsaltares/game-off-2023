extends ConditionLeaf
class_name PlayerInRange


func tick(actor: Node, _blackboard: Blackboard) -> int:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return FAILURE

	var distance_sq = (
		((player.global_position - actor.global_position) * Vector3(1.0, 0.0, 1.0)).length_squared()
	)

	if distance_sq <= actor.detect_player_range * actor.detect_player_range:
		return SUCCESS

	return FAILURE
