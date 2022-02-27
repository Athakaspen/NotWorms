extends Control

onready var turn_timer = $Turn/TurnTimer
onready var level = $"../.."
onready var inv_list = $Inventory/CenterContainer/VBoxContainer/HBoxContainer
#onready var inv_info = $Inventory/CenterContainer/VBoxContainer
onready var inv_info_name = $Inventory/CenterContainer/VBoxContainer/Name
onready var inv_info_desc = $Inventory/CenterContainer/VBoxContainer/Description
onready var inv_info_count = $Inventory/CenterContainer/VBoxContainer/Count

var inv_entry_res = preload("res://SubScenes/Menu/InventoryEntry.tscn")

signal start_turn
var cur_player : String

var in_preturn := false
var in_turn := false
var in_postturn := false
var in_inventory := false

var cur_entry

# Called when the node enters the scene tree for the first time.
func _ready():
	# So we can hide it in the editor
#	self.visible = true
	# UPDATE: This is now set in the turnqueue,
	# Set it to false for the wideshot instead
	self.visible = false
	
	$DeathToast.visible = false
	$WipeToast.visible = false
	$Inventory.visible = false

func _input(event):
	# This is really bad, should be updated
#	if event.is_action_pressed("ready") and $Preturn.visible and $Preturn/ReadyButton.visible:
#		emit_signal("start_turn")
#	if event.is_action_pressed("ready") and $Turn.visible and $Turn/EndTurnButton.visible:
#		_on_EndTurnButton_pressed()
	if event.is_action_pressed("menu_next") and in_inventory:
		next_weapon()
	if event.is_action_pressed("menu_prev") and in_inventory:
		prev_weapon()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_timer_progress(value:float):
	turn_timer.value = value

func set_current_player_name(value:String):
	cur_player = value
	$Turn/TurnLabelCorner.text = cur_player + "'s Turn"
	$Preturn/TurnLabelCenter.text = cur_player + "'s Turn"

func do_deathtoast(playername:String) -> void:
	$DeathToast/Text.text = playername + " has Died!"
	$DeathToast.visible = true
	$DeathToast/DeathToastTimer.start()

func do_wipetoast(team:String) -> void:
	match team:
		"red" : 
			$WipeToast/Text.text = "The Red Team has been Eliminated!"
		"blue" : 
			$WipeToast/Text.text = "The Blue Team has been Eliminated!"
		"green" : 
			$WipeToast/Text.text = "The Green Team has been Eliminated!"
	$WipeToast.visible = true
	$WipeToast/WipeToastTimer.start()

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
		$Preturn/ReadyButton.grab_focus()

func init_turn():
	in_preturn = false
	in_turn = true
	$Turn.visible = true
	$Preturn.visible = false
	
	$Turn/TurnTimer.visible = true
	
	$Turn/EndTurnLabel.visible = true
	
	# wait a sec before showing the end turn button
#	$Turn/EndTurnLabel.visible = false
#	yield(get_tree().create_timer(1.0), "timeout")
#	if in_turn:
#		$Turn/EndTurnLabel.visible = true

func show_inventory(inventory_data, cur_weapon):
	assert(in_turn or in_preturn, \
		"Attempted to open inventory outside of preturn or turn phase")
	update_inventory(inventory_data, cur_weapon)
	$Inventory.visible = true
	in_inventory = true

func hide_inventory() -> String:
	$Inventory.visible = false
	in_inventory = false
	if cur_entry == null:
		return "UNDEFINED"
	return cur_entry.id_string

func update_inventory(data, cur_weapon):
	# Clear the existing list
	Utilities.queue_free_children(inv_list)
	
	for weapon in data:
		if data[weapon] > 0:
			# Create an inventory entry for each weapon with more than 1 ammo
			var new_entry = inv_entry_res.instance()
			new_entry.name = weapon
			new_entry.id_string = weapon
			new_entry.pretty_name = GameData.WeaponData[weapon]["pretty_name"]
			new_entry.description = GameData.WeaponData[weapon]["description"]
			new_entry.count = data[weapon]
			new_entry.set_icon(GameData.WeaponData[weapon]["icon"])
			inv_list.add_child(new_entry)
			if weapon == cur_weapon:
				new_entry.set_active(true)
				cur_entry = new_entry
				inv_info_name.text = cur_entry.pretty_name
				inv_info_desc.text = cur_entry.description
				inv_info_count.text = str(cur_entry.count)
#	$Inventory/CenterContainer/VBoxContainer/Name.text = str(data["bomb"]["pretty_name"])
#	$Inventory/CenterContainer/VBoxContainer/Description.text = str(data["candle"]["description"])
#	$Inventory/CenterContainer/VBoxContainer/Count.text = str(data["rocket"]["count"])

func next_weapon():
	cycle_weapons(1)

func prev_weapon():
	cycle_weapons(-1)

# Helper for next_weapon and prev_weapon
func cycle_weapons(count : int):
	cur_entry.set_active(false)
	# fposmod is %, but works with negative nubmers too. Casted back to int.
	var new_index = int(fposmod(cur_entry.get_index()+count, inv_list.get_child_count()))
	cur_entry = inv_list.get_child(new_index)
	cur_entry.set_active(true)
	inv_info_name.text = cur_entry.pretty_name
	inv_info_desc.text = cur_entry.description
	inv_info_count.text = str(cur_entry.count)

func init_postturn():
	in_turn = false
	in_postturn = true
	$Turn/TurnTimer.visible = false
	$Turn/EndTurnLabel.visible = false

#func _on_EndTurnButton_pressed():
#	level.turn_queue.end_turn()

func _on_ReadyButton_pressed():
	emit_signal("start_turn")

func _on_DeathToastTimer_timeout():
	$DeathToast.visible = false

func _on_WipeToastTimer_timeout():
	$WipeToast.visible = false
