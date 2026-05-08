extends State

@export_category("Connected States")
@export var IdleState: State
@export var RunState: State
@export var FallState: State

func enter() -> void:
	MovementController.jump()
	MovementController.Acceleration = 3
	MovementController.Deceleration = 0.1

func process_physics(_delta: float) -> State:
	if parent.velocity.y < 0.0:
		return FallState
	
	if parent.is_on_floor():
		if parent.InputDir == Vector3.ZERO:
			return IdleState
		else:
			return RunState
	
	return null
