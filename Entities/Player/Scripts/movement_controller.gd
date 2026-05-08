extends Node

@onready var parent := $".."
@onready var camera := $"../Camera Controller"

@export_category("Movement Stats")
@export var JumpHeight: float
@export var JumpTimeToPeak: float
@export var JumpTimeToDescent: float
@export var Speed: float
@export var Acceleration: float
@export var Deceleration: float

var JumpVelocity: float
var JumpGravity: float
var FallGravity: float
var Direction: Vector3

func _ready() -> void:
	JumpVelocity = (2.0 * JumpHeight) / JumpTimeToPeak
	JumpGravity = (-2.0 * JumpHeight) / pow(JumpTimeToPeak, 2)
	FallGravity = (-2.0 * JumpHeight) / pow(JumpTimeToDescent, 2)

func _get_gravity() -> float:
	return JumpGravity if parent.velocity.y > 0.0 else FallGravity

func process_input(event: InputEvent) -> void:
	var dir = Input.get_vector("left","right","forward","backward")
	parent.InputDir = Vector3(dir.x, 0, dir.y)

func process_physics(delta: float) -> void:
	Direction = (parent.transform.basis * parent.InputDir).normalized()
	move(delta)
	parent.velocity.y += _get_gravity() * delta
	
	parent.move_and_slide()

func move(delta: float) -> void:
	var wishVel: Vector3 = Direction * Speed
	
	if Direction.length() > 0:
		parent.velocity = lerp(parent.velocity, wishVel, Acceleration * delta)
	else:
		parent.velocity = lerp(parent.velocity, wishVel, Deceleration * delta)

func jump() -> void:
	parent.velocity.y = JumpVelocity
