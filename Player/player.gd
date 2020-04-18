extends KinematicBody2D
class_name Player

enum {MOVE, ACTION, DODGE}
var current_state := MOVE

var inventory = {}

export var speed := 200
export var accelaration := 20

export var inventory_size := 3
var current_items := 0

var current_accelaration := Vector2()

signal pick_item

func _ready() -> void:
	var inventory_ui = get_tree().current_scene.get_node("ui/inventory")
	for i in range(inventory_size):
		inventory[i] = null
		inventory_ui.add_slot()
	connect("pick_item", get_tree().current_scene.get_node("ui/inventory"), "add_item")

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
		current_accelaration = current_accelaration.move_toward(force*speed, accelaration)
	else:
		current_accelaration = current_accelaration.move_toward(Vector2(), accelaration)
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
	# TODO add to this place
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
			get_tree().current_scene.get_node("ui/inventory").remove_item(key)
			return
