extends RigidBody2D

var popup_res = preload("res://SubScenes/DamagePopup.tscn")

var contents = {}

var grav

var open_SFX_res = preload("res://SFX/clothBelt.ogg")

var collide_SFX_res = [
	preload("res://SFX/footstep_grass_000.ogg"),
	preload("res://SFX/footstep_grass_001.ogg"),
	preload("res://SFX/footstep_grass_002.ogg"),
	preload("res://SFX/footstep_grass_003.ogg")
]
var sfx_threshold = 10.0
var sfx_cooldown = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	contents = MatchInfo.get_chest_contents()
	grav = gravity_scale
	gravity_scale = 0.0

func _process(delta):
	sfx_cooldown -= delta

func _on_Chest_body_entered(body):
	if body.is_in_group("Ground") \
	and abs(linear_velocity.length()) > sfx_threshold \
	and sfx_cooldown <= 0:
		MatchInfo.do_sound_effect(Utilities.rand_choice(collide_SFX_res), global_position, 1.0)
		sfx_cooldown = 0.5
	elif body.is_in_group("Player"):
		body.parent.give(contents)
		
		# SFX
		MatchInfo.do_sound_effect(open_SFX_res, global_position, 6.0)
		
		# pre-delete
		self.sleeping = true
		self.visible = false
		$CollisionPolygon2D.call_deferred("set_disabled", true)
		
		# Popups
		for item in self.contents:
			var popup = popup_res.instance()
			get_parent().add_child(popup)
			popup.set_text("+" + str(contents[item]) + " " + GameData.WeaponData[item]["pretty_name"])
			popup.set_color(Color.green)
			popup.set_lifespan(2.0)
			popup.position = self.position
			yield(get_tree().create_timer(0.5), "timeout")
		
		self.queue_free()

func _on_Timer_timeout():
	gravity_scale = grav
