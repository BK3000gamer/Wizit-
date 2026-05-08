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
@export var AirStrafeCurve: Curve
@export var AirStrafeMultiplier: float

var JumpVelocity: float
var JumpGravity: float
var FallGravity: float
var Direction: Vector3
var wishVel: Vector3
var samplePoint: float
const minStrafeAngle := 0.0
const maxStrafeAngle := 180.0

func _ready() -> void:
	JumpVelocity = (2.0 * JumpHeight) / JumpTimeToPeak
	JumpGravity = (-2.0 * JumpHeight) / pow(JumpTimeToPeak, 2)
	FallGravity = (-2.0 * JumpHeight) / pow(JumpTimeToDescent, 2)

func _get_gravity() -> float:
	return JumpGravity if parent.velocity.y > 0.0 else FallGravity

func process_input(_event: InputEvent) -> void:
	var dir = Input.get_vector("left","right","forward","backward")
	parent.InputDir = Vector3(dir.x, 0, dir.y)

func process_physics(delta: float) -> void:
	Direction = parent.InputDir.rotated(Vector3.UP, parent.get_rotation().y).normalized()
	
	if !parent.is_on_floor():
		samplePoint = (rad_to_deg(getHorizontalAngle(parent.velocity, wishVel)) - minStrafeAngle) / maxStrafeAngle
		wishVel *= 1.0 + (AirStrafeCurve.sample(samplePoint) * AirStrafeMultiplier)
	
	move(delta)
	parent.velocity.y += _get_gravity() * delta
	parent.move_and_slide()

func move(delta: float) -> void:
	wishVel = Direction * Speed
	print("wish velocity", wishVel)
	
	if Direction.length() > 0:
		parent.velocity.x = lerp(parent.velocity.x, wishVel.x, Acceleration * delta)
		parent.velocity.z = lerp(parent.velocity.z, wishVel.z, Acceleration * delta)
	else:
		parent.velocity.x = lerp(parent.velocity.x, wishVel.x, Deceleration * delta)
		parent.velocity.z = lerp(parent.velocity.z, wishVel.z, Deceleration * delta)

func jump() -> void:
	parent.velocity.y = JumpVelocity

func getHorizontalAngle(vec1 : Vector3, vec2 : Vector3) -> float:
	vec1.y = 0
	vec2.y = 0
	return abs(vec1.angle_to(vec2))
