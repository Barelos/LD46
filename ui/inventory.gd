extends Control

var item_slot := preload("res://ui/slotItem.tscn")

func add_slot() -> void:
	$layout.add_child(item_slot.instance())

func remove_slot() -> void:
	$layout.get_child($layout.get_child_count() - 1).queue_free()

func add_item(idx: int, icon: StreamTexture) -> void:
	if idx >= $layout.get_child_count():
		return
	$layout.get_child(idx).get_node("icon").texture = icon 

func remove_item(idx: int) -> void:
	if idx >= $layout.get_child_count():
		return
	$layout.get_child(idx).get_node("icon").texture = null 
