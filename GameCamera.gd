extends Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# set the limits for the camera
	var limit_obj = $"../CameraLimit"
	assert(limit_obj != null, "No camera limits found!")
	limit_left = 0
	limit_top = 0
	limit_bottom = limit_obj.transform.y
	limit_right = limit_obj.transform.x


func _process(delta):
	align()
