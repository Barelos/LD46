extends Camera2D

export var max_zoom := 1.1
export var zoom_speed = 0.9
export var dezoom_speed = 0.7
onready var parent = $".."

var zoom_factor := 1.0

func _process(delta: float) -> void:
	if parent.speeding:
		zoom_factor += zoom_speed * delta
	else:
		zoom_factor -= dezoom_speed * delta
	zoom_factor = clamp(zoom_factor, 1, max_zoom)
	zoom = Vector2.ONE * zoom_factor
