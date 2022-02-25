extends Node2D

var start_path = "res://MainScenes/PlayerMenu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	$MenuHolder/StartButton.grab_focus()
#	Input.set_custom_mouse_cursor(null)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#func _unhandled_input(event):
#	if event.is_action_pressed("ready"):
#		_on_StartButton_pressed()


func _on_StartButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene(start_path)
