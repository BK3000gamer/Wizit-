extends Node

@export var StartingState: State
@export var CurrentState: State

func init(Parent: Player) -> void:
	for child in get_children():
		child.parent = Parent
	
	change_state(StartingState)

func change_state(NewState: State) -> void:
	if CurrentState:
		CurrentState.exit()
	
	CurrentState = NewState
	CurrentState.enter()

func process_physics(delta: float) -> void:
	var NewState = CurrentState.process_physics(delta)
	if NewState:
		change_state(NewState)

func process_input(event: InputEvent) -> void:
	var NewState = CurrentState.process_input(event)
	if NewState:
		change_state(NewState)

func transition(target_state_name: String) -> bool:
	var fixed_states = ["Dash", "Stomp", "Updraft"]
	if CurrentState and CurrentState.name in fixed_states:
		return false 
		
	var target_state_node = get_node_or_null(target_state_name)
	
	if target_state_node and target_state_node is State:
		change_state(target_state_node)
		return true
	else:
		push_error("No State Match", target_state_name)
		return false
