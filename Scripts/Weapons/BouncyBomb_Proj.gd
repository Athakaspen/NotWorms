extends RigidBody2D

var explosion_radius = 75
var detection_margin = 30
var explosion_poly

var explosion_particles_res = preload("res://SubScenes/Weapons/ExplosionParticles.tscn")
var explode_SFX_res = preload("res://SFX/MinecraftExplosion.mp3")
var fuse_SFX_res = preload("res://SFX/MinecraftFuse.mp3")

var explosion_force = 500
var explosion_damage = 6
var explosion_delay = 3.5
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
	$ExplosionArea/ExplosionPoly.polygon = points
	
	# Detection body, larger to handle high speeds
	points = PoolVector2Array()
	for i in range(nb_points+1):
		var point = deg2rad(i * 360.0 / nb_points - 90)
		points.push_back(Vector2.ZERO + Vector2(cos(point), sin(point)) * (explosion_radius + detection_margin))
	$DetectionArea/DetectionPolygon.polygon = points
	
	# apply random spin for style points. 
	# The delay is because of an engine bug that ignores
	# torque_impulses when an object is first created
	yield(get_tree().create_timer(0.05), "timeout")
	apply_torque_impulse(rand_range(-1000, 1000))
	
	# SFX
	yield(get_tree().create_timer(randf()/3.0), "timeout")
	MatchInfo.do_sound_effect(fuse_SFX_res, position, 2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func explode() -> void:

	#Vibrate controller
	Input.start_joy_vibration(0, 1.0, 1.0, 0.3)
	
	# TODO: Add a list of bodies that were created this frame,
	# and check all of those too
	
	var hit_terrain := false
	for body in $DetectionArea.get_overlapping_bodies():
		if body.is_in_group("Destructible"):
			body.get_parent().clip(body, $ExplosionArea/ExplosionPoly)
			hit_terrain = true
		
		elif body in $ExplosionArea.get_overlapping_bodies():
			if body.is_in_group("Knockback"):
				body.apply_central_impulse( \
					(body.global_position - global_position).normalized() * explosion_force)
			if body.is_in_group("Damageable"):
				if body.has_method("do_damage"):
					body.do_damage(explosion_damage, owning_player)
				else: body.get_parent().do_damage(explosion_damage, owning_player)
	
	# Explosion Particle effect
	var particles = explosion_particles_res.instance()
	particles.set_radius(explosion_radius)
	particles.position = position
	if not hit_terrain: particles.set_dirt_visible(false)
	MatchInfo.projectile_holder.call_deferred("add_child", particles)
	
	# SFX
	MatchInfo.do_sound_effect(explode_SFX_res, position, 2)
	
	call_deferred("queue_free")

func _on_Timer_timeout():
	explode()
