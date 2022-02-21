extends Node2D
 
onready var camera = $GameCamera
onready var turn_queue = $TurnQueue
onready var UI = $CanvasLayer/UIHolder

# Called when the node enters the scene tree for the first time.
func _ready():
	# set the limits for the camera
	var camera_limit = $CameraLimit
	assert(camera_limit != null, "No camera limits found!")
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_bottom = camera_limit.position.y
	camera.limit_right = camera_limit.position.x
	
	turn_queue.initialize()
	
	update_camera(turn_queue.get_current_player().get_body())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update_camera(turn_queue.get_current_player().get_body(), 
		turn_queue.get_camera_mode())
	update_UI()
	

func update_UI():
	UI.set_timer_progress(turn_queue.get_timer_progress())
	UI.set_current_player_name(turn_queue.get_current_player().name)

func update_camera(player, includeMouse := true):
	if not includeMouse:
		# Camera follows player
		camera.global_position = player.global_position
	else:
		# Camera sits between player and aim point
		camera.global_position = \
			(2*player.global_position + get_global_mouse_position()) / 3
