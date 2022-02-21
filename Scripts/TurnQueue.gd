extends Node

class_name TurnQueue

export(float) var turnDuration = 7.0

enum State {
	INIT,
	PRETURN,
	TURN,
	POSTTURN
}
var STATE = State.INIT

# reference to parent
# not sure if this is really necessary
onready var level = $".."

var active_player : Player

func initialize():
	active_player = get_child(0)
	main_loop()

func main_loop():
	while true:
		STATE = State.PRETURN
		yield(init_preturn(), "completed")
		STATE = State.TURN
		yield(play_turn(), "completed")

func init_preturn():
	active_player.init_preturn()
	level.UI.init_preturn()
	yield(level.UI, "start_turn")

func play_turn():
	level.UI.init_turn()
	yield(active_player.play_turn(turnDuration), "completed")
	var new_index : int = (active_player.get_index() + 1) % get_child_count()
	active_player = get_child(new_index)

func get_current_player() -> Player:
	return active_player

func get_timer_progress() -> float:
	return active_player.get_timer_progress()

# Badly named function. true means to include the mouse
# position in camera position, false means base cam position
# only on player position. Very confusing.
func get_camera_mode() -> bool:
	# Only return false in PRETURN state
	return STATE != State.PRETURN

func end_turn() -> void:
	print("Turn ended by external caller")
	active_player.end_turn()
