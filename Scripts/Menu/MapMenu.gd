extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var map_path = "res://MainScenes/Maps/Map1.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/MapSelect.grab_focus()


func _on_TurnLength_value_changed(new_value:String):
	# Get the numerical value from the text
	# Text is in the form "X sec"
	var int_value = int(new_value.split(" ")[0])
	MatchInfo.turn_duration = int_value


func _on_Health_value_changed(new_value:String):
	MatchInfo.starting_health = int(new_value)


func _on_ChestFreq_value_changed(new_value:String):
	MatchInfo.chest_freq = new_value.to_lower()


func _on_StartButton_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene(map_path)


func _on_MapSelect_map_changed(new_path):
	map_path = new_path


func _on_Music_value_changed(new_value):
	MatchInfo.music_track = new_value
	# Preview
	if new_value == "Random":
		pass
	else:
		Music.stop_music()
		Music.start_music(new_value)
