extends Node

var winner:String = "UNDEFINED"

var death_order = []

var player_info = {}

var player_models = ["chicken1", "chicken1", "chicken1", "chicken1", "chicken1", "chicken1"]
var player_res = preload("res://SubScenes/Player/Player.tscn")

var projectile_holder : Node2D
var terrain_holder : Node2D
var chest_holder : Node2D
var chest_spawner : Node2D
var game_camera : Camera2D

# Number of players at the start of the game
var num_players : int = 2
# Team settings
enum TeamMode {
	NO_TEAMS,
	TWO_TEAMS,
	THREE_TEAMS
}
var TEAM_MODE = TeamMode.NO_TEAMS

# Whether the player is allowed more than one shot per turn
var oneshot = true
# Length of each turn, in seconds
var turn_duration : float = 12.0
# The visible timer runs out coyote_time seconds before turn ends
var coyote_time : float = 0.25

var starting_inventory = {
	"bomb": 200,
	"rocket": 2,
	"candle": 2
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
	print(num_players)
	var spawnpoints = turn_queue.level.get_spawnpoints()
	for i in range(num_players):
		var new_player = player_res.instance()
		turn_queue.add_child(new_player)
		new_player.player_body.load_player_model(player_models[i])
		new_player.player_body.position = spawnpoints[i]
		# Create a dict of the players to reference later
		player_info[new_player.name] = new_player
	
	projectile_holder = turn_queue.level.projectile_holder
	terrain_holder = turn_queue.level.get_node("Terrain")
	chest_holder = turn_queue.level.get_node("ChestHolder")
	chest_spawner = turn_queue.level.get_node("ChestSpawner")
	game_camera = turn_queue.level.get_node("GameCamera")
	
	winner = "UNDEFINED"
	


func get_starting_inventory() -> Dictionary:
	return starting_inventory.duplicate()

func get_chest_contents() -> Dictionary:
#	return Utilities.rand_choice([{"bomb": 1}, {"rocket": 1}, {"candle": 1}])
	return Utilities.rand_choice([{"rocket": 1}, {"candle": 1}])

func get_turns_til_next_chest() -> int:
	return randi() % 3 + 1

# Set the name of the winner, for use on winscreen
func set_winner(playername:String):
	winner = playername

# Record a death, for potential use later
func rec_death(playername:String):
	death_order.append(playername)
