extends State

@export_category("Connected States")
@export var IdleState: State
@export var JumpState: State
@export var FallState: State
@export var SlideState: State
@export var DashState: State
@export var UpdraftState: State

func enter() -> void:
	parent.floor_snap_length = 0.5

func exit() -> void:
	parent.floor_snap_length = 0.0

func process_input(event: InputEvent) -> State:
	if event.is_action_pressed("jump") and parent.is_on_floor():
		return JumpState
	
	if event.is_action_pressed("slide") and parent.is_on_floor() and parent.velocity.length() > 5.0:
		return SlideState
	
	if event.is_action_pressed("dash"):
		return DashState
	
	if event.is_action_pressed("updraft"):
		return UpdraftState
	
	return null

func process_physics(delta: float) -> State:
	MovementController.move(delta)
	
	if parent.InputDir == Vector3.ZERO:
		return IdleState
	
	if !parent.is_on_floor():
		return FallState
		
	return null
