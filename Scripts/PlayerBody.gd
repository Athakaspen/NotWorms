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
	"res://SubScenes/Weapons/RocketLauncher.tscn",
	"res://SubScenes/Weapons/RomanCandle.tscn"
]
var weapons = {}
var cur_weapon
var default_weapon = "bomb"

# Called when the node enters the scene tree for the first time.
func _ready():
	jump_timer.wait_time = jump_delay
	
	# Instance all weapons and add them to the dictionary for storage
	for w_path in weapon_path_list:
		var w = load(w_path).instance()
		weapons[w.id_string] = w
		w.owning_player = parent.name
	
	# default weapon
	switch_weapon(default_weapon)
	
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
		cur_weapon.hide_trajectory()
	
	# Set to active
	elif value == true:
		is_active = true
		$RotPoint.visible = true
		cur_weapon.set_active()

func finish_turn():
	$RotPoint.visible = false
	cur_weapon.set_inactive()

func set_inventory_active(open : bool) -> void:
	if open:
		is_active = false
	else:
		is_active = true

func _process(_delta: float) -> void:
	
	cur_weapon.update_trajectory(position.distance_to(parent.aim_point.position))
	
	# Bail if it's not ur turn
	if not is_active: return
	
	$RotPoint.look_at(parent.aim_point.global_position)
	


func _input(event: InputEvent) -> void:
	
	# Bail if it's not ur turn
	if not is_active: return
	
	if event.is_action_pressed("shoot"):
		var did_shoot = cur_weapon.do_shoot(position.distance_to(parent.aim_point.position))
		if MatchInfo.oneshot and did_shoot:
			parent.end_turn()

func _physics_process(delta: float) -> void:
	
	# No input-based movement if it's not ur turn
	if not is_active:
		
		# This delta checks if Engine.time_scale is 0, which happens when we're paused and breaks things
		if delta != 0:
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
