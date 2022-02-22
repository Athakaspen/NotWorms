extends RigidBody2D


var explosion_radius = 100
var explosion_force = 500
var explosion_damage = 25
var explosion_delay = 3.0
var owning_player = "UNDEFINED"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$Timer.start(explosion_delay)
	
	# This code taken directly from the destructible terrain demo
	var nb_points = 32
	var points = PoolVector2Array()
	for i in range(nb_points+1):
		var point = deg2rad(i * 360.0 / nb_points - 90)
		points.push_back(Vector2.ZERO + Vector2(cos(point), sin(point)) * explosion_radius)
	$ExplosionArea/DestructionPolygon.polygon = points
	
	# apply random spin for style points. 
	# The delay is because of an engine bug that ignores
	# torque_impulses when an object is first created
	yield(get_tree().create_timer(0.05), "timeout")
	apply_torque_impulse(rand_range(-1000, 1000))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func explode() -> void:
#	for x in affected:
#		x.apply_central_impulse((x.global_position - global_position).normalized() * explosion_force)
#	var inst = particles.instance()
#	inst.global_position = global_position
#	get_parent().call_deferred("add_child", inst)
	
	# TODO: Add a list of bodies that were created this frame,
	# and check all of those too
	
	for body in $ExplosionArea.get_overlapping_bodies():
		#print (body)
		if body.is_in_group("Destructible"):
			body.get_parent().clip(body, $ExplosionArea/DestructionPolygon)
		
		else:
			if body.is_in_group("Knockback"):
				body.apply_central_impulse( \
					(body.global_position - global_position).normalized() * explosion_force)
			if body.is_in_group("Damageable"):
				body.get_parent().do_damage(explosion_damage)
	
	call_deferred("queue_free")

func _on_Timer_timeout():
	
	# Only enable collision monitoring just before explosion
	$ExplosionArea.monitoring = true
	$ExplosionArea.monitorable = true
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	
	explode()
