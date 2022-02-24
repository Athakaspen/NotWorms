extends Node2D

class_name Player

signal turn_done

onready var player_body = $PlayerBody
onready var turn_timer = $TurnTimer
onready var turn_queue = $".."
#onready var aim_point = $AimPoint
onready var tag = $GamerTag

#var controller_aim_speed = 1000
#var max_aim_dist = 600

export var MAX_HEALTH = 100
var health

# bool, is it this players turn or not
var is_my_turn := false
var is_dead := false
# this used to make sure you don't die after winning
var is_invincible := false
# Whether the player has the inventory menu pulled up
var inventory_open := false

var in_preturn := false

var inventory_contents := {}

# Called when the node enters the scene tree for the first time.
func _ready():
	tag.set_player_name(name)
	health = MAX_HEALTH
	update_healthbar()
	inventory_contents = MatchInfo.get_starting_inventory()

func _process(delta):
	# ah cahnt dyu aneethin if ahm ded
	#if is_dead: return
	
	# Stick tag to player's head
	tag.position = player_body.position + Vector2.UP * 50
	update_staminabar()

func _input(event):
	
	if in_preturn or is_my_turn:
		if event.is_action_pressed("menu_open"):
			open_inventory()
		elif event.is_action_released("menu_open"):
			# This also switches to the selected weapon
			close_inventory()

	
#	if event.is_action_pressed("menu_open"):
#		if not inventory_open:
#			open_inventory()
#		else:
#			Engine.time_scale = 1.0
#			# This also switches to the selected weapon
#			close_inventory()

func open_inventory():
	var cur_weapon = player_body.cur_weapon.id_string
	turn_queue.level.UI.show_inventory(inventory_contents, cur_weapon)
	inventory_open = true
	player_body.set_inventory_active(true)
	Engine.time_scale = MatchInfo.inventory_timescale

func close_inventory():
	var new_weapon:String = turn_queue.level.UI.hide_inventory()
	player_body.switch_weapon(new_weapon)
	inventory_open = false
	player_body.set_inventory_active(false)
	Engine.time_scale = MatchInfo.normal_timescale

# Decreases ammo for the specified weapon by one.
# Used after shooting.
func decrease_ammo(weapon_id : String) -> void:
	inventory_contents[weapon_id] -= 1

# Add the contents of the item_dict to the player's inventory. 
# Used to recieve items from chests.
func give(item_dict : Dictionary):
	for item in item_dict:
		assert(item in inventory_contents,\
			"Attempted to add an invalid weapon key to inventory")
		inventory_contents[item] += item_dict[item]

# This function is called when the "Ready Up" screen shows,
# before the actual turn begins. It's here to set up visuals mostly.
func init_preturn():
	in_preturn = true
#	aim_point.position = player_body.position
	player_body.set_state_preturn()
	tag.set_turn_active(true)

func play_turn(turn_dur:float) -> void:
	in_preturn = false
	# print("It's %s's turn!" % name)
	if is_dead: 
		end_turn()
		return
	
	is_my_turn = true
	turn_timer.wait_time = turn_dur
	
	# Set active player's body to active
	player_body.set_state_turn();
	turn_timer.start()
	
	# Don't return until we emit a signal
	yield(self, "turn_done")

func end_turn():
	if inventory_open: close_inventory()
	player_body.set_state_postturn()
	is_my_turn = false
	# Stop the timer if it's still going
	turn_timer.stop()
	emit_signal("turn_done")

func finish_turn():
	player_body.set_state_offturn()
	tag.set_turn_active(false)

func get_body() -> Node:
	return player_body

func get_timer_progress() -> float:
	# Return 1 if the timer is stopped (hasn't started yet)
	if turn_timer.is_stopped(): return 1.0
	# else calculate the value
	# Coyote time gives a buffer between the visible timer and actual turn end
	return clamp((turn_timer.time_left - MatchInfo.coyote_time) \
		/ (turn_timer.wait_time - MatchInfo.coyote_time), 0, 1)

func do_damage(value:int) -> void:
	
	if is_invincible: return
	if is_dead: return
	
	# decrease health
	health = int(clamp(health-value, 0, MAX_HEALTH))
	
	update_healthbar()
	
	if health == 0:
		die()

func update_healthbar():
	# Extra value added to helth to prevent invisivle low health
	tag.set_health_bar_value(float(health+2)/float(MAX_HEALTH))

func update_staminabar():
	tag.set_stamina_bar_value(player_body.get_stamina_percent())

# TODO: Death... State? Turn? Basically need to delete self more carefully
func die():
	if is_dead: return
	is_dead = true
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
		
		end_turn()
#		yield(self, "turn_done")
		
		# Replace queue_free with remove_child. A reference to the player node
		# is kept in MatchInfo for later.
		#self.queue_free()
		get_parent().remove_child(self)

func set_invincible():
	is_invincible = true

func _on_TurnTimer_timeout():
	end_turn()
