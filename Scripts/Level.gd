extends Node2D
 
onready var camera = $GameCamera
onready var turn_queue = $TurnQueue
onready var UI = $UICanvas/UIHolder
onready var projectile_holder = $ProjectileHolder

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
	
	update_camera(turn_queue.get_camera_point())
	
#	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#	Input.set_custom_mouse_cursor(preload("res://Sprites/crosshair.png"), 0, Vector2(32,32))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	update_camera(turn_queue.get_camera_point())
	update_UI()


func update_UI():
	UI.set_timer_progress(turn_queue.get_timer_progress())
	UI.set_current_player_name(turn_queue.get_current_player().name)

func update_camera(point : Vector2):
	camera.global_position = point


# Kill players in death plane
func _on_DeathPlane_body_entered(body):
	if body.is_in_group("Player"):
		body.parent.do_damage(10000)
