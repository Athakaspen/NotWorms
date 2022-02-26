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
	
#	update_camera(turn_queue.get_camera_point())
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
#	update_camera(turn_queue.get_camera_point())
#	update_UI()


func get_spawnpoints():
	var num_players = MatchInfo.num_players
	if MatchInfo.TEAM_MODE == "off":
		var base = $SpawnPoints/NoTeams.get_node("PlayerCount"+str(num_players))
		var setup = Utilities.rand_choice(base.get_children())
		var res = []
		for point in setup.get_children():
			res.append(point.position)
		return res
	elif MatchInfo.TEAM_MODE == "two":
		# Returns an array with two arrays.
		var team1 = $SpawnPoints/TeamCount2/Team1
		var t1 = []
		for point in team1.get_children():
			t1.append(point.position)
		var team2 = $SpawnPoints/TeamCount2/Team2
		var t2 = []
		for point in team2.get_children():
			t2.append(point.position)
		return [t1, t2]
	elif MatchInfo.TEAM_MODE == "three":
		# Returns an array with three arrays.
		var team1 = $SpawnPoints/TeamCount3/Team1
		var t1 = []
		for point in team1.get_children():
			t1.append(point.position)
		var team2 = $SpawnPoints/TeamCount3/Team2
		var t2 = []
		for point in team2.get_children():
			t2.append(point.position)
		var team3 = $SpawnPoints/TeamCount3/Team3
		var t3 = []
		for point in team3.get_children():
			t3.append(point.position)
		return [t1, t2, t3]
#		print("Teams have not been implemented yet")
#		return null


func update_UI():
	UI.set_timer_progress(turn_queue.get_timer_progress())
	UI.set_current_player_name(turn_queue.get_current_player().get_gamertag())

func update_camera(point : Vector2):
	camera.global_position = point

# Kill players in death plane
func _on_DeathPlane_body_entered(body):
	if body.is_in_group("Player"):
		body.parent.do_damage(10000)
	if body.is_in_group("Projectile") or body.is_in_group("Chest"):
		body.queue_free()
