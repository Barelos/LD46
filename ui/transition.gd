extends Control

func show_next_level() -> void:
	$nextLevel.show()
	$nextLevel.connect("pressed", get_tree().current_scene.get_node("world"), "start_level")
	$nextLevel.connect("pressed", self, "hide")
	$nextLevel.connect("pressed", get_node("../mainUI"), "show")
	$nextLevel.connect("pressed", get_node("../mainUI"), "reset")

func init(title, flavor, icon):
	$Label.text = title
	$RichTextLabel.text = flavor
	$beauitifulMap.texture = icon


func _on_mainMenu_pressed() -> void:
	get_node("../mainUI").hide()
	get_node("../mainMenu").show()
	$mainMenu.hide()

func _on_nextLevel_pressed() -> void:
	for e in get_tree().get_nodes_in_group("enemy"):
		e.go = true
	
