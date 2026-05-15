extends Node

@onready var parent := $".."
@onready var AnimationTree3D := $"../3D Animation Tree"

func _process(delta: float) -> void:
	var vel: Vector3 = parent.global_transform.basis.inverse() * parent.velocity
	var dir := Vector2(vel.x, -vel.z)
	if dir.length() > 0.01:  # avoid jitter when nearly still
		dir = dir.normalized()
	
	AnimationTree3D.set("parameters/Run/blend_position", dir)
