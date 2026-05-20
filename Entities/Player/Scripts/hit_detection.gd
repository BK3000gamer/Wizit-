extends RayCast3D

var player : Player
var taggable: bool = true

func _ready() -> void:
	while player == null:
		player = get_tree().get_first_node_in_group("local_player")
		if player == null:
			await get_tree().process_frame
	
	enabled = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("tag") and taggable:
		enabled = true
		var timer = Timer.new()
		add_child(timer)
		timer.one_shot = true
		timer.wait_time = 0.5
		timer.timeout.connect(timer_timeout)
		timer.start()

func _process(_delta: float) -> void:
	if is_colliding():
		var body = get_collider()
		if body is HurtBox:
			body.tagged(player.WIZIT)

func timer_timeout():
	enabled = false
	taggable = false
	var timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = 1.0
	timer.timeout.connect(cooldown_timeout)
	timer.start()

func cooldown_timeout():
	taggable = true
