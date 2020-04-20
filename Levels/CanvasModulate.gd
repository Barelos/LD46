extends CanvasModulate

export var light_color = Color(0.5, 0.5, 0.5, 1)
export var dark_color = Color(0.05, 0.05, 0.05, 1)

func _process(delta: float) -> void:
	var fire = get_parent().get_node("fire")
	var level_timer = get_node("../Timer")
	var wood_modifier = fire.wood / fire.max_wood
	var time_modifier = 1 - level_timer.time_left / get_parent().time_limit
	color = dark_color.linear_interpolate(light_color, wood_modifier * 0.5 + time_modifier)
