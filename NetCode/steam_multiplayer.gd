extends Node

var peer = SteamMultiplayerPeer.new()
var current_lobby_id: int = 0

func _ready() -> void:
	var init_response = Steam.steamInitEx()
	if init_response.status != 0:
		push_error("Steamworks API failure: ", init_response.verbal)
		return
		
	Steam.lobby_created.connect(_on_lobby_created)
	Steam.lobby_joined.connect(_on_lobby_joined)
	
	Steam.join_requested.connect(_on_steam_overlay_join_requested)

func _process(_delta: float) -> void:
	Steam.run_callbacks()

func launch_arena_server() -> void:
	var error = peer.create_host(0)
	if error != OK:
		push_error("Failed to initialize Steam Host: ", error)
		return
		
	multiplayer.multiplayer_peer = peer
	
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, 4)

func _on_lobby_created(connect_status: int, lobby_id: int) -> void:
	if connect_status == 1:
		current_lobby_id = lobby_id
		print("Host successful! Session ID: ", lobby_id)
		
		Steam.setLobbyData(lobby_id, "name", Steam.getPersonaName() + "'s Arena")
		Steam.setLobbyJoinable(lobby_id, true)

func enter_arena(lobby_id: int) -> void:
	Steam.joinLobby(lobby_id)

func _on_lobby_joined(lobby_id: int, permissions: int, locked: bool, response: int) -> void:
	if response == 1:
		current_lobby_id = lobby_id
		
		var host_steam_id = Steam.getLobbyOwner(lobby_id)
		if host_steam_id == Steam.getSteamID():
			return
		var error = peer.create_client(host_steam_id, 0)
		if error != OK:
			push_error("Failed to connect client peer.")
			return
			
		multiplayer.multiplayer_peer = peer
		print("Successfully joined the arena!")
		
		get_tree().change_scene_to_file("res://Levels/test.tscn")
	else:
		push_error("Rejected the join request. Error Code: ", response)

func _on_steam_overlay_join_requested(lobby_id: int, friend_id: int) -> void:
	print("Overlay requested join to lobby: ", lobby_id)
	
	enter_arena(lobby_id)
