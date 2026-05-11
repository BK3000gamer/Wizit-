extends CharacterBody3D
class_name Player

#Card Abilities
var card_id: Array[String] = \
["Dash", "Speed Boost", "Stomp", "Updraft"]

#Inventory
var current_cards: Array[String] = []

var InputDir := Vector3.ZERO
var CurrentState: String
var PreviousState: String

@onready var StateMachine := $"State Machine"
@onready var MovementController := $"Movement Controller"
@onready var CameraController := $"Camera Controller"

func _ready() -> void:
	StateMachine.init(self)

func _unhandled_input(event: InputEvent) -> void:
	StateMachine.process_input(event)
	MovementController.process_input(event)
	CameraController.process_input(event)

func _physics_process(delta: float) -> void:
	StateMachine.process_physics(delta)
	MovementController.process_physics(delta)
	

#Card Pickup
func pickup_card() -> void:
	if current_cards.size() >=9:
		print("Inventory is Full")
		return

	var given_card: String = card_id.pick_random()
	current_cards.append(given_card)
	print("Inventory: ", current_cards)
	
