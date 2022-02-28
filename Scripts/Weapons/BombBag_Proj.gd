extends RigidBody2D

#var explosion_radius = 100
#var detection_margin = 30
#var explosion_poly

#var explosion_force = 700
#var explosion_damage = 25
#var explosion_delay = 3.0

var bomb_res = preload("res://SubScenes/Weapons/BouncyBomb_Proj.tscn")

# number of bombs inside
var num_bombs = 6

# Base delay until explode
var bomb_fuse_dur := 2.0
# Additionally, a random amount of this delay is added
var bomb_fuse_rand := 1.0

var bomb_mass := 1.0
var bomb_gravity := 6.0

# If we don't do something by this time, just die
var kill_time = 5.0

# Prevent double release
var release_done := false

var owning_player = "UNDEFINED"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$Timer.start(kill_time)
	
#	# This code taken directly from the destructible terrain demo
#	var nb_points = 32
#	var points = PoolVector2Array()
#	for i in range(nb_points+1):
#		var point = deg2rad(i * 360.0 / nb_points - 90)
#		points.push_back(Vector2.ZERO + Vector2(cos(point), sin(point)) * explosion_radius)
#	$ExplosionArea/ExplosionPoly.polygon = points
#
#	# Detection body, larger to handle high speeds
#	points = PoolVector2Array()
#	for i in range(nb_points+1):
#		var point = deg2rad(i * 360.0 / nb_points - 90)
#		points.push_back(Vector2.ZERO + Vector2(cos(point), sin(point)) * (explosion_radius + detection_margin))
#	$DetectionArea/DetectionPolygon.polygon = points
	
	# apply random spin for style points. 
	# The delay is because of an engine bug that ignores
	# torque_impulses when an object is first created
	yield(get_tree().create_timer(0.05), "timeout")
	apply_torque_impulse(rand_range(-1000, 1000))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func release_bombs():
	if release_done: return
	release_done = true
	for _i in range(num_bombs):
		var b = bomb_res.instance()
		b.mass = bomb_mass
		b.gravity_scale = bomb_gravity
		b.transform = self.transform
		b.rotation_degrees = rand_range(0,360)
		b.owning_player = owning_player
		b.explosion_delay = bomb_fuse_dur + randf() * bomb_fuse_rand
		b.apply_central_impulse(Vector2(rand_range(-1,1), rand_range(-1,1)) * 100)
		b.apply_central_impulse(self.linear_velocity * 0.6)
		MatchInfo.projectile_holder.call_deferred("add_child", b)
	
	# delete self
	call_deferred("queue_free")

#func explode() -> void:
##	for x in affected:
##		x.apply_central_impulse((x.global_position - global_position).normalized() * explosion_force)
##	var inst = particles.instance()
##	inst.global_position = global_position
##	get_parent().call_deferred("add_child", inst)
#
#	# TODO: Add a list of bodies that were created this frame,
#	# and check all of those too
#
#	for body in $DetectionArea.get_overlapping_bodies():
#		if body.is_in_group("Destructible"):
#			body.get_parent().clip(body, $ExplosionArea/ExplosionPoly)
#		elif body in $ExplosionArea.get_overlapping_bodies():
#			if body.is_in_group("Knockback"):
#				body.apply_central_impulse( \
#					(body.global_position - global_position).normalized() * explosion_force)
#			if body.is_in_group("Damageable"):
#				body.get_parent().do_damage(explosion_damage, owning_player)
#
#	call_deferred("queue_free")

func _on_Timer_timeout():
	release_bombs()

func _on_BombBag_Proj_body_entered(body):
	if body.is_in_group("Destructible") or body.is_in_group("Damageable"):
		release_bombs()
