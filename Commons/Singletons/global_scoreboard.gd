extends Node

var scores: Dictionary = {}
var current_map_name: String = "Test"

signal match_ended 

signal local_score_updated(new_score: int)

func add_survival_point(peer_id: int) -> void:
	if not multiplayer.is_server(): return
	
	scores[peer_id] = scores.get(peer_id, 0) + 1
	
	rpc("sync_live_score", peer_id, scores[peer_id])
	
func add_points(peer_id: int, amount: int) -> void:
	if not multiplayer.is_server(): return
	scores[peer_id] = scores.get(peer_id, 0) + amount
	
	rpc("sync_live_score", peer_id, scores[peer_id])
	
@rpc("authority", "call_local", "reliable")
func sync_live_score(target_peer_id: int, new_total: int) -> void:
	scores[target_peer_id] = new_total
	if target_peer_id == multiplayer.get_unique_id():
		local_score_updated.emit(new_total)

@rpc("authority", "call_local", "reliable")
func sync_final_scores(final_scores: Dictionary) -> void:
	scores = final_scores
	match_ended.emit() 

func purge_ledger() -> void:
	scores.clear()
