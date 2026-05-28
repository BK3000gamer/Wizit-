extends CharacterBody3D
class_name Player

var card_id: Array[String] = ["Dash", "Speed Boost", "Stomp", "Updraft"]
@export var current_cards: Array[String] = []
@export var active_slot: int = 0
var InputDir := Vector3.ZERO
var PreviousState: String
var slide_cooldown: float = 0.5
var tag_cooldown: bool = false

@onready var InputNode := $PlayerInput
@onready var StateMachine := $"State Machine"
@onready var MovementController := $"Movement Controller"
@onready var CameraController := $"Camera Controller"
@onready var AnimPlayer := $"Wizard/3D Animation Player"

@export var sync_position: Vector3
@export var sync_rotation: float
@export var CurrentState: String
@export var is_grounded: bool = true

@export var xray_shader_material: ShaderMaterial

@export var WIZIT: bool = false:
	set(new_value):
		if WIZIT == new_value: return
		WIZIT = new_value
		if not is_inside_tree(): return
		_on_wizit_state_changed(WIZIT)

func _ready() -> void:
	add_to_group("all_wizard_players")
	StateMachine.init(self)
	_make_materials_unique()
	update_xray_visuals()
	

	
func _enter_tree() -> void:
	var my_peer_id = name.to_int()
	set_multiplayer_authority(1)
	if has_node("StateSynchronizer"):
		$StateSynchronizer.set_multiplayer_authority(1)
	
	$PlayerInput.set_multiplayer_authority(my_peer_id)
	$InputSynchronizer.set_multiplayer_authority(my_peer_id)
	
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
		if slide_cooldown > 0.0:
			slide_cooldown -= delta
			
		InputDir = Vector3(InputNode.direction.x, 0.0, InputNode.direction.y)
		StateMachine.process_physics(delta)
		MovementController.process_physics(delta)
		
		if InputNode.is_sliding and is_on_floor() and velocity.length() > 3.0:
			if StateMachine.CurrentState.name != "Slide" && slide_cooldown <= 0.0:
				StateMachine.transition("Slide")
				slide_cooldown = 0.5
		
		elif not InputNode.is_sliding and StateMachine.CurrentState.name == "Slide":
			StateMachine.transition("Idle")
		
		if not is_on_floor():
			velocity.y += MovementController._get_gravity() * delta
			
		move_and_slide()
		
		sync_position = global_position
		sync_rotation = rotation.y
		CurrentState = StateMachine.CurrentState.name
		is_grounded = is_on_floor()
		
	else:
		global_position = global_position.lerp(sync_position, 15 * delta)
		
		if name.to_int() != multiplayer.get_unique_id():
			rotation.y = lerp_angle(rotation.y, sync_rotation, 15 * delta)
			
		if CurrentState != "" and StateMachine.CurrentState.name != CurrentState:
			StateMachine.transition(CurrentState)
		
	_update_animations()

func _update_animations() -> void:
	if CurrentState != PreviousState:
		
		if AnimPlayer and AnimPlayer.has_animation(CurrentState):
			AnimPlayer.play(CurrentState)
			
		if is_in_group("local_player"):
			if CurrentState == "Freeze":
				CameraController.isInFirstPerson = false
				$Wizard.visible = true
			else:
				CameraController.isInFirstPerson = true
				$Wizard.visible = false
				if CurrentState == "Slide":
					CameraController.target_height = 0.0
				else:
					CameraController.target_height = 0.5
		else:
			$Wizard.visible = true
		if not multiplayer.is_server():
			if StateMachine and is_instance_valid(StateMachine.CurrentState):
				if StateMachine.CurrentState.name != CurrentState and StateMachine.has_node(CurrentState):
					StateMachine.transition(CurrentState)
						
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

func _make_materials_unique() -> void:
	var body_parts = ["Arm", "Beard", "Eyebrow", "Face", "Hand", "Hat", "Leg", "Robe", "Shoe", "Stash"]
	for part in body_parts:
		var mesh = get_node_or_null("Wizard/Armature/Skeleton3D/" + part)
		if mesh:
			var mat = mesh.get_active_material(0)
			if mat:
				var unique_mat = mat.duplicate(false) 
				unique_mat.set_meta("original_next_pass", unique_mat.next_pass)
				mesh.set_surface_override_material(0, unique_mat)

func _on_wizit_state_changed(new_value: bool) -> void:
	if new_value == false:
		tag_cooldown = true
		get_tree().create_timer(1.5).timeout.connect(func():
			if is_instance_valid(self):
				tag_cooldown = false
		)
		
	call_deferred("_refresh_all_visuals")

func _refresh_all_visuals() -> void:
	for p in get_tree().get_nodes_in_group("all_wizard_players"):
		if is_instance_valid(p) and p.has_method("update_xray_visuals"):
			p.update_xray_visuals()

func update_xray_visuals() -> void:
	var body_parts = ["Arm", "Beard", "Eyebrow", "Face", "Hand", "Hat", "Leg", "Robe", "Shoe", "Stash"]
	var target_color = Color.RED if WIZIT else Color.WHITE
	
	var local_player = get_tree().get_first_node_in_group("local_player")
	
	var should_see_xray = false
	if local_player and local_player.WIZIT and not self.WIZIT:
		should_see_xray = true

	for part in body_parts:
		var mesh = get_node_or_null("Wizard/Armature/Skeleton3D/" + part)
		if not mesh: continue
		
		var mat = mesh.get_surface_override_material(0)
		if not mat: continue
			
		if mat is ShaderMaterial:
			mat.set_shader_parameter("albedo", target_color)
		else:
			mat.albedo_color = target_color
	
		if should_see_xray and xray_shader_material:
			var xray = xray_shader_material.duplicate(false)
			xray.set_shader_parameter("colour", Color.CYAN)
			mat.next_pass = xray
		else:
			mat.next_pass = null
			
@rpc("any_peer", "call_local", "reliable")
func request_active_tag(target_node_name: String) -> void:
	if not multiplayer.is_server(): return
	if not self.WIZIT: return
	
	var target_player = get_parent().get_node_or_null(target_node_name)
	
	if target_player and target_player is Player and not target_player.WIZIT and not target_player.tag_cooldown:
		
		rpc("set_wizit", false)
		target_player.rpc("set_wizit", true)
		target_player.rpc("force_freeze")

@rpc("call_local", "reliable")
func set_wizit(state: bool) -> void:
	self.WIZIT = state

@rpc("authority", "call_local", "reliable")
func force_freeze() -> void:
	if StateMachine.CurrentState.name != "Freeze":
		StateMachine.transition("Freeze")

			
