extends Position2D

onready var parent = $".."

func _ready() -> void:
	_update_pivot()

func _process(delta: float) -> void:
	_update_pivot()

func _update_pivot():
	rotation = parent.current_accelaration.angle()
