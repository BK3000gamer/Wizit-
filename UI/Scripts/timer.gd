extends Label

var game_manager: Node

func _process(_delta: float) -> void:
	if not game_manager:
		game_manager = get_tree().get_first_node_in_group("game_manager")
		return
		
	var time_left = game_manager.current_time
	
	var m = time_left / 60
	var s = time_left % 60
	
	text = "%02d:%02d" % [m, s]
