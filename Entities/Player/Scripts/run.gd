extends State

@export_category("Connected States")
@export var IdleState: State
@export var JumpState: State
@export var FallState: State
@export var SlideState: State

func enter() -> void:
	MovementController.Acceleration = 7.0
	MovementController.Deceleration = 8.0

func process_input(event: InputEvent) -> State:
	if event.is_action_pressed("jump") and parent.is_on_floor():
		return JumpState
	
	return null

func process_physics(delta: float) -> State:
	if parent.InputDir == Vector3.ZERO:
		return IdleState
	
	if !parent.is_on_floor():
		return FallState
		
	return null
