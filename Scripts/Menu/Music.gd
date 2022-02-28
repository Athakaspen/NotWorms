extends Node



# Called when the node enters the scene tree for the first time.
func _ready():
	start_music("Ouroboros")

func start_music(track:String):
	get_node(track).playing = true

func start_random_music():
	Utilities.rand_choice(get_children()).playing = true

func stop_music():
	for node in get_children():
		node.playing = false

func set_speed(value : float):
	for node in get_children():
		node.pitch_scale = value

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
