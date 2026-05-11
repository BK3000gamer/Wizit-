extends Node3D
class_name CardSpawner

@export var card_powerups: PackedScene
@export var spawn_interval: float = 3.0

@onready var spawnpoints_container := $CardSpawnPoints
var spawn_markers: Array[Node] = []
var spawn_timer := Timer.new()

func _ready() -> void:
	spawn_markers = spawnpoints_container.get_children()
	
	if spawn_markers.is_empty():
		push_error("No Spawn Points Available")
		return
	
	add_child(spawn_timer)
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_scatter_cards)
	spawn_timer.start()
	
	for i in range(3):
		_scatter_cards()

func _scatter_cards() -> void:
	if not card_powerups:
		push_error("No card powerup reference")
		return

	var vacant_spawns: Array[Node] = \
	spawn_markers.filter(func(marker: Node): return marker.get_child_count() == 0)

	if vacant_spawns.is_empty():
		return

	var new_powerup = card_powerups.instantiate()
	var choose_spawn: Marker3D = vacant_spawns.pick_random()

	choose_spawn.add_child(new_powerup)
	new_powerup.position = Vector3.ZERO
