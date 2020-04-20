extends Area2D
class_name Pickable

export var action_name := "test"
export var icon: StreamTexture
export var item_name := "wood"

export var lifetime := 3
onready var timer := $Timer

signal player_hover
signal player_done
signal player_want_to_pick

func _ready() -> void:
#	connect("player_hover", db, "show_debug", [action_name])
	connect("player_done", db, "hide_debug")
	connect("player_want_to_pick", get_tree().current_scene.get_node("world/player"), "pick_item")
	timer.connect("timeout", self, "queue_free")

func _on_PickableItem_mouse_entered() -> void:
	if _is_player_in_range():
		db.show_debug(action_name)
		emit_signal("player_hover")

func _on_PickableItem_mouse_exited() -> void:
	emit_signal("player_done")

func _on_PickableItem_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("invoke_action") and _is_player_in_range():
		emit_signal("player_want_to_pick", self)

func picked_up() -> void:
	timer.stop()
	hide()

func thrown() -> void:
	timer.start(lifetime)

func _is_player_in_range() -> bool:
	return $reach.get_overlapping_bodies().size() > 0
