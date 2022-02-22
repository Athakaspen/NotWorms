extends Node2D

var level_path = "res://MainScenes/Level.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_custom_mouse_cursor(null)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _unhandled_input(event):
	if event.is_action_pressed("ready"):
		_on_StartButton_pressed()


func _on_StartButton_pressed():
	get_tree().change_scene(level_path)
