extends Label

class_name Option

var _is_focused := false
var _is_active := false

export var option_id := "undefined_option"
export var choice_list : Array = ["1", "2", "3"]
var _cur_index : int = 0
onready var option_title := text

export var can_loop := true
export var prefix := "< "
export var postfix := " >"
export(Color) var color_normal = Color.white
export(Color) var color_focused = Color.green

# Called when the node enters the scene tree for the first time.
func _ready():
	self.focus_mode = Control.FOCUS_ALL
	_on_focus_exited()
	self.connect("focus_entered", self, "_on_focus_entered")
	self.connect("focus_exited", self, "_on_focus_exited")
	text = option_title + ": " + choice_list[_cur_index]

func _input(event):
	# Change to active/inactive
	if event.is_action_pressed("ui_accept") and _is_focused:
		_toggle_active()
	if _is_active:
		if event.is_action_pressed("ui_right"):
			_change_choice(1)
		if event.is_action_pressed("ui_left"):
			_change_choice(-1)
		if event.is_action_pressed("ui_up") \
		or event.is_action_pressed("ui_down"):
			_toggle_active()

func _toggle_active():
	if _is_active:
		_is_active = false
		text = option_title + ": " + choice_list[_cur_index]
		_set_sticky(false)
	else:
		_is_active = true
		text = prefix + choice_list[_cur_index] + postfix
		_set_sticky(true)

func _change_choice(offset:int):
	if can_loop:
		_cur_index = int(fposmod(_cur_index + offset, len(choice_list)))
	else:
		_cur_index = int(clamp(_cur_index + offset, 0, len(choice_list)-1))
	text = prefix + choice_list[_cur_index] + postfix

var saved_left_path
var saved_right_path
func _set_sticky(value : bool):
	if value == true:
		saved_left_path = focus_neighbour_left
		saved_right_path = focus_neighbour_right
		focus_neighbour_left = get_path()
		focus_neighbour_right = get_path()
	else:
		focus_neighbour_left = saved_left_path
		focus_neighbour_right = saved_right_path

func _on_focus_entered():
	_is_focused = true
	self.modulate = color_focused

func _on_focus_exited():
	_is_focused = false
	self.modulate = color_normal
