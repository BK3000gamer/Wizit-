extends CanvasLayer

var player: Player
var CurrentState: String

@onready var sprite := $"2D Animation/Sprite2D"

func _ready() -> void:
	while player == null:
		player = get_tree().get_first_node_in_group("local_player")
		if player == null:
			await get_tree().process_frame

func _physics_process(delta: float) -> void:
	if player and player is Player:
		CurrentState = player.CurrentState
		var target_texture = preload("res://Entities/Player/Sprites/Red.png") if player.WIZIT else preload("res://Entities/Player/Sprites/Blue.png")
		
		sprite.texture = target_texture
