extends Node

# Dictionary containing metadata about each weapon.
# Mostly used to create the inventory menu
var WeaponData = {
	"bomb":{
		"pretty_name": "Bouncy Bomb",
		"description": "Not the best weapon, but you seem to have a lot of these.\nBlows up after 3 seconds.",
		"damage": "XX",
		"icon": "res://Sprites/bomb.png",
		"resource": "res://SubScenes/Weapons/BouncyBomb.tscn"
	},
	"rocket":{
		"pretty_name": "Rocket Launcher",
		"description": "Long Range!\nExplodes on Impact!",
		"damage": "XX",
		"icon": "res://Sprites/rocket.png",
		"resource": "res://SubScenes/Weapons/RocketLauncher.tscn"
	},
	"candle":{
		"pretty_name": "Roman Candle",
		"description": "Barrage of low-damage,\nshort-range projectiles.",
		"damage": "XX",
		"icon": "res://Sprites/candle.png",
		"resource": "res://SubScenes/Weapons/RomanCandle.tscn"
	},
	"bag":{
		"pretty_name": "Bomb Bag",
		"description": "Found in a cave somewhere.\nReleases bombs on impact.",
		"damage": "XX",
		"icon": "res://Sprites/bag.png",
		"resource": "res://SubScenes/Weapons/BombBag.tscn"
	}
}

var PossibleChests = [
	{"rocket": 1},
	{"candle": 1},
	{"bag": 1},
	{"rocket": 2},
	{"candle": 2},
	{"bag": 2},
	{"rocket": 1, "candle": 1},
	{"candle": 1, "bag": 1},
	{"rocket": 1, "bag": 1},
	{"rocket": 1, "candle": 1, "bag": 1}
]

var PlayerModels = {
	"chicken1": "res://SubScenes/PlayerModels/Chicken1.tscn",
	"chicken2": "res://SubScenes/PlayerModels/Chicken2.tscn",
	"chicken3": "res://SubScenes/PlayerModels/Chicken3.tscn",
	"chicken4": "res://SubScenes/PlayerModels/Chicken4.tscn",
	"penguin1": "res://SubScenes/PlayerModels/Penguin1.tscn",
	"penguin2": "res://SubScenes/PlayerModels/Penguin2.tscn"
}

var TeamIDs = ["normal", "red", "blue", "green"]

# Map info
var Maps = {
	"Tilted Towers": {
		"path": "res://MainScenes/Maps/Map4.tscn",
		"image": "res://Sprites/crosshair.png"
	},
	"The Garden": {
		"path": "res://MainScenes/Maps/Map1.tscn",
		"image": "res://Sprites/plus-green.png"
	},
	"Final Destination": {
		"path": "res://MainScenes/Maps/Map2.tscn",
		"image": "res://Sprites/crosshair.png"
	},
	"Hell in a Cell": {
		"path": "res://MainScenes/Maps/Map3.tscn",
		"image": "res://Sprites/crosshair.png"
	}
}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
