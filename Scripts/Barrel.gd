extends RigidBody2D

var owning_player = "UNDEFINED"

var explosion_particles_res = preload("res://SubScenes/Weapons/ExplosionParticles.tscn")

# This var used for particles only
var explosion_radius = 220
var explosion_damage = 25
var explosion_force = 3500

var fakebullet_res = preload("res://SubScenes/FakeBullet.tscn")

var explosion_delay = 1.0 # sec

var grav

var has_exploded = false

# Called when the node enters the scene tree for the first time.
func _ready():
	grav = gravity_scale
	gravity_scale = 0.0

func do_damage(_value:int, source_player:String = "UNDEFINED"):
	if not has_exploded:
		has_exploded = true
		self.owning_player = source_player
		modulate = Color.red
		$DelayTimer.wait_time = explosion_delay
		$DelayTimer.start()
		
		# Keep turn in projectile mode
		var fb = fakebullet_res.instance()
		fb.wait_time = explosion_delay
		fb.position = position
		MatchInfo.projectile_holder.add_child(fb)
		
		yield($DelayTimer, "timeout")
		_explode()

func _explode() -> void:
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
	
	
	
	call_deferred("queue_free")

#func _on_Chest_body_entered(body):
#	if body.is_in_group("Player"):
#		body.parent.give(contents)
#
#		# pre-delete
#		self.sleeping = true
#		self.visible = false
#		$CollisionPolygon2D.call_deferred("set_disabled", true)
#
#		# Popups
#		for item in self.contents:
#			var popup = popup_res.instance()
#			get_parent().add_child(popup)
#			popup.set_text("+" + str(contents[item]) + " " + GameData.WeaponData[item]["pretty_name"])
#			popup.set_color(Color.green)
#			popup.set_lifespan(2.0)
#			popup.position = self.position
#			yield(get_tree().create_timer(0.5), "timeout")
#
#		self.queue_free()

func _on_Timer_timeout():
	gravity_scale = grav
