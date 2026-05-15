extends Node2D

@export var this_slot: int

@onready var sprite := $Sprite2D

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
		
	if this_slot + 1 > player.current_cards.size():
		sprite.visible = false
	else:
		sprite.visible = true
	
	if this_slot == player.active_slot:
		sprite.position.y = -40
		sprite.scale = Vector2(0.77, 1.1)
	else:
		sprite.position.y = 0
		sprite.scale = Vector2(0.7, 1.0)
	
	if this_slot >= player.current_cards.size():
		return
	
	var ability = player.current_cards[this_slot]
	match ability:
		"Dash":
			sprite.modulate = Color("blue")
		"Stomp":
			sprite.modulate = Color("green")
		"Updraft":
			sprite.modulate = Color("purple")
		"Speed Boost":
			sprite.modulate = Color("yellow")
