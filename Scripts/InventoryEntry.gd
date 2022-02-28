extends VBoxContainer

var id_string := "UNDEFINED INVENTORY ENTRY"
var pretty_name := "PRETTY_NAME"
var description := "THIS IS THE DEFAULT DESCRIPTION"
var count:int = -1

export(Color) var normal_color = Color.white
export(Color) var active_color = Color.green

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set count, or show infinity if it's a lot
	if count < 50:
		$Count.text = str(count)
	else:
		$Count.text = "∞"

func set_icon(path : String) -> void:
	$Img/Icon.set_texture(load(path))

func set_active(value : bool) -> void:
#	$Border.visible = value
	if value:
		$Img/Border.modulate = active_color
		$Count.modulate = active_color
	else:
		$Img/Border.modulate = normal_color
		$Count.modulate = normal_color

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
