extends Node


var winner:String = "UNDEFINED"

var death_order = []

var player_info = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Get information at the start of a match
func initialize_match(turn_queue:TurnQueue) -> void:
	winner = "UNDEFINED"
	
	# Create a dict of the players to reference later
	for player in turn_queue.get_children():
		player_info[player.name] = player
		
	return

# Set the name of the winner, for use on winscreen
func set_winner(playername:String):
	winner = playername

# Record a death, for potential use later
func rec_death(playername:String):
	death_order.append(playername)
