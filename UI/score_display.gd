extends Label

var player: Player

func _ready() -> void:
	text = "Score: 0"
	
	GlobalScoreBoard.local_score_updated.connect(_on_score_updated)
	
	while not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("local_player")
		if not is_instance_valid(player):
			await get_tree().process_frame
			
	if player.name.to_int() != multiplayer.get_unique_id():
		queue_free()

func _on_score_updated(new_score: int) -> void:
	text = "Score: " + str(new_score)
