extends Control

@onready var host_button := $HostArena
@onready var join_button := $JoinArena
@onready var lobby_ui := $LobbyUI
@onready var player_list := $LobbyUI/PlayerList
@onready var start_button := $LobbyUI/StartMatch
@onready var server_browser := $ServerBrowser
@onready var server_list := $ServerBrowser/ScrollContainer/ServerList

var current_lobby_id: int = 0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	lobby_ui.hide()
	server_browser.hide()
	
	SteamNetworkManager.arena_list_updated.connect(on_arenas_found)
	SteamNetworkManager.roster_updated.connect(refresh_roster_ui)
	
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
	enter_lobby(false)

func enter_lobby(is_host: bool) -> void:
	lobby_ui.show()
	
	if is_host:
		start_button.show()
	else:
		start_button.hide()

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
	host_button.show()
	join_button.show()
	host_button.disabled = false
	join_button.disabled = false

func on_lobby_back_pressed() -> void:
	SteamNetworkManager.leave_match()
	lobby_ui.hide()
	player_list.text = ""
	host_button.show()
	join_button.show()
	host_button.disabled = false
	join_button.disabled = false
	
	
