extends Node3D

@onready var parent := $".."

@export var sensitivity: float

@onready var camera: Camera3D = $Camera3D
var mouseCaptured := true

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if parent.is_multiplayer_authority():
		camera.make_current()
	else:
		camera.queue_free()
		
		set_process_input(false)

func process_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and mouseCaptured:
		parent.rotate_y(-event.relative.x * sensitivity * 0.001)
		rotate_x(-event.relative.y * sensitivity * 0.001)
		rotation.x = clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90))
