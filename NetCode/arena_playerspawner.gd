extends Node3D

@export var player_scene: PackedScene 
@onready var players_container = $Players 

var spawn_index: int = 0

func _ready() -> void:
	if multiplayer.is_server():
		_spawn_player(multiplayer.get_unique_id())
		
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_remove_player)
		for peer_id in multiplayer.get_peers():
				_spawn_player(peer_id)
	else:
		rpc_id(1, "client_map_loaded")

func _on_peer_connected(peer_id: int) -> void:
	_spawn_player(peer_id)

@rpc("any_peer", "call_local", "reliable")
func client_map_loaded() -> void:
	if multiplayer.is_server():
		var sender_id = multiplayer.get_remote_sender_id()
		_spawn_player(sender_id)

func _spawn_player(peer_id: int) -> void:
	if players_container.has_node(str(peer_id)):
		return

	var new_player = player_scene.instantiate()
	new_player.name = str(peer_id) 
	
	var spread_distance = 5.0 
	var spawn_x = cos(spawn_index * 2.0) * spread_distance
	var spawn_z = sin(spawn_index * 2.0) * spread_distance
	var spawn_point = Vector3(spawn_x, 2.0, spawn_z)
	
	new_player.position = spawn_point
	new_player.sync_position = spawn_point
	
	players_container.add_child(new_player)
	spawn_index += 1
	
	await get_tree().process_frame
	rpc_id(peer_id, "assign_spawn_position", spawn_point)
	
func _remove_player(peer_id: int) -> void:
	var player_node = players_container.get_node_or_null(str(peer_id))
	if player_node:
		player_node.queue_free()

@rpc("authority", "call_local", "reliable")
func assign_spawn_position(spawn_pos: Vector3) -> void:
	var my_peer_id = str(multiplayer.get_unique_id())
	var player_node = players_container.get_node_or_null(my_peer_id)
	
	var attempts = 0
	while not player_node and attempts < 100:
		await get_tree().process_frame
		player_node = players_container.get_node_or_null(my_peer_id)
		attempts += 1
		
	if player_node:
		player_node.global_position = spawn_pos
		if "sync_position" in player_node:
			player_node.sync_position = spawn_pos
