extends Label


func _process(delta: float) -> void:
	var m = GlobalTimer.m
	var s = GlobalTimer.s
	text = '%02d:%02d' % [m, s]
