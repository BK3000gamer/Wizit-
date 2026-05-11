extends Area3D
class_name CardPickup

@onready var card := $Card
var dir = 1.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

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
		body.pickup_card()
		queue_free()
