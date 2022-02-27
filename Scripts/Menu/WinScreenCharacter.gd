extends VBoxContainer

class_name WinScreenCharacter

onready var portrait = $Portrait

var player_model = null
var model_scale : float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	update_portrait()

func set_data(tag:String, team:String, model:Node2D, is_winner:bool):
	$Label.text = tag
	if MatchInfo.TEAM_MODE != "off":
		match team:
			"red":
				$Label.modulate = Color.red
				$Winner.modulate = Color.red
			"blue":
				$Label.modulate = Color.blue
				$Winner.modulate = Color.blue
			"green":
				$Label.modulate = Color.green
				$Winner.modulate = Color.green
	player_model = model
	add_child(player_model)
	if is_winner:
		$Winner.text = "Winner!"
		model_scale = 11.0
	else:
		$Winner.text = " "
		model_scale = 7.0
	update_portrait()

func set_stats(stat1:String, stat2:String):
	$Stat1.text = stat1
	$Stat2.text = stat2

#func _process(_delta):
#	update_portrait()

func update_portrait():
	if player_model != null:
		player_model.global_position = \
			portrait.rect_global_position + (portrait.rect_size / 2.0) \
			+ Vector2(-6, 11) * model_scale / 2.0
		player_model.scale = Vector2(1,1) * model_scale
