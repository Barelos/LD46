extends Area2D

var light

func can_see_light():
	return light != null

func _on_playerVision_body_entered(body: Node) -> void:
	light = body

func _on_playerVision_body_exited(body: Node) -> void:
	light = null

func _on_lightVision_area_shape_entered(area_id: int, area: Area2D, area_shape: int, self_shape: int) -> void:
	light = area.get_parent()

func _on_lightVision_area_shape_exited(area_id: int, area: Area2D, area_shape: int, self_shape: int) -> void:
	light = null
