extends Area3D
class_name CardPickup

@onready var card := $Card
var dir = 1.0
var card_id: Array[String] = \
["Dash", "Speed Boost", "Stomp", "Updraft", "Arcane"]
var chosen_card: String

var player: Player

func _ready() -> void:
	while player == null:
		player = get_tree().get_first_node_in_group("local_player")
		if player == null:
			await get_tree().process_frame
	
	body_entered.connect(_on_body_entered)
	chosen_card = card_id.pick_random()

func _process(_delta: float) -> void:
	var material = card.get_active_material(0)
	if not material:
		push_error("No active material found on card")
		return
	
	material = material.duplicate()
	card.set_surface_override_material(0, material)
	match chosen_card:
		"Dash":
			material.albedo_color = Color("blue")
		"Stomp":
			material.albedo_color = Color("green")
		"Updraft":
			material.albedo_color = Color("purple")
		"Speed Boost":
			material.albedo_color = Color("yellow")
		"Arcane":
			if player.WIZIT:
				material.albedo_color = Color("red")
			else:
				material.albedo_color = Color("cyan")

func _physics_process(delta: float) -> void:
	#Spinny
	card.rotate_y(delta * 2.0)
	#Move Up Down
	if card.position.y > 0.25 or card.position.y < -0.0:
		dir = -dir
	card.position.y += 0.2 * dir * delta

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		#Roll Pickup
		body.pickup_card(chosen_card)
		queue_free()
