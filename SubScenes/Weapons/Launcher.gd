extends Node2D

var id_string = "launcher"
var pretty_name = "Launcher"
var description = "Does what is says on the tin. Launches."

var MAX_SHOOT_VEL := 1000.0
var MIN_SHOOT_VEL := 200.0
var STEP_SHOOT_VEL:= 50.0
var shoot_velocity := 600.0
var projectile_mass := 1.0
var projectile_gravity := 6.0

# Length of the Trajectory Line in points
var traj_length = 100

var projectile_res = preload("res://SubScenes/Weapons/Bomb.tscn")

onready var shoot_point = $ShootPoint
onready var traj_line = $TrajectoryLine

# Whether this weapon is the current weapon of the player
var is_active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# dist is the distance away the player is aiming
func do_shoot(dist : float):
	var p = projectile_res.instance()
	p.mass = projectile_mass
	p.gravity_scale = projectile_gravity
	p.transform = shoot_point.global_transform
	MatchInfo.projectile_holder.add_child(p)
	p.apply_central_impulse(p.transform.x * dist * p.mass)
#	p.apply_central_impulse(p.transform.x * shoot_velocity * p.mass)

func do_power_up():
	shoot_velocity = clamp(shoot_velocity + STEP_SHOOT_VEL, MIN_SHOOT_VEL, MAX_SHOOT_VEL)

func do_power_down():
	shoot_velocity = clamp(shoot_velocity - STEP_SHOOT_VEL, MIN_SHOOT_VEL, MAX_SHOOT_VEL)

func set_active():
	is_active = true

func set_inactive():
	is_active = false

func _process(delta):
	# reset the line object transform so it drawin in the right place
	traj_line.global_transform = Transform.IDENTITY

var line_detail = 0.02

# This was basically taken from the destructable terrain video too
# dist is the distance of the aim spot from the player
func update_trajectory(dist):
	traj_line.clear_points()
	var pos = shoot_point.global_position
	var vel = shoot_point.global_transform.x * dist
#	var vel = shoot_point.global_transform.x * shoot_velocity
	for i in range(traj_length):
		traj_line.add_point(pos)
		# the number is a scalar that makes it line up, found from trial and error
		vel.y += projectile_gravity * line_detail * 103.6
		pos += vel * line_detail
		
		# stop the line when it hits terrain
		var did_collide = false
		for terrain_body in MatchInfo.terrain_holder.get_children():
			var terr_poly = terrain_body.get_node("RenderPoly")
			if Geometry.is_point_in_polygon(terr_poly.to_local(pos), terr_poly.polygon):
				did_collide = true
				break
		if did_collide:
			break
