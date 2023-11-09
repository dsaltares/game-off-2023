extends ActionLeaf
class_name FollowPatrol

const arrive_thresold_sq = 0.5 * 0.5

var path_idx: int


func tick(actor: Node, _blackboard: Blackboard) -> int:
	if not actor.patrol:
		return FAILURE

	if path_idx == null:
		path_idx = get_closest_patrol_point_idx(actor)

	var point = get_patrol_point_at_idx(actor, path_idx)
	var distance_sq = get_distance_sq(actor, point)
	if distance_sq < arrive_thresold_sq:
		path_idx = (path_idx + 1) % actor.patrol.curve.point_count

	actor.target_position = get_patrol_point_at_idx(actor, path_idx)
	actor.look_at_target = Vector3.ZERO

	return RUNNING


func get_patrol_point_at_idx(actor: Node, idx: int) -> Vector3:
	return actor.patrol.curve.get_point_position(idx) + actor.patrol.global_position


func get_closest_patrol_point_idx(actor: Node) -> int:
	var min_distance_sq := INF
	var closest_idx := 0

	for idx in range(actor.patrol.curve.point_count):
		var point := get_patrol_point_at_idx(actor, idx)
		var distance_sq := get_distance_sq(actor, point)
		if distance_sq < min_distance_sq:
			min_distance_sq = distance_sq
			closest_idx = idx

	return closest_idx


func get_distance_sq(actor: Node, point: Vector3) -> float:
	return ((point - actor.global_position) * Vector3(1.0, 0.0, 1.0)).length_squared()
