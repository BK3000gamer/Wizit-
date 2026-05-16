extends Node3D

@export var player_scene: PackedScene 
@onready var players_container = $Players 

var spawn_index: int = 0

func _ready() -> void:
	if not multiplayer.is_server():
		return
		
	await get_tree().create_timer(1.5).timeout
	
	for peer_id in multiplayer.get_peers():
		_spawn_player(peer_id)
		
	
	_spawn_player(multiplayer.get_unique_id())

func _spawn_player(peer_id: int) -> void:
	var new_player = player_scene.instantiate()
	new_player.name = str(peer_id) 
	new_player.set_multiplayer_authority(peer_id)
	
	#Spawn in a circle evenly spaced
	var spread_distance = 5.0 
	var spawn_x = cos(spawn_index * 2.0) * spread_distance
	var spawn_z = sin(spawn_index * 2.0) * spread_distance
	
	var spawn_point = Vector3(spawn_x, 0.5, spawn_z)
	
	new_player.position = spawn_point
	new_player.sync_position = spawn_point
	
	players_container.add_child(new_player)
	spawn_index += 1
	
	await get_tree().create_timer(0.2).timeout
	new_player.rpc("apply_spawn_point", spawn_point)
	
func _remove_player(peer_id: int) -> void:
	var player_node = players_container.get_node_or_null(str(peer_id))
	if player_node:
		player_node.queue_free()
