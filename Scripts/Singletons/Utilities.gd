extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

static func queue_free_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
