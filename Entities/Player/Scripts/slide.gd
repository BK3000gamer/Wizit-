extends State

@export_category("Connected States")
@export var IdleState: State
@export var RunState: State
@export var JumpState: State
@export var FallState: State

@onready var CameraController := $"../../Camera Controller"

var airborne_frame_counter: int = 0
var slide_timer: float = 0.0

func enter() -> void:
	airborne_frame_counter = 0
	slide_timer = 0.0
	
	if multiplayer.is_server():
		parent.floor_snap_length = 0.5
		parent.MovementController.slide_boost()
		$"../../CollisionShape3D".shape.height = 0.5
		$"../../CollisionShape3D".position = Vector3(0.0, -0.5, 0.0)
		$"../../Hurt Box/CollisionShape3D".rotation_degrees = Vector3(90.0, 0.0, 0.0)
		$"../../Hurt Box/CollisionShape3D".position = Vector3(0.0, -0.375, 0.0)

	if parent.is_in_group("local_player"):
		var tween := create_tween()
		tween.tween_property(CameraController, "position", Vector3.ZERO, 0.3)

func exit() -> void:
	if multiplayer.is_server():
		parent.floor_snap_length = 0.0
		$"../../CollisionShape3D".shape.height = 1.5
		$"../../CollisionShape3D".position = Vector3(0.0, 0.0, 0.0)
		$"../../Hurt Box/CollisionShape3D".rotation_degrees = Vector3.ZERO
		$"../../Hurt Box/CollisionShape3D".position = Vector3.ZERO
		
	if parent.is_in_group("local_player"):
		var tween := create_tween()
		tween.tween_property(CameraController, "position", Vector3(0.0, 0.5, 0.0), 0.3)

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
