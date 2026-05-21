extends Node

var scores: Dictionary = {}
var current_map_name: String = "Test"

signal match_ended 

func add_survival_point(peer_id: int) -> void:
	if not multiplayer.is_server(): return
	
	scores[peer_id] = scores.get(peer_id, 0) + 1

@rpc("authority", "call_local", "reliable")
func sync_final_scores(final_scores: Dictionary) -> void:
	scores = final_scores
	match_ended.emit() 

func purge_ledger() -> void:
	scores.clear()
