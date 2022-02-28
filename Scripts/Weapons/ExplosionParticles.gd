extends Particles2D

# This is taken 100% directly from the destructible terrain demo as well
# Minor changes were made to the actual particle settings

func _ready() -> void:
	emitting = true
	$DirtParticles.emitting = true
	$Timer.start($DirtParticles.lifetime*$DirtParticles.speed_scale)

func _on_Timer_timeout() -> void:
	call_deferred("queue_free")

func set_radius(value : float) -> void:
	# multiply by a value BECAUSE IT LOOKS GOOD
	self.process_material.scale = value * 1.5
	$DirtParticles.process_material.emission_sphere_radius = value * 0.6

func set_dirt_visible(value : bool):
	$DirtParticles.visible = value
