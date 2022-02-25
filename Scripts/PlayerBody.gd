extends RigidBody2D

class_name PlayerBody

export var move_force := 1100.0
export var MAX_SPEED = 300
export var H_damping := 3.0

var controller_aim_speed = 1000
var max_aim_dist = 700

export var jump_force := 350.0
export var air_jump_scalar := 0.72
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
onready var aim_point = $AimPointHolder/AimPoint
onready var sprite = $Sprite
onready var collider = $Collider

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
	# Set jump timer value from variable this script
	jump_timer.wait_time = jump_delay
	
	# Load player model 
#	load_player_model(player_model)
	
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
	if not weapon_name in weapons.keys():
		print("Invalid weapon_name passed to switch_weapon() in Playerbody.gd")
		return
	if cur_weapon != null:
		cur_weapon.set_inactive()
		$RotPoint.remove_child(cur_weapon)
	cur_weapon = weapons[weapon_name]
	$RotPoint.add_child(cur_weapon)
	cur_weapon.set_active()

func set_state_preturn():
	STATE = State.PRETURN
	aim_point.visible = true
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
	aim_point.visible = false
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
	
	# Aim point location
	# Start by locking the holder's rotation
	$AimPointHolder.global_rotation = 0
	if STATE == State.TURN:
		# Controller Movement
		var aim_input = Vector2(
			Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left"),
			Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
		)
		if aim_input.length() > 0:
#			var cur_mouse_pos = get_viewport().get_mouse_position()
#			Input.warp_mouse_position(cur_mouse_pos + aim_input * controller_aim_speed * delta)
			aim_point.global_position += aim_input * controller_aim_speed * delta
	
		# Lock cursor within a radius of the player
		if aim_point.position.length() > max_aim_dist:
			aim_point.position = aim_point.position.normalized()*max_aim_dist
	
	# Point weapon at target
	$RotPoint.look_at(aim_point.global_position)
	# regenerate the trajectory line based on new aim
	cur_weapon.update_trajectory(position.distance_to(aim_point.position))


func _input(event: InputEvent) -> void:
	# Bail if it's not ur turn
	if STATE != State.TURN: return
	
	# Aiming with mouse
	if event is InputEventMouseMotion:
		aim_point.global_position += event.relative
	
	# Shooting input
	if event.is_action_pressed("shoot"):
		var did_shoot = cur_weapon.do_shoot(position.distance_to(aim_point.position))
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

var MIN_AIM_MARGIN = 50
# returns a float between 0 and one, how string the shot should be
func get_aim_strength() -> float:
	var dist = aim_point.position.length()
	dist = clamp(dist-MIN_AIM_MARGIN, 0, max_aim_dist)
	return dist/(max_aim_dist-MIN_AIM_MARGIN)

func get_stamina_percent() -> float:
	return clamp((cur_stamina - JUMP_COST) / (MAX_STAMINA-JUMP_COST), 0, 1)

func load_player_model(model_id : String):
	# Load model scene
	var model = load(GameData.PlayerModels[model_id]).instance()
	
	sprite.queue_free()
	sprite = model.get_node("Sprite")
	model.remove_child(sprite)
	add_child(sprite)
	
	collider.queue_free()
	collider = model.get_node("Collider")
	model.remove_child(collider)
	add_child(collider)
	
	parent.set_gamertag(model.name)
	
	# free model to prevent leaks
	model.queue_free()









