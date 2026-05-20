extends Node3D

@export var sensitivity: float = 3.0

@onready var camera := $Camera3D
@onready var ThirdPersonRaycast := $"Third Person Raycast"
@onready var parent := $".."
var mouseCaptured := true
var isInFirstPerson := false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if parent.name.to_int() == multiplayer.get_unique_id():
		if is_instance_valid(camera):
			camera.make_current()
	else:
		if is_instance_valid(camera):
			camera.queue_free()
		set_process_input(false)

func _process(_delta: float) -> void:
	if not is_instance_valid(camera):
		return
		
	if isInFirstPerson:
		camera.position = Vector3.ZERO
	else:
		if ThirdPersonRaycast.is_colliding():
			if ThirdPersonRaycast.get_collision_normal().y < 0.8:
				camera.global_position = ThirdPersonRaycast.get_collision_point()
			else:
				camera.position = Vector3(0.0, 0.0, 3.0)
		else:
			camera.position = Vector3(0.0, 0.0, 3.0)

func process_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and mouseCaptured:
		parent.rotate_y(-event.relative.x * sensitivity * 0.001)
		rotate_x(-event.relative.y * sensitivity * 0.001)
		rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90))
