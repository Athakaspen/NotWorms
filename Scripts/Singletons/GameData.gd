extends Node

# Dictionary containing metadata about each weapon.
# Mostly used to create the inventory menu
var WeaponData = {
	"bomb":{
		"pretty_name": "Bouncy Bomb",
		"description": "Throw it and see what happens.\nBlows up after 3 seconds.",
		"damage": "XX",
		"icon": "res://icon.png"
	},
	"rocket":{
		"pretty_name": "Rocket Launcher",
		"description": "Long Range! Explodes on Impact!",
		"damage": "XX",
		"icon": "res://icon.png"
	},
	"candle":{
		"pretty_name": "Roman Candle",
		"description": "Barrage of rapid-fire,\nlow-damage projectiles.",
		"damage": "XX",
		"icon": "res://icon.png"
	}
}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
