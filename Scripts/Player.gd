extends Node2D

class_name Player

signal turn_done

onready var player_body = $PlayerBody
onready var turn_timer = $TurnTimer
onready var turn_queue = $".."
onready var aim_point = $AimPoint

export var MAX_HEALTH = 100
var health

# bool, is it this players turn or not
var is_my_turn := false
var is_dead := false
# this used to make sure you don't die after winning
var is_invincible := false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Tag/PlayerNametag.text = name
	health = MAX_HEALTH
	update_healthbar()

func _process(_delta):
	# ah cahnt dyu aneethin if ahm ded
	#if is_dead: return
	
	aim_point.global_position = get_global_mouse_position()
	
	# Stick tag to player's head
	$Tag.position = $PlayerBody.position + Vector2.UP * 50

# This function is called when the "Ready Up" screen shows,
# before the actual turn begins. It's here to set up visuals mostly.
func init_preturn():
	player_body.init_preturn()

func play_turn(turn_dur:float) -> void:
	# print("It's %s's turn!" % name)
	
	is_my_turn = true
	turn_timer.wait_time = turn_dur
	
	# Set active player's body to active
	player_body.set_turn_active(true);
	turn_timer.start()
	
	# Don't return until we emit a signal
	yield(self, "turn_done")

#func wait_end_turn(dur : float):
#	yield(get_tree().create_timer(dur), "timeout")
#	end_turn()

func end_turn():
	player_body.set_turn_active(false)
	is_my_turn = false
	# Stop the timer if it's still going
	turn_timer.stop()
	emit_signal("turn_done")

func get_body() -> Node:
	return player_body

func get_timer_progress() -> float:
	# Return 1 if the timer is stopped (hasn't started yet)
	if turn_timer.is_stopped(): return 1.0
	# else calcualte the value
	return turn_timer.time_left/turn_timer.wait_time

func do_damage(value:int) -> void:
	
	if is_invincible: return
	
	# decrease health
	health = int(clamp(health-value, 0, MAX_HEALTH))
	
	update_healthbar()
	
	if health == 0:
		die()

func update_healthbar():
	$Tag/HealthBar.value = float(health)/float(MAX_HEALTH)

# TODO: Death... State? Turn? Basically need to delete self more carefully
func die():
	turn_queue.level.UI.do_deathtoast(name)
	MatchInfo.rec_death(name)
	if not is_my_turn:
		
		# Replace queue_free with remove_child. A reference to the player node
		# is kept in MatchInfo for later.
		#self.queue_free()
		get_parent().remove_child(self)
		
	else:
		self.visible = false
		player_body.sleeping = true
		yield(self, "turn_done")
		
		# Replace queue_free with remove_child. A reference to the player node
		# is kept in MatchInfo for later.
		#self.queue_free()
		get_parent().remove_child(self)

func set_invincible():
	is_invincible = true

func _on_TurnTimer_timeout():
	end_turn()
