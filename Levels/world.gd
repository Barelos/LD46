extends YSort

export var time_limit := 30
onready var timer = $Timer

export var transition_title := ""
export (String, MULTILINE) var flavor_text
export var transition_im: StreamTexture

signal victory

func _ready() -> void:
	timer.connect("timeout", self, "end_level")
	connect("victory", $"..", "next_level")

func start_level():
	timer.start(time_limit)
	get_tree().current_scene.get_node("canvas/mainUI/bar").start_timer(time_limit)

func end_level() -> void:
	emit_signal("victory")
