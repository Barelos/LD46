extends Node

export (Array, PackedScene) var levels

export var victory_title := ""
export (String, MULTILINE) var victory_text
export var victory_im: StreamTexture

export var loose_title := ""
export (String, MULTILINE) var loose_text
export var loose_im: StreamTexture

var current_level = -1

signal victory

func _ready() -> void:
#	OS.window_fullscreen = true
#	OS.window_maximized = true
	connect("victory", $canvas/victoryScreen, "show_victory")

func start_game():
	next_level()

func next_level() -> void:
	current_level += 1
	if current_level >= levels.size():
		victory()
		return
	var new_level = levels[current_level].instance()
	$canvas/transition.init(
		new_level.transition_title, 
		new_level.flavor_text,
		new_level.transition_im)
	$canvas/transition.show()
	$canvas/mainUI.hide()
	$world.queue_free()
	yield($world, "tree_exited")
	new_level.connect("ready", $canvas/transition, "show_next_level")
	add_child(new_level)

func reset():
	current_level = -1

func victory():
	for e in get_tree().get_nodes_in_group("enemy"):
		e.go = false
	$canvas/transition.init(
		victory_title, 
		victory_text,
		victory_im)
	$canvas/transition/nextLevel.hide()
	$canvas/transition/mainMenu.show()
	$canvas/transition.show()
	$canvas/mainUI.hide()
	reset()

func defeat():
	for e in get_tree().get_nodes_in_group("enemy"):
		e.go = false
	$world/Timer.stop()
	$canvas/transition.init(
		loose_title, 
		loose_text,
		loose_im)
	$canvas/transition/nextLevel.hide()
	$canvas/transition/mainMenu.show()
	$canvas/transition.show()
	$canvas/mainUI.hide()
	reset()
