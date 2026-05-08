extends State

@export_category("Connected States")
@export var RunState: State
@export var JumpState: State
@export var FallState: State

func enter() -> void:
	MovementController.Acceleration = 7.0
	MovementController.Deceleration = 8.0

func process_input(event: InputEvent) -> State:
	if event.is_action_pressed("jump") and parent.is_on_floor():
		return JumpState
	
	return null

func process_physics(_delta: float) -> State:
	if parent.InputDir != Vector3.ZERO:
		return RunState
	
	if !parent.is_on_floor():
		return FallState
	
	return null
