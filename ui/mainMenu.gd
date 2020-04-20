extends Control

signal start_game

func _ready() -> void:
	var main = get_tree().current_scene
	connect("start_game", main, "start_game") 

func _on_instrucitons_pressed() -> void:
	$Instructions.show()

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_newGame_pressed() -> void:
	hide()
	emit_signal("start_game")
