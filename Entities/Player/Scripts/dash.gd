extends State


@export_category("Connected States")
@export var IdleState: State
@export var RunState: State
@export var FallState: State

var timeout: bool = false
var updrafted: bool = false
var stomped: bool = false

func enter() -> void:
	MovementController.dash()
	updrafted = false
	stomped = false
	
	timeout = false
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.3
	timer.one_shot = true
	timer.timeout.connect(timer_timeout)
	timer.start()

func exit() -> void:
	parent.velocity = Vector3.ZERO

func process_physics(_delta: float) -> State:
	parent.velocity.y = 0.0
	
	if timeout:
		if parent.is_on_floor():
			if parent.InputDir == Vector3.ZERO:
				return IdleState
			else:
				return RunState
		else:
			return FallState
	
	return null

func timer_timeout():
	timeout = true
