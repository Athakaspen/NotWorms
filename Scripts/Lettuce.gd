extends RigidBody2D

var popup_res = preload("res://SubScenes/DamagePopup.tscn")

var heal_amount = 30

var munch_SFX_res = preload("res://SFX/munch2.mp3")

var collide_SFX_res = [
	preload("res://SFX/footstep_grass_000.ogg"),
	preload("res://SFX/footstep_grass_001.ogg"),
	preload("res://SFX/footstep_grass_002.ogg"),
	preload("res://SFX/footstep_grass_003.ogg")
]
var sfx_threshold = 10.0
var sfx_cooldown = 0.0

var grav

# Called when the node enters the scene tree for the first time.
func _ready():
	grav = gravity_scale
	gravity_scale = 0.0

func _process(delta):
	sfx_cooldown -= delta

func _on_Lettuce_body_entered(body):
	if body.is_in_group("Ground") \
	and abs(linear_velocity.length()) > sfx_threshold \
	and sfx_cooldown <= 0:
		MatchInfo.do_sound_effect(Utilities.rand_choice(collide_SFX_res), global_position, 1.0)
		sfx_cooldown = 0.5
	elif body.is_in_group("Player"):
		body.parent.heal(heal_amount)
		
		# SFX
		MatchInfo.do_sound_effect(munch_SFX_res, global_position, 4.0)
		
		self.queue_free()

func _on_Timer_timeout():
	gravity_scale = grav
