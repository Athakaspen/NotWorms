extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	# This sets the randomness for everything
	randomize()

static func queue_free_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()

func _input(event):
	
	# use ESC to toggle mouse capture
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

static func rand_choice(arr : Array):
	return arr[randi() % arr.size()]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
