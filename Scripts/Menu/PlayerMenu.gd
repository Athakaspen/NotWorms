extends Control

export var MAX_PLAYERS := 6
export var MIN_PLAYERS := 2
var cur_players := 2

# Called when the node enters the scene tree for the first time.
func _ready():
	# Attach focus to the first entry
	$VBoxContainer/PlayerList/CharacterSelectEntry1.grab_focus()
	
	# Attach signal for all player select entries
	for child in $VBoxContainer/PlayerList.get_children():
		if child is CharacterSelectEntry:
			child.connect("character_changed", self, "_on_character_changed")
			child.connect("team_changed", self, "_on_team_changed")
	
	# Reset match info
	MatchInfo.player_models = ["chicken1", "chicken1", "chicken1", "chicken1", "chicken1", "chicken1"] 
	MatchInfo.player_teams = ["normal", "normal", "normal", "normal", "normal", "normal"]
	
	cur_players = MatchInfo.num_players
	# update the option label as well
	var option = $"VBoxContainer/MarginContainer2/HBoxContainer/VBoxContainer/NumPlayers"
	option._change_choice(cur_players - 2 - option._cur_index)
	option._toggle_active()
	option._toggle_active()
	update_visible_players()

func _on_PlusMinus_num_players_changed(new_count):
	MatchInfo.num_players = new_count

func _on_NumPlayers_value_changed(new_value):
	# convert from string to int
	cur_players = int(new_value)
	MatchInfo.num_players = cur_players
	update_visible_players()

func update_visible_players():
	for i in range(MAX_PLAYERS):
		$VBoxContainer/PlayerList.get_child(i).visible = i+1 <= cur_players

func _on_character_changed(index : int, new_model : String) -> void:
	MatchInfo.player_models[index] = new_model

func _on_team_changed(index : int, new_team : String) -> void:
#	print(index, new_team)
	MatchInfo.player_teams[index] = new_team

func _on_TurnLength_value_changed(new_value):
	# Get the numerical value from the text
	# Text is in the form "X sec"
	var int_value = float(new_value.split(" ")[0])
	MatchInfo.turn_duration = int_value

func _on_TeamMode_value_changed(new_value):
	match new_value:
		"Off": 
			MatchInfo.TEAM_MODE = "off"
		"2": 
			MatchInfo.TEAM_MODE = "two"
		"3": 
			MatchInfo.TEAM_MODE = "three"
	update_entry_teammodes(MatchInfo.TEAM_MODE)

func update_entry_teammodes(mode:String):
	for entry in $VBoxContainer/PlayerList.get_children():
		if entry is CharacterSelectEntry:
			entry.set_team_mode(mode)

func _on_StartButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://MainScenes/MapMenu.tscn")
