extends Node3D

@export var player_scene: PackedScene 
@onready var players_container = $Players 

func _ready() -> void:
	if not multiplayer.is_server():
		return
		
	_spawn_player(multiplayer.get_unique_id())
	multiplayer.peer_connected.connect(_spawn_player)
	multiplayer.peer_disconnected.connect(_remove_player)

func _spawn_player(peer_id: int) -> void:
	var new_player = player_scene.instantiate()
	new_player.name = str(peer_id) 
	
	new_player.set_multiplayer_authority(peer_id)
	players_container.add_child(new_player)
	

func _remove_player(peer_id: int) -> void:
	var player_node = players_container.get_node_or_null(str(peer_id))
	if player_node:
		player_node.queue_free()
