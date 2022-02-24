extends RigidBody2D

class_name PlayerBody

export var move_force := 1100.0
export var MAX_SPEED = 400
export var H_damping := 3.0


export var jump_force := 350.0
export var air_jump_scalar := 0.69
export var jump_delay := 0.2
# Whether the jump cooldown is inactive
var can_jump_cooldown = true
var is_jump_buffered = false

# Jump/fly stamina
export var MAX_STAMINA := 100.0
export var JUMP_COST := 15.0
export var STAMINA_REGEN := 32.0 # per second
var cur_stamina = MAX_STAMINA

onready var parent = $".."
onready var jump_timer = $JumpTimer

var PREV_STATE
var STATE
enum State {
	OFFTURN,
	PRETURN,
	TURN,
	POSTTURN,
	MENU
}

var weapons = {}
var cur_weapon
var default_weapon = "bomb"

# Called when the node enters the scene tree for the first time.
func _ready():
	jump_timer.wait_time = jump_delay
	
	# Instance all weapons and add them to the dictionary for storage
	for weapon in GameData.WeaponData:
		var res_path = GameData.WeaponData[weapon]["resource"]
		var w = load(res_path).instance()
		weapons[w.id_string] = w
		w.owning_player = parent.name
	
	# default weapon
	switch_weapon(default_weapon)
	
	set_state_offturn()

func switch_weapon(weapon_name):
	if cur_weapon != null:
		cur_weapon.set_inactive()
		$RotPoint.remove_child(cur_weapon)
	cur_weapon = weapons[weapon_name]
	$RotPoint.add_child(cur_weapon)
	cur_weapon.set_active()

func set_state_preturn():
	STATE = State.PRETURN
	cur_stamina = MAX_STAMINA
	if parent.inventory_contents[cur_weapon.id_string] == 0:
		switch_weapon(default_weapon)
	$RotPoint.visible = true

func set_state_turn() -> void:
	STATE = State.TURN
	$RotPoint.visible = true
	cur_weapon.set_active()

func set_state_postturn():
	STATE = State.POSTTURN
	cur_weapon.hide_trajectory()

func set_state_menu():
	STATE = State.MENU

func set_state_offturn():
	STATE = State.OFFTURN
	$RotPoint.visible = false
	cur_weapon.set_inactive()

func set_inventory_active(value : bool) -> void:
	if value == true and STATE != State.MENU:
		PREV_STATE = STATE
		STATE = State.MENU
	elif value == false and STATE == State.MENU:
		STATE = PREV_STATE

func _process(delta: float) -> void:
	# Bail if it's not ur turn
	if STATE == State.OFFTURN: return
	
	# Regen stamina
	cur_stamina = clamp(cur_stamina + STAMINA_REGEN*delta, 0, MAX_STAMINA)
	
	# Point weapon at target
	$RotPoint.look_at(parent.aim_point.global_position)
	# regenerate the trajectory line based on new aim
	cur_weapon.update_trajectory(position.distance_to(parent.aim_point.position))


func _input(event: InputEvent) -> void:
	# Bail if it's not ur turn
	if STATE != State.TURN: return
	
	if event.is_action_pressed("shoot"):
		var did_shoot = cur_weapon.do_shoot(position.distance_to(parent.aim_point.position))
		if MatchInfo.oneshot and did_shoot:
			parent.decrease_ammo(cur_weapon.id_string)
			parent.end_turn()

func _physics_process(delta: float) -> void:
	
	#attempting to prevent Engine.time_scale = 0 bugs
	if delta == 0: return
	
	# No input-based movement if it's not ur turn
	if STATE != State.TURN:
		
		# This delta checks if Engine.time_scale is 0, 
		# which happens when we're paused and breaks things
		if delta != 0:
			# Horizontal-only damping (so gravity feels heavier
			apply_central_impulse(Vector2(-linear_velocity.x * H_damping * delta * mass, 0))
		return
	
	# Standard Movement
	var move_strength = Input.get_action_strength("right") - Input.get_action_strength("left")
	if abs(move_strength) > 0:
		# Don't move if we're beyond max speed
		if linear_velocity.x > MAX_SPEED and move_strength > 0 \
		or linear_velocity.x < -MAX_SPEED and move_strength < 0:
			pass
		else:
			apply_central_impulse(Vector2.RIGHT * move_strength * move_force * delta * mass)
	else:
		# Horizontal-only damping (so gravity feels heavier
		apply_central_impulse(Vector2(-linear_velocity.x * H_damping * delta * mass, 0))
	
	# Buffer a jump input
	if Input.is_action_just_pressed("jump") and not can_jump():
		is_jump_buffered = true
	# Jumping
	if (Input.is_action_pressed("jump") or is_jump_buffered) and can_jump():
		# clear buffered input
		is_jump_buffered = false
		
		do_jump()

func _on_JumpTimer_timeout():
	can_jump_cooldown = true

func can_jump() -> bool:
	return can_jump_cooldown and cur_stamina >= JUMP_COST

func do_jump():
	# disallow jumps until this tiemr finishes
	can_jump_cooldown = false
	cur_stamina = clamp(cur_stamina - JUMP_COST, 0, MAX_STAMINA)
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
		
		# extra force to counterract falling momentum and nerf double jumps
		#print(linear_velocity.y)
		if linear_velocity.y > 0:
			var jump_bonus = linear_velocity.y * 0.8
			apply_central_impulse(Vector2.UP * jump_bonus * mass)

func get_stamina_percent() -> float:
	return clamp((cur_stamina - JUMP_COST) / (MAX_STAMINA-JUMP_COST), 0, 1)
