extends Node

var player_roster: Dictionary = {}

signal arena_list_updated(lobbies: Array)
signal roster_updated

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
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.server_disconnected.connect(_on_host_disconnected)

func _process(_delta: float) -> void:
	Steam.run_callbacks()

func launch_arena_server() -> void:
	multiplayer.multiplayer_peer = null
	peer = SteamMultiplayerPeer.new()
	
	var error = peer.create_host(0)
	if error != OK:
		push_error("Failed to initialize Steam Host: ", error)
		return
		
	multiplayer.multiplayer_peer = peer
	
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, 5)
	
	player_roster.clear()
	player_roster[1] = Steam.getPersonaName()
	roster_updated.emit()

func _on_lobby_created(connect_status: int, lobby_id: int) -> void:
	if connect_status == 1:
		current_lobby_id = lobby_id
		print("Host successful! Session ID: ", lobby_id)
		
		Steam.setLobbyData(lobby_id, "name", Steam.getPersonaName() + "'s Arena")
		Steam.setLobbyData(lobby_id, "game_id", "WIZ!")
		Steam.setLobbyJoinable(lobby_id, true)
		
		

func enter_arena(lobby_id: int) -> void:
	multiplayer.multiplayer_peer = null
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
	else:
		push_error("Rejected the join request. Error Code: ", response)

func _on_steam_overlay_join_requested(lobby_id: int, friend_id: int) -> void:
	print("Overlay requested join to lobby: ", lobby_id)
	
	enter_arena(lobby_id)
	
@rpc("call_local", "authority", "reliable")
func sync_start_match() -> void:
	print("Host Beginning Match")
	get_tree().change_scene_to_file("res://Levels/test.tscn")
	
func search_for_arenas() -> void:
	print("Searching Steam for WIZ!")
	Steam.addRequestLobbyListStringFilter("game_id", "WIZ!", Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()

func _on_lobby_match_list(lobbies: Array) -> void:
	print("Steam found ", lobbies.size(), " active arenas.")
	
	for lobby_id in lobbies:
		var host_name = Steam.getLobbyData(lobby_id, "name")
		
		var current_players = Steam.getNumLobbyMembers(lobby_id)
	
		print("Found: ", host_name, " | Players: ", current_players, "/5 | ID: ", lobby_id)
	
	arena_list_updated.emit(lobbies)

func leave_match() -> void:
	if current_lobby_id != 0:
		Steam.leaveLobby(current_lobby_id)
		current_lobby_id = 0
	
	multiplayer.multiplayer_peer = null

func _on_connected_to_server() -> void:
	var my_name = Steam.getPersonaName()
	var my_peer_id = multiplayer.get_unique_id()
	
	rpc_id(1, "register_player", my_peer_id, my_name)

@rpc("any_peer", "call_local", "reliable")
func register_player(new_peer_id: int, steam_name: String) -> void:
	if multiplayer.is_server():
		player_roster[new_peer_id] = steam_name
		
		rpc("sync_roster", player_roster)

@rpc("authority", "call_local", "reliable")
func sync_roster(full_roster: Dictionary) -> void:
	player_roster = full_roster
	roster_updated.emit()
	
func _on_host_disconnected() -> void:
	leave_match() 
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE 
	get_tree().change_scene_to_file("res://Menu/main_menu.tscn")

func _on_peer_disconnected(peer_id: int) -> void:
	if multiplayer.is_server():
		player_roster.erase(peer_id)
		rpc("sync_roster", player_roster)
