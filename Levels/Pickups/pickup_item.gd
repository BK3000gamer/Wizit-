extends Area3D
class_name CardPickup

@onready var card := $Card
var dir = 1.0
var card_id: Array[String] = ["Dash", "Speed Boost", "Stomp", "Updraft", "Arcane"]
var chosen_card: String

var player: Player
var unique_material: Material

const dash = preload("res://Assets/Textures/Cards/Dash.png")
const updraft = preload("res://Assets/Textures/Cards/Updraft.png")
const speed = preload("res://Assets/Textures/Cards/Speed.png")
const stomp = preload("res://Assets/Textures/Cards/Stomp.png")
const freeze = preload("res://Assets/Textures/Cards/Freeze.png")
const scan = preload("res://Assets/Textures/Cards/Scan.png")

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	if multiplayer.is_server():
		var rolled = card_id.pick_random()
		
		call_deferred("rpc", "sync_card_data", rolled, position)

func _process(_delta: float) -> void:
	if chosen_card == "Arcane" and unique_material:
		if is_instance_valid(player):
			if player.WIZIT:
				unique_material.albedo_texture = scan
			else:
				unique_material.albedo_texture = freeze
		else:
			player = get_tree().get_first_node_in_group("local_player")

func _physics_process(delta: float) -> void:
	card.rotate_y(delta * 2.0)
	if card.position.y > 0.25 or card.position.y < 0.0:
		dir = -dir
	card.position.y += 0.2 * dir * delta

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		if multiplayer.is_server():
			body.pickup_card(chosen_card)
		queue_free()

@rpc("call_local", "reliable")
func sync_card_data(server_chosen_card: String, server_pos: Vector3) -> void:
	chosen_card = server_chosen_card
	
	position = server_pos
	
	var base_mat = card.get_active_material(0)
	if base_mat:
		unique_material = base_mat.duplicate()
		card.set_surface_override_material(0, unique_material)
		
		match chosen_card:
			"Dash": unique_material.albedo_texture = dash
			"Stomp": unique_material.albedo_texture = stomp
			"Updraft": unique_material.albedo_texture = updraft
			"Speed Boost": unique_material.albedo_texture = speed
	else:
		push_error("No active material found on card")
