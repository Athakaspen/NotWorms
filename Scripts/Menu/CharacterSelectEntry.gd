extends VBoxContainer

class_name CharacterSelectEntry

var _is_focused := false
var _is_active := false

onready var char_list = GameData.PlayerModels.keys()
onready var team_list = GameData.TeamIDs
onready var MIN_TEAM_IDX = 0
onready var MAX_TEAM_IDX = len(team_list)-1

onready var portrait = $Portrait

signal character_changed(player_index, new_id)
signal team_changed(player_index, new_id)

var _cur_char_index : int = 0
var _cur_team_index : int = 0
var player_model = null
const MAX_SCALE = 4.5

export(Color) var color_normal = Color.white
export(Color) var color_focused = Color.green

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set up focus
	self.focus_mode = Control.FOCUS_ALL
	_on_focus_exited()
# warning-ignore:return_value_discarded
	self.connect("focus_entered", self, "_on_focus_entered")
# warning-ignore:return_value_discarded
	self.connect("focus_exited", self, "_on_focus_exited")
# warning-ignore:return_value_discarded
	self.connect("resized", self, "update_portrait")
	
	_change_char(0)
#	yield(get_tree(), "idle_frame")
#	update_portrait()

#func _process(_delta):
#	update_portrait()

func _input(event):
	# Change to active/inactive
	if event.is_action_pressed("ui_accept") and _is_focused:
		_toggle_active()
	if _is_active:
		if event.is_action_pressed("ui_down"):
			_change_char(1)
		elif event.is_action_pressed("ui_up"):
			_change_char(-1)
		if event.is_action_pressed("ui_right"):
			_change_team(1)
		elif event.is_action_pressed("ui_left"):
			_change_team(-1)
		elif event.is_action_pressed("ui_right") \
		or event.is_action_pressed("ui_left"):
			_toggle_active()

func _toggle_active():
	if _is_active:
		_is_active = false
		$UpArrow.visible = false
		$DownArrow.visible = false
#		$Team.visible = false
		update_team_text()
		_set_sticky(false)
	else:
		_is_active = true
		$UpArrow.visible = true
		$DownArrow.visible = true
#		$Team.visible = true
		update_team_text()
		_set_sticky(true)

func _change_char(offset:int):
	_cur_char_index = int(fposmod(_cur_char_index + offset, len(char_list)))
	if player_model != null:
		player_model.queue_free()
	player_model = load(GameData.PlayerModels[char_list[_cur_char_index]]).instance()
	add_child(player_model)
	$Label.text = player_model.name
	update_portrait()
	_change_team(0) # update the new model to the current team
	emit_signal("character_changed", get_index(), char_list[_cur_char_index])

func _change_team(offset:int):
	_cur_team_index = \
		MIN_TEAM_IDX + \
		int(fposmod( \
			(_cur_team_index-MIN_TEAM_IDX) + offset, \
			(MAX_TEAM_IDX+1) - MIN_TEAM_IDX))
	for child in player_model.get_children():
		child.visible = false
	player_model.get_node(team_list[_cur_team_index]).visible = true
	update_team_text()
	emit_signal("team_changed", get_index(), team_list[_cur_team_index])

func update_team_text():
	if _is_active:
		$Team.text = "<" + team_list[_cur_team_index].to_upper() + ">"
	else:
		$Team.text = team_list[_cur_team_index].to_upper()

func set_team_mode(mode : String):
	match mode:
		"off":
			MIN_TEAM_IDX = 0
			MAX_TEAM_IDX = len(team_list)-1
			$Team.visible = true
		"two":
			MIN_TEAM_IDX = 1
			MAX_TEAM_IDX = 2
			$Team.visible = true
		"three":
			MIN_TEAM_IDX = 1
			MAX_TEAM_IDX = 3
			$Team.visible = true
# warning-ignore:narrowing_conversion
	_cur_team_index = clamp(_cur_team_index, MIN_TEAM_IDX, MAX_TEAM_IDX)
	_change_team(0)

func update_portrait():
	player_model.global_position = portrait.rect_global_position + (portrait.rect_size / 2)
	var new_scale = 1.1 * 0.01 * min(portrait.rect_size.x, portrait.rect_size.y)
	player_model.scale = Vector2(1,1) * min(new_scale, MAX_SCALE)

var saved_top_path
var saved_bottom_path
var saved_left_path
var saved_right_path
func _set_sticky(value : bool):
	if value == true:
		saved_top_path = focus_neighbour_top
		saved_left_path = focus_neighbour_left
		saved_right_path = focus_neighbour_right
		saved_bottom_path = focus_neighbour_bottom
		focus_neighbour_top = get_path()
		focus_neighbour_left = get_path()
		focus_neighbour_right = get_path()
		focus_neighbour_bottom = get_path()
	else:
		focus_neighbour_top = saved_top_path
		focus_neighbour_left = saved_left_path
		focus_neighbour_right = saved_right_path
		focus_neighbour_bottom = saved_bottom_path

func _on_focus_entered():
	_is_focused = true
	$Label.modulate = color_focused
	$Team.modulate = color_focused
	$UpArrow.modulate = color_focused
	$DownArrow.modulate = color_focused

func _on_focus_exited():
	_is_focused = false
	$Label.modulate = color_normal
	$Team.modulate = color_normal
