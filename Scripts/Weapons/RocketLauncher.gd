extends Node2D

var id_string = "rocket"
#var pretty_name = "Rocket Launcher"
#var description = "Long Range! Explodes on Impact!"
var owning_player = "UNDEFINED"

var MAX_SHOOT_VEL := 1100.0
var MIN_SHOOT_VEL := 300.0
var projectile_mass := 1.0
var projectile_gravity := 6.0

# Length of the Trajectory Line in seconds
var traj_length := 0.8

var projectile_res = preload("res://SubScenes/Weapons/RocketLauncher_Proj.tscn")
#var SFX_res = preload("res://SFX/RocketLaunch.mp3")
var SFX_res = preload("res://SFX/rocket-takeoff.mp3")

onready var shoot_point = $ShootPoint
onready var traj_line = $TrajectoryLine

# Whether this weapon is the current weapon of the player
var is_active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Make the check area have the projectile's collision shape
	$ShootPoint/CheckArea.add_child(projectile_res.instance().get_node("CollisionShape2D").duplicate())

# dist is the distance away the player is aiming
func do_shoot(dist : float) -> bool:
	var p = projectile_res.instance()
	p.mass = projectile_mass
	p.gravity_scale = projectile_gravity
	p.transform = shoot_point.global_transform
	MatchInfo.projectile_holder.add_child(p)
	var shoot_velocity = get_shoot_velocity(dist)
	p.apply_central_impulse(p.transform.x * shoot_velocity)
#	p.apply_central_impulse(p.transform.x * shoot_velocity * p.mass)
	p.owning_player = owning_player
	
	for body in $ShootPoint/CheckArea.get_overlapping_bodies():
		if body.is_in_group("Ground") or body.is_in_group("Player"):
			p.explode()
			break
	
	# SFX
	MatchInfo.do_sound_effect(SFX_res, global_position, 4.0)
	
	# Push owner backwards
	$"../..".apply_central_impulse(-p.transform.x * shoot_velocity * 0.5)
	
	return true

func get_shoot_velocity(_dist):
	return $"../..".get_aim_strength() \
		* (MAX_SHOOT_VEL - MIN_SHOOT_VEL) + MIN_SHOOT_VEL

func set_active():
	traj_line.visible = true
	is_active = true

func set_inactive():
	is_active = false

func hide_trajectory():
	traj_line.visible = false

func _process(_delta):
	# reset the line object transform so it drawin in the right place
	traj_line.global_transform = Transform.IDENTITY

var line_detail = 0.02

# This was basically taken from the destructable terrain video too
# dist is the distance of the aim spot from the player
func update_trajectory(dist):
	traj_line.clear_points()
	var pos = shoot_point.global_position
	var vel = shoot_point.global_transform.x * get_shoot_velocity(dist)
#	var vel = shoot_point.global_transform.x * shoot_velocity
	for _i in range(traj_length/line_detail):
		traj_line.add_point(pos)
		# the number is a scalar that makes it line up, found from trial and error
		vel.y += projectile_gravity * line_detail * 106
		pos += vel * line_detail
		
#		# stop the line when it hits terrain
#		var did_collide = false
#		for terrain_body in MatchInfo.terrain_holder.get_children():
#			var terr_poly = terrain_body.get_node("RenderPoly")
#			if Geometry.is_point_in_polygon(terr_poly.to_local(pos), terr_poly.polygon):
#				did_collide = true
#				break
#		if did_collide:
#			break
