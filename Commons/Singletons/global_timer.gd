extends Node

@onready var RoundTotalTime: int = 180

var m: int = 0
var s: int = 0
var timer: Timer
var time: int
var pickup_timer: int = 0
var player: Player

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	start_game()
	while player == null:
		player = get_tree().get_first_node_in_group("local_player")
		if player == null:
			await get_tree().process_frame

func _process(delta: float) -> void:
	m = int(time / 60)
	s = time - m * 60
	
	if pickup_timer == 10:
		pickup_timer = 0
		player.pickup_card(distribute_cards())
	
	if time == 0:
		stop_game()

func start_game() -> void:
	time = RoundTotalTime
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.timeout.connect(timeout)
	timer.start()

func stop_game() -> void:
	if timer:
		timer.stop()
		timer.queue_free()

func timeout():
	time -= 1
	pickup_timer += 1

func distribute_cards() -> String:
	var card_id: Array[String] = \
	["Dash", "Speed Boost", "Stomp", "Updraft", "Arcane"]
	var chosen_card: String = card_id.pick_random()
	return chosen_card
