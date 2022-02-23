extends RigidBody2D

class_name PlayerBody

export var move_force := 1100.0
export var MAX_SPEED = 400
export var H_damping := 3.0


export var jump_force := 350.0
export var air_jump_scalar := 0.69
export var jump_delay := 0.2
var can_jump = true
var is_jump_buffered = false

onready var parent = $".."
onready var jump_timer = $JumpTimer

var is_active := false

var weapon_path_list = [
	"res://SubScenes/Weapons/BouncyBomb.tscn",
	"res://SubScenes/Weapons/RocketLauncher.tscn"
]
var weapons = {}
var cur_weapon

# Called when the node enters the scene tree for the first time.
func _ready():
	jump_timer.wait_time = jump_delay
	
	# Instance all weapons and add them to the dictionary for storage
	for w_path in weapon_path_list:
		var w = load(w_path).instance()
		weapons[w.id_string] = w
		w.owning_player = parent.name
	
	# default weapon
	switch_weapon("bomb")
	
	set_turn_active(false)

func switch_weapon(weapon_name):
	if cur_weapon != null:
		cur_weapon.set_inactive()
		$RotPoint.remove_child(cur_weapon)
	cur_weapon = weapons[weapon_name]
	$RotPoint.add_child(cur_weapon)
	cur_weapon.set_active()

func init_preturn():
	pass
#	$RotPoint.visible = true

func set_turn_active(value:bool) -> void:
	# Set to inactive
	if value == false:
		is_active = false
		$RotPoint.visible = false
		cur_weapon.set_inactive()
	
	# Set to active
	elif value == true:
		is_active = true
		$RotPoint.visible = true
		cur_weapon.set_active()

func _process(_delta: float) -> void:
	
	# Bail if it's not ur turn
	if not is_active: return
	
	$RotPoint.look_at(parent.aim_point.global_position)
	cur_weapon.update_trajectory(position.distance_to(parent.aim_point.position))
	
#	if Input.is_action_just_pressed("shoot"):
#		var b = bomb.instance()
#		b.transform = $RotPoint/ShootPoint.global_transform
#		get_parent().add_child(b)
#		b.apply_central_impulse(b.transform.x * bomb_velocity * b.mass)

func _input(event: InputEvent) -> void:
	
	# Bail if it's not ur turn
	if not is_active: return
	
	if event.is_action_pressed("shoot"):
		print("Shoot button pressed")
		cur_weapon.do_shoot(position.distance_to(parent.aim_point.position))
		if MatchInfo.oneshot:
			parent.end_turn()

func _physics_process(delta: float) -> void:
	
	# No input-based movement if it's not ur turn
	if not is_active:
		# Horizontal-only damping (so gravity feels heavier
		apply_central_impulse(Vector2(-linear_velocity.x * H_damping * delta * mass, 0))
		return
	
	# Standard Movement
#	if Input.is_action_pressed("left") and linear_velocity.x > -MAX_SPEED:
#		#apply_central_impulse(-global_transform.x * move_force * delta)
#		apply_central_impulse(Vector2.LEFT * move_force * delta * mass)
#	elif Input.is_action_pressed("right") and linear_velocity.x < MAX_SPEED:
#		#apply_central_impulse(global_transform.x * move_force * delta)
#		apply_central_impulse(Vector2.RIGHT * move_force * delta * mass)
	var move_strength = Input.get_action_strength("right") - Input.get_action_strength("left")
	if abs(move_strength) > 0:
		apply_central_impulse(Vector2.RIGHT * move_strength * move_force * delta * mass)
	else:
		# Horizontal-only damping (so gravity feels heavier
		apply_central_impulse(Vector2(-linear_velocity.x * H_damping * delta * mass, 0))
	
	
	# Buffer a jump input
	if Input.is_action_just_pressed("jump") and not can_jump:
		is_jump_buffered = true
	# Jumping
	if (Input.is_action_pressed("jump") or is_jump_buffered) and can_jump:
		# clear buffered input
		is_jump_buffered = false
		# disallow jumps until this tiemr finishes
		can_jump = false
		jump_timer.start()
		# Check if we're touching ground
		# (this doesn't care if it's ground, wall, or ceiling)
		var grounded = false
		for body in get_colliding_bodies():
			if body.is_in_group("Ground"): grounded = true
		
		if grounded:
			# Full jump
			apply_central_impulse(Vector2.UP * jump_force * mass)
		else:
			# Air jump
			apply_central_impulse(Vector2.UP * jump_force * air_jump_scalar * mass)
			#apply_central_impulse(Vector2.DOWN * -linear_velocity.y * mass)
			
			# extra force to counterract falling momentum and nerf double jumps
			#print(linear_velocity.y)
			if linear_velocity.y > 0:
				var jump_bonus = linear_velocity.y * 0.8
				apply_central_impulse(Vector2.UP * jump_bonus * mass)

func _on_JumpTimer_timeout():
	can_jump = true
