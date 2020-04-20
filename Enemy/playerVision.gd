extends Area2D

var player

func can_see_player():
	return player != null

func _on_playerVision_body_entered(body: Node) -> void:
	player = body

func _on_playerVision_body_exited(body: Node) -> void:
	player = null
