extends Control

onready var turn_timer = $Turn/TurnTimer
onready var level = $"../.."


signal start_turn
var cur_player : String

var in_preturn := false
var in_turn := false
var in_postturn := false

# Called when the node enters the scene tree for the first time.
func _ready():
	$DeathToast.visible = false

func _unhandled_input(event):
	# This is really bad, should be updated
	if event.is_action_pressed("ready") and $Preturn.visible and $Preturn/ReadyButton.visible:
		_on_ReadyButton_pressed()
	if event.is_action_pressed("ready") and $Turn.visible and $Turn/EndTurnButton.visible:
		_on_EndTurnButton_pressed()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_timer_progress(value:float):
	turn_timer.value = value

func set_current_player_name(value:String):
	cur_player = value
	$Turn/TurnLabelCorner.text = cur_player + "'s Turn!"
	$Preturn/TurnLabelCenter.text = cur_player + "'s Turn!"

func do_deathtoast(playername:String) -> void:
	$DeathToast/Text.text = playername + " has Died!"
	$DeathToast.visible = true
	$DeathToast/DeathToastTimer.start()

func init_preturn():
	in_postturn = false
	in_preturn = true
	$Turn.visible = false
	$Preturn.visible = true
	
	# wait a sec before showing the ready button
	$Preturn/ReadyButton.visible = false
	yield(get_tree().create_timer(1.0), "timeout")
	if in_preturn:
		$Preturn/ReadyButton.visible = true

func init_turn():
	in_preturn = false
	in_turn = true
	$Turn.visible = true
	$Preturn.visible = false
	
	$Turn/TurnTimer.visible = true
	
	# wait a sec before showing the end turn button
	$Turn/EndTurnButton.visible = false
	yield(get_tree().create_timer(1.0), "timeout")
	if in_turn:
		$Turn/EndTurnButton.visible = true

func show_inventory(inventory_data, cur_weapon):
	assert(in_turn, "Attempted to open inventory outside of turn phase")
	update_inventory(inventory_data, cur_weapon)
	$Inventory.visible = true

func hide_inventory() -> String:
	$Inventory.visible = false
	return "candle"

func update_inventory(data, cur_weapon):
	$Inventory/CenterContainer/VBoxContainer/Name.text = str(data["bomb"]["pretty_name"])
	$Inventory/CenterContainer/VBoxContainer/Description.text = str(data["candle"]["description"])
	$Inventory/CenterContainer/VBoxContainer/Count.text = str(data["rocket"]["count"])

func init_postturn():
	in_turn = false
	in_postturn = true
	$Turn/TurnTimer.visible = false
	$Turn/EndTurnButton.visible = false

func _on_EndTurnButton_pressed():
	level.turn_queue.end_turn()

func _on_ReadyButton_pressed():
	emit_signal("start_turn")

func _on_DeathToastTimer_timeout():
	$DeathToast.visible = false
