extends Node2D

class_name Player

signal turn_done

onready var player_body = $PlayerBody
onready var turn_timer = $TurnTimer
onready var turn_queue = $".."
onready var tag = $GamerTag

var damage_popup_res = preload("res://SubScenes/DamagePopup.tscn")
var grave_res = preload("res://SubScenes/Grave.tscn")

export var MAX_HEALTH = 100
var health

export var player_model = "chicken1"
var team = "normal"

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
#	player_body.load_player_model(player_model)

func _process(_delta):
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
		elif event.is_action_pressed("ui_up"):
			MatchInfo.game_camera.zoom_in()
		elif event.is_action_pressed("ui_down"):
			MatchInfo.game_camera.zoom_out()
	
	# end turn functionality
	if is_my_turn:
		if event.is_action_pressed("end_turn"):
			end_turn()

	
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
#	MatchInfo.game_camera.reset_zoom()
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

func get_gamertag() -> String:
	return tag.get_node("VBoxContainer/Nametag").text

func set_gamertag(gamertag: String) -> void:
	tag.set_player_name(gamertag)

func get_timer_progress() -> float:
	# Return 1 if the timer is stopped (hasn't started yet)
	if turn_timer.is_stopped(): return 1.0
	# else calculate the value
	# Coyote time gives a buffer between the visible timer and actual turn end
	return clamp((turn_timer.time_left - MatchInfo.coyote_time) \
		/ (turn_timer.wait_time - MatchInfo.coyote_time), 0, 1)

func do_damage(value:int, source_player:String = "UNDEFINED") -> void:
	
	if is_invincible: return
	if is_dead: return
	
	# decrease health
	health = int(clamp(health-value, 0, MAX_HEALTH))
	
	# update stats
	MatchInfo.rec_damage(self.name, source_player, value)
	
	# create popup
	var damage_popup = damage_popup_res.instance()
	damage_popup.set_text("-" + str(value))
	damage_popup.set_color(Color.red)
	damage_popup.set_lifespan(1.0)
	damage_popup.position = player_body.position \
		+ Vector2(rand_range(-20, 20), rand_range(-10, 10))
	get_parent().level.add_child(damage_popup)
	
	update_healthbar()
	
	if health == 0:
		die(source_player)

func heal(amount: int):
	health = int(clamp(health+amount, 0, MAX_HEALTH))
	
	# create popup
	var damage_popup = damage_popup_res.instance()
	damage_popup.set_text("-" + str(amount))
	damage_popup.set_color(Color.green)
	damage_popup.set_lifespan(1.0)
	damage_popup.position = player_body.position \
		+ Vector2(rand_range(-20, 20), rand_range(-10, 10))
	get_parent().level.add_child(damage_popup)
	
	update_healthbar()

func set_team(new_team : String):
	self.team = new_team
	# Change color if this is a team match
	if MatchInfo.TEAM_MODE != "off":
		match team:
#			"normal": tag.set_tag_color(Color.white)
			"red": tag.set_tag_color(Color.red)
			"blue": tag.set_tag_color(Color.blue)
			"green": tag.set_tag_color(Color.green)

func update_healthbar():
	# Extra value added to helth to prevent invisivle low health
	tag.set_health_bar_value(float(health+2)/float(MAX_HEALTH))

func update_staminabar():
	tag.set_stamina_bar_value(player_body.get_stamina_percent())

# TODO: Death... State? Turn? Basically need to delete self more carefully
func die(source_player : String):
	if is_dead: return
	is_dead = true
	turn_queue.level.UI.do_deathtoast(get_gamertag())
	MatchInfo.rec_death(name, source_player)
	
	# add the grave
	var grave = grave_res.instance()
	grave.position = player_body.position
	MatchInfo.chest_holder.call_deferred("add_child", grave)
	
	# Check for team wipe
	if MatchInfo.TEAM_MODE != "off":
		var is_team_wipe = true
		for player in MatchInfo.player_info.values():
			if player.team == self.team and not player.is_dead:
				is_team_wipe = false
		if is_team_wipe:
			turn_queue.level.UI.do_wipetoast(team)
	
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
