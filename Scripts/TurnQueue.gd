extends Node

class_name TurnQueue

var winscreen_path := "res://MainScenes/WinScreen.tscn"

var turnDuration : float

enum State {
	INIT,
	PRETURN,
	TURN,
	POSTTURN,
	CHEST,
	GAMEOVER
}
var STATE = State.INIT

enum CamMode {
	PLAYER,
	MIDPOINT,
	PROJECTILE,
	CHEST
}
var CAM_MODE = CamMode.PLAYER

# reference to parent
# not sure if this is really necessary
onready var level = $".."

var active_player : Player
var winner : Player = null
var player_list

var team_turn_queue

var turns_til_next_chest = MatchInfo.get_turns_til_next_chest()
var turns_til_next_barrel = MatchInfo.get_turns_til_next_barrel()
var turns_til_next_lettuce = MatchInfo.get_turns_til_next_lettuce()

func initialize():
	
	MatchInfo.initialize_match(self)
	turnDuration = MatchInfo.turn_duration
	player_list = get_children()
	
	# Setup for team based turns
	if MatchInfo.TEAM_MODE == "two" or MatchInfo.TEAM_MODE == "three":
		team_turn_queue = []
		var red = []
		var blue = []
		var green = []
		for player in player_list:
			match player.team:
				"red":
					red.append(player)
				"blue":
					blue.append(player)
				"green":
					green.append(player)
		team_turn_queue = [red, blue, green]
		team_turn_queue.shuffle()
	
	
	# Wait a second for a dramatic wide angle
	yield(get_tree().create_timer(1.5), "timeout")
	
	level.UI.visible = true
	level.camera.set_active()
	main_loop()

func main_loop():
	while true:
#		print ("Loop top")
		active_player = get_next_player()
		STATE = State.PRETURN
		yield(init_preturn(), "completed")
		
		# Stop if we've detected that the game is over
		if STATE == State.GAMEOVER: 
#			do_endgame()
			break
		if active_player.is_dead:
			continue
		
		STATE = State.TURN
		yield(play_turn(), "completed")
		
		# Stop if we've detected that the game is over
		if STATE == State.GAMEOVER: 
#			do_endgame()
			break
		
		# This state is to wait until all explosives explode
		STATE = State.POSTTURN
#		if MatchInfo.projectile_holder.get_child_count() > 0:
		yield(init_postturn(), "completed")
		active_player.finish_turn()
		
		# Stop if we've detected that the game is over
		if STATE == State.GAMEOVER: 
#			do_endgame()
			break
		
		# Reset zoom after the player's turn is done
		MatchInfo.game_camera.reset_zoom()
		
		#Items
		turns_til_next_chest -= 1
		if turns_til_next_chest <= 0:
			STATE = State.CHEST
			yield(init_chest_spawn(), "completed")
		
		turns_til_next_barrel -= 1
		if turns_til_next_barrel <= 0:
			STATE = State.CHEST
			yield(init_barrel_spawn(), "completed")
		
		turns_til_next_lettuce -= 1
		if turns_til_next_lettuce <= 0:
			STATE = State.CHEST
			yield(init_lettuce_spawn(), "completed")
		
		# Stop if we've detected that the game is over
		if STATE == State.GAMEOVER: 
#			do_endgame()
			break

# This doesn't work because yield is weird
#func do_items_phase():
#	turns_til_next_chest -= 1
#	if turns_til_next_chest <= 0:
#		STATE = State.CHEST
#		yield(init_chest_spawn(), "completed")
#		print("yield1 done")
#
#	turns_til_next_barrel -= 1
#	if turns_til_next_barrel <= 0:
#		STATE = State.CHEST
#		yield(init_barrel_spawn(), "completed")
#		print("yield2 done")

func get_next_player():
	if MatchInfo.TEAM_MODE == "off":
		# Standard free-for-all ordering
		var new_player = null
		while (new_player == null or new_player.is_dead):
			new_player = player_list.pop_front()
			player_list.push_back(new_player)
		return new_player
	else:
		# Team-based turn ordering
		var new_team = team_turn_queue.pop_front()
		while (new_team == []):
			team_turn_queue.push_back(new_team)
			new_team = team_turn_queue.pop_front()
		# Now we have the next team with live players
		var new_player = new_team.pop_front()
		while new_player.is_dead:
			if new_team == []:
				team_turn_queue.push_front(new_team)
				return get_next_player()
			else:
				new_player = new_team.pop_front()
		# At this point, we know new_palyer is the next player who should play.
		# Not just reset things to it's ready for next call
		new_team.push_back(new_player)
		team_turn_queue.push_back(new_team)
		return new_player

func shuffle_player_order():
	var children = get_children()
	children.shuffle()
	for child in children:
		move_child(child, 0)

func _process(_delta : float) -> void:
	if STATE != State.INIT:
		level.update_camera(get_camera_point())
		level.update_UI()
		check_win()

func init_preturn():
	active_player.init_preturn()
	level.UI.init_preturn()
	CAM_MODE = CamMode.PLAYER
	yield(level.UI, "start_turn")

func play_turn():
	level.UI.init_turn()
	CAM_MODE = CamMode.MIDPOINT
	yield(active_player.play_turn(turnDuration), "completed")

func init_postturn():
	CAM_MODE = CamMode.PROJECTILE
	level.UI.init_postturn()
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	yield(MatchInfo.projectile_holder, "no_children")
	yield(get_tree().create_timer(1.0), "timeout")

func init_chest_spawn():
	MatchInfo.chest_spawner.spawn_chest()
	turns_til_next_chest = MatchInfo.get_turns_til_next_chest()
	CAM_MODE = CamMode.CHEST
	yield(get_tree().create_timer(2.5), "timeout")

func init_barrel_spawn():
	MatchInfo.chest_spawner.spawn_barrel()
	turns_til_next_barrel = MatchInfo.get_turns_til_next_barrel()
	CAM_MODE = CamMode.CHEST
	yield(get_tree().create_timer(2.5), "timeout")

func init_lettuce_spawn():
	MatchInfo.chest_spawner.spawn_lettuce()
	turns_til_next_lettuce = MatchInfo.get_turns_til_next_lettuce()
	CAM_MODE = CamMode.CHEST
	yield(get_tree().create_timer(2.5), "timeout")

func do_endgame():
	CAM_MODE = CamMode.PROJECTILE
	yield(get_tree().create_timer(1.6), "timeout")
	# Remove the winners as children or they will be forceably deleted
	for child in get_children():
		remove_child(child)
	# Go straight to win screen
# warning-ignore:return_value_discarded
	get_tree().change_scene(winscreen_path)

func get_current_player() -> Player:
	return active_player

func get_timer_progress() -> float:
	if STATE == State.GAMEOVER: return 0.0
	return active_player.get_timer_progress()

func check_win() -> void:
	
	# Don't check wins again after one was found
	if STATE == State.GAMEOVER: return
	
	if MatchInfo.TEAM_MODE == "off":
		var num_players = get_child_count()
		#print ("Checking win... " + str(num_players) + " Players...")
		
		if num_players >= 2:
			# no winner
			pass
#			return
		elif num_players == 1:
			# We have a winner!
			STATE = State.GAMEOVER
			winner = get_child(0)
	#		print("Winner: " + winner.get_gamertag())
#			MatchInfo.set_winner(winner.name)
			MatchInfo.add_winner_name(winner.name)
#			MatchInfo.winner_tag = winner.get_gamertag()
			MatchInfo.add_winner_tag(winner.get_gamertag())
			
			winner.set_invincible()
#			return
		else:
			# Num Players is 0, we have a problem
			print("This is a problem")
			STATE = State.GAMEOVER
			level.UI.do_deathtoast("Everyone")
	
	else: # This is in two or three team mode
		if get_child_count() == 0:
			# everyone died
			print("This is a problem")
			STATE = State.GAMEOVER
			level.UI.do_deathtoast("Everyone")
#			return
		else:
			# Check if more than one team is still alive
			var first_team = get_child(0).team
			var is_it_gameover = true
			for child in get_children():
				if child.team != first_team:
					is_it_gameover = false
					break
			if is_it_gameover:
				# If we get here, only one team is left
				STATE = State.GAMEOVER
				# Add all players to winner list
				MatchInfo.set_winning_team(first_team)
				for child in get_children():
					MatchInfo.add_winner_name(child.name)
					MatchInfo.add_winner_tag(child.get_gamertag())
					child.set_invincible()
	if STATE == State.GAMEOVER:
		do_endgame()

var prev_cam_point : Vector2
# Return the point the camera should be moving towards this frame.
func get_camera_point() -> Vector2:
	
	check_win()
	
	#If the game is over, don't move the camera, to be safe
	if STATE == State.GAMEOVER: return prev_cam_point
	
	var player_pos = active_player.player_body.global_position
	var cam_point = Vector2.ZERO
	match CAM_MODE:
		CamMode.PLAYER:
			# follow player only
			cam_point = player_pos
		CamMode.MIDPOINT:
			# follow weighted midpoint of aiming
			var player_weight = 1.1
			cam_point = (player_weight*player_pos + active_player.player_body.aim_point.global_position) / (1+player_weight)
		CamMode.PROJECTILE:
			# Follow projectiles
			cam_point = MatchInfo.projectile_holder.get_cam_point()
			if cam_point == null:
				cam_point = prev_cam_point
		CamMode.CHEST:
			# Jump to most recently spawned chest
			cam_point = MatchInfo.chest_spawner.get_cam_point()
			if cam_point == null:
				cam_point = prev_cam_point
	
	
	prev_cam_point = cam_point
	return cam_point

func end_turn() -> void:
	print("Turn ended by external caller (probably the UI)")
	active_player.end_turn()
