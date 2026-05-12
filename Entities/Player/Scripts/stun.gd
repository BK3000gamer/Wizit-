extends State

@export_category("Connected States")
@export var IdleState: State
@export var RunState: State
@export var JumpState: State
@export var DashState: State
@export var UpdraftState: State

var timeout: bool = false
var jumped: bool = false
var dashed: bool = false
var updrafted: bool = false

func enter() -> void:
	timeout = false
	jumped = false
	dashed = false
	updrafted = false
	
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.25
	timer.one_shot = true
	timer.timeout.connect(timer_timeout)
	timer.start()

func process_input(event: InputEvent) -> State:
	if event.is_action_pressed("jump") and parent.is_on_floor():
		jumped = true
	
	if event.is_action_pressed("dash"):
		dashed = true
	
	if event.is_action_pressed("updraft"):
		updrafted = true
	
	return null

func process_physics(_delta: float) -> State:
	parent.velocity = Vector3.ZERO
	
	if timeout:
		if jumped:
			return JumpState
		
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
