extends Node
class_name PlayerInput

@export var direction := Vector2.ZERO
@export var look_angle: float = 0.0
@export var is_sliding: bool = false

var active_slot: int = 0

func _ready() -> void:
	set_process_unhandled_input(is_multiplayer_authority())
	set_physics_process(is_multiplayer_authority())

func _physics_process(_delta: float) -> void:
	direction = Input.get_vector("left", "right", "forward", "backward")
	look_angle = get_parent().rotation.y
	is_sliding = Input.is_action_pressed("slide")

func _unhandled_input(event: InputEvent) -> void:
	var root = get_parent()
	if root and root.CameraController:
		root.CameraController.process_input(event)
		
	var slot_changed = false
	
	# Inventory Scroll 
	if event.is_action_pressed("slot_up"):
		active_slot = active_slot + 1 if active_slot < 8 else 0
		slot_changed = true
	elif event.is_action_pressed("slot_down"):
		active_slot = active_slot - 1 if active_slot > 0 else 8
		slot_changed = true
		
	if event is InputEventKey and event.pressed and not event.echo:
		var input_index = event.keycode - KEY_1
		if input_index >= 0 and input_index < 9:
			active_slot = input_index
			slot_changed = true
			
	if slot_changed:
		rpc_id(1, "transmit_action", "ChangeSlot", active_slot)
	
	if event.is_action_pressed("jump"):
		rpc_id(1, "transmit_action", "Jump")
		
	if event.is_action_pressed("use"):
		rpc_id(1, "transmit_action", "Use", active_slot)

@rpc("any_peer", "call_local", "reliable")
func transmit_action(action: String, slot_index: int = 0) -> void:
	if not multiplayer.is_server():
		return
		
	var root = get_parent()
	
	match action:
		"Jump":
			if root.is_on_floor():
				root.StateMachine.transition("Jump")
		"ChangeSlot":
			root.active_slot = slot_index
		"Use":
			root.active_slot = slot_index
			root.use_equipped_card()
