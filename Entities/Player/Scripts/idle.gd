extends State

@export_category("Connected States")
@export var RunState: State
@export var JumpState: State
@export var FallState: State

@onready var CameraController := $"../../Camera Controller"

func process_input(event: InputEvent) -> State:
	if event.is_action_pressed("jump") and parent.is_on_floor():
		return JumpState
	
	return null

func process_physics(delta: float) -> State:
	MovementController.move(delta)
	
	if $"../../RayCast3D".is_colliding():
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
	else:
		if multiplayer.is_server():
			parent.floor_snap_length = 0.0
			$"../../CollisionShape3D".shape.height = 1.5
			$"../../CollisionShape3D".position = Vector3(0.0, 0.0, 0.0)
			$"../../Hurt Box/CollisionShape3D".rotation_degrees = Vector3.ZERO
			$"../../Hurt Box/CollisionShape3D".position = Vector3.ZERO
			
		if parent.is_in_group("local_player"):
			var tween := create_tween()
			tween.tween_property(CameraController, "position", Vector3(0.0, 0.5, 0.0), 0.3)
	
	if parent.InputDir != Vector3.ZERO:
		return RunState
	
	if !parent.is_on_floor():
		return FallState
	
	return null
