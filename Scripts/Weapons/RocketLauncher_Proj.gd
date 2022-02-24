extends RigidBody2D

var explosion_radius = 50
var detection_margin = 40
var explosion_poly

var explosion_force = 400
var explosion_damage = 20
var owning_player = "UNDEFINED"

# If we hit nothing in this long, explode
var explosion_delay = 6.0

# Used to prevent exploding before physics engine has kicked in
var live := false
# used to make sure we don't try to explode more than once
var exploded := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# Backup kill fuse
	$Timer.start(explosion_delay)
	
	# This code taken directly from the destructible terrain demo
	var nb_points = 24
	var points = PoolVector2Array()
	for i in range(nb_points+1):
		var point = deg2rad(i * 360.0 / nb_points - 90)
		points.push_back(Vector2.ZERO + Vector2(cos(point), sin(point)) * explosion_radius)
	$ExplosionPoly.polygon = points
	
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

func explode() -> void:
	if exploded or not live: return
	exploded = true
#	for x in affected:
#		x.apply_central_impulse((x.global_position - global_position).normalized() * explosion_force)
#	var inst = particles.instance()
#	inst.global_position = global_position
#	get_parent().call_deferred("add_child", inst)
	
	# TODO: Add a list of bodies that were created this frame,
	# and check all of those too
	
	for body in $DetectionArea.get_overlapping_bodies():
		print (body)
		if body.is_in_group("Destructible"):
			body.get_parent().clip(body, $ExplosionPoly)
		
		else:
			if body.is_in_group("Knockback"):
				if body.get_parent().name != owning_player:
					body.apply_central_impulse( \
						(body.global_position - global_position).normalized() * explosion_force)
				# Rocket jumping
				else:
					body.apply_central_impulse( \
						(body.global_position - global_position).normalized() * explosion_force * 5)
			if body.is_in_group("Damageable"):
				body.get_parent().do_damage(explosion_damage)
	
	call_deferred("queue_free")

func _on_Timer_timeout():
	explode()

func _on_RocketLauncher_Proj_body_entered(body):
	if body.is_in_group("Destructible") or body.is_in_group("Damageable"):
		explode()
