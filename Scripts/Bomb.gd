extends RigidBody2D

var spinspeed = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func explode() -> void:
#	for x in affected:
#		x.apply_central_impulse((x.global_position - global_position).normalized() * explosion_force)
#	var inst = particles.instance()
#	inst.global_position = global_position
#	get_parent().call_deferred("add_child", inst)
	
	for body in $ExplosionArea.get_overlapping_bodies():
		#print (body)
		if body.is_in_group("Destructible"):
			body.get_parent().clip(body, $ExplosionArea/DestructionPolygon)
	
	
	call_deferred("queue_free")

func _on_Timer_timeout():
	explode()
