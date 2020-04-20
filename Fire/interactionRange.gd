extends Area2D

func _on_interactionRange_body_entered(body: Node) -> void:
	if randf() <= 0.5:
		get_parent().say_hello()
