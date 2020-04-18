extends KinematicBody2D

export var idle_time := 2
export var wander_time := 3
export var chase_time := 2

export var speed := 150
export var accelaration := 20

export var wander_speed = 70

var current_accelaration := Vector2()

onready var idle_timer = $idle
onready var chase_timer = $chase
onready var wander_timer = $wander

enum {IDLE, WANDER, CHASE, ATTACK}
var current_state = WANDER

var target = null
var angle := 0.0

func _ready() -> void:
	idle_timer.connect("timeout", self, "start_wander")
	wander_timer.connect("timeout", self, "start_idle")
	chase_timer.connect("timeout", self, "stop_chase")
	start_wander()

func _process(delta: float) -> void:
	match current_state:
		IDLE:
			idle(delta)
		WANDER:
			wander(delta)
		CHASE:
			chase(delta)
		ATTACK:
			attack(delta)

func _on_hurtbox_body_entered(body: Node) -> void:
	idle_timer.stop()
	wander_timer.stop()
	chase_timer.stop()
	target = body
	current_state = ATTACK

func _on_hurtbox_body_exited(body: Node) -> void:
	idle_timer.stop()
	wander_timer.stop()
	chase_timer.stop()
	target = body
	current_state = CHASE

func _on_vision_body_entered(body: Node) -> void:
	idle_timer.stop()
	wander_timer.stop()
	chase_timer.stop()
	# prioretize player
	if target != null and target.is_in_group("player"):
		return
	target = body
	current_state = CHASE

func _on_vision_body_exited(body: Node) -> void:
	chase_timer.start(chase_time)

func stop_chase() -> void:
	idle_timer.stop()
	wander_timer.stop()
	chase_timer.stop()
	var overlapping = $vision.get_overlapping_bodies()
	if  overlapping.size( )> 0:
		target = overlapping[0]
	else:
		target = null
		start_idle()

func start_wander() -> void:
	idle_timer.stop()
	wander_timer.stop()
	chase_timer.stop()
	current_state = WANDER
	angle = rand_range(0, 2 * PI)
	wander_timer.start(wander_time)

func start_idle() -> void:
	idle_timer.stop()
	wander_timer.stop()
	chase_timer.stop()
	current_state = IDLE
	idle_timer.start(idle_time)

func wander(delta: float) -> void:
	angle += rand_range(-PI/16.0, PI/16.0)
	var force = Vector2(cos(angle), sin(angle))
	current_accelaration = current_accelaration.move_toward(force*wander_speed, accelaration)
	_move(current_accelaration)

func idle(delta: float) -> void:
	return

func attack(delta: float) -> void:
	pass

func chase(delta: float) -> void:
	var force = (target.position - position).normalized()
	current_accelaration = current_accelaration.move_toward(force*speed, accelaration)
	_move(current_accelaration)

#############################
# MOVEMENT
#############################
func _move(velocity) -> void:
	move_and_slide(velocity)
