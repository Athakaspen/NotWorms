extends Control



# Called when the node enters the scene tree for the first time.
func _ready():
	# Attach focus to the first entry
	$VBoxContainer/PlayerList/CharacterSelectEntry1.grab_focus()
	
	# Attach signal for all player select entries
	for child in $VBoxContainer/PlayerList.get_children():
		if child is CharacterSelectEntry:
			child.connect("character_changed", self, "_on_character_changed")

func _on_PlusMinus_num_players_changed(new_count):
	MatchInfo.num_players = new_count

func _on_character_changed(index : int, new_model : String) -> void:
	MatchInfo.player_models[index] = new_model

func _on_TurnLength_value_changed(new_value):
	# Get the numerical value from the text
	# Text is in the form "X sec"
	var int_value = float(new_value.split(" ")[0])
	MatchInfo.turn_duration = int_value

func _on_TeamMode_value_changed(new_value):
	match new_value:
		"Off": MatchInfo.TEAM_MODE = MatchInfo.TeamMode.NO_TEAMS
		"2": MatchInfo.TEAM_MODE = MatchInfo.TeamMode.TWO_TEAMS
		"3": MatchInfo.TEAM_MODE = MatchInfo.TeamMode.THREE_TEAMS

func _on_StartButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://MainScenes/Maps/Map1.tscn")
