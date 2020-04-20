extends KinematicBody2D

export var recovery_time := 1

export var speed := 150
export var accelaration := 20

export var wander_speed = 70
export var light_push = 25
var current_accelaration := Vector2()

onready var rig_scaling = $enemyRig.scale.x
onready var audio = $audio
var cooldown = false

onready var timer = $Timer
onready var tween = $Tween

enum {WANDER, CHASE, ATTACK, ESCAPE}
var current_state = WANDER

var recovering = false

var target = null
var angle := 0.0
var go = false

func _ready() -> void:
	timer.connect("timeout", self, "_recover_after_attack")

func _process(delta: float) -> void:
	if not go:
		return
	if recovering:
		return
	# first escape the light
	var light = $hitbox.get_closest_light_source()
	if  light != null:
		play_blinded()
		_move((position - light.position).normalized() * speed)
		return
	# if can hit hit and pause
	if $hitbox.can_hit_target(target):
		attack(delta)
	# work accordingly
	match current_state:
		WANDER:
			if $playerVision.can_see_player():
				target = $playerVision.player
				current_state = CHASE
				play_detection()
			elif $lightVision.can_see_light():
				target = $lightVision.light
				current_state = CHASE
				play_detection()
			else:
				wander(delta)
		CHASE:
			if $playerVision.can_see_player():
				target = $playerVision.player
				chase(delta)
			elif $lightVision.can_see_light():
				target = $lightVision.light
				chase(delta)
			else:
				current_state = WANDER

func wander(delta: float) -> void:
	angle += rand_range(-PI/16.0, PI/16.0)
	var force = Vector2(cos(angle), sin(angle))
	current_accelaration = current_accelaration.move_toward(force*wander_speed, accelaration)
	_move(current_accelaration)

func idle(delta: float) -> void:
	current_accelaration = current_accelaration.move_toward(Vector2.ZERO, accelaration * delta)
	_move(current_accelaration)

func attack(delta: float) -> void:
	recovering = true
	# TODO add some effect
	play_attack()
	target.take_hit(1)
	# start the recovery timer
	$enemyRig/AnimationPlayer.play("attack")
	timer.start(recovery_time)

func chase(delta: float) -> void:
	var force = (target.position - position).normalized()
	current_accelaration = current_accelaration.move_toward(force*speed, accelaration)
	_move(current_accelaration)

func _recover_after_attack() -> void:
	recovering = false

#############################
# MOVEMENT
#############################
func _move(velocity) -> void:
	if current_accelaration != Vector2():
		$enemyRig/AnimationPlayer.play("walk")
		$enemyRig.scale.x = -rig_scaling if current_accelaration.x > 0 else rig_scaling
	move_and_slide(velocity)

func play_detection():
	cooldown = false
	audio.stream = preload("res://Assets/sound/z1.wav")
	audio.play()

func play_attack():
	cooldown = false
	audio.stream = preload("res://Assets/sound/attack1.wav")
	audio.play()

func play_blinded():
	if cooldown:
		return
	cooldown = true
	$audio/timer.start(5)
	audio.stream = preload("res://Assets/sound/blinded2.wav")
	audio.play()

func _on_timer_timeout() -> void:
	cooldown = false
