extends Node

@export var StartingState: State
var CurrentState: State

var parent: Player
signal state_changed(new_state_name: String)

func init(Parent: Player) -> void:
	parent = Parent
	for child in get_children():
		if child is State:
			child.parent = Parent
	
	if StartingState == null:
		StartingState = get_node_or_null("Idle")
		
	if StartingState:
		change_state(StartingState)
	else:
		push_warning("No StartingState")

func change_state(NewState: State) -> void:
	if NewState == null or NewState == CurrentState:
		return
		
	if CurrentState:
		CurrentState.exit()
	
	CurrentState = NewState
	CurrentState.enter()
	
	state_changed.emit(CurrentState.name)

func process_physics(delta: float) -> void:
	if CurrentState:
		var NewState = CurrentState.process_physics(delta)
		if NewState:
			change_state(NewState)

func process_input(event: InputEvent) -> void:
	if CurrentState:
		var NewState = CurrentState.process_input(event)
		if NewState:
			change_state(NewState)

func transition(target_state_name: String) -> bool:
	if CurrentState and CurrentState.name == target_state_name:
		return false
	var fixed_states = ["Dash", "Stomp", "Updraft", "Freeze"]
	if CurrentState and CurrentState.name in fixed_states:
		return false
		
	var target_state_node = get_node_or_null(target_state_name)
	
	if target_state_node and target_state_node is State:
		change_state(target_state_node)
		return true
		
	push_error("No State", target_state_name)
	return false
