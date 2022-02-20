extends Node2D

onready var camera = $GameCamera
#onready var camera_target = $CameraTrackPoint


# Called when the node enters the scene tree for the first time.
func _ready():
	# set the limits for the camera
	var camera_limit = $CameraLimit
	assert(camera_limit != null, "No camera limits found!")
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_bottom = camera_limit.position.y
	camera.limit_right = camera_limit.position.x
	
	update_camera($Player)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_camera($Player)
	# set the camera tracking point's position
	

func update_camera(player):
	
	# Camera follows player
	#camera_target.global_position = player.global_position
	
	# Camera sits between player and aim point
	camera.global_position = \
		(2*player.global_position + get_global_mouse_position()) / 3
