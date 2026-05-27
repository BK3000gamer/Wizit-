extends Node
class_name GameManager

@export var round_total_time: int = 180
@export var players_container: Node3D 

@export var current_time: int = 0
var pickup_timer: int = 0
var game_started: bool = false
var match_state: String = "WAITING"

func _ready() -> void:
	add_to_group("game_manager")
	if multiplayer.is_server():
		start_game()


func start_game() -> void:
	if match_state != "WAITING": 
		return 
		
	match_state = "STARTING"
	current_time = round_total_time
	pickup_timer = 0
	game_started = false 
	
	if multiplayer.is_server():
		rpc("broadcast_it_status", "NOBODY") 
		
		print("5 Second Grace Period Begun")
		await get_tree().create_timer(5.0).timeout
		
		assign_it_player()
		
		match_state = "ACTIVE"
		game_started = true
	
		var timer = Timer.new()
		timer.name = "MatchTimer"
		add_child(timer)
		timer.wait_time = 1.0
		timer.timeout.connect(_on_tick)
		timer.start()

func _on_tick() -> void:
	if not game_started:
		return
	if multiplayer.is_server() and players_container:
		current_time -= 1
		pickup_timer += 1
		for p in players_container.get_children():
			if not p.WIZIT:
				var peer_id_int: int = p.name.to_int()
				GlobalScoreBoard.add_survival_point(peer_id_int)
				var current_score = GlobalScoreBoard.scores.get(peer_id_int, 0)
				
				print(" Player ID: %s | Current Score: %s" % [p.name, str(current_score)])
				
	if pickup_timer >= 20:
		pickup_timer = 0
		distribute_cards_to_all()
		
	if current_time <= 0:
		stop_game()
func assign_it_player() -> void:
	if not players_container: return
	
	var all_players = players_container.get_children()
	if all_players.is_empty(): return
	
	var tagged_player = all_players.pick_random()
	
	print("WIZIT: %s" % tagged_player.name)
	rpc("broadcast_it_status", tagged_player.name)

@rpc("authority", "call_local", "reliable")
func broadcast_it_status(player_name: String) -> void:
	for p in players_container.get_children():
		p.WIZIT = (str(p.name) == player_name)

func distribute_cards_to_all() -> void:
	var available_cards: Array[String] = ["Dash", "Speed Boost", "Stomp", "Updraft", "Arcane"]
	
	for p in players_container.get_children():
		var random_card = available_cards.pick_random()
		p.pickup_card(random_card)

func stop_game() -> void:
	game_started = false
	var timer = get_node_or_null("MatchTimer")
	if timer:
		timer.queue_free()
	
	print("Round Ended")
