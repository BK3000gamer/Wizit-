extends Node2D

@export_category("Crosshair Setting")
@export var InnerPoint: float
@export var OuterPoint: float
@export var MovementOffset: float
@export var curve: float
@export var colour: Color

var player: Player

var inner: float
var outer: float

func _ready() -> void:
	while player == null:
		player = get_tree().get_first_node_in_group("local_player")
		if player == null:
			await get_tree().process_frame
	
	inner = InnerPoint
	outer = OuterPoint

func _physics_process(delta: float) -> void:
	if player and player.is_grounded:
		inner = lerpf(inner, InnerPoint, ease(delta * 30.0, curve))
		outer = lerpf(outer, OuterPoint, ease(delta * 30.0, curve))
	else:
		inner = lerpf(inner, InnerPoint + MovementOffset, ease(delta * 30.0, curve))
		outer = lerpf(outer, OuterPoint + MovementOffset, ease(delta * 30.0, curve))

func _process(_delta: float) -> void:
	queue_redraw()
	
	if player and player.CameraController.isInFirstPerson:
		visible = true
	else:
		visible = false

func _draw() -> void:
	draw_line(Vector2(inner, 0.0), Vector2(outer, 0.0), colour, 2, false)
	draw_line(Vector2(-inner, 0.0), Vector2(-outer, 0.0), colour, 2, false)
	draw_line(Vector2(0.0, inner), Vector2(0.0, outer), colour, 2, false)
	draw_line(Vector2(0.0, -inner), Vector2(0.0, -outer), colour, 2, false)
