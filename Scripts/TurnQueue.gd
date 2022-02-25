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

var turns_til_next_chest = 1

func initialize():
	player_list = get_children()
	MatchInfo.initialize_match(self)
	turnDuration = MatchInfo.turn_duration
	main_loop()

func main_loop():
	while true:
		active_player = get_next_player()
		STATE = State.PRETURN
		yield(init_preturn(), "completed")
		
		# Stop if we've detected that the game is over
		if STATE == State.GAMEOVER: 
			do_endgame()
			break
		if active_player.is_dead:
			continue
		
		STATE = State.TURN
		yield(play_turn(), "completed")
		
		# Stop if we've detected that the game is over
		if STATE == State.GAMEOVER: 
			do_endgame()
			break
		
		# This state is to wait until all explosives explode
		STATE = State.POSTTURN
#		if MatchInfo.projectile_holder.get_child_count() > 0:
		yield(init_postturn(), "completed")
		active_player.finish_turn()
		
		# Stop if we've detected that the game is over
		if STATE == State.GAMEOVER: 
			do_endgame()
			break
		
		turns_til_next_chest -= 1
		if turns_til_next_chest <= 0:
			STATE = State.CHEST
			yield(init_chest_spawn(), "completed")
		
		# Stop if we've detected that the game is over
		if STATE == State.GAMEOVER: 
			do_endgame()
			break

func get_next_player():
	var new_player = null
	while (new_player == null or new_player.is_dead):
		new_player = player_list.pop_front()
		player_list.append(new_player)
	return new_player

func _process(delta : float) -> void:
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

func do_endgame():
	CAM_MODE = CamMode.PROJECTILE
	yield(get_tree().create_timer(1.0), "timeout")
	# Remove the winner as a child or it will be forceably deleted
	remove_child(winner)
	# Go straight to win screen
	get_tree().change_scene(winscreen_path)

func get_current_player() -> Player:
	return active_player

func get_timer_progress() -> float:
	if STATE == State.GAMEOVER: return 0.0
	return active_player.get_timer_progress()

func check_win() -> void:
	
	# Don't check wins again after one was found
	if STATE == State.GAMEOVER: return
	
	var num_players = get_child_count()
	#print ("Checking win... " + str(num_players) + " Players...")
	
	if num_players >= 2:
		# no winner
		return
	elif num_players == 1:
		# We have a winner!
		STATE = State.GAMEOVER
		winner = get_child(0)
		print("Winner: " + winner.name)
		MatchInfo.set_winner(winner.name)
		
		winner.set_invincible()
		
		return
	else:
		# Num Players is 0, we have a problem
		print("This is a problem")
		STATE = State.GAMEOVER
		level.UI.do_deathtoast("Everyone")

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
			var player_weight = 0.8
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
	print("Turn ended by external caller")
	active_player.end_turn()
