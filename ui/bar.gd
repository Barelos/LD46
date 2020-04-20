extends TextureRect

onready var start = $marker.rect_position
onready var end = start + Vector2.UP * 250
onready var tween = $Tween

func _ready() -> void:
	tween.connect("tween_all_completed", self, "reset")

func start_timer(time):
	tween.interpolate_property($marker, "rect_position", start, end, time, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()

func reset():
	$marker.rect_position = start
