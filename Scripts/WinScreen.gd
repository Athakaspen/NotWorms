extends Node2D

var menu_path = "res://MainScenes/MainMenu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_custom_mouse_cursor(null)
	
	$PlayerHolder/_placeholder.visible = false
	$UI/Title.text = MatchInfo.winner_tag + " Wins!"
	if MatchInfo.winner != "UNDEFINED":
		var winner_node = MatchInfo.player_info[MatchInfo.winner]
		var winner_sprite = winner_node.player_body.sprite
	
		winner_sprite.get_parent().remove_child(winner_sprite)
		winner_sprite.position = Vector2.ZERO
		
		$PlayerHolder.add_child(winner_sprite)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _unhandled_input(event):
	if event.is_action_pressed("ready"):
		_on_MainMenuButton_pressed()

func _on_MainMenuButton_pressed():
	get_tree().change_scene(menu_path)
