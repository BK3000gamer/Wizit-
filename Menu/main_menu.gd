extends Control

@onready var lobby_input := $LineEdit

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_host_arena_pressed() -> void:
	print("Button Clicked")
	SteamNetworkManager.launch_arena_server()
	
	get_tree().change_scene_to_file("res://Levels/test.tscn")

func _on_join_arena_pressed() -> void:
	var pasted_id: int = lobby_input.text.strip_edges().to_int()
	
	if pasted_id > 0:
		print("Finding ID ", pasted_id)
		SteamNetworkManager.enter_arena(pasted_id)
	else:
		print("Invalid Lobby ID entered.")
