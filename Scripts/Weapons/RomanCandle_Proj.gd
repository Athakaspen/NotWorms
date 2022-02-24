extends RigidBody2D

var explosion_radius = 24
var detection_margin = 30
var explosion_poly

var explosion_force = 160
var explosion_damage = 0 # This will be set by the gun
var owning_player = "UNDEFINED"

# If we hit nothing in this long, explode
var explosion_delay = 0.6

# Used to prevent exploding before physics engine has kicked in
var live := false
# used to make sure we don't try to explode more than once
var exploded := false
# If we should have exploded, but weren't live yet, set this to true.
# Then check it to explode later
var should_be_exploded := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Backup kill fuse
	$Timer.start(explosion_delay)
	
	# This code taken directly from the destructible terrain demo
	# Actual explotion poly
	var nb_points = 16
	var points = PoolVector2Array()
	for i in range(nb_points+1):
		var point = deg2rad(i * 360.0 / nb_points - 90)
		points.push_back(Vector2.ZERO + Vector2(cos(point), sin(point)) * explosion_radius)
	$ExplosionArea/ExplosionPoly.polygon = points
	
	# Detection body, larger to handle high speeds
	points = PoolVector2Array()
	for i in range(nb_points+1):
		var point = deg2rad(i * 360.0 / nb_points - 90)
		points.push_back(Vector2.ZERO + Vector2(cos(point), sin(point)) * (explosion_radius + detection_margin))
	$DetectionArea/DetectionPolygon.polygon = points
	
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	live = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	self.rotation = linear_velocity.angle()
	if should_be_exploded: explode()

func explode() -> void:
	if exploded: return
	if not live:
		should_be_exploded = true
#		print("bailed")
		return
	exploded = true
#	for x in affected:
#		x.apply_central_impulse((x.global_position - global_position).normalized() * explosion_force)
#	var inst = particles.instance()
#	inst.global_position = global_position
#	get_parent().call_deferred("add_child", inst)
	
	# TODO: Add a list of bodies that were created this frame,
	# and check all of those too
	
	for body in $DetectionArea.get_overlapping_bodies():
		if body.is_in_group("Destructible"):
			body.get_parent().clip(body, $ExplosionArea/ExplosionPoly)
		
		elif body in $ExplosionArea.get_overlapping_bodies():
			if body.is_in_group("Knockback"):
				if body.get_parent().name != owning_player:
					body.apply_central_impulse( \
						(body.global_position - global_position).normalized() * explosion_force)
				# Push owner back less
#				else:
#					body.apply_central_impulse( \
#						(body.global_position - global_position).normalized() * explosion_force * -.2)
			if body.is_in_group("Damageable"):
				# Do less damage to owner
				if body.get_parent().name != owning_player:
					body.get_parent().do_damage(explosion_damage)
				else:
					body.get_parent().do_damage(explosion_damage*0.4)
	
	call_deferred("queue_free")

func _on_Timer_timeout():
	explode()

func _on_RocketLauncher_Proj_body_entered(body):
	if body.is_in_group("Destructible") or body.is_in_group("Damageable"):
		explode()
