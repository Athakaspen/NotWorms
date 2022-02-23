extends Node2D

var id_string = "bomb"
var pretty_name = "Bouncy Bomb"
var description = "Throw it and see what happens. Blows up after 3 seconds."
var owning_player = "UNDEFINED"

var MAX_SHOOT_VEL := 600.0
var MIN_SHOOT_VEL := 100.0
var projectile_mass := 1.0
var projectile_gravity := 6.0

# Length of the Trajectory Line in seconds
var traj_length := 1.0

var projectile_res = preload("res://SubScenes/Weapons/BouncyBomb_Proj.tscn")

onready var shoot_point = $ShootPoint
onready var traj_line = $TrajectoryLine

# Whether this weapon is the current weapon of the player
var is_active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# dist is the distance away the player is aiming
# Return value represents whether the show was successful
func do_shoot(dist : float) -> bool:
	
	if check_can_shoot() == false: return false
	
	var p = projectile_res.instance()
	p.mass = projectile_mass
	p.gravity_scale = projectile_gravity
	p.transform = shoot_point.global_transform
	MatchInfo.projectile_holder.add_child(p)
	var shoot_velocity = get_shoot_velocity(dist)
	p.apply_central_impulse(p.transform.x * shoot_velocity)
#	p.apply_central_impulse(p.transform.x * shoot_velocity * p.mass)
	p.owning_player = owning_player
	return true

func get_shoot_velocity(dist):
	dist = clamp(dist-50, 0, 1000)
	return dist/1000 * (MAX_SHOOT_VEL - MIN_SHOOT_VEL) + MIN_SHOOT_VEL

func check_can_shoot()-> bool:
	for body in $ShootPoint/CheckArea.get_overlapping_bodies():
		if body is StaticBody2D:
			return false
	return true

#func do_power_up():
#	shoot_velocity = clamp(shoot_velocity + STEP_SHOOT_VEL, MIN_SHOOT_VEL, MAX_SHOOT_VEL)
#
#func do_power_down():
#	shoot_velocity = clamp(shoot_velocity - STEP_SHOOT_VEL, MIN_SHOOT_VEL, MAX_SHOOT_VEL)

func set_active():
	traj_line.visible = true
	is_active = true

func set_inactive():
	is_active = false

func hide_trajectory():
	traj_line.visible = false

func _process(delta):
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
		vel.y += projectile_gravity * line_detail * 110
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
