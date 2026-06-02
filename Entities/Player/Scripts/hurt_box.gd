extends Area3D
class_name HurtBox

@onready var collision := $CollisionShape3D
@onready var player: Player = get_parent() 

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if not multiplayer.is_server(): return
	
	if body is Player:
		if body.WIZIT and not player.WIZIT:
			
			if player.CurrentState == "Stasis":
				return
				
			if player.tag_cooldown:
				return
				
			tag_transfer(body)
			

func tag_transfer(tagger: Player) -> void:
	tagger.rpc("set_wizit", false)
	player.rpc("set_wizit", true)
	player.rpc("force_freeze")
