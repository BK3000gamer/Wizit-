extends State

@export_category("Connected States")
@export var IdleState: State
@export var RunState: State
@export var JumpState: State
@export var FallState: State

@onready var camera := $"../../Camera Controller"

func enter() -> void:
	MovementController.slide_boost()
	parent.floor_snap_length = 0.5

func exit() -> void:
	parent.floor_snap_length = 0.0

func process_input(event: InputEvent) -> State:
	if event.is_action_pressed("jump") and parent.is_on_floor():
		return JumpState
	
	return null

func process_physics(delta: float) -> State:
	MovementController.slide_decay(delta)
	
	if parent.InputDir == Vector3.ZERO:
		return IdleState
	
	if parent.velocity.length() < 3.0:
		return RunState
	
	if !parent.is_on_floor():
		return FallState
	
	return null
