extends Area3D
class_name CardPickup

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	#Spinny
	rotate_y(delta * 2.0)

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		#Roll Pickup
		body.pickup_card()
		queue_free()
