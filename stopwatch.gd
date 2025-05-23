extends Node

var running: bool = false
var time_elapsed: float = 0.0

func start() -> void:
	time_elapsed = 0.0 # If we were to have the stopwatch run multiple times this would be useful
	running = true

func stop() -> float:
	running = false 
	return time_elapsed

func _process(delta: float) -> void:
	if running:
		time_elapsed += delta # Delta represents time since last frame
