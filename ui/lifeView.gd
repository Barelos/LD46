extends Control

var lifes = 3

func _ready():
	$timer.connect("timeout", self, "hide_text")
	reset()

func reset():
	lifes = 3
	for child in $hearts.get_children():
		child.show()
	$talkBubble.hide()

func hit():
	if lifes > 0:
		lifes -= 1
		$hearts.get_child(lifes).hide()

func say(msg, time=2):
	$talkBubble/RichTextLabel.text = msg
	$talkBubble.show()
	$timer.start(time)

func hide_text():
	$talkBubble.hide()
