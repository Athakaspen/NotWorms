extends Node

class_name TurnQueue

export(float) var turnDuration = 7.0

var active_player : Player

func initialize():
	active_player = get_child(0)
	main_loop()

func main_loop():
	while true:
		yield(play_turn(), "completed")

func play_turn():
	yield(active_player.play_turn(turnDuration), "completed")
	var new_index : int = (active_player.get_index() + 1) % get_child_count()
	active_player = get_child(new_index)

func get_current_player() -> Player:
	return active_player

func get_timer_progress() -> float:
	return active_player.get_timer_progress()

func end_turn() -> void:
	print("Turn ended by external caller")
	active_player.end_turn()
