extends Node

onready var db_bg = get_tree().current_scene.get_node("canvas/ui/bg")
onready var db_label = db_bg.get_node("debug")

func _ready() -> void:
	pass

func show_debug(msg: String, time: float=2) -> void:
	db_bg.show()
	db_label.text = msg

func hide_debug() -> void:
	db_bg.hide()
