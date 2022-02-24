extends PanelContainer

var id_string := "UNDEFINED INVENTORY ENTRY"
var pretty_name := "PRETTY_NAME"
var description := "THIS IS THE DEFAULT DESCRIPTION"
var count:int = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_icon(path : String) -> void:
	$Icon.set_texture(load(path))

func set_active(value : bool) -> void:
	$Border.visible = value

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
