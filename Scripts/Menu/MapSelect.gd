extends HBoxContainer

var _is_focused := false

onready var map_list = GameData.Maps.keys()

signal map_changed(new_path)

export(Color) var color_normal = Color.white
export(Color) var color_focused = Color.green

var _cur_map_index : int = 0

onready var preview_image = $Preview/Panel/Image
onready var label = $Preview/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	self.focus_mode = Control.FOCUS_ALL
# warning-ignore:return_value_discarded
	self.connect("focus_entered", self, "_on_focus_entered")
# warning-ignore:return_value_discarded
	self.connect("focus_exited", self, "_on_focus_exited")
	
	$LeftArrow.visible = false
	$RightArrow.visible = false
	
	_change_map(0)


func _input(event):
	if _is_focused:
		if event.is_action_pressed("ui_right"):
			_change_map(1)
		elif event.is_action_pressed("ui_left"):
			_change_map(-1)

func _change_map(offset:int):
	_cur_map_index = int(fposmod(_cur_map_index + offset, len(map_list)))
	label.text = map_list[_cur_map_index]
	preview_image.texture = load(GameData.Maps[map_list[_cur_map_index]]["image"])
	emit_signal("map_changed", GameData.Maps[map_list[_cur_map_index]]["path"])

func _on_focus_entered():
	_is_focused = true
	$Preview/Label.modulate = color_focused
	$LeftArrow.modulate = color_focused
	$RightArrow.modulate = color_focused
	$LeftArrow.visible = true
	$RightArrow.visible = true

func _on_focus_exited():
	_is_focused = false
	$Preview/Label.modulate = color_normal
	$LeftArrow.modulate = color_normal
	$RightArrow.modulate = color_normal
	$LeftArrow.visible = false
	$RightArrow.visible = false
