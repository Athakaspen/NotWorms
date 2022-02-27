extends Control

var menu_path = "res://MainScenes/MainMenu.tscn"

var player_entry_res = preload("res://SubScenes/Menu/WinScreenCharacter.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	$UI/MainMenuButton.grab_focus()
	
	# clear data from player holder
	Utilities.queue_free_children($UI/PlayerHolder)
	
	# Add each player entry and set their data
	for player in MatchInfo.player_info.values():
		var entry = player_entry_res.instance()
		$UI/PlayerHolder.add_child(entry)
		var model = player.player_body.sprite
		player.player_body.remove_child(model)
		var is_winner
		if MatchInfo.TEAM_MODE == "off":
			is_winner = not player.is_dead
		else:
			is_winner = player.team == MatchInfo.winning_team
		entry.set_data(player.get_gamertag(), player.team, model, is_winner)
		var stat1 = "Damage\nDealt: " + str(MatchInfo.damage_dealt[player.name])
		var stat2 = " "
		if MatchInfo.kill_count[player.name] > 0:
			stat2 = "Kills: " + str(MatchInfo.kill_count[player.name])
		elif MatchInfo.killed_by[player.name] != "UNDEFINED":
			stat2 = "Died to " + \
				MatchInfo.player_info[MatchInfo.killed_by[player.name]].get_gamertag()
		elif len(MatchInfo.death_order) > 0 and \
			 MatchInfo.death_order[0] == player.name:
			stat2 = "Died First"
		entry.set_stats(stat1, stat2)
	
	$UI/Title.text = MatchInfo.get_win_text()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_MainMenuButton_pressed():
	get_tree().change_scene(menu_path)
