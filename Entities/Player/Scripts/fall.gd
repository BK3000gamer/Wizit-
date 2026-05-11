extends State

@export_category("Connected States")
@export var IdleState: State
@export var RunState: State
@export var DashState: State
@export var UpdraftState: State
@export var StompState: State

func process_input(event: InputEvent) -> State:
	if event.is_action_pressed("dash"):
		return DashState
	
	if event.is_action_pressed("updraft"):
		return UpdraftState
	
	if event.is_action_pressed("stomp"):
		return StompState
	
	return null

func process_physics(delta: float) -> State:
	MovementController.move(delta)
	
	if parent.is_on_floor():
		if parent.InputDir == Vector3.ZERO:
			return IdleState
		else:
			return RunState
	
	return null
