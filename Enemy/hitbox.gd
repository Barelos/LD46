extends Area2D

func can_hit_target(target):
	return target in get_overlapping_bodies()

func get_closest_light_source():
	var closest = null
	var dist = INF
	for area in get_overlapping_areas():
		var cur_dist = position.distance_to(area.position)
		if area.is_in_group("light") and cur_dist < dist:
			dist = cur_dist
			closest = area.get_parent()
	return closest
