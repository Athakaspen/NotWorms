extends Control

onready var turn_timer = $TurnTimer
onready var level = $"../.."

var cur_player : String

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_timer_progress(value:float):
	turn_timer.value = value

func set_current_player_name(value:String):
	cur_player = value
	$Label.text = cur_player + "'s Turn!"


func _on_EndTurnButton_pressed():
	level.turn_queue.end_turn()
