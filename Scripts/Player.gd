extends Node

class_name Player

signal turn_done

onready var player_body = $PlayerBody
onready var turn_timer = $TurnTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	$NametagPosition/PlayerNametag.text = name

func _process(_delta):
	$NametagPosition.position = $PlayerBody.position + Vector2.UP * 50

# This function is called when the "Ready Up" screen shows,
# before the actual turn begins. It's here to set up visuals mostly.
func init_preturn():
	player_body.init_preturn()

func play_turn(turn_dur:float) -> void:
	# print("It's %s's turn!" % name)
	
	turn_timer.wait_time = turn_dur
	
	# Set active player's body to active
	player_body.set_turn_active(true);
	turn_timer.start()
	
	# Don't return until we emit a signal
	yield(self, "turn_done")

#func wait_end_turn(dur : float):
#	yield(get_tree().create_timer(dur), "timeout")
#	end_turn()

func end_turn():
	player_body.set_turn_active(false)
	# Stop the timer if it's still going
	turn_timer.stop()
	emit_signal("turn_done")

func get_body() -> Node:
	return player_body

func get_timer_progress() -> float:
	# Return 1 if the timer is stopped (hasn't started yet)
	if turn_timer.is_stopped(): return 1.0
	# else calcualte the value
	return turn_timer.time_left/turn_timer.wait_time

func _on_TurnTimer_timeout():
	end_turn()
