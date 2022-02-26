extends Position2D


onready var nametag = $VBoxContainer/Nametag
onready var healthbar = $VBoxContainer/HealthBar
onready var staminabar = $VBoxContainer/StaminaBar

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_health_bar_value(value : float):
	healthbar.value = value

func set_stamina_bar_value(value : float):
	staminabar.value = value

func set_player_name(value:String):
	nametag.text = value

func set_tag_color(value:Color):
	nametag.modulate = value

func set_turn_active(value):
	if value == true:
		staminabar.visible = true
	else:
		staminabar.visible = false
