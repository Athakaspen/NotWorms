extends Node

# Dictionary containing metadata about each weapon.
# Mostly used to create the inventory menu
var WeaponData = {
	"bomb":{
		"pretty_name": "Bouncy Bomb",
		"description": "Throw it and see what happens.\nBlows up after 3 seconds.",
		"damage": "XX",
		"icon": "res://icon.png",
		"resource": "res://SubScenes/Weapons/BouncyBomb.tscn"
	},
	"rocket":{
		"pretty_name": "Rocket Launcher",
		"description": "Long Range!\nExplodes on Impact!",
		"damage": "XX",
		"icon": "res://icon.png",
		"resource": "res://SubScenes/Weapons/RocketLauncher.tscn"
	},
	"candle":{
		"pretty_name": "Roman Candle",
		"description": "Barrage of rapid-fire,\nlow-damage projectiles.",
		"damage": "XX",
		"icon": "res://icon.png",
		"resource": "res://SubScenes/Weapons/RomanCandle.tscn"
	}
}

var PlayerModels = {
	"chicken1": "res://SubScenes/PlayerModels/Chicken1.tscn",
	"chicken2": "res://SubScenes/PlayerModels/Chicken2.tscn",
	"chicken3": "res://SubScenes/PlayerModels/Chicken3.tscn",
	"chicken4": "res://SubScenes/PlayerModels/Chicken4.tscn",
	"penguin1": "res://SubScenes/PlayerModels/Penguin1.tscn",
	"penguin2": "res://SubScenes/PlayerModels/Penguin2.tscn"
}



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
