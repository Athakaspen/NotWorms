extends RigidBody2D

var bomb = preload("res://SubScenes/Weapons/Bomb.tscn")

#var gravity := 400.0
var speed := 1500.0
var velocity := Vector2.ZERO
var bomb_velocity := 600.0
var jump_force := 300.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta: float) -> void:
	$RotPoint.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("shoot"):
		var b = bomb.instance()
		b.transform = $RotPoint/ShootPoint.global_transform
		get_parent().add_child(b)
		b.apply_central_impulse(b.transform.x * bomb_velocity * b.mass)
		

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("left"):
		#apply_central_impulse(-global_transform.x * speed * delta)
		apply_central_impulse(Vector2.LEFT * speed * delta)
	elif Input.is_action_pressed("right"):
		#apply_central_impulse(global_transform.x * speed * delta)
		apply_central_impulse(Vector2.RIGHT * speed * delta)
	
	if Input.is_action_just_pressed("jump"):
		apply_central_impulse(Vector2.UP * jump_force)
	
	if Input.is_action_just_pressed("power_up"):
			bomb_velocity += 20
			bomb_velocity = clamp(bomb_velocity, 100, 1500)
	elif Input.is_action_just_pressed("power_down"):
			bomb_velocity -= 20
			bomb_velocity = clamp(bomb_velocity, 100, 1500)
