extends State 

@export var time: float = 3.0

@export_category("Connected States")
@export var IdleState: State
@export var RunState: State

var timeout: bool = false
var active_timer: Timer

func enter() -> void:
	timeout = false
	active_timer = Timer.new()
	add_child(active_timer)
	active_timer.wait_time = time
	active_timer.one_shot = true
	active_timer.timeout.connect(timer_timeout)
	active_timer.start()

func exit() -> void:
	if active_timer:
		active_timer.queue_free()

func process_physics(_delta: float) -> State:
	if multiplayer.is_server():
		parent.velocity.x = 0.0
		parent.velocity.z = 0.0
		
		if timeout:
			if parent.InputDir == Vector3.ZERO:
				return IdleState
			else:
				return RunState
				
	return null

func timer_timeout() -> void:
	timeout = true
