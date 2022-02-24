extends RigidBody2D


var contents = {}

var grav

# Called when the node enters the scene tree for the first time.
func _ready():
	contents = MatchInfo.get_chest_contents()
	grav = gravity_scale
	gravity_scale = 0.0

func _on_Chest_body_entered(body):
	if body.is_in_group("Player"):
		body.parent.give(contents)
		self.queue_free()

func _on_Timer_timeout():
	gravity_scale = grav
