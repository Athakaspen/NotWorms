extends RigidBody2D


var contents = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	contents = MatchInfo.get_chest_contents()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass



func _on_Chest_body_entered(body):
	if body.is_in_group("Player"):
		body.parent.give(contents)
		self.queue_free()
