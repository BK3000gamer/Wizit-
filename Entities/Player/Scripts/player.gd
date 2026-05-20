extends CharacterBody3D
class_name Player

var WIZIT: bool = false
var card_id: Array[String] = ["Dash", "Speed Boost", "Stomp", "Updraft"]
var current_cards: Array[String] = []
var active_slot: int = 0
var InputDir := Vector3.ZERO
var PreviousState: String

@onready var InputNode := $PlayerInput
@onready var StateMachine := $"State Machine"
@onready var MovementController := $"Movement Controller"
@onready var CameraController := $"Camera Controller"
@onready var AnimPlayer := $"Wizard/3D Animation Player"

@export var sync_position: Vector3
@export var sync_rotation: float
@export var CurrentState: String 

func _ready() -> void:
	StateMachine.init(self)
	
func _enter_tree() -> void:
	var my_peer_id = name.to_int()
	set_multiplayer_authority(1)
	if has_node("StateSynchronizer"):
		$StateSynchronizer.set_multiplayer_authority(1)
	
	$PlayerInput.set_multiplayer_authority(my_peer_id)
	$InputSynchronizer.set_multiplayer_authority(my_peer_id)
	
	$Wizard.visible = true
	if my_peer_id == multiplayer.get_unique_id():
		add_to_group("local_player")

	if multiplayer.is_server():
		collision_layer = 1
		collision_mask = 1
	else:
		if my_peer_id == multiplayer.get_unique_id():
			collision_layer = 1
			collision_mask = 1
		else:
			collision_layer = 0
			collision_mask = 0

func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		if InputNode.get_multiplayer_authority() != multiplayer.get_unique_id():
			rotation.y = InputNode.look_angle
		
		InputDir = Vector3(InputNode.direction.x, 0.0, InputNode.direction.y)
		StateMachine.process_physics(delta)
		MovementController.process_physics(delta)
		
		if InputNode.is_sliding and is_on_floor() and velocity.length() > 3.0:
			if StateMachine.CurrentState.name != "Slide":
				StateMachine.transition("Slide")
		
		elif not InputNode.is_sliding and StateMachine.CurrentState.name == "Slide":
			StateMachine.transition("Idle")
		
		if not is_on_floor():
			velocity.y += MovementController._get_gravity() * delta
			
		move_and_slide()
		
		sync_position = global_position
		sync_rotation = rotation.y
		CurrentState = StateMachine.CurrentState.name
		
	else:
		global_position = global_position.lerp(sync_position, 15 * delta)
		
		if name.to_int() != multiplayer.get_unique_id():
			rotation.y = lerp_angle(rotation.y, sync_rotation, 15 * delta)

	_update_animations()

func _update_animations() -> void:
	if CurrentState != PreviousState:
		if AnimPlayer and AnimPlayer.has_animation(CurrentState):
			AnimPlayer.play(CurrentState)
		PreviousState = CurrentState

func pickup_card(card: String) -> void:
	if current_cards.size() >= 9:
		return
	current_cards.append(card)

func use_equipped_card() -> void:
	if active_slot >= current_cards.size():
		return
		
	var targeted_ability: String = current_cards[active_slot]
	var ability_triggered: bool = false
	var num: int = 0
	var slots: Array[int] = []
	
	match targeted_ability:
		"Dash", "Stomp", "Updraft":
			ability_triggered = StateMachine.transition(targeted_ability)
		
		"Arcane":
			for c in range(current_cards.size()):
				if current_cards[c] == "Arcane":
					num += 1
					slots.append(c)
			
			if num >= 3:
				ability_triggered = true if WIZIT else StateMachine.transition("Freeze")
			
		"Speed Boost":
			ability_triggered = true
			MovementController.speed_boost()
			
	if ability_triggered:
		if num >= 3:
			current_cards.remove_at(slots[2])
			current_cards.remove_at(slots[1])
			current_cards.remove_at(slots[0])
		else:
			current_cards.remove_at(active_slot)
			
		if active_slot >= current_cards.size() and current_cards.size() > 0:
			active_slot = current_cards.size() - 1
	
