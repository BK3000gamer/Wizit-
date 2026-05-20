extends Area3D
class_name HurtBox

@onready var collision := $CollisionShape3D
@onready var FreezeState := $"../State Machine/Freeze"

var player : Player

func _ready() -> void:
	while player == null:
		player = get_tree().get_first_node_in_group("local_player")
		if player == null:
			await get_tree().process_frame

func _process(_delta: float) -> void:
	if player.WIZIT:
		collision.set_deferred("disabled", true)
	else:
		collision.set_deferred("disabled", false)

func tagged(tagged_by_wizit: bool) -> void:
	if player.WIZIT:
		pass
	else:
		if player.CurrentState == "Freeze":
			if tagged_by_wizit:
				return
			else:
				FreezeState.timer_timeout()
		else:
			if tagged_by_wizit:
				player.WIZIT = true
				FreezeState.time = 3.0
				player.StateMachine.transition("Freeze")
