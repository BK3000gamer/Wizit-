extends State

@export_category("Connected States")
@export var IdleState: State
@export var RunState: State
@export var DashState: State
@export var UpdraftState: State
@export var StunState: State

var timeout: bool = false
var dashed: bool = false
var updrafted: bool = false

func enter() -> void:
	timeout = false
	dashed = false
	updrafted = false
	
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.5
	timer.one_shot = true
	timer.timeout.connect(timer_timeout)
	timer.start()

#func process_input(event: InputEvent) -> State:
	#if event.is_action_pressed("dash"):
		#dashed = true
	
	#if event.is_action_pressed("updraft"):
		#updrafted = true
	
	#return null

func process_physics(_delta: float) -> State:
	MovementController.stomp()
	
	if parent.is_on_floor():
		if timeout:
			return StunState
		
		if dashed:
			return DashState
		
		if updrafted:
			return UpdraftState
		
		if parent.InputDir == Vector3.ZERO:
			return IdleState
		else:
			return RunState
		
	return null

func timer_timeout():
	timeout = true
