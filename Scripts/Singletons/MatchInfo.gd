extends Node

var winners_list = []
var winner_tags_list = []
var winning_team = "NULL"

var death_order = []

var player_info = {}

# stats
var damage_dealt = {}
var killed_by = {}
var kill_count = {}

var player_models = ["chicken1", "chicken1", "chicken1", "chicken1", "chicken1", "chicken1"]
var player_teams = ["normal", "normal", "normal", "normal", "normal", "normal"]
var player_res = preload("res://SubScenes/Player/Player.tscn")

var SFX_res = preload("res://SFX/ExplosionSFX1.tscn")

#this is used to give everyone unique tags
var used_tags = []

var projectile_holder : Node2D
var terrain_holder : Node2D
var chest_holder : Node2D
var chest_spawner : Node2D
var game_camera : Camera2D

# Number of players at the start of the game
var num_players : int = 2
# Team settings
#enum TeamMode {
#	NO_TEAMS,
#	TWO_TEAMS,
#	THREE_TEAMS
#}
# Team mode. Either "off", "two", or "three"
var TEAM_MODE = "off"

# Whether or not we should randomize turn order
var rand_turn_order := true
# Whether the player is allowed more than one shot per turn
var oneshot := true
# Length of each turn, in seconds
var turn_duration : float = 12.0
# The visible timer runs out coyote_time seconds before turn ends
var coyote_time : float = 0.25
# Starting health of each player
var starting_health : int = 100
# How often chests will drop
# values are "rare", "normal", "max"
# ACTUALLY, applies to all items
var chest_freq = "normal"
#The music track to play
var music_track : String = "Random"

var starting_inventory = {
	"bomb": 690,
	"rocket": 1,
	"candle": 1,
	"bag": 1
}

# Speed the game runs at normally
var normal_timescale : float = 1.0
# Speed the game runs at when a player's inventory is open
# Value of 1.0 means no slowdown, value of 0 means completely pause
var inventory_timescale : float = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Get information at the start of a match
func initialize_match(turn_queue:TurnQueue) -> void:
	# Reset values
	player_info = {}
	winners_list = []
	winner_tags_list = []
	winning_team = "NULL"
#	print(num_players)
	var player_list = []
	used_tags = []
	for i in range(num_players):
		var new_player = player_res.instance()
		turn_queue.add_child(new_player)
		new_player.player_body.load_player_model(player_models[i], player_teams[i])
		new_player.set_team(player_teams[i])
		new_player.MAX_HEALTH = starting_health
		new_player.health = starting_health
		# Create a dict of the players to reference later
		player_info[new_player.name] = new_player
		# init stats
		damage_dealt[new_player.name] = 0
		kill_count[new_player.name] = 0
		killed_by[new_player.name] = "UNDEFINED"
		# This is redundant and bad, but it's for spawnpoints below
		player_list.append(new_player)
	kill_count["UNDEFINED"] = 0
	damage_dealt["UNDEFINED"] = 0
	
	# Start Music
	Music.stop_music()
	if music_track == "Random":
		Music.start_random_music()
	elif music_track == "None":
		pass
	else:
		Music.start_music(music_track)
	
	# Place players at spawn points
	# This is gonna get messy
	var spawnpoints = turn_queue.level.get_spawnpoints()
	match TEAM_MODE:
		"off":
			spawnpoints.shuffle()
			for i in range(num_players):
				player_list[i].player_body.position = spawnpoints[i]
		"two":
			spawnpoints.shuffle()
			var t1 = spawnpoints[0]
			t1.shuffle()
			var t2 = spawnpoints[1]
			t2.shuffle()
			for player in player_list:
				if player.team == "red":
					player.player_body.position = t1.pop_back()
				elif player.team == "blue":
					player.player_body.position = t2.pop_back()
				else:
					print("Something went horribly wrong in 2-team spawning")
		"three":
			spawnpoints.shuffle()
			var t1 = spawnpoints[0]
			t1.shuffle()
			var t2 = spawnpoints[1]
			t2.shuffle()
			var t3 = spawnpoints[2]
			t3.shuffle()
			for player in player_list:
				if player.team == "red":
					player.player_body.position = t1.pop_back()
				elif player.team == "blue":
					player.player_body.position = t2.pop_back()
				elif player.team == "green":
					player.player_body.position = t3.pop_back()
				else:
					print("Something went horribly wrong in 3-team spawning")
	
	if rand_turn_order:
		turn_queue.shuffle_player_order()
	
	projectile_holder = turn_queue.level.projectile_holder
	terrain_holder = turn_queue.level.get_node("Terrain")
	chest_holder = turn_queue.level.get_node("ChestHolder")
	chest_spawner = turn_queue.level.get_node("ChestSpawner")
	game_camera = turn_queue.level.get_node("GameCamera")

func get_unique_tag(tag:String):
	if tag in used_tags:
		var i=1
		while tag + str(i) in used_tags:
			i+=1
		tag = tag + str(i)
	used_tags.append(tag)
	return tag

func get_starting_inventory() -> Dictionary:
	return starting_inventory.duplicate()

func get_chest_contents() -> Dictionary:
	return Utilities.rand_choice(GameData.PossibleChests).duplicate()

func get_turns_til_next_chest() -> int:
	match chest_freq:
		"rare":
			return randi() % 4 + 4
		"normal":
			return randi() % 3 + 2
		"max":
			return 1
	print("Unexpected chest_freq, defaulting to normal")
	return randi() % 3 + 1

func get_turns_til_next_barrel() -> int:
	match chest_freq:
		"rare":
			return randi() % 5 + 4
		"normal":
			return randi() % 4 + 2
		"max":
			return 1
	print("Unexpected chest_freq, defaulting to normal")
	return randi() % 4 + 2

func get_turns_til_next_lettuce() -> int:
	match chest_freq:
		"rare":
			return randi() % 5 + 4
		"normal":
			return randi() % 3 + 3
		"max":
			return 1
	print("Unexpected chest_freq, defaulting to normal")
	return randi() % 3 + 3

# Set the name of the winner, for use on winscreen
func add_winner_name(playername:String):
	winners_list.append(playername)

func add_winner_tag(tag:String):
	winner_tags_list.append(tag)

func set_winning_team(team:String):
	winning_team = team

func get_win_text() -> String:
	if TEAM_MODE == "off":
		if winner_tags_list == []:
			return "ENTROPY ALWAYS WINS"
		else:
			return winner_tags_list[0] + " Wins!"
	else:
		match winning_team:
			"red":
				return "The RED Team Wins!"
			"blue":
				return "The BLUE Team Wins!"
			"green":
				return "The GREEN Team Wins!"
	return "ENTROPY ALWAYS WINS"

# Record a death, for potential use later
func rec_death(dead_player:String, killing_player:String = "UNDEFINED"):
	death_order.append(dead_player)
	kill_count[killing_player] += 1
	killed_by[dead_player] = killing_player

# warning-ignore:unused_argument
func rec_damage(victim:String, culprit:String, amount:int):
	damage_dealt[culprit] += amount

func do_sound_effect(stream:AudioStream, position:Vector2, volume:float=0.0):
	var sfx = SFX_res.instance()
	sfx.position = position
	sfx.stream = stream
	sfx.volume_db = volume
	MatchInfo.chest_holder.call_deferred("add_child", sfx)
