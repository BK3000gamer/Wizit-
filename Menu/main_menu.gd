extends Control

@onready var status_label := $ServerBrowser/StatusLabel
@onready var host_button := $HostArena
@onready var join_button := $JoinArena
@onready var lobby_ui := $LobbyUI
@onready var player_list := $LobbyUI/PlayerList
@onready var start_button := $LobbyUI/StartMatch
@onready var server_browser := $ServerBrowser
@onready var server_list := $ServerBrowser/ScrollContainer/ServerList

var current_lobby_id: int = 0
var is_offline_debug: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	lobby_ui.hide()
	server_browser.hide()
	
	SteamNetworkManager.arena_list_updated.connect(on_arenas_found)
	SteamNetworkManager.roster_updated.connect(refresh_roster_ui)
	SteamNetworkManager.connection_status_changed.connect(on_status_changed)
	
	multiplayer.connected_to_server.connect(on_client_connection_success)
	
	var instance_id = OS.get_process_id()
	DisplayServer.window_set_title("Player Instance: " + str(instance_id))
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		# F1 for Local host
		if event.keycode == KEY_F1:
			print("Local Host Activated")
			is_offline_debug = true
			start_offline_host()
			
		# F2 For Local Join
		if event.keycode == KEY_F2:
			print("Local Join Activated")
			is_offline_debug = true
			start_offline_join()

func start_offline_host() -> void:
	host_button.hide()
	join_button.hide()
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(8910, 5) 
	multiplayer.multiplayer_peer = peer
	
	SteamNetworkManager.player_roster.clear()
	SteamNetworkManager.player_roster[1] = "Debug_Host"
	SteamNetworkManager.roster_updated.emit()
	
	enter_lobby(true)

func start_offline_join() -> void:
	host_button.hide()
	join_button.hide()
	server_browser.hide()
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("127.0.0.1", 8910)
	multiplayer.multiplayer_peer = peer
	
	await multiplayer.connected_to_server
	var my_id = multiplayer.get_unique_id()
	SteamNetworkManager.rpc_id(1, "register_player", my_id, "Debug_Client_" + str(my_id))
	
	enter_lobby(false)
	
func on_host_arena_pressed() -> void:
	host_button.disabled = true
	join_button.disabled = true
	host_button.hide()
	join_button.hide()
	
	SteamNetworkManager.launch_arena_server()
	enter_lobby(true)
	
func on_join_arena_pressed() -> void:
	host_button.hide()
	join_button.hide()
	server_browser.show()
	on_refresh_servers_pressed()

func on_refresh_servers_pressed() -> void:
	for child in server_list.get_children():
		child.queue_free()
		
	var loading_label = Label.new()
	loading_label.text = "Searching Steam..."
	server_list.add_child(loading_label)
	
	SteamNetworkManager.search_for_arenas()
	
func on_arenas_found(lobbies: Array) -> void:
	for child in server_list.get_children():
		child.queue_free()
		
	if lobbies.is_empty():
		var empty_label = Label.new()
		empty_label.text = "No Lobbies Available"
		server_list.add_child(empty_label)
		return
		
	for lobby_id in lobbies:
		var host_name = Steam.getLobbyData(lobby_id, "name")
		var current_players = Steam.getNumLobbyMembers(lobby_id)
		
		var join_btn = Button.new()
		join_btn.text = host_name + " | Players: " + str(current_players) + "/5"
		join_btn.custom_minimum_size = Vector2(0, 40) 
		
		join_btn.pressed.connect(func(): connect_to_server(lobby_id))
		server_list.add_child(join_btn)

func connect_to_server(lobby_id: int) -> void:
	print("Joining ID: ", lobby_id)
	
	server_browser.hide()
	SteamNetworkManager.enter_arena(lobby_id)

func on_status_changed(message: String) -> void:
	status_label.show()
	status_label.text = message

func enter_lobby(is_host: bool) -> void:
	lobby_ui.show()
	
	if is_host:
		start_button.show()
	else:
		start_button.hide()
		
func on_client_connection_success() -> void:
	status_label.hide()
	enter_lobby(false)

func refresh_roster_ui() -> void:
	player_list.text = ""
	
	for peer_id in SteamNetworkManager.player_roster:
		var actual_name = SteamNetworkManager.player_roster[peer_id]
		if peer_id == 1:
			player_list.text += "[HOST] " + actual_name + "\n"
		else:
			player_list.text += actual_name + "\n"


func on_start_match_pressed() -> void:
	if multiplayer.is_server():
		SteamNetworkManager.rpc("sync_start_match")
		
func on_browser_back_pressed() -> void:
	server_browser.hide()
	status_label.hide()
	host_button.show()
	join_button.show()
	host_button.disabled = false
	join_button.disabled = false

func on_lobby_back_pressed() -> void:
	SteamNetworkManager.leave_match()
	lobby_ui.hide()
	status_label.hide()
	player_list.text = ""
	host_button.show()
	join_button.show()
	host_button.disabled = false
	join_button.disabled = false
	
	
