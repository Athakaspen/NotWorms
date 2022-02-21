extends Node2D

var menu_path = "res://MainScenes/Menu.tscn"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$PlayerHolder/_placeholder.visible = false
	$UI/Title.text = MatchInfo.winner + " Wins!"
	var winner_node = MatchInfo.player_info[MatchInfo.winner]
	var winner_sprite = winner_node.player_body.get_node("SpritePoly")
	print(winner_node.name)
	print(winner_sprite)
	
	winner_sprite.get_parent().remove_child(winner_sprite)
	winner_sprite.position = Vector2.ZERO
	
	$PlayerHolder.add_child(winner_sprite)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_MainMenuButton_pressed():
	get_tree().change_scene(menu_path)
