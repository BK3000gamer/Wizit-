extends Node2D

@export var this_slot: int

@onready var sprite := $Sprite2D

const dash = preload("res://Assets/Textures/Cards/Dash.png")
const updraft = preload("res://Assets/Textures/Cards/Updraft.png")
const speed = preload("res://Assets/Textures/Cards/Speed.png")
const stomp = preload("res://Assets/Textures/Cards/Stomp.png")
const freeze = preload("res://Assets/Textures/Cards/Freeze.png")
const scan = preload("res://Assets/Textures/Cards/Scan.png")

var player: Player

func _ready() -> void:
	while player == null:
		player = get_tree().get_first_node_in_group("local_player")
		if player == null:
			await get_tree().process_frame

func  _process(_delta: float) -> void:
	if player == null:
		sprite.visible = false
		return
	
	sprite.visible = true
		
	if this_slot + 1 > player.current_cards.size():
		sprite.texture = scan
		sprite.modulate = Color(0.0, 0.0, 0.0, 0.25)
	else:
		sprite.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	if this_slot == player.active_slot:
		sprite.position.y = -40
		sprite.scale = Vector2(0.05, 0.05)
	else:
		sprite.position.y = 0
		sprite.scale = Vector2(0.04, 0.04)
	
	if this_slot >= player.current_cards.size():
		return
	
	var ability = player.current_cards[this_slot]
	match ability:
		"Dash":
			sprite.texture = dash
		"Stomp":
			sprite.texture = stomp
		"Updraft":
			sprite.texture = updraft
		"Speed Boost":
			sprite.texture = speed
		"Arcane":
			if player.WIZIT:
				sprite.texture = scan
			else:
				sprite.texture = freeze
