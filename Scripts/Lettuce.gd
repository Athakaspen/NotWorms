extends RigidBody2D

var popup_res = preload("res://SubScenes/DamagePopup.tscn")

var heal_amount = 30

var grav

# Called when the node enters the scene tree for the first time.
func _ready():
	grav = gravity_scale
	gravity_scale = 0.0

func _on_Lettuce_body_entered(body):
	if body.is_in_group("Player"):
		body.parent.heal(heal_amount)
		
		self.queue_free()

func _on_Timer_timeout():
	gravity_scale = grav
