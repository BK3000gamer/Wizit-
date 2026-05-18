extends Area3D

@onready var parent := $".."
@onready var collision := $CollisionShape3D

func _process(_delta: float) -> void:
	if parent.WIZIT:
		collision.set_deferred("disabled", true)
	else:
		collision.set_deferred("disabled", false)

func tagged() -> void:
	parent.WIZIT = true
	parent.StateMachine.transition("Freeze")
