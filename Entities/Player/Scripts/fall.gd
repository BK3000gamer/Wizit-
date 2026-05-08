extends State

@export_category("Connected States")
@export var IdleState: State
@export var RunState: State

func process_physics(_delta: float) -> State:
	if parent.is_on_floor():
		if parent.InputDir == Vector3.ZERO:
			return IdleState
		else:
			return RunState
	
	return null
