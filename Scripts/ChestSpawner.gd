extends Node2D

var chest_res = preload("res://SubScenes/Chest.tscn")
var last_chest = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_random_point():
	# pick a random line object
	var line = Utilities.rand_choice(get_children())
	var points = line.points
	var idx = randi() % (len(points)-1)
	var p1 = points[idx] 
	var p2 = points[idx + 1] 
	return p1 + (p2-p1)*randf()

func spawn_chest():
	var new_chest = chest_res.instance()
	new_chest.position = get_random_point()
	MatchInfo.chest_holder.add_child(new_chest)
	last_chest = new_chest

func get_cam_point():
	if is_instance_valid(last_chest):
		return last_chest.global_position
	else: return null

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
