extends StaticBody2D
class_name Fire

##################################
# FIRE SHAPE
##################################
onready var fire_shape = $light/area.shape
export var min_radius := 100
export var max_radius := 800
export var low_radius := 200

onready var radius_range = max_radius - min_radius
var radius

##################################
# FIRE BURN
##################################
export var starting_wood := 3
export var max_wood := 5
export var wood_burning_rate := 0.2
onready var wood := float(starting_wood)

signal low_fuel
signal extremly_low_fuel
signal player_hover
signal player_done
signal player_want_to_fuel

func _ready() -> void:
#	connect("low_fuel", db, "show_debug", ["Low fuel"])
#	connect("extremly_low_fuel", db, "show_debug", ["Super low fuel"])
	connect("player_hover", db, "show_debug", ["Fuel fire"])
	connect("player_done", db, "hide_debug")
	connect("player_want_to_fuel", get_tree().current_scene.get_node("world/player"), "fuel_fire")

func _process(delta: float) -> void:
	burn_wood(wood_burning_rate * delta)

func _update_radius():
	radius = min_radius + exp(-(max_wood - wood) * 0.8) * radius_range
#	radius = lerp(0, max_radius, wood / max_wood)
	fire_shape.radius = max(radius, min_radius)
	if radius < min_radius * 1.05:
		get_tree().quit()
	elif radius < min_radius * 1.2:
		emit_signal("extremly_low_fuel")
	elif radius < low_radius:
		emit_signal("low_fuel")

func _set_wood(val):
	wood = clamp(val, 0, max_wood)
	_update_radius()

func burn_wood(val: float) -> void:
	_set_wood(wood - val)

func add_wood(val: float) -> void:
	_set_wood(wood + val)
	_update_radius()

func _on_interactionArea_mouse_entered() -> void:
	if _player_in_range():
		emit_signal("player_hover")

func _on_interactionArea_mouse_exited() -> void:
	emit_signal("player_done")

func _on_interactionArea_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if _player_in_range() and event.is_action_pressed("invoke_action"):
		emit_signal("player_want_to_fuel", self)

func _player_in_range() -> bool:
	return $interactionRange.get_overlapping_bodies().size() > 0
