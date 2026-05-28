extends Node3D
class_name CardSpawner

@export var card_powerups: PackedScene
@export var spawn_interval: float = 30.0

@onready var spawnpoints := $CardSpawnPoint
var spawn_timer := Timer.new()
var waiting_to_spawn := false

var active_pickup: Node3D = null

func _ready() -> void:
	if not multiplayer.is_server():
		set_process(false)
		return
		
	_scatter_cards()
	
	add_child(spawn_timer)
	spawn_timer.one_shot = true
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_scatter_cards)

func _process(_delta: float) -> void:
	if not is_instance_valid(active_pickup) and not waiting_to_spawn:
		waiting_to_spawn = true
		spawn_timer.start()

func _scatter_cards() -> void:
	if not card_powerups:
		push_error("No card powerup reference")
		return
	var new_powerup = card_powerups.instantiate()
	waiting_to_spawn = false
	new_powerup.position = spawnpoints.position
	active_pickup = new_powerup
	add_child(new_powerup)
		
		
		
