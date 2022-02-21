extends Control

onready var turn_timer = $Turn/TurnTimer
onready var level = $"../.."


signal start_turn
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
	$Turn/TurnLabelCorner.text = cur_player + "'s Turn!"
	$Preturn/TurnLabelCenter.text = cur_player + "'s Turn!"

func init_preturn():
	$Turn.visible = false
	$Preturn.visible = true
	
	# wait a sec before showing the ready button
	$Preturn/ReadyButton.visible = false
	yield(get_tree().create_timer(1.0), "timeout")
	$Preturn/ReadyButton.visible = true

func init_turn():
	$Turn.visible = true
	$Preturn.visible = false

func _on_EndTurnButton_pressed():
	level.turn_queue.end_turn()

func _on_ReadyButton_pressed():
	emit_signal("start_turn")
