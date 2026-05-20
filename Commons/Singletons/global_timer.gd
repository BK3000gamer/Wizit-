extends Node

@onready var RoundTotalTime: int = 180

var m: int = 0
var s: int = 0
var timer: Timer
var time: int

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	m = int(time / 60)
	s = time - m * 60
	
	if time == 0:
		stop_game()

func start_game() -> void:
	time = RoundTotalTime
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.timeout.connect(timeout)
	timer.start()

func stop_game() -> void:
	if timer:
		timer.stop()
		timer.queue_free()

func timeout():
	time -= 1
