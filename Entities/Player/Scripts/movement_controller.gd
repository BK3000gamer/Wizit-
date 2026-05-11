extends Node

@onready var parent := $".."
@onready var camera := $"../Camera Controller"

@export_category("Movement Stats")
@export var JumpHeight: float
@export var JumpTimeToPeak: float
@export var JumpTimeToDescent: float
@export var Speed: float
@export var MaxAirSpeed: float 
@export var Acceleration: float
@export var Deceleration: float
@export var AirAcceleration: float
@export var AirStrafeCurve: Curve
@export var AirStrafeMultiplier: float
@export var SlideBoost: float
@export var SlideCurve: Curve
@export var SlopeCurve: Curve
@export var SlideDecayMultiplier: float
@export var DashBoost: float
@export var UpdraftBoost: float
@export var StompGravity: float

var JumpVelocity: float
var JumpGravity: float
var FallGravity: float
var Direction: Vector3
var wishVel: Vector3
var samplePoint: float
const minStrafeAngle := 0.0
const maxStrafeAngle := 180.0
var land_buffer: int = 0
const LAND_BUFFER_FRAMES: int = 2
var SlideTime := 0.0

func _ready() -> void:
	JumpVelocity = (2.0 * JumpHeight) / JumpTimeToPeak
	JumpGravity = (-2.0 * JumpHeight) / pow(JumpTimeToPeak, 2)
	FallGravity = (-2.0 * JumpHeight) / pow(JumpTimeToDescent, 2)

func _get_gravity() -> float:
	return JumpGravity if parent.velocity.y > 0.0 else FallGravity

func process_input(_event: InputEvent) -> void:
	var dir = Input.get_vector("left","right","forward","backward")
	parent.InputDir = Vector3(dir.x, 0.0, dir.y)

func process_physics(delta: float) -> void:
	Direction = parent.InputDir.rotated(Vector3.UP, parent.get_rotation().y).normalized()
	
	if parent.is_on_floor():
		if land_buffer > 0:
			land_buffer -= 1
		samplePoint = 0.0
	else:
		land_buffer = LAND_BUFFER_FRAMES
		var baseWish := Direction * Speed
		samplePoint = (rad_to_deg(getHorizontalAngle(parent.velocity, baseWish)) - minStrafeAngle) / maxStrafeAngle
	
	parent.velocity.y += _get_gravity() * delta
	parent.move_and_slide()

func move(delta: float) -> void:
	var boost := 1.0 + (AirStrafeCurve.sample(samplePoint) * AirStrafeMultiplier)
	wishVel = Direction * Speed * boost
	
	if parent.is_on_floor() and land_buffer == 0:
		if Direction.length() > 0:
			parent.velocity.x = lerp(parent.velocity.x, wishVel.x, Acceleration * delta)
			parent.velocity.z = lerp(parent.velocity.z, wishVel.z, Acceleration * delta)
		else:
			parent.velocity.x = lerp(parent.velocity.x, wishVel.x, Deceleration * delta)
			parent.velocity.z = lerp(parent.velocity.z, wishVel.z, Deceleration * delta)
	else:
		_accelerate_air(Direction, Speed * boost, delta)

func jump() -> void:
	parent.velocity.y = JumpVelocity

func getHorizontalAngle(vec1 : Vector3, vec2 : Vector3) -> float:
	vec1.y = 0
	vec2.y = 0
	return abs(vec1.angle_to(vec2))
	
func _accelerate_air(wishDir: Vector3, wishSpeed: float, delta: float) -> void:
	if wishDir.length() == 0:
		return
	
	var currentSpeed: float = parent.velocity.dot(wishDir)
	var addSpeed := wishSpeed - currentSpeed
	if addSpeed <= 0:
		addSpeed = clamp(addSpeed, -AirAcceleration * wishSpeed * delta, 0)
		parent.velocity.x += addSpeed * wishDir.x
		parent.velocity.z += addSpeed * wishDir.z
	else:
		var accelSpeed: float = min(AirAcceleration * wishSpeed * delta, addSpeed)
		parent.velocity.x += accelSpeed * wishDir.x
		parent.velocity.z += accelSpeed * wishDir.z
	
	var horizontal := Vector2(parent.velocity.x, parent.velocity.z)
	if horizontal.length() > MaxAirSpeed:
		horizontal = horizontal.normalized() * MaxAirSpeed
		parent.velocity.x = horizontal.x
		parent.velocity.z = horizontal.y

func slide_boost() -> void:
	SlideTime = 0.0
	var SlideDirection = Vector3.FORWARD.rotated(Vector3.UP, parent.get_rotation().y).normalized()
	parent.velocity = SlideDirection * SlideBoost

func slide_decay(delta) -> void:
	SlideTime += delta * 8.0
	
	var groundNormal = parent.get_floor_normal().normalized()
	var floorAngle = parent.get_floor_angle()
	var slopeDir = sign(Vector3.DOWN.slide(groundNormal).dot(parent.velocity))
	var slope = (floorAngle / parent.floor_max_angle) * slopeDir
	var slopeNormalized = remap(slope, -1.0, 1.0, 0.0, 1.0)
	
	var SlideDeceleration = SlideCurve.sample(SlideTime) * SlopeCurve.sample(slopeNormalized) * SlideDecayMultiplier
	parent.velocity.x = lerp(parent.velocity.x, 0.0, SlideDeceleration * delta)
	parent.velocity.z = lerp(parent.velocity.z, 0.0, SlideDeceleration * delta)

func dash() -> void:
	var DashDirection = Vector3.FORWARD.rotated(Vector3.UP, parent.get_rotation().y).normalized()
	parent.velocity = DashDirection * DashBoost

func updraft() -> void:
	parent.velocity.y = UpdraftBoost

func stomp() -> void:
	parent.velocity.y = -StompGravity
