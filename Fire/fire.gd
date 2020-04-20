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
signal fire_died

##################################
# FIRE BURN
##################################
export var hitpoints := 3

var say_again = true

var hurt_saying = [
	"Dad they can reach me!",
	"Help dad!",
	"AHHHHH!"
]

var dad_close_saying = [
	"Hello there",
	"Where have you been.\nI've been scared.",
	"Good to se you again, was starting to think you were going to bring milk."
]

var wood_recived_saying = [
	"Thanks dad",
	"Ahh nice and warm",
	"Another wood another...never mind I hanvn't thought this through"
]

func _ready() -> void:
#	connect("low_fuel", db, "show_debug", ["Low fuel"])
#	connect("extremly_low_fuel", db, "show_debug", ["Super low fuel"])
	connect("player_hover", db, "show_debug", ["Collect wood and put in here"])
	connect("player_done", db, "hide_debug")
	connect("player_want_to_fuel", get_tree().current_scene.get_node("world/player"), "fuel_fire")
	connect("fire_died", get_tree().current_scene, "defeat")

func _process(delta: float) -> void:
	burn_wood(wood_burning_rate * delta)

func _update_radius(val=null):
	if val != null:
		radius = val
	else:
		radius = min_radius + exp(-(max_wood - wood) * 0.8) * radius_range
	$Light2D.scale = Vector2.ONE * radius * 0.002
	fire_shape.radius = max(radius, min_radius)
	if radius < min_radius * 1.05:
#		say("The fire is out dad, I can't see anything!", 2)
		pass
	elif radius < min_radius * 1.2:
		say("Dead we are almost out of wood, hurry!", 2)
		emit_signal("extremly_low_fuel")
	elif radius < low_radius:
#		say("We are starting to get low on wood father", 2)
		emit_signal("low_fuel")

func _set_wood(val):
	wood = clamp(val, 0, max_wood)
	_update_radius()

func burn_wood(val: float) -> void:
	_set_wood(wood - val)
	if wood <= 0.5:
		_update_radius(5)

func add_wood(val: float) -> void:
	say(wood_recived_saying[randi() % wood_recived_saying.size()], 2)
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

func take_hit(val):
	hitpoints -= val
	say(hurt_saying[randi() % hurt_saying.size()], 2)
	play_hurt()
	get_tree().current_scene.get_node("canvas/mainUI/childLife").hit()
	if hitpoints <= 0:
		emit_signal("fire_died")

func play_hurt():
	$audio.stream = load("res://Assets/sound/girlattacked2.wav")
	$audio.play()

func say(msg, time):
	get_tree().current_scene.get_node("canvas/mainUI/childLife").say(msg, time)

func say_hello():
	say(dad_close_saying[randi() % dad_close_saying.size()], 2)
