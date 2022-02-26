extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal no_children

var cam_point

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if get_child_count() == 0:
		emit_signal("no_children")
		cam_point = Vector2.ZERO
	else:
		var acc = Vector2.ZERO
		for child in get_children():
			acc += child.position
		cam_point = acc / get_child_count()

func get_cam_point():
	if cam_point == Vector2.ZERO:
		return null
	return cam_point
