extends State

@export_category("Connected States")
@export var IdleState: State
@export var RunState: State
@export var JumpState: State
@export var FallState: State

var airborne_frame_counter: int = 0
var slide_timer: float = 0.0

func enter() -> void:
	airborne_frame_counter = 0
	slide_timer = 0.0
	parent.floor_snap_length = 0.5
	parent.MovementController.slide_boost()

func exit() -> void:
	parent.floor_snap_length = 0.0

func process_input(event: InputEvent) -> State:
	if event.is_action_pressed("jump") and parent.is_on_floor():
		return JumpState
	return null

func process_physics(delta: float) -> State:
	slide_timer += delta
	parent.MovementController.slide_decay(delta)

	if parent.is_on_floor():
		parent.velocity.y = -5.0
		
	if slide_timer > 0.2:
		var horizontal_speed = Vector2(parent.velocity.x, parent.velocity.z).length()
		if horizontal_speed < 3.0:
			if parent.InputDir != Vector3.ZERO:
				return RunState
			else:
				return IdleState
			
	if not parent.is_on_floor():
		airborne_frame_counter += 1
	else:
		airborne_frame_counter = 0
		
	if airborne_frame_counter > 5:
		return FallState
		
	return null
