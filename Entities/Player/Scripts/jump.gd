extends State

@export_category("Connected States")
@export var IdleState: State
@export var RunState: State
@export var FallState: State

var timeout: bool = false
var active_timer: Timer

func enter() -> void:
	MovementController.jump()
	timeout = false
	active_timer = Timer.new()
	add_child(active_timer)
	active_timer.wait_time = 0.1
	active_timer.one_shot = true
	active_timer.timeout.connect(timer_timeout)
	active_timer.start()

func process_physics(delta: float) -> State:
	MovementController.move(delta)
	
	if parent.velocity.y < 0.0:
		return FallState
	
	if parent.is_on_floor() and timeout:
		if parent.InputDir == Vector3.ZERO:
			return IdleState
		else:
			return RunState
	
	return null

func timer_timeout() -> void:
	timeout = true
