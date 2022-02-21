extends RigidBody2D

class_name PlayerBody

var bomb = preload("res://SubScenes/Weapons/Bomb.tscn")

export var move_force := 1100.0
export var MAX_SPEED = 400
export var H_damping := 3.0
export var bomb_velocity := 600.0
export var jump_force := 350.0
export var air_jump_scalar := 0.65

onready var parent = $".."

var is_active := false

# Called when the node enters the scene tree for the first time.
func _ready():
	set_turn_active(false)

func init_preturn():
	$RotPoint.visible = true

func set_turn_active(value:bool) -> void:
	# Set to inactive
	if value == false:
		is_active = false
		$RotPoint.visible = false
	
	# Set to active
	elif value == true:
		is_active = true
		$RotPoint.visible = true

func _process(_delta: float) -> void:
	
	# Bail if it's not ur turn
	if not is_active: return
	
	$RotPoint.look_at(parent.aim_point.global_position)
	
#	if Input.is_action_just_pressed("shoot"):
#		var b = bomb.instance()
#		b.transform = $RotPoint/ShootPoint.global_transform
#		get_parent().add_child(b)
#		b.apply_central_impulse(b.transform.x * bomb_velocity * b.mass)

func _unhandled_input(event: InputEvent) -> void:
	
	# Bail if it's not ur turn
	if not is_active: return
	
	if event.is_action_pressed("shoot"):
		var b = bomb.instance()
		b.transform = $RotPoint/ShootPoint.global_transform
		parent.turn_queue.level.projectile_holder.add_child(b)
		b.apply_central_impulse(b.transform.x * bomb_velocity * b.mass)

func _physics_process(delta: float) -> void:
	
	# No input-based movement if it's not ur turn
	if not is_active:
		# Horizontal-only damping (so gravity feels heavier
		apply_central_impulse(Vector2(-linear_velocity.x * H_damping * delta * mass, 0))
		return
	
	# Standard Movement
	if Input.is_action_pressed("left") and linear_velocity.x > -MAX_SPEED:
		#apply_central_impulse(-global_transform.x * move_force * delta)
		apply_central_impulse(Vector2.LEFT * move_force * delta * mass)
	elif Input.is_action_pressed("right") and linear_velocity.x < MAX_SPEED:
		#apply_central_impulse(global_transform.x * move_force * delta)
		apply_central_impulse(Vector2.RIGHT * move_force * delta * mass)
	else:
		# Horizontal-only damping (so gravity feels heavier
		apply_central_impulse(Vector2(-linear_velocity.x * H_damping * delta * mass, 0))
	
	# Jumping
	if Input.is_action_just_pressed("jump"):
		
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



#	if Input.is_action_just_pressed("power_up"):
#			bomb_velocity += 20
#			bomb_velocity = clamp(bomb_velocity, 100, 1500)
#	elif Input.is_action_just_pressed("power_down"):
#			bomb_velocity -= 20
#			bomb_velocity = clamp(bomb_velocity, 100, 1500)
