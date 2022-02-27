extends RigidBody2D

var popup_res = preload("res://SubScenes/DamagePopup.tscn")

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
		
		# pre-delete
		self.sleeping = true
		self.visible = false
		$CollisionPolygon2D.call_deferred("set_disabled", true)
		
		# Popups
		for item in self.contents:
			var popup = popup_res.instance()
			get_parent().add_child(popup)
			popup.set_text("+" + str(contents[item]) + " " + GameData.WeaponData[item]["pretty_name"])
			popup.set_color(Color.black)
			popup.set_lifespan(2.0)
			popup.position = self.position
			yield(get_tree().create_timer(0.5), "timeout")
		
		self.queue_free()

func _on_Timer_timeout():
	gravity_scale = grav
