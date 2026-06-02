extends RayCast3D

var player: Player
var taggable: bool = true
var active_timer: Timer
var cooldown_timer: Timer

func _ready() -> void:
	enabled = false
	player = get_tree().get_first_node_in_group("local_player")

func _unhandled_input(event: InputEvent) -> void:
	if not player or str(player.name) != str(multiplayer.get_unique_id()): 
		return

	if event.is_action_pressed("tag") and taggable:
		enabled = true
		taggable = false
		
		active_timer = Timer.new()
		add_child(active_timer)
		active_timer.one_shot = true
		active_timer.wait_time = 0.5
		active_timer.timeout.connect(_on_active_timeout)
		active_timer.start()

func _process(_delta: float) -> void:
	if enabled and is_colliding():
		var body = get_collider()
		var target_player: Player = null
		
		if body is HurtBox:
			target_player = body.player
		elif body is Player:
			target_player = body
			
		if target_player and target_player != player:
			enabled = false
			if player.WIZIT:
				player.rpc_id(1, "request_active_tag", target_player.name)
			else:
				player.rpc_id(1, "request_stasis_steal", target_player.name)

func _on_active_timeout() -> void:
	enabled = false
	if active_timer: 
		active_timer.queue_free()
	
	cooldown_timer = Timer.new()
	add_child(cooldown_timer)
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = 1.0 
	cooldown_timer.timeout.connect(_on_cooldown_timeout)
	cooldown_timer.start()

func _on_cooldown_timeout() -> void:
	taggable = true
	if cooldown_timer: 
		cooldown_timer.queue_free()
