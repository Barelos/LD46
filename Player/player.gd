extends KinematicBody2D
class_name Player

enum {MOVE, ACTION, DODGE}
var current_state := MOVE

var inventory = {}

onready var animation_player = $characterRig/AnimationPlayer
onready var rig_scale = $characterRig.scale.x
onready var audio = $audio
export var speed := 200
export var accelaration := 20

export var inventory_size := 3
var current_items := 0

export var hit_points := 3
var speeding := false

var current_accelaration := Vector2()

export var torch_length := 6.0
var torch_lit = false
onready var timer = $Timer

signal pick_item
signal player_died

var hurt_saying = [
	"Dammit",
	"That hurt",
	"Stop it",
	"Basterds"
]

var torch_light_saying = [
	"This is better",
	"Finally I can see",
	"Take that ugly basterds",
	"How about a torch light dinner.\nWait...that makes me the main course..."
]

var item_pickup_saying = [
	"That's helpful",
	"Ahh I can use this",
	"Alice would love this"
]

func _ready() -> void:
	var inventory_ui = get_tree().current_scene.get_node("canvas/ui/inventory")
	inventory_ui.reset_slots()
	for i in range(inventory_size):
		inventory[i] = null
		inventory_ui.add_slot()
	connect("pick_item", get_tree().current_scene.get_node("canvas/ui/inventory"), "add_item")
	timer.connect("timeout", self, "torch_over")
	connect("player_died", get_tree().current_scene, "defeat")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("light_torch"):
		if torch_lit:
			return
		for key in inventory.keys():
			if inventory[key] != null and inventory[key].item_name == "torch":
				light_torch()
				inventory[key] = null
				get_tree().current_scene.get_node("canvas/ui/inventory").remove_item(key)
				return

func _physics_process(delta: float) -> void:
	match current_state:
		MOVE:
			_move_state(delta)
		ACTION:
			pass
		DODGE:
			pass

func _move_state(delta) -> void:
	var force = Vector2()
	force.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	force.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	if force != Vector2():
		force = force.normalized()
		if force.x < 0:
			$characterRig.scale.x = rig_scale
		elif force.x > 0:
			$characterRig.scale.x = -rig_scale
		if torch_lit:
			animation_player.play("torch_walk")
		else:
			animation_player.play("walk")
		current_accelaration = current_accelaration.move_toward(force*speed, accelaration)
		speeding = true
	else:
		if torch_lit:
			animation_player.play("torch_idle")
		else:
			animation_player.play("idle")
		current_accelaration = current_accelaration.move_toward(Vector2(), accelaration)
		speeding = false
	move_and_slide(current_accelaration)

func _get_free_key() -> int:
	for key in inventory.keys():
		if inventory[key] == null:
			return key
	return -1

func pick_item(item: Pickable) -> void:
	# test if there is room in inventory
	var free_key = _get_free_key()
	if free_key == -1:
		# TODO add prompt
		return
	say(item_pickup_saying[randi() % item_pickup_saying.size()], 2)
	# TODO add to this place
	audio.stream = load("res://Assets/sound/basket.wav")
	audio.play()
	inventory[free_key] = item
	emit_signal("pick_item", free_key, item.icon)
	item.picked_up()

func drop_item(key: int) -> void:
	if inventory[key] == null:
		return
	# TODO drop item

func fuel_fire(fire: Fire):
	for key in inventory.keys():
		if inventory[key] != null and inventory[key].item_name == "wood":
			fire.add_wood(1)
			inventory[key].queue_free()
			inventory[key] = null
			get_tree().current_scene.get_node("canvas/ui/inventory").remove_item(key)
			return

func take_hit(val):
	hit_points -= val
	get_tree().current_scene.get_node("canvas/mainUI/playerLife").hit()
	audio.stream = load("res://Assets/sound/hurt1.wav")
	audio.play()
	say(hurt_saying[randi() % hurt_saying.size()], 2)
	if hit_points <= 0:
		emit_signal("player_died")
	else:
		animation_player.play("hit")

func light_torch():
	torch_lit = true
	audio.stream = load("res://Assets/sound/firelit.wav")
	audio.play()
	say(torch_light_saying[randi() % torch_light_saying.size()], 2)
	$light.monitorable = true
	$light.monitoring = true
	$Light2D.show()
	$characterRig/body/arm/torch.show()
	timer.start(torch_length)

func torch_over():
	torch_lit = false
	$light.monitorable = false
	$light.monitoring = false
	$Light2D.hide()
	$characterRig/body/arm/torch.hide()

func say(msg, time):
	get_tree().current_scene.get_node("canvas/mainUI/playerLife").say(msg, time)
