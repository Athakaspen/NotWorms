extends VBoxContainer

class_name CharacterSelectEntry

var _is_focused := false
var _is_active := false

onready var char_list = GameData.PlayerModels.keys()
onready var portrait = $Portrait

signal character_changed(player_index, new_id)

var _cur_index : int = 0
var player_model = null
const MAX_SCALE = 4

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
		elif event.is_action_pressed("ui_right") \
		or event.is_action_pressed("ui_left"):
			_toggle_active()

func _toggle_active():
	if _is_active:
		_is_active = false
		$UpArrow.visible = false
		$DownArrow.visible = false
		_set_sticky(false)
	else:
		_is_active = true
		$UpArrow.visible = true
		$DownArrow.visible = true
		_set_sticky(true)

func _change_char(offset:int):
	_cur_index = int(fposmod(_cur_index + offset, len(char_list)))
	if player_model != null:
		player_model.queue_free()
	player_model = load(GameData.PlayerModels[char_list[_cur_index]]).instance()
	add_child(player_model)
	$Label.text = player_model.name
	update_portrait()
	emit_signal("character_changed", get_index()-1, char_list[_cur_index])

func update_portrait():
	player_model.global_position = portrait.rect_global_position + (portrait.rect_size / 2)
	var new_scale = 1.1 * 0.01 * min(portrait.rect_size.x, portrait.rect_size.y)
	player_model.scale = Vector2(1,1) * min(new_scale, MAX_SCALE)

var saved_top_path
var saved_bottom_path
func _set_sticky(value : bool):
	if value == true:
		saved_top_path = focus_neighbour_top
		saved_bottom_path = focus_neighbour_bottom
		focus_neighbour_top = get_path()
		focus_neighbour_bottom = get_path()
	else:
		focus_neighbour_top = saved_top_path
		focus_neighbour_bottom = saved_bottom_path

func _on_focus_entered():
	_is_focused = true
	$Label.modulate = color_focused

func _on_focus_exited():
	_is_focused = false
	$Label.modulate = color_normal
