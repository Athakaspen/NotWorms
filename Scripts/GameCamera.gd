extends Camera2D

var zoom_level : float = 1
var _cur_zoom : float
export var MIN_ZOOM : float = 0.6
export var MAX_ZOOM : float = 1.0
export var ZOOM_STEP: float = 0.1
export var default_zoom := 0.8
export var zoom_speed := 0.08

# Whether this script should control the camera
var is_active = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Instantly jump to editor-specified zoom level
	pass

func _process(_delta):
	if is_active:
		_cur_zoom = lerp(_cur_zoom, zoom_level, zoom_speed)
		zoom = Vector2(1,1) * _cur_zoom

func set_active():
	is_active = true
	_cur_zoom = zoom.y
	zoom_level = default_zoom

func reset_zoom():
	zoom_level = default_zoom

func zoom_in():
	zoom_level = clamp(zoom_level - ZOOM_STEP, MIN_ZOOM, MAX_ZOOM)

func zoom_out():
	zoom_level = clamp(zoom_level + ZOOM_STEP, MIN_ZOOM, MAX_ZOOM)
