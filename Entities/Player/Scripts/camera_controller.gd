extends Node3D

@onready var parent := $".."

@export var sensitivity: float

var camera: Camera3D
var mouseCaptured := true

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera = get_tree().current_scene.get_viewport().get_camera_3d()

func process_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and mouseCaptured:
		parent.rotate_y(-event.relative.x * sensitivity * 0.001)
		rotate_x(-event.relative.y * sensitivity * 0.001)
