extends Node

var cur_speed = 1.0
var goal_speed = 1.0


# Called when the node enters the scene tree for the first time.
func _ready():
	start_music("Ouroboros")

func _process(delta):
	cur_speed = lerp(cur_speed, goal_speed, 0.08)
	for node in get_children():
		node.pitch_scale = cur_speed

func start_music(track:String):
	get_node(track).playing = true

func start_random_music():
	Utilities.rand_choice(get_children()).playing = true

func stop_music():
	for node in get_children():
		node.playing = false

func set_speed(value : float):
	goal_speed = value

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
