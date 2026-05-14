extends CharacterBody3D
class_name Player

#Card Abilities
var card_id: Array[String] = \
["Dash", "Speed Boost", "Stomp", "Updraft"]

#Inventory
var current_cards: Array[String] = []
var active_slot: int = 0

var InputDir := Vector3.ZERO
var CurrentState: String
var PreviousState: String

@onready var StateMachine := $"State Machine"
@onready var MovementController := $"Movement Controller"
@onready var CameraController := $"Camera Controller"

func _ready() -> void:
	StateMachine.init(self)
	
func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	if is_multiplayer_authority():
		add_to_group("local_player")

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): 
		return
	StateMachine.process_input(event)
	MovementController.process_input(event)
	CameraController.process_input(event)
	if event is InputEventKey and event.pressed and not event.echo:
		var input_index = event.keycode - KEY_1
		
		if input_index >= 0 and input_index < 9:
			active_slot = input_index
		
		if event.is_action_pressed("slot_up"):
			if active_slot < 8:
				active_slot += 1
			elif active_slot == 8:
				active_slot = 0
		elif event.is_action_pressed("slot_down"):
			if active_slot > 0:
				active_slot -= 1
			elif active_slot == 0:
				active_slot = 8
			
		if active_slot < current_cards.size():
			print("Equipped: ", current_cards[active_slot], " (Slot ", active_slot + 1, ")")
		else:
			print("Equipped: Empty Slot (Slot ", active_slot + 1, ")")
	
	if event.is_action_pressed("use"):
		use_equipped_card()

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): 
		return
	
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

func use_equipped_card() -> void:
	if active_slot >= current_cards.size():
		print("Slot is Empty")
		return
	var targeted_ability: String = current_cards[active_slot]
	var ability_triggered: bool = false
	match targeted_ability:
		"Dash", "Stomp", "Updraft":
			ability_triggered = \
			StateMachine.transition(targeted_ability)
			
			#Non State Transition Abilities
		"Speed Boost":
			ability_triggered = true
			MovementController.speed_boost()
	# Remove Card
	if ability_triggered:
		current_cards.remove_at(active_slot)
		print("Used ", targeted_ability," Inventory: ", current_cards)
		if active_slot >= current_cards.size() and current_cards.size() > 0:
			active_slot = current_cards.size() - 1
	else:
		print("Nothing Happened")
	
